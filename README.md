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
- Fig 1 - Overview figure of Stevenage. A) Location of Stevenage within the UK; B)  Pléiades image of Stevenage used in this study
- Fig 2 – Land cover classifications. (A-E) Generated from pixel-based random forest analysis, (F-J) generated from object-based random forest analysis

- Table 1 – NA (not generated from data)
- Table 2 – Confusion matrices with producer’s accuracies and user’s accuracies. A) Pixel-based random forest analysis; B) object-based random forest analysis. For each matrix, the number of classified pixels are provided. 

- Fig S1 – Locations of test and training data. A) All test and training data locations, B-E) zoomed examples of each class.
- Fig S2 - Proportion of correctly classified pixels in reference artificial turf polygons of different sizes. The number of pixels in the reference polygons are proportional to their size, so polygons with more reference points are larger polygons. We are using the size of the polygon as a proxy for the size of the area of artificial turf, as this is consistent with how we created the reference polygons.

- Table S1 – Number of training and test points broken down by class.
- Table S2 – Percentage of study area classified as each land-cover class by each classification approach.

