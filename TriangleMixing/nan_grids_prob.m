%this script nans out the regridded mat file
%gridded_occupations_finalregrid

close all;
clear all;

load /Users/Dana/Documents/MATLAB/Latrabjarg/ChooseGrids/grids.mat
orig_grids = grids;
load XYZ_pcents_extrap

load grids_regrid.mat;
load /Users/Dana/Documents/MATLAB/Latrabjarg/Bathymetry/LatBat.mat
[regdist,c]=unique(regdist);
regbat=regbat(c);

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

    
for i=1:length(grids)
    
    if ~ismember(i,toss_occs)
    
    x=grids(i).X(1,:);
    y=grids(i).Y(:,1);
    
    %cut off edges for certain sections
    if ismember(i,[3 5 8 12 14 18 21 23 26 30 31 35 37 43 45 47 52 54 55 ...
            59 60 63 64 69 71 72 78 79 82 86 87 88 93 95 96 97 98 102 105 ...
            107 106])
        k= x < orig_grids(i).stagrdx(1);

        for n=1:length(pnames)
            eval(['grids(' mat2str(i) ').' pnames{n} '(:,' mat2str(k) ')=NaN;']);
        end
    end
    if ismember(i,[8 12 40 43 79 80])
        p= x > orig_grids(i).stagrdx(end);
     
        for n=1:length(pnames)
            eval(['grids(' mat2str(i) ').' pnames{n} '(:,' mat2str(p) ')=NaN;']);
        end
    end

    %nan below selected casts
    if ismember(i,[4 5 6 76])
        m = find(y > 510);
        
        for n=1:length(pnames)
            eval(['grids(' mat2str(i) ').' pnames{n} '(' mat2str(m) ',:)=NaN;']);
        end
    end   
        
    %nan out surface data
    if i==41
        for n=1:length(pnames)
            eval(['grids(' mat2str(i) ').' pnames{n} '(1:4,:)=NaN;']);
        end
    end
    
    end
end %grids

%Save the "grids" structure
save('grids','grids','toss_occs');

for i=1:length(grids)
    
    if ~ismember(i,toss_occs)
    
        %create patch for data
    [x,y,xcont,ycont] = create_patch(XYZ(i));
    [xcells,ycells]=polysplit(x,y);
    
    domain_cont{i,1}=xcont; domain_cont{i,2}=ycont;
    domain_patch{i,1}=x; domain_patch{i,2}=y;
    
    %get rid of interpolated bits
        if ~isempty(x)
            IN = inpolygon(grids(i).X,grids(i).Y,x,y);
            grids(i).prob1(~IN) = NaN;
            grids(i).prob2(~IN) = NaN;
            grids(i).prob3(~IN) = NaN;
            grids(i).prob4(~IN) = NaN;
        end
    
    
        %nan out data below bottom 
    y_bat=interp1(regdist, regbat, grids(i).X(1,:));
    for j=1:size(grids(i).X,2)
        nids=find(grids(i).Y(:,j)>y_bat(j));
        for m=1:length(pnames)
            eval(['grids(' mat2str(i) ').' pnames{m} '(' mat2str(nids) ',' ...
                mat2str(j) ')=NaN;']);
        end
        
        clear nids;
    end
    end
end

save('mixing_contours','domain_cont');
save('mixing_patches','domain_patch');


%Save the "grids" structure
save('naned_grids', 'grids','toss_occs');