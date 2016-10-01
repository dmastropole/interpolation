%this script nans out the regridded mat file
%gridded_occupations_finalregrid

close all;
clear all;

load grids_regrid.mat;
load /Users/Dana/Documents/MATLAB/Latrabjarg/Bathymetry/LatBat.mat
[regdist,c]=unique(regdist);
regbat=regbat(c);

for i=1:length(grids)
    
    x=grids(i).X(1,:);
    y=grids(i).Y(:,1);
    
    %cut off edges for certain sections
    if ismember(i,[3 5 8 12 14 18 21 23 26 30 31 35 37 43 45 47 52 54 55 ...
            59 60 63 64 69 71 72 78 79 82 86 87 88 93 95 96 97 98 102 105 ...
            107 106])
        k= x < grids(i).stagrdx(1);

        grids(i).the(:,k)=NaN;
        grids(i).sal(:,k)=NaN;
        grids(i).sig(:,k)=NaN;
    end
    if ismember(i,[8 12 40 43 79 80])
        p= x > grids(i).stagrdx(end);
     
        grids(i).the(:,p)=NaN;
        grids(i).sal(:,p)=NaN;
        grids(i).sig(:,p)=NaN;
    end

    %nan below selected casts
    if ismember(i,[4 5 6 76])
        m = find(y > 510);
        grids(i).the(m,:)=NaN;
        grids(i).sal(m,:)=NaN;
        grids(i).sig(m,:)=NaN;
    end   
    
%     %nan out data in middle of strait
%     if ismember(i, [4 5 9 76])
%         k = x < grids(i).stagrdx(3) & x > grids(i).stagrdx(2);
%         
%         grids(i).the(:,k) = NaN;
%         grids(i).sal(:,k) = NaN;
%         grids(i).sig(:,k) = NaN;
%     end
        
    %nan out surface data
    if i==41
        grids(i).the(1:4,:) = NaN;
        grids(i).sal(1:4,:) = NaN;
        grids(i).sig(1:4,:) = NaN;
    end
end

%Save the "grids" structure
save('grids', 'grids');

for i=1:length(grids)
        %nan out data below bottom 
    y_bat=interp1(regdist, regbat, grids(i).X(1,:));
    for j=1:length(x)
        nids=find(grids(i).Y(:,j)>y_bat(j));
        grids(i).the(nids,j)=NaN;
        grids(i).sal(nids,j)=NaN;
        grids(i).sig(nids,j)=NaN;
        clear nids;
    end
end

%Save the "grids" structure
save('naned_grids', 'grids');