%This script creates a data structure with all of the gridded occupations
%such that each occupation is either depth gridded or a hybrid
%depth-density grid

close all;
clear all;

load('/Users/Dana/Documents/MATLAB/Latrabjarg/DepthGridding/naned_grids.mat');
naned_grids_depth = grids;
load('/Users/Dana/Documents/MATLAB/Latrabjarg/Gridding/naned_grids.mat');
naned_grids = grids;

load('/Users/Dana/Documents/MATLAB/Latrabjarg/DepthGridding/grids.mat');
grids_depth = grids;
load('/Users/Dana/Documents/MATLAB/Latrabjarg/Gridding/grids.mat');

for i=1:length(grids)
    grids(i).type = 'mix';
    grids_depth(i).type = 'depth';
    
    naned_grids(i).type = 'mix';
    naned_grids_depth(i).type = 'depth';
end

tdfread('choose_grid_type.txt',',');
type = cellstr(type);

depthids = strcmp('depth',type);
grids(depthids) = grids_depth(depthids);
naned_grids(depthids) = naned_grids_depth(depthids);

save('grids','grids');

grids = naned_grids;
save('naned_grids','grids');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Rewrite text file for tension factors and grid resolution
tdfread('/Users/Dana/Documents/MATLAB/Latrabjarg/DepthGridding/grd_specs_dpthgrd.txt',',');
grd_depth = grd;
t_pvar_depth = t_pvar;
t_sig_depth = t_sig;

tdfread('/Users/Dana/Documents/MATLAB/Latrabjarg/Gridding/grd_specs.txt',',');

grd(depthids) = grd_depth(depthids);
t_pvar(depthids) = t_pvar_depth(depthids);
t_sig(depthids) = t_sig(depthids);

fid = fopen ('grd_specs_comb','w');
fprintf(fid,'occ,name,grd,t_pvar,t_sig\n');
for i=1:length(occ)
    fprintf(fid,'%3d,%s,%d,%d,%d\n',occ(i),name(i,:),grd(i),t_pvar(i),t_sig(i));
end
fclose(fid);

save('grd_specs_comb','grd','t_pvar','t_sig');