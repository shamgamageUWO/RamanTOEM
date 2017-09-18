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
Q.Csum =  2.8077e+18;
Q.CLfac = 10^-2;
Q.CHfac = 10^-2;
Q.coaddalt = 2;
% Q.Rate = 30;%Hz
Q.t_bin = 60;%s
Q.altbinsize = 3.75;%m
Q.Clight = 299792458; %ISSI value
Q.ScaleFactor = 150/3.75;
Q.shots = 1800;

Q.deadtimeJL = 3.8e-9; % 4ns
Q.deadtimeJH = 3.8e-9; % 4ns
Q.CovDTJL = (0.1.*Q.deadtimeJL).^2;
Q.CovDTJH = (0.1 .*Q.deadtimeJH).^2;

Q.deltaT = 10; %2 K
Q.g0a=90*10^-3;%m % this is to create a priori overlap
Q.g0real=100*10^-3;%m % this is to create real overlap
Q.deltatime = 30;
Q.Rate = 1800; 

disp('All the constants are ready')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load raw measurements
 [Y] = makeY(Q);
% % Digital measurements 2km above
% JHnew = Y.JH;
% JLnew = Y.JL;
% alt = Y.alt;
% Eb = Y.Eb;
% Q.binzise = Y.binsize;
% Q.Eb = Eb(alt>=2000);
% Q.Eb(Q.Eb <=0)= rand();
% Q.JHnew= JHnew(alt>=2000);
% Q.JLnew= JLnew(alt>=2000);
% Q.alt = alt(alt>=2000);
% Q.Zmes2 = Q.alt';
% 
% % Analog measurements
 Q.JHreal = Y.JHa;
 Q.JLreal = Y.JLa;
% Eba = Y.Eba;
 Q.ANalt = Y.alt_an;
% % Q.Eba = Eba(alt>=50 & alt<6000);
% % Q.Eba(Q.Eba <=0)= rand();
% % Q.JHnewa= JHnewa(alt>=50 & alt<5000);
% % Q.JLnewa= JLnewa(alt>=50 & alt<5000);
% % % Q.ANalt = ANalt(alt>=50 & alt<5000);
% Q.Eba = Eba(ANalt>=100 & ANalt <= 10000);
% Q.Eba(Q.Eba <=0)= rand();
% Q.JHnewa= JHnewa(ANalt>=100 & ANalt <=10000);
% Q.JLnewa= JLnewa(ANalt>=100 & ANalt <=10000);
% Q.ANalt = ANalt(ANalt>=100);
% % Q.Zmes = Q.ANalt';
% Q.Zmes1 = ANalt(ANalt>=100 & ANalt <= 10000);
% Q.Zmes1 = Q.Zmes1';
% Q.Zmes = Q.Zmes1;
% %  Q.YYYa = Y.YYYa(ANalt>=100 & ANalt <= 5000);
%  Q.YYa  = Y.YYa(ANalt>=100 & ANalt <= 5000);


% Q.BaJL = Y.bgJL;%0.297350746852139; % change later
% Q.BaJH = Y.bgJH;%4.998109499057194e-04;
Q.BaJLa = 119;%Y.bgJLa;%0.297350746852139; % change later
Q.BaJHa = 61;%Y.bgJHa;%4.998109499057194e-04;
% Q.BaJLa = 10;%0.297350746852139; % change later
% Q.BaJHa = 20;%4.998109499057194e-04;
disp('Loaded RALMO measurements ')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% N = length(JHnew);
% 
% % %% Fix off set 
% zAoffset = 10; % bins ie 10*3.75 = 37.5m 
% Q.JHnew= Q.JHnew(1:N-zAoffset); % already in counts ./ (y2HzRaw./1e6);
% Q.JLnew = Q.JLnew(1:N-zAoffset); % ./ (y2HzRaw./1e6);
% Q.JHnewa = Q.JHnewa(1+zAoffset:end);
% Q.JLnewa = Q.JLnewa(1+zAoffset:end);
% 
% Q.n1=length(Q.JHnew);
% Q.n2=length(Q.JLnew);
% Q.n3=length(Q.JHnewa);
% Q.n4=length(Q.JLnewa);

%% Define grid sizes
% Q.Zmes1 = Q.ANalt';
% Q.d_alti_Diff = length(Q.Zmes)-length(Q.Zmes2);
% Q.Zmes1 = Q.Zmes1(1+zAoffset:end);
% Q.Zmes2 = Q.Zmes2(1:Q.n1-zAoffset);
% Q.Zmes = Q.Zmes1;%[Q.Zmes1 Q.Zmes2];% Measurement grid
% Q.Zmes = Q.Zmes(1:N-zAoffset);
% Z1 = Q.Zmes(1):(Q.Zmes(2)-Q.Zmes(1))*10:10000;% Retrieval grid
Q.Zmes1 = 100:10:12000;
Q.Zmes = Q.Zmes1;
Q.Zret = Q.Zmes1(1):(Q.Zmes1(2)-Q.Zmes1(1))*10:12000;% Retrieval grid
% Q.Zret = [Z1 Z2];% Retrieval grid
disp('Defined grids ')
% Yc = [Q.JHnewa;Q.JHnew]
% figure;semilogx(Yc,Q.Zmes./1000)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  a priori temperatures

%msis data for temperature
% [Tmsis, pmsis,zmsis]= msisRALMO;
% % Tmsis = Tmsis;
%  Q.Ta = interp1(zmsis,Tmsis,Q.Zret,'linear');
%  Q.Ti = interp1(Q.Zret,Q.Ta,Q.Zmes,'linear');
%  Q.Pressi = interp1(zmsis,pmsis,Q.Zmes,'linear');
%  Q.rho = Q.Pressi./(Rsp.*Q.Ti);
 [Tsonde,Zsonde,Psonde] = get_sonde_RS92(Q.date_in,Q.time_in);
  Zsonde = Zsonde-491;
  Q.Treal = interp1(Zsonde,Tsonde,Q.Zret,'linear'); % this should be in x vector
%   Q.Ti = interp1(Q.Zret,Q.Ta,Q.Zmes,'linear');
%  Q.Pressi =interp1(Zsonde,Psonde,Q.Zmes,'linear');
%  Q.rho = Q.Pressi./(Rsp.*Q.Ti);

% US temperature model
% load('USdata.mat');
% Q.Ta = Ta; Q.Ti = Ti; Q.Pressi = Pressi; Q.Nmol = Nmol; Q.rho = rho;
            [temp, press, dens, alt] = US1976(Q.date_in, Q.time_in, Q.Zret);
            Q.Ta = temp; % for now im adding 2K to test
            Q.Ti = interp1(Q.Zret,Q.Ta,Q.Zmes1,'linear');
            Q.Pressi =interp1(Q.Zret,press,Q.Zmes1,'linear');
            Q.rho = Q.Pressi./(Rsp.*Q.Ti);
            Q.Nmol = (NA/M).* Q.rho ; % mol m-3

disp('a priori temperature profile is loaded ')

%%%%%






% % Calculate the aerosol attenuation
[alphaAer] = asrSham(Q);
Q.alpha_aero = alphaAer;
% total transmission air + aerosol 
Q.Tr = Total_Transmission(Q);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% R is calibrated wrt sonde profiles
%  [Ra] = Rcalibration(Q); 
Q.Ra = 0.8639;%Ra;%1.042367710538608;%Ra; %%I'm hardcoding this for now. for some reason FM doesnt provide measurements close to real unless divide by 2
disp('R is calibrated ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Estimating background and lidar constant wrt a priori 

% [CJLa,OV] = estimations(Q);% Q.OVa = ones(1,length(Q.Ta));
%   Q.OVa = OV;
 load('ovmodeldata.mat');
 OVnw = interp1(z,epsi,Q.Zret,'linear');
 OVnw(isnan(OVnw))=1;
 Q.OVa =OVnw;
%  Q.OVa = ones(1,length(Q.Ta));
Q.OVlength = length(Q.OVa);
Q.COVa = OVCov(Q.Zret,Q.OVa);
Q.CLa = 1.812939733130996e16;%CJLa;
Q.CovCLa = (1 .* (Q.CLa)).^2;%sqrt(Q.CL);


                           Q.CovBJLa = ((Y.bg_JL_stda)).^2; % day time
                           Q.CovBJHa = ((Y.bg_JH_stda)).^2;

%%
% load synthetic measurements and add noise
x_a = [Q.Treal Q.OVa Q.BaJHa Q.BaJLa Q.CLa];
[JLa,JHa]=forwardmodelTraman(Q,x_a);
Q.JLnewa = awgn(JLa,100,'measured');
Q.JHnewa = awgn(JHa,100,'measured');

%                         Q.JHnew(Q.JHnew<=0)= round(rand(1)*10);
                        Q.JHnewa(Q.JHnewa<=0)= round(rand(1)*10);
%                         Q.JLnew(Q.JLnew<=0)= round(rand(1)*10);
                        Q.JLnewa(Q.JLnewa<=0)= round(rand(1)*10);

% JHreal = Q.JHnew'; JLreal = Q.JLnew';  JHrealan = Q.JHnewa';    JLrealan = Q.JLnewa';
% 
% 
%  Q.JHnew =JHreal;  Q.JLnew=JLreal ;  Q.JHnewa =JHrealan ;   Q.JLnewa= JLrealan;

                        Q.y = [Q.JHnewa Q.JLnewa]';
                        
%                         
% Q.n1=length(Q.JHnew);
% Q.n2=length(Q.JLnew);
Q.n3=length(Q.JHnewa);
Q.n4=length(Q.JLnewa);
% Variance need to be fixed as below: 
% below 2 km use the Var from the piecewise code
% above 2 km use the counts


 [JHav,go1] =bobpoissontest(Q.JHnewa,Q.Zmes1,12);
 [JLav,go2] =bobpoissontest(Q.JLnewa,Q.Zmes1,12);

            ar1 = ones(1,go1-1).* JHav(1);
            ar2 = ones(1,go1-1).* JHav(end);
            ar3 = ones(1,go2-1).* JLav(1);
            ar4 = ones(1,go2-1).* JLav(end);
            Q.JHav = [ar1 JHav ar2];
            Q.JLav = [ar3 JLav ar4];
            
%             slope = (((0.05-1).*Q.Zmes1)/(Q.Zmes1(end)))+1;
% slope1 = (((0.05-1).*Q.Zmes1)/(Q.Zmes1(end)))+1;

%                 for i = 1: length(Q.JLav)
%                     if Q.Zmes2(i) <= 4000
%                         Q.YYa(i) = 0.01.*Q.JLav(i);
%                     else
%                         Q.YYa(i) = 20.*Q.JLav(i);
%                     end
%                 end
%                 
%                 for i = 1: length(Q.JHav)
%                     if  Q.Zmes2(i) <= 4000
%                         Q.YYYa(i) = 0.01.*Q.JHav(i);
%                     else
%                         Q.YYYa(i) = 20.*Q.JHav(i);
%                     end
%                 end

            


% % HEre I linearlize the covariance
  slope = (((0.008-0.5).*Q.Zmes1)/(Q.Zmes1(end)))+.5;
% slope1 = (((0.0008-0.5).*Q.Zmes1)/(Q.Zmes1(end)))+0.5;
%     Q.YYYa = slope.*smmohtenJHa';
%     Q.YYa  =  slope.*smmohtenJLa';
% %  slope=1;
 Q.YYYa = Q.JHav;
  Q.YYa = Q.JLav;

            Q.Yvar =[Q.YYYa Q.YYa];
%            Q.Yvar =[smmohtenJH' smmohtenJL' Q.YYYa Q.YYa];
                Q.yvar = diag(Q.Yvar);
                
                



disp('Estimations for CJL, backgrounds and overlap done ')
disp('makeQ complete ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



end





