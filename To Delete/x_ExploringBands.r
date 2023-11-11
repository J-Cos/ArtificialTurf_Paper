# explore indice ability to distinguish artifical from tuneRF


#########################
# Conduct supervised classification
##########################

#1: Dependencies
    #packages
        library(terra)
        library(randomForest)
        library(tidyverse)

    #load project functions
        function_files<-list.files(file.path("Code","Functions"))
        sapply(file.path("Code","Functions",function_files),source)

    # Parameters
        ExcludeShadow<-TRUE

#2. Load Data

    # Load training and validation points #
        TestTrain<-readRDS( file.path("Outputs", "TestTrainPoints.RDS") )

        if (ExcludeShadow) {
            # update excluding function to all when 2019 ready as well
            TestTrain<-ExcludeShadowFromTestTrain(TestTrain)
            ShadowId<-"NoShadow_"
        } else {ShadowId<-NULL}

BandNames<-c("clipped2015_1", "clipped2015_2", "clipped2015_3", "clipped2015_4", "CTVI" ,
            "DVI", "EVI", "GEMI", "GNDVI","KNDVI", "MSAVI", "MSAVI2", "NDVI", 
            "NDWI" ,"NRVI", "RVI", "SAVI", "SR", "TTVI", "TVI",  "WDVI")     


TestTrain [[1]]$pointVals %>% 
    rbind(TestTrain [[3]]$pointVals) %>%
    filter(response %in% c("Artifical", "Turf")) %>% 
    setNames( c("response", BandNames)) %>% 
    pivot_longer(cols=!response, names_to="Band", values_to="Value") %>%
    ggplot( aes(fill=response, x=Value, alpha=0.5)) +
        geom_density()+
        facet_wrap(~Band, scales="free")
ggsave("Figures/BandDifferences_TurfArtitifical_2015.png")

TestTrain [[1]]$pointVals %>% 
    rbind(TestTrain [[3]]$pointVals) %>%
    setNames( c("response", BandNames)) %>% 
    pivot_longer(cols=!response, names_to="Band", values_to="Value") %>%
    ggplot( aes(fill=response, x=Value, alpha=0.5)) +
        geom_density()+
        facet_wrap(~Band, scales="free")
ggsave("Figures/BandDifferences_All_2015.png")