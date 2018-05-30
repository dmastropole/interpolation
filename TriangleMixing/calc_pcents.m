%This script calculates mixing triangle percentages

close all;
clear all;

%%%% Form mixing traingle matrices  [ T1 T2 T3; S1 S2 S3; 1 1 1]

matfiles = dir('/Users/Dana/Documents/MATLAB/Latrabjarg/EndMembers/*_indices.mat');
for i=1:length(matfiles)
    slash = strfind(matfiles(i).name,'_');
    names{i} = matfiles(i).name(1:slash-1);
    load(['/Users/Dana/Documents/MATLAB/Latrabjarg/EndMembers/' matfiles(i).name]);
    eval(['sal_' names{i} '=indices(1);']);
    eval(['the_' names{i} '=indices(2);']);
end

%create EGC and NIJ mixing matrices
E = [the_deep the_psw the_rAtW; sal_deep sal_psw sal_rAtW; 1 1 1]; %EGC
N = [the_deep the_psw the_iw; sal_deep sal_psw sal_iw; 1 1 1]; %NIJ

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Calculate percentages
load('/Users/Dana/Documents/MATLAB/Latrabjarg/TriangleGUI/XYZ.mat');

%initalize pxyz field
for i=1:length(XYZ)
    xyz_size = size(XYZ(i).xyz);
    pxyz = nan(xyz_size(1), xyz_size(2), xyz_size(3)+1);
    
    pxyz(:,1:2,:) = repmat(XYZ(i).xyz(:,1:2,1),[1 1 4]);
    
    XYZ(i).pxyz = pxyz;
    
    XYZ(i).fields.watermasses = {'deep','psw','rAtW','iw'};
end


%cycle through each occupation
for i=1:length(XYZ)
    
    [dist,ixyz,idist] = unique(XYZ(i).xyz(:,1,1));
    
    IN_occ = [];
    
    %cycle through each station
    for j=1:length(dist)
        sta_ids = j == idist;
        
        %find datapoints that correspond to each of the mixing traingles
        Eids = sta_ids & XYZ(i).egc;
        Nids = sta_ids & XYZ(i).nij;
        
        %get points inside EGC mixing triangle
        IN = inpolygon(XYZ(i).xyz(sta_ids,3,2),XYZ(i).xyz(sta_ids,3,1),...
            [sal_deep sal_psw sal_rAtW sal_deep],[the_deep the_psw...
            the_rAtW the_deep]);
        
        %get points inside NIJ mixing triangle
        IN = inpolygon(XYZ(i).xyz(sta_ids,3,2),XYZ(i).xyz(sta_ids,3,1),...
            [sal_deep sal_psw sal_iw sal_deep],[the_deep the_psw the_iw ...
            the_deep]) | IN;
        
        %cycle through each datapoint in station
        for n=1:length(sta_ids)
            
            %create [T S 1] vector
            vec(1) = XYZ(i).xyz(n,3,1); %theta
            vec(2) = XYZ(i).xyz(n,3,2); %salinity
            vec(3) = 1;
            
            %EGC mixing triangle calculation
            if Eids(n)
                
                P = inv(E)*vec';
                
                XYZ(i).pxyz(n,3,1) = P(1); %deep water
                XYZ(i).pxyz(n,3,2) = P(2); %polar surface water
                XYZ(i).pxyz(n,3,3) = P(3); %return atlantic water
                XYZ(i).pxyz(n,3,4) = 0; %irmingur water
                
                
            %NIJ mixing triangle claculation
            elseif Nids(n)
                
                P = inv(N)*vec';
                
                XYZ(i).pxyz(n,3,1) = P(1); %deep water
                XYZ(i).pxyz(n,3,2) = P(2); %polar surface water
                XYZ(i).pxyz(n,3,3) = 0; %return atlantic water
                XYZ(i).pxyz(n,3,4) = P(3); %irmingur water
                
                
            else
                if sta_ids(n)
                    disp('ERROR: data in station not assigned to triangle!')
                end
            end
            
        end
        
        %get rid of points outside of triangles
        IN_occ = [IN_occ; IN];
        
    end
    XYZ(i).pxyz = XYZ(i).pxyz(logical(IN_occ),:,:);
    if sum(IN_occ) == 0
        disp(['CALCULATION BREAK! OCCUPATION: ' mat2str(i)]);
    end
    
end


%find occupations where there are less than 2 casts worth of pcent
%information
k=1;
for i=1:length(XYZ)
    
    flag = false;
    [dists,ixyz,idists] = unique(XYZ(i).pxyz(:,1,1));
    
    %throw out occupations with less than 5 datapoints per station
    for j=1:length(dists)
        staids = idists == j;
        if sum(staids) < 5
            flag = true;
        end
    end
    
    %thow out occupations with less than two stations
    if length(dists) < 2
        flag = true;
    end
    
    if flag
        toss_occs(k) = i;
        k=k+1;
    end
end


save('XYZ_pcents','XYZ','toss_occs');