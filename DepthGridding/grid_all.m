%This creates both high and low resolution grids of each occupation from
%xyz_batproj matricies in the Gridding folder. It saves the grids as a 2x1
%structure.

%The different gridded 
close all;
clear all;

%load mat files
LatBat=load('/Users/Dana/Documents/MATLAB/Latrabjarg/Bathymetry/LatBat.mat');
load XYGrids.mat;
load('/Users/Dana/Documents/MATLAB/Latrabjarg/XYZMod/XYZ_dpthextrap.mat');

%set plotting parameters
scrsz = get(0,'ScreenSize');

%setting the approximate dimensions of the master grid
x_range=max(LatBat.regdist);
y_range=750;

%get grid resolutions and tension factors
tdfread('grd_specs_dpthgrd.txt',',');
resol={'low2med2high' 'med2high' 'high'};

for i=1:length(XYZ)
    grids(i).name=XYZ(i).name;
end

for i=1:length(grids)

    %create masking file
    filename=mat2str(['bottom_mask_' XYZ(i).name(1:10) '.txt']);
    grids(i).mask=mask_xyz(XYZ(i).xyz, [x_range y_range], filename, LatBat);
    
    %create grids
    if grd(i)==1
    var=create_dpthgrds(XYZ(i).xyz,'low',t_pvar(i),t_sig(i),[x_range y_range],...
        filename,LatBat);
    x=X.low(1,:);
    dist=XYZ(i).fields.dist;
    [new_dist,ids]=nearest_neighbor(x,dist);
    grids(i).stagrdx=new_dist(:);
    
    elseif grd(i)==2
    var=create_dpthgrds(XYZ(i).xyz,'med',t_pvar(i),t_sig(i),[x_range y_range],...
        filename,LatBat);
    x=X.med(1,:);
    dist=XYZ(i).fields.dist;
    [new_dist,ids]=nearest_neighbor(x,dist);
    grids(i).stagrdx=new_dist(:);
    
    elseif grd(i)==3
    var=create_dpthgrds(XYZ(i).xyz,'high',t_pvar(i),t_sig(i),[x_range y_range],...
        filename,LatBat);
    x=X.high(1,:);
    dist=XYZ(i).fields.dist;
    [new_dist,ids]=nearest_neighbor(x,dist);
    grids(i).stagrdx=new_dist(:);
    end
    

    grids(i).X=var.X;
    grids(i).Y=var.Y;
    grids(i).the=var.the;
    grids(i).sal=var.sal;
    grids(i).sig=var.sig;
    grids(i).arg=var.arg;
    
    disp(i)
end

%Save the "grids" structure
save('grids_first', 'grids');