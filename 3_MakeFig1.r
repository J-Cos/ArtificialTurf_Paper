#########################
# Make fig 1
##########################

#1: Dependencies
    #packages
        library(terra)
        library(tidyverse)
        library(tidyterra)
        library(ggplot2)

    #load project functions
        function_files<-list.files(file.path("Code","Functions"))
        sapply(file.path("Code","Functions",function_files),source)

#2. Load data
        s <-  terra::rast(file.path("Outputs", "Stretched.tif"))

#3) make maps
    # get pleiades image
        pimage <- ggplot() +
                        geom_spatraster_rgb( data = s,alpha = 1, r=1, g=2, b=3)+
                        theme_classic()

    # get location map
        world_coordinates <- ggplot2::map_data("world") 
        LocationMap<-ggplot() + 
            geom_map( 
                data = world_coordinates, map = world_coordinates, 
                aes(long, lat, map_id = region), fill="black" 
            )+
            coord_sf(
                default_crs = 4326,
                xlim = c(-9, 1.5), ylim = c(49, 60.2)
            ) +
            annotate("point", x=0.1966, y=51.904, color="red", fill="red", size=2)+
            theme_classic()+
            theme(  axis.title.x = element_blank(),
                    axis.title.y = element_blank() )
                    
# 4) print plot

    scalingFactor<-(6.85/8) # to fit 174mm page width of J. Urban Ecosystems

    tiff(file.path("Figures","Fig1.tiff"), height = 8, width = 8, units = 'in', res = 600* scalingFactor)
            cowplot::ggdraw() +
                cowplot::draw_plot(cowplot::as_grob(pimage),  x=0, y=0, width=1, height=1)+
                cowplot::draw_plot(LocationMap, x=0.8, y=0.8, width=0.2, height=0.2)
    dev.off()