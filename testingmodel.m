clear all ; close all; 
[Q] = makeQsham( );
Zret = 1000:1000:40000;
[temp, press, dens, alt] = US1976(20110816, 23, Zret); 
x = [temp Q.BaJH Q.BaJL Q.CL];
[JLUS,JHUS,A_Zi,B_Zi,Diff_JL_i,Diff_JH_i,TUS]=forwardmodelTraman(Q,x);

% OEM retrieval
[X,R,Q,O,S_a,Se,xa]=TRamanOEM;

[JL,JH,A_Zi,B_Zi,Diff_JL_i,Diff_JH_i,Ti]=forwardmodelTraman(Q,X.x);
y = Q.y;
% close all;
% plotting
figure;subplot(1,2,1)
plot(((JHUS-JH)./JH).*100,Q.Zmes./1000)
hold on;
plot(((y(1:Q.n1) - X.yf(1:Q.n1))./X.yf(1:Q.n1)).*100 ,Q.Zmes./1000,'black')
plot(-sqrt(y(1:Q.n1))./X.yf(1:Q.n1).*100,Q.Zmes./1000,'r',sqrt(y(1:Q.n1))./X.yf(1:Q.n1).*100,Q.Zmes./1000,'r');
hold off;
xlabel('JH %')

subplot(1,2,2)
plot(((JLUS-JL)./JL).*100,Q.Zmes./1000)
hold on;
plot(((y(Q.n1+1:end) - X.yf(Q.n1+1:end))./X.yf(Q.n1+1:end)).*100 ,Q.Zmes./1000,'black')
plot(-sqrt(y(Q.n1+1:end))./X.yf(Q.n1+1:end).*100,Q.Zmes./1000,'r',sqrt(y(Q.n1+1:end))./X.yf(Q.n1+1:end).*100,Q.Zmes./1000,'r');
hold off;
xlabel('JL %')

% 
% figure;subplot(1,2,1)
% plot(((JH' - X.yf(1:Q.n1))./X.yf(1:Q.n1)).*100 ,Q.Zmes(Q.ind)./1000,'black')
% xlabel('JH (final oem and FM) %')
% subplot(1,2,2)
% plot(((JL' - X.yf(Q.n1+1:end))./X.yf(Q.n1+1:end)).*100 ,Q.Zmes(Q.ind)./1000,'black')
% xlabel('JL (final oem and FM) %')


% 
figure;
% subplot(1,2,1)
plot(y(1:Q.n1)-(JHUS)',Q.Zmes./1000,'r',(y(Q.n1+1:end)-(JLUS)'),Q.Zmes./1000,'b')
% xlabel('JH (final oem and FM) %')
% subplot(1,2,2)
% plot(((JL' - X.yf(Q.n1+1:end))./X.yf(Q.n1+1:end)).*100 ,Q.Zmes(Q.ind)./1000,'black')
% xlabel('JL (final oem and FM) %')