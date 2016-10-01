function var_mix = graft_grids(var_sig,var_dpth,sig,upper,lower)

%This function joins two gridded variables in density and depth space.
%Values with corresponding densities lower than the sigma value defined 
%by "upper" stay in depth space.  Values with corresponding densities
%greater than the sigma value defined by "lower" stay in density space.
%Values falling between "upper" and "lower" are averaged with linear
%weights.  This averaging process is described by the equations:
%
%       var_new =   alpha*var_sig + (1-alpha)*var_dpth
%       alpha   =   [sig - upper]/[lower - upper]
%
%   Inputs:
%       - var_sig   :   2D gridded field in density space
%       - var_dpth  :   2D gridded field in depth space
%       - sig       :   2D density field (gridded in depth space)
%       - upper     :   value of upper (lighter) density bound
%       - lower     :   value of lower (denser) density bound
%   Output:
%       - var_mix   :   2D field gridded in density and depth space

I = ones(size(sig));
A = NaN(size(sig));

uids = sig < upper;
lids = sig > lower;
mids = sig <= lower & sig >= upper;

A(uids) = 0;
A(lids) = 1;
A(mids) = (sig(mids)-upper)./(lower-upper);

var_mix = A.*var_sig + (I-A).*var_dpth;

end