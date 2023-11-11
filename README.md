# ArtificialTurf_Paper
 Code for a remote sensing paper on artifical turf prevelence in Greater London

## Instructions

### Step 1 - Create Directory Structure
Create a project directory with the following subdirectories
- Code (contaning a clone of this repo)
- Data/Stevenage (containing i) clipped2015.tif; and ii) a directory called 'test_train' containing the reference data shapefile
- Outputs (into which intermediate and final outputs will be written)
- Figures (into which heuristic visualisations and paper figures will be written)

### Step 2 - Run Code
- Run the code scripts in the order they are numbered, each relies on outputs from those before. If two scripts have the same number they can be run in any order.
- No paths need to be changed if the directory structure above is implemented as the code uses only relative paths.


### Notes

#### Figures produced by scripts
- Fig 1 - pleidaes data and location
- Fig 2 – land cover map, zoomed in on a few turf areas where classifications are wrong (showing object and pixel based)

- Table 1 – training and test data descriptions
- Table 2 – stats of training and test data
- Table 3 – confusion matrix and accuracy table (as in Crowson et al., 2019)

- supp fig 1 – zoomed in classes and locations of points