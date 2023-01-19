GetClassCoverageDf<-function(sc, resPl){
    sc_freq<- freq(sc, useNA="no")
    area_m2 <- sc_freq[,"count"]*prod(resPl)
    landcoverdf <- data.frame(landcover=classes, area_m2=area_m2)
    return(landcoverdf)
}
