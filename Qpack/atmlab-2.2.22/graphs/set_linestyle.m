% SET_LINESTYLE   Sets an (almost) unique line style
%
%    The function sets a line style, based on the sequentail number given.
%    An unique combination of line color and symbols are given for numbers
%    between 1 and 70. To achieve this, a loop must be used.
%
%    To plot each column of A with a different line style:
%      for i=1:size(A,2)
%        h = plot( x, A(:,i) );
%        hold on
%        set_linestyle( h, i );
%      end
%
% FORMAT   set_linestyle( h, n )
%        
% IN    h   Handle to line, or lines.
%       n   A sequential number. 

% 2006-10-19   Created by Patrick Eriksson.


function set_linestyle(h,n)

%= Define colors
%
c = [
 0.00 0.00 1.00;
 0.00 1.00 0.00;
 1.00 0.00 0.00;
 0.00 1.00 1.00;
 1.00 1.00 0.00;
 1.00 0.00 1.00;
 0.00 0.00 0.00;
 0.00 0.00 0.60;
 0.00 0.60 0.00;
 0.60 0.00 0.00;
 0.00 0.60 0.60;
 0.60 0.60 0.00;
 0.60 0.00 0.60;
 0.60 0.60 0.60;
];


%= Define line styles
%
s = { '-', '--', '-.', '-', '-' };
m = { 'none',  'none',   'none', '.', '*' };

ic = rem( n-1, size(c,1) ) + 1;
t  = ceil( n/size(c,1) );
t= 1;
is = rem( n-1, length(s) ) + 1;

for i = 1:length(h)
  set( h(i), 'Color', c(ic,:), 'LineWidth', t, ...
                                          'LineStyle', s{is}, 'Marker', m{is} );
end
 
    