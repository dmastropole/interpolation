%This script combines the end member distributions and indices into two
%datastructures

close all;
clear all;

%------------------ Get Distributions ------------------------------------%

%Arctic-origin water
load('/Users/Dana/Documents/MATLAB/Latrabjarg/EndMembers/data_deep.mat');
names{1} = 'deep';

sal=[]; the=[];
for j=1:length(data)
    sal = [sal; data(j).sal(data(j).em)];
    the = [the; data(j).the(data(j).em)];
end
D.deep.sal = sal;
D.deep.the = the;

%PSW, rAtW, IW
%get filenames of data structures
matfiles = dir('/Users/Dana/Documents/MATLAB/Latrabjarg/EndMemberGUI/data_*.mat');
for i=1:length(matfiles)
    slash = strfind(matfiles(i).name,'_');
    names{i+1} = matfiles(i).name(slash+1:end-4);
    
    %load the data
    load(['/Users/Dana/Documents/MATLAB/Latrabjarg/EndMemberGUI/data_' names{i+1} '.mat']);
    
    %find all of the end member T/S data
    sal=[]; the=[];
    for j=1:length(data)
        sal = [sal; data(j).sal(data(j).em)];
        the = [the; data(j).the(data(j).em)];
    end
    
    eval(['D.' names{i+1} '.sal=sal;']);
    eval(['D.' names{i+1} '.the=the;']);
    
end


%save distributions
save('EM_distributions','D');

%------------------ Get indices ------------------------------------------%

for i=1:length(names)
    load(['/Users/Dana/Documents/MATLAB/Latrabjarg/EndMembers/' names{i} '_indices.mat']);
    eval(['I.' names{i} '.sal = indices(1);']);
    eval(['I.' names{i} '.the = indices(2);']);
end

save('EM_indices','I');