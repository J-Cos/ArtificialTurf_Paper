WriteClassCoverageCsv<-function(sc, resPl, name){
    freq(sc, useNA="no") %>%
        as_tibble %>%
        mutate(area_m2=count*prod(resPl)) %>%
        write.csv(file.path("Outputs", paste0("ClassCoverage_", name, ".csv")))
}
