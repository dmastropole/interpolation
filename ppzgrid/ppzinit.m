% Function ppzinit
% Function ppzinit is used to do the preliminary housekeeping for the
% Matlab implementation of the GMT implementation of the C language 
% implementation of the Fortran language implementation of the Plot-Plus
% gridding program zgrid.  Lest this appear to be plagiarism on a 
% massive scale, it should be noted it was only plagiarized once way
% back in the beginning and the rest has merely been internal manipulation.
%
% Usage:  [Z, grd_struct] = ppzinit (mymat, command)
%    mymat     - is a three column matrix containing the randomly spaced
%                observation triplets {x, y, z}
%    command   - is the GMT style command.  Some of the options are 
%                detailed below.
%                If the command begins with the identifier 'WIN' the
%                user will be presented with a graphical user interface.
%
%       command arguments:  -I<dx>[/<dy>]  -R<west/east/south/north> 
%                  [-E<empty>/[<mask_val>]]  [-C<eps> ]  [-M<mask_file> ]
%                  [-N<max_iter>] [-S<search_radius> ] [-T<tension> ]
%                  [-V ] 
%          Required:
%             -I sets the grid spacing for the grid.
%             -R specifies the min/max coordinates of data region in user units.
%          Optional:
%             -E value to use for empty nodes [Default is Nan].
%                If mask value not specified, default = <empty>.
%             -C set the convergence criteria epsilon.  [0.002]
%             -M specify multi-polygon format masking file.
%                Polygon separating headers may specify ['INSIDE']
%                or 'OUTSIDE' immediately after the '>' character.
%                A 'C'|'c' immediately after the '>' character indicates 
%                cell mode specification.  In this mode the {x y <mask>}
%                triplet is given.
%                The <mask> value, if given, is 1 (default) for masking.
%                A zero (0) value causes the cell to be unmasked.
%                NOTE:  Some words about masking.  Very powerful, and unlike
%                GMT which masks after the grid is generated, here the 
%                masking is done prior to the computation and carried through.
%                It comes with a price.  Example:
%                5776 records, 0.1 km resolution along bottom took 90 sec
%                to apply the mask.  But the Delta X grid spacing was only
%                2 km.  So by sub-sampling the mask to 2 km resolution
%                the time was reduced to 7 seconds.  Further, the X range
%                only went out to 200 km, not 577.  So cutting the mask
%                back to 200km further reduced the time to 4.5 sec.  So be
%                intelligent in applying the mask.  That said, masking is
%                often better than leaving it blank.  Blank, i.e. no data,
%                regions tend to introduce edge effects, especially 
%                noticeable in the computation of the DZ field and the 
%                resulting convergence.  Left blank, the above analysis 
%                went through the default 100 iterations at about 1 sec per
%                iteration.  Using the mask allowed convergence in 40 
%                passes.
%             -N set the max convergence iterations.  [100]
%             -S set the search radius, in integer grid intervals => 1.
%                If no data is within range of a node it is set to empty.
%                Default is -S5
%             -T adds tension to gridding procedure; range [0 -> infinity].
%                A zero value gives a Lagrangian effect with tent-pole like
%                behavior around data points.  Higher values give a spline
%                effect with a smoother field but the possibility of spurious
%                peaks or valleys.
%                A value of 5 is normal and is the default.
%             -V Run in verbose mode [OFF].
% Returns:
%    Z         - the gridded array of z values at the nodes specified
%                by the values in the structure.
%    grd_struct- is a structure containing elements which define the grid.
%                It simplifies the subsequent use of ppsmooth and may also
%                be used to generate a meshgrid. 
%                struct ('x_min', xmin, ...
%                        'x_max', xmax, ...
%                        'y_min', ymin, ...
%                        'y_max', ymax, ...
%                        'x_inc', DX, ...
%                        'y_inc', DY, ...
%                        'nx', NX, ...
%                        'ny', NY, ...
%                        'missing', empty, ...
%                        'masked', mask_val);
%
%
%


function [Z, grd_struct] = ppzinit (mymat, command)


     % Because this is not a standalone program I don't like using
     % global as it may conflict with something else.  I also don't
     % like passing lots of arguments.  In this particular application
     % the array Z is the only parameter that goes both ways;  everything
     % else is just input.  I toyed with the idea of making things
     % unique globals, then just setting before calling the gridding
     % function and reassigning locally.  It looks kludgey, probably
     % because it is.  I've settled for just stuffing things
     % in a structure and then unwinding  to local variables in the 
     % function.  Not elegant but ...

 
     % Some initialization and defaults for now.
program_id = 'ppzinit';
disp (['  Entering program '  program_id]);
LDEBUG = 0;
zbig = 1.0E+35;
zmask = 1.1E+35;

eps_default = 0.002;
empty_default = nan;
mask_val_default = nan;
itmax_default = 100;
popt_default = 0;    % init_method ...Changed from 0 to 1 - Dana, 2013
NRNG_default = 5;
CAY_default = 5.0;


n_mask = 0;
Z = [];
grd_struct = [];


     % Create separate arrays.  This is okay as long
     % as things don't get too big, in which case we'll
     % do it the other way.
     
xp = mymat(:,1);
yp = mymat(:,2);
zp = mymat(:,3);
fprintf (1, '    Data x range: %g   %g\n',  min(xp), max(xp) );
fprintf (1, '         y range: %g   %g\n',  min(yp), max(yp) );

     % Test to see if the command is requested through a user
     % window, via a WINDOW request.
test_command = upper (command);
if (strncmp (test_command, 'WIN', 3) == 1)
  def_tem = [eps_default  empty_default  mask_val_default  itmax_default];
  def_tem = [def_tem  popt_default  NRNG_default  CAY_default];
  command = 'RESET';
  while (strcmp (command, 'RESET') == 1)
    command = ppzinit_win (mymat, def_tem);
    disp (['  Generated command: '  command]);
    end  % while command reset.
  end  % if new command;
if (strcmp (command, 'CANCEL') == 1)
  return
  end  % if cancel.

     % Process the command.  There were several ways to go about this.
     % I inherently dislike passing lots of arguments in a call list
     % especially when most are optional.  So for compatibility with
     % GMT I will use the command line form.  So what's the next step.
     % I could replicate the GMT switch case stuff but this becomes
     % program specific anyway.  I don't see much saving so I'll
     % play with Matlab a bit and try something else.
     % How much validation is done is sort of arbitrary depending on
     % where I think things could go awry.
lc = length (command);
argerr = 0;
     % The -C convergence.
iarg = findstr (command, '-C');
if (~isempty (iarg) )
  [tema, retn] = sscanf (command(iarg+2:lc), '%f', 1);
  if (retn ~= 1)
    fprintf (2, '  *** ppzinit:  INVALID -C OPTION.\n');
    fprintf (2, '                DEFAULT VALUE USED (%f).\n',  eps_default);
    eps = eps_default;
   else
    if (tema(1) <= 0.0)
      fprintf (2, '  *** ppzinit:  INVALID -C OPTION <= 0.0.\n');
      argerr = 1;
     else
      eps = tema(1);
      end  % if
    end  % if retn check.
 else
  eps = eps_default;
  end  % if convergence argument.

     % The -E empty fill values.
iarg = findstr (command, '-E');
if (~isempty (iarg) )
  if (iarg+2 > lc)
    fprintf (2, '  *** ppzinit:  INVALID -E OPTION.\n');
    argerr = 1;
   elseif (command(iarg+2) == ' ')
    fprintf (2, '  *** ppzinit:  INVALID -E OPTION.\n');
    argerr = 1;

   else
    [eopt_str, retn] = sscanf (command(iarg+2:lc), '%s');
    if (eopt_str(1) == 'N'  |  eopt_str(1) == 'n')
      empty = nan;
     else
      [tema, retn] = sscanf (command(iarg+2:lc), '%f', 1);
      empty = tema(1);
      end  % NaN or value check.

    iarg_mask = findstr (eopt_str, '/');
    if (~isempty (iarg_mask) )
      if (iarg_mask+1 > length (eopt_str) )
        mask_val = empty;
       elseif (eopt_str(iarg_mask+1) == 'N'  |  eopt_str(iarg_mask+1) == 'n')
        mask_val = nan;
       else 
        tema = sscanf (eopt_str(iarg_mask+1:length(eopt_str)), '%f', 1);
        mask_val = tema(1);
        end % mask value
     else
      mask_val = empty;
      end  % if mask string.
    end  % if not void.

 else
  empty = empty_default;
  mask_val = mask_val_default;
  end  % if empty fill argument.

     % The -I delta, here required.
iarg = findstr (command, '-I');
if (~isempty (iarg) )
  [tema, retn] = sscanf (command(iarg+2:lc), '%f/%f', 2);
  if (retn ~= 2)
    if (retn == 1)
      x_inc = tema(1);
      y_inc = x_inc;
     else
      fprintf (2, '  *** ppzinit:  INVALID -I OPTION.\n');
      argerr = 1;
      end  % if
   else
    if (tema(1)*tema(2) <= 0.0)
      fprintf (2, '  *** ppzinit:  INVALID -I OPTION.\n');
      argerr = 1;
     else
      x_inc = tema(1);
      y_inc = tema(2);
      end  % if
    end  % if retn check.
 else
  fprintf (2, '  *** ppzinit: -I<dx/dy> ARGUMENT MUST BE SPECIFIED.\n');
  argerr = 1;
  end  % if delta argument.

     % The -M maskfile.
iarg = findstr (command, '-M');
if (~isempty (iarg) )
  [maskfile, retn] = sscanf (command(iarg+2:lc), '%s', 1);
  if (retn ~= 1)
    fprintf (2, '  *** ppzinit:  INVALID -M OPTION.\n');
    maskfile = [];
    argerr = 1;
    end  % if retn check.
 else
  maskfile = [];
  end  % if maskfile argument.

     % The -N iterations.
iarg = findstr (command, '-N');
if (~isempty (iarg) )
  [tema, retn] = sscanf (command(iarg+2:lc), '%i', 1);
  if (retn ~= 1)
    fprintf (2, '  *** ppzinit:  INVALID -N OPTION.\n');
    fprintf (2, '                DEFAULT VALUE USED (%i).\n',  itmax_default);
    itmax = itmax_default;
   else
    if (fix (tema(1) ) < 1)
      fprintf (2, '  *** ppzinit:  INVALID -N OPTION < 1.\n');
      argerr = 1;
     else
      itmax = fix (tema(1) ) ;
      end  % if
    end  % if retn check.
 else
  itmax = itmax_default;
  end  % if iterations argument.

     % The -P pre-field method.
iarg = findstr (command, '-P');
if (~isempty (iarg) )
  [tema, retn] = sscanf (command(iarg+2:lc), '%i', 1);
  if (retn ~= 1)
    fprintf (2, '  *** ppzinit:  INVALID -P OPTION.\n');
    fprintf (2, '                DEFAULT VALUE USED (%i).\n',  popt_default);
    init_method = popt_default;
   else
    tema = fix (tema);
    if (tema < 0  |  tema > 1)
      fprintf (2, '  *** ppzinit:  INVALID -P OPTION NOT [0,1]\n');
      argerr = 1;
     else
      init_method = tema;
      end  % if
    end  % if retn check.
 else
  init_method = popt_default;
  end  % if pre-field method argument.

     % The -R range, here optional.
iarg = findstr (command, '-R');
if (~isempty (iarg) )
  [range, retn] = sscanf (command(iarg+2:lc), '%f/%f/%f/%f', 4);
  if (retn ~= 4)
    fprintf (2, '  *** ppzinit:  INVALID -R OPTION.\n');
    argerr = 1;
   elseif (range(2) <= range(1)  | range(4) <= range(3) )
    fprintf (2, '  *** ppzinit:  INVALID -R OPTION.\n');
    argerr = 1;
    end  % if
 else
  range = [];
  end  % if range argument.

     % The -S search.
iarg = findstr (command, '-S');
if (~isempty (iarg) )
  [tema, retn] = sscanf (command(iarg+2:lc), '%i', 1);
  if (retn ~= 1)
    fprintf (2, '  *** ppzinit:  INVALID -S OPTION.\n');
    fprintf (2, '                DEFAULT VALUE USED (%i).\n',  NRNG_default);
    NRNG = NRNG_default;
   else
    if (fix (tema(1) ) < 1)
      fprintf (2, '  *** ppzinit:  INVALID -S OPTION < 1.\n');
      argerr = 1;
     else
      NRNG = fix (tema(1) ) ;
      end  % if
    end  % if retn check.
 else
  NRNG = NRNG_default;
  end  % if search argument.

     % The -T tension.
iarg = findstr (command, '-T');
if (~isempty (iarg) )
  [tema, retn] = sscanf (command(iarg+2:lc), '%f', 1);
  if (retn ~= 1)
    fprintf (2, '  *** ppzinit:  INVALID -T OPTION.\n');
    fprintf (2, '                DEFAULT VALUE USED (%f).\n',  CAY_default);
    CAY = CAY_default;
   else
    if (tema(1) < 0.0)
      fprintf (2, '  *** ppzinit:  INVALID -T OPTION < 0.0\n');
      argerr = 1;
     else
      CAY = tema(1);
      end  % if
    end  % if retn check.
 else
  CAY = CAY_default;
  end  % if search argument.

     % The -V verbose.
iarg = findstr (command, '-V');
if (~isempty (iarg) )
  lverbose = 1;
 else
  lverbose = 0;
  end  % if verbose argument.


if (argerr == 1)  return;  end

     % Find the points in the valid range.
     % Theoretically they have to specify a range for compatibility
     % with the old.  But to keep things in the normal Matlab
     % environment of doing things assume they may not and get the
     % actual range here.
if (isempty (range) )
  range(1) = min(mymat(:,1) );
  range(2) = max(mymat(:,1) );
  range(3) = min(mymat(:,2) );
  range(4) = max(mymat(:,2) );
  fprintf (1, '  Using range [%f %f  %f %f]\n', range);
  end  % if we needed to compute the range.

kind = find (mymat(:,1) >= range(1)  &  ...
             mymat(:,1) <= range(2)  &  ...
             mymat(:,2) >= range(3)  &  ...
             mymat(:,2) <= range(4) );
if (isempty(kind) )
  fprintf (2, ' *** NO POINTS IN SPECIFIED RANGE.\n')
  fprintf (2, '     [%f %f  %f %f]\n', range);
  return;
 else
  N = max (size (kind));
 end  % if no valid points and setting length.

     % Get the grid specifications.
one_or_zero = 1;
xinc2 = 0.5*x_inc;
yinc2 = 0.5*y_inc;
idx = 1.0/x_inc;
idy = 1.0/y_inc;
nx = round ((range(2) - range(1))*idx) + one_or_zero;
ny = round ((range(4) - range(3))*idy) + one_or_zero;
xleft = range(1) - xinc2;
xright = range(2) + xinc2;
ybottom = range(3) - yinc2;
ytop = range(4) + yinc2;

NX = nx;
NY = ny;
X1 = range(1);
Y1 = range(3);
DX = x_inc;
DY = y_inc;
Z = zeros (ny, nx);

     % Process mask file if requested.  This method is almost
     % tortuous to implement but let's get the original working
     % before I slip in some more efficient code.  Hopefully
     % the nodes and polygons are few or the machine is fast.
     %
  
mask_seg = 0;
if (~isempty (maskfile) ) 
          % For now it is defined as multi-segment.
  fp = fopen (maskfile, 'r');
  if (fp == -1)
    fprintf (1, '  %s: Cannot open requested masking file %s\n', ...
             program_id, maskfile);
    return 
    end  % if error opening mask file.

  if (lverbose) 
    fprintf (1, '  %s: Working on masking file %s\n', ...
             program_id, maskfile);
    end  % if verbose.

  mheader = fgets (fp);
  cell_mode = 0;
  if (mheader(2) == 'C'  |  mheader(2) == 'c')  cell_mode = 1;  end
          % By default it masks the inside of the polygon.
  mask_outside = 0;
  if (mheader(2) == 'O'  |  mheader(2) == 'o')  mask_outside = 1;  end
             
  moremask = fgets (fp);
  while (moremask ~= -1)
    n = 0;
    clear  xmask ymask
    mrange = [zbig -zbig zbig -zbig];
    while (moremask  ~= -1  &  moremask(1) ~= '>') 
          % Cell mode assumes points are at nodes.
      if (cell_mode)
        [xy_tem, count] = sscanf (moremask, '%f', 3);
        if (count < 2)
          fprintf (1, '%s: < 2 fields in masking file cell spec.\n', ...
                    program_id);
          return 
         elseif (count == 2) 
          cell_zval = 1;
          end  % if count checks.

        cell_zval = xy_tem(3);
        i = fix ((xy_tem(1) - X1) / DX + 1.5);
        if (i*(NX + 1 - i) > 0)
          j = fix ((xy_tem(2) - Y1) / DY + 1.5);
          if (j*(NY + 1 - j) > 0)
               % Are we masking? It should be 1.0
            if (cell_zval > 0.5)
              if (Z(j,i) < zbig)
                Z(j,i) = zmask*cell_zval;
                n_mask = n_mask + 1;
                end  % if
                    % Or unmasking. It better be 0.0
             else
              if (Z(j,i) >= zbig)
                Z(j,i) = zmask*cell_zval;
                n_mask = n_mask - 1;
                end  % if
              end % if unmasking.
            if (LDEBUG == 1)
              fprintf (1, '  CELL MASK>NODE: %f %f -> %i %i\n', ...
                       xy_tem(1), xy_tem(2), j, i);
              end  % if debug
            n = n + 1;
            mrange([1,3]) = min (mrange([1,3]), xy_tem([1,2])' );
            mrange([2,4]) = max (mrange([2,4]), xy_tem([1,2])' );
            end  % if valid j node.
          end  % if i valid node.

       else        % Not cell_mode so must be vertices.
        [xy_tem, count] = sscanf (moremask, '%f', 2);
        n = n + 1;
        xmask(n) = xy_tem(1);
        ymask(n) = xy_tem(2);
        if (LDEBUG == 1)
          fprintf (1, '  MASK POINT %i: %f %f\n', n, xmask(n), ymask(n));
          end  % if verbose
        end  % if not cell_mode. 
      moremask = fgets (fp);
      end  % while same segments. 


          % Here is were we do the mask check.  I repeat, this method
          % is being used to replicate the original zgrid procedure.
          % In the future one might look at the gmt/grdmask code and the
          % use of the non-zero_winding/out_edge_in routines to do the
          % polygon check.  Two very important notes.  The uniqueness
          % of this procedure is that it performs the masking before
          % the gridding, whereas gmt applies the mask afterward, or
          % more correctly does not consider it in the gridding routines
          % surface and nearneighbor.  Second, and also crucial, is
          % the array order.  GMT considers the grd format rows as
          % starting at ymax, i.e. top down like a monitor image.  The
          % zgrid routine is stored in the math convention from the
          % bottom up, i.e. first row at ymin.  I load them this
          % latter way and flip it later.  The zgrid is unidirectional
          % in that it uses a point in place smoothing and will not
          % produce the same results starting at a corner other that
          % xmin/ymin.  You can sometimes approach the same effect with
          % small convergence values but I repeat, the process is
          % not in general transmutable.
          %
          % This should be a good candidate for vectorization.
    mask_seg = mask_seg + 1;
    if (~cell_mode)
      for (i=1:NX)
        xnode = X1 + (i - 1) * DX;
        for (j=1:NY)
          if (Z(j,i) < zbig)
            ynode = Y1 + (j - 1) * DY;
            poly_inside = inpolygon (xnode, ynode, xmask, ymask);
          % The Matlab implementation of inpolygon returns 0.5 is the
          % point is on the line.  We consider this out of the polygon
          % for compatibility with the GMT version but I think the
          % other way gives better results..
            % if (poly_inside > 0)  poly_inside = 1;  end
            if (poly_inside < 1)  poly_inside = 0;  end

            if (mask_outside == 1) 
              Z(j,i) = zmask * (1 - poly_inside);
              if (poly_inside < 1) 
                n_mask = n_mask + 1;
                if (LDEBUG == 1)
                  fprintf (1, '  MASKED: %i %i  %f %f  %i\n', ...
                           i, j, xnode, ynode, poly_inside); 
                  end  % if debug
                end  % if poly_inside

             else 
              Z(j,i) = zmask *  poly_inside;
              if (poly_inside == 1)
                n_mask = n_mask + 1;
                if (LDEBUG == 1)
                  fprintf (1, '  MASKED: %i %i  %f %f  %i\n', ...
                           i, j, xnode, ynode, poly_inside); 
                  end  % if debug
                end  % if poly_inside.
             end  % if inside masking mode.
            end  % if valid point.

          end  % j for masking nodes.
        end  % i for masking nodes.
      mrange = [min(xmask)  max(xmask)  min(ymask)  max(ymask)];
      end  % if not cell_mode.

    if (lverbose)
      fprintf (1, '    Mask segment %i:  mode %i, %i records.\n', ...
               mask_seg, cell_mode, n);
      fprintf (1, '       Mask x range: %g   %g\n', mrange(1), mrange(2) );
      fprintf (1, '            y range: %g   %g\n', mrange(3), mrange(4) );
      fprintf (1, '       nodes masked: %i.\n', n_mask);
      end  % if verbose

    cell_mode = 0;
    if (moremask(1) == '>') 
      if (moremask(2) == 'C'  |  modemask(2) == 'c')  cell_mode = 1;  end
      mask_outside = 0;
      if (moremask(2) == 'O'  |  moremask(2) == 'o')  mask_outside = 1;  end
      end  % if moremask
    if (moremask ~= -1)  moremask = fgets (fp);  end
    end  % while moremask segments.

  fclose (fp);
  end % if using mask.

     % Do the gridding thing.
tem_struct = struct ('VOPT', lverbose, ...
                     'zbig', zbig, ...
                     'X1', X1,  'Y1', Y1, ...
                     'NX', NX,  'NY', NY, ...
                     'DX', DX,  'DY', DY, ...
                     'POPT', init_method, ...
                     'SOPT', NRNG, ...
                     'TOPT', CAY, ...
                     'COPT', eps, ...
                     'NOPT', itmax);
                 
[Z] = ppzgrid (mymat(kind,:), Z, tem_struct);


     % Reset missing or masked values.
n_empty = 0;
iempty = find (Z >= zbig);
if (isempty (iempty) )  n_empty = 0;
 else  n_empty = length (iempty);  end
     % Make sure both checks are done before changing anything. 
imask = find (Z >= zmask);
Z(iempty) = empty;
Z(imask) = mask_val;

n_set = NX*NY - n_empty;
n_empty = n_empty - n_mask;

  
if (lverbose == 1)
  fprintf (1, '  ppzgrid nodes: %i assigned; %i empty (', n_set, n_empty);
  if (isnan (empty) == 1) 
    fprintf (1, 'NaN');
   else 
    fprintf (1, '%g', empty);
    end  % if empty test
  fprintf (1, ') and %i masked (', n_mask);
   if (isnan (mask_val) )
    fprintf (1, 'NaN)\n');
   else 
    fprintf (1, '%g)\n', mask_val);
    end  % if mask test.
  end  % if verbose

     % I've eventually decided, for compatibility with ppsmooth,
     % to only return the structure.  But here they are if you want them.
  XVEC = X1 + (0:(NX-1))*DX;
  YVEC = Y1 + (0:(NY-1))*DY;
YVEC = YVEC';


grd_struct = struct ('x_min', XVEC(1), ...
              'x_max', XVEC(nx), ...
              'y_min', YVEC(1), ...
              'y_max', YVEC(ny), ...
              'x_inc', DX, ...
              'y_inc', DY, ...
              'nx', NX, ...
              'ny', NY, ...
              'missing', empty, ...
              'masked', mask_val);


return 


