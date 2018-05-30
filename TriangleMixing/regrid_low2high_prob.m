%This script regrids the low resolution sections onto the high resolution
%grid.  

close all;
clear all;

%get grid resolutions and tension factors
load('/Users/Dana/Documents/MATLAB/Latrabjarg/ChooseGrids/grd_specs_comb.mat');
tdfread('/Users/Dana/Documents/MATLAB/Latrabjarg/ChooseGrids/choose_grid_type.txt',',');
resol={'low2med2high' 'med2high' 'high'};

%load in gridded density from first iteration 
depth_grids=load('/Users/Dana/Documents/MATLAB/Latrabjarg/DepthGridding/grids_first.mat');
mix_grids=load('/Users/Dana/Documents/MATLAB/Latrabjarg/Gridding/grids_first.mat');
for i=1:length(depth_grids.grids)
    if strcmp(type(i,:),'depth')
        sig_grids(i) = depth_grids.grids(i);
    else
        sig_grids(i) = mix_grids.grids(i);
    end
end

load grids_first.mat;
LatBat=load('/Users/Dana/Documents/MATLAB/Latrabjarg/Bathymetry/LatBat.mat');

%setting the approximate dimensions of the master grid
x_range=max(LatBat.regdist);
y_range=750;

%low --> med
for i=1:length(grids)
    
    if ~ismember(i,toss_occs)
    if grd(i)==1
        
    disp(['i = ' mat2str(i)]);
        
    %create a new xyz matrix (only 3 cols) to feed into ppzgrid
    [pxyz_regrid,xyz_regrid]=create_pxyz_regrid(grids(i),sig_grids(i));
%     xyz_regrid=create_xyz_regrid(sig_grids,i);    
    
    %identify bottom mask file which corresponds to occupation i
    filename=mat2str(['bottom_mask_' grids(i).name(1:10) '.txt']);
    
    %create grids
    var=create_pgrids(pxyz_regrid,xyz_regrid,'med',t_pvar(i),t_sig(i),...
        [x_range y_range],filename,LatBat,type(i,:));
    
    %regrid sig
    if strcmp(strtrim(type(i,:)),'mix')
        sig=create_grids(xyz_regrid,'med',t_pvar(i),t_sig(i),[x_range y_range],...
            filename,LatBat);
    else
        sig=create_dpthgrds(xyz_regrid,'med',t_pvar(i),t_sig(i),[x_range y_range],...
            filename,LatBat);
    end
    sig_grids(i).sig = sig.sig;
    sig_grids(i).X = sig.X;
    sig_grids(i).Y = sig.Y;
    
    %add the new grid as a field
    fnames = fieldnames(var);
    for n=1:length(fnames)
        eval(['grids(' mat2str(i) ').' fnames{n} '=var.' fnames{n} ';']);
    end
    
    clear xyz_regrid pxyz_regrid;
    end
    end
end


%low --> med --> high
for j=1:length(grids)
    
    if ~ismember(j,toss_occs)
    if grd(j)==1
        
    disp(['j = ' mat2str(j)]);
        
    %create a new xyz matrix (only 3 cols) to feed into ppzgrid
    [pxyz_regrid,xyz_regrid]=create_pxyz_regrid(grids(j),sig_grids(j));
%     xyz_regrid=create_xyz_regrid(sig_grids,j); 
    
    %identify bottom mask file which corresponds to occupation i
    filename=mat2str(['bottom_mask_' grids(j).name(1:10) '.txt']);
    
    %create grids
    var=create_pgrids(pxyz_regrid,xyz_regrid,'high',t_pvar(j),t_sig(j),...
        [x_range y_range],filename,LatBat,type(j,:));
    
    %add the new grid as a field
    fnames = fieldnames(var);
    for n=1:length(fnames)
        eval(['grids(' mat2str(j) ').' fnames{n} '=var.' fnames{n} ';']);
    end
    
    clear xyz_regrid pxyz_regrid;

    end
    end
end

%med --> high
for k=1:length(grids)
    if ~ismember(k,toss_occs)
    
    if grd(k)==2
        
    disp(['k = ' mat2str(k)]);
        
    %create a new xyz matrix (only 3 cols) to feed into ppzgrid
    [pxyz_regrid,xyz_regrid]=create_pxyz_regrid(grids(k),sig_grids(k));
%     xyz_regrid=create_xyz_regrid(sig_grids,k); 
    
    %identify bottom mask file which corresponds to occupation i
    filename=mat2str(['bottom_mask_' grids(k).name(1:10) '.txt']);
    
    %create grids
    var=create_pgrids(pxyz_regrid,xyz_regrid,'high',t_pvar(k),t_sig(k),...
        [x_range y_range],filename,LatBat,type(k,:));
    
    %add the new grid as a field
    fnames = fieldnames(var);
    for n=1:length(fnames)
        eval(['grids(' mat2str(k) ').' fnames{n} '=var.' fnames{n} ';']);
    end
    
    clear xyz_regrid pxyz_regrid;
    end
    end
end

%Save the "grids" structure
save('grids_regrid', 'grids','toss_occs');
