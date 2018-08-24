% MAKE_CHECK_QARTS   Runs a number of qarts related scripts
%
%    The function runs some of the scripts in atmlab/demo, including in some
%    cases a comparsion to older results. The tests cover also Qpack2.
%
% FORMAT   make_check_qarts( [do_fortran] )
%
% OPT   do_fortran   Performs checks requiring compilation of ARTS
%                    with Fortran support. Default is false.

% 2005-06-21   Created by Patrick Eriksson.


function make_check_qarts( do_fortran )
%
if nargin == 0, do_fortran = false; end


%= Handle verbosity
%
va = atmlab( 'VERBOSITY', 0 );
vf = atmlab( 'FMODEL_VERBOSITY', 0 );


%= qarts_abstable_demo
%
try
  qarts_abstable_demo;
catch
  reset_verbosity( va, vf );
  fprintf('\n=== Error while running *qarts_abstable_demo* ===\n\n');
  rethrow(lasterror);
end
disp( 'Done: qarts_abstable_demo')



%= qarts_ppath_demo
%
try
  ppath = qarts_ppath_demo(600e3,113);
catch
  reset_verbosity( va, vf );
  fprintf('\n=== Error while running *qarts_ppath_demo* ===\n\n');
  rethrow(lasterror);
end
%
if abs( ppath.np ~= 120 )
  reset_verbosity( va, vf );
  error('Unexpected result from *qarts_ppath_demo*');
else
  disp( 'Done: qarts_ppath_demo')
end



%= qarts_demo 1 and 2
%
y0 = [ 4.115 27.94 ];
dy = 1e-2;
%
try
  [Q,f,y] = qarts_demo;
catch
  reset_verbosity( va, vf );
  fprintf('\n=== Error while running *qarts_demo* ===\n\n');
  rethrow(lasterror);
end
%
if any( abs( [min(y) max(y)] - y0 ) > dy )
  reset_verbosity( va, vf );
  error('Unexpected result from *qarts_demo*');
else
  disp( 'Done: qarts_demo')
end
%
y0 = [ 3.16 21.84 ];
try
  [Q,f,y] = qarts_demo2;
catch
  reset_verbosity( va, vf );
  fprintf('\n=== Error while running *qarts_demo2* ===\n\n');
  rethrow(lasterror);
end
%
if any( abs( [min(y) max(y)] - y0 ) > dy )
  reset_verbosity( va, vf );
  error('Unexpected result from *qarts_demo2*');
else
  disp( 'Done: qarts_demo2')
end



%= qarts_backend_demo
%
try
  [f,y] = qarts_backend_demo( 0, 0 );
catch
  reset_verbosity( va, vf );
  fprintf('\n=== Error while running *qarts_backend_demo* ===\n\n');
  rethrow(lasterror);
end
%
if abs( y(end) - 291.03 ) > 0.01
  reset_verbosity( va, vf );
  error('Unexpected result from *qarts_backend_demo*');
else
  disp( 'Done: qarts_backend_demo')
end



%= Qarts with DOIT
%
y0 = [ 152.78 -0.21 ];
dy = 1e-2;
%
try
  [Q,f,ztan,y_c,y] = qarts_scattering_demo( [], 'doit' );
catch
  reset_verbosity( va, vf );
  fprintf('\n=== Error while running *qarts_scatting_demo* ===\n\n');
  rethrow(lasterror);
end
%
if any( abs( y(end+[-1:0])' - y0 ) > dy )
  reset_verbosity( va, vf );
  error('Unexpected result from *qarts_scattering_demo* with DOIT.');
else
  disp( 'Done: qpack_scattering_demo with DOIT')
end


%= OEM
%
try
  X = arts_oem_demo;
catch
  reset_verbosity( va, vf );
  fprintf('\n=== Error while running *arts_oem_demo* ===\n\n');
  rethrow(lasterror);
end
%
disp( 'Done: arts_oem_demo')



%= Qpack2, 1 and 2
%
try
  L2 = qpack2_demo;
catch
  reset_verbosity( va, vf );
  fprintf('\n=== Error while running *qpack2_demo* ===\n\n');
  rethrow(lasterror);
end
%
if any( [L2.cost] > 1.2 )
  reset_verbosity( va, vf );
  error('Unexpected result from *qpack2_demo*');  
else
  disp( 'Done: qpack2_demo')
end
%
try
  L2 = qpack2_demo2;
catch
  reset_verbosity( va, vf );
  fprintf('\n=== Error while running *qpack2_demo2* ===\n\n');
  rethrow(lasterror);
end
%
if any( [L2.cost] > 1.2 )
  reset_verbosity( va, vf );
  error('Unexpected result from *qpack2_demo2*');  
else
  disp( 'Done: qpack2_demo2')
end


%= T-matrix
%
if do_fortran
try
  f_grid  = [ 100e9; 200e9 ];
  t_grid  = [ 275 : 25 : 350 ]';
  za_grid = [ 0 : 20 : 180 ]';
  aa_grid = [ 0 : 60 : 360 ]';
  N       = complex_refr_indexFromFunc( f_grid, t_grid, ...
                                        @eps_water_liebe93, @sqrt);  
  D = tmatrix( [], f_grid, t_grid, za_grid, aa_grid, N, ...
               'spheroidal', {'horizontally_aligned'}, 150e-6, [1.001;2] );
catch 
  reset_verbosity( va, vf );
  fprintf('\n=== Error while running *qpack2_demo2* ===\n\n');
  rethrow(lasterror);
end
%
disp( 'Done: Call of tmatrix.m')
end


%== Finished
%
reset_verbosity( va, vf );
disp( 'Ready !!!' )
%
return




%-----------------------------------------------------------------------------

function reset_verbosity( va, vf )
  atmlab( 'VERBOSITY', va );
  atmlab( 'FMODEL_VERBOSITY', vf );
return