% LORENTZ_LSHAPE   Different versions of pressure broadened line shape
%
%    Calculates different versions of the pressure induced line shape. The 
%    most basic version is denoted as the Lorentz line shape.
%
%    The line shape can be expressed as
%      l = 1/pi * (f/f0)^prefac * ( dp/((f-f0)^2+dp^2) + dp/((f+f0)^2+dp^2) )
%    where the second term (including f+f0) is considered only if *mirror*
%    is set.
%
%    Default values correspond to the basic Lorentz shape. The van
%    Vleck-Weisskopf line shape is obtained with prefac=2 and mirror=true.
%
% FORMAT   l = lorentz_lshape( f, f0, dp [, prefac, mirror ] )
%        
% OUT   l       Line shape. Dimensions [f,dp]. 
% IN    f       Frequency vector.
%       f0      Centre frequency. Only scalar input allowed.
%       dp      Pressure broadened line width. Following standard definition,
%               which corresponds to FWHM/2. Can be a vector. 
% OPT   prefac  Exponent for (f/f0) term. Default is 0.
%       mirror  To consider the mirror transition at -f0. Default is false.

% 2006-11-21   Created by Patrick Eriksson.


function l = lorentz_lshape( f, f0, dp, varargin )
%
[prefac,mirror] = optargs( varargin, { 0, false } );
                                                                           %&%
                                                                           %&%
%- Check input                                                             %&%
%                                                                          %&%
rqre_nargin( 3, nargin )                                                   %&%
%                                                                          %&%
rqre_datatype( f, {@istensor1} );                                          %&%
rqre_datatype( f0, {@istensor1} );                                         %&%
rqre_datatype( dp, {@istensor0,@istensor1} );                              %&%
%                                                                          %&%
rqre_datatype( prefac, {@istensor1} );                                     %&%
rqre_datatype( mirror, {@isboolean} );                                     %&%


%- Allocate output
%
l = zeros( length(f), length(dp) );


if prefac == 0
  a = 1/pi;
else
  a = (f/f0).^prefac/pi;
end


for i = 1 : length(dp)

  if mirror
    l(:,i) = a .* ( dp(i) ./ ( (f-f0).^2 + dp(i)^2 ) + ...
                    dp(i) ./ ( (f+f0).^2 + dp(i)^2 ) );
  else
    l(:,i) = a .* ( dp(i) ./ ( (f-f0).^2 + dp(i)^2 ) );
  end
end