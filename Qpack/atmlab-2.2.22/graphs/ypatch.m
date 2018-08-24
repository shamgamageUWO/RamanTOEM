% YPATCH   A patch object defined at a set of y-coordinates
%
%    Creates a patch object where the patch limits can be specified
%    as two functions of y. 
%
%    The edge of the patch is turned off.
%
%    A typical application of this function is to plot the confidence
%    interval around a vertical profile as a patch. If the estimated
%    vector *x*, defined at *y* has the uncertainty *si*, this can be
%    plotted as:
%       ypatch(x-si,x+si,y,[0.8 0.8 0.8]);
%       hold on
%       plot(x,y);
%
% FORMAT   hp = ypatch(xlow,xhigh,y,c[,varargin])
%        
% OUT   hp         Handle to patch object.
% IN    xlow       Low x-value for each y.
%       xhigh      High x-value for each y.
%       y          Y-coordinates.
%       c          Color specification.
% OPT   varargin   Arguments passed on to PATCH.

% 2003-03-09   Created by Patrick Eriksson.


function hp = ypatch(xlow,xhigh,y,c,varargin)


hp = patch( [ vec2col(xlow); flipud(vec2col(xhigh)) ], ...
            [ vec2col(y); flipud(vec2col(y)) ], ...
            c, varargin{:} );

set( hp, 'EdgeColor', 'none' );