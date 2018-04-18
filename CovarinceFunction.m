%Testing the Cov method to find the analog varince 
%S_noise = Var(X) - COV(X(1:end-1),X(2:end));

function [S_noise,S_cov] = CovarinceFunction

signal = randn(1,30);
lag = 29;

x= signal;
S_noise = var(x)-cov(x(1:end-1),x(2:end));


% Use ACF to find Covariance

[ACF , Lags , bounds] = autocorr(x,lag);

S_cov = ACF.*var(x); % Cov(x,y) = Corr(x,y)Std(x)std(y)

figure;
subplot(1,2,1)
plot(ACF)
% xlabel('lag')
ylabel(' ACF')
subplot(1,2,2)
plot(S_cov)
% xlabel('lag')
ylabel(' Cov')


disp('Var of the signal')
var(x)

disp('Cov from ACF method')
S_cov(1)

disp('S noise from var and Cov method')
S_noise(1,2)