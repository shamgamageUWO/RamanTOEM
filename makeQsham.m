function [Q] = makeQsham( date_in,time_in,flag)

% -Usage-
%	[Q,y,yvar] = makeQ(in)
%
% -Inputs-
%	in - data structure of parameters passed from oem
% flag == 1 day time measurement
%
% -Outputs-
%	Q - retrieval input structure
%   y - n channels of data
%   yvar - the data's variance
%  t= cputime


%% All the constants

kb = 1.38064852*10^-23;
Rsp = 287;
NA = 6.02214129 *(10^23) ;% Avergadro Number mol?1
M = 28.9645 * (10^-3); 
Q.date_in = date_in;%20110616; % daytime 20110816
Q.time_in = time_in;%23; % 11
Q.Csum =  2.8077e+18;
Q.CLfac = 10^-2;
Q.CHfac = 10^-2;
Q.coaddalt = 4;
Q.Rgas = 8.3145;%Hz
Q.t_bin = 60;%s
Q.altbinsize = 3.75;%m
Q.Clight = 299792458; %ISSI value
Q.ScaleFactor = 150/3.75;
Q.shots = 1800;
Lambda = 354.7* (10^-3);
A = 4.02*10^(-28);
B = -0.3228;
C = 0.389;
D = 0.09426;
exponent = 4+B+C*Lambda+D/Lambda;
sigma_Rcm2 = A / Lambda^(exponent);
Q.sigmaNicolet = sigma_Rcm2*1e-4;%m2
Q.deadtimeJL = 3.8e-9; % 4ns
Q.deadtimeJH = 3.7e-9; % 4ns
Q.deadtimeN2 = 3.8e-9; % 4ns
Q.deadtimeWV = 3.8e-9; % 4ns
Q.CovDTJL = (.01.*Q.deadtimeJL).^2;
Q.CovDTJH = (.01.*Q.deadtimeJH).^2;
Q.CovDTWV = (.01.*Q.deadtimeWV).^2;
Q.CovDTN2 = (.01.*Q.deadtimeN2).^2;
Q.g0a=90*10^-3;%m % this is to create a priori overlap
Q.g0real=100*10^-3;%m % this is to create real overlap
Q.deltatime = 30;
Q.Shots = 1800; 
disp('All the constants are ready')
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Inputs
alt_d0 = 4000; % PRR Digital Channel starting altitude 20110705 2000 2011080223 3000
alt_d01 = 4000; % WV/N2 Digital Channel starting altitude 20110705 2000 2011080223 3000
alt_df = 20000; % Digital Channel ending altitude
alt_a0 = 200;% Analog Channel starting altitude 20110705 150
alt_af = 8000;% Analog Channel ending altitude 20110705 2000, 2011080223 6000
b1 = 8; % Bin size for piecewise cov for digital 20110705 2011080223 8
Q.b2 = 8; % Bin size for piecewise cov for analog 20110705  2011080223 24
c1 = 3; % retrieval bin size
c2 = 2.*c1;
c3 = 2.*c2;
c4 = 2.*c3;

% For asr
Q.LRfree = 25; % was 20 on 20120228/20110901/20110705/2011080223, 0308 50, 200905-6 50 Cirrus cloud???
Q.LRpbl = 80; % 50 on 20110705 20110901 2011080223; was 80 on otherwise 
Q.LRtranHeight = 2000; %  800 for 20120228 2000 for 20110901 this is the height to the BL 1500 20110705 2011080223 6000
% 3 is nominal, not accurate 2.75; 
Q.AerosolFreeheight = 15000;%2011080223 17000
Q.ASRcutoffheight = 15000; % 20110909 1400


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load raw measurements
%    [Y] = makeY(Q);
[Y] = makeYNEW(Q);
% [Y]=makeYFFT(Q);
Q.Dateofthefolder = Y.Dateofthefolder;

% Digital measurements 2km above
JHnew = Y.JH;
JLnew = Y.JL;
N2new = Y.N2;
WVnew = Y.WV;

JL_DS = Y.JL_DS;
JH_DS = Y.JH_DS;
N2_DS = Y.N2_DS;
WV_DS = Y.WV_DS;

alt = Y.alt;
Eb = Y.Eb;
Q.binzise = Y.binsize;

Q.Eb = Eb(alt>=alt_d0 & alt <= alt_df );
Q.Eb(Q.Eb <=0)= rand();

Q.JHnew= JHnew(alt>=alt_d0 & alt <= alt_df);
Q.JLnew= JLnew(alt>=alt_d0 & alt <= alt_df);
Q.JH_DS =JH_DS(alt>=alt_d0 & alt <= alt_df);
Q.JL_DS =JL_DS(alt>=alt_d0 & alt <= alt_df);

Q.N2new= N2new(alt>=alt_d01 & alt <= alt_af);
Q.WVnew= WVnew(alt>=alt_d01 & alt <= alt_af);
Q.N2_DS =N2_DS(alt>=alt_d01 & alt <= alt_af);
Q.WV_DS =WV_DS(alt>=alt_d01 & alt <= alt_af);

Q.alt = alt(alt>=alt_d0 & alt <= alt_df);
Q.Zmes2 = Q.alt';

Q.alt1 = alt(alt>=alt_d01 & alt <= alt_af);
Q.Zmes3 = Q.alt1';

Q.f = 1e6./(Y.F);

% Analog measurements
JHnewa = Y.JHa;
JLnewa = Y.JLa;
N2newa = Y.N2a;
WVnewa = Y.WVa;
Eba = Y.Eba;

ANalt = Y.alt_an;
Q.Eba = Eba(ANalt>=alt_a0 & ANalt <= alt_af);
Q.Eba(Q.Eba <=0)= rand();

Q.JHnewa= JHnewa(ANalt>=alt_a0 & ANalt <=alt_af);
Q.JLnewa= JLnewa(ANalt>=alt_a0 & ANalt <=alt_af);
Q.N2newa= N2newa(ANalt>=alt_a0 & ANalt <=alt_af);
Q.WVnewa= WVnewa(ANalt>=alt_a0 & ANalt <=alt_af);


Q.ANalt = ANalt(ANalt>=alt_a0);
Q.Zmes1 = ANalt(ANalt>=alt_a0 & ANalt <= alt_af);
Q.Zmes1 = Q.Zmes1';

Q.Zmes =  alt(alt>=alt_a0 & alt <= alt_df);%% Fix this here ..one range should fix the asr

% Backgrounds
Q.BaJL = Y.bgJL;%0.297350746852139; % change later
Q.BaJH = Y.bgJH;%4.998109499057194e-04;
Q.BaN2 = Y.bgN2;%0.297350746852139; % change later
Q.BaWV = Y.bgWV;

Q.BaJLa = Y.bgJLa;%0.297350746852139; % change later
Q.BaJHa = Y.bgJHa;%4.998109499057194e-04;
Q.BaN2a = Y.bgN2a;%0.297350746852139; % change later
Q.BaWVa = Y.bgWVa;

disp('Loaded RALMO measurements ')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Q.n1=length(Q.JHnew);
Q.n2=length(Q.JLnew);
Q.n3=length(Q.JHnewa);
Q.n4=length(Q.JLnewa);
Q.n5=length(Q.WVnew);
Q.n6=length(Q.N2new);
Q.n7=length(Q.WVnewa);
Q.n8=length(Q.N2newa);
%% Define grid sizes
Q.d_alti_Diff = length(Q.Zmes)-length(Q.Zmes2);
Z1 = Q.Zmes(1):(Q.Zmes(2)-Q.Zmes(1))*c1:6000;
Z2 = 6000:(Q.Zmes(2)-Q.Zmes(1))*c2:10000;
Z3 = 10000:(Q.Zmes(2)-Q.Zmes(1))*c3:15000;
Z4 = 15000:(Q.Zmes(2)-Q.Zmes(1))*c4:21000;
Q.Zret =[Z1 Z2 Z3 Z4];
disp('Defined grids ')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  a priori temperatures

[Tsonde,Zsonde,Psonde,RH] = get_sonde_RS92(Q.date_in, Q.time_in);
Zsonde = Zsonde-491; % altitude correction
Tsonde = Tsonde(Zsonde<=32000);
Psonde = Psonde(Zsonde<=32000);
Zsonde = Zsonde(Zsonde<=32000);
RHsonde = RH(Zsonde<=32000);

Q.Tsonde = interp1(Zsonde,Tsonde,Q.Zmes,'linear'); % this goes to Restimation and asr code
Q.RHsonde = interp1(Zsonde,RHsonde,Q.Zmes,'linear'); 

Psonde = interp1(Zsonde,log(Psonde),Q.Zmes,'linear'); % this goes asr
Q.Psonde = exp(Psonde);
Q.Tsonde2 = interp1(Zsonde,Tsonde,Q.Zret,'linear'); % this goes to CJL estimation
Q.RHsonde2 = interp1(Zsonde,RHsonde,Q.Zret,'linear'); % this goes to CJL estimation


Q.Pressi = Q.Psonde;
Ti = Q.Tsonde;
Q.rho = Q.Pressi./(Rsp.*Ti);
Q.Nmol = (NA/M).* Q.rho ; % mol m-3
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% US temperature model
[temp, press, dens, alt] = US1976(Q.date_in, Q.time_in, Q.Zret);
Ta = temp; % for now im adding 2K to test
 Q.Ta = (Ta./Ta(1)).* Q.Tsonde2(1);
% Q.Ta = smooth(Q.Tsonde2,100);%a priori RH
% Q.Ta = Q.Ta';
Q.Ti = interp1(Q.Zret,Q.Ta,Q.Zmes,'linear');
RHa = smooth(log(Q.RHsonde2./100),10);%a priori RH
Q.RHa = RHa';
disp('a priori temperature profile is loaded ')



% Calculate the aerosol attenuation
[alphaAer,odaer] = asrSham(Q);
Q.alpha_aero = alphaAer;
Q.odaer = odaer;
% total transmission air + aerosol 
[Tr_PRR,Tr_N2,Tr_WV] = Total_Transmission(Q);
Q.Tr = Tr_PRR;
Q.Tr_N2 = Tr_N2;
Q.Tr_WV = Tr_WV;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% R is calibrated wrt sonde profiles
 [R_fit,Ra_fit,dfacR,dfacRa] = Restimationnew(Q);
Q.R = R_fit;%0.7913;%R;%0.808780013344381;%R;%R;%0.17;
Q.Ra = Ra_fit;%0.8639;%Ra;%1.042367710538608;%Ra; %%I'm hardcoding this for now. for some reason FM doesnt provide measurements close to real unless divide by 2                     Ttradi = real(Q.bb./(Q.aa-lnQ));
Q.GR = dfacR ; % ISSI recommend
Q.GRa = dfacRa;
% disp('R is calibrated ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        load('OVDay.mat')
                                        OVnw = interp1(OVDay.Z,OVDay.OV,Q.Zret,'linear');
                                        OVnw(isnan(OVnw))=1;
                                        Q.OVa = OVnw;                                    
                                        Q.OVlength = length(Q.OVa);
                                        Q.COVa = OVCov(Q.Zret,Q.OVa);
                                        
                                         load('OV_N2.mat')
                                        OVnwv = interp1(OVN2.z,OVN2.OV,Q.Zret,'linear');
                                        OVnwv(isnan(OVnwv))=1;
                                        Q.OVwva = OVnwv;                                    
                                        Q.OVwvlength = length(Q.OVwva);
                                        Q.COVwva = OVCov(Q.Zret,Q.OVwva);
                                        disp('Daytime retrieval')% Estimating background and lidar constant wrt a priori 

C = estimations(Q);% Q.OVa = ones(1,length(Q.Ta));
Q.CL = C.CJL;
Q.CLa =C.CJLa;
Q.CN2 = C.Cn2;
Q.CWV = C.Cwv;
Q.CN2a = C.Cn2a;
Q.CWVa =C.Cwva;

Q.CovCL = (.1 .* (Q.CL)).^2;%sqrt(Q.CL);
Q.CovCLa = (.1 .* (Q.CLa)).^2;%sqrt(Q.CL);
Q.CovWV = (.1 .* (Q.CWV)).^2;%sqrt(Q.CL);
Q.CovWVa = (.1 .* (Q.CWVa)).^2;%sqrt(Q.CL);
Q.CovN2 = (.1 .* (Q.CN2)).^2;%sqrt(Q.CL);
Q.CovN2a = (.1 .* (Q.CN2a)).^2;%sqrt(Q.CL);

Q.CovBJLa = ((Y.bg_JL_stda)).^2; % day time
Q.CovBJHa = ((Y.bg_JH_stda)).^2;
Q.CovBN2a = ((Y.bg_N2_stda)).^2; % day time
Q.CovBWVa = ((Y.bg_WV_stda)).^2;
 

                                        if flag ==1
                                            Q.CovBJL = ((Y.bg_JL_std)).^2; % day time
                                            Q.CovBJH = ((Y.bg_JH_std)).^2;
                                            Q.CovBWV = ((Y.bg_WV_std)).^2; % day time
                                            Q.CovBN2 = ((Y.bg_N2_std)).^2;
                                            
%                                         load('OVDay.mat')
%                                         OVnw = interp1(OVDay.Z,OVDay.OV,Q.Zret,'linear');
%                                         OVnw(isnan(OVnw))=1;
%                                         Q.OVa = OVnw;                                    
%                                         Q.OVlength = length(Q.OVa);
%                                         Q.COVa = OVCov(Q.Zret,Q.OVa);
%                                         
%                                          load('OV_N2.mat')
%                                         OVnwv = interp1(OVN2.z,OVN2.OV,Q.Zret,'linear');
%                                         OVnwv(isnan(OVnwv))=1;
%                                         Q.OVwva = OVnwv;                                    
%                                         Q.OVwvlength = length(Q.OVwva);
%                                         Q.COVwva = OVCov(Q.Zret,Q.OVwva);
%                                         disp('Daytime retrieval')
                                        
                                        
                                        else 
                                            Q.CovBJL = ((Y.bg_JL_std/sqrt(Y.bg_length2))).^2;
                                            Q.CovBJH = ((Y.bg_JH_std/sqrt(Y.bg_length1))).^2;
                                            Q.CovBWV = ((Y.bg_WV_std/sqrt(Y.bg_length4))).^2;
                                            Q.CovBN2 = ((Y.bg_N2_std/sqrt(Y.bg_length3))).^2;
                                            
%                                         load('OVDay.mat')
%                                         OVnw = interp1(OVDay.Z,OVDay.OV,Q.Zret,'linear');
%                                         OVnw(isnan(OVnw))=1;
%                                         Q.OVa = OVnw;
%                                         Q.OVlength = length(Q.OVa);
%                                         Q.COVa = OVCov(Q.Zret,Q.OVa);
% 
%                                         load('OV_N2.mat')
%                                         OVnwv = interp1(OVN2.z,OVN2.OV,Q.Zret,'linear');
%                                         OVnwv(isnan(OVnwv))=1;
%                                         Q.OVwva = OVnwv;
%                                         Q.OVwvlength = length(Q.OVwva);
%                                         Q.COVwva = OVCov(Q.Zret,Q.OVwva);
                                        
                                        disp('Nighttime retrieval')
                                        end 

%%
                        % this need to be done if there is any zeros in the real measurements
                        % smooth the signal over 1
                  
                        Q.JHnew(Q.JHnew<=0)= round(rand(1)*10);
                        Q.JHnewa(Q.JHnewa<=0)= round(rand(1)*10);
                        Q.JLnew(Q.JLnew<=0)= round(rand(1)*10);
                        Q.JLnewa(Q.JLnewa<=0)= round(rand(1)*10);
                                          
                        Q.N2new(Q.N2new<=0)= round(rand(1)*10);
                        Q.N2newa(Q.N2newa<=0)= round(rand(1)*10);
                        Q.WVnew(Q.WVnew<=0)= round(rand(1)*10);
                        Q.WVnewa(Q.WVnewa<=0)= round(rand(1)*10);

JHreal = Q.JHnew'; JLreal = Q.JLnew';  JHrealan = Q.JHnewa';    JLrealan = Q.JLnewa';
N2real = Q.N2new'; WVreal = Q.WVnew';  N2realan = Q.N2newa';    WVrealan = Q.WVnewa';


 Q.JHnew =JHreal;  Q.JLnew=JLreal ;  Q.JHnewa =JHrealan ;   Q.JLnewa= JLrealan;
  Q.N2new =N2real;  Q.WVnew=WVreal ;  Q.N2newa =N2realan ;   Q.WVnewa= WVrealan;


                        Q.y = [Q.JHnew Q.JLnew Q.JHnewa Q.JLnewa Q.WVnew Q.N2new Q.WVnewa Q.N2newa]';



             [JHv,go11] =bobpoissontest(JHreal,Q.Zmes2,b1);
             [JLv,go] =bobpoissontest(JLreal,Q.Zmes2,b1);
          
             r1 = ones(1,go11-1).* JHv(1);
             r2 = ones(1,go11-1).* JHv(end);
             r3 = ones(1,go-1).* JLv(1);
             r4 = ones(1,go-1).* JLv(end);
             Q.JHv = [r1 JHv r2];
             Q.JLv = [r3 JLv r4];

             [n2v,g1] =bobpoissontest(N2real,Q.Zmes3,b1);
             [wvv,g11] =bobpoissontest(WVreal,Q.Zmes3,b1);
          
             r11 = ones(1,g1-1).* n2v(1);
             r21 = ones(1,g1-1).* n2v(end);
             r31 = ones(1,g11-1).* wvv(1);
             r41 = ones(1,g11-1).* wvv(end);
             Q.n2v = [r11 n2v r21];
             Q.wvv = [r31 wvv r41];

            
            
        for i = 1: length(Q.JLv)
            if Q.Zmes2(i) <= 4000
                Q.YY(i) = Q.JLv(i);
                Q.YYY(i) = Q.JHv(i);
%                 Q.YYn2(i) = Q.n2v(i);
%                 Q.YYwv(i) = Q.wvv(i);
            else
                Q.YY(i) = JLreal(i);
                Q.YYY(i) = JHreal(i);
%                 Q.YYn2(i) = N2real(i);
%                 Q.YYwv(i) = WVreal(i);
            end
        end

        for i = 1: length(Q.wvv)
            if Q.Zmes3(i) <= 4000
%                 Q.YY(i) = Q.JLv(i);
%                 Q.YYY(i) = Q.JHv(i);
                Q.YYn2(i) = Q.n2v(i);
                Q.YYwv(i) = Q.wvv(i);
            else
%                 Q.YY(i) = JLreal(i);
%                 Q.YYY(i) = JHreal(i);
                Q.YYn2(i) = N2real(i);
                Q.YYwv(i) = WVreal(i);
            end
        end

        
%                 Q.YYa = Y.YYa(1:length(Q.JLnewa));%ANalt>=alt_a0 & ANalt <=alt_af);
%                 Q.YYYa = Y.YYYa(1:length(Q.JHnewa));%ANalt>=alt_a0 & ANalt <=alt_af);
%                 Q.YYa =Q.YYa';
%                 Q.YYYa =Q.YYYa';
% 
%                 Q.YYwva = Y.YYWVa(1:length(Q.WVnewa));%ANalt>=alt_a0 & ANalt <=alt_af);
%                 Q.YYYn2a = Y.YYYN2a(1:length(Q.N2newa));%ANalt>=alt_a0 & ANalt <=alt_af);
%                 Q.YYwva =Q.YYwva';
%                 Q.YYYn2a =Q.YYYn2a';
                Q.YYa = 0.01.*ones(1,length(Q.JLnewa));
                Q.YYYa = 0.01.*ones(1,length(Q.JHnewa));
%                 Q.YYa =Q.YYa';
%                 Q.YYYa =Q.YYYa';

                Q.YYwva = 0.01.*ones(1,length(Q.WVnewa));
                Q.YYYn2a =0.01.*ones(1,length(Q.N2newa));
%                 Q.YYwva =Q.YYwva;
%                 Q.YYYn2a =Q.YYYn2a;


Q.Yvar =[Q.YYY Q.YY Q.YYYa Q.YYa Q.YYwv Q.YYn2 Q.YYwva Q.YYYn2a];
Q.yvar = diag(Q.Yvar);
                
                



disp('Estimations for CJL, backgrounds and overlap done ')
disp('makeQ complete ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



end





