#########################
# Add spectral indicies
##########################

#1: Dependencies
    #packages
        library(terra)
        library(tidyverse)
        library(RStoolbox)

    #load project functions
        function_files<-list.files(file.path("Code","Functions"))
        sapply(file.path("Code","Functions",function_files),source)

#2. Load, add all spectral indices and plot
        p15 <- terra::rast(file.path("Data", "Stevenage", "clipped2015.tif")) %>%
                    AddAllAvailableIndices

        p19 <-  terra::rast(file.path("Data", "Stevenage", "clipped2019.tif")) %>%
                    AddAllAvailableIndices

#3. save output
    terra::writeRaster(p15, file.path("Outputs", "AllIndices_p15.tif"), overwrite=TRUE)
    terra::writeRaster(p19, file.path("Outputs", "AllIndices_p19.tif"), overwrite=TRUE)
