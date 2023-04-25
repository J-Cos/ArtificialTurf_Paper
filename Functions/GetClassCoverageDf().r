GetClassCoverageDf<-function(sc, resPl){
    landcoverdf<- freq(sc, useNA="no") %>%
        as_tibble %>%
        mutate(area_m2=count*prod(resPl))

    return(landcoverdf)
}
