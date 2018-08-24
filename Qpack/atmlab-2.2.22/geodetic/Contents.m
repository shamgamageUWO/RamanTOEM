% Functions for handling geographical coordinate systems and reference
% ellipsoids.
%
% If nothing else is stated:
%
% Latitudes range [-90,90] and longitudes [-180,180].
%
% Cartesian coordinates follow the Earth-centred earth-fixed (ECEF) system.
% That is, the X axis passes (lat,lon)=(0,0), Y axis (0,90) and Z axis
% (90,x).
%
% Reference ellipsoids are specified by the equatorial radius (r) and its
% eccentricity (e), as a vector of length two: ellipsoid = [r,e]
% (this fits the definition used in Matlab's mapping toolbox)
%
%The local Line of sight angles are defined following 
% the EAST-NORTH-UP system:
%         za    aa
%         90    0   points towards north
%         90    90  points towards east
%         0     aa  points up

