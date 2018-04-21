function [s] = acf(y,do_plot)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Number of lags
N = 10;

% Degree of polynomial
D = 3;

% set default value for plotting
if nargin==1
    do_plot=0;
end

% compute covariance for lag 1 to N
for i=1:N+1, C = cov(y,circshift(y,i-1-N/2)); c(i) = C(1,2); end

% generate vector for x-axis
x = -N/2:N/2;

% fit covariances
p = polyfit(x, c, D);

% compute difference between total variance and interpolated cov
s = var(y) - polyval(p,0);

% plotting
if do_plot==1
    figure, hold on, grid on
    plot(x, c,'x')
    plot(x, polyval(p,x), 'r')
    
    % title
    title(sprintf('total var = %d, var interp = %d, signal var = %d', var(y), polyval(p,0), s));
    
    % plot signal
    figure, plot(y)
    title('signal')
end

end

