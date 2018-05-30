%This script creates mean pcent sections

close all;
clear all;


screen_size = get(0, 'ScreenSize');
load('/Users/Dana/Documents/MATLAB/Latrabjarg/Bathymetry/LatBat.mat');
x_range=max(regdist);
y_range=750;

load grids;
load mixing_contours;
load mixing_patches;

load('/Users/Dana/Documents/MATLAB/Latrabjarg/Quadrants/bolus_pulse_occs.mat')

load mixing_contours;
probs = {'prob1','prob2','prob3','prob4'};

count = zeros(size(grids(2).X));

for i=1:length(grids)
    disp(i)
    
    if ~ismember(i,toss_occs)
        
        %get rid of interpolated data outside casts
        for j=1:length(probs)
            eval(['Z=grids(' mat2str(i) ').' probs{j} ';']);
            IN = inpolygon(grids(i).X,grids(i).Y,domain_cont{i,1},domain_cont{i,2});
            Z(~IN) = NaN;
            eval(['all_' probs{j} '(:,:,' mat2str(i) ')=Z;']);
        end
    else
        for j=1:length(probs)
            Z = NaN(size(count));
            eval(['all_' probs{j} '(:,:,' mat2str(i) ')=Z;']);
        end
        
    end
    
    %count how many datapoints in each section of the plot
    count_occ = ~isnan(Z);
    count = count+count_occ;
end

% plot data density
figure('Position',screen_size);
[c,h,colbh]=contourf_colorbar(grids(2).X,grids(2).Y,count,[0:5:110],'summer');
set(colbh,'fontsize',15);
set(gca,'YDir','Reverse','fontsize',15);
patch([regdist; x_range; 0; regdist(1)],[regbat; y_range; y_range; regbat(1)],...
    [.7 .7 .7]);
axis([0 x_range 0 y_range]);
title('Data Density','fontsize',15,'fontweight','bold');
export_fig('-pdf','-transparent','DataDensity');


clear grids;

for j=1:length(probs)
    grids.count = count;
    eval(['grids.mean.' probs{j} '=nanmean(all_' probs{j} ',3);']);
    eval(['grids.median.' probs{j} '=nanmedian(all_' probs{j} ',3);']);
    eval(['grids.bolus.' probs{j} '=nanmean(all_' probs{j} ...
        '(:,:,bolus_occs),3);']);
    eval(['grids.background.' probs{j} '=nanmean(all_' probs{j} ...
        '(:,:,background_occs),3);']);
    eval(['grids.anomaly.' probs{j} '= grids.bolus.' probs{j} ...
        '- grids.background.' probs{j} ';']);
    
    %plot histogram of percentages
    figure;
    N=hist(eval(['all_' probs{j} '(:)']),[-7.5 -1.5 -1.1:0.2:1.1 1.5 7.5]);
    hold on;
    plot([-1 -1],[0 max(N)],'r');
    plot([1 1],[0 max(N)],'r');
    hist(eval(['all_' probs{j} '(:)']),[-7.5 -1.5 -1.1:0.2:1.1 1.5 7.5]);
end


save('mean_median','grids');
save('all_pcents','all_prob1','all_prob2','all_prob3','all_prob4');