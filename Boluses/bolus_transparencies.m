%This script takes the definitions of the boluses, contours them in the
%Denmark Strait occupations, and creates bolus transparences.  

close all;
clear all;

screen_size=get(0,'ScreenSize');

%load in data
load('/Users/Dana/Documents/MATLAB/Latrabjarg/Bathymetry/LatBat.mat');
load('/Users/Dana/Documents/MATLAB/Latrabjarg/Mean&Anomaly/mean_grids.mat');
load('bolus_cont.mat');
load('bolus_occs.mat');

%Make middle of Denmark Strait 0
IDX = knnsearch(X(1,:)', regdist(regbat == max(regbat)));
shiftval = X(1,IDX);
X = X - shiftval;
regdist = regdist - shiftval;
xvec = X(1,:); yvec = Y(:,1);

% THE(:,92:end) = NaN;
nids = X < -50 | X > 50 | Y < 200;
THE(nids) = NaN;
xids = nansum(THE) > 0;
yids = nansum(THE,2) > 0;

x_range=[min(xvec(xids)) max(xvec(xids))];
y_range=[min(yvec(yids)) 700];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load mooring
load('/Users/Dana/Documents/MATLAB/Latrabjarg/Mooring/HH009_HHDS102_Final1.mat');

%position
lat_mooring=settings.position(1)+settings.position(2)/60;
lon_mooring=settings.position(3)+settings.position(4)/60;

%restrict velocities to times when transducer was underwater
time_ids=sensor.tr_depth>600;

%find average depth of each bin
depth=sensor.depth(:,time_ids);
depth=nanmean(depth,2);

%get rid of velocities where the depth is above the surface
depth_ids=depth >= 0;
depth=depth(depth_ids);

%get distance of mooring along line
load('/Users/Dana/Documents/MATLAB/Latrabjarg/ref_coord_LB_bath.mat');
dist_mooring=sta_proj(lat_mooring,lon_mooring,ref_coord_LB_bath);
dist_vec=repmat(dist_mooring, length(depth), 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

r0=0;
a=0.025;

colors={'b','r'};

%bolus transparencies 
fpos = [1           1        1280         705];
f=figure;
set(f,'Position',fpos);

for i=1:length(cont)
    if ~isempty(cont{i})
        [F,V]=poly2fv(cont{i}(:,1)-shiftval,cont{i}(:,2));
        p1=patch('Faces', F, 'Vertices', V, 'FaceColor', [r0 r0 1], ...
            'EdgeColor', 'none');
        alpha(p1,a);
        hold on;
    end
end

H = 0.7;
W = aspect_ratio(f,H,'height',x_range,y_range);
% set(gca,'ydir','reverse','fontsize',16,'Position',[0.1300 0.1100 W-.08 H]);
set(gca,'ydir','reverse','fontsize',16,'Position',[0.1300 0.1100 W H]);

%labels
xlabel('Distance from sill [km]', 'fontsize', 18,'fontweight','bold');
ylabel('Depth [m]', 'fontsize', 18,'fontweight','bold');
% title('Locations of Boluses','fontsize',20,'fontweight','bold');

cmap =[];

for n = 1:55  %n= number of elements in colorbar (# overlying patches)
    r =r0 + (1-r0)*(1-a)^(n);
    cmap(n,:) = [r r 1 ];
end

colormap(cmap);
c=colorbar;

keyboard
set(c,'YTick',[0:1/10:1],'YTickLabel',[0:5:50],'Position',...
    [0.13+W+0.02 0.1084 0.025 0.7019],'linewidth',2);
%     [0.7941 0.1084 0.025 0.7019]);
set(gca,'Fontsize',15,'Linewidth',2);
ylabel(c,'Number of Boluses','fontsize',18,'fontweight','bold');
axis([x_range(1) x_range(2) y_range(1) y_range(2)]);
box on;

%bathymetry
patch([regdist; x_range(2); min(regdist); regdist(1)],[regbat; y_range(2); y_range(2); regbat(1)],...
    [.5 .5 .5]);
            
set(gcf,'PaperPositionMode','auto');

print('-depsc' ,'-r200','TransparentAreasBolus');
% export_fig('-pdf','-transparent',['TransparentAreasBolus']);