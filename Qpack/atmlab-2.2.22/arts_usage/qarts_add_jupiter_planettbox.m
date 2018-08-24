% QARTS_ADD_JUPITER_PLANETTBOX   Includes planet toolbox study data for Jupiter
%
%  This function works as an interface to the data for the planet Jupiter
%  gathered during the ESA study, where ARTS was extended to cover other
%  planets.
%
%  Q.ATMOSPHERE_DIM must be set and determines if a 1D or 3D atmosphere is
%  created (2D is not handled).
%
%  The following fields are mandatory:
%    A.atmo
%    A.basespecies
%    A.h2ospecies
%    A.nh3species
%    A.ch4species
%    A.h2species
%    A.Necase
%  These variables and possible settings are described in the file 
%  arts/controlfiles/planetary_toolbox/DemoJupiterAtmo1D.arts.
%
%  All "zeropadding" variables are hard-coded to 1.
%
%  Wind and magnetic field parts are not yet handled by this function.
%  
%  The atmospheric grids can be cropped by the following (also mandatory) 
%  fields:
%    A.pmin
%    A.latmin   (not needed for 1D)
%    A.latmax   (not needed for 1D)
%    A.lonmin   (not needed for 1D)
%    A.lonmax   (not needed for 1D)
%  Grid points outside these values are removed (pmax hard-coded to a very
%  high value). Longitude limits can be inside [-360,360].
%
% FORMAT Q = qarts_add_jupiter_planettbox( A, Q, workfolder )
%
% OUT   Q          Modified Q
% IN    A          Atmosphere structure, see above.
%       Q          Original Q
%       workfolder Path to workfolder (not used, but an input is demanded)

% 2013-10-22   Created by Patrick Eriksson.

function Q = qarts_add_jupiter_planettbox( A, Q, workfolder )
%
rqre_datatype( A, { @isstruct } );
rqre_datatype( Q, { @isstruct, @ischar } );
rqre_datatype( workfolder, { @ischar,@isempty } );


arts_xmldata_path       = atmlab( 'ARTS_XMLDATA_PATH' );
if isnan( arts_xmldata_path )
  error('You need to set ARTS_XMLDATA_PATH to use this function.');
end


% Create the variables used by getatmo_jupiter.arts
%
Q.WSMS_BEFORE_ATMSURF{end+1} = 'IndexCreate( atmo )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'ArrayOfIndexCreate( basespecies )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'ArrayOfIndexCreate( h2ospecies )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'ArrayOfIndexCreate( nh3species )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'ArrayOfIndexCreate( ch4species )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'ArrayOfIndexCreate( h2species )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'ArrayOfIndexCreate( Necase )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'ArrayOfIndexCreate( windcase )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'NumericCreate( pmin )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'NumericCreate( pmax )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'NumericCreate( latmin )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'NumericCreate( latmax )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'NumericCreate( lonmin )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'NumericCreate( lonmax )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'IndexCreate( auxfield_zeropad )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'IndexCreate( vmr_zeropad )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'IndexCreate( interp_order )';


% Set the variables above
%
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( 'IndexSet( atmo, %d )',    A.atmo    );
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( 'IndexSet( auxfield_zeropad, %d )', 1 );
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( 'IndexSet( vmr_zeropad, %d )', 1 );
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( 'IndexSet( interp_order, %d )',  ...
                                                              A.interp_order );
%
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( 'NumericSet( pmin, %d )', A.pmin );
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( 'NumericSet( pmax, %d )', 1e99 );
%
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( ...
   'ArrayOfIndexSet( basespecies, [%s] )', vector2commalist( A.basespecies ) );
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( ...
     'ArrayOfIndexSet( h2ospecies, [%s] )', vector2commalist( A.h2ospecies ) );
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( ...
     'ArrayOfIndexSet( nh3species, [%s] )', vector2commalist( A.nh3species ) );
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( ...
     'ArrayOfIndexSet( h2ospecies, [%s] )', vector2commalist( A.h2ospecies ) );
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( ...
     'ArrayOfIndexSet( ch4species, [%s] )', vector2commalist( A.ch4species ) );
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( ...
     'ArrayOfIndexSet( h2species, [%s] )', vector2commalist( A.h2species ) );
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( ...
             'ArrayOfIndexSet( Necase, [%s] )', vector2commalist( A.Necase ) );
Q.WSMS_BEFORE_ATMSURF{end+1} = ...
                 'INCLUDE "planetary_toolbox/includes/common/createvars.arts"';
Q.WSMS_BEFORE_ATMSURF{end+1} = ...
                  'INCLUDE "planetary_toolbox/includes/jupiter/atmo_jupiter.arts"';
Q.WSMS_BEFORE_ATMSURF{end+1} = ...
               'INCLUDE "planetary_toolbox/includes/jupiter/getatmo_jupiter.arts"';


if Q.ATMOSPHERE_DIM == 1
  Q.WSMS_BEFORE_ATMSURF{end+1} = ...
                 'INCLUDE "planetary_toolbox/includes/common/getgrids_1D.arts"';
  Q.WSMS_BEFORE_ATMSURF{end+1} = ...
                 'INCLUDE "planetary_toolbox/includes/common/makeatmo1D.arts"';
elseif Q.ATMOSPHERE_DIM == 3
  Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( 'NumericSet( latmin, %d )', ...
                                                                   A.latmin );
  Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( 'NumericSet( latmax, %d )', ...
                                                                   A.latmax );
  Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( 'NumericSet( lonmin, %d )', ...
                                                                   A.lonmin );
  Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( 'NumericSet( lonmax, %d )', ...
                                                                   A.lonmax );
  Q.WSMS_BEFORE_ATMSURF{end+1} = ...
                'INCLUDE "planetary_toolbox/includes/common/getgrids_3D.arts"';
  Q.WSMS_BEFORE_ATMSURF{end+1} = ...
                 'INCLUDE "planetary_toolbox/includes/common/makeatmo3D.arts"';
else
  error( 'Only 1D and 3D atmosphere can be generated.' );
end



