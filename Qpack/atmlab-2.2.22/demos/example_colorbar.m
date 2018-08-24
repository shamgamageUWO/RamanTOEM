% EXAMPLE_COLORBAR
%
% Demonstrate how zerowhite and colorbarf can be used to create a
% filled contour plot with correct colorbar.
%
% 2004-04-07 Stefan Buehler


z = peaks;

[cmap,v] = zerowhite( z, [-8 -6 -4 -2 -1 1 2 4 6 8], 'nzp', 0.5 );

% Another example, with more levels and stronger blacking
% You have sometime to play around with upper and lower limit for color levels.
% Matlab does strange things with the colors!
%[cmap,v] = zerowhite( z, [-8:-2 -1.5:0.5:-0.5 0.5:0.5:1.5 2:8], 'nzp', 0.9 );


colormap(cmap);
[cout,H,cf] = contourf(z,v);
clabel(cout,H);
colorbarf(cout,H);

hold on;

[c,h] = contour(z,[0 0],'k--');
clabel(c,h);

hold off;

