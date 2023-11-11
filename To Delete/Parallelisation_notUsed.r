      #modsc <- raster::predict(data, mod, filename=file.path("Outputs",OutputName), format="GTiff", datatype="INT1U", type="response", overwrite=TRUE)

      #divide raster into chunks 
        Chunk_list<-list()
        chunkDelimiters<-seq(from=1, to=dim(data)[1], by=100)
        numChunks<-length(chunkDelimiters)-1
        print(paste0("Diving into ", numChunks, " chunks"))
        for (i in 1:numChunks){
          Chunk_list[[i]]<-terra::crop(data, raster::extent(data,  chunkDelimiters[i], chunkDelimiters[i+1], 1, dim(data)[2]))
          print(paste0("Chunk ", i, " complete"))
        }

      #run parallel predictions
                print(paste0("Starting parallel classification with ", as.integer(mc.cores), " cores"))

                scs<-parallel::mclapply(Chunk_list[1:2], mc.cores=mc.cores, function(rasterChunk){
                                                        terra::predict(object=data, 
                                                          model=mod, 
                                                          #cores=4,
                                                          filename=file.path("Outputs",OutputName), 
                                                          format="GTiff", 
                                                          datatype="INT1U", 
                                                          type="response", 
                                                          overwrite=TRUE)
                                                        }
                                    )

      print("Recombining raster chunks")
      sc<-do.call(terra::merge, scs)



      data<-terra::crop(p19, raster::extent(p19, 1, 100, 1, 12344))
      ext(p19)
      names(data)<-names(p19)

terra::crop(p19, terra::ext(-50,0,0,30))

rfun <- function(mod, dat, ...) {
	library(randomForest)
	predict(mod, dat, ...)
}

system.time(tseq <- predict(data, mod))
system.time(tseq <- predict(data, mod, cores = 4))


start_time <- Sys.time()
  prf <- predict(data, mod, fun=rfun, cores=2)
end_time <- Sys.time()
end_time - start_time

