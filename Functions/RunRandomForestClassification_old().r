#direct dependencies
  #randomForest
  #terra
  #raster
  #caret
#indirect dependencies
  #rgdal
  #sp

RunRandomForestClassification_old<-function(data, tp, vp) {

  #run main random forest
    #unclear how this connects appears to only be used in noise filtering and independent validation - which itself is poorly connected
   # sc <- RStoolbox::superClass(img = data, model = "rf", trainData = tp, valData = vp, responseCol = "class_name") 

    #extract training values into dataframe
      set.seed(25) 
      print("Getting training points")
      trainingvals<-GetClassPoints(data= data, polygons=tp, MaxPointsPerPolygon=10, StratifyingCellSize=0.1)

      write.csv(trainingvals[[2]], file=file.path("Outputs", "TrainingPoints.csv"))

    #some code to come splitting and lumping classes for different iterations
    #
    #
    #
    #
    #
    #
    #
    #
    
    #fit random forest
      print("Fitting random forest")
      mod <- randomForest::randomForest(response ~ ., data=trainingvals[["pointVals"]], na.action=na.omit, ntree=200, confusion=TRUE)
      
      OutputName<-paste0("SupervisedClassification_",deparse(substitute(data)), "_", Sys.Date())

      print("Predicting values")
      modsc <- terra::predict(object=data, 
                              model=mod, 
                              #cores=4,
                              filename=file.path("Outputs",OutputName), 
                              format="GTiff", 
                              datatype="INT1U", 
                              type="response", 
                              overwrite=TRUE)

      png(file.path("Outputs",paste0("View_",OutputName,".png")), height = 8.3, width = 11.7, units = 'in', res = 300)
        terra::plot(modsc, 
                    legend=FALSE, 
                    axes=FALSE, 
                    box=FALSE, 
                    col = c("green", "black", "red", "blue"), 
                    bty = "n") 
      dev.off()
      saveRDS(modsc, file.path("Outputs",paste0(OutputName,".RDS")))

  # Filtering out noise # 
    #unclear how this connects, not returned
      #window <- matrix(1, 7, 7)
      #sc7x7 <- focal(sc, w = window, fun = modal)

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

  return(list(
              "randomForest"=mod,
              "randomForestPrediction"=modsc,
              "IndependentValidation"=confMat,
              "InputCellsPerCategory"=trainingvals[["NumberCellsPerCategory"]]
              )
          )
}