function var=grid_var(xyz,p,names,vals)

%This function reads in a variable in XYZ column format and
%outputs gridded fields along with the the parameters used to generate the grid.
% 
%            var=grid_var(file, p)
%
%Input:       filename in single quotes (string) taken from the
%variable "file," which contains all of the .lis files.  
%       parameters - structure  with the following fields:
%               .inc - two element vector with x and y grid increments
%               respectively.
%               .range - 4 element vector with xmin xmax ymin ymax,
%               respectively.
%               .sradius - search radius for interpolation
%               .tension - tension/smoothing factor for interpolation
%Output:
%     var.     .sig     .data - gridded variable
%              .sal     .x - vector x
%              .the     .y - vector y
%              .oxy     .X- gridded X
%              .flu     .Y - gridded Y
%              .xms     .params - parameters used to generate grid
%                       .arg - string with the argument as used w/ ppzinit.

for i=1:size(xyz,3)

info=xyz(:,:,i);
var_name=names(i); 

parameters=p(i);
arg=['-I' num2str(parameters.inc(1)) '/' num2str(parameters.inc(2)) ' -R' ...
    num2str(parameters.range(1)) '/' num2str(parameters.range(2)) '/'...
    num2str(parameters.range(3)) '/' num2str(parameters.range(4)) ' -S'...
    num2str(parameters.sradius) ' -T' num2str(parameters.tension)];
    
%     ' -M'...
%    'bottom_mask.txt'];

[Z,grd_struct]=ppzinit(info,arg);

x=grd_struct.x_min:grd_struct.x_inc:grd_struct.x_max;
y=grd_struct.y_min:grd_struct.y_inc:grd_struct.y_max;

[X,Y]=meshgrid(x,y);

var.(cell2mat(var_name)).data=Z;
var.(cell2mat(var_name)).x=x;
var.(cell2mat(var_name)).y=y;
var.(cell2mat(var_name)).X=X;
var.(cell2mat(var_name)).Y=Y;
var.(cell2mat(var_name)).params=parameters;
var.(cell2mat(var_name)).string=arg;

%getting rid of fake data
dist=vals(:,4);
bottom=vals(:,5);
x_depth=interp1(dist, bottom, x);
grd_depth=repmat(x_depth,length(y),1);
f=(grd_depth<=Y);
nan_loc = logical(f);

var.(cell2mat(var_name)).data(nan_loc) = nan;
 
end


