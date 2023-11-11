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

    MakeConfusionTable<-function(modelConfusionMatrix) {
        ConfTable<-modelConfusionMatrix %>% as.data.frame 
        ConfTable<-ConfTable[-5]
        ConfTable$Correct<-diag(modelConfusionMatrix)
        ConfTable$Total<-rowSums(ConfTable) - ConfTable$Correct
        ConfTable['PA(%)']<-round(ConfTable$Correct/ConfTable$Total, 3)*100
        ConfTable<-rbind(ConfTable, 
                        c(diag(modelConfusionMatrix), sum(ConfTable$Correct), "", "") )
        ConfTable<-rbind(ConfTable,
                        c(colSums(as.data.frame(modelConfusionMatrix)[-5]), "", sum(as.numeric(ConfTable$Total), na.rm=TRUE), ""))
        ConfTable<-rbind(ConfTable, 
                        c(round(as.numeric(ConfTable[5,1:4])/as.numeric(ConfTable[6,1:4] ),3)*100, "", "", ""))

        colnames(ConfTable)<-c("Vegetation", "Man-made", "Artificial Turf", "Water", "Correct", "Total", "PA(%)")
        rownames(ConfTable)<-c("Vegetation", "Man-made", "Artificial Turf", "Water", "Correct", "Total", "UA(%)")

        return(ConfTable)
    }

    # Parameters
        ExcludeShadow<-TRUE
        ExcludeWater<-FALSE

#2. Load Data
    # Load training and validation points #
        TestTrain<-readRDS( file.path("Outputs", "TestTrainPoints.RDS") )
        p15 <-  terra::rast(file.path("Outputs", "AllIndices_p15.tif"))
        p15seg<- terra::rast("Outputs/SegmentSummaryRaster_p15.tif")


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
        #tune rfs
            #2015
                #tune rf
                    model_tuned <- randomForest::tuneRF(
                        x=select(TestTrain[["train15"]][["pointVals"]], !c(response, ID)), #define predictor variables
                        y=TestTrain[["train15"]][["pointVals"]]$response, #define response variable
                        ntreeTry=1001,
                        mtryStart=2, 
                        stepFactor=1.5,
                        improve=0.001,
                        trace=TRUE #don't show real-time progress
                    )
                #optimum mtry 
                    #2
                #error rates stabilise by 500 trees - visible with plot(mod15)
            #segmentation
                #tune rf
                    model_tuned <- randomForest::tuneRF(
                        x=select(TestTrain[["train15seg"]][["pointVals"]], !c(response, ID)), #define predictor variables
                        y=TestTrain[["train15seg"]][["pointVals"]]$response, #define response variable
                        ntreeTry=1001,
                        mtryStart=2, 
                        stepFactor=1.5,
                        improve=0.001,
                        trace=TRUE #don't show real-time progress
                    )
                #optimum mtry =2 for seg
                #error rates stabilise by 500 trees - visible with plot(mod15seg)
        # fit train test rfs
            mod15 <- randomForest::randomForest(x=select(TestTrain[["train15"]][["pointVals"]], !c(response, ID)), 
                                                xtest= select(TestTrain[["test15"]][["pointVals"]], !c(response, ID)) , 
                                                y=TestTrain[["train15"]][["pointVals"]]$response, 
                                                ytest= TestTrain[["test15"]][["pointVals"]]$response , 
                                                na.action=na.omit, 
                                                ntree=3001, 
                                                mtry=2, 
                                                confusion=TRUE)
                
            mod15seg <- randomForest::randomForest(x=select(TestTrain[["train15seg"]][["pointVals"]], !c(response, ID)), 
                                                xtest= select(TestTrain[["test15seg"]][["pointVals"]], !c(response, ID)) , 
                                                y=TestTrain[["train15seg"]][["pointVals"]]$response, 
                                                ytest= TestTrain[["test15seg"]][["pointVals"]]$response , 
                                                na.action=na.omit, 
                                                ntree=3001, 
                                                mtry=2, 
                                                confusion=TRUE)

        #save table 3
            MakeConfusionTable(mod15[["test"]][["confusion"]]) %>%
                write.csv("Figures/Table3a.csv")    
            MakeConfusionTable(mod15seg[["test"]][["confusion"]]) %>%
                write.csv("Figures/Table3b.csv")    


    #make land cover map
    set.seed(1) 

            mod15 <- randomForest::randomForest(response ~ ., data=select(TestTrain[["train15"]][["pointVals"]], !ID), na.action=na.omit, ntree=3001, mtry=2, confusion=TRUE)
            sc15 <- terra::predict(object=p15, 
                                    model=mod15, 
                                    type="response",
                                    filename=file.path("Outputs", "landcover_15.tif"), 
                                    format="GTiff", 
                                    datatype="INT1U",
                                    overwrite=TRUE)

            mod15seg <- randomForest::randomForest(response ~ ., data=select(TestTrain[["train15seg"]][["pointVals"]], !ID), na.action=na.omit, ntree=3001, mtry=2, confusion=TRUE)
            sc15seg <- terra::predict(object=p15seg, 
                                    model=mod15seg, 
                                    type="response",
                                    filename=file.path("Outputs", "landcover_15seg.tif"), 
                                    format="GTiff", 
                                    datatype="INT1U",
                                    overwrite=TRUE)


#4. save outputs
    #saving random forest models - (classification rasters written to file by functions)
        saveRDS(mod15, file.path("Outputs", paste0(TrainingClassId,"RandomForestModel_15")))
        saveRDS(mod15seg, file.path("Outputs", paste0(TrainingClassId,"RandomForestModel_15seg")))
