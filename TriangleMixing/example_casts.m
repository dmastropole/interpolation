%This script plots some examples of casts in TS space

close all
clear all

load('/Users/Dana/Documents/MATLAB/Latrabjarg/Plotting/sig_levels');
% levels = [levels 28.05 28.1];
levels = [26.6:.2:27.6 28 28.2];
screen_size = get(0, 'ScreenSize');
axlim = [33.8 35.2 -2 8];
% colors = [  1,108,89
%             129,15,124
%             33,102,172
%             214,96,77 ]./255;
colors = [  0 .5 0
    129/255 15/255 124/255
    212/255 185/255 218/255
    214/255 96/255 77/255];

load('/Users/Dana/Documents/MATLAB/Latrabjarg/TriangleGUI/XYZ.mat');
type = {'hybrid','egc','nij'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Get TS indices

%get all mat files for indices
matfiles = dir('/Users/Dana/Documents/MATLAB/Latrabjarg/EndMembers/*_indices.mat');
for i=1:length(matfiles)
    slash = strfind(matfiles(i).name,'_');
    names{i} = matfiles(i).name(1:slash-1);
    load(['/Users/Dana/Documents/MATLAB/Latrabjarg/EndMembers/' matfiles(i).name]);
    eval(['sal_' names{i} '=indices(1);']);
    eval(['the_' names{i} '=indices(2);']);
    
    eval(['sal_std_' names{i} '=stds(1);']);
    eval(['the_std_' names{i} '=stds(2);']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Set up dimensions of TS plot

minS=33.8; maxS=35.2; minT=-2; maxT=8;

%grid points
Sg=minS+[0:50]/50*(maxS-minS);
Tg=minT+[0:50]'/50*(maxT-minT);

[SV,SG]=swstate(ones(size(Tg))*Sg,Tg*ones(size(Sg)),0);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% screen_size(1) = screen_size(4)/2.75;
figure('Position',screen_size);
% pos = [0.1   0.15    0.2    0.70];
pos = [0.1   0.3    0.2    0.70/2.75];
inc = pos(3)+0.02;

for k=1:3
    
    s = subplot(1,3,k);
    set(s,'Position',pos);
    pos(1) = pos(1) + inc;
    hold all;
    
    %plot density contours
    [CS,H]=contour(Sg,Tg,SG,levels,'Color',[.4 .4 .4]);
    cc=clabel(CS,H);
    set(cc,'Color',[.4 .4 .4]);
    [cs,h]=contour(Sg,Tg,SG,[27.8 27.8],'k','Linewidth',1.2);
    cc = clabel(cs,h);
    set(cc,'Color','k','Linewidth',1.5);
    
    %Irminger water cast
    if k==1
        
        % NIJ mixing triangle
        plot([sal_deep sal_iw sal_psw sal_deep],[the_deep the_iw the_psw the_deep],...
            'k','LineWidth',2);
        
        %plot vertices
        plot(sal_deep, the_deep,'p','MarkerFaceColor',colors(1,:),...
            'MarkerEdgeColor','k','MarkerSize',15);
        plot(sal_psw, the_psw,'p','MarkerFaceColor',colors(2,:),...
            'MarkerEdgeColor','k','MarkerSize',15);
        plot(sal_iw, the_iw,'p','MarkerFaceColor',colors(4,:),...
            'MarkerEdgeColor','k','MarkerSize',15);
        
        %plot uncertainties
        ems = {'iw','psw','deep'};
        for j=1:length(ems)
            eval(['h = plot([sal_' ems{j} '- sal_std_' ems{j} ' sal_' ems{j} '- sal_std_' ems{j} ...
                ' sal_' ems{j} '+ sal_std_' ems{j} ' sal_' ems{j} '+ sal_std_' ems{j} ...
                ' sal_' ems{j} '- sal_std_' ems{j} '],[the_' ems{j} '- the_std_' ems{j} ...
                ' the_' ems{j} '+ the_std_' ems{j} ' the_' ems{j} '+ the_std_' ems{j} ...
                ' the_' ems{j} '- the_std_' ems{j} ' the_' ems{j} '- the_std_' ems{j} ']);']);
            
            set(h,'Color',[.7 .7 .7],'Linewidth',1.5);
        end
        
        %plot cast
        xyz = XYZ(109).xyz;
        [dist,ixyz,idist] = unique(xyz(:,1,1));
        ids = idist == 17;
        
        the = xyz(ids,3,1);
        sal = xyz(ids,3,2);
        plot(sal,the,'r','linewidth',2);
        
        axis(axlim);
        box on;
        
        ylabel('Potential Temperature [^oC]','fontsize',14,'Fontweight','bold');
        set(gca,'XTick',[33.8:0.2:35.2]);
        
        title('Irminger Water Cast','fontsize',12,'fontweight','bold');
        
        %Return Atlantic Water cast
    elseif k==2
        
        % EGC mixing triangle
        plot([sal_deep sal_rAtW sal_psw sal_deep],...
            [the_deep the_rAtW the_psw the_deep],'k','LineWidth',2);
        
        %plot vertices
        plot(sal_deep, the_deep,'p','MarkerFaceColor',colors(1,:),...
            'MarkerEdgeColor','k','MarkerSize',15);
        plot(sal_psw, the_psw,'p','MarkerFaceColor',colors(2,:),...
            'MarkerEdgeColor','k','MarkerSize',15);
        plot(sal_rAtW, the_rAtW,'p','MarkerFaceColor',colors(3,:),...
            'MarkerEdgeColor','k','MarkerSize',15);
        
        %plot uncertainties
        ems = {'psw','rAtW','deep'};
        for j=1:length(ems)
            eval(['h = plot([sal_' ems{j} '- sal_std_' ems{j} ' sal_' ems{j} '- sal_std_' ems{j} ...
                ' sal_' ems{j} '+ sal_std_' ems{j} ' sal_' ems{j} '+ sal_std_' ems{j} ...
                ' sal_' ems{j} '- sal_std_' ems{j} '],[the_' ems{j} '- the_std_' ems{j} ...
                ' the_' ems{j} '+ the_std_' ems{j} ' the_' ems{j} '+ the_std_' ems{j} ...
                ' the_' ems{j} '- the_std_' ems{j} ' the_' ems{j} '- the_std_' ems{j} ']);']);
            
            set(h,'Color',[.7 .7 .7],'Linewidth',1.5);
        end
        
        %plot cast
        xyz = XYZ(110).xyz;
        [dist,ixyz,idist] = unique(xyz(:,1,1));
        ids = idist == 8;
        
        the = xyz(ids,3,1);
        sal = xyz(ids,3,2);
        
        the = xyz(ids,3,1);
        sal = xyz(ids,3,2);
        plot(sal,the,'b','linewidth',2);
        
        axis(axlim);
        box on;
        
        xlabel('Salinity','fontsize',14,'Fontweight','bold');
        set(gca,'YTickLabel',' ','XTick',[33.8:0.2:35.2]);
        
        title('Atlantic Origin Water Cast','fontsize',12,'fontweight','bold');
        
        %Hybrid cast
    elseif k==3
        xyz = XYZ(106).xyz;
        [dist,ixyz,idist] = unique(xyz(:,1,1));
        ids = idist == 6;
        egc = XYZ(106).egc & ids;
        nij = XYZ(106).nij & ids;
        
        
        the_egc = xyz(egc,3,1);
        sal_egc = xyz(egc,3,2);
        
        the_nij = xyz(nij,3,1);
        sal_nij = xyz(nij,3,2);
        
        % NIJ mixing triangle
        plot([sal_deep sal_iw sal_psw sal_deep],[the_deep the_iw the_psw the_deep],...
            'k','LineWidth',2);
        
        % EGC mixing triangle
        plot([sal_deep sal_rAtW sal_psw sal_deep],...
            [the_deep the_rAtW the_psw the_deep],'k','LineWidth',2);
        
        %plot vertices
        sloc1 = plot(sal_deep, the_deep,'p','MarkerFaceColor',colors(1,:),...
            'MarkerEdgeColor','k','MarkerSize',15);
        sloc2 = plot(sal_psw, the_psw,'p','MarkerFaceColor',colors(2,:),...
            'MarkerEdgeColor','k','MarkerSize',15);
        sloc3 = plot(sal_rAtW, the_rAtW,'p','MarkerFaceColor',colors(3,:),...
            'MarkerEdgeColor','k','MarkerSize',15);
        sloc4 = plot(sal_iw, the_iw,'p','MarkerFaceColor',colors(4,:),...
            'MarkerEdgeColor','k','MarkerSize',15);
        
        %plot uncertainties
        ems = {'iw','psw','rAtW','deep'};
        for j=1:length(ems)
            eval(['h = plot([sal_' ems{j} '- sal_std_' ems{j} ' sal_' ems{j} '- sal_std_' ems{j} ...
                ' sal_' ems{j} '+ sal_std_' ems{j} ' sal_' ems{j} '+ sal_std_' ems{j} ...
                ' sal_' ems{j} '- sal_std_' ems{j} '],[the_' ems{j} '- the_std_' ems{j} ...
                ' the_' ems{j} '+ the_std_' ems{j} ' the_' ems{j} '+ the_std_' ems{j} ...
                ' the_' ems{j} '- the_std_' ems{j} ' the_' ems{j} '- the_std_' ems{j} ']);']);
            
            set(h,'Color',[.7 .7 .7],'Linewidth',1.5);
        end
        
        L = legend([sloc1 sloc2 sloc3 sloc4],'Arctic Origin Water',...
            'Polar Surface Water','Atlantic Origin Water',...
            'Irminger Current Water','Location','SouthOutside');
        
        set(L,'Units','Pixels','Fontsize',11);
        pos = get(L,'OuterPosition');
        
        %         set(L,'Position',[970 pos(2:end)]);
        set(L,'Position',[pos(1) 120 pos(3:end)]);
        
        
        %plot cast
        plot(sal_nij,the_nij,'r','linewidth',2);
        plot(sal_egc,the_egc,'b','linewidth',2);
        
        axis(axlim);
        box on;
        
        set(gca,'YTickLabel',' ','XTick',[33.8:0.2:35.2]);
        
        title('Hybrid Cast','fontsize',12,'fontweight','bold');
        
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[a1,h1]= suplabel('(a)','t');
set(h1,'fontsize',14);
set(get(a1,'Title'),'Position',[0.05 1.05 1.00005]);

[a2,h2]= suplabel('(b)','t');
set(h2,'fontsize',14);
set(get(a2,'Title'),'Position',[0.35 1.05 1.00005]);

[a3,h3]= suplabel('(c)','t');
set(h3,'fontsize',14);
set(get(a3,'Title'),'Position',[0.65 1.05 1.00005]);


export_fig('-pdf','-transparent','ExampleCasts');