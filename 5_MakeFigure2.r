##################
## Make figure 2 ###
##################

#1: Dependencies
    #packages
        library(terra)
        library(tidyverse)
        library(tidyterra)
        library(ggpubr)

    #load project functions
        function_files<-list.files(file.path("Code","Functions"))
        sapply(file.path("Code","Functions",function_files),source)

    # Parameters
        df<-data.frame(val=c(1,2,3,4), cat=c("Vegetation", "Man-made", "Artificial Turf", "Water"))
            plotCols<-c("green", "grey", "red", "blue")

#2. Load Data


    # Importing satellite data #
        sc15<-terra::rast(file.path("Outputs", "landcover_15.tif"))
        levels(sc15)<-df
        sc15seg<-terra::rast(file.path("Outputs", "landcover_15seg.tif")) #%>%
        levels(sc15seg)<-df


# 3. Make plots with some zoomed areas
    #get zoomed areas
        MakePolygon<-function(e){
            v <- as.polygons(crop(sc15, e), extent=TRUE)
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


    # make main plot
        makeMainPlot<-function(sc){
            plot<-ggplot() +
                geom_spatraster(
                    data = sc,alpha = 1, aes(fill=cat), na.rm=TRUE
                )+ 
                scale_fill_manual(values = plotCols, na.translate=FALSE)+
                geom_spatvector(data=polys, fill=NA, color="black")+
                geom_spatvector_text(data=polys, aes(label = polyNames), fontface = "bold", color = "black")+
                theme_classic()+
                theme(  axis.title = element_blank(),
                        legend.title= element_blank(),
                        legend.text=element_text(size=15))
            return(plot)
        }

        plot<-makeMainPlot(sc15)+theme(legend.position="none")
        plotseg<-makeMainPlot(sc15seg)+theme(legend.position="none")

        legend<-ggpubr::as_ggplot(ggpubr::get_legend(makeMainPlot(sc15)))

    #make zoomed subplots

        makeZoomedPlotList<-function(sc) {
            plot_l<-list()
            for (i in 1: length(ZoomedExtents)) {
                    plot_l[[i]]<-ggplot() +
                            geom_spatraster(       data= crop(sc, ZoomedExtents[[i]]), alpha = 1, na.rm=TRUE, show.legend=FALSE         )+ 
                            scale_fill_manual(values = plotCols, na.translate=FALSE)+
                            theme_classic()+
                            theme(  axis.title = element_blank(),
                                    axis.text=element_text(size=6) )
            }
            return(plot_l)
        }


        plot_l<-makeZoomedPlotList(sc15)
        plotseg_l<-makeZoomedPlotList(sc15seg)

#4. save compound figure

    png(file.path("Figures",paste0("Figure2.png")), height = 16.6, width = 16, units="in", res=600)
        cowplot::ggdraw() +
            cowplot::draw_plot(plot, x=0, y=0.5, width=0.45, height=0.5)+
            cowplot::draw_plot(ggpubr::ggarrange(plotlist=plot_l, nrow=2, ncol=2), x=0.45, y=0.5, width=0.45, height=0.5)+
            cowplot::draw_plot(plot, x=0, y=0, width=0.45, height=0.5)+
            cowplot::draw_plot(ggpubr::ggarrange(plotlist=plot_l, nrow=2, ncol=2), x=0.45, y=0, width=0.45, height=0.5)+
            cowplot::draw_plot(legend, x=0.9, y=0, width=0.1, height=1)+
            cowplot::draw_plot_label(   label = c("A", "B","C","D","E","F", "G", "H", "I", "J"), 
                        size = 15, 
                        x = c(  0, 0.45, 0.675, 0.45, 0.675,
                                0, 0.45, 0.675, 0.45, 0.675), 
                        y = c(1, 1, 1, 0.75, 0.75, 0.5, 0.5, 0.5, 0.25, 0.25))
    dev.off()
    