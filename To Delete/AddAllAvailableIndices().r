 #direct dependencies
  #terra
  #raster
  #RStoolbox


AddAllAvailableIndices<-function(raster) {
    print("Calculating indices")
    names<-names(raster)
    AllIndices<-RStoolbox::spectralIndices( raster, 
                                            red = names[3],
                                            green = names[2],
                                            blue = names[1],
                                            nir = names[4],
                                            scaleFactor=10000
                                            )

    print("combining new indices with existing raster layers")
    AllIndices_terra<- terra::rast(AllIndices)
    CompletedRaster <- c(raster, AllIndices_terra)

    return(CompletedRaster)
}


