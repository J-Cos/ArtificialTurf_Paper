####################################

#A set seed for replication
    set.seed(0.1)

#B dependencies    
    #R packages (install from bioconductor or through R devtools as appropriate )
    if (!require("pacman")) install.packages("pacman")
    pacman::p_load( terra,
                    tidyverse,
                    ggplot2)

#C parameters
    #cluster settings
        #on HPC?
        HPC<-TRUE
        if (HPC==TRUE)   {setwd("/rds/general/user/jcw120/home/OtherAnalyses")} #necessary as it appears different job classes have different WDs.

        #CRAN mirror
            r = getOption("repos")
            r["CRAN"] = "http://cran.us.r-project.org"
            options(repos = r)



    # general settings
        path <-"../BioinformaticPipeline_Env" # HPC
        #path <-"../../BioinformaticPipeline_Env" #for personal machine

seg<-terra::rast(file.path("Data", "ArtificalTurf", "clip2015_segmented_min5_0_01.tif"))
print("Segmentation loaded")
p15<-terra::rast(file.path("Data", "ArtificalTurf", "AllIndices_p15.tif"))
print("Satellite data loaded")

terra::zonal(x=p15, z=seg, fun=mean, as.raster=TRUE, filename="Outputs/SegmentsMean.tif")
print("segment means calculated")
terra::zonal(x=p15, z=seg, fun=sd, as.raster=TRUE, filename="Outputs/SegmentsMean.tif")
print("segment SDs calculated")
