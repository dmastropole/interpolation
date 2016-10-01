%this code adds 50 m of water to the bottom of each cast in order to improve
%interpolation
close all;
clear all;

load XYZ_batproj
% load('/Users/Dana/Documents/MATLAB/Latrabjarg/Bathymetry/LatBat.mat');
% dpth = 50; %changed from 100
dsig = 0.0005;

for i=1:length(XYZ)
    
    xyz=XYZ(i).xyz;
    [dists,c]=unique_old(xyz(:,1,1));
    depths=xyz(c,2,1);
    sigs=xyz(c,3,3);
    
    
    for j=1:length(dists)
        if (i==14 && j==6) || (i==20 && j==7) || (i==25 && j==9) || (i==28 && j==1)...
                || (i==30 && j==5) || (i==30 && j==6)...
                || (i==46 && j==3) || (i==46 && j==4) || (i==46 && j==5) ... 
                || (i==49 && j==7) || (i==52 && j==4) || (i==52 && j==5) ...
                || (i==52 && j==6) || (i==56 && j==4) || (i==56 && j==5) ...
                || (i==61 && j==21) || (i==61 && j==22) || (i==61 && j==23) ...
                || (i==64 && j==3) ...
                || (i==68 && j==5) || (i==68 && j==4) || (i==70 && j==4)...
                || (i==71 && j==5) || (i==71 && j==6) || (i==72 && j==2) || (i==72 && j==6) ...
                || (i==78 && j==4) || (i==78 && j==5) ...
                || (i==81 && j==1) || (i==85 && j==1) || (i==88 && j==6) ...
                || (i==88 && j==5) || (i==100 && j==4) || (i==102 && j==6)
            dpth = 100;
        else
            dpth = 50;
        end
            
        if (i~=37 && j~=3) ||  (i~=37 && j~=4) || (i~=39 && j~=3) || ...
                (i~=50 && j~=4) || (i~=91 && j~=2)
        dpthvec = 1:dpth;
        dpthvec = dpthvec(:);
        new_depths=depths(j)+dpthvec;
        new_sigs=sigs(j)+(dpthvec.*dsig);
        
        %creating the chunk of fake data
        data_slice=xyz(c(j),:,:);
        data_chunk=repmat(data_slice,dpth,1);
        data_chunk(:,2,:)=repmat(new_depths,[1 1 3]);
        data_chunk(:,3,3)=new_sigs;
        
        if c(j) == length(xyz)
            xyz = [xyz; data_chunk];
        else
            xyz = [xyz(1:c(j),:,:); data_chunk; xyz(c(j)+1:end,:,:)];
        end
        
        [dists,c]=unique_old(xyz(:,1,1));
        end
    end
    
    XYZ(i).xyz=xyz;
end

save('XYZ_mod','XYZ');