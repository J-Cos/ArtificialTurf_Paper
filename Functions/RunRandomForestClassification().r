
RunRandomForestClassification<-function(data, tp, vp) {

  #run main random forest
    #unclear how this connects appears to only be used in noise filtering and independent validation - which itself is poorly connected
   # sc <- RStoolbox::superClass(img = data, model = "rf", trainData = tp, valData = vp, responseCol = "class_name") 

    #extract training values into dataframe
      set.seed(25) 
      trainingvals<-GetClassPoints(data= data, polygons=tp, MaxPointsPerPolygon=10, StratifyingCellSize=3)

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
      mod <- randomForest(response ~ ., data=trainingvals[["pointVals"]], na.action=na.omit, ntree=500, confusion=TRUE)
      
      OutputName<-paste0("SupervisedClassifiction_",deparse(substitute(data)), Sys.Date())

      modsc <- predict(data, mod, filename=file.path("Outputs",OutputName), format="GTiff", datatype="INT1U", type="response", overwrite=TRUE)
      png(file.path("Outputs",paste0("View",OutputName,".png")), height = 8.3, width = 11.7, units = 'in', res = 300)
        terra::plot(modsc, legend=FALSE, axes=FALSE, box=FALSE, col = c("grey", "green"), bty = "n") 
      dev.off()

  # Filtering out noise # 
    #unclear how this connects, not returned
      #window <- matrix(1, 7, 7)
      #sc7x7 <- focal(sc, w = window, fun = modal)

  # Running independent validation # 
    #extract our assigned classifications of the validation points
      validationpts<-GetClassPoints(data= data, polygons=vp, MaxPointsPerPolygon=10, StratifyingCellSize=3)
      obs<-validationpts[["points"]]$class %>% as.factor()

    #extract the predicted values of the same points
      pred <- raster::extract(modsc, validationpts[["points"]], cellnumbers = TRUE)
      preds<-pred[,"layer"] %>% as.factor()

    confMat<-confusionMatrix(obs, reference = preds) 

  return(list(
              "randomForest"=mod,
              "randomForestPrediction"=modsc,
              "IndependentValidation"=confMat,
              "InputCellsPerCategory"=trainingvals[["NumberCellsPerCategory"]]
              )
          )
}