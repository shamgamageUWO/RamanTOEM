% AXES_TITLE   Legend title.
%
%    Adds text at the top of any axes objects.
%
%    The function can be used to set titles for legends and colorbars.
%
% FORMAT   ht = axes_title(h,s[,'Property1',PropertyValue1,...])
%        
% OUT   ht   Handle to the title.
% IN    s    Title string.
% OPT        Arbitrary number of property / property value pairs.

% 2002-12-12   Created by Patrick Eriksson.


function ht = axes_title(h,s,varargin)


%=== Check input
%
rqre_nargin( 2, nargin );
%
if ~iseven( length(varargin) )
  error('Input arguments beside *s* must be property pairs.');
end

ht = get( h, 'title' );

set( ht, 'string', s, varargin{:} );