#########################
# Conduct supervised classification
##########################

#1: Dependencies
    #packages
        library(terra)
        library(randomForest)
        library(tidyverse)

    #load project functions
        function_files<-list.files(file.path("Code","Functions"))
        sapply(file.path("Code","Functions",function_files),source)

    # Parameters
        ExcludeShadow<-TRUE
        ExcludeWater<-FALSE
        BandNames<-c("clipped2015_1", "clipped2015_2", "clipped2015_3", "clipped2015_4", "CTVI" ,
            "DVI", "EVI", "GEMI", "GNDVI","KNDVI", "MSAVI", "MSAVI2", "NDVI", 
            "NDWI" ,"NRVI", "RVI", "SAVI", "SR", "TTVI", "TVI",  "WDVI")
        IndicesToUse<-c(1,2,3,4,13,14)

#2. Load Data
    # Importing satellite data #
        p15<-terra::rast(file.path("Outputs", "AllIndices_p15.tif"))%>%
            raster::subset(., IndicesToUse)
        p19<-terra::rast(file.path("Outputs", "AllIndices_p19.tif"))

    # Load training and validation points #
        TestTrain<-readRDS( file.path("Outputs", "TestTrainPoints.RDS") )

        if (ExcludeShadow & !ExcludeWater) {
            # update excluding function to all when 2019 ready as well
            TestTrain<-ExcludeClassFromTestTrain(TestTrain, "Shadow")
            TrainingClassId<-"NoShadow_"
        } else if (ExcludeShadow & ExcludeWater) {
            TestTrain<-ExcludeClassFromTestTrain(TestTrain, "Shadow") %>%
                ExcludeClassFromTestTrain(., "Water") 
            TrainingClassId<-"NoShadowOrWater_"
        } else if (!ExcludeShadow & !ExcludeWater) {
            TrainingClassId<-NULL
        } else if (!ExcludeShadow & ExcludeWater) {
            TestTrain<-ExcludeShadowFromTestTrain(TestTrain, "Water")
            TrainingClassId<-"NoWater_"
        } 

#3. Run Classifications and save output

    set.seed(1) 

    #fit random forests and classify
        #2015
            #tune rf
                model_tuned <- randomForest::tuneRF(
                    x=select(TestTrain[["train15"]][["pointVals"]], !response), #define predictor variables
                    y=TestTrain[["train15"]][["pointVals"]]$response, #define response variable
                    ntreeTry=1001,
                    mtryStart=2, 
                    stepFactor=1.5,
                    improve=0.001,
                    trace=TRUE #don't show real-time progress
                )
            #optimum mtry 
                #near 10 for all bands
                #3 for spectral +ndvi
            #error rates stabilise by 500 trees - visible with plot(mod15)


            mod15 <- randomForest::randomForest(response ~ ., data=TestTrain[["train15"]][["pointVals"]], na.action=na.omit, ntree=501, mtry=3, confusion=TRUE)
            sc15 <- terra::predict(object=p15, 
                                    model=mod15, 
                                    type="response",
                                    filename=file.path("Outputs", paste0(TrainingClassId, "sc15.tif")), 
                                    format="GTiff", 
                                    datatype="INT1U",
                                    overwrite=TRUE)
        #2019
            mod19 <- randomForest::randomForest(response ~ ., data=TestTrain[["train19"]][["pointVals"]], na.action=na.omit, ntree=501, mtry=10, confusion=TRUE)
            sc19 <- terra::predict(object=p19, 
                                    model=mod19, 
                                    type="response",
                                    filename=file.path("Outputs", paste0(TrainingClassId, "sc19.tif")), 
                                    format="GTiff", 
                                    datatype="INT1U",
                                    overwrite=TRUE)


#4. save outputs
    #saving random forest models - (classification rasters written to file by functions)
        saveRDS(mod15, file.path("Outputs", paste0(TrainingClassId,"RandomForestModel_15")))
        saveRDS(mod19, file.path("Outputs", paste0(TrainingClassId,"RandomForestModel_19")))
