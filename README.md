[![DOI](https://zenodo.org/badge/590949414.svg)](https://zenodo.org/doi/10.5281/zenodo.10214173)

# ArtificialTurf_Paper
 Code for manuscript: "Challenges for monitoring the growth of artificial turf with remote sensing"

## Instructions

### Step 1 - Create Directory Structure
Create a project directory with the following subdirectories
- Code (contaning a clone of this repo)
- Data/Stevenage (containing i) clipped2015.tif; and ii) a directory called 'test_train' containing the reference data shapefile
- Outputs (into which intermediate outputs will be written)
- Figures (into which paper figures and tables will be written)

### Step 2 - Run Code
- Open R from the project directory
- Run the code scripts in the order they are numbered, each relies on outputs from those before. If two scripts have the same number they can be run in any order.
- No paths need to be changed if the directory structure above is implemented as the code uses only relative paths.


### Notes

#### Figures produced by scripts
- Fig 1 - pleidaes data and location
- Fig 2 – land cover map, zoomed in on a few turf areas where classifications are wrong (showing object and pixel based)

- Table 1 – NA (not generated from data)
- Table 2 – stats of training and test data
- Table 3 – confusion matrices and accuracy tables for each approach

- Fig S1 – locations of reference polygons
- Fig S2 - boxplots showing turf classification accuracy by size of reference polygon
