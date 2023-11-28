#########################
# Extract test and train points from polygons
##########################

#1: Dependencies
    #packages
        library(sp)
        library(terra)
        library(raster)
        library(rgdal)
        library(tidyverse)
        library(tidyterra)

    #load project functions
        function_files<-list.files(file.path("Code","Functions"))
        sapply(file.path("Code","Functions",function_files),source)

#2. Load Data

    # Importing satellite data #
        p <-  terra::rast(file.path("Outputs", "AllBands.tif"))
        pseg<- terra::rast("Outputs/SegmentSummaryRaster.tif")

    # Load training and validation polygons #
    # And setting coordinate reference system to match imagery
        tv_polygons<-LoadTestTrainData(TestTrain="reference_data_2015_improved_water_poly_split", pleiades=p)

    # adjust mislabelled classes to match ids (there are currently two artifical classes with typo names "man" and "man-made")
        NewClassNames<-tv_polygons$id %>%
            as.factor
        levels(NewClassNames) <- list(green  = "1", manmade = "2",turf  = "3", water = "4",Shadow  = "5")
        tv_polygons$class<-NewClassNames
        

#3 split 
    set.seed(1) 

    # split polys
        TrainTestPolys<-SplitPolysIntoTrainAndTest(polys=tv_polygons, trainPercent=0.8)

#4. Get points from polygons
    #set seed as random sampling involved

    train15<-GetClassPoints(data= p, 
                            polygons=TrainTestPolys[["trainPolys"]], 
                            MaxPointsPerPolygonClass=c("water"=20, "turf"=20, "Other"=20), 
                            StratifyingCellSize=0.1)
    test15<-GetClassPoints(data= p, 
                            polygons=TrainTestPolys[["testPolys"]],
                            MaxPointsPerPolygonClass=c("water"=20, "turf"=20, "Other"=20), 
                            StratifyingCellSize=0.1)

    train15seg<-GetClassPoints(data= pseg, 
                            polygons=TrainTestPolys[["trainPolys"]], 
                            MaxPointsPerPolygonClass=c("water"=20, "turf"=20, "Other"=20), 
                            StratifyingCellSize=0.1)
    test15seg<-GetClassPoints(data= pseg, 
                            polygons=TrainTestPolys[["testPolys"]],
                            MaxPointsPerPolygonClass=c("water"=20, "turf"=20, "Other"=20), 
                            StratifyingCellSize=0.1)

    TestTrain<-list("train15"=train15,
                    "test15"=test15,
                    "train15seg"=train15seg,
                    "test15seg"= test15seg)

#5. Save output

    # save test and train polys for downstream figue
        saveRDS(TrainTestPolys, file.path("Outputs", "TrainTestPolys.RDS"))

    #save rds for next steps
        saveRDS(TestTrain, file.path("Outputs", "TestTrainPoints.RDS"))
    #save renamed polygons for next steps
        saveRDS(tv_polygons, file.path("Outputs", "reference_data_2015_renamed.RDS"))