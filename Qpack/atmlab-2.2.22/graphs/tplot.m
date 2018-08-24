% TPLOT Text plots.
%
%    Creates plots just including text. The text can be written in columns.
%
%    The plot is initialized by calling the function with the axes handle
%    and number of columns to create. Text is then written from the top
%    downwards, one row (per column) for each function call.
%
%    An example:
%      tplot( gca, 2 );
%      tplot( gca, 1, 'A FANCY AND BOORING TITLE',14,'B');
%      tplot( gca, 2, '',14,'B');
%      tplot( gca, 1, 'Here is column 1.');
%      tplot( gca, 1, 'Column 1 again.');
%      tplot( gca, 2, 'Here is column 2.');
%
% FORMAT   tplot(h,col)  or  tplot(h,col,s[,fsize,fweight])
%        
% IN    h         Handle to axes where to place the text.
%       col       In first format case: Number of columns to create.
%                 In second format case: The text is placed in this column.
%       s         String to print.
% OPT   fsize     Font size. Default is 12.
%       fweight   Font weight. Default is 'n' (normal). For bold font: 'b'.

% 2002-12-14   Created by Patrick Eriksson.


function tplot(h,col,s,fsize,fweight)


%=== Input arguments
%
rqre_nargin( 2, nargin );
%
if ~iswhole(col)  |  col <= 0
  error('The argument *col* must be an integer > 0.');
end
%
if nargin < 4
  fsize = 12;
end
%
if nargin < 5
  fweight = 'n';
end



%=== Init the plot
%
if nargin < 3
  %
  h0 = gca;
  axes( h );
  cla;
  axes( h0 );
  %
  %- Turn off frame 
  axes_frame( h, 'off' );
  %
  %- Set other values to store in UserData
  A.ncol = col;
  A.row  = repmat( 0.98, 1, col );  % y-position of lower part ot text per col   
  %
  set( h, 'UserData', A );


%=== Write text
%
else
  %
  A = get( h, 'UserData' );
  %
  if ~isfield( A, 'ncol' )
    error('It appears that the UserData of the axes are corrupted.');
  end
  %
  if col > A.ncol
    error( sprintf('You selected column %d, but only %d columns exist.', ...
                                                              col, A.ncol ) );
  end
  %
  %- Determine height of text in axes coordinates
  ht = text( 0.5, 0.5, 'T', 'FontSize', fsize, 'FontWeight', fweight );
  dummy = get( ht, 'Extent' );
  htext = dummy(4); 
  delete(ht);
  %
  x = 0.02 + 0.98 * (col -1) / A.ncol;
  y = A.row(col) - 0.6 * htext;
  %
  A.row(col) = y - htext/2;;
  %
  text( x, y, s, 'FontSize', fsize, 'FontWeight', fweight ); 
  %
  set( h, 'UserData', A );

end