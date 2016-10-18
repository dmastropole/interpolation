function [c,h,colbh,hb] = contourf_colorbar(X,Y,Z,ticks,color,midpt)

% [c,h,colbh] = contourf_colorbar(X,Y,Z,ticks,color,midpt)
%
% INPUT: 
%   - X     :   2D matrix of x values to be contoured (input to contourf)
%   - Y     :   2D matrix of y values to be contoured (input to contourf)
%   - Z     :   2D matrix of z values to be contoured (input to contourf)
%   - ticks :   either 1) a single number specifing number of contour levels
%               or 2) a vector of contour levels
%   - color :   either 1) (2n+1) x 3 matrix of rgb values (doesn't 
%               have to be one less than the number of contour levels) or 2) 
%               one of the following colors: bluegreen, greenblue,
%               bluepurple, redyellow, pink, redblue, or summer
%   - midpt :   optional input specifing the countour level that divides
%               the color spectrum in half.  (Useful for bipolar colorbars)
%
% OUTPUT:
%   - c     :   contour matrix (output of contourf)
%   - h     :   handle to contourf plot
%   - colbh :   handle to colorbar

%preset rgb values from Bob and colorbrewer2.org
load('/Users/Dana/Documents/MATLAB/Latrabjarg/Mean&Anomaly/theta_colorbar.mat');
load('/Users/Dana/Documents/MATLAB/Latrabjarg/Mean&Anomaly/salinity_colorbar.mat');

bluegreen = flipud([255,247,251
236,226,240
208,209,230
166,189,219
103,169,207
54,144,192
2,129,138
1,108,89
1,70,54])./255;

greenblue = [255,247,251
236,226,240
208,209,230
166,189,219
103,169,207
54,144,192
2,129,138
1,108,89
1,70,54]./255;

bluepurple = [247,252,253
224,236,244
191,211,230
158,188,218
140,150,198
140,107,177
136,65,157
129,15,124
77,0,75]./255;

redyellow = [255,247,236
254,232,200
253,212,158
253,187,132
252,141,89
239,101,72
215,48,31
179,0,0
127,0,0]./255;

pink = [247,244,249
231,225,239
212,185,218
201,148,199
223,101,176
231,41,138
206,18,86
152,0,67
103,0,31]./255;

redblue = flipud([178,24,43
214,96,77
244,165,130
253,219,199
247,247,247
209,229,240
146,197,222
67,147,195
33,102,172])./255;

summer = flipud([215,48,39
244,109,67
253,174,97
254,224,144
255,255,191
224,243,248
171,217,233
116,173,209
69,117,180])./255;

blue = [247,251,255
222,235,247
198,219,239
158,202,225
107,174,214
66,146,198
33,113,181
8,81,156
8,48,107]./255;

rainbow = [158,1,66
213,62,79
244,109,67
253,174,97
254,224,139
255,255,191
230,245,152
171,221,164
102,194,165
50,136,189
94,79,162]./255;

orangepurple = flipud([127,59,8
179,88,6
224,130,20
253,184,99
254,224,182
247,247,247
216,218,235
178,171,210
128,115,172
84,39,136
45,0,75])./255;

%if midpt is empty, then get rid of variable
if exist('midpt','var')
    if isempty(midpt)
        clear midpt
    end
end


%if color isn't an input, use the current colormap rgbs
if ~exist('color','var')
    rgb = get(gcf,'colormap');
end

%determine whether color refers to preset rgb values or not
if isa(color,'numeric')
    rgb = color;
else
    rgb = eval(color);
end

%make rgb matrix the correct size and tickvector
ticks = unique(ticks);

if length(ticks) == 1 %if given number of ticks
    range = [min(min(Z)) max(max(Z))];
    
    if exist('midpt','var') %if selected a midpoint
        if midpt < max(range) & midpt > min(range)
            if mod(ticks,2) == 0
                disp('WARNING: changed number of ticks to next largest odd number')
            end
            ticks = [linspace(range(1),midpt,ceil(ticks/2))...
                linspace(midpt,range(2),ceil(ticks/2))];
            ticks = unique(ticks); 
        end
        ticks = linspace(range(1), range(2), ticks);
    else %if no midpoint
        ticks = linspace(range(1), range(2), ticks);
    end
    
    xi = linspace(1,size(rgb,1),ticks-1);
    rgb = interp1(rgb,xi);
    
else %if given a vector of ticks
    
    if exist('midpt','var')
        %make sure that ticks includes the midpt
        [ticks,ai,ci] = unique([ticks(:); midpt]);
        midptid = ci(end);
        if mod(size(rgb,1),2) == 0
            disp('ERROR: Need to start with an odd number of RGB values');
            return
        end
        xi1 = linspace(1,floor(size(rgb,1)/2),midptid-1);
        rgb1 = interp1(rgb(1:floor(size(rgb,1)/2),:),xi1);
        
        xi2 = linspace(1,floor(size(rgb,1)/2),length(ticks)-midptid);
        rgb2 = interp1(rgb(round(size(rgb,1)/2)+1:end,:),xi2);
        rgb = [rgb1;rgb2];
%         rgb = unique([rgb1;rgb2],'rows');
    else
        xi = linspace(1,size(rgb,1),length(ticks)-1);
        range = [min(ticks) max(ticks)];
        rgb = interp1(rgb,xi);
    end
    
    
end

%create contourplot
[c,h]=contourf(X,Y,Z,[min(min(Z)); ticks(:)]);
kids = get(h,'Children');
for i=1:length(kids)
    set(kids(i),'LineStyle','none');
end
cpt.cpt = rgb;
cpt.levels = ticks(:);
cpt.annot = num2str(cpt.levels);
[hb,colbh] = nonlinear_colorbar(h,cpt,'EastOutside');

end