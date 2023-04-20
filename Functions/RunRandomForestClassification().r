
RunRandomForestClassification<-function(pleiades, tp, vp, classes= factor(c("green", "manmade", "turf", "water"))) {

  #run main random forest
    #unclear how this connects appears to only be used in noise filtering and independent validation - which itself is poorly connected
   # sc <- RStoolbox::superClass(img = pleiades, model = "rf", trainData = tp, valData = vp, responseCol = "class_name") 

    #extract training values into dataframe
      set.seed(25) 
      xy_train_list <- lapply(classes, GetClassPoints, points=tp)
      xy_train <- do.call("rbind", xy_train_list)

      trainingvals <- raster::extract(pleiades, y=xy_train, cellnumbers=TRUE)
      trainingvals <- data.frame(response = xy_train$class, trainingvals)

      # remove cells that are selected multiple times
        if (any(duplicated(trainingvals$cells))) {
          trainingvals <- trainingvals[!duplicated(trainingvals$cells), -2]
        }
        NumberCellsPerCategory<-table(trainingvals$response)

    #fit random forest
      mod <- randomForest(response ~ ., data=trainingvals, na.action=na.omit, ntree=500, confusion=TRUE)
      
      OutputName<-paste0("SupervisedClassifiction_",deparse(substitute(pleiades)), Sys.Date())

      modsc <- predict(pleiades, mod, filename=file.path("Outputs",OutputName), format="GTiff", datatype="INT1U", type="response", overwrite=TRUE)
      png(file.path("Outputs",paste0("View",OutputName,".png")), height = 8.3, width = 11.7, units = 'in', res = 300)
        terra::plot(modsc, legend=FALSE, axes=FALSE, box=FALSE, col = c("grey", "green"), bty = "n") 
      dev.off()

  # Filtering out noise # 
    #unclear how this connects, not returned
      #window <- matrix(1, 7, 7)
      #sc7x7 <- focal(sc, w = window, fun = modal)

  # Running independent validation # 
    set.seed(7)
    xy_validation_list <- lapply(classes, GetClassPoints, points=vp)
    xy_validation <- do.call("rbind", xy_validation_list)

    pred <- raster::extract(modsc, xy_validation, cellnumbers = TRUE)
    dup <- duplicated(pred)
    pred <- pred[!dup, "layer"]
    obs <- xy_validation$class[!dup]
    valFact <- classes[pred] 
    confMat<-confusionMatrix(obs, reference = valFact) 

  return(list(
              "randomForest"=mod,
              "randomForestPrediction"=modsc,
              "IndependentValidation"=confMat,
              "InputCellsPerCategory"=NumberCellsPerCategory
              )
          )
}