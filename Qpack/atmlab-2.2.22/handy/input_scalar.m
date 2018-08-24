% INPUT_SCALAR   Prompts for user input of scalar type.
%
%    Works as INPUT but accepts only scalar input. It is also possible
%    to define a range for allowed input and default value. For example:
%
%	v = input_scalar( 'Select shoe size', 30, 50 );
%
%     results in
%
%       Select shoe size {30 <= v <= 50}: 
%
%     If a default value is given, this is used for empty input, which
%     otherwise not is allowed.
%     
% FORMAT   v = input_scalar( s [, vlow, vhigh, vdefault ] )
%
% OUT      v          User input.
% IN       s          String describing the selection
% OPT      vlow       A lower limit for the selection. Default is [],
%                     which means no lower limit.
%          vhigh      An upper limit for the selection.Default is [],
%                     which means no upper lower limit.
%          vdefault   Default value.

% HISTORY: 2003-03-07  Created by Patrick Eriksson

function v = input_scalar( s, vlow, vhigh, vdefault )


%=== Default values
%
if nargin < 2
  vlow = [];
end
if nargin < 3
  vhigh = [];
end
if nargin == 4
  default = 1;
  if ~isempty( vlow )  &  vdefault < vlow
    error('Inconsistency between default value and lower limit.');
  end
  if ~isempty( vhigh )  &  vdefault > vhigh
    error('Inconsistency between default value and upper limit.');
  end
else
  default = 0;
end


%=== Create question string
%
sq = s;
%
if default
  sq = [ sq, ' (default = ', num2str(vdefault),')' ];
end
%
if ~isempty( vlow )  |  ~isempty( vhigh )
  sq = [ sq, ' {' ];
  if~isempty( vlow )
    sq = [ sq, num2str(vlow), ' <= ' ];
  end
  sq = [ sq, 'v' ];  
  if~isempty( vhigh )
    sq = [ sq, ' <= ', num2str(vhigh) ];
  end
  sq = [ sq, '}' ];
end
%
sq = [ sq, ': ' ];



while 1

  v = input( sq );

  if ( default & isempty(v) )
    v = vdefault;
    return
  elseif isscalar(v)  &  ( isempty(vlow) | v >= vlow )  &  ...
                                                ( isempty(vhigh) | v <= vhigh )
    return;
  end 

  fprintf('Incorrect selection. Please try again:\n');
end