GetClassPoints<-function(class_item, points){
                  class_data <- subset(points, class_name == class_item)
                  classpts <- spsample(class_data, type = "stratified", n = 1000)
                  classpts$class <- rep(class_i, length(classpts))
                  return(classpts)
                }