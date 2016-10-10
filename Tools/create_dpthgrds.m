function new_grids=create_dpthgrds(xyz, resolution, t_pvar, t_sig,...
    ranges, filename, LatBat)


    %new_grids=create_dpthgrds(xyz, resolution, t_pvar, t_sig, ranges, filename, LatBat)


    x_range=ranges(1); y_range=ranges(2);
    [regdist,u]=unique_old(LatBat.regdist); regbat=LatBat.regbat(u);

    %finding new origin so deepest point falls on grid point
    deepest_pt=find(LatBat.regbat==max(LatBat.regbat));
    dist_deepest_pt=LatBat.regdist(deepest_pt);
    
    %set inc
    if strcmp(resolution, 'low')
        inc=[10 10];
    elseif strcmp(resolution,'med')
        inc=[5 10];
    else
        inc=[2.5 10];
    end
    
    %set range
    steps_up=floor((x_range-dist_deepest_pt)/inc(1));
    steps_down=floor(dist_deepest_pt/inc(1));
    x_domain=[dist_deepest_pt-steps_down*inc(1) dist_deepest_pt+steps_up*inc(1)];
    range=[x_domain 0 floor(y_range/inc(2))*inc(2)];
    
    %identify what's going into to ppzgrid
    the_info=xyz(:,:,1);
    sal_info=xyz(:,:,2);
    sig_info=xyz(:,:,3);
    
    %functions that create structures for each parameter  containing
    %gridded X, Y, and Z as well CPT and levels
    the=grid_grids(the_info,inc,t_pvar,range,filename);
    sal=grid_grids(sal_info,inc,t_pvar,range,filename);
    sig=grid_grids(sig_info,inc,t_sig,range,filename,2);
      
    new_grids.X=the.X;
    new_grids.Y=the.Y;
    new_grids.the=the.Z;
    new_grids.sal=sal.Z;
    new_grids.sig=sig.Z;
    
    new_grids.arg.the=the.arg;
    new_grids.arg.sal=sal.arg;
    new_grids.arg.sig=sig.arg;
    
end