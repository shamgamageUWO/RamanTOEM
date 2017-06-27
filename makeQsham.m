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
Q.coaddalt = 5;
Q.Rate = 30;%Hz
Q.t_bin = 60;%s
Q.altbinsize = 3.75;%m
Q.Clight = 299792458; %ISSI value
Q.ScaleFactor = 150/3.75;
Q.shots = 1800;
Q.deadtime = 3.8e-9; % 4ns
Q.deltaT = 10; %2 K
Q.g0a=90*10^-3;%m % this is to create a priori overlap
Q.g0real=100*10^-3;%m % this is to create real overlap
Q.deltatime = 30;
Q.Rate = 1800; 

disp('All the constants are ready')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load raw measurements
[Y] = makeY(Q);
% Digital measurements 2km above
JHnew = Y.JH;
JLnew = Y.JL;
alt = Y.alt;
Eb = Y.Eb;
Q.binzise = Y.binsize;
Q.Eb = Eb(alt>3000);
Q.Eb(Q.Eb <=0)= rand();
Q.JHnew= JHnew(alt>3000);
Q.JLnew= JLnew(alt>3000);
Q.alt = alt(alt>3000);
Q.Zmes2 = Q.alt';

% Analog measurements
JHnewa = Y.JHa;
JLnewa = Y.JLa;
Eba = Y.Eba;
ANalt = Y.alt_an;
% Q.Eba = Eba(alt>=50 & alt<6000);
% Q.Eba(Q.Eba <=0)= rand();
% Q.JHnewa= JHnewa(alt>=50 & alt<5000);
% Q.JLnewa= JLnewa(alt>=50 & alt<5000);
% % Q.ANalt = ANalt(alt>=50 & alt<5000);
Q.Eba = Eba(ANalt>=50 & ANalt < 5000);
Q.Eba(Q.Eba <=0)= rand();
Q.JHnewa= JHnewa(ANalt>=50 & ANalt < 5000);
Q.JLnewa= JLnewa(ANalt>=50 & ANalt < 5000);
Q.ANalt = ANalt(ANalt>=50);
Q.Zmes = Q.ANalt';
Q.Zmes1 = ANalt(ANalt>=50 & ANalt < 5000);
Q.Zmes1 = Q.Zmes1';

Q.BaJL = Y.bgJL;%0.297350746852139; % change later
Q.BaJH = Y.bgJH;%4.998109499057194e-04;
Q.BaJLa = Y.bgJLa;%0.297350746852139; % change later
Q.BaJHa = Y.bgJHa;%4.998109499057194e-04;
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

Q.n1=length(Q.JHnew);
Q.n2=length(Q.JLnew);
Q.n3=length(Q.JHnewa);
Q.n4=length(Q.JLnewa);

%% Define grid sizes
% Q.Zmes1 = Q.ANalt';
Q.d_alti_Diff = length(Q.Zmes)-length(Q.Zmes2);
% Q.Zmes1 = Q.Zmes1(1+zAoffset:end);
% Q.Zmes2 = Q.Zmes2(1:Q.n1-zAoffset);
% Q.Zmes = Q.Zmes1;%[Q.Zmes1 Q.Zmes2];% Measurement grid
% Q.Zmes = Q.Zmes(1:N-zAoffset);
% Z1 = Q.Zmes(1):(Q.Zmes(2)-Q.Zmes(1))*10:10000;% Retrieval grid
Q.Zret = Q.Zmes(1):(Q.Zmes(2)-Q.Zmes(1))*10:70000;% Retrieval grid
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
 [R,Ra,aa,bb] = Rcalibration(Q); 
Q.aa= aa;%1.148467566403494;%aa;
Q.bb =bb;%22.634605327641157;%bb;
Q.aa_an = -2.1e2;
Q.bb_an =1.2e2;
Q.Ttraditional_an = Q.aa_an.*log((Q.JHnewa -Q.BaJHa) ./(Q.JLnewa -Q.BaJLa))+Q.bb_an; 

Q.R = R;%0.808780013344381;%R;%R;%0.17;
Q.Ra = Ra;%1.042367710538608;%Ra; %%I'm hardcoding this for now. for some reason FM doesnt provide measurements close to real unless divide by 2
Q.Ttraditional_digi = real(Q.bb./ (Q.aa-log((Q.JHnew -Q.BaJH) ./(Q.JLnew -Q.BaJL)))); 
%      lnQ = log(Q.y(1:Q.n1)./Q.y(Q.n1+1:end));
%                     Ttradi = real(Q.bb./(Q.aa-lnQ));
disp('R is calibrated ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Estimating background and lidar constant wrt a priori 

[CJL, CJLa,OV] = estimations(Q);% Q.OVa = ones(1,length(Q.Ta));
%  load('ovmodeldata.mat');
%  OVnw = interp1(Q.Zmes,ov,Q.Zret,'linear');
Q.OVa = OV;%ones(1,length(Q.Ta));
Q.OVlength = length(Q.OVa);
Q.COVa = OVCov(Q.Zret,Q.OVa);

Q.CL = CJL;
Q.CovCL = (0.1 .* (Q.CL)).^2;%sqrt(Q.CL);
Q.CLa = CJLa;
Q.CovCLa = (0.1 .* (Q.CLa)).^2;%sqrt(Q.CL);
% Q.CHa = CJHa;
% Q.CovCHa = (0.5 .* (Q.CHa)).^2;%sqrt(Q.CL);

                           Q.CovBJLa = ((Y.bg_JL_stda)).^2; % day time
                           Q.CovBJHa = ((Y.bg_JH_stda)).^2;
%                            Q.CovBJLa = ((Y.bg_JL_stda/sqrt(Y.bg_length2a))).^2;
%                                     Q.CovBJHa = ((Y.bg_JH_stda/sqrt(Y.bg_length1a))).^2;
%                        Q.CovBJLa = (0.5 .* (Q.BaJLa)).^2;%((Y.bg_JL_stda)).^2; % day time
%                            Q.CovBJHa =(0.5 .* (Q.BaJHa)).^2;% ((Y.bg_JH_stda)).^2;

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

%%
                        % this need to be done if there is any zeros in the real measurements
                        % smooth the signal over 1
                    
                        Q.JHnew(Q.JHnew<=0)= round(rand(1)*10);
                        Q.JHnewa(Q.JHnewa<=0)= round(rand(1)*10);
                        Q.JLnew(Q.JLnew<=0)= round(rand(1)*10);
                        Q.JLnewa(Q.JLnewa<=0)= round(rand(1)*10);

JHreal = Q.JHnew'; JLreal = Q.JLnew';  JHrealan = Q.JHnewa';    JLrealan = Q.JLnewa';

                        smmohtenJH = smooth(JHreal,100); % smoothing covariance to smooth the envelop cover
                        smmohtenJL = smooth(JLreal,100);
                        smmohtenJHa = smooth(JHrealan,100); % smoothing covariance to smooth the envelop cover
                        smmohtenJLa = smooth(JLrealan,100);
                        % ysmoothen= [smmohtenJH' smmohtenJL']';

 Q.JHnew =JHreal;  Q.JLnew=JLreal ;  Q.JHnewa =JHrealan ;   Q.JLnewa= JLrealan;

                        Q.y = [Q.JHnew Q.JLnew Q.JHnewa Q.JLnewa]';
                        
                        
% Q.yvar = diag(ysmoothen);


% Variance need to be fixed as below: 
% below 2 km use the Var from the piecewise code
% above 2 km use the counts

% Q.yvar = diag(Q.y);
%             [JHv,go] =bobpoissontest(JHreal,Q.Zmes2);
%             [JLv,go] =bobpoissontest(JLreal,Q.Zmes2);
% 
% 
%             
%             r1 = ones(1,go-1).* JHv(1);
%             r2 = ones(1,go-1).* JHv(end);
%             r3 = ones(1,go-1).* JLv(1);
%             r4 = ones(1,go-1).* JLv(end);
%             Q.JHv = [r1 JHv r2];
%             Q.JLv = [r3 JLv r4];


[JHav,go] =bobpoissontest(smmohtenJHa',Q.Zmes1);
[JLav,go] =bobpoissontest(smmohtenJLa',Q.Zmes1);

            ar1 = ones(1,go-1).* JHav(1);
            ar2 = ones(1,go-1).* JHav(end);
            ar3 = ones(1,go-1).* JLav(1);
            ar4 = ones(1,go-1).* JLav(end);
            Q.JHav = [ar1 JHav ar2];
            Q.JLav = [ar3 JLav ar4];
            
            for i = 1: length(Q.JLav)
                if Q.Zmes2(i) <= 2000
                    Q.YYa(i) = Q.JLav(i);
                else
                    Q.YYa(i) = 30.*Q.JLav(i);
                end
            end
            
            for i = 1: length(Q.JHav)
                if  Q.Zmes2(i) <= 2000
                    Q.YYYa(i) = Q.JHav(i);
                else
                    Q.YYYa(i) = 30.*Q.JHav(i);
                end
            end

            
            
%         for i = 1: length(Q.JLv)
%             if Q.Zmes2(i) <= 4000
%                 Q.YY(i) = Q.JLv(i);
%             else
%                 Q.YY(i) = smmohtenJL(i);
%             end
%         end
% 
%         for i = 1: length(Q.JHv)
%             if  Q.Zmes2(i) <= 4000
%                 Q.YYY(i) = Q.JHv(i);
%             else
%                 Q.YYY(i) = smmohtenJH(i);
%             end
%         end

%         Q.Yvar =[YYY YY JHav JLav];
%         Q.Yvar =[JHreal JLreal];
        
                Q.Yvar =[smmohtenJH' smmohtenJL' Q.YYYa Q.YYa];
                Q.yvar = diag(Q.Yvar);
                
                



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


