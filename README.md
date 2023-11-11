# ArtificialTurf_Paper
 Code for a remote sensing paper on artifical turf prevelence in Greater London

## Instructions

### Step 1 - Create Directory Structure
Create a project directory with the following subdirectories
- Code (contaning a clone of this repo)
- Data/Stevenage (containing i) clipped2015.tif; ii) clipped2019.tif, and iii) a directory called 'test_train' containing the reference data shapefile
- Outputs (into which intermediate and final outputs will be written)
- Figures (into which heuristic visualisations and paper figures will be written)

### Step2 - Install dependencies (R packages)
- tidyverse

- raster
- terra
- RStoolbox
- rgdal
- sp

- randomForest
- caret

### Step 3 - Run Code
- Run the code scripts in the order they are numbered, each relies on outputs from those before.
- No paths need to be changed if the directory structure above is implemented as the code uses only relative paths.

<<<<<<< Updated upstream
=======
-N.B. ensure you start work from this directory - all paths are relative.
<<<<<<< Updated upstream
=======


# Analysis plan
Pre-processing 

 

    Classes 

Two classes:  

1 man made 

2 vegetated 

Should we have a separate class for areas of shadow?  

 

    Training and test data collection 

Only create training and test data for the areas we want to include in our analysis (based on the Verisk polygon data – gardens, parks… any other classes relevant to our analysis?) 

    Analysis 

 

Calculate NDVI 

 

Map accuracy: Visualisation and confusion matrix 

Crop the map using the Verisk data, so that we can better see how well the approach to analysis has worked 

 
>>>>>>> Stashed changes
>>>>>>> Stashed changes
