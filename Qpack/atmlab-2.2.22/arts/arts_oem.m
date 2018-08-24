% ARTS_OEM   Interface between *oem* and the ARTS forward model
%
%    See *arts_oem_init* for usage of this function.
%
% FORMAT   [R,y,J] = arts_oem( Q, R, x, iter )
%        
% OUT   R      Retrieval data structure. See above.
%       y      Calculated measurement vector.
%       J      Jacobian.
% IN    Q      Qarts structure, as returned by *arts_oem_init*.
%       R      Retrieval data structure. See above.
%       x      State vector.
%       iter   Iteration number. The case of x = xa is treated as iter=1. If 
%              another initial linearisation point is used, iter must be set
%              to >= 2.

% 2010-01-11   Started by Patrick Eriksson.


function [R,y,J] = arts_oem( Q, R, x, iter )


% Checks done *arts_oem_init* are not repeated here


%--- Map x to variables ----------------------------------------------

if iter > 1
  [Q,R] = arts_x2QR( Q, R, x );
end


%--- Run ARTS --------------------------------------------------------

if nargout == 3
  do_j  = 1;
  cfile = R.cfile_yj;
else
  do_j  = 0;
  cfile = R.cfile_y;
end
%
arts( cfile );
%
y = xmlLoad( fullfile( R.workfolder, 'y.xml' ) );
%
if do_j  
  
  % Load Jacobian
  J = xmlLoad( fullfile( R.workfolder, 'jacobian.xml' ) );

  % Jacobian calculated for x, but for "rel" it should be with respect to xa:
  % (as arts takes x as xa, no scaling needed for "logrel", and no scaling 
  %  needed for first calculation)
  if iter > 1 & ~isempty( R.i_rel )
    % The solution below sets an upper limit on the size of J at roughly 33%
    % of free memory. 
    % J(:,R.i_rel) =  J(:,R.i_rel) ./ repmat( x(R.i_rel)', size(J,1), 1 );
    % To avoid hitting the memory roof, we do this instead column-by-column.
    % And this turned out to be a faster option, at least for large J!
    for i = vec2row(R.i_rel)
      J(:,i) = J(:,i) / x(i);
    end
  end  
end


%- Add baseline
%
if iter > 1
  y = y + R.bl;
end

