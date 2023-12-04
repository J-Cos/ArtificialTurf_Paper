#########################
# Make figures and tables from test and train points
##########################

# 1) Dependencies
    #packages
        library(terra)
        library(tidyverse)
        library(tidyterra)
        library(ggpubr)

    #functions
        #load project functions
        function_files<-list.files(file.path("Code","Functions"))
        sapply(file.path("Code","Functions",function_files),source)

        GetZoomedPleiades<-function(s, polys, polyClass, margin, col, i=1){


            poly<-subset(polys, polys$class==polyClass)[i]

            extent<-as.vector(ext(poly)) +c (-margin,+margin, -margin, +margin)


            zoomed<-crop(s, extent)


            zoomedPleiades<-ggplot() +
                geom_spatraster_rgb( data = zoomed ,alpha = 1, r=1, g=2, b=3)+
                geom_spatvector(data=poly, color=col, linewidth=1, fill=NA)+
                theme_classic()+
                theme(
                    axis.text=element_text(size=3)
                )
            
            return(zoomedPleiades)
        }
# 2) load data
        plotCols<-c("green", "grey", "red", "blue")

        TestTrain<-readRDS(file.path("Outputs", "TestTrainPoints.RDS"))
        s <-  terra::rast(file.path("Outputs", "Stretched.tif"))
        polys<-readRDS(file.path("Outputs", "TrainTestPolys.RDS")) %>% lapply(., terra::vect)
        polys<-rbind(polys[[1]], polys[[2]])
# 3) make figures and tables for test train data
    #Table 2 – stats of training and test data
        testTrainStats_table<-rbind(
                                TestTrain[["train19"]][["NumberCellsPerCategory"]],
                                TestTrain[["test19"]][["NumberCellsPerCategory"]],
                                TestTrain[["train19seg"]][["NumberCellsPerCategory"]],
                                TestTrain[["test19seg"]][["NumberCellsPerCategory"]]
                            ) %>%
                            as.data.frame

        #rename columns
        rownames(testTrainStats_table)<-c("Training", "Validation", "Training - Segmentation", "Validation - Segmentation")
        colnames(testTrainStats_table)<-c("Vegetation", "Man-made", "Artificial Turf", "Water")

        # remove shadow cols and remove seperate segmentation rows (as they are identical to non-segmented)
        testTrainStats_table<-testTrainStats_table[c(-3, -4),-5]

        #create total column
        testTrainStats_table$Total<- rowSums(testTrainStats_table)        

        #save
        write.csv(testTrainStats_table, "Figures/Table2.csv")

    #supp fig 1 – zoomed in classes and locations of points

        z1<-GetZoomedPleiades(s, polys, polyClass="green", col="green", margin=50, i=3)
        z2<-GetZoomedPleiades(s, polys, polyClass="manmade", col="grey", margin=50)
        z3<-GetZoomedPleiades(s, polys, polyClass="turf", col="red", margin=50, i=8)
        z4<-GetZoomedPleiades(s, polys, polyClass="water", col="blue", margin=50)



        plotPolys<-subset(polys, polys$class!="Shadow") 
        
        NewClassNames<-plotPolys$class %>%
            as.factor %>%
            droplevels
        levels(NewClassNames) <- c("Vegetation", "Man-made", "Artificial Turf", "Water")
        plotPolys$class<-NewClassNames

        p<-ggplot() +
            geom_spatraster_rgb( data = s ,alpha = 1, r=1, g=2, b=3)+
            geom_spatvector(data=plotPolys, aes(color=class), linewidth=2, fill=NA)+
            scale_color_manual(values = plotCols, na.translate=FALSE)+
            theme_classic()+
            theme(legend.title=element_blank())
        
        legend<-ggpubr::as_ggplot(ggpubr::get_legend(p))
        p<-p+theme(legend.position="none")


    #save polygon images for heuristic checks
        png(file.path("Figures","SupplementaryFigure1.png"), height = 8.3, width = 13, units = 'in', res = 200)
                cowplot::ggdraw() +
                    cowplot::draw_plot(p, x=0, y=0, width=0.65, height=1)+
                    cowplot::draw_plot(z1, x=0.65, y=0.75, width=0.25, height=0.25)+
                    cowplot::draw_plot(z2, x=0.65, y=0.5, width=0.25, height=0.25)+
                    cowplot::draw_plot(z3, x=0.65, y=0.25, width=0.25, height=0.25)+
                    cowplot::draw_plot(z4, x=0.65, y=0, width=0.25, height=0.25)+
                    cowplot::draw_plot(legend, x=0.92, y=0, width=0.05, height=1)+
                    cowplot::draw_plot_label(   label = c("A", "B", "C", "D", "E"), 
                                            size = 19, 
                                            x = c(0,0.62, 0.62, 0.62, 0.62), 
                                            y = c(1, 1, 0.75, 0.5, 0.25))
        dev.off()





# get zooms of all turf polygons

    turfPlot_l<-list()
    for (poly in 1:sum(polys$class=="turf")) {

        turfPlot_l[[poly]]<-GetZoomedPleiades(s, polys, polyClass="turf", col="red", margin=10, i=poly)

    }

    png(file.path("Figures","TurfPolygons.png"), height = 8.3, width = 13, units = 'in', res = 600)
        cowplot::plot_grid(plotlist=turfPlot_l)
    dev.off()
