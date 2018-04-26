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
Q.deadtimeJL = 3.8e-9; % 3.84ns
Q.deadtimeJH = 3.7e-9; % 3.74ns
Q.CovDTJL = (.1.*Q.deadtimeJL).^2;
Q.CovDTJH = (.1.*Q.deadtimeJH).^2;
Q.g0a=90*10^-3;%m % this is to create a priori overlap
Q.g0real=100*10^-3;%m % this is to create real overlap
Q.Shots = 1800; 
Q.deltatime = 10;%30;3
Q.min1 = 00;
Q.min2 = 10;
disp('All the constants are ready')
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Inputs
alt_d0 = 4000; % Digital Channel starting altitude 20110705 2000 2011080223 3000
alt_df = 30000; % Digital Channel ending altitude
alt_a0 = 50;% Analog Channel starting altitude 20110705 150
alt_af = 6000;% Analog Channel ending altitude 20110705 2000, 2011080223 6000
b1 = 8; % Bin size for piecewise cov for digital 20110705 2011080223 8
% Q.b2 = 20; % Bin size for piecewise cov for analog 20110705  2011080223 24
c1 = 3; % retrieval bin size
c2 = 2.*c1;
c3 = 2.*c2;
c4 = 2.*c3;

% For asr
%  Q.LRfree = 50; % was 20 on 20120228/20110901/20110705/2011080223, 0308 50, 200905-6 50 Cirrus cloud???
%  Q.LRpbl = 80; % 50 on 20110705 20110901 2011080223; was 80 on otherwise 
%  Q.LRtranHeight = 2000; %  800 for 20120228 2000 for 20110901 this is the height to the BL 1500 20110705 2011080223 6000
% 3 is nominal, not accurate 2.75; 
Q.AerosolFreeheight = 12000;%2011080223 17000
Q.ASRcutoffheight = 12000; % 20110909 1400 20110802 day 11km
% Q.asrsmoothing = 10; % 100 for 20110802 day, 
% Q.OVCOV_6above = 1e-3; % 1e-4 for clear 1e-2/3 for cloud relax this 

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load raw measurements
%    [Y] = makeY(Q);
%    [Y] = makeYNEW(Q);
[Y] = makeYNEWer(Q);
% [Y] = makeYNEWCov(Q);
Q.Dateofthefolder = Y.Dateofthefolder;

% Digital measurements 2km above
JHnew = Y.JH;
JLnew = Y.JL;
JL_DS = Y.JL_DS;
JH_DS = Y.JH_DS;
alt = Y.alt;
Eb = Y.Eb;
Q.binzise = Y.binsize;

Q.Eb = Eb(alt>=alt_d0 & alt <= alt_df );
Q.Eb(Q.Eb <=0)= rand();
Q.JHnew= JHnew(alt>=alt_d0 & alt <= alt_df);
Q.JLnew= JLnew(alt>=alt_d0 & alt <= alt_df);
Q.JH_DS =JH_DS(alt>=alt_d0 & alt <= alt_df);
Q.JL_DS =JL_DS(alt>=alt_d0 & alt <= alt_df);
Q.alt = alt(alt>=alt_d0 & alt <= alt_df);
Q.Zmes2 = Q.alt';

% Zmes = alt(alt>=alt_a0 & alt <= alt_df);
% Q.Zmes = Zmes';

Q.f = 1e6./(Y.F);

% Analog measurements
JHnewa = Y.JHa;
JLnewa = Y.JLa;
Eba = Y.Eba;
ANalt = Y.alt_an;
Q.Eba = Eba(ANalt>=alt_a0 & ANalt <= alt_af);
Q.Eba(Q.Eba <=0)= rand();
Q.JHnewa= JHnewa(ANalt>=alt_a0 & ANalt <=alt_af);
Q.JLnewa= JLnewa(ANalt>=alt_a0 & ANalt <=alt_af);
% Q.JLanalogstd = Y.YYa(ANalt>=alt_a0 & ANalt <=alt_af);
% Q.JHanalogstd = Y.YYYa(ANalt>=alt_a0 & ANalt <=alt_af);
Q.ANalt = ANalt(ANalt>=alt_a0);
Q.Zmes1 = ANalt(ANalt>=alt_a0 & ANalt <= alt_af);
Q.Zmes1 = Q.Zmes1';

 Zmes = ANalt(ANalt>=alt_a0 & ANalt <= alt_df);
 Q.Zmes = Zmes';
%  Q.Zmes = [Q.Zmes1 Q.Zmes2]; %% Fix this here ..one range should fix the asr

% Backgrounds
Q.BaJL = Y.bgJL;%0.297350746852139; % change later
Q.BaJH = Y.bgJH;%4.998109499057194e-04;
Q.BaJLa = Y.bgJLa;%0.297350746852139; % change later
Q.BaJHa = Y.bgJHa;%4.998109499057194e-04;

disp('Loaded RALMO measurements ')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Q.n1=length(Q.JHnew);
Q.n2=length(Q.JLnew);
Q.n3=length(Q.JHnewa);
Q.n4=length(Q.JLnewa);

%% Define grid sizes
Q.d_alti_Diff = length(Q.Zmes)-length(Q.Zmes2);
Z1 = Q.Zmes(1):(Q.Zmes(2)-Q.Zmes(1))*c1:6000;
Z2 = 6000:(Q.Zmes(2)-Q.Zmes(1))*c2:10000;
Z3 = 10000:(Q.Zmes(2)-Q.Zmes(1))*c3:15000;
Z4 = 15000:(Q.Zmes(2)-Q.Zmes(1))*c4:32000;
Q.Zret =[Z1 Z2 Z3 Z4];
disp('Defined grids ')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  a priori temperatures

[Tsonde,Zsonde,Psonde] = get_sonde_RS92(Q.date_in, Q.time_in);
Zsonde = Zsonde-491; % altitude correction
Tsonde = Tsonde(Zsonde<=32000);
Psonde = Psonde(Zsonde<=32000);
Zsonde = Zsonde(Zsonde<=32000);

Q.Tsonde = interp1(Zsonde,Tsonde,Q.Zmes,'linear'); % this goes to Restimation and asr code
Psonde1 = interp1(Zsonde,log(Psonde),Q.Zmes,'linear'); % this goes asr
Q.Psonde = exp(Psonde1);

Psonde2= interp1(Zsonde,log(Psonde),Q.Zret,'linear'); % this goes asr
Q.Psonde2 = exp(Psonde2);
Q.Tsonde2 = interp1(Zsonde,Tsonde,Q.Zret,'linear'); % this goes to CJL estimation

Q.Pressi = Q.Psonde;
Ti = Q.Tsonde;
Q.rho = Q.Pressi./(Rsp.*Ti);
Q.Nmol = (NA/M).* Q.rho ; % mol m-3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% US temperature model
[temp, press, dens, alt] = US1976(Q.date_in, Q.time_in, Q.Zret);
Ta = temp; % for now im adding 2K to test
% Q.Ta=Ta;
 Q.Ta = (Ta./Ta(1)).* Q.Tsonde2(1);
Q.Ti = interp1(Q.Zret,Q.Ta,Q.Zmes,'linear');

disp('a priori temperature profile is loaded ')



% % Calculate the aerosol attenuation
[alpha_aero,odaer] = asrSham(Q);
 Q.alpha_aero = alpha_aero';%interp1(Q.Zmes,alphaAer,Q.Zret,'linear'); % this goes to CJL estimation

% Q.odaer = odaer;
% 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% R is calibrated wrt sonde profiles
    [R,Ra,R_fit,Ra_fit,dfacR,dfacRa] = Restimationnew(Q);
    Q.R = R_fit;%0.7913;%R;%0.808780013344381;%R;%R;%0.17;
    Q.Ra = Ra_fit;%0.8639;%Ra;%1.042367710538608;%Ra; %%I'm hardcoding this for now. for some reason FM doesnt provide measurements close to real unless divide by 2                     Ttradi = real(Q.bb./(Q.aa-lnQ));
    Q.GR = dfacR ; % ISSI recommend
    Q.GRa = dfacRa;
disp('R is calibrated ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % total transmission air + aerosol 
[alpha_mol] = Transmission(Q);
Q.alpha_mol = alpha_mol;

%% Estimating background and lidar constant wrt a priori 

    C = estimations(Q);% Q.OVa = ones(1,length(Q.Ta));
    Q.CL = C.CJL;
    Q.CLa =C.CJLa;
% % Q.CL = 3.8362e+19 ;
% % Q.CLa= 4.6099e+15;
Q.CovCL = (1 .* (Q.CL)).^2;%sqrt(Q.CL);
Q.CovCLa = (1 .* (Q.CLa)).^2;%sqrt(Q.CL);

% load('OverlapSham.mat')
% OVnw = interp1(OverlapSham.z,OverlapSham.OVsmooth,Q.Zret,'linear');
% 
% load('ralmoFixedOverlap.mat')
% OVnw = interp1(ralmoO.zoverlap,ralmoO.overlap,Q.Zret,'linear');
% OVnw(isnan(OVnw))=1;
% Q.OVa = OVnw;
% %  Q.OVa = ones(1,length(Q.Ta));
% Q.OVlength = length(Q.OVa);
% Q.COVa = OVCov(Q.Zret,Q.OVa);





                           Q.CovBJLa = ((Y.bg_JL_stda)).^2; % day time
                           Q.CovBJHa = ((Y.bg_JH_stda)).^2;


                                        if flag ==1
                                        Q.CovBJL = ((Y.bg_JL_std)).^2; % day time
                                        Q.CovBJH = ((Y.bg_JH_std)).^2;
                                        load('OVDay.mat')
                                        OVnw = interp1(OVDay.Z,OVDay.OV,Q.Zret,'linear');
                                        OVnw(isnan(OVnw))=1;
                                        Q.OVa = OVnw;
                                        %  Q.OVa = ones(1,length(Q.Ta));
                                        Q.OVlength = length(Q.OVa);
                                        Q.COVa = OVCov(Q.Zret,Q.OVa);
                                        disp('Daytime retrieval')
                                        else 
                                        Q.CovBJL = ((Y.bg_JL_std/sqrt(Y.bg_length2))).^2;
                                        Q.CovBJH = ((Y.bg_JH_std/sqrt(Y.bg_length1))).^2;
%                                         load('ralmoFixedOverlap.mat')
%                                         OVnw = interp1(ralmoO.zoverlap,ralmoO.overlap,Q.Zret,'linear');
                                        %                                         load('OVNight.mat')
                                        %                                         OVnw = interp1(OVNight.Z,OVNight.OV,Q.Zret,'linear');
                                        load('OVDay.mat')
                                        OVnw = interp1(OVDay.Z,OVDay.OV,Q.Zret,'linear');
                                        OVnw(isnan(OVnw))=1;
                                        Q.OVa = OVnw;
                                        Q.OVlength = length(Q.OVa);
                                        Q.COVa = OVCov(Q.Zret,Q.OVa);

                                        disp('Nighttime retrieval')
                                        end 

%%
                        % this need to be done if there is any zeros in the real measurements
                        % smooth the signal over 1
% figure;plot(Q.Zret./1000,Q.OVa)                    
                        Q.JHnew(Q.JHnew<=0)= round(rand(1)*10);
                        Q.JHnewa(Q.JHnewa<=0)= round(rand(1)*10);
                        Q.JLnew(Q.JLnew<=0)= round(rand(1)*10);
                        Q.JLnewa(Q.JLnewa<=0)= round(rand(1)*10);

JHreal = Q.JHnew'; JLreal = Q.JLnew';  JHrealan = Q.JHnewa';    JLrealan = Q.JLnewa';


 Q.JHnew =JHreal;  Q.JLnew=JLreal ;  Q.JHnewa =JHrealan ;   Q.JLnewa= JLrealan;

                        Q.y = [Q.JHnew Q.JLnew Q.JHnewa Q.JLnewa]';



             [JHv,go11] =bobpoissontest(JHreal,Q.Zmes2,b1);
             [JLv,go] =bobpoissontest(JLreal,Q.Zmes2,b1);
          
             r1 = ones(1,go11-1).* JHv(1);
             r2 = ones(1,go11-1).* JHv(end);
             r3 = ones(1,go-1).* JLv(1);
             r4 = ones(1,go-1).* JLv(end);
             Q.JHv = [r1 JHv r2];
             Q.JLv = [r3 JLv r4];




            
            
        for i = 1: length(Q.JLv)
            if Q.Zmes2(i) <= 6000
                Q.YY(i) = Q.JLv(i);
            else
                Q.YY(i) = JLreal(i);
            end
        end

        for i = 1: length(Q.JHv)
            if  Q.Zmes2(i) <= 6000
                Q.YYY(i) = Q.JHv(i);
            else
                Q.YYY(i) = JHreal(i);
            end
        end

for i =1:length(Q.JLnew)
    if Q.JLnew(i) <15
         Q.YY(i) = 15;
        Q.JLnew(i) = Q.JLnew(i) + rand*sqrt(20);
    end
end
for i =1:length(Q.JHnew)
    if Q.JHnew(i) <25
         Q.YYY(i) = 25;
        Q.JHnew(i) = Q.JHnew(i) + rand*sqrt(20);
    end
end



Q.YYa = 0.0025.*ones(1,length(Q.JLnewa)); 
Q.YYYa = 0.0025.*ones(1,length(Q.JHnewa));
%                 Q.YYa = Y.YYa(ANalt>=alt_a0 & ANalt <=alt_af);
%                 Q.YYYa = Y.YYYa(ANalt>=alt_a0 & ANalt <=alt_af);
%                 Q.YYa =Q.YYa';
%                 Q.YYYa =Q.YYYa';
                

Q.Yvar =[Q.YYY Q.YY Q.YYYa Q.YYa];
Q.yvar = diag(Q.Yvar);
                
                



disp('Estimations for CJL, backgrounds and overlap done ')
disp('makeQ complete ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



end





