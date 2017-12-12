function [Q] = makeQsham( date_in,time_in,flag)
% makeQ(in)

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
% Q.Csum =  2.8077e+18;
% Q.CLfac = 10^-2;
% Q.CHfac = 10^-2;
Q.coaddalt = 20;
Q.Rgas = 8.3145;
% Q.Rate = 30;%Hz
Q.t_bin = 60;%s
% Q.altbinsize = 3.75;%m
Q.Clight = 299792458; %ISSI value
% Q.ScaleFactor = 150/3.75;
Q.shots = 1800;
% Q.f = Q.Clight ./ (2.*(Q.Rate).*Q.altbinsize);

Q.deadtimeJH = 3; % 4ns
Q.deadtimeJL = 1.5; % 4ns
Q.CovDTJL = (.1.*Q.deadtimeJL).^2;
Q.CovDTJH = (.1.*Q.deadtimeJH).^2;

% Q.deltaT = 5; %2 K
Q.g0a=90*10^-3;%m % this is to create a priori overlap
Q.g0real=100*10^-3;%m % this is to create real overlap
% Q.deltatime = 30;
Q.Shots = 1800; 
% Q.f = Q.Clight ./ (2.*(Q.Shots).*Q.altbinsize); 
disp('All the constants are ready')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load raw measurements
[Y] = makeY(Q);

Q.deltatime = Y.deltatime;
% Digital measurements 2km above
JHnew = Y.JH;
JLnew = Y.JL;
JL_DS = Y.JL_DS;
JH_DS = Y.JH_DS;
Eb = Y.Eb;
Ebalt = Y.Ebalt;

alt = Y.alt;
Q.binzise = Y.binsize;
Q.JHnew= JHnew(alt>=1000  & alt <=45000);
Q.JLnew= JLnew(alt>=1000 & alt <=45000);
Q.JH_DS =JH_DS(alt>=1000  & alt <=45000);
Q.JL_DS =JL_DS(alt>=1000  & alt <=45000);
Q.alt = alt(alt>=1000  & alt <=45000);
Q.Eb = Eb(Ebalt>=1000  & Ebalt <=45000);
Q.Ebalt = Ebalt(Ebalt>=1000  & Ebalt <=45000);
Q.Zmes2 = Q.alt';
Q.Zmes = Q.Zmes2;
Q.f = 1e6./(Y.F);
Q.BaJL = Y.bgJL;%0.297350746852139; % change later
Q.BaJH = Y.bgJH;%4.998109499057194e-04;
Q.n1=length(Q.JHnew);
Q.n2=length(Q.JLnew);
disp('Loaded RALMO measurements ')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Define grid sizes
% k = find(Q.Zmes<=3000);
% h = k(end);
%  deltaZ = (Q.Zmes(2)-Q.Zmes(1));
% Z1 = Q.Zmes(1):deltaZ*2:Q.Zmes(h);
% Z2= Q.Zmes(h):deltaZ*4:50000;   
%   Q.Zret = [Z1 Z2];
      Q.Zret = Q.Zmes(1):(Q.Zmes(2)-Q.Zmes(1))*5:50000;% Retrieval grid
disp(' Grids Defined')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  a priori temperatures

%msis data for temperature
% [Tmsis, pmsis,zmsis]= msisRALMO;
% % Tmsis = Tmsis;
%  Q.Ta = interp1(zmsis,Tmsis,Q.Zret,'linear');
%  Q.Ti = interp1(Q.Zret,Q.Ta,Q.Zmes,'linear');
%  Q.Pressi = interp1(zmsis,pmsis,Q.Zmes,'linear');
%  Q.rho = Q.Pressi./(Rsp.*Q.Ti);
% [Tsonde,Zsonde,Psonde] = get_sonde_RS92(Q.date_in,Q.time_in);
% Q.Ta = interp1(Zsonde,Tsonde,Q.Zret,'linear'); % this should be in x vector
% Q.Ti = interp1(Q.Zret,Q.Ta,Q.Zmes,'linear');
% Q.Pressi =interp1(Zsonde,Psonde,Q.Zmes,'linear');
% Q.rho = Q.Pressi./(Rsp.*Q.Ti);

% US temperature model
% load('USdata.mat');
% Q.Ta = Ta; Q.Ti = Ti; Q.Pressi = Pressi; Q.Nmol = Nmol; Q.rho = rho;
            [temp, press, dens, alt] = US1976(Q.date_in, Q.time_in, Q.Zret);
            Q.Ta = temp; % for now im adding 2K to test
            Q.Ti = interp1(Q.Zret,Q.Ta,Q.Zmes,'linear');
            lnpress = log(press);
            Pressi =interp1(Q.Zret,lnpress,Q.Zmes,'linear');
            Q.Pressi = exp(Pressi);
            Q.rho = Q.Pressi./(Rsp.*Q.Ti);
            Q.Nmol = (NA/M).* Q.rho ; % mol m-3

obj2 = Gravity(Q.Zmes, 46.82);
Q.grav = obj2.accel;
Q.MoR = (M./Q.Rgas).*ones(size(Q.Ti));
Q.z0 = 35000;            
[Q.Pdigi,p0A] = find_pHSEQ(Q.z0,Q.Zmes,Q.Ti,Q.Pressi,0,Q.grav',Q.MoR);           
disp('a priori temperature profile is loaded ')

[Tsonde,Zsonde,Psonde] = get_Sonde_C50(Q.date_in, Q.time_in);
 Zsonde = Zsonde - 491; % altitude correction isn't required for C50
%  ind =  Zsonde>=0 & Zsonde < 33000;
%  Zsonde = Zsonde(ind);
%  Tsonde = Tsonde(ind);
%  Psonde = Psonde(ind);

%  [Zsonde, sortIndex] = sort(Zsonde);
% Tsonde = Tsonde(sortIndex);
% Psonde = Psonde(sortIndex); 
nn=find(isnan(Tsonde)); %% There is always a nan at the end of the temperature 
Tsonde = Tsonde(1:nn-1);
Psonde = Psonde(1:nn-1);
Zsonde = Zsonde(1:nn-1);

[Zsonde, index] = unique(Zsonde); 
Tsonde = Tsonde(index);
Psonde = Psonde(index);

Q.Tsonde = interp1(Zsonde,Tsonde,Q.Zmes,'linear'); % this goes to Restimation and asr code
Psonde = interp1(Zsonde,log(Psonde),Q.Zmes,'linear'); % 
Q.Psonde = exp(Psonde);
Q.Tsonde2 = interp1(Zsonde,Tsonde,Q.Zret,'linear'); % this goes to CJL estimation
%%%%%

% Calculate the aerosol attenuation NoT USINH+G THIS FOR NOW
%                         [alphaAer, odaer] = asrShamFastCom(Q);
%                          Q.alpha_aero = alphaAer;
%                          Q.odaer = odaer;
%                         % total transmission air 
%                         Q.Tr = Total_Transmission(Q);

[Tr1,Tr2] = TransmissionFastCom(Q);
Q.Tr = Tr2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% R is calibrated wrt sonde profiles
[R,R_fit] = Restimationnew(Q);
Q.R = R_fit;
% Q.R = 0.8359;
disp('R is calibrated ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Estimating background and lidar constant wrt a priori 

[CJL,OV] = estimations(Q);% Q.OVa = ones(1,length(Q.Ta));
%  load('ovmodeldata.mat');
% OVnw = interp1(z,epsi,Q.Zret,'linear');
% OVnw(isnan(OVnw))=1;
% Q.OVa = OVnw;
    Q.OVa = ones(1,length(Q.Ta));
%    Q.OVa = OV;
Q.OVlength = length(Q.OVa);
Q.COVa = OVCov(Q.Zret,Q.OVa);

Q.CL = CJL;
Q.CovCL = (1 .* (Q.CL)).^2;%sqrt(Q.CL);

if flag ==1
    Q.CovBJL = ((Y.bg_JL_std)).^2; % day time
    Q.CovBJH = ((Y.bg_JH_std)).^2;
    %                                         Q.CovBJLa = ((Y.bg_JL_stda)).^2; % day time
    %                                         Q.CovBJHa = ((Y.bg_JH_stda)).^2;
    disp('Daytime retrieval')
else
    Q.CovBJL = ((Y.bg_JL_std/sqrt(Y.bg_length2))).^2;
    Q.CovBJH = ((Y.bg_JH_std/sqrt(Y.bg_length1))).^2;
    %                                          Q.CovBJLa = ((Y.bg_JL_stda/sqrt(Y.bg_length2a))).^2;
    %                                         Q.CovBJHa = ((Y.bg_JH_stda/sqrt(Y.bg_length1a))).^2;
    disp('Nighttime retrieval')
end


                    
                        Q.JHnew(Q.JHnew<=0)= round(rand(1)*10);
                        Q.JLnew(Q.JLnew<=0)= round(rand(1)*10);

                        Q.y = [Q.JHnew ;Q.JLnew];

             [JHv,go1] =bobpoissontest(Q.JHnew',Q.Zmes2,12);
             [JLv,go] =bobpoissontest(Q.JLnew',Q.Zmes2,12);
% 
% 
%             
             r1 = ones(1,go1-1).* JHv(1);
             r2 = ones(1,go1-1).* JHv(end);
             r3 = ones(1,go-1).* JLv(1);
             r4 = ones(1,go-1).* JLv(end);
             Q.JHv = [r1 JHv r2];
             Q.JLv = [r3 JLv r4];



            
             for i = 1: length(Q.JLv)
                 if Q.Zmes2(i) <= 3500
                     Q.YY(i) = Q.JLv(i);
                 else
                     Q.YY(i) =  Q.JLnew(i);
                 end
             end
             
             for i = 1: length(Q.JHv)
                 if  Q.Zmes2(i) <= 3500
                     Q.YYY(i) = Q.JHv(i);
                 else
                     Q.YYY(i) =  Q.JHnew(i);
                 end
             end
             
             
              Q.Yvar =[Q.YYY Q.YY];
             Q.yvar = diag(Q.Yvar);
                
                



disp('Estimations for CJL, backgrounds and overlap done ')
disp('makeQ complete ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load('Temperature20110909.mat');
JHt = Q.JH_DS-Q.BaJH;
JLt = Q.JL_DS-Q.BaJL;

Q_Digi = JLt./JHt;
Tprofiledg = 1./log(Q_Digi);

            y_d = (Q.Tsonde);
            y_d = y_d( Q.Zmes>=4000 & Q.Zmes<=8000);
            x_d = 1./Tprofiledg( Q.Zmes>=4000 & Q.Zmes<=8000);

            ftdg=fittype('a/(x+b)','dependent',{'y'},'independent',{'x'},'coefficients',{'a','b'});
            fodg = fitoptions('method','NonlinearLeastSquares','Robust','On');
            set(fodg, 'StartPoint',[350, 0.3]);


            [f_dg,gofdg] = fit(x_d,y_d',ftdg,fodg);
            Q.a_dg = f_dg.a;
            Q.b_dg = f_dg.b;

% Q.a_dg = 399.8616;
% Q.b_dg = 0.5247;

Tradi= real(Q.a_dg./(1./Tprofiledg +Q.b_dg));
Q.Ttradi = interp1(Q.Zmes,Tradi,Q.Zret,'linear');
% figure;plot(Q.Ttradi,Q.Zmes,Q.Tsonde,Q.Zmes,'r')

end





