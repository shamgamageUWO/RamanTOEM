% SET_TEXT   Properties of text objects.
%
%    The function sets any property of text objects. The properties are 
%    applied to the given handles and their childrens (all generations, 
%    see *children*). To set the fontsize used in a legend with handle *h*,
%    execute:
%       set_text( h, 'FontSize', 10 );
%
%    See also *set_labels* and *set_title*.
%
% FORMAT   set_text(h,varargin)
%        
% IN    h   Handle to a figure, or figure objects.
%           Arbitrary number of property / property value pairs.

% 2002-12-13   Created by Patrick Eriksson.


function set_text(h,varargin)


%=== Check input
%
rqre_nargin( 1, nargin );
%
if ~isvector( h )
  error('The argument *h* must be a numeric vector.');
end
%
if ~iseven( length(varargin) )
  error('Input be pairs of property and its value.');
end


%=== Append given handle(s) and children
%
h = [ h; children( h ) ];


%=== Loop handles and apply settings for all text objects
%
for ih = 1 : length( h )

  if strcmp( get( h(ih), 'type' ), 'text' )

    set( h(ih), varargin{:} );

  end

end
