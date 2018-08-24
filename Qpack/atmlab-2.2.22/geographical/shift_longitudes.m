% SHIFT_LONGITUDES   Ensures that longitudes are inside defined range
%
%    The function shifts longitudes to match the defined longitude range.
%    Longitudes will end up in therange [lonlow,lonhigh], that must
%    be 360 degrees wide. 
%
%    There is no demand on input longitudes (except not beig NaN), the
%    function shifts n*360, where n is the suitable integer.
%
% FORMAT   lon = shift_longitudes(lon,lonlow,lonhigh)
%        
% OUT   lon       Longitudes, restricted to defined range.
% IN    lon       Original longitudes.
% OPT   lonlow    Lower limit for expected longitude range. Default is 0.
%       lonhigh   Upper limit for expected longitude range. Default is 360.

% 2008-03-17   Created by Patrick Eriksson.


function lon = shift_longitudes(lon,varargin)
%
[lonlow,lonhigh] = optargs( varargin, { 0, 360 } );

if atmlab( 'STRICT_ASSERT' )
  if lonhigh - lonlow ~= 360   
    error(['atmlab:' mfilename], ...
      'Longitude range (lonhigh-lonlow) must be 360 degrees.' );  
  end 

  if any(isnan(lon(:)))
    warning(['atmlab:' mfilename], ...
        'Found nans in longitude!');
  end
end


ind = find( lon < lonlow );
%
while ~isempty(ind)
  lon(ind) = lon(ind) + 360;
  ind = find( lon < lonlow );
end

ind = find( lon > lonhigh );
%
while ~isempty(ind)
  lon(ind) = lon(ind) - 360;
  ind = find( lon > lonhigh );
end

end
  
