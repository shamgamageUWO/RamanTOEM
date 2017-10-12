% this is to find gluing coefficients for jl and jh channels
function [a_JL,b_JL,a_JH,b_JH] = GlueCoef

[Q] = makeQsham( 20110909,23,2);

 % Desaturate the digital
            JLDS =Q.JL_DS;
            JHDS =Q.JH_DS;
            
% analog signals
            JLan = Q.JLnewa ;
            JHan = Q.JHnewa ;
            

            % Measurements between 2-3km
indJL1 = Q.Zmes1>3.2e3 & Q.Zmes1<4.2e3; %JL-ana
indJL2 = Q.Zmes2>3.2e3 & Q.Zmes2<4.2e3; %JL-digi

indJH1 = Q.Zmes1>2e3 & Q.Zmes1<2.5e3; %JH
indJH2 = Q.Zmes2>2e3 & Q.Zmes2<2.5e3; %JH

x_JL = JLan(indJL1);
x_JH = JHan(indJH1);
y_JL = JLDS(indJL2);
y_JH = JHDS(indJH2);

 figure;plot(x_JL,y_JL,'r',x_JH,y_JH,'b')

fJL = fittype({'x','1'},'coefficients',{'a','b'});
fitJL = fit(x_JL',y_JL,fJL,'Robust','on');
g = coeffvalues(fitJL);
a_JL = g(1);
b_JL = g(2);

fJH = fittype({'x','1'},'coefficients',{'a','b'});
fitJH = fit(x_JH',y_JH,fJH,'Robust','on');
gg = coeffvalues(fitJH);
a_JH = gg(1);
b_JH = gg(2);


New_JLa = (JLDS - b_JL)./a_JL ;
New_JHa = (JHDS - b_JH)./a_JH ;

 figure;
% subplot(1,2,1)
semilogx(JLan,Q.Zmes1./1000,'r', New_JLa,Q.Zmes2./1000,'b')
hold on;
semilogx(JHan,Q.Zmes1./1000,'g', New_JHa,Q.Zmes2./1000,'black')
legend('real JL analog','JL analog using digital','real JH analog','JH analog using digital')
xlabel ('analog signals')
ylabel('Altitude (km)')
% hold off;
% 
% subplot(1,2,2)
% plot(JLan(Q.Zmes1<=6000)-New_JLa(Q.Zmes2<=6000)',Q.Zmes1./1000,'r',JHan(Q.Zmes1<=6000)-New_JHa(Q.Zmes2<=6000)',Q.Zmes1./1000,'b')
% legend('difference JL','difference JH')
% xlabel ('Difference of analog signals')
% ylabel('Altitude (km)')