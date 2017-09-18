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
% Q.Rate = 30;%Hz
Q.t_bin = 60;%s
Q.altbinsize = 3.75;%m
Q.Clight = 299792458; %ISSI value
Q.ScaleFactor = 150/3.75;
Q.shots = 1800;
Q.deadtime = 3.8e-9;% 4ns
Q.deltaT = 10; %2 K
Q.g0a=90*10^-3;%m % this is to create a priori overlap
Q.g0real=100*10^-3;%m % this is to create real overlap
Q.deltatime = 30;
Q.Rate = 1800; 
Q.f = Q.Clight ./ (2.*(Q.Rate).*Q.altbinsize);

disp('All the constants are ready')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load raw measurements
[Y] = makeY(Q);
JHnew = Y.JH;
JLnew = Y.JL;
alt = Y.alt;
Eb = Y.Eb;
Q.binzise = Y.binsize;
Q.Eb = Eb(alt>=1500);
Q.Eb(Q.Eb <=0)= rand();
Q.JHnew= JHnew(alt>=1500);
Q.JLnew= JLnew(alt>=1500);
Q.alt = alt(alt>1500);
Q.JL_DS = Y.JL_DS(alt>=1500);
Q.JH_DS = Y.JH_DS(alt>=1500);

Q.BaJL=  Y.bgJL;
Q.BaJH = Y.bgJH;
Q.bg_JL_std = Y.bg_JL_std;
Q.bg_JH_std = Y.bg_JH_std;
Q.bg_length1 = Y.bg_length1;
Q.bg_length2 = Y.bg_length2;

disp('Loaded RALMO measurements ')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define grid sizes
Q.Zmes = Q.alt';% Measurement grid
Q.Zret = Q.Zmes(1):(Q.Zmes(2)-Q.Zmes(1))*10:70000;% Retrieval grid
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

%%%%%






% Calculate the aerosol attenuation
[alphaAer] = asrSham(Q);
Q.alpha_aero = alphaAer;
% total transmission air + aerosol 
Q.Tr = Total_Transmission(Q);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% R is calibrated wrt sonde profiles
 [R] = Rcalibration(Q); 
% Q.aa= aa;
% Q.bb =bb;
 Q.R = R;%R;%0.17;
% Q.aa= 0.4981;
% Q.bb =408.6183;
% Q.R = 0.7913;%R;%0.17;
disp('R is calibrated ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Estimating background and lidar constant wrt a priori 
% [CJL, CJH,OV] = estimations(Q);
Q.OVa = ones(1,length(Q.Zret));%
Q.OVlength = length(Q.OVa);
Q.CL = 8e19;%(2.9e+18);
Q.CovCL = (0.1 .* (Q.CL)).^2;%sqrt(Q.CL);



if flag ==1
Q.CovBJL = ((Q.bg_JL_std)).^2; % day time
Q.CovBJH = ((Q.bg_JH_std)).^2;
disp('Daytime retrieval')
else 
Q.CovBJL = ((Q.bg_JL_std/sqrt(Q.bg_length2))).^2;
Q.CovBJH = ((Q.bg_JH_std/sqrt(Q.bg_length1))).^2;
disp('Nighttime retrieval')
end 

% this need to be done if there is any zeros in the real measurements
% smooth the signal over 1
% JHreal = Q.JHnew';
Q.JHnew(Q.JHnew<=0)= rand();
% JHreal(end) = JHreal(end-1);
% JLreal = Q.JLnew';
Q.JLnew(Q.JLnew<=0)= rand();


% smmohtenJH = smooth(JHreal,100); % smoothing covariance to smooth the envelop cover
% smmohtenJL = smooth(JLreal,100);
% ysmoothen= [smmohtenJH' smmohtenJL']';
Q.y = [Q.JHnew;Q.JLnew];

%  Q.yvar = diag(ysmoothen);


% Variance need to be fixed as below: 
% below 2 km use the Var from the piecewise code
% above 2 km use the counts

% % Q.yvar = diag(Q.y);
            [JHv,go] =bobpoissontest(Q.JHnew',Q.Zmes);
            [JLv,go] =bobpoissontest(Q.JLnew',Q.Zmes);

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
            if Q.Zmes(i) <= 100
                YY(i) = Q.JLv(i);
            else
                YY(i) = Q.JLnew(i);
            end
        end

        for i = 1: length(Q.JHv)
            if  Q.Zmes(i) <= 100
                YYY(i) = Q.JHv(i);
            else
                YYY(i) = Q.JHnew(i);
            end
        end

       

%           Q.Yvar =[smmohtenJH;smmohtenJL];
%         for ii = 1:length(Q.y)
%             if Q.y(ii) <= 15
%                 Q.Yvar(ii)=15;
%                 Q.y(ii)=Q.y(ii)+randn(1)*sqrt(Q.Yvar(ii));
%             end
%         end
%         Q.yvar = diag(Q.Yvar);
%         Q.Yvar =[JHreal JLreal];
%     Q.yvar = diag(Q.Yvar);
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
 Q.Yvar =[YYY YY];
Q.yvar = diag(Q.Yvar);

Q.n1=length(Q.JHnew);
Q.n2=length(Q.JLnew);

disp('Estimations for CJL, backgrounds and overlap done ')
disp('makeQ complete ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



end

