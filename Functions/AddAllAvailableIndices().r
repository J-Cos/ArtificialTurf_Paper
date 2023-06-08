 #direct dependencies
  #raster
  #RStoolbox


AddAllAvailableIndices<-function(raster) {
    print("Calculating indices")
    AllIndices<-RStoolbox::spectralIndices( raster, 
                                            red = "clipped2015_3", 
                                            green = "clipped2015_2", 
                                            blue = "clipped2015_1", 
                                            nir = "clipped2015_4", 
                                            scaleFactor=10000
                                            )

    print("combining new indices with existing raster layers")
    CompletedRaster <- raster::stack(raster, AllIndices)

    return(CompletedRaster)
}


