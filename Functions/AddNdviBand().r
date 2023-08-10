 
AddNdviBand<-function(raster) {
    NDVI <- (raster[[4]] - raster[[1]]) / (raster[[4]] + raster[[1]])
    raster<-c(raster, NDVI)
    names(raster)[5]<-c("NDVI")
    return(raster)
}
