% SCALE_TEXT   Scales the text size of a figure or objects with a factor.
%
%    The function scales all text objects with the given scalimng factor.
%    The scaling is applied to the given handles and their childrens (all
%    generations, see *children*). To make all text objects 20% in a figure:
%       scale_text( gcf, 1.2 );
%
% FORMAT   scale_text(h,scfac)
%        
% IN    h       Handle to the figure, or figure objects.
%       scfac   Scaling factor (1 results in no effective scaling).

% 2002-12-12   Created by Patrick Eriksson.


function scale_text(h,scfac)


%=== Check input
%
rqre_nargin( 2, nargin );
%
if ~isvector( h )
  error('The argument *h* must be a numeric vector.');
end
%
if ~isscalar( scfac )  |  scfac <= 0
  error('The scaling factor must be a scalar >= 0.');
end


%=== Append given handle(s) and children
%
h = [ h; children( h ) ];


%=== Loop handles and scale all possible text
%
for ih = 1 : length( h )

  switch lower( get( h(ih), 'type' ) )

    case 'text'
      %
      fsize = get( h(ih), 'FontSize' );
      set( h(ih), 'FontSize', scfac*fsize );

    case 'axes'
      %
      fsize = get( h(ih), 'FontSize' );
      set( h(ih), 'FontSize', scfac*fsize );
      %
      hl = get( h(ih), 'Xlabel' );
      fsize = get( hl, 'FontSize' );
      set( hl, 'FontSize', scfac*fsize );
      %
      hl = get( h(ih), 'Ylabel' );
      fsize = get( hl, 'FontSize' );
      set( hl, 'FontSize', scfac*fsize );
      %
      hl = get( h(ih), 'Zlabel' );
      fsize = get( hl, 'FontSize' );
      set( hl, 'FontSize', scfac*fsize );
      %
      hl = get( h(ih), 'Title' );
      fsize = get( hl, 'FontSize' );
      set( hl, 'FontSize', scfac*fsize );

  end
end
