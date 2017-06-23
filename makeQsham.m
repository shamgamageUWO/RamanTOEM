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
Q.coaddalt = 20;
Q.Rate = 30;%Hz
Q.t_bin = 60;%s
Q.altbinsize = 3.75;%m
Q.Clight = 299792458; %ISSI value
Q.ScaleFactor = 150/3.75;
Q.shots = 1800;
Q.deadtime = 3.3e-9;% 4ns
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
Eb = Y.Eb;
Q.binzise = Y.binsize;
Q.Eb = Eb(alt>=1500);
Q.Eb(Q.Eb <=0)= rand();
Q.JHnew= JHnew(alt>=1500);
Q.JLnew= JLnew(alt>=1500);
Q.alt = alt(alt>=1500);
disp('Loaded RALMO measurements ')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define grid sizes
Q.Zmes = Q.alt';% Measurement grid
Q.Zret = Q.Zmes(1):(Q.Zmes(2)-Q.Zmes(1))*5:70000;% Retrieval grid
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
% [R,aa,bb] = Rcalibration(Q); 
% Q.aa= aa;
% Q.bb =bb;
% Q.R = R;%R;%0.17;
Q.aa= 0.4981;
Q.bb =408.6183;
Q.R = 0.7913;%R;%0.17;
disp('R is calibrated ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Estimating background and lidar constant wrt a priori 
[CJL, CJH,Bg_JL_real,Bg_JH_real,bg_JL_std,bg_JH_std,bg_length1,bg_length2,OV] = estimations(Q);
Q.OVa = OV;%ones(1,length(OV));%
Q.OVlength = length(Q.OVa);
Q.CL = CJL;%(2.9e+18);
Q.Bg_JH_real = Bg_JH_real; % revisit
Q.Bg_JL_real = Bg_JL_real;
Q.BaJL = Q.Bg_JL_real;%0.297350746852139; % change later
Q.BaJH = Q.Bg_JH_real;%4.998109499057194e-04;
Q.CovCL = (0.5 .* (Q.CL)).^2;%sqrt(Q.CL);

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


smmohtenJH = smooth(JHreal,10); % smoothing covariance to smooth the envelop cover
smmohtenJL = smooth(JLreal,10);
ysmoothen= [smmohtenJH' smmohtenJL']';
Q.y = [JHreal JLreal]';

 Q.yvar = diag(ysmoothen);


% Variance need to be fixed as below: 
% below 2 km use the Var from the piecewise code
% above 2 km use the counts

% % Q.yvar = diag(Q.y);
%             [JHv,go] =bobpoissontest(JHreal,Q.Zmes);
%             [JLv,go] =bobpoissontest(JLreal,Q.Zmes);
% %             r1 = interp1(JHv, -3:0, 'linear', 'extrap');
% %             r2 = ones(1,go-1).* JHv(end);
% %             r3 = JLreal(1:go-1);
% %             r4 = ones(1,go-1).* JLv(end);
% % r1 = interp1(JHv, -(go-2):0, 'linear', 'extrap');
% % r2 = interp1(JHv, JHv(end):go-1, 'linear', 'extrap');
% % r3 = interp1(JLv, -(go-2):0, 'linear', 'extrap');
% % r4 = interp1(JLv, JLv(end):go-1, 'linear', 'extrap');
%             r1 = ones(1,go-1).* JHv(1);
%             r2 = ones(1,go-1).* JHv(end);
%             r3 = ones(1,go-1).* JLv(1);
%             r4 = ones(1,go-1).* JLv(end);
%             Q.JHv = [r1 JHv r2];
%             Q.JLv = [r3 JLv r4];
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

%         for i = 1: length(Q.JLv)
%             if Q.Zmes(i) <= 4000
%                 YY(i) = Q.JLv(i);
%             else
%                 YY(i) = smmohtenJL(i);
%             end
%         end
% 
%         for i = 1: length(Q.JHv)
%             if  Q.Zmes(i) <= 4000
%                 YYY(i) = Q.JHv(i);
% %             else
% %                 YYY(i) = smmohtenJH(i);
% %             end
% %         end
% 
       

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
% % Q.Yvar =[Q.JHv Q.JLv];


Q.n1=length(JHreal);
Q.n2=length(JLreal);

disp('Estimations for CJL, backgrounds and overlap done ')
disp('makeQ complete ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



end


% % % 
% % % % Constants
% % % Q.effi_stokeN2_JH = [0.22742041,0.61706630,1,0.66219893,0.26342483,0.00549319,0];
% % % Q.effi_antiN2_JH = [0.20278330,0.57977270,0.99609541,0.71343372,0.31181249,0.02739112,0];
% % % 
% % % Q.effi_stokeO2_JH = [0.37619836,0.98166707,0.53912801,0.0511171,0];
% % % Q.effi_antiO2_JH = [0.34586496,0.94294973,0.59074973,0.08572700,0];
% % % 
% % % Q.effi_stokeO2_JL = [0.02301580,0.48028012,1,0.43039766,0.00583559];
% % % Q.effi_antiO2_JL = [0.02098297,0.47166835,1,0.44867305,0.01345647];
% % % 
% % % Q.effi_stokeN2_JL = [0.00025546,0.23878872,0.63072501,1,0.64955950,0.25355097,0.00289517];
% % % Q.effi_antiN2_JL = [0,0.23299892,0.62055134,1,0.66708875,0.27132321,0.00944014];
% % % 
% % % Q.h = 6.6262 *10^-27; %erg-s
% % % Q.c = 2.9979*10^10; %cm/s
% % % Q.kb = 1.3807*10^-16; % erg/K
% % % Q.B_N2 = 1.98957;% cm-1
% % % Q.B_O2 = 1.43768;%cm-1
% % % Q.D_N2 = 5.76*10^-6;%cm-1
% % % Q.D_O2 = 4.85*10^-6; %cm-1
% % % Q.r_N2 = 0.51*10^-48; %cm^6
% % % Q.r_O2 = 1.27*10^-48; %cm^6
% % % Q.n_N2 = .7808; % relative volume abundance
% % % Q.n_O2 = .2095;
% % % Q.v0 = 1/ (3.547*10^-5); %cm-1 355nm
% % % Q.kb_SI = 1.38064852*10^-23; %Boltzman SI
% % % Q.I_N2 = 1;
% % % Q.I_O2 = 0;
% % % Q.Const_N2 = (112* pi^4* Q.h*Q.c*Q.r_N2*Q.n_N2 )/((2*Q.I_N2+1)^2 * Q.kb *15);
% % % Q.Const_O2 = (112* pi^4* Q.h*Q.c*Q.r_O2*Q.n_O2 )/((2*Q.I_O2+1)^2 * Q.kb *15);
% % % 
% % % 
% % % %Q numbers
% % % JHO2= [15,17, 19, 21,0];
% % % JLO2 = [5,7,9,11,13];
% % % JHN2 =[10,11,12,13,14,15,0];
% % % JLN2 =[3,4,5,6,7,8,9];
% % % 
% % % % rotational energy
% % % Q.ErotJHO2=[];
% % % Q.ErotJLO2=[];
% % % Q.ErotJHN2=[];
% % % Q.ErotJLN2=[];
% % % 
% % % % JH_O2
% % % for i = 1:length(JHO2)
% % %     
% % %     Q.ErotJHO2(i)= (Q.B_O2.*JHO2(i) *(JHO2(i)+1) - Q.D_O2.*(JHO2(i)^2).*(JHO2(i)+1)^2)*Q.h*Q.c;
% % %     Q.shift_JHO2_as(i) = Q.B_O2 * 2 * (2*(JHO2(i)+2)-1) - Q.D_O2 * (3 * (2*(JHO2(i)+2)-1) + (2*(JHO2(i)+2)-1)^3);
% % %     Q.shift_JHO2_s(i) =  -Q.B_O2 * 2 * (2*JHO2(i)+3) + Q.D_O2 * (3 * (2*JHO2(i)+3) + (2*JHO2(i)+3)^3);
% % %     Q.X_JHO2_as(i) = ((JHO2(i)+2)*((JHO2(i)+2)-1))/(2*(JHO2(i)+2)-1);
% % %     Q.X_JHO2_s(i) = ((JHO2(i)+1)*(JHO2(i)+2))/(2*JHO2(i)+3);
% % %     
% % % end
% % % 
% % % % JH_N2
% % % 
% % % for i = 1:length(JHN2)
% % %     Q.ErotJHN2(i)= (Q.B_N2.*JHN2(i) *(JHN2(i)+1) - Q.D_N2.*(JHN2(i)^2).*(JHN2(i)+1)^2)*Q.h*Q.c;
% % %     Q.shift_JHN2_as(i) = Q.B_N2 * 2 * (2*(JHN2(i)+2)-1) - Q.D_N2 * (3 * (2*(JHN2(i)+2)-1) + (2*(JHN2(i)+2)-1)^3);
% % %     Q.shift_JHN2_s(i) =  -Q.B_N2 * 2 * (2*JHN2(i)+3) + Q.D_N2 * (3 * (2*JHN2(i)+3) + (2*JHN2(i)+3)^3);
% % %     Q.X_JHN2_as(i) = ((JHN2(i)+2)*((JHN2(i)+2)-1))/(2*(JHN2(i)+2)-1);
% % %     Q.X_JHN2_s(i) = ((JHN2(i)+1)*(JHN2(i)+2))/(2*JHN2(i)+3);
% % %     
% % % end
% % % 
% % % 
% % % 
% % % % JL_O2
% % % for i = 1:length(JLO2)
% % %     
% % %     Q.ErotJLO2(i)= (Q.B_O2.*JLO2(i) *(JLO2(i)+1) - Q.D_O2.*(JLO2(i)^2).*(JLO2(i)+1)^2)*Q.h*Q.c;
% % %     Q.shift_JLO2_as(i) =Q.B_O2 * 2 * (2*(JLO2(i)+2)-1) - Q.D_O2 * (3 * (2*(JLO2(i)+2)-1) + (2*(JLO2(i)+2)-1)^3);
% % %     Q.shift_JLO2_s(i) =  -Q.B_O2 * 2 * (2*JLO2(i)+3) + Q.D_O2 * (3 * (2*JLO2(i)+3) + (2*JLO2(i)+3)^3);
% % %     Q.X_JLO2_as(i) = ((JLO2(i)+2)*((JLO2(i)+2)-1))/(2*(JLO2(i)+2)-1);
% % %     Q.X_JLO2_s(i) = ((JLO2(i)+1)*(JLO2(i)+2))/(2*JLO2(i)+3);
% % %     
% % % end
% % % 
% % % 
% % % % JL_N2
% % % for i = 1:length(JLN2)
% % %     
% % %     Q.ErotJLN2(i)= (Q.B_N2.*JLN2(i) *(JLN2(i)+1) - Q.D_N2.*(JLN2(i)^2).*(JLN2(i)+1)^2)*Q.h*Q.c;
% % %     Q.shift_JLN2_as(i) = Q.B_N2 * 2 * (2*(JLN2(i)+2)-1) - Q.D_N2 * (3 * (2*(JLN2(i)+2)-1) + (2*(JLN2(i)+2)-1)^3);
% % %     Q.shift_JLN2_s(i) =  -Q.B_N2 * 2 * (2*JLN2(i)+3) + Q.D_N2 * (3 * (2*JLN2(i)+3) + (2*JLN2(i)+3)^3);
% % %     Q.X_JLN2_as(i) = ((JLN2(i)+2)*((JLN2(i)+2)-1))/(2*(JLN2(i)+2)-1);
% % %     Q.X_JLN2_s(i) = ((JLN2(i)+1)*(JLN2(i)+2))/(2*JLN2(i)+3);
% % % end
% % % 
% % % 
% % % 
% % % 
% % % 
% % % Q.JHO2 = JHO2;
% % % Q.JLO2 = JLO2;
% % % Q.JHN2 = JHN2;
% % % Q.JLN2 = JLN2;


