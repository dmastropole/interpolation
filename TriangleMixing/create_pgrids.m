function new_grids=create_pgrids(pxyz,xyz,resolution,t_pvar,t_sig,ranges,...
    filename,LatBat,type)

    %make sure that sigma values are real
    xyz=real(xyz);
    
    %make sure that pxyz and xyz have the same dis/depth
    idp = ismember(pxyz(:,1:2,1),xyz(:,1:2,1),'rows');
    idx = ismember(xyz(:,1:2,1),pxyz(:,1:2,1),'rows');
    pxyz = pxyz(idp,:,:); xyz = xyz(idx,:,:);
    
    %get rid of spaces in string "type"
    type = strtrim(type);
    
    x_range=ranges(1); y_range=ranges(2);
    [regdist,u]=unique_old(LatBat.regdist); regbat=LatBat.regbat(u);
    
    %determine number of fields (or watermasses)
    n = size(pxyz,3);

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
    
    %identify what's going into to ppzgrid and create gridded structures
    for i=1:n
        
        %depth space
        info = pxyz(:,:,i);
        eval(['prob' mat2str(i) '=grid_grids(info,inc,t_pvar,range,filename);']);
        
        %if hybrid grid
        if strcmp(type,'mix')
            sig_info=real(xyz(:,:,3));
            sig=grid_grids(sig_info,inc,t_sig,range,filename,2);
            
            %change depth input to density
            dinf = info; 
            dinf(:,2) = sig_info(:,3);
            
            %grid in density space
            prob_s=grid_grids(dinf,sinc,t_pvar,srange);
            
            %convert back into depth space
            x = sig.X(1,:); INFO =[];
            
            for m = 1:length(x)
                sigvec = sig.Z(:,m);
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
                    %remove nans
                    pvec = prob_s.Z(:,m); sigvec2 = prob_s.Y(:,m);
                    ids = ~isnan(pvec) & ~isnan(sigvec2);
                    pvec = pvec(ids); sigvec2 = prob_s.Y(ids);

                    %make sure theta is monotonically increasing
                    [sigvec2,c]=unique(sigvec2);
                    pvec = pvec(c);

                    %interpolate
                    Dp = interp1(sigvec,y,sigvec2);
                    pids = ~isnan(Dp);
                    tf = sum(pids*1) >= 2;
                    
                    if tf
                        P = interp1(Dp(pids),pvec(pids),yy);
                        ids = ~isnan(P);

                        %recreate ppzgrid input
                        xyz_sta = [repmat(x(n),sum(ids*1),1) yy(ids) P(ids)];
                        INFO = [INFO; xyz_sta];
                        clear xyz_sta;
                    end %if tf
                end %if length(sigvec) >= 2
        
            end %for m=1:length(x)
            
            %delete interpolated data near original data
            x_info = unique(info(:,1,1));
            stagrdx = nearest_neighbor(x,x_info);
            Pids = ismember(INFO(:,1,1),stagrdx);

            INFO(Pids,:,:)=[];

            %add in original data
            INFO = [INFO; info];

            %regrid again in depth space
            PROB=grid_grids(INFO,inc,t_pvar,range,filename);
            disp('**** hybrid gridding ****'); 

            %combine density and depth space
            eval(['prob' mat2str(i) '.Z=graft_grids(PROB.Z,prob' mat2str(i) ...
                '.Z,sig.Z,27.5,27.7);']);
            
        end %if strcmp(type,'mix')
    end
    
    %organize fields of structure
    new_grids.X=prob1.X;
    new_grids.Y=prob1.Y;
    
    %add in gridded probability fields
    for i=1:n
        eval(['new_grids.prob' mat2str(i) '=prob' mat2str(i) '.Z;']);
    end

end