%This script calculates the error the percent calculation due to end member
%variability 

close all;
clear all;

%load "true" cast data
load XYZ_pcents

%------------- Calculate all combos of end member indices ----------------%

%(sal,the) std operation combos
sign = {'--','-+','++','+-'};

%get filenames of indices 
matfiles = dir('/Users/Dana/Documents/MATLAB/Latrabjarg/EndMembers/*_indices.mat');
for i=1:length(matfiles)
    slash = strfind(matfiles(i).name,'_');
    names{i} = matfiles(i).name(1:slash-1);
end

%initialize index vectors
for i=1:length(names)
    eval([names{i} '_ind = NaN(4^4,2);']);
end

%looping parameters
for j=1:length(names)
    n{j} = names{j}(1);
end

k=1;
%irminger water
for i=1:length(sign)
    
    %atlantic-origin water
    for r=1:length(sign)
        
        %polar surface water
        for p=1:length(sign)
            
            %arctic-origin water
            for d=1:length(sign)
                
                disp(k)
                for j=1:length(names)

                    load(['/Users/Dana/Documents/MATLAB/Latrabjarg/EndMembers/' ...
                        matfiles(j).name]);
                    
                    %sal
                    eval([names{j} '_ind(' mat2str(k) ',1)=indices(1)' sign{eval(n{j})}(1)...
                        'stds(1);']);
                    
                    %the
                    eval([names{j} '_ind(' mat2str(k) ',2)=indices(2)' sign{eval(n{j})}(2)...
                        'stds(2);']);
                end
                
                k=k+1;
            end
        end
    end
end
