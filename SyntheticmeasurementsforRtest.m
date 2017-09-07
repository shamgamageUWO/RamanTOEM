% Testing Coupling constants using the synthetic
% Create Synthetic data use T _US
% CJL, CJH
% Assuming 
Q.date_in = 20110909;
Q.time_in = 23;
Q.Zret = 100:100:56000;
Q.Zmes1 = 100:10:12000;
Q.Zmes2 = 2000:10:56000;
Q.Zmes = 100:10:56000;
Q.d_alti_Diff = length(Q.Zmes)-length(Q.Zmes2);


kb = 1.38064852*10^-23;
Rsp = 287;
NA = 6.02214129 *(10^23) ;% Avergadro Number mol?1
M = 28.9645 * (10^-3); 
Q.coaddalt = 10;
% Q.Rate = 30;%Hz
Q.t_bin = 60;%s
Q.altbinsize = 3.75;%m
Q.Clight = 299792458; %ISSI value
Q.ScaleFactor = 150/3.75;
Q.shots = 1800;
Q.deltatime = 30;
Q.Rate = 1800; 
Q.f = Q.Clight ./ (2.*(Q.Rate).*Q.altbinsize);

[temp, press, dens, alt] = US1976(Q.date_in, Q.time_in, Q.Zret);
            Q.Ta = temp; % for now im adding 2K to test
            Q.Ti = interp1(Q.Zret,Q.Ta,Q.Zmes,'linear');
            Q.Pressi =interp1(Q.Zret,press,Q.Zmes,'linear');
            Q.rho = Q.Pressi./(Rsp.*Q.Ti);
            Q.Nmol = (NA/M).* Q.rho ; % mol m-3
            
CJH = 3.0479e+20;
Q.CL = 2.8813e+20;
% Q.R = CJH./Q.CL;
Q.R =1;

CJHa = 4.2952e+16;
Q.CLa = 4.289e+16;
% Q.Ra = CJHa./Q.CLa;
Q.Ra=1;

Q.deadtimeJL = 0; % 4ns
Q.deadtimeJH = 0; % 4ns
Q.OVa = ones(1,length(Q.Ta));
Q.BaJH = 0.4;
Q.BaJL = 0.5;
Q.BaJHa = 420;
Q.BaJLa = 530;

% [Tsonde,Zsonde,Psonde] = get_sonde_RS92(Q.date_in, Q.time_in);
Q.Tsonde = Q.Ti; % asr code
Q.Psonde = Q.Pressi; % this goes asr 
% Calculate the aerosol attenuation
[alphaAer] = asrSham(Q);
Q.alpha_aero = alphaAer;
% total transmission air + aerosol 
Q.Tr = Total_Transmission(Q);

x_a = [Q.Ta Q.BaJH Q.BaJL Q.CL Q.OVa Q.BaJHa Q.BaJLa Q.CLa Q.deadtimeJH Q.deadtimeJL]; % now im retrieving log of CJL
[JL,JH,JLa,JHa,A_Zi_an,A_Zi_d,B_Zi_an,B_Zi_d,Diff_JL_i,Diff_JH_i,Ti]=forwardmodelTraman(Q,x_a);

%  figure;semilogx(JLa,Q.Zmes1./1000,'black',JL,Q.Zmes2./1000,'r',JHa,Q.Zmes1./1000,'b',JH,Q.Zmes2./1000,'m')



% Test 1: Ratio of BG removed Synthetic counts to Differential Cross
% sections
N1 = length(Q.Zmes1);
Ratio_diff = Diff_JH_i./Diff_JL_i;
Ratio_Counts_digi = (JH-Q.BaJH)./(JL-Q.BaJL);
Ratio_Counts_an = (JHa-Q.BaJHa)./(JLa-Q.BaJLa);
R_esti_digi = Ratio_Counts_digi ./Ratio_diff(Q.d_alti_Diff+1:end);
R_esti_a =  Ratio_Counts_an./Ratio_diff(1:N1);

% figure;plot(Q.Zmes1./1000,R_esti_a,'r',Q.Zmes2./1000,R_esti_digi,'b')

% Difference between estimated and R from independent values
digi_R_diff = abs(Q.R - nanmean(R_esti_digi'))
ana_R_diff = abs(Q.Ra - nanmean(R_esti_a'))

%% Test Conclusion : R estimated = R from ratios of constants
%%
% Here use Estimated backgrounds from 20110909 measurements 20bins alt
% obsrved bg 
ind = Q.Zmes2>50e3;
ind2 = Q.Zmes1>8e3;
BG_JL = JL(ind);
BG_JL  = nanmean(BG_JL');
BG_JH = JH(ind);
BG_JH = nanmean(BG_JH');
BG_JLa = JLa(ind2);
BG_JLa = nanmean(BG_JLa');
BG_JHa = JHa(ind2);
BG_JHa  = nanmean(BG_JHa');
% Desaturate to get true, however DT =0 , therefore Bo = Bt

Ratio_Counts_digi_2 = (JH-BG_JH)./(JL-BG_JL);
Ratio_Counts_an_2 = (JHa-BG_JHa)./(JLa-BG_JLa);
R_esti_digi_2 = Ratio_Counts_digi_2 ./Ratio_diff(Q.d_alti_Diff+1:end);
R_esti_a_2 =  Ratio_Counts_an_2./Ratio_diff(1:N1);

% figure;plot(Q.Zmes1./1000,R_esti_a_2,'r',Q.Zmes2./1000,R_esti_digi_2,'b')

% Difference between estimated and R from independent values
digi_R_diff_2 = abs(Q.R - nanmean(R_esti_digi_2(Q.Zmes>=5000 & Q.Zmes<=8000)'))
ana_R_diff_2 = abs(Q.Ra - nanmean(R_esti_a_2(Q.Zmes>=100 & Q.Zmes<=1200)'))


%% Test Conclusion : R estimated = R from ratios of constants even with estimated BG


x = [Q.Ta Q.BaJH Q.BaJL Q.CL Q.OVa Q.BaJHa Q.BaJLa Q.CLa 3.8e-9 3.8e-9]; % new synthetic counts with DT
[JLn,JHn,JLan,JHan]=forwardmodelTraman(Q,x);

% Correct counts before finding R
% Desatuarte
    %% Saturation correction is applied for the averaged count profile This is just for digital channel
        % 1. Make the Co added counts to avg counts
        JHn = JHn./(Q.deltatime.*Q.coaddalt);
        JLn = JLn./(Q.deltatime.*Q.coaddalt);
        
        % 2. Convert counts to Hz
        JHnwn = (JHn.*Q.f);
        JLnwn = (JLn.*Q.f);
        
        % 3. Apply DT
        JL_dtc = JLnwn ./ (1 - JLnwn.*(3.8e-9)); % non-paralyzable
        JH_dtc = JHnwn ./ (1 - JHnwn.*(3.8e-9));
          % 4. Convert to counts
           JLn = JL_dtc.*(1./Q.f);
           JHn = JH_dtc.*(1./Q.f);
       % 5. Scale bacl to coadded signal    
       JLn = JLn.*(Q.deltatime.*Q.coaddalt);
       JHn = JHn.*(Q.deltatime.*Q.coaddalt);

       % Now find the true background from the desaturated signal
       % determine the observed bg from the counts
BG_JLn = JLn(ind);
BG_JLn  = nanmean(BG_JLn');
BG_JHn = JHn(ind);
BG_JHn = nanmean(BG_JHn');
BG_JLan = JLan(ind2);
BG_JLan = nanmean(BG_JLan');
BG_JHan = JHan(ind2);
BG_JHan  = nanmean(BG_JHan');
       
Ratio_Counts_digi_3 = (JHn-BG_JHn)./(JLn-BG_JLn);
Ratio_Counts_an_3 = (JHan-BG_JHan)./(JLan-BG_JLan);
R_esti_digi_3 = Ratio_Counts_digi_3 ./Ratio_diff(Q.d_alti_Diff+1:end);
R_esti_a_3 =  Ratio_Counts_an_3./Ratio_diff(1:N1);

% figure;plot(Q.Zmes1./1000,R_esti_a_3,'r',Q.Zmes2./1000,R_esti_digi_3,'b')

% Difference between estimated and R from independent values
digi_R_diff_3 = abs(Q.R - nanmean(R_esti_digi_3(Q.Zmes>=5000 & Q.Zmes<=8000)'))
ana_R_diff_3 = abs(Q.Ra - nanmean(R_esti_a_3(Q.Zmes>=100 & Q.Zmes<=1200)'))
figure;plot(Q.Zmes2./1000,R_esti_digi,'b',Q.Zmes2./1000,R_esti_digi_2,'r',Q.Zmes2./1000,R_esti_digi_3,'--m')

% Ratio_Counts_digi_4 = (JHn-Q.BaJH)./(JLn-Q.BaJL);
% % Ratio_Counts_an_4 = (JHan-BG_JHa)./(JLan-BG_JLa);
% R_esti_digi_4 = Ratio_Counts_digi_4 ./Ratio_diff(Q.d_alti_Diff+1:end);
% digi_R_diff_4 = abs(Q.R - nanmean(R_esti_digi_4(Q.Zmes>=5000 & Q.Zmes<=8000)'))
% 
