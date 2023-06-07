WriteConfusionMatrixCsvs<-function(confMat, name){
    path<-file.path("Outputs",paste0("ConfusionMatrixOutputs_", name))
    dir.create(path, showWarnings=FALSE)
    write.csv(p15_rf$IndependentValidation$overall, file=file.path(path, paste0("overall_", name, ".csv")))
    write.csv(p15_rf$IndependentValidation$byClass, file=file.path(path, paste0("byClass_", name, ".csv")))
    write.csv(p15_rf$IndependentValidation$table, file=file.path(path, paste0("table_", name, ".csv")))
}
