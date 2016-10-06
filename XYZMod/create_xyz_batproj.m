%This script goes through all the mat files in the XYZ folder and then
%shifts their distances (column 3) so that the depth of the cast best
%matches the bathymetry in a 5km radius.  It also spits out a plot of how
%much each station was shifted and then 

close all;
clear all;

LatBat=load('/Users/Dana/Documents/MATLAB/Latrabjarg/Bathymetry/LatBat.mat');
load XYZ_cutcasts;

%create vectors that store the distance of all the 90 deg projections as
%well as how much each stations was shifted
DIST=[]; DIFF=[];

%Cycle through each MAT file
for i=1:length(XYZ)
    
    %Extract the deistances, depths, and coordinates
    [dist,c]=unique_old(XYZ(i).xyz(:,1,1));
    depth=XYZ(i).xyz(c,2,1);
    
    %get rid of stations that fall off the line;
    ids = dist < max(LatBat.regdist) & dist > min(LatBat.regdist);
    dist = dist(ids);
    depth = depth(ids);
    datetime = XYZ(i).fields.datetime(ids);
    ids = ismember(XYZ(i).xyz(:,1,1), dist);
    XYZ(i).xyz=XYZ(i).xyz(ids,:,:);

    
    %change distances in xyz to distances using the bathymetry projection
    %scheme
    
    %cycle through each station in the occupation
    for n=1:length(dist)
        
        %find lat/lon of bathymetry corresponding to lat/lon of projected
        %station
        [il,D]=knnsearch(LatBat.regdist,dist(n));
        
        %find lat/lons of bathymetry within a 2km radius of the projected station
        %locations
        ils = LatBat.regdist >= dist(n)-2 & LatBat.regdist <= dist(n)+2;
    
        %find the lat/lon of the bathymetry whose bottom is closest to the
        %cast depth of the station
        batbot=LatBat.regbat(ils);
        [ib,d]=knnsearch(batbot,depth(n));
        BatBot(n)=batbot(ib);

        id=find(BatBot(n)==LatBat.regbat);
        Lat(n)=LatBat.reglat(id);
        Lon(n)=LatBat.reglon(id);
        Dist(n)=LatBat.regdist(id);
        
        %replace distances in xyz
        XYZ(i).xyz(XYZ(i).xyz(:,1,1)==dist(n),1,:)=Dist(n);

        clear batbot;
    end
    

%sort according to batproj distances
[Dist,c]=sort(Dist); 

%if Dists are out of order, display error message
if sum(diff(c))~=length(c)-1
    disp(['STATIONS FLIPPED! occ:' XYZ(i).name]);
end
Lon=Lon(c);Lat=Lat(c);datetime=datetime(c);

%change fields
XYZ(i).fields.datetime=datetime(:);
XYZ(i).fields.lon=Lon(:);
XYZ(i).fields.lat=Lat(:);
XYZ(i).fields.dist=Dist(:);

%sort xyz
xyz=[];

for n=1:length(Dist)
    xyz_sta=XYZ(i).xyz(XYZ(i).xyz(:,1,1)==Dist(n),:,:);
    xyz=[xyz;xyz_sta];
    clear xyz_sta;
end

XYZ(i).xyz=xyz;

DIST=[DIST;dist]; DIFF=[DIFF;abs(Dist(:)-dist(:))];

clear Lat Lon Dist BatBot
end

save('XYZ_batproj','XYZ');

f=figure;
scrsz = get(0,'ScreenSize');
set(f, 'Position', scrsz);
plot(LatBat.regdist,LatBat.regbat,'.m');
hold on;
scatter(DIST,DIFF.*100,'ob','MarkerFaceColor','b');
set(gca,'YDir','Reverse');
