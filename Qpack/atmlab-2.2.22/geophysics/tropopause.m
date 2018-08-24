% TROPOPAUSE   Determines the tropopause height 
%
%    The WMO definition of the tropopause: "The lowest level at which the lapse
%    rate decreases to 2 C/km or less, provided that the average lapse rate
%    between this level and all higher levels within 2 km does not exceed 
%    2 C/km." 
%
%    This function makes a simplified search of this altitude. Only the part
%    "The lowest level at which the lapse rate decreases to 2 C/km" is here
%    considered. More precisely, the function returns the lowest altitude with a
%    local lapse rate below 2 K/km, inside the range limited of *zmin* and
%    *zmax*. If the lapse rate limit is outside this range, z is set to to
%    either *zmin* or *zmax* (depending on size of lapse rate between (*zmin*
%    and *zmax*).
%
%    The function works for smooth (climatological) profiles, but can not
%    be applied on structured temperature profiles.
%
%    The "columns" (dim 1) of *Z* and *T* are taken as profiles for different
%    locations. *Z* and *T* can have a dimensionality <= 3.
%
% FORMAT   z = tropopause(Z,T[,zmin,zmax,lrlim])
%        
% OUT   z       Row vector with tropopause heights.
% IN    Z       Altitude vectors.
%       T       Temperature profiles.
% OPT   zmin    Lowest possible altitude for tropopause. Default is 6 km.
%       zmax    Highest possible altitude for tropopause. Deafult is 20 km.

% 2007-03-01   Created by Patrick Eriksson


function z = tropopause(Z,T,varargin)
%
[zmin,zmax] = optargs( varargin, { 6e3, 20e3 } );

%-- Hard coded values
%
lrlim = 2;   % Lapse rate limit. WMO definition corresponds to 2
                                                                           %&%
                                                                           %&%
%- Check input                                                             %&%
%                                                                          %&%
rqre_nargin( 2, nargin )                                                   %&%
%                                                                          %&%
rqre_datatype( Z, {@istensor3} );                                          %&%
rqre_datatype( T, {@istensor3} );                                          %&%
%                                                                          %&%
rqre_datatype( zmin, {@istensor0} );                                       %&%
rqre_in_range( zmin, 0, 20e3 );                                            %&%
rqre_datatype( zmax, {@istensor0} );                                       %&%
rqre_in_range( zmax, 0, 20e3 );                                            %&%
%                                                                          %&%
if any( size(Z) ~= size(T) )                                               %&%
  error( 'Mismatch in size between *Z* and *T*.' );                        %&%
end                                                                        %&%
if any( Z(1,:,:) > zmin )                                                  %&%
  error( 'Not all altitide profiles cover *zmin*.' );                      %&%
end                                                                        %&%
if any( Z(end,:,:) < zmax )                                                %&%
  error( 'Not all altitide profiles cover *zmax*.' );                      %&%
end                                                                        %&%



%- Allocate output variables
%
n    = [ size( Z ) 1 ];   % To ensure that length(n)>= 3
np   = n(1);
n(1) = 1;
%
z  = repmat( NaN, n );
t0 = repmat( NaN, n );


for i2 = 1:n(2)
  for i3 = 1:n(3)
    
    %- Calculate lapse rate between grid points
    %
    zp = edges2grid( Z(:,i2,i3) );
    lr = -1e3 * ( diff(T(:,i2,i3)) ./ diff(Z(:,i2,i3)) );
    
    %- Find part inside [zmin,zmax]
    %
    ind = find( zp >= zmin  &  zp <= zmax );
    %
    % Expand one step in each direction, to cover zmin and zmax 
    ind = max([1 ind(1)-1]) : min([np-1 ind(end)+1]);
    
    % Find lowest point below *lrlim*
    %
    ip = min(find(lr(ind)<2 ));
      
    %- Pick out altitude
    %
    if isempty(ip)
      z(i2,i3) = zmax;
    elseif ip == 1
      z(i2,i3) = zmin;
    else
      ind      = ind( [ ip + [-1 0] ] );
      z(i2,i3) = interp1( lr(ind), zp(ind), lrlim );
    end
    
  end
end



