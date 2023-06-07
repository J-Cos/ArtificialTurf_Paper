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
      validationpts<-GetClassPoints(data= data, polygons=vp, MaxPointsPerPolygon=10, StratifyingCellSize=0.1)
      obs<-validationpts[["points"]]$class %>% as.factor()

    #extract the predicted values of the same points
      print("Quantifying predictive accuracy")
      pred <- raster::extract(modsc, validationpts[["points"]], cellnumbers = TRUE)
      preds<-pred[,"layer"] %>% as.factor()
      levels(preds) <- c("green", "manmade", "turf", "water")

      confMat<-caret::confusionMatrix(obs, reference = preds) 

  return(confMat)
}