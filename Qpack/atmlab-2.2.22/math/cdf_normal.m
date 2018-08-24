% CDF_NORMAL   Normal cumulative distribution function (cdf).
%
%    Returns the cumulative distribution function for a normal distribution.
%
%    The function *normcdf* in the statistics toolbox performs the same
%    calculations.
%
% FORMAT   c = cdf_normal( x [, xm, si ] )
%        
% OUT   c   Cumulative distrubution function.
% IN    x   Data values.
% OPT   xm  Mean value. Default is 0.
%       si  Standard deviation. Default is 1.

% 2005-05-21   Created by Patrick Eriksson.


function c = cdf_normal(x,varargin)
%
[xm,si] = optargs( varargin, { 0, 1 } );


c = erf( (x-xm)/sqrt(2)/si )/2 + 0.5;
