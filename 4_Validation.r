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
        sc15<-terra::rast(file.path("Outputs", "sc15.tif"))
        sc19<-terra::rast(file.path("Outputs", "sc19.tif"))

    # Load training and validation polygons #
    # And setting coordinate reference system to match imagery
        tv_list<-list(
            "t15"=LoadTestTrainData(TestTrain="training2015", pleiades=p15),
            "v15"=LoadTestTrainData(TestTrain="validation2015", pleiades=p15),
            "t19"=LoadTestTrainData(TestTrain="training2019", pleiades=p19),
            "v19"=LoadTestTrainData(TestTrain="validation2019", pleiades=p19)
        )

#3 
    cm15<-RunIndependentValidation(data= sc15, vp=tv_list[["v15"]])
    cm19<-RunIndependentValidation(data= sc19, vp=tv_list[["v19"]])

#4. Save stats outputs
    #Comparing classified maps and extracting land cover statistics # 
        #crossTabulation <- crosstab(Vision_rf[["randomForestPrediction"]], Planet_rf[["randomForestPrediction"]], long = TRUE) # Using cross tabulation # different extents
        WriteClassCoverageCsv(sc=sc15, resPl=res(p15), name="p15")
        WriteClassCoverageCsv(sc=sc19, resPl=res(p19), name="p19")
    # confusion matrices
        WriteConfusionMatrixCsvs(cm15, "p15")
        WriteConfusionMatrixCsvs(cm19, "p19")