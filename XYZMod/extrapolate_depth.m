load XYZ_batproj
% load('/Users/Dana/Documents/MATLAB/Latrabjarg/Bathymetry/LatBat.mat');

for i=1:length(XYZ)
    
    xyz=XYZ(i).xyz;
    [dists,c]=unique_old(xyz(:,1,1));
    depths=xyz(c,2,1);
    
    for j=1:length(dists)
        if (i==12 && j==1) || (i==12 && j==4) || (i==20 && j==7) ...
                || (i==25 && j==9) || (i==28 && j==1) || (i==48 && j==1) ... 
                || (i==50 && j==4) || (i==58 && j==4) ...
                || (i==56 && j==1) || (i==56 && j==4) || (i==56 && j==5) ... 
                || (i==57 && j==3) || (i==58 && j==4) || (i==72 && j==2) ...
                || (i==100 && j==4)
            dpth = 100;
        else
            dpth = 50;
        end
        
        if (i~=37 && j~=3) ||  (i~=37 && j~=4) || (i~=50 && j~=4)
        new_depths=depths(j)+[1:dpth]';
        
        %creating the chunk of fake data
        data_slice=xyz(c(j),:,:);
        data_chunk=repmat(data_slice,dpth,1);
        data_chunk(:,2,:)=repmat(new_depths,[1 1 3]);
        
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

save('XYZ_dpthextrap','XYZ');