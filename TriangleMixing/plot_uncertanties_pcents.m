%this script plots the uncertainties 

close all;
clear all;

load Uncertainties

screen_size=get(0,'ScreenSize');

figure('Position',screen_size);

subplot(2,2,1);
n = calcnbins(DEEP);
hist(DEEP,n);
[f,xi] = ksdensity(DEEP);
hold on;
yl = get(gca,'ylim');
[f,xi] = ksdensity(DEEP);
plot(xi,f*yl(2)/max(f),'r')
title(['Arct. Orig: ' mat2str(std(DEEP))], 'fontsize', 14);


subplot(2,2,2);
n = calcnbins(PSW);
hist(PSW,n);
[f,xi] = ksdensity(PSW);
hold on;
yl = get(gca,'ylim');
[f,xi] = ksdensity(PSW);
plot(xi,f*yl(2)/max(f),'r')
title(['PSW: ' mat2str(std(PSW))], 'fontsize', 14);

subplot(2,2,3);
n = calcnbins(RATW);
hist(PSW,n);
[f,xi] = ksdensity(RATW);
hold on;
yl = get(gca,'ylim');
[f,xi] = ksdensity(RATW);
plot(xi,f*yl(2)/max(f),'r')
title(['RATW: ' mat2str(std(RATW))], 'fontsize', 14);

subplot(2,2,4);
n = calcnbins(IW);
hist(IW,n);
[f,xi] = ksdensity(IW);
hold on;
yl = get(gca,'ylim');
[f,xi] = ksdensity(IW);
plot(xi,f*yl(2)/max(f),'r')
title(['Irminger: ' mat2str(std(IW))], 'fontsize', 14);

export_fig('-pdf','-transparent','Uncertainties_hist');