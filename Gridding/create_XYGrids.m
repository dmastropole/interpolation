%This script creates the X and Y grids in ppzgrid
clear all;
close all;

load 1990-03-01_xyz_batproj.mat;
LatBat=load('/Users/Dana/Documents/MATLAB/Latrabjarg/Bathymetry/LatBat.mat');

[regdist,u]=unique_old(LatBat.regdist); regbat=LatBat.regbat(u);
x_range=max(LatBat.regdist);
y_range=750;

%finding new origin so deepest point falls on grid point
deepest_pt=find(LatBat.regbat==max(LatBat.regbat));
dist_deepest_pt=LatBat.regdist(deepest_pt);


for i=1:3
    if i==1
        inc=[10 10];
    elseif i==2
        inc=[5 10];
    elseif i==3
        inc=[2.5 10];
    end
    
    %set range
    steps_up=floor((x_range-dist_deepest_pt)/inc(1));
    steps_down=floor(dist_deepest_pt/inc(1));
    x_domain=[dist_deepest_pt-steps_down*inc(1) dist_deepest_pt+steps_up*inc(1)];
    range=[x_domain 0 floor(y_range/inc(2))*inc(2)];

    tension=0;
    %assign arguments and grid
    arg=['-I' num2str(inc(1)) '/' num2str(inc(2)) ' -R' ...
    num2str(range(1)) '/' num2str(range(2)) '/'...
    num2str(range(3)) '/' num2str(range(4)) ' -S'...
    '15' ' -T' num2str(tension)];
    
    %feed into ppzgrid
    [Z,grd_struct]=ppzinit(xyz_batproj(:,3:5,1),arg);
    
    x=grd_struct.x_min:grd_struct.x_inc:grd_struct.x_max;
    y=grd_struct.y_min:grd_struct.y_inc:grd_struct.y_max;
    
    [XX,YY]=meshgrid(x,y);
    
    if i==1
        X.low=XX;
        Y.low=YY;
        dim.low=inc;
    elseif i==2
        X.med=XX;
        Y.med=YY;
        dim.med=inc;
    elseif i==3
        X.high=XX;
        Y.high=YY;
        dim.high=inc;
    end
end

save(['XYGrids.mat'], 'X', 'Y', 'dim');