function [pxyz_regrid,xyz_regrid]=create_pxyz_regrid(grids,sig_grids)

%get names for each of the probabilities
names = fieldnames(grids);
k = 1;
for i=1:length(names)
    name = names{i};
    id = strfind(name, 'prob');
    
    if ~isempty(id)
        pnames{k} = name;
        k = k+1;
    end
    
end

pxyz_regrid=[];

%cycle through distance
for n=1:length(grids.X(1,:))
    x=grids.X(1,:);
    y=grids.Y(:,1);

    %get rid of nans
    ids=~isnan(grids.prob1(:,n));
    if ~isempty(find(ids==1))
        
        %add each column (percent) to ppzgrid input matrix
        for i=1:length(pnames)
            xyz_gridpt(:,1,i)=repmat(x(n),1,length(find(ids==1)));
            xyz_gridpt(:,2,i)=y(ids);
            eval(['xyz_gridpt(:,3,' mat2str(i) ')=grids.' pnames{i} ...
                '(' mat2str(ids) ',' mat2str(n) ');']);
        end
        pxyz_regrid=[pxyz_regrid; xyz_gridpt];
        clear xyz_gridpt ids;
    end
end

xyz_regrid=[];

if nargin > 1
    for n=1:length(sig_grids.X(1,:))
        x=sig_grids.X(1,:);
        y=sig_grids.Y(:,1);
        
        ids=~isnan(sig_grids.sig(:,n));
        
        if ~isempty(find(ids==1))

            xyz_gridpt(:,1,1)=repmat(x(n),1,length(find(ids==1)));
            xyz_gridpt(:,2,1)=y(ids);            
            xyz_gridpt(:,3,1)=sig_grids.sig(ids,n);

            xyz_regrid=[xyz_regrid; xyz_gridpt];
            clear xyz_gridpt ids;
        end
    end
    
    xyz_regrid = repmat(xyz_regrid,[1 1 3]);
end

end