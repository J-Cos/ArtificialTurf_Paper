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
        p <-  terra::rast(file.path("Outputs", "AllBands.tif"))
        pseg<- terra::rast("Outputs/SegmentSummaryRaster.tif")


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
            #2019
                #tune rf
                    model_tuned <- randomForest::tuneRF(
                        x=select(TestTrain[["train19"]][["pointVals"]], !c(response, ID)), #define predictor variables
                        y=TestTrain[["train19"]][["pointVals"]]$response, #define response variable
                        ntreeTry=3001,
                        mtryStart=2, 
                        stepFactor=1.5,
                        improve=0.001,
                        trace=TRUE #don't show real-time progress
                    )
                #optimum mtry 
                    #5
                #error rates stabilise by 500 trees - visible with plot(mod19)
            #segmentation
                #tune rf
                    model_tuned <- randomForest::tuneRF(
                        x=select(TestTrain[["train19seg"]][["pointVals"]], !c(response, ID)), #define predictor variables
                        y=TestTrain[["train19seg"]][["pointVals"]]$response, #define response variable
                        ntreeTry=3001,
                        mtryStart=2, 
                        stepFactor=1.5,
                        improve=0.001,
                        trace=TRUE #don't show real-time progress
                    )
                #optimum mtry =5 for seg
                #error rates stabilise by 500 trees - visible with plot(mod19seg)
        # fit train test rfs
        set.seed(1) 
            mod19 <- randomForest::randomForest(x=select(TestTrain[["train19"]][["pointVals"]], !c(response, ID)), 
                                                xtest= select(TestTrain[["test19"]][["pointVals"]], !c(response, ID)) , 
                                                y=TestTrain[["train19"]][["pointVals"]]$response, 
                                                ytest= TestTrain[["test19"]][["pointVals"]]$response , 
                                                na.action=na.omit, 
                                                ntree=3001, 
                                                mtry=2, 
                                                confusion=TRUE)
                
            mod19seg <- randomForest::randomForest(x=select(TestTrain[["train19seg"]][["pointVals"]], !c(response, ID)), 
                                                xtest= select(TestTrain[["test19seg"]][["pointVals"]], !c(response, ID)) , 
                                                y=TestTrain[["train19seg"]][["pointVals"]]$response, 
                                                ytest= TestTrain[["test19seg"]][["pointVals"]]$response , 
                                                na.action=na.omit, 
                                                ntree=3001, 
                                                mtry=2, 
                                                confusion=TRUE)

        #save table 3
            MakeConfusionTable(mod19[["test"]][["confusion"]]) %>%
                write.csv("Figures/Table3a.csv")    
            MakeConfusionTable(mod19seg[["test"]][["confusion"]]) %>%
                write.csv("Figures/Table3b.csv")    

        #get F1 stats
            GetF1<-function(mod, var){
                2/((1/as.numeric(MakeConfusionTable(mod[["test"]][["confusion"]])[var,7])) + (1/ as.numeric(MakeConfusionTable(mod[["test"]][["confusion"]])[7,var])))
            }

            #green
            GetF1(mod19, 1)
            GetF1(mod19seg, 1)
            #urban
            GetF1(mod19, 2)
            GetF1(mod19seg, 2)
            #turf
            GetF1(mod19, 3)
            GetF1(mod19seg, 3)
            #water
            GetF1(mod19, 4)
            GetF1(mod19seg, 4)


# 4. make land cover maps
    set.seed(1) 
    mod19 <- randomForest::randomForest(response ~ ., data=select(TestTrain[["train19"]][["pointVals"]], !ID), na.action=na.omit, ntree=3001, mtry=2, confusion=TRUE)
    sc19 <- terra::predict(object=p, 
                            model=mod19, 
                            type="response",
                            filename=file.path("Outputs", "landcover_19.tif"), 
                            format="GTiff", 
                            datatype="INT1U",
                            overwrite=TRUE)
    set.seed(1) 
    mod19seg <- randomForest::randomForest(response ~ ., data=select(TestTrain[["train19seg"]][["pointVals"]], !ID), na.action=na.omit, ntree=3001, mtry=2, confusion=TRUE)
    sc19seg <- terra::predict(object=pseg, 
                            model=mod19seg, 
                            type="response",
                            filename=file.path("Outputs", "landcover_19seg.tif"), 
                            format="GTiff", 
                            datatype="INT1U",
                            overwrite=TRUE)


# 5. save outputs
    #saving random forest models - (classification rasters written to file by functions)
        saveRDS(mod19, file.path("Outputs", paste0(TrainingClassId,"RandomForestModel_19")))
        saveRDS(mod19seg, file.path("Outputs", paste0(TrainingClassId,"RandomForestModel_19seg")))
