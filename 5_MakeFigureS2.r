#########################
# Conduct supervised classification
##########################

#1: Dependencies
    #packages
        library(sp)
        library(terra)
        library(raster)
        library(rgdal)
        library(tidyverse)

    #load project functions
        function_files<-list.files(file.path("Code","Functions"))
        sapply(file.path("Code","Functions",function_files),source)


    #saving random forest models - (classification rasters written to file by functions)
        df<-data.frame(val=c(1,2,3,4), cat=c("Vegetation", "Man-made", "Artificial Turf", "Water"))
        sc15<-terra::rast(file.path("Outputs", "landcover_15.tif"))
        levels(sc15)<-df
        sc15seg<-terra::rast(file.path("Outputs", "landcover_15seg.tif")) #%>%
        levels(sc15seg)<-df


        TrainPolys<-terra::vect(readRDS(file.path("Outputs", "TrainTestPolys.RDS"))[["trainPolys"]])
        TestPolys<-terra::vect(readRDS(file.path("Outputs", "TrainTestPolys.RDS"))[["testPolys"]])

MakeTurfClassificationDf<-function(Polys, sc){
    TurfPolys<-subset(Polys, Polys$class=="turf")

    Turf_df<-terra::extract(sc, TurfPolys) %>%
        as_tibble %>%
        group_by(ID, cat)%>%
        summarise(n=n()) %>%
        pivot_wider(names_from=cat, values_from=n)%>%
        pivot_longer(-ID, names_to="cat", values_to="n") %>%
        mutate(n=replace_na(n, 0)) %>%
        mutate(total=sum(n, na.rm=TRUE)) %>%
        mutate(prop=n/total) 
    return(Turf_df)
    }

MakeTurfClassificationPlot<-function(Turf_df) {

    p<-Turf_df %>%
        filter(cat=="Artificial Turf") %>%
        mutate(TurfSize=cut(total, breaks=c(0, 10, 100, 1000, 10000, 100000))) %>% 
        mutate(TurfSize = fct_recode(TurfSize, "1-10"="(0,10]", "10-100"="(10,100]", "100-1,000"="(100,1e+03]","1,000-10,000"="(1e+03,1e+04]", "10,000-100,000"="(1e+04,1e+05]" )) %>%
        ggplot(., aes(x=TurfSize, y=prop))+
            geom_boxplot(outlier.shape = NA)+
            geom_jitter(aes(color=TV), width=0.25, size=2)+
            facet_wrap(~TV)+
            theme_classic()+
            geom_hline(yintercept=0.9, linetype=3)+
            ylab("Proportion of pixels\ncorrectly classified")+
            xlab("Number of pixels in reference polygon")+
            theme(
                legend.position="none",
                axis.title=element_text(size=16),
                axis.text=element_text(size=10, color="black" ),
                strip.text=element_text(size=16),
                strip.background = element_blank()
            )
    return(p)
}

# 2. make figure and stats
    #pixel based df
        Turf_df<-rbind(
            mutate(MakeTurfClassificationDf(TrainPolys, sc15), TV="Training turf polygons"),
            mutate(MakeTurfClassificationDf(TestPolys, sc15), TV="Validation turf polygons")
        )

    #object based df
        Turfseg_df<-rbind(
            mutate(MakeTurfClassificationDf(TrainPolys, sc15seg), TV="Training turf polygons"),
            mutate(MakeTurfClassificationDf(TestPolys, sc15seg), TV="Validation turf polygons")
        )
    
    #get stats 
        dat<-Turf_df %>%
            filter(cat=="Artificial Turf") %>%
            filter(TV=="Validation turf polygons") 
        cor.test(dat$total, dat$prop, method="spearman")

        dat %>%
            mutate(size=total>10) %>%
            kruskal.test(prop~size, .)

        datseg<-Turfseg_df %>%
            filter(cat=="Artificial Turf") %>%
            filter(TV=="Validation turf polygons")  
        cor.test(datseg$total, datseg$prop, method="spearman")
        datseg %>%
            mutate(size=total>10) %>%
            kruskal.test(prop~size, .)

    #make fig
        pb_plot<-MakeTurfClassificationPlot(Turf_df)
        ob_plot<-MakeTurfClassificationPlot(Turfseg_df)

    pdf(file.path("Figures",paste0("Figure3.pdf")), height = 6, width = 12)
        cowplot::ggdraw() +
            cowplot::draw_plot(pb_plot, x=0, y=0.5, width=1, height=0.5)+
            cowplot::draw_plot(ob_plot, x=0, y=0, width=1, height=0.5)+
            cowplot::draw_plot_label(   label = c("A", "B"), size = 15, x = c(  0, 0), y = c(1, 0.5))
    dev.off()

 

