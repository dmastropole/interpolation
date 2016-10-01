%This script regrids the low resolution sections onto the high resolution
%grid.  

close all;
clear all;

load grids_first.mat;
LatBat=load('/Users/Dana/Documents/MATLAB/Latrabjarg/Bathymetry/LatBat.mat');

%setting the approximate dimensions of the master grid
x_range=max(LatBat.regdist);
y_range=750;

%get grid resolutions and tension factors
tdfread('grd_specs.txt',',');
resol={'low2med2high' 'med2high' 'high'};

%low --> med
for i=1:length(grids)
    if grd(i)==1
    %create a new xyz matrix (only 3 cols) to feed into ppzgrid
    xyz_regrid=create_xyz_regrid(grids,i);
    
    %identify bottom mask file which corresponds to occupation i
    filename=mat2str(['bottom_mask_' grids(i).name(1:10) '.txt']);
    
    %create grids
    var=create_grids(xyz_regrid,'med',t_pvar(i),t_sig(i),...
        [x_range y_range],filename, LatBat);
    
    %add the new grid as a field
    grids(i).X=var.X;
    grids(i).Y=var.Y;
    grids(i).the=var.the;
    grids(i).sal=var.sal;
    grids(i).sig=var.sig;
    clear xyz_regrid;
    i
    end
end


%low --> med --> high
for j=1:length(grids)
    if grd(j)==1
    %create a new xyz matrix (only 3 cols) to feed into ppzgrid
    xyz_regrid=create_xyz_regrid(grids, j);
    
    %identify bottom mask file which corresponds to occupation i
    filename=mat2str(['bottom_mask_' grids(j).name(1:10) '.txt']);
    
    %create grids
    var=create_grids(xyz_regrid,'high',t_pvar(j),t_sig(j),...
        [x_range y_range],filename, LatBat);
    
    %add the new grid as a field
    grids(j).X=var.X;
    grids(j).Y=var.Y;
    grids(j).the=var.the;
    grids(j).sal=var.sal;
    grids(j).sig=var.sig;
    clear xyz_regrid;
    j
    end
end

%med --> high
for k=1:length(grids)
    if grd(k)==2
    %create a new xyz matrix (only 3 cols) to feed into ppzgrid
    xyz_regrid=create_xyz_regrid(grids, k);
    
    %identify bottom mask file which corresponds to occupation i
    filename=mat2str(['bottom_mask_' grids(k).name(1:10) '.txt']);
    
    %create grids
    var=create_grids(xyz_regrid,'high',t_pvar(k),t_sig(k),...
        [x_range y_range],filename, LatBat);
    
    %add the new grid as a field
    grids(k).X=var.X;
    grids(k).Y=var.Y;
    grids(k).the=var.the;
    grids(k).sal=var.sal;
    grids(k).sig=var.sig;
    clear xyz_regrid;
    k
    end
end

%Save the "grids" structure
save('grids_regrid', 'grids');
