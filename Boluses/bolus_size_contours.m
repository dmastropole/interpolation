%This script attempts to divide observations of the height of homog. blobs
%of water coming through Denmark Stait into boluses and non-boluses by
%looking at histograms of area filled in trough and height in trough

close all;
clear all;

screen_size = get(0, 'ScreenSize');

load bolus_cont_single.mat;
load dspoly.mat;
load('/Users/Dana/Documents/MATLAB/Latrabjarg/XYZMod/XYZ_batproj.mat');
load('/Users/Dana/Documents/MATLAB/Latrabjarg/Bathymetry/LatBat.mat');

%depth of latrabjarg
sill_depth = max(regbat);
depth_thresh = sill_depth - 150;

%figure out distances corresponding to width of trough
[xint,yint]=intersections(regdist,regbat,[regdist(1) regdist(end)],...
    [depth_thresh depth_thresh]);
[dsx,dsy]=polybool('&',dspoly(:,1),dspoly(:,2),[min(xint) min(xint) ...
    max(xint) max(xint) min(xint)],[700 max(yint) max(yint) 700 700]);
x_range = [min(dsx) max(dsx)];
b = polyarea(dsx,dsy);

%Plot size criterion
figure('Position',screen_size);
patch(dsx,dsy,[0 .5 0]);
hold on;
patch([regdist; max(regdist); 0; regdist(1)],[regbat; 750; 750; regbat(1)],...
    [.7 .7 .7]);
set(gca,'fontsize',15,'YDir','Reverse');
ylabel('Depth (m)','fontsize',17,'fontweight','bold');
xlabel('Distance (km)','fontsize',17,'fontweight','bold');
axis([0 max(regdist) 0 750]);
export_fig('-pdf','-transparent','BolusSizeCriterion');


%calculate areas in trhough and height of contours in trough
for i=1:length(cont)
    if isempty(cont{i})
        all_areas(i) = NaN;
        all_heights(i) = NaN;
    else
        [x,y] = polybool('&',cont{i}(:,1),cont{i}(:,2),dsx,dsy);
        a = polyarea(x,y);
        all_areas(i) = a/1000;
        all_pcents(i) = a/b;
        
        xids = cont{i}(:,1) <= x_range(2) & cont{i}(:,1) >= x_range(1);
        
        if sum(xids*1) > 0
            all_heights(i) = max(cont{i}(xids,2)) - min(cont{i}(xids,2));
        else
            all_heights(i) = NaN;
        end
    end
end

figure;

subplot(1,2,1);
hist(all_areas,[0:0.2:3]);
axis([-0.5 3.5 0 20]);
title('area');

subplot(1,2,2);
hist(all_heights,[0:20:400]);
axis([-10 410 0 15]);
title('thickness');

%save areas and heights of contours
save('contour_areas_thicknesses','all_areas','all_pcents','all_heights');


%display results
load bolus_occs_old;
all_occs = [1:i];

area_dspoly = polyarea(dsx,dsy)/1000;
disp(['Area of trough: ' mat2str(area_dspoly)]);

area_ids = all_areas > area_dspoly*0.65;
area_num = sum(area_ids*1);
area_occs = all_occs(area_ids);
area_mismatch = area_occs(~ismember(area_occs,bolus_occs));

disp(['Number satisfying area: ' mat2str(area_num)]);
disp(['Disagreeing occs: ' mat2str(length(area_mismatch)) ' dissagrements...']);
disp(area_mismatch);

thick_ids = all_heights >= 150;
thick_num = sum(thick_ids*1);
thick_occs = all_occs(thick_ids);
thick_mismatch = thick_occs(~ismember(thick_occs,bolus_occs));

disp(['Number satisfying thickness: ' mat2str(thick_num)]);
disp(['Disagreeing occs: ' mat2str(length(thick_mismatch)) ' dissagrements...']);
disp(thick_mismatch);

int_occs = intersect(area_occs,thick_occs);
int_mismatch = int_occs(~ismember(int_occs,bolus_occs));
bolus_mismatch = bolus_occs(~ismember(bolus_occs,int_occs));

disp(['Number satisfying both: ' num2str(length(int_occs))]);
disp(['Disagreeing occs: ' mat2str(length(int_mismatch)) ' dissagrements...']);
disp(int_mismatch);
disp(['Disagreeing bolus occs: ' mat2str(length(bolus_mismatch)) ' dissagrements...']);
disp(bolus_mismatch);

bolus_occs = int_occs;
save('bolus_occs','bolus_occs');

%create bolus contours with size criterion 
load bolus_cont_single;
for i = 1:length(cont)
    if ~ismember(i,bolus_occs)
        cont{i} =[];
    end
end

save('bolus_cont','cont');
