% QARTS_ABS_SPECIES   Adds an absorption species to the Q and SX structures
%
%    The method modifies the fields ABS_SPECIES, ABS_NLS and J.ABS_SPECIES.
%    The field ATMOSPHERE_DIM must be set.
%
%    Example on adding a species, without jacobians:
%       Q = qarts_abs_species( Q, {'H2O-PWR93'}, 1 );
%
%    With jacobians:
%       [Q,SX] = qarts_gas_species( Q,{'O2-PWR98'},0,1,SX,D,p_grid,'vmr');
%
% FORMAT   [Q,SX] = q_abs_species( Q, tags [, nonlin, do_j, SX, D, grids, unit, 
%                                                            method, dx ] )
%        
% OUT   Q          Modified Q structure.
%       SX         Modified SX structure.
% IN    Q          Original Q structure.
%       tags       Tag names as cell string array.
% OPT   nonlin     Boolean for including as "non-liner" in absorption
%                  look-up table. Default is 0.
%       do_j       Flag to do jacobians. Default is 0. If 0, the variables
%                  below are not needed.
%       SX         Original SX structure.
%       D          Covariance definition. See *arts_covmat*.
%       grids      Retrieval grids, as an ArrayOfVector. 
%       unit       Retrieval unit ('rel', 'vmr' or 'nd'). Default is 'rel'.
%       method     Calculation method ('analytical' or 'perturbation').
%                  Default is 'analytical'.
%       dx         Size of perturbations. Ignored if *method* = 'analytical'.
%                  Default is 0.

% 2005-06-23   Created by Patrick Eriksson.


function [Q,SX] = ...
                qarts_abs_species(Q,tags,nonlin,do_j,SX,D,grids,unit,method,dx)


if nargin < 2  |  ( nargin > 2  &  nargin < 5 )
  error('Number of input arguments must = 2 or >= 6.');
end

%= Set defaults
%
nonlin_DEFAULT = 0;
do_j_DEFAULT   = 0;
unit_DEFAULT   = 'rel';
method_DEFAULT = 'analytical';
dx_DEFAULT     = 0;
%
set_defaults;


%= Check input
%
rqre_datatype( tags, {@iscellstr} );                                       %&%
rqre_datatype( do_j, {@isboolean} );                                       %&%
rqre_datatype( nonlin, {@isboolean} );                                     %&%


i = length(Q.ABS_SPECIES) + 1;


for j = 1 : length(tags)
  Q.ABS_SPECIES{i}{j} = tags{j};
end


if nonlin
  Q.ABS_NLS = { Q.ABS_NLS, arts_tgs_cnvrt(Q.ABS_SPECIES) };
end


if isstruct( Q.J )
  Q.J.ABS_SPECIES(i).DO = do_j;  
end


if do_j
  Q.J.ABS_SPECIES(i).UNIT   = unit;
  Q.J.ABS_SPECIES(i).METHOD = method;
  Q.J.ABS_SPECIES(i).DX     = dx;
  Q.J.ABS_SPECIES(i).GRID1  = grids{1};

  if Q.ATMOSPHERE_DIM >= 2
    Q.J.ABS_SPECIES(i).GRID2 = grids{2};

    if Q.ATMOSPHERE_DIM >= 3
      Q.J.ABS_SPECIES(i).GRID3 = grids{3};
    end
  end

  SX.ABS_SPECIES{i} = D;
end