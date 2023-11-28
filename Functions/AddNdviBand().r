 
AddNdviBand<-function(raster, redBand, nirBand) {
    numBands<-dim(raster)[3]
    NDVI <- (raster[[nirBand]] - raster[[redBand]]) / (raster[[nirBand]] + raster[[redBand]])
    raster<-c(raster, NDVI)
    names(raster)[numBands+1]<-c("NDVI")
    return(raster)
}
