%This script is the master gridding script

close all;
clear all;
clc

disp('*** Running: calc_pcents.m');
run('calc_pcents.m');

clc

disp('*** Running: extrap_pcents.m');
run('extrap_pcents.m');

clc

disp('*** Running: grid_prob_first.m');
run('grid_prob_first.m');

clc

disp('*** Running: grid_prob_low2high.m');
run('regrid_low2high_prob.m');

clc

disp('*** Running: nan_grids_prob.m');
run('nan_grids_prob.m');