function [x,y,xsmall,ysmall] = create_patch(XYZ)

%this function creates a patch (x,y) using cast data for types "nij" and
%"egc." It also returns xdata and ydata that correspond to the polygon that
%inscribes the data. 

load('/Users/Dana/Documents/MATLAB/Latrabjarg/Bathymetry/LatBat.mat');
%get rid of repeated regdist values
[regdist,c]=unique(regdist);
regbat = regbat(c);

x=[]; y=[];
xsmall=[];ysmall=[];

xyz = XYZ.pxyz;

[dist,ixyz,idist] = unique(xyz(:,1,1));
stations = unique(idist);
dist = dist(stations);

%find distance and depth coordinates of upper limit of calculation
k=1;
for i=1:length(stations)
    staids = idist == stations(i);
    depth_ids = staids;
    
    if sum(depth_ids*1)~=0
        sta_dist(k) = dist(i);
        sta_upper(k) = xyz(min(find(depth_ids*1==1)),2,1);
        sta_lower(k) = xyz(max(find(depth_ids*1==1)),2,1);
        k=k+1;
    end
    
end

if k==1
    return
end

%lengthen 
xx = [min(sta_dist)-2.5; sta_dist(:); max(sta_dist)+2.5];
yupper = [sta_upper(sta_dist == min(sta_dist)); sta_upper(:); ...
    sta_upper(sta_dist == max(sta_dist))];
ylower = [sta_lower(sta_dist == min(sta_dist)); sta_lower(:); ...
    sta_lower(sta_dist == max(sta_dist))]+10;

 
%get rid of negative yy values created in spline process
nids = yupper < 0;
yupper = yupper(~nids);
ylower = ylower(~nids);
xx = xx(~nids);

%create patch
%find bathymetry beneath xx,yy contour
ids = regdist >= min(xx) & regdist <= max(xx);
xbat = regdist(ids);
ybat = regbat(ids);

xbig = [min(regdist);regdist; max(regdist); min(regdist)];
ybig = [0; regbat; 0; 0];

% xsmall = [xbat(:); flipud(xx); min(xbat)];
% ysmall = [ybat(:); flipud(yupper); ybat(xbat == min(xbat))]; 
xsmall = [xx(:); flipud(xx); min(xx)];
ysmall = [ylower(:); flipud(yupper); ylower(xx == min(xx))]; 
[x,y] = polybool('-',xbig,ybig,xsmall,ysmall);

end