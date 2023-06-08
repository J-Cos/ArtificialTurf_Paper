#direct dependencies
  #randomForest
  #terra
  #raster
  #caret
#indirect dependencies
  #rgdal
  #sp

RunIndependentValidation<-function(data, vp) {

  # Running independent validation # 
    #extract our assigned classifications of the validation points
      print("Getting validation points")
      obs<-vp[["points"]]$class

    #extract the predicted values of the same points
      print("Quantifying predictive accuracy")
      pred <- raster::extract(data, vp[["points"]], cellnumbers = TRUE)
      preds<-pred[,"layer"] %>% as.factor()
      levels(preds) <- c("Green", "Artifical", "Turf", "Water", "Shadow")

      confMat<-caret::confusionMatrix(obs, reference = preds) 

  return(confMat)
}