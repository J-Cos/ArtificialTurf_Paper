#uses as input a segmentation created seperately in grass

library(terra)

terraOptions(verbose=TRUE, memmax=10)

#load and crop data
    seg<-terra::rast(file.path("Data", "Stevenage", "clip2019_segmented_min5_0_01.tif"))

    #load 2015 image to crop
        croppingImage <- terra::rast(file.path("Outputs", "AllBands.tif") )

    # crop image
        seg<-terra::project(seg,terra::crs(croppingImage)) 
        seg_cropped<-terra::crop(seg, terra::ext(croppingImage))
        croppingImage_cropped<-terra::crop(croppingImage, terra::ext(seg_cropped))
        seg_masked<-terra::mask(seg_cropped, croppingImage_cropped[[1]])
    #plot(seg_masked)

#convert to polygons
    #free memory
        rm(list=setdiff(ls(), "seg_masked"))
    #run
    pols<-terra::as.polygons(seg_masked, na.rm=TRUE)
    print("polygons created")
    writeVector(pols, file.path("Outputs", "SegmentationPolygons"))
    print("polygons saved")
