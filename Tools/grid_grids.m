function gridded_var=grid_grids(info, inc, t, range, filename, smooth)

addpath('/Users/Dana/Documents/MATLAB/CPT_files');
info = real(info); range = real(range);

for i=1:length(t)

    tension=t(i);
    
    %assign arguments and grid
    if nargin > 4
        arg=['-I' num2str(inc(1)) '/' num2str(inc(2)) ' -R' ...
        num2str(range(1)) '/' num2str(range(2)) '/'...
        num2str(range(3)) '/' num2str(range(4)) ' -S'...
        '20' ' -T' num2str(tension) ' -M'...
        filename];
    else
        arg=['-I' num2str(inc(1)) '/' num2str(inc(2)) ' -R' ...
        num2str(range(1)) '/' num2str(range(2)) '/'...
        num2str(range(3)) '/' num2str(range(4)) ' -S'...
        '20' ' -T' num2str(tension) ];
    end
        
    
    %feed into ppzgrid
    [Z,grd_struct]=ppzinit(info,arg);
    x=grd_struct.x_min:grd_struct.x_inc:grd_struct.x_max;
    y=grd_struct.y_min:grd_struct.y_inc:grd_struct.y_max;
    [X,Y]=meshgrid(x,y);

    %smooth
    if nargin == 6
        smooth_arg = strcat('-ENaN -Fs0 -S', mat2str(smooth));
        [Z,grd_struct]=ppsmooth(Z,grd_struct, smooth_arg);
    end
    
    eval(['gridded_var.X=X;']);
    eval(['gridded_var.Y=Y;']);
    eval(['gridded_var.Z=Z;']);
    eval(['gridded_var.arg=arg;']);
    
end
end