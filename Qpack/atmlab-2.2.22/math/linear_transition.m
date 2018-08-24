% LINEAR_TRANSITION   Functrion having a linear transition between 0 and 1 
%
%   As the Heaviside function, but with extended transition between 0 and 1.
%   The output is 0 for the range [-Inf,xbp0], 1 for [xbp1,Inf] and a linear
%   transition between 0 and 1 for [xbp0,xbp1].
%
% FORMAT h = linear_transition(xbp0,xbp1,x)
%
% OUT   h      The weight for each point in x, a value between 0 and 1
% IN    xbp0   The breakepoint at 0
%       xbp1   The breakepoint at 1
%       x      The points where h shall be calculated

% 2014-01-15 Patrick Eriksson

function h = linear_transition(xbp0,xbp1,x)
  
h = max( min( (x-xbp0)/(xbp1-xbp0) , 1 ), 0 );
  