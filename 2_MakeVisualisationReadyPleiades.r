#########################
# Make visualisation ready pleiades tif
##########################

#1: Dependencies
    #packages
        library(terra)
        library(tidyverse)
        library(tidyterra)
        library(ggplot2)

    #load project functions
        function_files<-list.files(file.path("Code","Functions"))
        sapply(file.path("Code","Functions",function_files),source)

#2. Load data
        p <-  terra::rast(file.path("Outputs", "AllBands.tif"))

#3) make streched pleiades for optimal plotting contrast
        s <- terra::stretch(p, minq=0.02, maxq=.98)
        terra::writeRaster(s, file.path("Outputs", "Stretched_p15.tif"), overwrite=TRUE)
