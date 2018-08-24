% QARTS_ABSTABLE   Help preparing qarts for calculation of an absorption table
%
%   Sets automatically some Q-fields (see below) needed for calculation of
%   an absorption look-up table. The fields are set to match the selected
%   pressure grid and atmospheric temperature and VMR fields. 
%
%   The pressure grid is set to be identical to P_GRID, while temperature
%   and VMR profiles are set to the mean of max and min values. 
%
%   Default values for optional arguments should work for a single
%   calculation. Temperature and "non-linear" species variations are then
%   selected automatically to precisely cover the variation of specified
%   atmospheric fields.
%
%   The following fields must always be set:
%      Q.ATMOSPHERE_DIM
%      Q.P_GRID
%      Q.ABS_NLS
%
% FORMAT   Q = qarts_abstable( Q [, nt, dt, dnls ] )
%        
% OUT   Q      Q structure with some fields automatically set. These fields
%              are:
%                 ABSORPTION
%                 ABS_P
%                 ABS_T
%                 ABS_T_PERT 
%                 ABS_VMRS 
%                 ABS_NLS_PERT
% IN    Q      Original qarts settings.
% OPT   nt     Number of temperature variations. Default is 1.
%       dt     Maximum size of temperature variation. If set to be empty,
%              an automatic selection is made. Default is 50. This value 
%              has no impact if *dt* < 2.
%       dnls   Relative disturbances for "non-linear" species.
%              Default is [], that signifies no disturbances.
%              Otherwise required to be a vector, the vector values are used 
%              as variations. A value of 2 means here "twice the reference".

% 2007-08-22   Created by Patrick Eriksson.


function Q = qarts_abstable( Q, varargin )
%
[nt,dt,dnls] = optargs( varargin, { 1, 50, [] } );
                                                                           %&%
%= Check input                                                             %&%
%                                                                          %&%
rqre_nargin(1,nargin);                                                     %&%
%                                                                          %&%
rqre_datatype( Q, @isstruct );                                             %&%
%                                                                          %&%
if ~qarts_isset( Q.ATMOSPHERE_DIM )                                        %&%
  error( 'Q.ATMOSPHERE_DIM must be set' );                                 %&%
end                                                                        %&%
rqre_alltypes( Q.ATMOSPHERE_DIM, {@istensor0,@iswhole}, ...                %&%
                                           'Q.ATMOSPHERE_DIM' );           %&%
if ~qarts_isset( Q.P_GRID )                                                %&%
  error( 'Q.P_GRID must be set' );                                         %&%
end                                                                        %&%
if ~qarts_isset( Q.ABS_NLS )                                               %&%
  error( 'Q.ABS_NLS must be set' );                                        %&%
end                                                                        %&%
rqre_alltypes( nt, {@istensor0,@iswhole} );                                %&%
rqre_datatype( dt, {@istensor0} );                                         %&%
rqre_datatype( dnls, {@isempty,@istensor1} );                              %&%


%- Obtain atmospheric profiles
%
p_grid = qarts_get( Q.P_GRID );
%
if qarts_isset( Q.RAW_ATMOSPHERE )
  %
  [t_field,z_field,vmr_field] = arts_atmfields( Q ); 
else
  t_field   = qarts_get( Q.T_FIELD );
  vmr_field = qarts_get( Q.VMR_FIELD );
  %
  np = length( p_grid );
  if np~=size(t_field,1)  |  np~=size(vmr_field,2)
    error( 'Either T_FIELD or VMR_FIELD does not match P_GRID' );
  end
end



%- Compact to 1D, and possibly determine dt and dnls automatically
%
if Q.ATMOSPHERE_DIM == 1
  %
  t = t_field;
  if isempty(dt)
    dt = 0;
  end
  %
  vmr = vmr_field;
  %
else
  %
  t_max   = t_field;
  t_min   = t_field;
  vmr_max = vmr_field;
  vmr_min = vmr_field;
  %
  if Q.ATMOSPHERE_DIM == 3
    t_max   = max( t_max, [], 3 );
    t_min   = min( t_min, [], 3 );
    vmr_max = max( vmr_max, [], 4 );
    vmr_min = min( vmr_min, [], 4 );
  end
  if Q.ATMOSPHERE_DIM > 1
    t_max   = max( t_max, [], 2 );
    t_min   = min( t_min, [], 2 );
    vmr_max = max( vmr_max, [], 3 );
    vmr_min = min( vmr_min, [], 3 );
  end 
  %
  t   = ( t_max + t_min ) / 2;
  vmr = ( vmr_max + vmr_min ) / 2;
  %
  if isempty(dt)
    dt   = max([ max(t_max-t_min)/2 (nt-1)/2]);  % No idea to have steps < 1K
  end
end



%- Fill Q fields
%
Q.ABSORPTION = 'CalcTable';
%
Q.ABS_P      = p_grid;
%
Q.ABS_T      = t;
%
if dt == 0  |  nt < 2
  Q.ABS_T_PERT = [];
else
  Q.ABS_T_PERT = linspace( -dt, dt, nt )';
end  
%
Q.ABS_VMRS   = vmr;
%
if isempty( Q.ABS_NLS )  |  isempty( dnls )
  Q.ABS_NLS_PERT = [];
else
  if length(dnls) < 2
    error( 'The argument *dnls* can not be a scalar.' );
  else
    Q.ABS_NLS_PERT = dnls;
  end
end  



