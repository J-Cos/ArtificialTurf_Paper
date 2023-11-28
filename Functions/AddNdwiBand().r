AddNdwiBand<-function(raster, greenBand, nirBand) {
    numBands<-dim(raster)[3]
    NDWI <- (raster[[greenBand]] - raster[[nirBand]]) / (raster[[greenBand]] + raster[[nirBand]])
    raster<-c(raster, NDWI)
    names(raster)[numBands+1]<-c("NDWI")
    return(raster)
}
