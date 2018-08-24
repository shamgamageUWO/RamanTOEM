% HISTOGRAM  Histogram.
%
%   Plots a histogram, defined by bin edges, rather than bin centers.
%
%   The data given in y is counted into bins given in x. A special first
%   and last bin are added. They contain additionally all data
%   outside of the histogram on the respective side.
%
% FORMAT   n = histogram(y,x)
%        
% OUT   n          Occurence count in each bin.
% IN    y          A vector of data to analyze.
%       x          A vector of bin edges. There will be length(x)+1
%                  bins, due to the two special bins for outsiders.
%
% 2006-02-24   Created by Stefan Buehler

function n = histogram(y,x)

% Prepare the bins for the histc function, to collect also
% outsiders:

bins = [-inf,x,inf];

n = histc(y,bins);

% Safety check: The last bin must be empty, since histc stores
% there all data not accounted for in any other bin, and we have
% included -inf and inf:
if n(end)~=0
  error('Unexpected behaviour of histc');
else
  n = n(1:end-1);
end

% The bar function interprets indices as bar centers, not edges. We
% have to generate these from our bin edges. I'm sure there is a
% more Matlabish way to do this than the for loop...
for i=1:length(x)-1
  l(i) = ( x(i) + x(i+1) ) / 2.0;
end
% Special treatment for first and last bin:
first = x(1)   - ( l(1)   - x(1)   );
last  = x(end) + ( x(end) - l(end) );
l = [first,l,last];

%length(bins)
%length(l)
%length(n)

% Draw the bar plot:
bar(l,n);

