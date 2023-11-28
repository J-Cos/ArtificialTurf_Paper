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
        p <- terra::rast(file.path("Data", "Stevenage", "clipped2015.tif")) 

# 3) processing
    #add NDVI band used
        p<-AddNdviBand(p, nirBand=4, redBand=3) %>%   
            AddNdwiBand(., nirBand=4, greenBand=2)

#3. plot all bands
    png(file.path("Figures","AllBands.png"), height = 8.3, width = 15, units = 'in', res = 600)
        plot(p)
    dev.off()  

#4. save output
    terra::writeRaster(p, file.path("Outputs", "AllBands.tif"), overwrite=TRUE)

