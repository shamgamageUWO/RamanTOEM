% TMATRIX   T-matrix scattering data, following ARTS
%
%    Basically an interface to ARTS for obtaining T-matrix data. 
%    For detailed information, such as options for *pshape* see: 
%       arts -d scat_meta_arrayAddTmatrix
%    
%    This function can handle combinations of shapes, types and sizes
%    (and then differs a bit from scat_meta_arrayAddTmatrix).
%    The variables that can be varied are N, pshape, ptype, pdiameter
%    and aspect_ratio. These variables must have length 1 or *np*, 
%    where *np* is the number of particles considered. If one or 
%    several of these variables have length 1, these data are assumed 
%    to be valid for all particles. For example, to compare scattering  
%    of ice and water for identical particles:
%
%      % set shape, type, diameter and aratio to scalar values
%      N(1) = complex_refr_indexFromFunc(fg,tg,@eps_water_liebe93,@sqrt);
%      N(2) = complex_refr_indexFromFunc(fg,tg,@eps_ice_liebe93,@sqrt);
%      D    = tmatrix( ...
%    
%    The grids are common for all particles.
%
% FORMAT   [D,M] = tmatrix( workfolder,f_grid,t_grid,za_grid,aa_grid,N, ...
%                       pshape,ptype,pdiameter,aspect_ratio)
%        
% OUT   D            Array of ARTS single scattering data
%       M            The "meta data" corresponding to D.
% IN    workfolder   A folder where temporary files can be stored.
%                    If set to [], a temporary folder is created.
%       f_grid       Frequency grid.
%       t_grid       Temperature grid.
%       za_grid      Zenith angle grid.
%       aa_grid      Azimuth angle grid.
%       N            Data of complex refractive index.
%       pshape       Particle shape. A string or a cell string array.
%       ptype        Particle type. A string or a cell string array.
%       pdiameter    Particle diameter.
%       aspect_ratio Particle aspect ratio.

% 2013-08-19   Created by Patrick Eriksson.

function [D,M] = tmatrix( workfolder,f_grid,t_grid,za_grid,aa_grid,N, ...
                      pshape,ptype,pdiameter,aspect_ratio)


%- Basic checks of input
%
rqre_datatype( f_grid, @istensor1 );
rqre_datatype( t_grid, @istensor1 );
rqre_datatype( za_grid, @istensor1 );
rqre_datatype( aa_grid, @istensor1 );
rqre_datatype( N, @isstruct );
rqre_datatype( pshape, { @ischar, @iscellstr } );
rqre_datatype( ptype, { @ischar, @iscellstr } );
rqre_datatype( pdiameter, @istensor1 );
rqre_datatype( aspect_ratio, @istensor1 );

%- Convert char input to cellstrs
%
if ischar( pshape ) 
  dummy = pshape;
  clear pshape;
  pshape{1} = dummy; 
  clear dummy;
end
if ischar( ptype )
  dummy = ptype;
  clear ptype;
  ptype{1} = dummy;  
  clear dummy;
end

%- How many particle types?
%
np = max( [ length(N), length(pshape), length(ptype), ...
            length(pdiameter), length(aspect_ratio) ] );

%- Check if length 1 or np
%
if ~( length(N)==1 | length(N)==np )
  error( 'In this case, length of *N* must be 1 or %d', np );
end
if ~( length(pshape)==1 | length(pshape)==np )
  error( 'In this case, length of *pshape* must be 1 or %d', np );
end
if ~( length(ptype)==1 | length(ptype)==np )
  error( 'In this case, length of *ptype* must be 1 or %d', np );
end
if ~( length(pdiameter)==1 | length(pdiameter)==np )
  error( 'In this case, length of *pdiameter* must be 1 or %d', np );
end
if ~( length(aspect_ratio)==1 | length(aspect_ratio)==np )
  error( 'In this case, length of *aspect_ratio* must be 1 or %d', np );
end

  
%- Create workfolder?
%
if isempty( workfolder )
  workfolder = create_tmpfolder;
  cu = onCleanup( @()delete_tmpfolder( workfolder ) );
end


%- Start defining cfile
%
S{1} = 'Arts2{';


%- Grids
%
filename = fullfile( workfolder, 'scat_f_grid.xml' ); 
xmlStore( filename, f_grid, 'Vector' );
S{end+1} = 'VectorCreate(scat_f_grid)';
S{end+1} = sprintf( 'ReadXML(scat_f_grid,"%s")', filename );
%
filename = fullfile( workfolder, 'scat_t_grid.xml' ); 
xmlStore( filename, t_grid, 'Vector' );
S{end+1} = 'VectorCreate(scat_t_grid)';
S{end+1} = sprintf( 'ReadXML(scat_t_grid,"%s")', filename );
%
filename = fullfile( workfolder, 'scat_za_grid.xml' ); 
xmlStore( filename, za_grid, 'Vector' );
S{end+1} = sprintf( 'ReadXML(scat_za_grid,"%s")', filename );
%
filename = fullfile( workfolder, 'scat_aa_grid.xml' ); 
xmlStore( filename, aa_grid, 'Vector' );
S{end+1} = sprintf( 'ReadXML(scat_aa_grid,"%s")', filename );
  

%- Create meta data
%
S{end+1} = 'scat_meta_arrayInit';
%
for i = 1 : np
  
  % Store complex_refr_index
  if i==1 | length(N) > 1
    filename = fullfile( workfolder, ...
                              sprintf('complex_refr_index_%d.xml',i) ); 
    xmlStore( filename, N(i), 'GriddedField3' );
    S{end+1} = sprintf( 'ReadXML(complex_refr_index,"%s")', filename );
  end
  
  % Expand meta data
  S{end+1} = 'scat_meta_arrayAddTmatrixOldVersion(';
  S{end+1} = '  complex_refr_index = complex_refr_index,';  
  if length(pshape) > 1
    S{end+1} = sprintf( '  shape              = "%s",', pshape{i} );
    desc{i}  = sprintf( '%s', pshape{i} );
  else
    S{end+1} = sprintf( '  shape              = "%s",', pshape{1} );
    desc{i}  = sprintf( '%s', pshape{1} );
  end
  if length(ptype) > 1
    S{end+1} = sprintf( '  particle_type      = "%s",', ptype{i} );
  else
    S{end+1} = sprintf( '  particle_type      = "%s",', ptype{1} );
  end
  if length(aspect_ratio) > 1
    S{end+1} = sprintf( '  aspect_ratio       = %.6d,', aspect_ratio(i) );
    desc{i}  = sprintf( '%s, aspect ratio %.3f', desc{i}, aspect_ratio(i) );
  else
    S{end+1} = sprintf( '  aspect_ratio       = %.6d,', aspect_ratio(1) );
    desc{i}  = sprintf( '%s, aspect ratio %.3f', desc{i}, aspect_ratio(1) );
  end  
  if length(pdiameter) > 1
    S{end+1} = sprintf( '  diameter_grid      = [%.6e],', pdiameter(i) );
    desc{i}  = sprintf( '%s, %.3f um', desc{i}, 1e6*pdiameter(i) );
  else
    S{end+1} = sprintf( '  diameter_grid      = [%.6e],', pdiameter(1) );
    desc{i}  = sprintf( '%s, %.3f um', desc{i}, 1e6*pdiameter(1) );
  end
  S{end+1} = '  scat_f_grid        = scat_f_grid,';
  S{end+1} = '  scat_T_grid        = scat_t_grid )';
end


%- T-matrix part and save
%
S{end+1} = 'scat_data_arrayFromMeta(';
S{end+1} = '  za_grid   = scat_za_grid,';
S{end+1} = '  aa_grid   = scat_aa_grid,';
S{end+1} = '  precision = 0.001 )';
S{end+1} = 'WriteXML( "ascii", scat_meta_array )';
S{end+1} = 'WriteXML( "ascii", scat_data_array )';


%- Create cfile
%
S{end+1} = '}';
cfile = fullfile( workfolder, 'cfile.arts' );
strs2file( cfile, S );


%- Run arts and load result
%
arts( cfile );
%
D = xmlLoad( fullfile( workfolder, 'cfile.scat_data_array.xml' ) );
%
for i = 1 : np
  D{i}.description = desc{i};
end  
  

if nargout > 1
  M = xmlLoad( fullfile( workfolder, ...
                                  'cfile.scat_meta_array.xml' ) );
end
