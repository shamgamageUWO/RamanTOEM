function r = circ_distd(x, y)

% circ_distd Degree-version of circ_dist
%
% As <a href="matlab:help circ_dist">circ_dist</a> but with degrees.
%
% $Id: circ_distd.m 6644 2010-11-12 19:50:07Z gerrit $

r = circ_rad2ang(circ_dist(circ_ang2rad(x), circ_ang2rad(y)));
