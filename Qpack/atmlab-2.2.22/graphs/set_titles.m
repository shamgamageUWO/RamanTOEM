% SET_TITLES   Properties of plot titles.
%
%    The function sets any property of plot title objects. The properties are 
%    applied to the given handles and their childrens (all generations, 
%    see *children*). To set the fontsize for all titles of a figure to 10
%       set_titles( gcf, 'FontSize', 10 );
%
%    See also *set_axes* and *set_labels*.
%
% FORMAT   set_titles(h,varargin)
%        
% IN    h   Handle to a figure, or figure objects.
%           Arbitrary number of property / property value pairs.

% 2002-12-13   Created by Patrick Eriksson.


function set_titles(h,varargin)


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


%=== Loop handles and scale all possible text
%
for ih = 1 : length( h )

  if strcmp( get( h(ih), 'type' ), 'axes' )

    hl = get( h(ih), 'Title');
    set( hl, varargin{:} );

  end

end
