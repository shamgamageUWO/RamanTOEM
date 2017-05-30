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
Q.coaddalt = 10;
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
Q.Rate = 1800; 

disp('All the constants are ready')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load raw measurements
[Y] = makeY(Q);
JHnew = Y.JH;
JLnew = Y.JL;
alt = Y.alt;
Q.binzise = Y.binsize;
Q.JHnew= JHnew(alt>=500);
Q.JLnew= JLnew(alt>=500);
Q.alt = alt(alt>=500);
disp('Loaded RALMO measurements ')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define grid sizes
Q.Zmes = Q.alt';% Measurement grid
Q.Zret = Q.Zmes(1):(Q.Zmes(2)-Q.Zmes(1))*20:70000;% Retrieval grid
disp('Defined grids ')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% R is calibrated wrt sonde profiles
[R,aa,bb] = Rcalibration(Q); 
Q.aa= aa;
Q.bb =bb;
Q.R = R;%R;%0.17;
disp('R is calibrated ')

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
[CJL, CJH,Bg_JL_real,Bg_JH_real,bg_JL_std,bg_JH_std,bg_length1,bg_length2,OV] = estimations(Q);
Q.OVa = OV;
Q.OVlength = length(Q.OVa);
Q.CL = CJL;%(2.9e+18);
Q.Bg_JH_real = Bg_JH_real; % revisit
Q.Bg_JL_real = Bg_JL_real;
Q.BaJL = Q.Bg_JL_real;%0.297350746852139; % change later
Q.BaJH = Q.Bg_JH_real;%4.998109499057194e-04;
Q.CovCL = (0.01 .* (Q.CL)).^2;%sqrt(Q.CL);

            %%%Q.CovCL = (0.01 .* log(Q.CL)).^2;%sqrt(Q.CL);

if flag ==1
Q.CovBJL = ((bg_JL_std)).^2; % day time
Q.CovBJH = ((bg_JH_std)).^2;
disp('Daytime retrieval')
else 
Q.CovBJL = ((bg_JL_std/sqrt(bg_length2))).^2;
Q.CovBJH = ((bg_JH_std/sqrt(bg_length1))).^2;
disp('Nighttime retrieval')
end 

% this need to be done if there is any zeros in the real measurements
% smooth the signal over 1
JHreal = Q.JHnew';
JHreal(JHreal<=0)= rand();
% JHreal(end) = JHreal(end-1);
JLreal = Q.JLnew';
JLreal(JLreal<=0)= rand();


smmohtenJH = smooth(JHreal,100); % smoothing covariance to smooth the envelop cover
smmohtenJL = smooth(JLreal,100);
% ysmoothen= [smmohtenJH' smmohtenJL']';
Q.y = [JHreal JLreal]';
% Q.yvar = diag(ysmoothen);


% Variance need to be fixed as below: 
% below 2 km use the Var from the piecewise code
% above 2 km use the counts

% Q.yvar = diag(Q.y);
            [JHv,go] =bobpoissontest(JHreal,Q.Zmes);
            [JLv,go] =bobpoissontest(JLreal,Q.Zmes);
%             r1 = interp1(JHv, -3:0, 'linear', 'extrap');
%             r2 = ones(1,go-1).* JHv(end);
%             r3 = JLreal(1:go-1);
%             r4 = ones(1,go-1).* JLv(end);
% r1 = interp1(JHv, -(go-2):0, 'linear', 'extrap');
% r2 = interp1(JHv, JHv(end):go-1, 'linear', 'extrap');
% r3 = interp1(JLv, -(go-2):0, 'linear', 'extrap');
% r4 = interp1(JLv, JLv(end):go-1, 'linear', 'extrap');
            r1 = ones(1,go-1).* JHv(1);
            r2 = ones(1,go-1).* JHv(end);
            r3 = ones(1,go-1).* JLv(1);
            r4 = ones(1,go-1).* JLv(end);
            Q.JHv = [r1 JHv r2];
            Q.JLv = [r3 JLv r4];
% figure;plot(Q.JLv,Q.Zmes./1000,'r',JLreal,Q.Zmes./1000,'b')
% xlabel('Log of Variance')
% ylabel('Alt(km)')
% %  h1
% % % 
% figure;plot(Q.JHv,Q.Zmes./1000,'r',JHreal,Q.Zmes./1000,'b')
% xlabel('Log of Variance')
% ylabel('Alt(km)')

% X1 =  ((Q.JLv'-Q.y(length(Q.JLv)+1:end)));
% k1 = find(abs(X1)<500);
% indi1 = k1(1);
% h1 = Q.Zmes(indi1)
% 
% X2 =  ((Q.JHv'-Q.y(1:length(Q.JHv))));
% k2 = find(abs(X2)<100);
% indi2 = k2(1);
% h2 = Q.Zmes(indi2)

% % X1 =  ((Q.JLv'-Q.y(length(Q.JLv)+1:end))./(Q.JLv')).*100;
% % k1 = find(abs(X1)<50);
% % indi1 = k1(1);
% % h1 = Q.Zmes(indi1)
% % 
% % X2 =  ((Q.JHv'-Q.y(1:length(Q.JHv)))./(Q.JHv')).*100;
% % k2 = find(abs(X2)<50);
% % indi2 = k2(1);
% % h2 = Q.Zmes(indi2)

        for i = 1: length(Q.JLv)
            if Q.Zmes(i) <= 7000
                YY(i) = Q.JLv(i);
            else
                YY(i) = smmohtenJL(i);
            end
        end

        for i = 1: length(Q.JHv)
            if  Q.Zmes(i) <= 7000
                YYY(i) = Q.JHv(i);
            else
                YYY(i) = smmohtenJH(i);
            end
        end

        Q.Yvar =[YYY YY];
%         Q.Yvar =[JHreal JLreal];
      Q.yvar = diag(Q.Yvar);
% figure;semilogx(Q.Yvar(length(Q.JLv)+1:end),Q.Zmes./1000,'r',JLreal,Q.Zmes./1000,'b')
% xlabel('Log of Variance')
% ylabel('Alt(km)')
% %  h1
% % % 
% figure;semilogx(Q.Yvar(1:length(Q.JLv)),Q.Zmes./1000,'r',JHreal,Q.Zmes./1000,'b')
% xlabel('Log of Variance')
% ylabel('Alt(km)')
%  h2
% % Q.yvar = diag(Q.Yvar);
% % Q.Yvar =[Q.JHv Q.JLv];


Q.n1=length(JHreal);
Q.n2=length(JLreal);

disp('Estimations for CJL, backgrounds and overlap done ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





end
