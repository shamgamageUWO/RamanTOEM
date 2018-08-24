% ARTS_RSLOPE_CROSSING   Testing of arts' rslope_crossing function
%
%    The function is a Matlab implementation of the rslope_crossing function
%    found in ppath.cc of arts. The output *dlat* is as calculated inside
%    arts, while *dlat2* is a comparison value that should be accurate with
%    a precision of 0.0001 deg. The search for *dlat2* is limited to [-1,1].
%    The search for dlat2 can return the crossing on the other side of a
%    tangent point.
%
% FORMAT   [dlat,dlat2] = arts_rslope_crossing(rp,za,r0,c)
%        
% OUT   dlat   Latitude difference calculated by Taylor expansion.
%       dlat2  Same as *dlat*, but calculated by trail and error.
% IN    rp     Ppath radius.
%       za     Ppath zenith angle.
%       r0     Radius of level at latitude matching *rp*
%       c      Slope of level [m/deg]

% 2012-02-21   Created by Patrick Eriksson.

function [dlat,dlat2] = arts_rslope_crossing(rp,za,r0,c)

  DEG2RAD = constants( 'DEG2RAD' );
  RAD2DEG = constants( 'RAD2DEG' );
  
  % If r0=rp, numerical inaccuracy can give a false solution, very close
  % to 0, that we must throw away.
  dmin = 0;
  if( r0 == rp )
    dmin = 1e-12;
  end
  
  % The nadir angle in radians, and cosine and sine of that angle
  beta = DEG2RAD * ( 180 - abs(za) );
  cv = cos( beta );
  sv = sin( beta );

  % Convert slope to m/radian and consider viewing direction
  c = RAD2DEG*c;
  if( za < 0 )
    c = -c;
  end
  
  % The vector of polynomial coefficients
  p = zeros(5,1);
  %
  p(5) = ( r0 - rp ) * sv;
  p(4) = r0 * cv + c * sv;
  p(3) = -r0 * sv / 2 + c * cv;
  p(2) = -r0 * cv / 6 - c * sv / 2;
  p(1) = -c * cv / 6;

  % Calculate roots of the polynomial
  rs = roots(p);
  
  % Find the smallest root with imaginary part = 0, and real part > 0.
  %
  dlat = 1.571;
  %
  for i = 1 : length(rs)
    if isreal(rs(i))  &  rs(i) < dlat  &  rs(i) > dmin
      dlat = rs(i); 
    end
  end  
  
  % Convert back to degrees
  % Change also sign if zenith angle is negative
  if( dlat < 1.57 )
    
    dlat = RAD2DEG * dlat;
  
    if za < 0
      dlat = -dlat; 
    end
  else
    dlat = 99e99;
  end
  
  
  % Second solution
  if nargout > 1
    
    c = DEG2RAD * c;
    dr = Inf;
  
    for latt = -1 : 0.0001 : 1

      r1  = r0 + c*latt;
      r2  = (rp*sind(abs(za))) / sind(abs(za)-latt);
      drt = abs( r1 - r2 );
      %
      if drt < dr
        dr    = drt;
        dlat2 = latt;
      end
    end
    
    if za < 0
      dlat2 = -dlat2;
    end

    if dr > 1
      dlat2 = 99e99;
      fprintf( 'Closest distance for dlat2 = %.2f\n', dr );
    end
  end
