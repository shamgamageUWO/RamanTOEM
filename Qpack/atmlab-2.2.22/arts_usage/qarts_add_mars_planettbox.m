% QARTS_ADD_MARS_PLANETTBOX   Includes planet toolbox study data for Mars
%
%  This function works as an interface to the data for the planet Mars 
%  gathered during the ESA study, where ARTS was extended to cover other
%  planets.
%
%  Q.ATMOSPHERE_DIM must be set and determines if a 1D or 3D atmosphere is
%  created (2D is not handled).
%
%  The following fields are mandatory:
%    A.Ls
%    A.daytime
%    A.dust
%    A.solar
%    A.interp_order
%    A.basespecies
%    A.ch4species
%    A.h2ospecies
%    A.Necase
%  These variables and possible settings are described in the file 
%  arts/controlfiles/planetary_toolbox/DemoMarsAtmo1D.arts.
%
%  All "zeropadding" variables are hard-coded to 1.
%
%  Wind fields are included by setting A.wind_u, A.wind_v and A.wind_w
%  to true, respectively. Default is false.
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
% FORMAT Q = qarts_add_mars_planettbox( A, Q, workfolder )
%
% OUT   Q          Modified Q
% IN    A          Atmosphere structure, see above.
%       Q          Original Q
%       workfolder Path to workfolder (not used, but an input is demanded)

% 2013-10-03   Created by Patrick Eriksson.

function Q = qarts_add_mars_planettbox( A, Q, workfolder )
%
rqre_datatype( A, { @isstruct } );
rqre_datatype( Q, { @isstruct, @ischar } );
rqre_datatype( workfolder, { @ischar,@isempty } );


arts_xmldata_path       = atmlab( 'ARTS_XMLDATA_PATH' );
if isnan( arts_xmldata_path )
  error('You need to set ARTS_XMLDATA_PATH to use this function.');
end


% Create the variables used by getatmo_mars.arts
%
Q.WSMS_BEFORE_ATMSURF{end+1} = 'IndexCreate( Ls )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'IndexCreate( daytime )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'IndexCreate( dust )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'IndexCreate( solar )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'ArrayOfIndexCreate( basespecies )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'ArrayOfIndexCreate( h2ospecies )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'ArrayOfIndexCreate( ch4species )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'ArrayOfIndexCreate( Necase )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'ArrayOfIndexCreate( vertwind )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'ArrayOfIndexCreate( NSwind )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'ArrayOfIndexCreate( EWwind )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'NumericCreate( latmin )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'NumericCreate( latmax )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'NumericCreate( lonmin )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'NumericCreate( lonmax )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'IndexCreate( auxfield_zeropad )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'IndexCreate( vmr_zeropad )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'IndexCreate( interp_order )';


% Set the variables above
%
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( 'IndexSet( Ls, %d )',      A.Ls      );
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( 'IndexSet( daytime, %d )', A.daytime );
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( 'IndexSet( dust, %d )',    A.dust    );
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( 'IndexSet( solar, %d )',   A.solar   );
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( 'IndexSet( interp_order, %d )',  ...
                                                              A.interp_order );
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( 'IndexSet( vmr_zeropad, %d )', 1 );
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( 'IndexSet( auxfield_zeropad, %d )', 1 );
%
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( ...
   'ArrayOfIndexSet( basespecies, [%s] )', vector2commalist( A.basespecies ) );
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( ...
     'ArrayOfIndexSet( ch4species, [%s] )', vector2commalist( A.ch4species ) );
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( ...
     'ArrayOfIndexSet( h2ospecies, [%s] )', vector2commalist( A.h2ospecies ) );
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( ...
             'ArrayOfIndexSet( Necase, [%s] )', vector2commalist( A.Necase ) );

Q.WSMS_BEFORE_ATMSURF{end+1} = ...
                 'INCLUDE "planetary_toolbox/includes/common/createvars.arts"';
Q.WSMS_BEFORE_ATMSURF{end+1} = ...
                    'INCLUDE "planetary_toolbox/includes/mars/atmo_mars.arts"';
Q.WSMS_BEFORE_ATMSURF{end+1} = ...
                 'INCLUDE "planetary_toolbox/includes/mars/getatmo_mars.arts"';

% Set pmin and pmax
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( 'NumericSet( pmin, %d )', A.pmin );
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( 'NumericSet( pmax, %d )', 1e99 );


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


Q.WSMS_BEFORE_ATMSURF{end+1} = 'ArrayOfIndexSet( vertwind, [0] )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'ArrayOfIndexSet( EWwind, [0] )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'ArrayOfIndexSet( NSwind, [0] )';

u_wind = safegetfield( A, 'wind_u', 0 );
v_wind = safegetfield( A, 'wind_v', 0 );
w_wind = safegetfield( A, 'wind_w', 0 );

if u_wind | v_wind | w_wind
  Q.WSMS_BEFORE_ATMSURF{end+1} = ...
                 'INCLUDE "planetary_toolbox/includes/mars/getwind_mars.arts"';
  if u_wind 
    Q.WSMS_BEFORE_ATMSURF{end+1} = 'Copy( rawfield, wind_u_raw )';
    if Q.ATMOSPHERE_DIM == 1
      Q.WSMS_BEFORE_ATMSURF{end+1} = ...
                'INCLUDE "planetary_toolbox/includes/common/makefield1D.arts"';
    else
      Q.WSMS_BEFORE_ATMSURF{end+1} = ...
                'INCLUDE "planetary_toolbox/includes/common/makefield3D.arts"';
    end
    Q.WSMS_BEFORE_ATMSURF{end+1} = 'Copy( wind_u_field, finalfield )';
  end
  if v_wind 
    Q.WSMS_BEFORE_ATMSURF{end+1} = 'Copy( rawfield, wind_v_raw )';
    if Q.ATMOSPHERE_DIM == 1
      Q.WSMS_BEFORE_ATMSURF{end+1} = ...
                'INCLUDE "planetary_toolbox/includes/common/makefield1D.arts"';
    else
      Q.WSMS_BEFORE_ATMSURF{end+1} = ...
                'INCLUDE "planetary_toolbox/includes/common/makefield3D.arts"';
    end
    Q.WSMS_BEFORE_ATMSURF{end+1} = 'Copy( wind_v_field, finalfield )';
  end
  if w_wind 
    Q.WSMS_BEFORE_ATMSURF{end+1} = 'Copy( rawfield, wind_w_raw )';
    if Q.ATMOSPHERE_DIM == 1
      Q.WSMS_BEFORE_ATMSURF{end+1} = ...
                'INCLUDE "planetary_toolbox/includes/common/makefield1D.arts"';
    else
      Q.WSMS_BEFORE_ATMSURF{end+1} = ...
                'INCLUDE "planetary_toolbox/includes/common/makefield3D.arts"';
    end
    Q.WSMS_BEFORE_ATMSURF{end+1} = 'Copy( wind_w_field, finalfield )';
  end
end




