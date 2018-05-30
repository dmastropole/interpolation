%This script determines the end member contribution to the 1) Atlantic
%origin water core and 2) the recirculated Irminger Water core

close all;
clear all;

screen_size = get(0, 'ScreenSize');

load('/Users/Dana/Documents/MATLAB/Latrabjarg/Bolus/bolus_cont.mat');
load mixing_contours;

load('/Users/Dana/Documents/MATLAB/Latrabjarg/ChooseGrids/grids.mat');
orig_grids = grids;
load grids;
load Uncertainties_std;

probs = {'prob1','prob2','prob3','prob4'};
names = {'Arctic Origin Water','Polar Surface Water','Altantic Origin Water',...
    'Irminger Water'};

%initialize structures and fields
for j=1:length(probs)
    eval(['raw.' probs{j} '=[];']);
    eval(['riw.' probs{j} '=[];']);
    eval(['psw.' probs{j} '=[];']);
    eval(['gsw.' probs{j} '=[];']);
    eval(['iw.' probs{j} '=[];']);
end

%distance of shelf
x_shelf = 70;

%cutoff temperature for recirculated irminger water
riw_temp = 3;

for i=1:length(grids)
    
    %ignore extrapolated data
    if ~isempty(domain_cont{i,1})
        IN = inpolygon(grids(i).X,grids(i).Y,domain_cont{i,1},domain_cont{i,2});
        
        %if there is dsow in section
        Dids = orig_grids(i).sig >= 27.8;
        if sum(sum(Dids)) > 0 & ~ismember(i,toss_occs)
            
            %find the values of core of return atlantic water
            for j=1:length(probs)
                eval([probs{j} '=grids(' mat2str(i) ').' probs{j} '(Dids);']);
            end
            
            if max(prob3) > 0
                id_max = prob3 == max(prob3);
                
                %exclude irminger water from calculation
                %             if nanmean(prob4(id_max)) <= 0
                for j=1:length(probs)
                    eval(['raw(' mat2str(i) ').' probs{j} '=nanmean(' probs{j} '(id_max));']);
                end
                %             end
                
            end
            
            %find values of recirculated irminger water and polar surface water
            for j=1:length(probs)
                
                eval(['IDS = ~Dids & grids(' mat2str(i) ').X < x_shelf;']);
                eval([probs{j} '=grids(' mat2str(i) ').' probs{j} '(IDS);']);
            end
            
            temp = orig_grids(i).the(IDS);
            
            if max(prob4) > 0
                id_riw = temp >= riw_temp;
                
                %exclude atlantic origin water from calculation
                %             if nanmean(prob3(id_max)) <= 0
                for j=1:length(probs)
                    eval(['riw(' mat2str(i) ').' probs{j} '=nanmean(' probs{j} '(id_riw));']);
                end
                %             end
            end
            
            %find max polar surface water values of Greenland shelf
            for j=1:length(probs)
                
                eval(['IDS = grids(' mat2str(i) ').X < x_shelf;']);
                eval([probs{j} '=grids(' mat2str(i) ').' probs{j} '(IDS);']);
            end
            
            if max(prob2) > 0 
                id_max = prob2 == max(prob2);
                
                for j=1:length(probs)
                    eval(['psw(' mat2str(i) ').' probs{j} '=nanmean(' probs{j} '(id_max));']);
                end
            end
            
            %find max arctic origin water values of Greenland shelf DSOW
            for j=1:length(probs)
                
                eval(['IDS = Dids & grids(' mat2str(i) ').X < x_shelf;']);
                eval([probs{j} '=grids(' mat2str(i) ').' probs{j} '(IDS);']);
            end
            
            if max(prob1) > 0
                id_max = prob1 == max(prob1);
                
                for j=1:length(probs)
                    eval(['gsw(' mat2str(i) ').' probs{j} '=nanmean(' probs{j} '(id_max));']);
                end
            end
            
            %find irminger current water entraned on eastern side of trough
            for j=1:length(probs)
                
                eval(['IDS = Dids & grids(' mat2str(i) ').X >= 140;']);
                eval([probs{j} '=grids(' mat2str(i) ').' probs{j} '(IDS);']);
            end
            
                
            for j=1:length(probs)
                eval(['iw(' mat2str(i) ').' probs{j} '=nanmean(' probs{j} ');']);
            end
            
        end %look for DSOW
    end %look for data
end

%create histograms of percentages and find means
types = {'raw','riw','psw','gsw','iw'};
types_std = {'rAtW_std','iw_std','psw_std','deep_std','iw_std'};

for i=1:length(types)
    
    figure('Position',screen_size);
    
    for j=1:length(probs)
        
        subplot(2,2,j);
        eval(['vec = [' types{i} '.' probs{j} '];']);
        [N,y] = hist(vec);
        b = bar(y,N,'hist');
        hold on;
        ave =  nanmean(vec);
        sterr = nanstd(vec)./sqrt(length(vec));
        err = sterr + eval(types_std{i});
        
%         [ave, stdev] = gbbootstrap(vec,200,'mean');
        plot([ave ave],[0 max(N)],'r','linewidth',3);
        title([names{j} ' , Mean: ' mat2str(ave) ', err: ' mat2str(err)]);
        
    end
    
    suplabel(types{i},'t');
    export_fig('-pdf','-transparent',['hist_' types{i} '_mean']);
end