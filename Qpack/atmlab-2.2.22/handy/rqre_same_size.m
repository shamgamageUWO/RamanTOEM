% RQRE_SAME_SIZE   Checks that two variables have exactly the same size
%
%    Issues an error if criterion not fulfilled.
%
%    Only sizes are compared and *a* and *b* can be of different types.
%
% FORMAT   rqre_same_size( a, b )
%        
% IN    a   A variable
%       b   A second variable

% 2010-01-04   Created by Patrick Eriksson.

function rqre_same_size(a, b)

if any(size(a) ~= size(b))
  error(['atmlab:' mfilename], ...
      'The variables %s and %s must have the same size. Sizes found: %s %s', ...
        inputname(1), inputname(2), ...
        mat2str(size(a)), mat2str(size(b)));
end

end
