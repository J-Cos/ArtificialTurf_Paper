#function to extract stratified points from a spatial polygons dataframe of n polygons
# returns a spatialpointsdataframe

  #sp
  #raster
  #terra
GetClassPoints<-function(data, polygons, MaxPointsPerPolygonClass=c("Other"=10), StratifyingCellSize=0.1){

                #get stratiefied poitns from polygons
                print("Getting stratified points")
                  pts_list<-list()
                  for (i in 1:length(polygons)){
                    #get max points per polygon for this class of polygon
                      if ( polygons[i,]$class %in% names(MaxPointsPerPolygonClass) ) {
                        MaxPointsPerPolygon<-MaxPointsPerPolygonClass[as.character(polygons[i,]$class)]
                      } else {
                        MaxPointsPerPolygon<-MaxPointsPerPolygonClass["Other"]
                      }
                    # sample points
                      pts <- try(sp::spsample(polygons[i,], type = "stratified", cellsize=StratifyingCellSize))
                      if(class(pts)=="try-error") {return(print("StratifyingCellSize is too large for smallest polygon - there is some randomness in this process"))}
                      pts<-sample(pts,MaxPointsPerPolygon, replace=TRUE)
                      pts$class <- rep(polygons[i,]$class, length(pts))
                      pts_list<-c(pts_list, pts)
                    print(paste0("Polygon ", i , " (", polygons[i,]$class, ") complete"))
                  }
                  allpts <- do.call("rbind", pts_list)
                  allpts<-terra::vect(allpts)

                #extract values from raster based on raster cell each point falls within
                print("Extracting values from raster cells")
                  trainingvals <- terra::extract(data, y=allpts, cellnumbers=TRUE, method="simple")
                  trainingvals <- data.frame(response = allpts$class, trainingvals)
                
                # remove raster cells that are selected multiple times
                print("Removing duplicated cells")
                  if (any(duplicated(trainingvals$cells))) {
                    print(paste0(sum(duplicated(trainingvals$cells)), " duplicated cells removed"))
                    allpts<-allpts[!duplicated(trainingvals$cells),]
                    trainingvals <- trainingvals[!duplicated(trainingvals$cells), -2]
                  }

                #save point map for visual inspection
                  #png(file.path("Outputs","TrainingPoints.png"), height = 8.3, width = 11.7, units = 'in', res = 300)
                  #      terra::plot(allpts, col= c("water"="blue", "green"="green", "manmade"="black", "turf"="red"))
                  #dev.off()

                  #dir.create(file.path("Outputs","TrainingPointsShapeFile"), showWarnings=FALSE)
                  #raster::shapefile(allpts, filename=file.path("Outputs","TrainingPointsShapeFile", "TrainingPointsShapeFile"), overwrite=TRUE)

                #ensure class is a factor
                  trainingvals$response<-as.factor(trainingvals$response)
                  
                return( list( "pointVals"=trainingvals,
                              "NumberCellsPerCategory" = table(trainingvals$response),
                              "points"=allpts))
                }