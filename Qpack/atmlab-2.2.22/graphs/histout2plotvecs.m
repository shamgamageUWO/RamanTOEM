% HISTOUT2PLOTVECS Convert the output of matlab's hist command to two
% vectors that can be plotted with plot.
% 
% This function is handy to make histogram plots where only the top
% contour is shown, not the bars.  In that style, several histograms
% can be plotted in one graph.
%
% The trick is that we are not just connecting the histogram points
% by a straight line, but we plot little stairs corresponding to
% the histogram bins.
%
% FORMAT A typical calling sequence is:
%        [n,xout] = hist(...);
%        [x,y]    = histout2plotvecs(n,xout);
%        plot(x,y);
%
% OUT    x,y     Two vectors that can be plotted by plot(x,y)
% IN     n       Frequencies of occurence (hist command output)
%        xout    Bin locations (hist command output)
%
% 2008-5-27 Created by Stefan Buehler

function [x,y] = histout2plotvecs(n,xout)

% We assume that xout increases monotonically.

% Always make sure the data are row vectors (e.g. incase input doesn't come from hist)
n=n(:)';
xout=xout(:)';

% Halv the distance between adjacent points in x:
d = diff(xout)/2;

% We put the boundaries in the middle between the points in
% xout. Furthermore, we add extra points at the bottom and at the
% top, so that in total boundaries has one element more than xout.
boundaries = [xout(1)-d(1), xout(1:end-1)+d, xout(end)+d(end)];

% For x, we have to double all points in boundaries. (This will give
% the plot the staircase look.)
%
% The trick we use to calculate this efficiently is that a matrix can
% be interpreted as one continuous vector:
x = [boundaries;...
     boundaries];
x = x(1:end);

% We use the same trick to get the y, but then we must also add
% zeros at both ends:
y = [n;...
     n];
y = [0, y(1:end), 0];

end
