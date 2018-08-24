% XPATCH   A patch object defined at a set of x-coordinates
%
%    As YPATCH but for patches defined as a function of x.
%
% FORMAT   hp = ypatch(x,ylow,yhigh,c[,varargin])
%        
% OUT   hp         Handle to patch object.
% IN    x          X-coordinates.
%       ylow       Low y-value for each x.
%       yhigh      High y-value for each x.
%       c          Color specification.
% OPT   varargin   Arguments passed on to PATCH.

% 2003-03-09   Created by Patrick Eriksson.


function hp = xpatch(x,ylow,yhigh,c,varargin)


hp = patch( [ vec2col(x); flipud(vec2col(x)) ], ...
            [ vec2col(ylow); flipud(vec2col(yhigh)) ], ...
            c, varargin{:} );

set( hp, 'EdgeColor', 'none' );