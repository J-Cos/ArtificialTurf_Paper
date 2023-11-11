#########################
# Add spectral indicies
##########################

#1: Dependencies
    #packages
        library(terra)
        library(tidyverse)

    #load project functions
        function_files<-list.files(file.path("Code","Functions"))
        sapply(file.path("Code","Functions",function_files),source)

#2. Load, add all spectral indices and plot
    #load 2015 data
        p15 <- terra::rast(file.path("Data", "Stevenage", "clipped2015.tif")) 

# 3) processing
    #add NDVI band used
        p15<-AddNdviBand(p15)

#3. save output
    terra::writeRaster(p15, file.path("Outputs", "AllIndices_p15.tif"), overwrite=TRUE)
