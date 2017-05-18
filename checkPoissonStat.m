% check if signal follows poisson statistics.
% checkPoissonStat(r, S)
%
% input:
% r: range
% S: signal in photons
%
% output: plots

function xs=checkPoissonStat(r,x_ph)

% r = altitude
% x - counts

% bin size
N = 6;

% reshape vectors
ind = 1:length(r)-mod(length(r),N);
r = mean(reshape(r(ind),N,[]),1)/1000;
xm = sqrt(mean(reshape(x_ph(ind),N,[]),1)); 
xsm = reshape(x_ph(ind),N,[]);
clear xs
for j=1:size(xsm,2)
    P = polyfit([1:N]',xsm(:,j),1);
    xs(j) = std(xsm(:,j)-polyval(P,[1:N]'));
end


% plot
figure;
plot(r,xm)
hold
plot(r,xs)
% plot(r,xm./xs)
grid on, hold
xlim([0 30])
legend('sqrt(S)','stdv(S)')
xlabel('range (km)')
ylabel('\sigma [-]');


