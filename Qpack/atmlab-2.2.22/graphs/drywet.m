function cmap = drywet(varargin)

% colourmap with deserty colours for low and blueish colours for high
%
% IN
%
%   width   Relative width of the white region compared to the other
%           colours.  In the range (0, 1) where limit 0 means no white at
%           all and limit 1 means the colourmap is dominated by bright colours.
%           Defaults to 0.5.
%
% See also: zerobright

% http://en.wikipedia.org/wiki/Desert_sand_%28color%29

w = optargs(varargin, {0.5});

field_drap = [108, 84, 30];
%sand = [194, 178, 128];
%brightsand = [246, 237, 211];
%brightsand = [256, 234, 169];
brightsand = [256, 241, 195];
%antisky = [236, 163, 134];
%antisky = [236, 202, 188];
%wheat = [245, 222, 179];
white = [255, 255, 255];
sky_blue = [135, 206, 235];
midnight_blue = [25, 25, 112];

pos = 1+[0, 0.5-w/2, 0.5, 0.5+w/2, 1];

%pos = 1+[0, (0.5-w/2)/2, 0.5-w/2, 0.5, 0.5+w/2, 1-(0.5-w/2)/2, 1];

colours = [field_drap; brightsand; white; sky_blue; midnight_blue];
%colours = [field_drap; sand; white-0.01; white; white-0.01; sky_blue; midnight_blue];

cmap = interp1(pos, colours, linspace(1, max(pos), 256))/256;

end
