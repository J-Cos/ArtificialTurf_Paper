#########################
# Conduct supervised classification
##########################

#1: Dependencies
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
    ExcludeShadow<-TRUE

#2. Load Data
    # Importing satellite data #
        #p15<-readRDS(file.path("Outputs", "CompleteRasterStack_2015.RDS") )
        #p19<-readRDS(file.path("Outputs", "CompleteRasterStack_2019.RDS") )
        p15<-terra::rast(file.path("Outputs", "AllIndices_p15.tif"))
        p19<-terra::rast(file.path("Outputs", "AllIndices_p19.tif"))

    # Load training and validation points #
        TestTrain<-readRDS( file.path("Outputs", "TestTrainPoints.RDS") )

        if (ExcludeShadow) {
            # update to all when 2019 ready as well
            ExcludeShadowFromTestTrain<-function(TestTrain){
                for (i in c(1,3) ) { 
                    keep<-TestTrain[[i]][["pointVals"]]$response != "Shadow"

                    TestTrain[[i]][["pointVals"]]<-TestTrain[[i]][["pointVals"]][keep,] %>% droplevels()
                    TestTrain[[i]][["NumberCellsPerCategory"]] <-TestTrain[[i]][["NumberCellsPerCategory"]] [ names(TestTrain[[i]][["NumberCellsPerCategory"]]) != "Shadow" ]
                    TestTrain[[i]][["points"]]<-TestTrain[[i]][["points"]][keep,]
                }
                return(TestTrain)
            }

            TestTrain<-ExcludeShadowFromTestTrain(TestTrain)
            ShadowId<-"NoShadow_"
        } else {ShadowId<-NULL}


#3. Run Classifications and save output

    set.seed(1) 

    #fit random forests and classify
        #2015
            #tune rf
                model_tuned <- randomForest::tuneRF(
                    x=select(TestTrain[["train15"]][["pointVals"]], !response), #define predictor variables
                    y=TestTrain[["train15"]][["pointVals"]]$response, #define response variable
                    ntreeTry=301,
                    mtryStart=4, 
                    stepFactor=1.4,
                    improve=0.001,
                    trace=TRUE #don't show real-time progress
                )
            #optimum mtry near 10
            #error rates stabilise by 500 trees - visible with plot(mod15)


            mod15 <- randomForest::randomForest(response ~ ., data=TestTrain[["train15"]][["pointVals"]], na.action=na.omit, ntree=501, mtry=10, confusion=TRUE)
            sc15 <- terra::predict(object=p15, 
                                    model=mod15, 
                                    type="response",
                                    filename=file.path("Outputs", paste0(ShadowId, "sc15.tif")), 
                                    format="GTiff", 
                                    datatype="INT1U",
                                    overwrite=TRUE)
        #2019
            mod19 <- randomForest::randomForest(response ~ ., data=TestTrain[["train19"]][["pointVals"]], na.action=na.omit, ntree=501, mtry=10, confusion=TRUE)
            sc19 <- terra::predict(object=p19, 
                                    model=mod19, 
                                    type="response",
                                    filename=file.path("Outputs", paste0(ShadowId, "sc19.tif")), 
                                    format="GTiff", 
                                    datatype="INT1U",
                                    overwrite=TRUE)


#4. save outputs
    #saving random forest models - (classification rasters written to file by functions)
        saveRDS(mod15, file.path("Outputs", paste0(ShadowId,"RandomForestModel_15")))
        saveRDS(mod19, file.path("Outputs", paste0(ShadowId,"RandomForestModel_19")))
