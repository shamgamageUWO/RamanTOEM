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
Q.coaddalt = 30;
Q.Rate = 30;%Hz
Q.t_bin = 60;%s
Q.altbinsize = 3.75;%m
Q.Clight = 299792458; %ISSI value
Q.ScaleFactor = 150/3.75;
Q.shots = 1800;
Q.deadtime = 4e-9; % 4ns
Q.deltaT = 10; %2 K
Q.g0a=90*10^-3;%m % this is to create a priori overlap
Q.g0real=100*10^-3;%m % this is to create real overlap
Q.deltatime = 30;

disp('All the constants are ready')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load raw measurements
[Y] = makeY(Q);
JHnew = Y.JH;
JLnew = Y.JL;
alt = Y.alt;
Q.F  = 1800.*Q.deltatime.*Q.coaddalt.* (Y.binsize./150);  % this is the unit conversion constant between MHz to counts
Q.f = 1./Q.F; % conversion 
% [JHnew,JLnew,alt]=rawcountsRALMOnew(Q);
Q.JHnew= JHnew(alt>=500);
Q.JLnew= JLnew(alt>=500);
Q.alt = alt(alt>=500);
disp('Loaded RALMO measurements ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% R is calibrated wrt sonde profiles
[R,aa,bb] = Rcalibration(Q); 
Q.aa= aa;
Q.bb =bb;
Q.R = R;%R;%0.17;
disp('R is calibrated ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define grid sizes
Q.Zmes = Q.alt';% Measurement grid
Q.Zret = Q.Zmes(1):(Q.Zmes(2)-Q.Zmes(1))*4:70000;% Retrieval grid
disp('Defined grids ')
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
[temp, press, dens, alt] = US1976(Q.date_in, Q.time_in, Q.Zret); 
Q.Ta = temp; % for now im adding 2K to test
Q.Ti = interp1(Q.Zret,Q.Ta,Q.Zmes,'linear');
Q.Pressi =interp1(Q.Zret,press,Q.Zmes,'linear');
Q.rho = Q.Pressi./(Rsp.*Q.Ti);
Q.Nmol = (NA/M).* Q.rho ; % mol m-3

disp('a priori temperature profile is loaded ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Estimating background and lidar constant wrt a priori 
[CJL, CJH,Bg_JL_real,Bg_JH_real,bg_JL_std,bg_JH_std,bg_length,OV] = estimations(Q);
Q.OVa = OV;
Q.OVlength = length(Q.OVa);
Q.CL = CJL;%(2.9e+18);%1.449192680052850e+18;%.*(1+1e-14);
Q.Bg_JH_real = Bg_JH_real; % revisit
Q.Bg_JL_real = Bg_JL_real;
Q.BaJL = Q.Bg_JL_real;%0.297350746852139; % change later
Q.BaJH = Q.Bg_JH_real;%4.998109499057194e-04;
Q.CovCL = (0.01 .* Q.CL).^2;%sqrt(Q.CL);

if flag ==1
Q.CovBJL = (bg_JL_std).^2; % day time
Q.CovBJH = (bg_JH_std).^2;
disp('Daytime retrieval')
else 
Q.CovBJL = (bg_JL_std/sqrt(bg_length)).^2;
Q.CovBJH = (bg_JH_std/sqrt(bg_length)).^2;
disp('Nighttime retrieval')
end 

% this need to be done if there is any zeros in the real measurements
% smooth the signal over 1
JHreal = Q.JHnew';
JHreal(JHreal<=0)= rand();
% JHreal(end) = JHreal(end-1);
JLreal = Q.JLnew';
JLreal(JLreal<=0)= rand();
% smmohtenJH = smooth(JHreal,100);
% smmohtenJL = smooth(JLreal,100);
% ysmoothen= [smmohtenJH' smmohtenJL']';

Q.y = [JHreal JLreal]';
%  Q.yvar = diag(ysmoothen);
Q.yvar = diag(Q.y);

Q.n1=length(JHreal);
Q.n2=length(JLreal);

disp('Estimations for CJL, backgrounds and overlap done ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






end
