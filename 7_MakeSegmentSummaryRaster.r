library(terra)
library(tidyverse)

#load data and parameters
    PolygonChunkSize<-1000
    numCores<-4
    seg<-terra::rast(file.path("Data", "Stevenage", "clip2015_segmented_min5_0_01.tif"))
    pols<-terra::vect(file.path("Outputs", "SegmentationPolygons"))
    p15<-terra::rast(file.path("Outputs", "AllIndices_p15.tif"))

#functions
GetCPUTimeToCompleteExtraction<-function(fun) {
    print(paste0("Expectected time to complete: ",round(system.time(terra::extract(p15, pols_l[[1]], fun=fun))[3]*length(pols_l)/3600, digits=1), " hours"))
}
ExtractStat<-function(polsChunk, stat){ 
    df<-terra::extract(p15, polsChunk, fun=stat)
    print("-")
    return(df)  
}

# run parallel extract
    pols_l<-base::split(pols, ceiling(seq_along(pols)/PolygonChunkSize))

    GetCPUTimeToCompleteExtraction(mean)
    GetCPUTimeToCompleteExtraction(sd)

    print(paste0("Starting parallel mean extraction from ", length(pols_l), " polygons with ", as.integer(numCores), " cores"))
    means_l<-parallel::mclapply(pols_l, mc.cores=numCores, ExtractStat, stat=mean)
    saveRDS(means_l, "Outputs/SegmentedPolygonMeans.RDS")

    print(paste0("Starting parallel SD extraction from polygons with ", as.integer(numCores), " cores"))
    SDs_l<-parallel::mclapply(pols_l, mc.cores=numCores, ExtractStat, stat=sd)
    saveRDS(SDs_l, "Outputs/SegmentedPolygonSDs.RDS")

# create SpatVect with summary stats
    means<-bind_rows(means_l) %>%
        select(-ID)
    names(means)<-paste0("mean_", names(means))

    SDs<-bind_rows(SDs_l) %>%
        select(-ID)
    names(SDs)<-paste0("SD_", names(SDs))
    
    Stats<-cbind(means, SDs)
    pols_wStats<-setValues(pols, Stats)

#rasterise each bands summary stat in series
    dir.create("Outputs/IndividualSegementationSummaryRasters")
    Rast_l<-list()
    for (layer in names(Stats)){
        Rast_l[[layer]]<-terra::rasterize(p_wStats, seg, field=layer, filename= paste0("Outputs/IndividualSegementationSummaryRasters/", layer, ".tif"), overwrite=TRUE)
    }

    SegmentSummaryRaster<-rast(Rast_l)
    terra::writeRaster(SegmentSummaryRaster, file.path("Outputs", "SegmentSummaryRaster_p15.tif"), overwrite=TRUE)

############################################
#END OF CODE ###
############################################