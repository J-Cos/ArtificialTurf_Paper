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

    # Parameters
        ExcludeShadow<-FALSE
        
#2. Load Data

    # Load training and validation polygons #
    # And setting coordinate reference system to match imagery
        TestTrain<-readRDS( file.path("Outputs", "TestTrainPoints.RDS") )

        if (ExcludeShadow) {
            # update excluding function to all when 2019 ready as well
            TestTrain<-ExcludeShadowFromTestTrain(TestTrain)
            ShadowId<-"NoShadow_"
            plotCols<-c("green", "grey", "red", "blue")
        } else {
            ShadowId<-NULL
            plotCols<-c("green", "grey", "red", "blue", "black")

        }


    # Importing satellite data #
        sc15<-raster::brick(file.path("Outputs", paste0(ShadowId, "sc15.tif")))
        sc19<-raster::brick(file.path("Outputs", paste0(ShadowId, "sc19.tif")))

#3 
    cm15<-RunIndependentValidation(data= sc15, vp=TestTrain[["test15"]])
    cm19<-RunIndependentValidation(data= sc19, vp=TestTrain[["test19"]])

#4. save outputs
    
    # make visualisation of the classification
        png(file.path("Figures",paste0("View_", ShadowId, "sc15.png")), height = 8.3, width = 11.7, units = 'in', res = 300)
            terra::rast(sc15) %>% 
                terra::plot(., 
                    legend=TRUE,  col=plotCols,  main=paste0(ShadowId,"Supervised Classification"))
        dev.off()


    #Save stats outputs
    #Comparing classified maps and extracting land cover statistics # 
        #crossTabulation <- crosstab(Vision_rf[["randomForestPrediction"]], Planet_rf[["randomForestPrediction"]], long = TRUE) # Using cross tabulation # different extents
        #WriteClassCoverageCsv(sc=sc15, resPl=res(sc15), name="sc15")
        #WriteClassCoverageCsv(sc=sc19, resPl=res(p19), name="p19")
    # confusion matrices
        WriteConfusionMatrixCsvs(cm15, paste0(ShadowId, "p15"))
        WriteConfusionMatrixCsvs(cm19, paste0(ShadowId, "p19"))