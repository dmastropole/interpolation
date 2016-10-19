function [x,y] = get_contour(c, val)

%This function returns the x and y loctaions of a contour. 
%INPUT:
%   - c:    The contour matrix, or output of MATLAB function "contour" 
%   - val:  The value of the contour you want to get
%
%OUTPUT: 
%   - x:    The x values of the contour "val." If more than one contour
%   exists for "val," the curves are delimited by NaNs 
%   - y:    The y values of the contour "val." See above. 


x =[]; y=[];

id=find(c(1,:)==val);

if ~isempty(id)
    for j=1:length(id)
        x=[x c(1,id(j)+1:id(j)+c(2,id(j))) NaN];
        y=[y c(2,id(j)+1:id(j)+c(2,id(j))) NaN];
    end
    x(end) = [];
    y(end) = [];
    
    %make sure clockwise
    [x,y]=poly2cw(x,y);
else
    disp('*** No contour found! ***');
end

end