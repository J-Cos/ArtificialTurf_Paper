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
    #load 2019 data
        p <- terra::rast(file.path("Data", "Stevenage", "clipped2019_4_bands.tif")) 
    #load 2015 image to crop
        croppingImage <- terra::rast(file.path("Data", "Stevenage", "clipped2015.tif")) 

# 3) processing
    # crop image
        croppingImage<-terra::project(croppingImage,terra::crs(p)) 
        p_cropped<-terra::crop(p, terra::ext(croppingImage))
        croppingImage_cropped<-terra::crop(croppingImage, terra::ext(p_cropped))
        p_masked<-terra::mask(p_cropped, croppingImage_cropped)

    #add NDVI band used
        p_allBands<-AddNdviBand(p_masked, nirBand=4, redBand=1) %>%   
            AddNdwiBand(., nirBand=4, greenBand=2)

#3. plot all bands
    png(file.path("Figures","AllBands.png"), height = 8.3, width = 15, units = 'in', res = 600)
        plot(p_allBands)
    dev.off()  

#4. save output
    terra::writeRaster(p_allBands, file.path("Outputs", "AllBands.tif"), overwrite=TRUE)

