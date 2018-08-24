% VMRUNIT   Automatic selection of VMR unit
%
%    Converts data in "true" VMR to ppt, ppb, ppm or leaves the data 
%    unchanged.
%
% FORMAT   [x,xtext,xunit] = vmrunit(x[,shorttext])
%        
% OUT   x           Data scaled to selected unit.
%       xtext       Text describing data: Volume mixing ratio [*xunit*]
%       xunit       String just holding selected unit.
% IN    x           VMR data.
% OPT   shorttext   Flag to use 'VMR' in *xtext* instead of longer version.
%                   Default is false.

% 2007-03-01   Created by Patrick Eriksson.

function [x,xtext,xunit] = vmrunit(x,shorttext)
  
if max( x ) < 999e-12
  xunit = 'ppt';
  xfac  = 1e12;
elseif max( x ) < 999e-9
  xunit = 'ppb';
  xfac  = 1e9;
elseif max( x( ) < 999e-6
  xunit = 'ppm';
  xfac  = 1e6;
else
  xfac  = 1;
  xunit = '-';
end


if xfac ~= 1
  x = xfac * x;  
end


if nargin >= 2  |  shorttext
  xtext = sprintf( 'VMR [%s]', xunit );
else
  xtext = sprintf( 'Volume mixing ratio [%s]', xunit );
end

  

  
