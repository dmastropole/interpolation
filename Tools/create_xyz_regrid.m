function xyz_regrid=create_xyz_regrid(grids, i)

xyz_regrid=[];
    for n=1:length(grids(i).X(1,:))
        x=grids(i).X(1,:);
        y=grids(i).Y(:,1);
        
        ids=~isnan(grids(i).the(:,n));
        
        if ~isempty(find(ids==1))
            xyz_gridpt(:,1,1)=repmat(x(n),1,length(find(ids==1)));
            xyz_gridpt(:,2,1)=y(ids);
            xyz_gridpt(:,3,1)=grids(i).the(ids,n);

            xyz_gridpt(:,1,2)=repmat(x(n),1,length(find(ids==1)));
            xyz_gridpt(:,2,2)=y(ids);
            xyz_gridpt(:,3,2)=grids(i).sal(ids,n);

            xyz_gridpt(:,1,3)=repmat(x(n),1,length(find(ids==1)));
            xyz_gridpt(:,2,3)=y(ids);            
            xyz_gridpt(:,3,3)=grids(i).sig(ids,n);

            xyz_regrid=[xyz_regrid; xyz_gridpt];
            clear xyz_gridpt ids;
        end
    end

end