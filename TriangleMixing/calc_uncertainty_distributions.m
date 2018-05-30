%This script calculates the percent end member uncertinty from
%distributions

close all;
clear all;

load EM_distributions
load EM_indices
load XYZ_pcents

names = {'deep','psw','rAtW','iw'};

%----------------------- Find N random combinations ----------------------%
%set number of times calculation is done
NN = 500;

for i=1:length(names)
    S = eval(['D.' names{i}]);
    R = randi(length(S.sal),[NN,1]);
    
    eval(['D.' names{i} '.pairs = [S.sal(R) S.the(R)];']);
end
%----------------------- Find main mixing triangles ----------------------%

E = [I.deep.the I.psw.the I.rAtW.the; I.deep.sal I.psw.sal I.rAtW.sal; 1 1 1]; %EGC
N = [I.deep.the I.psw.the I.iw.the; I.deep.sal I.psw.sal I.iw.sal; 1 1 1]; %NIJ

%----------------------- Find N Mixing triangles -------------------------%
for i=1:NN
    
    for j=1:length(names)
        eval(['sal_' names{j} '=D.' names{j} '.pairs(' mat2str(i) ',1);']);
        eval(['the_' names{j} '=D.' names{j} '.pairs(' mat2str(i) ',2);']);
    end
    
    %create EGC and NIJ mixing matrices
    M(i).E = [the_deep the_psw the_rAtW; sal_deep sal_psw sal_rAtW; 1 1 1]; %EGC
    M(i).N = [the_deep the_psw the_iw; sal_deep sal_psw sal_iw; 1 1 1]; %NIJ
    
end

%----------------------- Calculate residuals -----------------------------%
%change order of names
names = {'deep','psw','iw','rAtW'};

DEEP = []; PSW = []; IW = []; RATW = [];

%cycle through number of combinations
for p = 1:NN
    disp(p)
    
    for j=1:length(names)
        if strcmp(names{j},'rAtW')
            eval(['sal_' names{j} '=M(p).E(2,3);']);
            eval(['the_' names{j} '=M(p).E(1,3);']);
        else
            eval(['sal_' names{j} '=M(p).N(2,j);']);
            eval(['the_' names{j} '=M(p).N(1,j);']);
        end
    end
    
    %cycle through each occupation
    for i=1:length(XYZ)
        
        [dist,ixyz,idist] = unique(XYZ(i).xyz(:,1,1));
        
        IN_occ = [];
        
        %initialize each occupation
        for j=1:length(names)
            eval([names{j} '=[];']);
        end
        
        %cycle through each station
        for j=1:length(dist)
            sta_ids = j == idist;
            
            %find datapoints that correspond to each of the mixing traingles
            Eids = sta_ids & XYZ(i).egc;
            Nids = sta_ids & XYZ(i).nij;
            
            %get points inside EGC mixing triangle
            IN = inpolygon(XYZ(i).xyz(sta_ids,3,2),XYZ(i).xyz(sta_ids,3,1),...
                [I.deep.sal I.psw.sal I.rAtW.sal I.deep.sal],[I.deep.the I.psw.the...
                I.rAtW.the I.deep.the]);
            
            %get points inside NIJ mixing triangle
            IN = inpolygon(XYZ(i).xyz(sta_ids,3,2),XYZ(i).xyz(sta_ids,3,1),...
                [I.deep.sal I.psw.sal I.iw.sal I.deep.sal],[I.deep.the I.psw.the I.iw.the ...
                I.deep.the]) & IN;
            
            %get points inside EGC mixing triangle
            IN = inpolygon(XYZ(i).xyz(sta_ids,3,2),XYZ(i).xyz(sta_ids,3,1),...
                [sal_deep sal_psw sal_rAtW sal_deep],[the_deep the_psw...
                the_rAtW the_deep]) & IN;
            
            %get points inside NIJ mixing triangle
            IN = inpolygon(XYZ(i).xyz(sta_ids,3,2),XYZ(i).xyz(sta_ids,3,1),...
                [sal_deep sal_psw sal_iw sal_deep],[the_deep the_psw the_iw ...
                the_deep]) & IN;
            
            %cycle through each datapoint in station
            for n=1:length(sta_ids)
                
                %create [T S 1] vector
                vec(1) = XYZ(i).xyz(n,3,1); %theta
                vec(2) = XYZ(i).xyz(n,3,2); %salinity
                vec(3) = 1;
                
                %EGC mixing triangle calculation
                if Eids(n)
                    
                    P = inv(E)*vec';
                    B = inv(M(p).E)*vec';
                    
                    deep = [deep; B(1) - P(1)]; %deep water
                    psw = [psw; B(2) - P(2)]; %polar surface water
                    rAtW = [rAtW; B(3) - P(3)]; %return atlantic water
                    iw = [iw; 0]; %irmingur water
                    
                    
                    %NIJ mixing triangle claculation
                elseif Nids(n)
                    
                    P = inv(N)*vec';
                    B = inv(M(p).N)*vec';
                    
                    deep = [deep; B(1) - P(1)]; %deep water
                    psw = [psw; B(2) - P(2)]; %polar surface water
                    rAtW = [rAtW; 0]; %return atlantic water
                    iw = [iw; B(3) - P(3)]; %irmingur water
                    
                    
                else
                    if sta_ids(n)
                        disp('ERROR: data in station not assigned to triangle!')
                    end
                end
                
            end
            
            %get rid of points outside of triangles
            IN_occ = [IN_occ; IN];
            
        end
        %         XYZ(i).pxyz = XYZ(i).pxyz(logical(IN_occ),:,:);
        DEEP = [DEEP; deep(logical(IN_occ))];
        PSW = [PSW; psw(logical(IN_occ))];
        IW = [IW; iw(logical(IN_occ))];
        RATW = [RATW; rAtW(logical(IN_occ))];
        
        if sum(IN_occ) == 0
            disp(['CALCULATION BREAK! OCCUPATION: ' mat2str(i)]);
        end
        
    end
end

save('Uncertainties','DEEP','PSW','IW','RATW');