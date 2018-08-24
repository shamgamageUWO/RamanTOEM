% SATVIEWDEPTH   Satellite viewing depth
%
%    Calculates how far down into the atmosphere "can see". The viewing
%    depth is based on the optical thickness, calculated from the top of
%    the atmosphere and downwards. The atmosphere top is defined by the 
%    highest altitude for which absorption is provided.
%
%    Refraction is not considered. In this case, the propagation path is
%    best described by the tangent altitude. Down-looking cases correspond
%    to negative tangent altitudes.
%
% FORMAT   zs = satviewdepth(z,Abs,ztan[,tau,Re])
%        
% OUT   zs    Viewing altitude, for each combination of frequency and tangent
%             altitudes ([ztan,f]).
% IN    z     Altitudes for absorption.
%       Abs   Absorption, where each column corresponds to an altitude.
%       ztan  Tangent altitude(s).
% OPT   tau   Definition of view limit, in optical thickness. Default is 1.
%       Re    Earth radius. Defualt is taken from *constants*.

% 2006-04-26   Created by Parick Eriksson.


function zs = satviewdepth(z,Abs,ztan,varargin)
%
[tau,Re] = optargs( varargin, { 1, constants('EARTH_RADIUS') } );
                                                                           %&%
                                                                           %&%
%- Check input                                                             %&%
%                                                                          %&%
rqre_nargin( 3, nargin )                                                   %&%
%                                                                          %&%
rqre_datatype( z, {@istensor1} );                                          %&%
rqre_datatype( Abs, {@istensor2} );                                        %&%
rqre_datatype( ztan, {@istensor1} );                                       %&%
%                                                                          %&%
rqre_datatype( tau, {@istensor0} );                                        %&%
rqre_in_range( tau, 0 );                                                   %&%
rqre_datatype( Re, {@istensor0} );                                         %&%
rqre_in_range( Re, 0 );                                                    %&%
%                                                                          %&%
if ~issorted(z)                                                            %&%
  error('Argument *z* must be a sorted increasing vector.');               %&%
end                                                                        %&%
if length(z) ~= size(Abs,2)                                                %&%
  error('Size mismatch between *z* and *Abs*.');                           %&%
end                                                                        %&%


%= Return argument
%
zs = zeros( length(ztan), size(Abs,1) );


%= Loop tangent altitudes
%
for j = 1:length(ztan)


  %= Matrix of cumulative optical depths
  %
  Tau = zeros( size(Abs) );
  %
  ind = 1:size(Abs,2);

  %= Loop downwards
  %
  for i = size(Abs,2)-1:-1:1

     %- Above tangent altitude
     %
     if z(i) > ztan(j)  
       l        = sqrt( (Re+z(i+1)).^2 - (Re+ztan(j))^2 ) - ...
                                         sqrt( (Re+z(i)).^2 - (Re+ztan(j))^2 );
       Tau(:,i) = Tau(:,i+1) +   l * (Abs(:,i+1)+Abs(:,i))/2; 

   
     %- Below tangent altitude
     %
     else
       l            = sqrt( (Re+z(i+1)).^2 - (Re+ztan(j))^2 );
       Tau(:,i)     = Tau(:,i+1) + l * (Abs(:,i+1)+interp1(z,Abs',ztan(j))')/2;
       ind          = i:ind(end);
       break
     end
  end


  %= Interpolate in tau
  %
  for i = 1:size(Abs,1)
    zs(j,i) = interp1( Tau(i,ind), z(ind), tau );
  end

end