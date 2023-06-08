#########################
# Add spectral indicies
##########################

#1: Dependencies
    #packages
        library(raster)
        library(tidyverse)
        library(RStoolbox)

    #load project functions
        function_files<-list.files(file.path("Code","Functions"))
        sapply(file.path("Code","Functions",function_files),source)

#2. Load, add all spectral indices and plot
    #2015
        p15 <-  raster::brick(file.path("Data", "Stevenage", "clipped2015.tif")) %>%
                    AddAllAvailableIndices
        p15<-raster::dropLayer(p15, 8) # remove layer.8 (EVI2) as includes NAs

    #2019
        p19 <-  raster::brick(file.path("Data", "Stevenage", "clipped2019.tif")) %>%
                    AddAllAvailableIndices
        p19<-raster::dropLayer(p19, 8) # do we need to remove any other layers based on the 2019 data - should match to 2015?

    #is subsetting needed for NA layers?
                    #plot them to confirm
                    #            terra::plot(p19, 
                    #                        legend=FALSE, 
                    #                        axes=FALSE, 
                    #                        box=FALSE, 
                    #                        col = c("black"), 
                    #                        bty = "n") 

#3. save output
    terra::writeRaster(p15, file.path("Outputs", "AllIndices_p15.tif"), overwrite=TRUE)
    terra::writeRaster(p19, file.path("Outputs", "AllIndices_p19.tif"), overwrite=TRUE)
