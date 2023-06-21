### Example hyper-parameter tuning

#set up
    library(randomForest)
    library(tidyverse)
    library(ggplot2)
    
    set.seed(1)
    data(iris)

# visualise ntree parameter impact on error
    mod <- randomForest::randomForest(Species ~ ., data=iris, ntree=10001, confusion=TRUE) # mtry not specified so uses defalt value
    plot(mod)

# explore mtry
    #use inbuilt function
                model_tuned <- randomForest::tuneRF(
                    x =dplyr::select(iris, -Species),
                    y=iris$Species, 
                    ntreeTry=1001,
                    mtryStart=2, 
                    stepFactor=1.5,
                    improve=0.1,
                    trace=TRUE #don't show real-time progress
                )

    #use loop to get replicate answers
        #set number of replicates and trees desired
            numReplicates<-100
            numTrees<-1001
        #run loop
            mtryRange<-dim(iris)[2]-2
            oobs<-data.frame(oob=rep(NA, mtryRange*numReplicates))
            counter<-1
            for (replicate in 1:numReplicates){
                for (mtry in 2:(mtryRange+1) ) {
                    mod <- randomForest::randomForest(Species ~ ., data=iris, ntree=numTrees, mtry=mtry) # mtry not specified so uses defalt value
                    oobs$oob[counter]<-as.vector(mod$err.rate[numTrees, 1])
                    oobs$mtry[counter]<-mtry
                    oobs$replicate[counter]<-replicate

                    counter<-counter+1
                }
                print(paste0("Replicate ", replicate, " complete"))
            }
        #plot
        ggplot(oobs, aes(x=mtry, y=oob))+
            geom_jitter(width = 0.1, height = 0.001, alpha=0.5) #adds a little jitter to points to aid visualisation


