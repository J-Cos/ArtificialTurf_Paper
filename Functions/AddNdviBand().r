 
AddNdviBand<-function(raster) {
    raster[[5]] <- (raster[[4]] - raster[[1]]) / (raster[[4]] + raster[[1]])
    return(raster)
}
