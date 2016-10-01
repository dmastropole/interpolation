function gridded_var=grid_sig(t, info, inc, range, regdist, regbat, filename)

for i=1:length(t)
    
    tension=t(i);
    gridded_var.levels=[26.5 27 27.25 27.5 27.6 27.7 27.8 27.9 27.95 28];
    
    %assign arguments and grid
    arg=['-I' num2str(inc(1)) '/' num2str(inc(2)) ' -R' ...
    num2str(range(1)) '/' num2str(range(2)) '/'...
    num2str(range(3)) '/' num2str(range(4)) ' -S'...
    '15' ' -T' num2str(tension) ' -M'...
    filename];
    
    %feed into ppzgrid
    [Z,grd_struct]=ppzinit(info,arg);
    
    x=grd_struct.x_min:grd_struct.x_inc:grd_struct.x_max;
    y=grd_struct.y_min:grd_struct.y_inc:grd_struct.y_max;
    
    [X,Y]=meshgrid(x,y);
    y_bat=interp1(regdist, regbat, x);

    %nan out all data below the bottom
    for j=1:length(x)
        nids=find(Y(:,j)>y_bat(j));
        Z(nids,j)=NaN;
        clear nids;
    end
    
    eval(['gridded_var.T' num2str(t(i)) '.X=X;']);
    eval(['gridded_var.T' num2str(t(i)) '.Y=Y;']);
    eval(['gridded_var.T' num2str(t(i)) '.Z=Z;']);
    eval(['gridded_var.T' num2str(t(i)) '.arg=arg;']);
    
end

end