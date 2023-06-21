ExcludeClassFromTestTrain<-function(TestTrain, Class){
    for (i in c(1,3) ) { 
        keep<-TestTrain[[i]][["pointVals"]]$response != Class

        TestTrain[[i]][["pointVals"]]<-TestTrain[[i]][["pointVals"]][keep,] %>% droplevels()
        TestTrain[[i]][["NumberCellsPerCategory"]] <-TestTrain[[i]][["NumberCellsPerCategory"]] [ names(TestTrain[[i]][["NumberCellsPerCategory"]]) != Class ]
        TestTrain[[i]][["points"]]<-TestTrain[[i]][["points"]][keep,]
    }
    return(TestTrain)
}