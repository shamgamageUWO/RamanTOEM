% SPHDIST   The distance between two geograpgical positions
%
%    "As-the-crow-flies" distance between two points, specified by their
%    latitude and longitude. 
%
%    If the optional argument *r* is given, the distance in m is returned.
%    Otherwise the angular distance in degrees is returned.
%
% FORMAT   d = sphdist2(lat1,lon1,lat2,lon2[,r])
%        
% OUT   d      Distance, either in degress or m.
% IN    lat1   Latitude of position 1.
%       lon1   Longitude of position 1.
% IN    lat2   Latitude of position 2.
%       lon2   Longitude of position 2.
% OPT   r      The radius (common for both points).

% 2012-04-05   Created by Patrick Eriksson.

function d = sphdist(lat1,lon1,lat2,lon2,r)

% Equations taken from http://www.movable-type.co.uk/scripts/latlong.html
  
a = sind( (lat2-lat1)/2 ).^2 + cosd(lat1).*cosd(lat2).*sind( (lon2-lon1)/2 ).^2;
c = 2 * atan2( sqrt(a), sqrt(1-a) );

if nargin == 5
  d = r .* c;
else
  d = constants('RAD2DEG') * c;
end

