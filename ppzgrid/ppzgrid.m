%%
%%  Routine zgrid.c is a C language version of the FORTRAN language
%%  subroutine of the same name found in the PLOT+ Scientific Graphics 
%%  System.  The original boilerplate follows.
%%    @(#)zgrid.f	1.3    3/30/93
%%
%%*********************************************************************
%%
%%                 PLOT+ Scientific Graphics System
%%
%%*********************************************************************
%%
%%
%%     Sets up square grid for contouring , given arbitrarily placed 
%%     data points. Laplace interpolation is used. 
%%     The method used here was lifted directly from notes left by 
%%     Mr Ian Crain formerly with the comp.science div. 
%%     Info on relaxation solution of laplace equations  supplied by 
%%     Dr T Murty.   FORTRAN II   Oceanography/EMR   Dec 68   JDT 
%% 
%%     z = 2-d array of hgts to be set up. points outside region to be 
%%     contoured should be initialized to 10%%35 . The rest should be 0.0 
%%     nx,ny = max subscripts of z in x and y directions. 
%%     x1,y1 = coordinates of z(1,1) 
%%     dx,dy = x and y increments . 
%%     xp,yp,zp = arrays giving position and hgt of each data point. 
%%     n = size of arrays xp,yp and zp . 
%% 
%%     modification feb/69   to get smoother results a portion of the 
%%     beam eqn  was added to the laplace eqn giving 
%%     delta2x(z)+delta2y(z) - k(delta4x(z)+delta4y(z)) = 0 . 
%%     k=0 gives pure laplace solution.  k=inf. gives pure spline solution. 
%%     cayin = k = amount of spline eqn (between 0 and inf.) 
%%     nrng...grid points more than nrng grid spaces from the nearest 
%%            data point are set to undefined. 
%% 
%%
%%  Because a lot of this is in-place processing it is very order 
%%  dependent and definitely does not lend itself to vectorization.
%%  Are there other ways of doing it? Most assuredly, but they would
%%  not produce the same results and thats the thing here.
%%  Matlab version has the following 'refinements'.
%%  - Test for NaN as well as the 'flag' value 1.0E+35.
%%
%%*****************************************************************************
%%


function [Z] = ppzgrid (mymat, Z, tem_struct);
  
     % Initialization.  Don't messa around with the order unless you are
     % prepared for major screw-ups.
LDEBUG = 0;
lverbose    = tem_struct.VOPT;
zbig        = tem_struct.zbig;
X1          = tem_struct.X1;
Y1          = tem_struct.Y1;
NX          = tem_struct.NX;
NY          = tem_struct.NY;
DX          = tem_struct.DX;
DY          = tem_struct.DY;
init_method = tem_struct.POPT;
NRNG        = tem_struct.SOPT;
CAY         = tem_struct.TOPT;
eps         = tem_struct.COPT;
itmax       = tem_struct.NOPT;

XP = mymat(:,1);
YP = mymat(:,2);
ZP = mymat(:,3);

big = 0.9E+35;
bigger = zbig;
 
zmin =  big;
zmax = -big;


     % Some initialization.
imnew = zeros (NY, 1);

     % Get zbase which will make all zp values positive by 20*(zmax-zmin)
     % Ignore NaN while we are at it.
ik = find (ZP < bigger  &  isnan(ZP) == 0);
zmax = max (ZP(ik) );
zmin = min (ZP(ik) );
zrange = zmax - zmin;
if zrange == 0 %need if you are trying to grid field of same values - Dana
    zrange = 1;
end
zbase = zrange * 20.0 - zmin;
hrange = DX*(NX - 1);
if (DY*(NY-1) < hrange)  
  hrange = DY*(NY-1);
  end  % if
derzm = 2.0 * zrange / hrange;
if (lverbose)
  fprintf (1, '    ZRANGE:  %f   used in eps test;\n',  zrange);
  fprintf (1, '    ZBASE:   %f\n', zbase);
  fprintf (1, '    HRANGE:  %f\n', hrange);
  fprintf (1, '    DERZM:   %f\n', derzm);
  end  % if verbose

     % From here on I make no apologies for slavishly following the
     % C code.  It was confusing enough the first two times I converted
     % the program.

     % Set pointer array knxt.  Test that subscripts are in range.
N = length (XP);
for (kk=1:N)  
  k =  N - kk + 1;
  knxt(k) = 0;
  i = fix ((XP(k) - X1) / DX + 1.5);
  if (i*(NX + 1 - i) > 0) 
    j = fix ((YP(k) - Y1) / DY + 1.5);
    if (j*(NY + 1 - j) > 0)
      if (Z(j,i) <  big  &  ~isnan(Z(j,i)))
        knxt(k) = N + 1;
        if (Z(j,i) > 0)  
          knxt(k) = fix (Z(j,i) + 0.5);
          end
        Z(j,i) = k;
        end  % if valid Z point.
      end  % if j is in y range.
    end  % if i is in valid x range.
  end  % for loop setting pointer array.
  
if (LDEBUG >= 1)
  fprintf (1, 'KNXT: %i %i %i\n', N, NX, NY);
  fprintf (1, '  %i', knxt);
  fprintf (1, '\n');
  for (j=1:NY)
    fprintf (1, '\nI:%i', j);
    fprintf (1, ' %i', Z(j,:) );
    end  % for each line of output.
  fprintf (1, '\n')
  end  % if debug output.
 
     % Affix each data point ZP to its nearby grid point.  Take avg ZP if 
     % more than one ZP nearby the grid point.  Add zbase and complement. 
     %
for (k=1:N)  
  if (knxt(k) > 0) 
    npt = 0;
    imask = 0;

    zsum = 0.0;
    i = fix ((XP(k) - X1) / DX + 1.5);
    j = fix ((YP(k) - Y1) / DY + 1.5);
    kk = k;

    while (kk <= N  |  npt == 0) 
      npt = npt + 1;
      kksav(npt) = kk;
      if (ZP(kk) > big)  imask = 1;  end

      zsum = zsum + ZP(kk);
      knxt(kk) = -knxt(kk);
      kk = -knxt(kk);
      end  % while kk <= N

    if (imask == 0) 
      Z(j,i) = -zsum / npt - zbase;
     else 
      Z(j,i) = bigger;
      for (i=1:npt)
        knxt(kksav(i)) = 0
        end  % for knxt reset.
      end  % if not masked
    end  % knxt is > 0
  end  % for each knot.

     % Initially set each unset grid point to value of nearest known pt. 
     %
ik = find (Z == 0.0);
Z(ik) = -bigger;

if (LDEBUG >= 1)
  for (j=1:NY)
    fprintf (1, '\nU:%i', j);
    fprintf (1, ' %g', Z(j,:) );
    end  % for each line of output.
  fprintf (1, '\n')
  end  % if debug output.


     % This whole row/column concept is by now very misleading.
for (iter=1:NRNG) %SEARCH RADIUS PART - DANA

  nnew = 0;
  for (i=1:NX)
    for (j=1:NY)
      jskip = 0;
      ninit = 0;
      zinit = 0.0;
      if (Z(j,i) + big < 0) % if unset grid point - Dana
          
        if (j > 1)  % if not the first row.
          if (jmnew <= 0) % Make sure you're only setting real data to unset point for first iteration - Dana
            zijn = abs (Z(j-1,i) );
            if (zijn < big) % If the surrounding point is not masked or unset - Dana
              [imnew(j), jmnew, nnew] = set_new  (nnew);
              if (init_method == 0)  
                Z(j,i) = zijn;
                jskip = 1;
               elseif (init_method == 1)
                ninit = ninit + 1;
                zinit = zinit + zijn;
                end  % if init_method
              end  % if zijn < big
            end  % if jmnew <= 0
          end  % if not the first row.

        if (i > 1  &  jskip == 0)     % If not the first column.
          if (imnew(j) <= 0)
            zijn = abs (Z(j,i-1) );
            if (zijn < big) 
              [imnew(j), jmnew, nnew] = set_new  (nnew);
              if (init_method == 0)
                Z(j,i) = zijn;
                jskip = 1;
               elseif (init_method == 1)
                ninit = ninit + 1;
                zinit = zinit + zijn;
                end  % if init_method
              end  % if zijn < big
            end  % if imnew(j) <= 0
          end  %  If not the first column.

        if (j < NY  &  jskip == 0)  % If not the last row.
          zijn = abs (Z(j+1,i) );
          if (zijn < big) 
            [imnew(j), jmnew, nnew] = set_new  (nnew);
            if (init_method == 0) 
              Z(j,i) = zijn;
              jskip = 1;
             elseif (init_method == 1)
              ninit = ninit + 1;
              zinit = zinit + zijn;
              end  % if init_method
            end  % if zijn < big
          end  % If not the last row.

        if (i < NX  &  jskip == 0)     % If not the last column.
          zijn = abs (Z(j,i+1) );
          if (zijn < big)
            [imnew(j), jmnew, nnew] = set_new  (nnew);
            if (init_method == 0) 
              Z(j,i) = zijn;
              jskip = 1;
             elseif (init_method == 1)
              ninit = ninit + 1;
              zinit = zinit + zijn;
              end  % if init_method
            end  % if zijn < big
          end  % if not the last column.

        if (init_method == 1  &  ninit > 0) 
          Z(j,i) = zinit/ninit;
          end  % if init_method == 1
        end  % if first pass Z[i][j]+big < 0.
        
      if (init_method == 0  &  jskip == 0) 
        imnew(j) = 0;
        jmnew = 0;
       elseif (init_method == 1  &  ninit <= 0) 
        imnew(j) = 0;
        jmnew = 0;
       end  % if init_method 

      end % for j
    end  % for i
  if (nnew <= 0)  break;  end
  end  % for iter.

ik = find (abs(Z) >= big);
Z(ik) = abs (Z(ik) );

if (LDEBUG >= 1)
  for (j=1:NY)
    fprintf (1, '\nIMP:%i', j);
    fprintf (1, ' %g', Z(j,:) );
    end  % for each line of output.
  fprintf (1, '\n')
  end  % if debug output.


     % Improve the non-data points by applying point over-relaxation 
     % using the Laplace-spline equation  (Carres method is used) .
     %
if (lverbose == 1)
  fprintf (1, '  Convergence criteria will be printed.\n')
  fprintf (1, '    iteration;\n')
  fprintf (1, '    dzmax   maximum individual dz;\n')
  fprintf (1, '    npg     # good points used in weighting dz;\n')
  fprintf (1, '    dzrms   rms of dz;\n')
  fprintf (1, '    root    ratio of current over previous dzrms;\n')
  fprintf (1, '    eps_test = dzmax/zrange/(1.0 - root_mod)\n')
  end  % if verbose
dzrmsp = zrange;
relax = 1.0;
for (iter=1:itmax)
  dzrms = 0.0;
  dzmax = 0.0;
  npg = 0;
  for (i=1:NX)
    for (j=1:NY)
      z00 = Z(j,i);
      if (z00 < big)
        if (z00 >= 0)% If non-data or "filled-in" point (-Dana)
          wgt = 0.0;
          zsum = 0.0;

          % Take care of the boundary conditions.
          im = 0;
          if (i > 1)
            zim = abs (Z(j,i-1) );
            if (zim < big)
              im = 1;
              wgt = wgt + 1.0;
              zsum = zsum + zim;
              if (i > 2)
                zimm = abs (Z(j,i-2) );
                if (zimm < big)
                  wgt = wgt + CAY;
                  zsum = zsum - CAY * (zimm - 2.0*zim);
                  end  % if
                end  % if i > 2
              end  % if zim < big
            end  % if i > 1

          if (i < NX) 
            zip = abs (Z(j,i+1) );
            if (zip < big)
              wgt = wgt + 1.0;
              zsum = zsum + zip;
              if (im > 0)
                wgt = wgt + 4.0 * CAY;
                zsum = zsum + 2.0 * CAY * (zim + zip);
                end  % if
              if (i < NX-1) 
                zipp = abs (Z(j,i+2) );
                if (zipp < big)
                  wgt = wgt + CAY;
                  zsum = zsum - CAY * (zipp - 2.0*zip);
                  end  % if zipp < big
                end  % if i < NX-1
              end  % if zip < big
            end  % if i < NX

          jm = 0;
          if (j > 1)
            zjm = abs (Z(j-1,i) );
            if (zjm < big)
              jm = 1;
              wgt = wgt + 1.0;
              zsum = zsum + zjm;
              if (j > 2) 
                zjmm = abs (Z(j-2,i) );
                if (zjmm < big)
                  wgt = wgt + CAY;
                  zsum = zsum - CAY * (zjmm - 2.0*zjm);
                  end  % if
                end  % if j > 2
              end  % if zjm < big
            end  % if j > 1 

          if (j < NY)
            zjp = abs (Z(j+1,i) );
            if (zjp < big)
              wgt = wgt + 1.0;
              zsum = zsum + zjp;
              if (jm > 0)
                wgt = wgt + 4.0 * CAY;
                zsum = zsum + 2.0 * CAY * (zjm + zjp);
                end  % if
              if (j < NY-1)
                zjpp = abs (Z(j+2,i) );
                if (zjpp < big)
                  wgt = wgt + CAY;
                  zsum = zsum - CAY * (zjpp - 2.0*zjp);
                  end  % if
                end  % j < NY-1
              end  % if zjp < big
            end  % if j < NY
 
          dz = zsum / wgt - z00;
          npg = npg + 1;
          dzrms = dzrms + dz*dz;
          if (abs (dz) > dzmax)  dzmax = abs (dz);  end
          Z(j,i) = z00 + dz * relax;
          end  % if z00 >= 0
        end  % if z00 < big
      end  % for j loop
    end  % for i loop
    

  if (LDEBUG >= 1)
    for (j=1:NY)
      fprintf (1, '\n2000:%i', j);
      fprintf (1, ' %g', Z(j,:) );
      end  % for each line of output.
    fprintf (1, '\n')
    end  % if debug output.

     % Shift data points zp progressively back to their proper places as 
     % the shape of surface z becomes evident. 
     %

%   if (mod (iter, 10) == 0) 
%     for (k=1:N)
%       if (knxt(k) < 0)  knxt(k) = -knxt(k);  end
%       if (knxt(k) > 0) 
%           
%         x = (XP(k) - X1) / DX;
%         i = fix (x + 1.5);
%         x = x + 1.0 - i; % (distance in x away from nearest gridpoint - Dana)
%         y = (YP(k) - Y1) / DY;
%         j = fix (y + 1.5);
%         y = y + 1.0 - j;
%         zpxy = ZP(k) + zbase;
%         z00 = abs (Z(j,i));
% 
%         zw = bigger;
%         if (i > 1)
%           zw = abs (Z(j,i-1) );
%           end  % if
%         ze = bigger;
%         if (i < NX) 
%           ze = abs (Z(j,i+1) );
%           end  % if
%         if (ze >= big)
%           if (zw < big)
%             ze = 2.0 * z00 - zw;
%            else 
%             ze = z00;
%             zw = z00;
%             end  % if
%          else      % if ze < big
%           if (zw >= big)
%             zw = 2.0 * z00 - ze;
%             end  % if
%           end  % if
% 
%         zs = bigger;
%         if (j > 1)
%           zs = abs (Z(j-1,i) );
%           end  % if
%         zn = bigger;
%         if (j < NY) 
%           zn = abs (Z(j+1,i) );
%           end  % if
%         if (zn >= big)
%           if (zs < big)
%             zn = 2.0 * z00 - zs;
%            else  
%             zn = z00;
%             zs = z00;
%             end  % if
%          else      % zn < big
%           if (zs >= big)
%             zs = 2.0 * z00 - zn;
%             end  % if
%           end  % if
% 
%         a = (ze - zw) * 0.5;
%         b = (zn - zs) * 0.5;
%         c = (ze + zw) * 0.5 - z00;
%         d = (zn + zs) * 0.5 - z00;
%         zxy = z00 + a*x + b*y + c*x*x + d*y*y;
%         delz = z00 - zxy;
%         delzm = derzm * (abs (x)*DX + abs (y)*DY) * 0.80;
%         if (delz > delzm)
%           delz = delzm;
%           end  % if
%         if (delz+delzm < 0)
%           delz = -delzm;
%           end  % if
%         zpij(k) = zpxy + delz;
%         end  % if knxt(k) > 0
%       end  % for k loop
% 
%     if (LDEBUG >= 1)
%       for (j=1:NY)
%         fprintf (1, '\n3400:%i', j);
%         fprintf (1, ' %g', Z(j,:) );
%         end  % for each line of output.
%       fprintf (1, '\n')
%       end  % if debug output.
%  
%     for (k=1:N)
%       if (knxt(k) > 0)
%         npt = 0;
%         zsum = 0.0;
%         i = fix ((XP(k) - X1) / DX + 1.5);
%         j = fix ((YP(k) - Y1) / DY + 1.5);
%         kk = k;
%         while (kk <= N  |  npt == 0)
%           npt = npt + 1;
%           zsum = zsum + zpij(kk);
%           knxt(kk) = -knxt(kk);
%           kk = -knxt(kk);
%           end  % while  (kk <= N)
%         if (npt > 0)  Z(j,i) = -zsum / npt;  end
%         end  % if knxt(k) > 0
%       end  % for k loop
%     end  % if (iter % 10 == 0)


     % Test for convergence.
 
  if (npg == 0)  break;  end
  dzrms = sqrt(dzrms/npg);
  root = dzrms / dzrmsp;
  dzrmsp = dzrms;
  dzmaxf = dzmax / zrange;
  eps_test = dzmaxf/(1.0 - root);
  if (lverbose == 1)
    fprintf (1, '  convergence: %i  %f %i %f  %f  %f\n', ...
             iter, dzmax, npg, dzrms, root, eps_test);
    end  % if lverbose
  if (mod (iter,10) == 2)
    dzrms8 = dzrms;
    end  % if
  if (mod (iter,10) == 0) 
    root = sqrt(sqrt(sqrt(dzrms/dzrms8)));
    if (root < 0.9999)
      if (dzmaxf/(1.0 - root) - eps <= 0)  break;  end
 
          % Improve the relaxation factor.
 
      if (mod(iter,20)*mod(iter,40)*mod(iter,60) == 0)
        if (relax - 1.0 - root < 0)
          tpy = (root + relax - 1.0) / relax;
          rootgs = tpy * tpy / root;
          relaxn = 2.0 / (1. + sqrt(1.0 - rootgs));
          if (iter ~= 60)
            relaxn = relaxn - 0.25 * (2.0 - relaxn);
            end  % if 
          if (relaxn > relax)  relax = relaxn;  end
          end  % if relax - 1.0 - root < 0
        end  % if mod(iter,20) == 0
      end  % if root < 0.9999
    end  % if mod (iter,10) == 0
  end  % for iter loop


if (lverbose == 1)
  if (iter > itmax)  iter = itmax;  end
  fprintf (1, '  Convergence = %g after %i iterations.\n', ...
           dzmaxf/(1.0-root), iter); 
  end  % if lverbose

     % Remove zbase from array z and return.
for (i=1:NX)
  for (j=1:NY)
    if (Z(j,i) < big)
      Z(j,i) = abs (Z(j,i) ) - zbase;
      end  % if
    end  % for j loop
  end  % for i loop
  
  if (LDEBUG >= 1)
    for (j=1:NY)
      fprintf (1, '\nGRID:%i', j);
      fprintf (1, ' %g', Z(j,:) );
      end  % for each line of output.
    fprintf (1, '\n');
    end  % if debug output.


return


     % Function set_new updates flags and parameters.
function [imnewt, jmnewt, nnewt] = set_new (n)
imnewt = 1;
jmnewt = 1;
nnewt = n + 1;
return;

