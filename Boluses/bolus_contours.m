%This script finds the contours of boluses according to N^2 criteria

close all;
clear all;

load('/Users/Dana/Documents/MATLAB/Latrabjarg/Nsq/grids_nsq.mat');
load('/Users/Dana/Documents/MATLAB/Latrabjarg/Bathymetry/LatBat.mat');

%create contours;
rd = regdist(regdist < 165 & regdist > 93);
rb = regbat(regdist < 165 & regdist > 93)+40;
% ids = regbat <= max(regbat)+15 & regbat >= max(regbat)-15;
% rb(ids) = rb(ids)+15;
dspoly = [rd(1) 0; rd rb; rd(end) 0; rd(1) 0];
latrabjarg = [regdist(1) 0; regdist regbat; regdist(end) 0; regdist(1) 0];

figure;
plot(regdist,regbat);
hold on;
plot(dspoly(:,1),dspoly(:,2),'r','linewidth',5);
set(gca,'YDir','Reverse');

print('-depsc' ,'-r200','dspoly');

% save('dspoly','dspoly');

for i=1:length(grids)
    disp(i)
    
    %find weakly stratified overflow water
%     ID = grids(i).sig >= 27.8 & grids(i).nsq <= 0.05e-4;
    ID = grids(i).sig >= 27.8 & grids(i).nsq <= 0.02e-4;
    ID = ID*1;
    
    %smooth and contour bolus
    ID = smooth2a(ID,2,2);
    
    %water outside irminger and above bottom
    IN = ~inpolygon(grids(i).X,grids(i).Y,dspoly(:,1),dspoly(:,2));
    ID(IN) = 0;
    
    c = contour(grids(i).X,grids(i).Y,ID,[.5 .5]);
    
    if ~isempty(c)
        [x,y] = get_contour(c,0.5);
        
        %cut out irminger water and bottom
        [x,y]=polybool('&',x,y,latrabjarg(:,1),latrabjarg(:,2));
        
        if ~isempty(x)
            cont{i} = [x(:) y(:)];
            plot(x,y,'m');
        else
            cont{i} =[];
        end
    else
        cont{i} = [];
    end
    
end

save('bolus_cont_nosize','cont');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Select biggest contour

%pick largest contour
for i=1:length(cont)
    
    if ~isempty(cont{i})
        [xcells,ycells]=polysplit(cont{i}(:,1),cont{i}(:,2));

        cell_area = [];
        for j=1:length(xcells)
            cell_area(j) = polyarea(xcells{j},ycells{j});
        end
        
        [cell_area,ids]=sort(cell_area);
        
        new_cont{i} = [xcells{ids(end)} ycells{ids(end)}];
        cont_area(i) = cell_area(end)*1000;
    else
        new_cont{i} = [];
        cont_area(i) = NaN;
    end
end

cont = new_cont;

save('bolus_cont_single','cont');

