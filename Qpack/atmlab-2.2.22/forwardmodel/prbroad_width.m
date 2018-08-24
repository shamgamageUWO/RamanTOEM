% PRBROAD_WIDTH   Pressure broadening line shape width
%
%    The pressure broadening width is calculated as:
%
%       dp = ga * p * (t0/t)^n
%
%    The full width at half maximum (FWHM) is 2*dp
% 
%    The constants ga, n and t0 must be scalars, while p and t can be vectors
%    or matrices (but then with matching size).
%
% FORMAT   dp = prbroad_width(ga,n,t0,p,t)
%        
% OUT   dd   Pressure broadened width [Hz]
% IN    ga   Broadening parameter [Hz/Pa]
%       n    Temperature exponent [-]
%       t0   Reference temperature [K]
%       p    Pressure [Pa].
%       t    Temperature [K].

% 2009-11-19   Created by Patrick Eriksson.

function dp = prbroad_width(ga,n,t0,p,t)
  
dp = ga * p .* (t0./t).^n;