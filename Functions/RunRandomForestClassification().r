#direct dependencies
  #randomForest
  #terra
  #raster
  #caret
#indirect dependencies
  #rgdal
  #sp

RunRandomForestClassification<-function(data, tp) {

    
    #fit random forest
      print("Fitting random forest")
      mod <- randomForest::randomForest(response ~ ., data=tp[["pointVals"]], na.action=na.omit, ntree=200, confusion=TRUE)
      
      print("Predicting values")
      OutputName<-paste0("SupervisedClassification_",deparse(substitute(data)), "_", Sys.Date())
      modsc <- terra::predict(object=data, 
                              model=mod, 
                              type="response")
    
    return(list(
        "mod"=mod,
        "sc"=modsc
        ))
}