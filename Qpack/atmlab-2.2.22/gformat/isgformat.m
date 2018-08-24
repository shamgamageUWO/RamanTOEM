% ISGFORMAT   Determines if the variable has mandatory gformat fields
%
%    The check considers only field names. The content of the fields is not
%    considered.
%
%    For a description of the gformat
%       help gformat
%
% FORMAT   b = isgformat( G )
%        
% OUT   b     True or false.
% IN    G     A gformat structure (array).

% 2010-01-06   Created by Patrick Eriksson.

function b = isgformat( G )
  
b = false;

if ~isstruct(G) ||  ~isfield(G,'DIM'), return, end

Gt = gf_empty( max( G(:).DIM ) );

if ~all( isfield( G, fieldnames(Gt) ) ), return, end

b = true;