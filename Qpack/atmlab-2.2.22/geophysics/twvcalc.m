% TWVCALC Total column water vapor
%
% Calculate the column water vapor by vertically integrating the
% water vapor density. 
% 
% For better accuarcy, first interpolate onto a fine vertical
% grid. The interpolation is linear in log(p). For humidity, the
% interpolation is done for RH, not VMR.
% 
% FORMAT twv = twvcalc(p, t, z, h2o, plogspacing, verbose)
%
% OUT    y     Total column water vapor in kg/m^2.
% IN     p     Vector of pressures [Pa]. Must be strictly decreasing.
%        t     Vector of temperatures [K].
%        h2o   Vater vapor [VMR]. 
%        plogspacing Max spacing (in log units) of the pressure grid on
%                    which we interpolate. Must not be too coarse,
%                    recommended value: 0.01
%        verbose     Output some information if this is present and
%                    not zero.
%
% 2007-08-06 Created by Stefan Buehler.

function twv = twvcalc(p, t, z, h2o, plogspacing, verbose)

%= Check input

rqre_nargin( 5, nargin );

rqre_datatype( p, {@istensor1} );                                           %&%
rqre_datatype( t, {@istensor1} );                                           %&%
rqre_datatype( z, {@istensor1} );                                           %&%
rqre_datatype( h2o, {@istensor1} );                                         %&%
rqre_datatype( plogspacing, {@istensor0} );                                 %&%

np = length( p );

log_p = log(p);

mindiff = min(abs(diff(log_p)));

if max(diff(p)) >= 0
  error('The pressure grid *p* must be strictly decreasing.');
end 

if length(t) ~= np
  error('The length of *p* and *t* must be identical.');
end 

if length(z) ~= np
  error('The length of *p* and *z* must be identical.');
end 

if min(diff(z)) <= 0
  error('The vector *z* must be strictly increasing.');
end 

if length(h2o) ~= np
  error('The length of *p* and *h2o* must be identical.');
end 

if plogspacing <= 0
  error('The value of *plogspacing* must be greater than zero.');
end 

if plogspacing > mindiff
  error(['The value of *plogspacing* is larger than the original log\n' ...
         'grid spacing, which is %g'], mindiff);
end 


%= Start to do some business now.

% Create fine log pressure grid:

% Construct a fine pressure grid. We go from max pressure to min pressure,
% in steps given by the desired spacing. 
log_p_fine = log_p(1):-plogspacing:log_p(end);

% Interpolate T, z, RH:
  
t_int = interp1( log_p, t, log_p_fine ); 
z_int = interp1( log_p, z, log_p_fine ); 

% RH (RH = p*VMR_H2O/e_eq_water(T)):
rh = p .* h2o ./ e_eq_water(t);

rh_int = interp1( log_p, rh, log_p_fine ); 

% H2O In VMR units:
h2o_int = rh_int .* e_eq_water(t_int) ./ exp(log_p_fine); 


% The gas constant of water vapor in J/(K kg), from Wallace&Hobbs,
% 2nd edition:
Rv = 461;

% The density is
% rho = p*h2o / (Rv*T)
% (from W&H)

rho = exp(log_p_fine) .* h2o_int ./ (Rv * t_int);


% Now vertically integrate rho:
twv = sum(layermean(rho) .* diff(z_int));

% Output some information, if verbose is set:
if exist('verbose','var') 
  if verbose ~= 0
    disp(sprintf('Original log_p spacing: %g',mindiff));
    disp(sprintf('No of old/new pressure grid points: %d/%d', ...
                 length(log_p), ...
                 length(log_p_fine)));
    disp(sprintf('Min and max RH: %g, %g', min(rh), max(rh)));
  end
end


% That's it, we are done.
