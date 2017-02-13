function [Q,x] = makeQsham( date_in,time_in,flag)
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


%% Altitudes 
% Note that Zret can be in a greater range that Zmes
Q.Zmes = 30:3.75:56250;% Measurement grid
Q.Zret = 30:3.75:56250;% Retrieval grid

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
Q.coaddalt = 20;
Q.Rate = 30;%Hz
Q.t_bin = 60;%s
Q.altbinsize = 3.75;%m
Q.Clight = 299792458; %ISSI value
Q.ScaleFactor = 150/3.75;
Q.shots = 1800;
Q.deadtime = 4e-9;
Q.deltaT = 0; %2 K

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This is to find the calibration const, R and backgrounds from real measurements.
%% Note that R = CJH/CJL, (not the fitted value)
[CJL, CJH, R,Bg_JL_real,Bg_JH_real,bg_JL_std,bg_JH_std,bg_length]  = calibration(Q);
Q.CL = CJL;%(2.9e+18);%1.449192680052850e+18;%.*(1+1e-14);
Q.R = R;%R;%0.17;
Q.Bg_JH_real = Bg_JH_real; % revisit
Q.Bg_JL_real = Bg_JL_real;
Q.BaJL = Q.Bg_JL_real;%0.297350746852139; % change later
Q.BaJH = Q.Bg_JH_real;%4.998109499057194e-04;
Q.CovCL = (0.1 .* Q.CL).^2;%sqrt(Q.CL);
% Q.CovCH = 100;%sqrt(Q.CH);
% Q.CovBJL = (0.1.*bg_JL_mean).^2;
% Q.CovBJH = (0.1*bg_JH_mean).^2;

if flag ==1
Q.CovBJL = (bg_JL_std).^2; % day time
Q.CovBJH = (bg_JH_std).^2;
else 
Q.CovBJL = (bg_JL_std/sqrt(bg_length)).^2;
Q.CovBJH = (bg_JH_std/sqrt(bg_length)).^2;
end 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% A priori 

%msis data for temperature
% [Tmsis, pmsis,zmsis]= msisRALMO;
% % Tmsis = Tmsis;
%  Q.Ta = interp1(zmsis,Tmsis,Q.Zret,'linear');
%  Q.Ti = interp1(Q.Zret,Q.Ta,Q.Zmes,'linear');
%  Q.Pressi = interp1(zmsis,pmsis,Q.Zmes,'linear');
%  Q.rho = Q.Pressi./(Rsp.*Q.Ti);
% 
% [Tsonde,Zsonde,Psonde] = get_sonde_RS92(Q.date_in,Q.time_in);
% Q.Ta = interp1(Zsonde,Tsonde,Q.Zret,'linear'); % this should be in x vector
% Q.Ti = interp1(Q.Zret,Q.Ta,Q.Zmes,'linear');
% Q.Pressi =interp1(Zsonde,Psonde,Q.Zmes,'linear');
% Q.rho = Q.Pressi./(Rsp.*Q.Ti);

% US temperature model
 
 [temp, press, dens, alt] = US1976(Q.date_in, Q.time_in, Q.Zret); 
Q.Ta = temp + Q.deltaT; % for now im adding 2K to test
Q.Ti = interp1(Q.Zret,Q.Ta,Q.Zmes,'linear');
Q.Pressi =interp1(Q.Zret,press,Q.Zmes,'linear');
Q.rho = Q.Pressi./(Rsp.*Q.Ti);
Q.Nmol = (NA/M).* Q.rho ; % mol m-3


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This section is to generate synthetic measurements using the forward model
Q.Treal = temp;
x = [Q.Treal Q.BaJH Q.BaJL Q.CL]; % feed T_US to generate synthetic measurements
[JL,JH,A_Zi,B_Zi,Diff_JL_i,Diff_JH_i,T_US]=forwardmodelTraman(Q,x);
JLreal = NoiseP(JL);
JHreal = NoiseP(JH);

JLreal(JLreal==0)= 1;
JHreal(JHreal==0)= 1;

Q.y = [JHreal JLreal]';
Q.yvar = diag(Q.y);
% %  JLreal = JL+ sqrt(JL(Q.Zmes==4000))*randn(size(JL));%NoiseP(JL);
% %  JHreal = JH +sqrt(JL(Q.Zmes==4000))*randn(size(JH));%NoiseP(JH);
% %  figure;plot(JHreal,Q.Zmes./1000,'r',JHreal,Q.Zmes./1000,'b')
 Q.noiseJL = JLreal - JL;
 Q.noiseJH = JHreal - JH;
% [JLreal,JHreal,T_US,CL,CH,Diff_JH_i,Diff_JL_i,A_Zi,Pressi,noisejl,noisejh]=realmeasurements(Q);
% Q.Treal = T_US;
% Q.noiseJL = noisejl;
% Q.noiseJH = noisejh;
% Q.yvar = eye(length(Q.y)).*(sqrt(JLreal(Q.Zmes==4000)));

Q.n1=length(JHreal);
Q.n2=length(JLreal);

end
