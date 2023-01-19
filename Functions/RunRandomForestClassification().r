
RunRandomForestClassification<-function(pleiades, tp, vp, SupervisedClassifictionTIF) {

  #run main random forest
    #unclear how this connects appears to only be used in noise filtering and independent validation - which itself is poorly connected
    sc <- RStoolbox::superClass(img = pleiades, model = "rf", trainData = tp, valData = vp, responseCol = "class_name") 

    #define classes
      classes <- factor(c("green", "manmade", "turf", "water"))

    #extract training values into dataframe
      set.seed(25) 
      xy_train_list <- lapply(classes, GetClassPoints(points=tp))
      xy_train <- do.call("rbind", xy_train_list)

      trainingvals <- extract(pleiades, y=xy, cellnumbers=TRUE)
      trainingvals <- data.frame(response = xy$class, trainingvals)
      # unclear what the duplication and table steps are for - clarify and improve
        any(duplicated(trainingvals$cells))
        trainingvals <- trainingvals[!duplicated(trainingvals$cells), -2]
        table(trainingvals$response)

    #fit random forest
      mod <- randomForest(response ~ ., data=trainingvals, na.action=na.omit, ntree=500, confusion=TRUE)
      modsc <- predict(pleiades, mod, filename=file.path("Data",SupervisedClassifictionTIF), format="GTiff", datatype="INT1U", type="response")
      #plot(modsc, legend=FALSE, axes=FALSE, box=FALSE, col = c("chartreuse3", "lightblue1", "red", "dodgerblue"), bty = "n") 

  # Filtering out noise # 
    #unclear how this connects, not returned
      window <- matrix(1, 7, 7)
      sc7x7 <- focal(sc, w = window, fun = modal)

  # Running independent validation # 
  #unclear what this is doing, confirm and adjust, not returned
    set.seed(7)
    xy_validation_list <- lapply(classes, GetClassPoints(points=vp))
    xy_validation <- do.call("rbind", xy_validation_list)

    pred <- extract(sc, xy_validation, cellnumbers = TRUE)
    dup <- duplicated(pred)
    pred <- pred[!dup, "class_name"]
    obs <- xy_val$class[!dup]
    valFact <- classes[pred] 
    confMat<-confusionMatrix(obs, reference = valFact) 

  return(list(
              "randomForest"=mod,
              "randomForestPrediction"=modsc,
              "supervisedClassification"=sc
              )
          )
}
