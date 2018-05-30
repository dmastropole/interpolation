%This script calculates the contribution to the percent errors based on the
%contribution of seasonal/interannual variability in the end members

close all;
clear all;

load Uncertainties

NAMES = {'DEEP','IW','PSW','RATW'};
names = {'deep','iw','psw','rAtW'};

for i=1:length(names)
    eval([names{i} '_std = nanstd(' NAMES{i} ');']);
end

save('Uncertainties_std','deep_std','iw_std','psw_std','rAtW_std');
