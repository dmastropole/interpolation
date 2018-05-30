%this code plots the mean and median percentages 

close all;
clear all;

screen_size = get(0, 'ScreenSize');

load('/Users/Dana/Documents/MATLAB/Latrabjarg/Mean&Anomaly/mean_grids.mat');
load mean_median;
load('/Users/Dana/Documents/MATLAB/Latrabjarg/Bolus/bolus_cont_envelope.mat');

load('/Users/Dana/Documents/MATLAB/Latrabjarg/Bathymetry/LatBat.mat');

ttl = {'Arctic-Origin Water','Polar Surface Water','Atlantic-Origin Water',...
    'Irminger Current Water'};
colors = {'greenblue','bluepurple','pink','redyellow'};
probs = {'prob1','prob2','prob3','prob4'};
type = {'mean', 'median'};
count = {'count','bolus_count','background_count','anomaly_count'};

order = [4 2 1 3];

%Make middle of Denmark Strait 0
IDX = knnsearch(X(1,:)', regdist(regbat == max(regbat)));
shiftval = X(1,IDX);
X = X - shiftval;
regdist = regdist - shiftval;

% x_range=max(regdist);
y_range=[0 700];

fpos = [1           1        1280         705];

% ww = 0.3347;
ww = 0.29;
ww = 0.25;

for i=1:length(type)
    f = figure('Position',screen_size);
    set(f,'Position',fpos);

    for j=1:length(probs)
        s = subplot(2,2,j);
%         pos = get(s,'Position');

        if j == 2 || j==4 %change left
%             pos(1) = 0.45;
            pos(1) = 0.4;
        else
            pos(1) = 0.13;
        end
        
        if j == 1 || j==2 %change bottom
            pos(2) = 0.52; 
        else
            pos(2) = 0.13;
        end
        
%         set(s,'Position',pos);  
        eval(['Z=grids.' type{i} '.prob' mat2str(order(j)) ';']);
        
        %nan out data with fewer than 10 realizations
        nids = grids.count < 10;
        Z(nids) = NaN;
        
        x_range = calc_ranges(X,Y,Z);
        hh = aspect_ratio(f,ww,'width',x_range,y_range);
        pos(3) = ww;
        pos(4) = hh;
        
        %set negative data to zero . 
        zids = Z < 0;
        Z(zids) = 0;
        
        %find lateral extent of non-NaNed data
        dids = sum(~isnan(Z)) > 0;
        xvec = X(1,dids);
        
        set(s,'Position',pos);
  
        if i==4
            [c,h,colbh]=contourf_colorbar(X,Y,Z,[-.7:0.05:0.7],'redblue',0);
        else
            [c,h,colbh]=contourf_colorbar(X,Y,Z,[0:0.05:1],colors{order(j)});
        end
        
        tnums = round(str2num(get(colbh,'YTicklabel'))*100);
        set(colbh,'YTicklabel',tnums);
        yph = ylabel(colbh,'%');
        set(yph,'Rotation',0);
        
        hold on;

        if i==2 || i==4
            hold on;
            plot(envelope_cont(:,1),envelope_cont(:,2),'color',[.5 .5 .5],...
                'linewidth',3);
        end
        
%         if i==1
            contour(X,Y,SIG,[27.8 27.8],'color',[.7 .7 .7],'linewidth',3);
%         end

        set(colbh,'fontsize',10);
        set(gca,'YDir','Reverse','fontsize',10);
        set(s,'Color',[.8 .8 .8]);
        
        %get rid of some ticks
         if j == 2 || j==4
            set(gca,'YTickLabel',' ');
        end
        
        if j == 1 || j==2
            set(gca,'XTickLabel',' ');
        end
        
        patch([regdist; max(regdist); min(regdist); regdist(1)],[regbat; y_range(2); y_range(2); regbat(1)],...
            [.5 .5 .5]);

        axis([x_range y_range]);
        title(ttl{order(j)},'fontsize',12,'fontweight','bold');
      
        
    end


    [ax,xhl] = suplabel('Distance from sill [km]','x');
    set(xhl,'fontsize',14,'fontweight','bold');
    set(get(ax,'XLabel'),'Position',[0.499073 -0.01 1.00005])
    [ay,yhl] = suplabel('Depth [m]','y');
    set(get(ay,'YLabel'),'Position',[0 0.4983 1.0001]);
    set(yhl,'fontsize',14,'fontweight','bold');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [axa,xha] = suplabel('(a)','t');
    set(xha,'fontsize',14);
    set(get(axa,'Title'),'Position',[0.05    1.0080    1.0001])
    
    [axb,xhb] = suplabel('(b)','t');
    set(xhb,'fontsize',14);
    set(get(axb,'Title'),'Position',[0.53    1.0080    1.0001])
    
    [axc,xhc] = suplabel('(c)','t');
    set(xhc,'fontsize',14);
    set(get(axc,'Title'),'Position',[0.05    .5    1.0001])
    
    [axd,xhd] = suplabel('(d)','t');
    set(xhd,'fontsize',14);
    set(get(axd,'Title'),'Position',[0.53    .5    1.0001])

    export_fig('-pdf','-transparent',[type{i} '_pcents']);
end

