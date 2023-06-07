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

    set.seed(1) 

#2. Load Data
    # Importing satellite data #
        #p15<-readRDS(file.path("Outputs", "CompleteRasterStack_2015.RDS") )
        #p19<-readRDS(file.path("Outputs", "CompleteRasterStack_2019.RDS") )
        p15<-terra::rast(file.path("Outputs", "AllIndices_p15.tif"))
        p19<-terra::rast(file.path("Outputs", "AllIndices_p19.tif"))

    # Load training and validation points #
        TestTrain<-readRDS( file.path("Outputs", "TestTrainPoints.RDS") )

#3. Run Classifications and save output

    #fit random forests and classify
        #2015
            mod15 <- randomForest::randomForest(response ~ ., data=TestTrain[["train15"]][["pointVals"]], na.action=na.omit, ntree=200, confusion=TRUE)
            sc15 <- terra::predict(object=p15, 
                                    model=mod15, 
                                    type="response",
                                    filename=file.path("Outputs", "sc15.tif"), 
                                    format="GTiff", 
                                    datatype="INT1U")
        #2019
            mod19 <- randomForest::randomForest(response ~ ., data=TestTrain[["train19"]][["pointVals"]], na.action=na.omit, ntree=200, confusion=TRUE)
            sc19 <- terra::predict(object=p19, 
                                    model=mod19, 
                                    type="response",
                                    filename=file.path("Outputs", "sc19.tif"), 
                                    format="GTiff", 
                                    datatype="INT1U")


#4. save outputs
    #saving random forest models - (classification rasters written to file by functions)
        saveRDS(mod15, file.path("Outputs", "RandomForestModel_15"))
        saveRDS(mod19, file.path("Outputs", "RandomForestModel_19"))