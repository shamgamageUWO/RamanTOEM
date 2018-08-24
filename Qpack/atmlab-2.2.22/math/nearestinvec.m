% [ind,zn] = nearestinvec(z,zi)
%
%          Find the nearest value in a vector z to a given value zi
%
% FORMAT   [ind,zn] = nearestinvec(z,zi)
%
% OUT      ind  the index in vector z of closest value to zi
%          zn   the closest value in z to zi
% IN       z    the vector
%          zi   the value

% 2003-02-10   Created by Carlos Jimenez

function [ind,zn] = nearestinvec(z,zi);

[ aux, ind ] = min( abs( z -zi ) );
zn           = z( ind );

return





