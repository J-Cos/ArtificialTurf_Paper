#1: Sample testing
    #packages
        library(sp)
        library(terra)
        library(raster)
        library(rgdal)
        library(randomForest)
        library(caret)
        library(tidyverse)
        library(RStoolbox)

    #load project functions
        function_files<-list.files(file.path("Code","Functions"))
        sapply(file.path("Code","Functions",function_files),source)

#2. Load Data
    # Importing satellite data #
        p19 <- raster::brick(file.path("Data", "Stevenage", "clipped2019.tif")) %>%
                    AddAllAvailableIndices
        saveRDS(p19,file.path("Outputs", "CompleteRasterStack_2019.RDS") )
        png(file.path("Outputs",paste0("View2019", Sys.Date(),".png")), height = 8.3, width = 11.7, units = 'in', res = 300)
            raster::plotRGB(p19, r=3, g=2, b=1, stretch="lin")
        dev.off()

        p15 <- raster::brick(file.path("Data", "Stevenage", "clipped2015.tif")) %>%
                    AddAllAvailableIndices
        saveRDS(p15,file.path("Outputs", "CompleteRasterStack_2015.RDS") )
        png(file.path("Outputs",paste0("View2015", Sys.Date(),".png")), height = 8.3, width = 11.7, units = 'in', res = 300)
            raster::plotRGB(p15, r=3, g=2, b=1, stretch="lin")
        dev.off()

    # Load training and validation polygons #
    # And setting coordinate reference system to match imagery
        tv_list<-list(
            "t15"=LoadTestTrainData(TestTrain="training2015", pleiades=p15),
            "v15"=LoadTestTrainData(TestTrain="validation2015", pleiades=p15),
            "t19"=LoadTestTrainData(TestTrain="training2019", pleiades=p19),
            "v19"=LoadTestTrainData(TestTrain="validation2019", pleiades=p19)
        )

#3. Run Random Forests
    p15_rf<-RunRandomForestClassification(data=p15, tp=tv_list[["t15"]], vp=tv_list[["v15"]])
    #p19_rf<-RunRandomForestClassification(data=p19, tp=tv_list[["t19"]], vp=tv_list[["v19"]])
#4. Misc
    #Comparing classified maps and extracting land cover statistics # 
        #crossTabulation <- crosstab(Vision_rf[["randomForestPrediction"]], Planet_rf[["randomForestPrediction"]], long = TRUE) # Using cross tabulation # different extents
        landcover_15_df<-GetClassCoverageDf(sc=p15_rf[["randomForestPrediction"]], resPl=res(p15) )
        #landcover_19_df<-GetClassCoverageDf(sc=p19_rf[["randomForestPrediction"]], resPl=res(p19) )

#5.Save Output
    write.csv(p15_rf$IndependentValidation$overall, file=file.path("Outputs", "p15_ValidationStats.csv"))
    #write.csv(p19_rf$IndependentValidation$overall, file=file.path("Outputs", "p19_ValidationStats.csv"))


######################
# END OF CODE ########
######################
