function new_grids=create_grids(xyz, resolution, t_pvar, t_sig,...
    ranges, filename, LatBat)

    %new_grids=create_grids(xyz, resolution, t_pvar, t_sig, ranges, filename, LatBat)

    xyz = real(xyz);

    x_range=ranges(1); y_range=ranges(2);
    [regdist,u]=unique_old(LatBat.regdist); regbat=LatBat.regbat(u);

    %finding new origin so deepest point falls on grid point
    deepest_pt=find(LatBat.regbat==max(LatBat.regbat));
    dist_deepest_pt=LatBat.regdist(deepest_pt);
    
    %set inc in depth space
    if strcmp(resolution, 'low')
        inc=[10 10];
    elseif strcmp(resolution,'med')
        inc=[5 10];
    else
        inc=[2.5 10];
    end
    
    %set inc in density sapce
    if strcmp(resolution, 'low')
        sinc=[10 0.01]; 
    elseif strcmp(resolution,'med')
        sinc=[5 0.01];
    else
        sinc=[2.5 0.01];
    end
    
    %set range
    steps_up=floor((x_range-dist_deepest_pt)/inc(1));
    steps_down=floor(dist_deepest_pt/inc(1));
    x_domain=[dist_deepest_pt-steps_down*inc(1) dist_deepest_pt+steps_up*inc(1)];
    range=[x_domain 0 floor(y_range/inc(2))*inc(2)];
    srange=[x_domain min(xyz(:,3,3)) ...
        min(xyz(:,3,3))+floor((max(xyz(:,3,3))-min(xyz(:,3,3)))/sinc(2))*sinc(2)];
    
    %identify what's going into to ppzgrid
    the_info=xyz(:,:,1);
    sal_info=xyz(:,:,2);
    sig_info=xyz(:,:,3);
    
    %functions that create structures for each parameter  containing
    %gridded X, Y, and Z as well CPT and levels
    sig=grid_grids(sig_info,inc,t_sig,range,filename,2);
    the=grid_grids(the_info,inc,t_pvar,range,filename);
    sal=grid_grids(sal_info,inc,t_pvar,range,filename);
    
    %%%% Ben's density space interpolation bit
    
    %change input into ppzgrid so y is now sigma
    the_dinf = the_info; sal_dinf = sal_info;
    the_dinf(:,2) = sig_info(:,3);
    sal_dinf(:,2) = sig_info(:,3);
    
    %grid in density space
    the_s=grid_grids(the_dinf,sinc,t_pvar,srange);
    sal_s=grid_grids(sal_dinf,sinc,t_pvar,srange);
    
%     %plot in density space
%     plot_section('the',the_s.X,the_s.Y,the_s.Z,the_dinf)
%     print('-depsc' ,'-r200',['dens_' filename(14:23)]);
    
    %convert back into depth space
    x = sig.X(1,:);
    THE_info=[]; SAL_info=[];
    
    for n=1:length(x)
        
        sigvec = sig.Z(:,n);
        y = sig.Y(:,1);
        yy = y;
        
        %get rid of naned values in sigvec
        y = y(~isnan(sigvec));
        sigvec = sigvec(~isnan(sigvec));
        
        %make sure that sigvec is monotonically increasing
        dids = NaN; 
        while ~isempty(dids)
            ds = diff(sigvec);
            dids = find(ds <= 0);
            if ~isempty(dids)
                sigvec(dids+1) = [];
                y(dids+1) = [];
            end
        end
        
        if length(sigvec) >= 2
            
            %%%% theta 
            %remove nans
            thevec = the_s.Z(:,n); sigvec2 = the_s.Y(:,n);
            ids = ~isnan(thevec) & ~isnan(sigvec2);
            thevec = thevec(ids); sigvec2 = the_s.Y(ids);
            
            %make sure theta is monotonically increasing
            [sigvec2,c]=unique(sigvec2);
            thevec = thevec(c);
            
            %interpolate
            Dt = interp1(sigvec,y,sigvec2);
            tids = ~isnan(Dt);
            ttf = sum(tids*1) >= 2;
            
            %%%% salinity
            %remove nans
            salvec = sal_s.Z(:,n); sigvec2 = sal_s.Y(:,n);
            ids = ~isnan(salvec) & ~isnan(sigvec2);
            salvec = salvec(ids); sigvec2 = sal_s.Y(ids);
            
            %make sure salinity is monotonically increasing 
            [sigvec2,c]=unique(sigvec2);
            salvec = salvec(c);
            
            %interpolate
            Ds = interp1(sigvec,y,sigvec2);
            sids = ~isnan(Ds);
            stf = sum(sids*1) >= 2;
            
            if ttf & stf
                %theta 
                T = interp1(Dt(tids),thevec(tids),yy);
                ids = ~isnan(T);

                %recreate ppzgrid input
                xyz_sta = [repmat(x(n),sum(ids*1),1) yy(ids) T(ids)];
                THE_info = [THE_info; xyz_sta];
                clear xyz_sta;
                
                %salinity
                S = interp1(Ds(sids),salvec(sids),yy);
                ids = ~isnan(S);

                %recreate ppzgrid input
                xyz_sta = [repmat(x(n),sum(ids*1),1) yy(ids) S(ids)];
                SAL_info = [SAL_info; xyz_sta];
                clear xyz_sta; 
            end
              
        end
    end
    
    %delete interpolated data near original data
    x_info = unique(the_info(:,1,1));
    stagrdx = nearest_neighbor(x,x_info);
    Tids = ismember(THE_info(:,1,1),stagrdx);
    
    THE_info(Tids,:,:)=[];
    SAL_info(Tids,:,:)=[];
    
    %add in original data
    THE_info = [THE_info; the_info];
    SAL_info = [SAL_info; sal_info];
    
    %regrid again in depth space
    THE=grid_grids(THE_info,inc,t_pvar,range,filename);
    SAL=grid_grids(SAL_info,inc,t_pvar,range,filename);
    
%     %plot in depth space
%     plot_section('the',THE.X,THE.Y,THE.Z,THE_info);
%     plot(regdist,regbat,'m');
%     print('-depsc' ,'-r200',['depth_' filename(14:23)]);
    
    %combine density and depth space
    thegrd = graft_grids(THE.Z,the.Z,sig.Z,27.5,27.7);
    salgrd = graft_grids(SAL.Z,sal.Z,sig.Z,27.5,27.7);

    %return data in organized structure  
    new_grids.X=sig.X;
    new_grids.Y=sig.Y;
    new_grids.the=thegrd;
    new_grids.sal=salgrd;
    new_grids.sig=sig.Z;
    
    new_grids.arg.the=the.arg;
    new_grids.arg.sal=sal.arg;
    new_grids.arg.sig=sig.arg;
    
%     close all

end