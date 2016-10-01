# interpolation

#Data format
Hydrographic data is contained in XYZ.mat. XYZ is indexed by the occupation number (1-111). 

The fields are as follows:

.xyz = the data fed into the interpolator.

Columns represent the following: Distance-Depth-Property

Along the 3rd dimension of the matrix, the "Property" columns corresponds to the following: PotentialTemperature-Salinity-PotentialDensity 

.name = date of the occupation and some identifying information about the source

.information for each cast in the occupation (including datetime, lat, lon, and distance along the line)


# XYZMod
This folder contains scripts where the data were shifted and extrapolated before they were interpolated.


# ppzgrid
The scripts which carry out the interpolation are contained in the ppzgrid folder. 

#Gridding
Here data xyz are gridded in density space

#DepthGridding
Here data xyz are gridded in depth space

#ChooseGrids
Depth and density grids are combined/selected for individual occupations
