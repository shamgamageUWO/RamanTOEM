% COLORSPEC   Extracts color specifications.
%
%    A help function to handle Matlab's treatment of colors. This function
%    returns the color map as *colormap*, but also the data range
%    corresponding to each color: *cranges*.
%
%    *cranges* is a matrix with two columns, with nas many rows as *cmap*.
%    Color i (row i in *cmap*) is used for the data range:
%      [cranges(i,1),cranges(i,2)[
%
% FORMAT   [cranges,cmap] = colorspec(h)
%        
% OUT   cranges   Color ranges. See above.
%       cmap      Color map, as returned by *colormap*.
% OPT   h         Axis hanlde. Default is *gca*.

% 2007-03-12   Created by Patrick Eriksson.


function [cranges,cmap] = colorspec(h)
  
if nargin == 0
  h = gca;
end

clims = caxis;
cmap  = colormap;

x = linspace( clims(1), clims(2), size(cmap,1)+1 );

cranges = [ [ -Inf x(2:end-1)]' [x(2:end-1) Inf]' ];

