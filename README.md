# interpolation

## Data format

### XYZ
Hydrographic, station data are contained in XYZ.mat. XYZ is indexed by the occupation number (1-111). 

The fields are as follows:

.xyz = the data fed into the interpolator

Columns represent the following: Distance-Depth-Property

Along the 3rd dimension of the matrix, the "Property" columns corresponds to the following: PotentialTemperature-Salinity-PotentialDensity 

.name = date of the occupation and some identifying information about the source

.information for each cast in the occupation (including datetime, lat, lon, and distance along the line)

### Grids
Gridded, hydrographic data for each occupation are contained in grids.mat. grids is indexed by occupation number as well.

The fields are as follows:

.name = same ".name" field in XYZ

.mask = file that masks out bathymetry and unsampled regions of the strait

.stagrdx = the locations of gridpoints nearest each station (in kilometers) 

.X .Y .the .sal .sig = gridded X, Y, potential temperature, salinity, and potential density fields

.arg = input into ppzgrid (interpolator). it contains the search radius "-S", tension factor "-T" and masking file name "-M"


## Order which scripts are run
XYZMod/create_xyz_batproj.m

XYZMod/add_fake_dense_water.m --> Gridding

XYZMod/extrapolate_depth.m --> DepthGridding

(Depth)Gridding/grid_all.m

(Depth)Gridding/regrid_low2high.m

(Depth)Gridding/nan_grids.m

ChooseGrids/combine_grids.m

## Bathymetry
This folder contains the bathymetry file LatBat.mat

## XYZMod
This folder contains scripts where the data were shifted and extrapolated before they were interpolated.


## ppzgrid
The scripts which carry out the interpolation are contained in the ppzgrid folder. 

## Gridding
Here data xyz are gridded in density space

## DepthGridding
Here data xyz are gridded in depth space

## ChooseGrids
Depth and density grids are combined/selected for individual occupations

## Bolus
This folder contains the scripts needed to generate the bolus shape files (and Figure 9). First the brunt vaisala frequency should be calcuated for gridded sections. Then the scrips should be run in the following order:

bolus_contours.m

bolus_size_contours.m

bolus_transparencies.m

