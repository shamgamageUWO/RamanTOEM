% GF_SET_FIELDS   Setting of character fields
%
%   An example:
%      G = gf_set( G, 'SOURCE', 'Set manually', 'NAME', 'X' );
%
% FORMAT   G = gf_set_fields(G [, field1, string1, ...] )
%        
% OUT   G              Modified gformat structure.
% IN    G              Original gformat structure.
% OPT   field/string   Combinations of field names and strings.      

% 2007-10-17   Created by Patrick Eriksson.

function G = gf_set_fields(G,varargin)

strict_assert = atmlab('STRICT_ASSERT');

if strict_assert
  rqre_nargin( 1, nargin );
  if ~iseven( length( varargin ) )
    error( ['The number of input arguments must be an even number.'] );
  end
end

for i = 1 : 2: length(varargin)
  if strict_assert
    rqre_datatype( varargin{i}, {@ischar}, 'Field names' );
    rqre_datatype( varargin{i+1}, {@ischar,@isempty}, ... 
                                               'An optional field argument' );
  end
  G = setfield( G, varargin{i}, varargin{i+1} );
end
