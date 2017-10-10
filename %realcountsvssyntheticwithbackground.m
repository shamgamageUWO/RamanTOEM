close all; clear all;
date_in = 20110628;
time_in = 23;


% RALMO counts

[JHnew,JLnew,alt,JLwithoutBG,JHwithoutBG,bkg_JL,bkg_JH]=rawcountsRALMOwithBG(date_in);

% Synthetic counts 
Zi = 500:100:40000;
[JLL,JHH,T_US,CL,CH,Diff_JH_i,Diff_JL_i,A_Zi]=realmeasurements(date_in, time_in, Zi);

% Altitude limiting
SJH = (JHnew(alt<=40000));
SJL = (JLnew(alt<=40000));
alt = alt(alt<=40000);

 figure;
% subplot(1,2,1)
 semilogx(SJL,alt./1000,'r',SJH,alt./1000,'b')
hold on;

BG_JL = nansum(bkg_JL);
BG_JH = nansum(bkg_JH);

% Synthetic

JLN = (A_Zi.* Diff_JL_i)./(T_US);
JHN = (A_Zi.* Diff_JH_i)./(T_US);


CL = 2.9e18;
CH = 0.7.*CL;


JLsyn = CL.*JLN;
JHsyn = CH.*JHN;

% Random poissson noise

% JLn = poissrnd(nanmean(JLsyn),1,396);
% JL = JLsyn+JLn;
% 
% JHn = poissrnd(nanmean(JHsyn),1,396);
% JH = JHsyn+JHn;


% Add background
JL = JLsyn +BG_JL;
JH = JHsyn +BG_JH;
% figure;semilogx(JL,Zi./1000,'r',JH,Zi./1000,'b') 
% hold on;

% add poisson noise
JL = NoiseP(JL);
JH = NoiseP(JH);
semilogx(JL,Zi./1000,'g',JH,Zi./1000,'m') 
hold off;

% 
% test std and sqrt
SQ = sqrt(JL);
% figure;plot(SQ,Zi)

n = [2 5 10 15];
STD=[];
figure;
for j = 1:4
    for i = n(j)+1:length(JL)-n(j)
        STD(i-n(j)) = std(JL(i-n(j):i+n(j)));
    end
    alti = Zi(n(j)+1:length(JL)-n(j));
    subplot(1,4,j)
    semilogx(SQ(n(j)+1:length(JL)-n(j)),alti./1000,'b')
    hold on;
    semilogx(STD,alti./1000,'r')
    xlabel('log')
    ylabel('Alt(km)')
    legend('Sqrt','STD')
    title({'number of points considered',n(j)});
    hold off; 
    clear STD
end  
% 
