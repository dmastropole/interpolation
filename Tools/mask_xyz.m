%This function takes in xyz matrices creates a masking file.
%In this code, you can only mask out the bottom, not gaps in surface data.

function mask=mask_xyz(xyz, ranges, filename, LatBat)

x_range=ranges(1);
y_range=ranges(2);

[dist, b]=unique_old(xyz(:,1,1));
bot=xyz(b,2,1)+15;
half_way=dist(2:end)-dist(1:end-1);
half_way=half_way./2;
t=[0; b]+1;
t=t(1:end-1);
top=xyz(t,2,1);

%BOX
if nargin == 3
j=1;
for i=1:length(dist)-1
    new_dist(j)=dist(i);
    new_dist(j+1)=dist(i)+half_way(i);
    new_dist(j+2)=dist(i)+half_way(i);
    
    new_bot(j)=bot(i);
    new_bot(j+1)=bot(i);
    new_bot(j+2)=bot(i+1);
    
    new_top(j)=top(i);
    new_top(j+1)=top(i);
    new_top(j+2)=top(i+1);
    j=j+3;
end
i=i+1;
new_dist(j)=dist(i);
new_bot(j)=bot(i);
new_top(j)=top(i);

% dist_col=[new_dist fliplr(new_dist) new_dist(1)];
% depth_col=[new_top fliplr(new_bot) new_top(1)];

else

%BOTTOM BATHYMETRY MASK

%find the domain of the mask

if isempty(max(LatBat.regdist(LatBat.regdist<=min(dist)-10)))
    imin=find(LatBat.regdist==min(LatBat.regdist));
else
    imin=find(LatBat.regdist==max(LatBat.regdist(LatBat.regdist<=min(dist)-10)));
end
if size(imin>1)
    imin=min(imin);
end

if isempty(min(LatBat.regdist(LatBat.regdist>=max(dist)+10)))
    imax=find(LatBat.regdist==max(LatBat.regdist));
else
    imax=find(LatBat.regdist==min(LatBat.regdist(LatBat.regdist>=max(dist)+10)));
end
if size(imax>1)
    imax=max(imax);
end

ids=[imin:imax];
new_dist=LatBat.regdist(ids); new_dist=new_dist';
new_bot=LatBat.regbat(ids); new_bot=new_bot'+200;

end

dist_col=[new_dist new_dist(end) new_dist(1) new_dist(1)];
depth_col=[new_bot 0 0 new_bot(1)];
mask=[dist_col' depth_col'];

fid = fopen (filename,'w');
fprintf(fid,'>OUTSIDE\n');
fprintf(fid,'%8.2f%8.2f\n',mask');
fclose(fid);

end