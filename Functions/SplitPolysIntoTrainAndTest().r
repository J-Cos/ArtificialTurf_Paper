
SplitPolysIntoTrainAndTest<-function(polys, trainPercent) {
    trainPolys_list<-list()
    testPolys_list<-list()
    for (class in unique(polys$class)) {
        classPolys<-polys[polys$class ==class,]
        trainIndices<-sample(1:length(classPolys),trainPercent*length(classPolys))
        trainPolys_list[[class]]<-classPolys[trainIndices,]
        testPolys_list[[class]]<-classPolys[-trainIndices,]
    }

    trainPolys <-do.call(rbind, trainPolys_list)
    testPolys<-do.call(rbind, testPolys_list)

    return(list(
        "trainPolys"=trainPolys,
        "testPolys"=testPolys
    ))
}