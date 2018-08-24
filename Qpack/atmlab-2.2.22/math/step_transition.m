% STEP_TRANSITION   A version of the Heaviside step function
%
%   The Heaviside function is mimicked, but with option to set where the
%   breakepoint between 0 and 1 takes place. This point is denoted as
%   *xbp*, and the output exactly at *xbp* is 0.5.
%
% FORMAT h = step_transition(xbp,x)
%
% OUT   h     The "function"
% IN    xbp   The breakpoint between 0 and 1
%       x     The points where h shall be calculated

% 2014-01-15 Patrick Eriksson

function h = step_transition(xbp,x)
  
h = repmat( 0.5, size(x) );

h(find(x<xbp)) = 0;
h(find(x>xbp)) = 1;

  