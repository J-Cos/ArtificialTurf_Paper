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
        p15 <-  terra::rast(file.path("Outputs", "AllIndices_p15.tif"))

#3) make streched pleiades for optimal plotting contrast
        s <- terra::stretch(p15, minq=0.02, maxq=.98)
        terra::writeRaster(s, file.path("Outputs", "Stretched_p15.tif"), overwrite=TRUE)

#4) make maps
    # get pleiades image
        p15image <- ggplot() +
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
                xlim = c(-10.5, 2), ylim = c(49.5, 59)
            ) +
            annotate("point", x=0.1966, y=51.904, color="red", fill="red", size=5)+
            theme_classic()+
            theme(  axis.title.x = element_blank(),
                    axis.title.y = element_blank() )
                    
# 5) print plot
    png(file.path("Figures","Figure1.png"), height = 8.3, width = 15, units = 'in', res = 600)
            cowplot::ggdraw() +
                cowplot::draw_plot(LocationMap, x=0, y=0, width=0.5, height=1)+
                cowplot::draw_plot(cowplot::as_grob(p15image),  x=0.5, y=0, width=0.5, height=1)+
                cowplot::draw_plot_label(   label = c("A", "B"), 
                                        size = 15, 
                                        x = c(0,0.5), 
                                        y = c(1, 1))
    dev.off()