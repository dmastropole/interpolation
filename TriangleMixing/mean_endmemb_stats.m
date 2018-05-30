%This script computes the statistics on endmember contribution to DSOW and
%boluses 

close all;
clear all;

screen_size = get(0, 'ScreenSize');

load('/Users/Dana/Documents/MATLAB/Latrabjarg/Bolus/bolus_cont.mat');
load mixing_contours;

load('/Users/Dana/Documents/MATLAB/Latrabjarg/ChooseGrids/grids.mat');
orig_grids = grids;
load grids;
load Uncertainties_std

probs = {'prob1','prob2','prob3','prob4'};
names = {'Arctic Origin Water','Polar Surface Water','Altantic Origin Water',...
    'Irminger Water'};
names_std = {'deep_std','psw_std','rAtW_std','iw_std'};

%initialize structures and fields
for j=1:length(probs)
    eval(['bolus.' probs{j} '=[];']);
    eval(['nbdsow.' probs{j} '=[];']);
end

%initalize cross sectional area and density difference between bolus and
%overflow
drho = [];
xarea = [];

for i=1:length(grids)
    
    %ignore extrapolated data
    if ~isempty(domain_cont{i,1})
    IN = inpolygon(grids(i).X,grids(i).Y,domain_cont{i,1},domain_cont{i,2});
    
    %if there is dsow in section
    Dids = orig_grids(i).sig >= 27.8;
    if sum(sum(Dids)) > 0
        
        %if there is a bolus in that occupation
        if ~isempty(cont{i})
            Bids = inpolygon(grids(i).X,grids(i).Y,cont{i}(:,1),cont{i}(:,2));
            
            %cycle through end members
            for j=1:length(probs)
                eval(['nbdsow(' mat2str(i) ').' probs{j} '= nanmean(grids(' ...
                    mat2str(i) ').' probs{j} '(Dids & ~Bids));']);
                eval(['bolus(' mat2str(i) ').' probs{j} '= nanmean(grids(' ...
                    mat2str(i) ').' probs{j} '(Bids));']);
                disp(i)
            end
            
            %compute cross sectional area
            xarea = [xarea; polyarea(cont{i}(:,1), cont{i}(:,2))/1000];
            
            %compute density difference
            drho = [drho; nanmean(orig_grids(i).sig(Bids)) - nanmean(orig_grids(i).sig(Dids & ~Bids))];
                   
        else
            
            %cycle through end members
            for j=1:length(probs)
                eval(['nbdsow(' mat2str(i) ').' probs{j} '= nanmean(grids(' ...
                    mat2str(i) ').' probs{j} '(Dids));']);
            end
            
        end %look for bolus
        
        for j=1:length(probs)
            eval(['dsow(' mat2str(i) ').' probs{j} '= nanmean(grids(' ...
                    mat2str(i) ').' probs{j} '(Dids));']);
        end
                
    end %look for DSOW
    end %look for data
end


%add in last occupation for missing bolus occupation
for j=1:length(probs)
    eval(['bolus(111).' probs{j} '= [];']);
end


%create histograms of percentages and find means
types = {'nbdsow','bolus','dsow'};
for i=1:length(types)
    
    figure('Position',screen_size);
    
    for j=1:length(probs)
        
        subplot(2,2,j);
        eval(['vec = [' types{i} '.' probs{j} '];']);
%         [ave, stdev, means] = gbbootstrap(vec,2000,'mean');
        [N,y] = hist(vec);
        b = bar(y,N,'hist');
        ave = nanmean(vec);
        err = nanstd(vec)./sqrt(length(vec)) + eval(names_std{j});
        hold on;
        plot([ave ave],[0 max(N)],'r','linewidth',3);
        title([names{j} ' , Mean: ' mat2str(ave) ', err: ' ...
            mat2str(err)]);
        
    end
    
    suplabel(types{i},'t');
    export_fig('-pdf','-transparent',['hist_' types{i} '_mean']);
end

%cross sectional area
figure('Position',screen_size);
vec = xarea;
% [ave, stdev, means] = gbbootstrap(vec,2000,'mean');
[N,y] = hist(vec);
b = bar(y,N,'hist');
hold on;
ave = nanmean(vec);
sterr = nanstd(vec)./sqrt(length(vec));
plot([ave ave],[0 max(N)],'r','linewidth',3);
title(['XArea Bolus , Mean: ' mat2str(ave) ', err: ' ...
    mat2str(sterr)]);
export_fig('-pdf','-transparent','hist_xarea_mean');

%rho difference
figure('Position',screen_size);
vec = drho;
% [ave, stdev, means] = gbbootstrap(vec,2000,'mean');
[N,y] = hist(vec);
b = bar(y,N,'hist');
hold on;
ave = nanmean(vec);
sterr = nanstd(vec)./sqrt(length(vec));
plot([ave ave],[0 max(N)],'r','linewidth',3);
title(['Density difference , Mean: ' mat2str(ave) ', err: ' ...
    mat2str(sterr)]);
export_fig('-pdf','-transparent','hist_drho_mean');

save('bolus_dsow_pcents','bolus','dsow','nbdsow');
