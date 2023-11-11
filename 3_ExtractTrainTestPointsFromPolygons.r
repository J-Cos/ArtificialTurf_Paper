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
        p15 <-  terra::rast(file.path("Outputs", "AllIndices_p15.tif"))
        p15seg<- terra::rast("Outputs/SegmentSummaryRaster_p15.tif")

    # Load training and validation polygons #
    # And setting coordinate reference system to match imagery
        tv_polygons15<-LoadTestTrainData(TestTrain="reference_data_2015_improved_water_poly_split", pleiades=p15)

    # adjust mislabelled classes to match ids (there are currently two artifical classes with typo names "man" and "man-made")
        NewClassNames<-tv_polygons15$id %>%
            as.factor
        levels(NewClassNames) <- list(green  = "1", manmade = "2",turf  = "3", water = "4",Shadow  = "5")
        tv_polygons15$class<-NewClassNames
        

    # split polys
        TrainTestPolys15<-SplitPolysIntoTrainAndTest(polys=tv_polygons15, trainPercent=0.8)

#3. Get points from polygons
    #set seed as random sampling involved
        set.seed(1) 

    train15<-GetClassPoints(data= p15, 
                            polygons=TrainTestPolys15[["trainPolys"]], 
                            MaxPointsPerPolygonClass=c("water"=50, "turf"=50, "Other"=10), 
                            StratifyingCellSize=0.1)
    test15<-GetClassPoints(data= p15, 
                            polygons=TrainTestPolys15[["testPolys"]],
                            MaxPointsPerPolygonClass=c("water"=50, "turf"=50, "Other"=10), 
                            StratifyingCellSize=0.1)

    train15seg<-GetClassPoints(data= p15seg, 
                            polygons=TrainTestPolys15[["trainPolys"]], 
                            MaxPointsPerPolygonClass=c("water"=50, "turf"=50, "Other"=10), 
                            StratifyingCellSize=0.1)
    test15seg<-GetClassPoints(data= p15seg, 
                            polygons=TrainTestPolys15[["testPolys"]],
                            MaxPointsPerPolygonClass=c("water"=50, "turf"=50, "Other"=10), 
                            StratifyingCellSize=0.1)

    TestTrain<-list("train15"=train15,
                    "test15"=test15,
                    "train15seg"=train15seg,
                    "test15seg"= test15seg)

#4. Save output
    #save rds for next steps
        saveRDS(TestTrain, file.path("Outputs", "TestTrainPoints.RDS"))
    #save renamed polygons for next steps
        saveRDS(tv_polygons15, file.path("Outputs", "reference_data_2015_renamed.RDS"))