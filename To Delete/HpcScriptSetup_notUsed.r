
    #on HPC?
        setwd("/rds/general/user/jcw120/home/Other/ArtificalTurf") #necessary as it appears different job classes have different WDs.

    #CRAN mirror
        r = getOption("repos")
        r["CRAN"] = "http://cran.us.r-project.org"
        options(repos = r)

    # Loading required packages # 
        if (!require("pacman")) install.packages("pacman")
        pacman::p_load( sp,
                        terra,
                        raster,
                        rgdal,
                        randomForest,
                        caret,
                        tidyverse,
                        devtools) #needed for RStoolbox
        install_github("bleutner/RStoolbox")
