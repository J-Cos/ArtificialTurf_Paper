GetClassPoints<-function(class_item, points){
                  class_data <- subset(points, class == class_item)
                  classpts <- spsample(class_data, type = "stratified", n = 1000)
                  classpts$class <- rep(class_item, length(classpts))
                  return(classpts)
                }