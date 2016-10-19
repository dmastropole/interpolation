function [hb,colbh] = nonlinear_colorbar(hi,cpt,pos,fs)

% function hb = nonlinear_colorbar(hi,cpt,pos,fs)
%
% Redraws the color contours according to the levels specified in cpt and
% makes an appropriate colorbar
%
% INPUTS:
% hi  - Handle to the output of [Ci,hi] = countourf(...,cpt.levels)
% cpt - Structure with GMT-like color palette table containing
%       cpt.cpt    - Colormap in RGB matrix
%       cpt.levels - Levels at which colors should be used
%       cpt.annot  - Character matrix with annotation for the colorbar
%       cpt.COLOR_BACKGROUND (optional)
%       cpt.COLOR_FOREGROUND (optional)
%       We require:
%       length(cpt.levels) == size(cpt.annot,1) == size(cpt.cpt,1)+1
% pos - Position for colorbar (optional) e.g. 'EastOutside', 'SouthOutside'
%       If pos is not specified, we will not draw a colorbar
% fs  - Font size
% OUTPUT:
% hb   - Handle to the colorbar
% colbh - Handle to old colorbar (use for creating labels)

% Check the dimensions of cpt
if length(cpt.levels) ~= size(cpt.annot,1) || ...
   length(cpt.levels) ~= size(cpt.cpt,1)+1
    error(['We require: \newline' ...
           'length(cpt.levels) == size(cpt.annot,1) == size(cpt.cpt,1)+1'])
end
    
% Check optional arguments in cpt, i.e. set out of bounds colors to black
if ~isfield(cpt,'COLOR_BACKGROUND');
    cpt.COLOR_BACKGROUND = [0 0 0];
end
if ~isfield(cpt,'COLOR_FOREGROUND');
    cpt.COLOR_FOREGROUND = [0 0 0];
end


% Set the colormap to cpt.cpt such that the colorbar is automatically using
% these colors. However, we still have to manually adjust the face colors
% as we use non-uniform color-steps.
% % colormap(gca,cpt.cpt);

% Cycle through each contour level
hx = get(hi,'Children'); % hx is handle to each color contour face
% % hx = hi;
for ii = 1:length(hx)
    % Get the value of the current color contour face
	dat = get(hx(ii),'Cdata');
    % Find index of the color transition that precedes dat
    ind1 = find(cpt.levels <= dat,1,'last'); 
    % Find index of the color transition that succeeds dat
    ind2 = find(cpt.levels > dat,1,'first');
    if ~isempty(ind1) && ~isempty(ind2)
        % We have found an intermediate color, so use cpt.cpt(ind1,:)
        set(hx(ii),'FaceColor',cpt.cpt(ind1,:),'EdgeColor','none'); 
    elseif ~isempty(ind2)
        % We have found a contour level below lowest non-uniform color
        % level, so use COLOR_BACKGROUND
        set(hx(ii),'FaceColor',cpt.COLOR_BACKGROUND,'EdgeColor','none');
    elseif ~isempty(ind1)
        % We have found a contour level above highest non-uniform color
        % level, so use COLOR_FOREGROUND
        set(hx(ii),'FaceColor',cpt.COLOR_FOREGROUND,'EdgeColor','none');
    end
end

% Save handle to the axis in order to be able to revert it
ax1 = gca;

if exist('pos') %#ok<EXIST> % If position is specified, we draw a colorbar
    % Append a new colormap to the existing one and save the old one such
    % that one can refer back to its length
    cmap_old = colormap;
    colormap([cmap_old;cpt.cpt])
    
    % Make a colorbar and make it invisible
  	hb = colorbar('Location',pos); % Handle to the colorbar to be removed
	cp = get(hb,'Position'); % Handle to position of colorbar
	set(hb,'visible','off'); % Make colorbar invisible
	cx = get(hb,'Children'); % Handle to children of colorbar
	set(cx,'visible','off'); % Turn them off
	colbh = axes('Position',cp); % Handle to position of invisble colorbar
    
    % Find out where the colorbar has been plotted
    if any(strcmp({'W' 'w' 'E' 'e'},pos(1)))
        % Colorbar is to the left or right
        % Make the 'colorbar' using pcolor
        hcc = pcolor([(1:length(cpt.cpt)+1)' (1:length(cpt.cpt)+1)']);
        set(hcc,'CDataMapping','direct')
        set(hcc,'CData',length(cmap_old)+(1:length(cpt.cpt)+1)')
        set(hcc,'EdgeColor','none')

        % Find y-limits, rescale and annotate them
        y_lim = get(colbh,'YLim');
        set(colbh,'XTick',[])
        if any(strcmp({'E' 'e'},pos(1)))
            set(colbh,'YAxisLocation','right')
        else
            set(colbh,'YAxisLocation','left')
        end
        set(colbh,'YTick',linspace(y_lim(1),y_lim(2),length(cpt.levels)));
        set(colbh,'YTickLabel',cpt.annot);
        
        %Setting size of colorbar labels!!
        if nargin==4
            set(colbh,'FontSize',fs)
        else
            set(colbh,'FontSize',get(hb,'FontSize'));
        end

    elseif any(strcmp({'S' 's' 'N' 'n'},pos(1)))
        % Colorbar is to the top or bottom
        % Make the 'colorbar' using pcolor
        hcc = pcolor([(1:length(cpt.cpt)+1); (1:length(cpt.cpt)+1)]);
        set(hcc,'CDataMapping','direct')
        set(hcc,'CData',length(cmap_old)+(1:length(cpt.cpt)+1))
        set(hcc,'EdgeColor','none')

        % Find x-limits, rescale and annotate them
        x_lim = get(colbh,'XLim');
        set(colbh,'YTick',[])
        set(colbh,'XAxisLocation','bottom')
        set(colbh,'XTick',linspace(x_lim(1),x_lim(2),length(cpt.levels)));
        set(colbh,'XTickLabel',cpt.annot);
        set(colbh,'FontSize',15)
    else
        error('Cannot deal with the location specification: pos')
    end
    
else % Do not draw a colorbar :-(
    disp('Since no position has been specified, no colorbar is drawn.')
    hb = [];
end

axes(ax1)

