library(terra)
library(tidyverse)
terraOptions(verbose=TRUE, memmax=10)

#load data and parameters
    PolygonChunkSize<-1000
    numCores<-4
    seg<-terra::rast(file.path("Data", "Stevenage", "clip2019_segmented_min5_0_01.tif"))
    pols<-terra::vect(file.path("Outputs", "SegmentationPolygons"))
    p<-terra::rast(file.path("Outputs", "AllBands.tif"))

#functions
GetCPUTimeToCompleteExtraction<-function(fun) {
    print(paste0("Expectected time to complete: ",round(system.time(terra::extract(p, pols_l[[1]], fun=fun))[3]*length(pols_l)/3600, digits=1), " hours"))
}
ExtractStat<-function(polsChunk, stat){ 
    df<-terra::extract(p, polsChunk, fun=stat)
    print("-")
    return(df)  
}
#verbose version
    ExtractStat <- function(NumberOfChunk, poly_list, stat) {
        df<-terra::extract(p, poly_list[[NumberOfChunk]], fun=stat)
        print(NumberOfChunk)
        return(df)
    }
#####################

# run parallel extract
    pols_l<-base::split(pols, ceiling(seq_along(pols)/PolygonChunkSize))

    #GetCPUTimeToCompleteExtraction(mean)
    #GetCPUTimeToCompleteExtraction(sd)

    print(paste0("Starting parallel mean extraction from ", length(pols_l), " polygon chunks with ", as.integer(numCores), " cores"))
    means_l<-parallel::mclapply(names(pols_l), mc.cores=numCores, ExtractStat,  poly_list=pols_l, stat=mean)
    saveRDS(means_l, "Outputs/SegmentedPolygonMeans.RDS")

    print(paste0("Starting parallel SD extraction from ", length(pols_l), " polygon chunks with ", as.integer(numCores), " cores"))
    SDs_l<-parallel::mclapply(names(pols_l), mc.cores=numCores, ExtractStat, poly_list=pols_l, stat=sd)
    saveRDS(SDs_l, "Outputs/SegmentedPolygonSDs.RDS")

# create SpatVect with summary stats
    means_l<-readRDS("Outputs/SegmentedPolygonMeans.RDS")
    SDs_l<-readRDS("Outputs/SegmentedPolygonSDs.RDS")

    means<-bind_rows(means_l) %>%
        select(-ID)
    names(means)<-paste0("mean_", names(means))

    SDs<-bind_rows(SDs_l) %>%
        select(-ID)
    names(SDs)<-paste0("SD_", names(SDs))
    
    Stats<-cbind(means, SDs)
    pols_wStats<-terra::setValues(pols, Stats)
    writeVector(pols_wStats, "Outputs/PolygonStatsVect.gpkg", overwrite=TRUE)

#rasterise each bands summary stat in series
    pols_wStats<-terra::vect("Outputs/PolygonStatsVect.gpkg")

    dir.create("Outputs/IndividualSegementationSummaryRasters")
    Rast_l<-list()
    for (layer in names(pols_wStats)){
        terra::rasterize(pols_wStats, seg, field=layer, filename= paste0("Outputs/IndividualSegementationSummaryRasters/", layer, ".tif"), overwrite=TRUE)
        print(paste0(layer, " complete"))
    }


    rasts<-list.files("Outputs/IndividualSegementationSummaryRasters", full.names=TRUE)
    SegmentSummaryRaster_l<-lapply(rasts, terra::rast)
    SegmentSummaryRaster<-terra::rast(SegmentSummaryRaster_l)
    terra::writeRaster(SegmentSummaryRaster, file.path("Outputs", "SegmentSummaryRaster.tif"), overwrite=TRUE)

############################################
#END OF CODE ###
############################################