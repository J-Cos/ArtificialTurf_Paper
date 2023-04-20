#1: Sample testing
    # Loading required packages # 
        require(raster)
        require(rgdal)
        require(RStoolbox)
        require(randomForest)
        require(caret)
        require(landscapemetrics)
        require(tidyverse)
    #load project functions
        function_files<-list.files("Functions")
        sapply(file.path("Functions",function_files),source)

#2. Load Data
    # Importing satellite data #
        planet <- brick(file.path("Data", "Planet", "20220807_104951_87_241_Clip.tif"))
        vision <- brick(file.path("Data", "Vision", "Sample_Vision_1_improved_5Km2.tif"))
    
        png(file.path("Outputs",paste0("ViewPlanet", Sys.Date(),".png")), height = 8.3, width = 11.7, units = 'in', res = 300)
            plotRGB(planet, r=1, g=2, b=3, stretch="lin")
        dev.off()

        png(file.path("Outputs",paste0("ViewVision", Sys.Date(),".png")), height = 8.3, width = 11.7, units = 'in', res = 300)
            plotRGB(vision, r=1, g=2, b=3, stretch="lin")
        dev.off()

    # Loading training and validation polygons #
    # And setting coordinate reference system to match imagery
        p <- readOGR(dsn = file.path("Data", "ReferenceData"), layer="north_ken_test_train")  %>% spTransform(crs(vision))
        trainIndices<-sample(1:length(p), 24)
        tp<-p[trainIndices,]
        vp<-p[-trainIndices,]

    # Calculating spectral indices #
    #hashed out as not seemingly used downstream - confirm and delete
        #indexstack15<- spectralIndices(pleiades2015, red = "clipped2015.3", green = "clipped2015.2", blue = "clipped2015.1", nir = "clipped2015.4") # Additional indices created using raster calculator in QGIS 
        #indexstack19<- spectralIndices(pleiades2019, red = "clipped2019.3", green = "clipped2019.2", blue = "clipped2019.1", nir = "clipped2019.4")

#3. Run Random Forests
    classes<-factor(c(1,2))

    Vision_rf<-RunRandomForestClassification(pleiades=vision, tp=tp, vp=vp, classes=classes)
    Planet_rf<-RunRandomForestClassification(pleiades=planet, tp=tp, vp=vp, classes=classes)

#4. Misc
    #Comparing classified maps and extracting land cover statistics # 
        #crossTabulation <- crosstab(Vision_rf[["randomForestPrediction"]], Planet_rf[["randomForestPrediction"]], long = TRUE) # Using cross tabulation # different extents
        landcover_vision_df<-GetClassCoverageDf(sc=Vision_rf[["randomForestPrediction"]], resPl=res(vision) )
        landcover_planet_df<-GetClassCoverageDf(sc=Planet_rf[["randomForestPrediction"]], resPl=res(planet) )

#5.Save Output
    write.csv(Vision_rf$IndependentValidation$overall, file=file.path("Outputs", "VisionValidationStats.csv"))
    write.csv(Planet_rf$IndependentValidation$overall, file=file.path("Outputs", "PlanetValidationStats.csv"))


######################
# END OF CODE ########
######################
