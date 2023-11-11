##################
## Make figure ###
##################

#1: Dependencies
    #packages
        library(terra)
        library(raster)
        library(caret)
        library(tidyverse)
        library(tidyterra)

    #load project functions
        function_files<-list.files(file.path("Code","Functions"))
        sapply(file.path("Code","Functions",function_files),source)

    # Parameters
        ExcludeShadow<-TRUE
        ExcludeWater<-FALSE
        df<-data.frame(val=c(1,2,3,4), cat=c("Vegetation", "Manmade", "Turf", "Water"))

#2. Load Data

    # Load training and validation polygons #
    # And setting coordinate reference system to match imagery
        TestTrain<-readRDS( file.path("Outputs", "TestTrainPoints.RDS") )

        if (ExcludeShadow & !ExcludeWater) {
            # update excluding function to all when 2019 ready as well
            TestTrain<-ExcludeClassFromTestTrain(TestTrain, "Shadow")
            TrainingClassId<-"NoShadow_"
            plotCols<-c("green", "grey", "red", "blue")
        } else if (ExcludeShadow & ExcludeWater) {
            TestTrain<-ExcludeClassFromTestTrain(TestTrain, "Shadow") %>%
                ExcludeClassFromTestTrain(., "Water") 
            TrainingClassId<-"NoShadowOrWater_"
            plotCols<-c("green", "grey", "red")
        } else if (!ExcludeShadow & !ExcludeWater) {
            TrainingClassId<-NULL
            plotCols<-c("green", "grey", "red", "blue", "black")
        } else if (!ExcludeShadow & ExcludeWater) {
            TestTrain<-ExcludeShadowFromTestTrain(TestTrain, "Water")
            TrainingClassId<-"NoWater_"
            plotCols<-c("green", "grey", "red", "black")
        } 


    # Importing satellite data #
        sc15<-terra::rast(file.path("Outputs", paste0(TrainingClassId, "sc15.tif")))
        levels(sc15)<-df
        sc19<-terra::rast(file.path("Outputs", paste0(TrainingClassId, "sc19.tif"))) #%>%
        levels(sc19)<-df

        sc15_cropped<-crop(sc15, sc19)# %>%
        sc19_cropped<-crop(sc19, sc15_cropped)# %>%

        mask<- ifel(is.na(sc15_cropped), NA, 1)
        #sc19_cropped<-crop(sc19, mask)# %>%
        #mask_cropped<-crop(mask, sc19_cropped)# %>%
        sc19_masked<-mask(sc19_cropped, mask, NA, 1)


    # get land cover change raster
        sc15_Turf<-sc15_cropped=="Turf"
        sc19_Turf<-sc19_masked=="Turf"
        change<-sc19_Turf-sc15_Turf
        levels(change)<-data.frame(vals=c(-1, 0, 1), cats=c("TurfLost", "NoChange", "TurfGained"))



# 3. Make plots with some zoomed areas
    #get zoomed areas
        MakePolygon<-function(e){
            v <- as.polygons(crop(sc19_masked, e), extent=TRUE)
            return(v)
        }

        ZoomedExtents<-list(
        ext(691500, 692000, 5753000, 5753500),
        ext(692000, 692500, 5755000, 5755500) ,
        ext(694000, 694500, 5754000, 5754500) ,
        ext(694750, 695250, 5750750, 5751250) 
        )

        polys<-rbind(
            MakePolygon(ZoomedExtents[[1]] ),
            MakePolygon(ZoomedExtents[[2]] ),
            MakePolygon(ZoomedExtents[[3]] ),
            MakePolygon(ZoomedExtents[[4]])
        )

        polys<-cbind(polys, data.frame(polyNames=1:length(polys)))


    # make main plots
            plot19<-ggplot() +
                geom_spatraster(
                    data = sc19_masked,alpha = 1, aes(fill=cat), na.rm=TRUE
                )+ 
                scale_fill_manual(values = plotCols, na.translate=FALSE)+
                geom_spatvector(data=polys, fill=NA, color="black")+
                geom_spatvector_text(data=polys, aes(label = polyNames), fontface = "bold", color = "black")

           plotchange<-ggplot() +
                geom_spatraster(
                    data = change,alpha = 1, na.rm=TRUE
                )+ 
                scale_fill_manual(values = c("blue", "grey", "red"), na.translate=FALSE)+
                geom_spatvector(data=polys, fill=NA, color="black")+
                geom_spatvector_text(data=polys, aes(label = polyNames), fontface = "bold", color = "black")

    #make zoomed subplots
        changePlot_l<-list()
        plot19_l<-list()
        for (i in 1: length(ZoomedExtents)) {
                changePlot_l[[i]]<-ggplot() +
                        geom_spatraster(
                            data= crop(change, ZoomedExtents[[i]]), alpha = 1, na.rm=TRUE, show.legend=FALSE
                        )+ 
                        scale_fill_manual(values = c("blue", "grey", "red"), na.translate=FALSE)
                plot19_l[[i]]<-ggplot() +
                        geom_spatraster(
                            data= crop(sc19_masked, ZoomedExtents[[i]]), alpha = 1, na.rm=TRUE, show.legend=FALSE
                        )+ 
                        scale_fill_manual(values = plotCols, na.translate=FALSE)
        }

#4. save compound figure

    png(file.path("Figures",paste0("Fig3:LandCoverMaps", Sys.Date(),".png")), height = 8.3, width = 15, units = 'in', res = 300)
        cowplot::ggdraw() +
            cowplot::draw_plot(ggpubr::ggarrange(plot19, plotchange, nrow=2), x=0, y=0, width=0.5, height=1)+
            cowplot::draw_plot(ggpubr::ggarrange(plotlist=plot19_l, nrow=4, ncol=1), x=0.5, y=0, width=0.25, height=1)+
            cowplot::draw_plot(ggpubr::ggarrange(plotlist=changePlot_l, nrow=4, ncol=1), x=0.75, y=0, width=0.25, height=1)
    dev.off()
    