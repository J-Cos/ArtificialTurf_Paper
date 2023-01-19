#1: Dependencies and Parameters
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
        pleiades2015 <- brick("clipped2015.tif")
        pleiades2019 <- brick("clipped2019.tif")
        #plotRGB(pleiades2015, r=1, g=2, b=3, stretch="lin")
        #plotRGB(pleiades2019, r=1, g=2, b=3, stretch="lin")

    # Loading training and validation polygons #
    # And setting coordinate reference system to match imagery
        tp2015 <- readOGR(dsn = "Data", layer="training2015")  %>% spTransform(crs(pleiades2015))
        vp2015 <- readOGR(dsn = "Data", layer="validpoints15") %>% spTransform(crs(pleiades2015))
        tp2019 <- readOGR(dsn = "Data", layer="newtrainingdata2019") %>% spTransform(crs(pleiades2019))
        vp2019 <- readOGR(dsn="Data", layer = "validpoints19") %>%  spTransform( crs(pleiades2019))

    # Calculating spectral indices #
    #hashed out as not seemingly used downstream - confirm and delete
        #indexstack15<- spectralIndices(pleiades2015, red = "clipped2015.3", green = "clipped2015.2", blue = "clipped2015.1", nir = "clipped2015.4") # Additional indices created using raster calculator in QGIS 
        #indexstack19<- spectralIndices(pleiades2019, red = "clipped2019.3", green = "clipped2019.2", blue = "clipped2019.1", nir = "clipped2019.4")

#3. Run Random Forests
    RandFor15<-RunRandomForestClassification(pleiades=pleiades2015, tp=tp2015, vp=vp2015, SupervisedClassifictionTIF="mod15sc.tif")
    RandFor19<-RunRandomForestClassification(pleiades=pleiades2019, tp=tp2019, vp=vp2019, SupervisedClassifictionTIF="mod19sc.tif")

#4. Misc
    #Comparing classified maps and extracting land cover statistics # 
        crossTabulation <- crosstab(RandFor15[["supervisedClassification"]], RandFor19[["supervisedClassification"]], long = TRUE) # Using cross tabulation
        landcover15_df<-GetClassCoverageDf(sc=RandFor15[["supervisedClassification"]], resPl=res(pleiades2015) )
        landcover19_df<-GetClassCoverageDf(sc=RandFor19[["supervisedClassification"]], resPl=res(pleiades2019) )

#5.Save Output
    #TBC

######################
# END OF CODE ########
######################
