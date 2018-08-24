% NEW_FIGURE   Creates a new figure window
%
%    Works as a plain call of the standard *figure* function (a
%    call without an input argument), but has two options for which
%    figure to open:
% 
%       append: The number of the new figure will have number n+1, 
%               where n is the old maximum figure number.
%       fill  : The new figure will be placed in the first free slot.
%  
%    The *figure* uses the 'fill' strategy. 
%
% FORMAT   h = new_figure( [strategy] )
%        
% OUT   h
% OPT   strategy   Open strategy, see above. Default is 'append'.

% 2013-09-03   Created by Patrick Eriksson.


function h = new_figure( strategy )
%
if nargin < 1, strategy = 'append'; end

figHandles = findobj( 'Type', 'figure' );

switch lower( strategy )
  
 case 'append' 
  if isempty(figHandles)
    h = figure(1);
  else
    h = figure( max(figHandles) + 1 );    
  end

 case 'fill' 
  h = figure;

 otherwise
  error( 'The argument *strategy* must be ''append'' or ''fill''.' );
end