library(terra)

seg<-terra::rast(file.path("Data", "Stevenage", "clip2015_segmented_min5_0_01.tif"))
print("seg loaded")
pols<-terra::as.polygons(seg)
print("polygons created")
writeVector(pols, file.path("Outputs", "SegmentationPolygons"))
print("polygons saved")

