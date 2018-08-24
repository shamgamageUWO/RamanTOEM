% INPUT_VECTOR   Prompts for user input of vector type.
%
%    Works as INPUT but accepts only input that is a numeric vector.
%
%    The optional arguments can be used to set constraints for allowed
%    vectors.
%     
% FORMAT   v = input_vector( s [, sorted, min_length ] )
%
% OUT      v            User input.
% IN       s            String describing the selection
% OPT      sorted       Allow only sorted vectors. 
%                       Default is 0 (not sorted).
%          min_length   Require a minimum length ofg vector.
%                       Default is 1.

% HISTORY: 2003-03-07  Created by Patrick Eriksson


function v = input_vector(s,sorted,min_length)


if nargin < 2
  sorted = 0;
end

if nargin < 3
  min_length = 1;
end



while 1

  v = input( [s,' (give vector as [1,2]): '] );

  if isvector( v )  &  length( v ) >= min_length
    if ~sorted  |  ( sorted  &  issorted( v ) )
      return
    end
  end

  fprintf('Incorrect selection. Please try again:\n');

end