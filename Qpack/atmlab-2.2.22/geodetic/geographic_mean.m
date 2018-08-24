function [mean_lat, mean_lon] = geographic_mean(lat, lon)

% Calculate mean position for set of coordinates
%
% For each row of lat/lon, calculate mean position.
%
% TODO: consider altitude.  Currently takes fixed Earth radius.  Not very
% precise, but good enough for many applications.
%
% FORMAT
%
%   [mean_lat, mean_lon] = geometric_mean(lat, lon)
%
% IN
%
%   lat    Matrix of latitudes (degrees)
%   lon    Matrix of longitudes (degrees), must have same size as lat
%
% OUT
%
%   mean_lat    Mean vector of latitudes (degrees) for each row of lats
%   mean_lon    Mean vector of longitudes (degrees) for each row of lons

if ~isequal(size(lat), size(lon))
    error(['atmlab:' mfilename ':invalid'], 'lat/lon must have same size');
end

[x, y, z] = geodetic2cart(0, lat, lon);
[~, mean_lat, mean_lon] = cart2geodetic(mean(x, 2), mean(y, 2), mean(z, 2));

end
