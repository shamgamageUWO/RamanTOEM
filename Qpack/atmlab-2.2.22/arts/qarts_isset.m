% QARTS_ISSET   Determines if a Qarts field is set or not
%
%   Returns 0 if the data equal {}, and 1 otherwise.
%
% FORMAT   b = qarts_isset( qfield )
%        
% OUT   b        Boolean. 0 if {}, 1 otherwise.
% IN    qfield   Data of some Qarts field

% 2008-05-27   Created by Patrick Eriksson.


function b = qarts_isset( qfield )

  if iscell(qfield) & length(qfield) == 0
    b = 0;
  else
    b = 1;
  end  



