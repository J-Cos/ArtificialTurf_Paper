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

    #load project functions
        function_files<-list.files(file.path("Code","Functions"))
        sapply(file.path("Code","Functions",function_files),source)

#2. Load Data

    # Importing satellite data #
        p15<-raster::brick(file.path("Outputs", "AllIndices_p15.tif"))
        p19<-raster::brick(file.path("Outputs", "AllIndices_p19.tif"))

    # Load training and validation polygons #
    # And setting coordinate reference system to match imagery
        tv_polygons15<-LoadTestTrainData(TestTrain="reference_data_2015_improved", pleiades=p15)

    # adjust mislabelled classes to match ids (there are currently two ariitifical classes with typo names "man" and "man-made")
        NewClassNames<-tv_polygons15$id %>%
            as.factor
        levels(NewClassNames) <- list(Green  = "1", Artifical = "2",Turf  = "3", Water = "4",Shadow  = "5")
        tv_polygons15$class<-NewClassNames

    # split polys
        TrainTestPolys15<-SplitPolysIntoTrainAndTest(polys=tv_polygons15, trainPercent=0.8)



#3. Get points from polygons
    #set seed as random sampling involved
        set.seed(1) 

    train15<-GetClassPoints(data= p15, 
                            polygons=TrainTestPolys15[["trainPolys"]], 
                            MaxPointsPerPolygonClass=c("Water"=30, "Other"=10), 
                            StratifyingCellSize=0.1)
    test15<-GetClassPoints(data= p15, 
                            polygons=TrainTestPolys15[["testPolys"]],
                            MaxPointsPerPolygonClass=c("Water"=30, "Other"=10), 
                            StratifyingCellSize=0.1)

    train19<-NULL
    test19<-NULL

    TestTrain<-list("train15"=train15,
                "train19"=train19,
                "test15"=test15,
                "test19"=test19)

#4. Save output
    #save rds for next steps
        saveRDS(TestTrain, file.path("Outputs", "TestTrainPoints.RDS")        )

    # save point shapefiles for inspection
        dir.create(file.path("Outputs", 'TestTrainPoints'))

        shapefile(TestTrain[["train15"]][["points"]], file.path("Outputs", "TestTrainPoints",'train15.shp'), overwrite=TRUE)
        shapefile(TestTrain[["test15"]][["points"]], file.path("Outputs", "TestTrainPoints", 'test15.shp'), overwrite=TRUE)
        
        shapefile(TestTrain[["train19"]][["points"]], file.path("Outputs", "TestTrainPoints",'train19.shp'), overwrite=TRUE)
        shapefile(TestTrain[["test19"]][["points"]], file.path("Outputs", "TestTrainPoints", 'test19.shp'), overwrite=TRUE)

    #save polygon images for heuristic checks
        png(file.path("Figures","TestTrainPolygons_15.png"), height = 8.3, width = 11.7, units = 'in', res = 300)      
            par(mfrow=c(1,2))
            terra::vect(TrainTestPolys15[["trainPolys"]]) %>%
                terra::plot(., "class", col=rainbow(5),  main="train")

            terra::vect(TrainTestPolys15[["testPolys"]]) %>%
                terra::plot(., "class", col=rainbow(5), main="test")
        dev.off()
