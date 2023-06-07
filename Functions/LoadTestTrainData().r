    #rgddal
    #raster
    #sp    
        LoadTestTrainData<-function(TestTrain, pleiades) { #load data and ensure second attribute is called "class", then match to coordiate system of raster
            p <- rgdal::readOGR(dsn = file.path("Data", "Stevenage", "test_train"), layer=TestTrain)  %>% 
                sp::spTransform(raster::crs(pleiades))
            names(p)[2]<-"class"
            return(p)
        }