%% Plot the real counts and forward model counts goes to the OEM code
% clear all;
[Q] = makeQsham( 20110909,23,2);
x =[Q.Ta Q.BaJH Q.BaJL Q.CL Q.OVa];

[JL,JH,A_Zi,B_Zi,Diff_JL_i,Diff_JH_i,Ti]=forwardmodelTraman(Q,x);
figure;
semilogx(Q.y(1:length(Q.Zmes)),Q.Zmes./1000,'r',JH,Q.Zmes./1000,'b');
hold on
semilogx(Q.y(length(Q.Zmes)+1:end),Q.Zmes./1000,'g',JL,Q.Zmes./1000,'black');
xlabel('Log of counts')
ylabel(' Alt(km)')
legend('JH real','JH FM','JLreal','JL FM')
hold off;

 % Check poisson noise 
 
 checkPoissonStat(Q.Zmes,Q.y(length(Q.Zmes)+1:end))
 checkPoissonStat(Q.Zmes,Q.y(1:length(Q.Zmes)))