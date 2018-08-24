% ROT2D   Two dimemnsion rotation
%
%    Performs a clockwise rotation in two dimensions.
%
% FORMAT   [x,y] = rot2D(x,y,alpha)
%        
% OUT   x       x-coordinate after rotation
%       y       y-coordinate after rotation 
% IN    x       x-coordinate before rotation
%       y       y-coordinate before rotation 
%       alpaha  Rotation angle [rad]

% 2006-03-26   Created by Patrick Eriksson


function [x,y] = rot2D(x,y,alpha)


A = [ cos(alpha) sin(alpha); -sin(alpha) cos(alpha) ];

b = A * [vec2row(x); vec2row(y)];

x = reshape( b(1,:), size(x) );
y = reshape( b(2,:), size(y) );