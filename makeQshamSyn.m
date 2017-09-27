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
Q.t_bin = 60;%s
Q.altbinsize = 3.75;%m
Q.Clight = 299792458; %ISSI value
Q.ScaleFactor = 150/3.75;
Q.shots = 1800;
 Q.Rgas = 8.3145;%Hz
Q.deadtimeJL = 3.9e-9; % 4ns
Q.deadtimeJH = 3.8e-9; % 4ns
Q.CovDTJL = (0.01.*Q.deadtimeJL).^2;
Q.CovDTJH = (0.01 .*Q.deadtimeJH).^2;

Q.deltaT = 10; %2 K
Q.g0a=90*10^-3;%m % this is to create a priori overlap
Q.g0real=100*10^-3;%m % this is to create real overlap
Q.deltatime = 30;
Q.Shots = 1800; 
% Q.f = Q.Clight ./ (2.*(Q.Shots).*Q.altbinsize); 
disp('All the constants are ready')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load raw measurements
 [Y] = makeY(Q);
% % Digital measurements 2km above
% JHnew = Y.JH;
% JLnew = Y.JL;
% JL_DS = Y.JL_DS;
% JH_DS = Y.JH_DS;
% 
% alt = Y.alt;
% Eb = Y.Eb;
% Q.binzise = Y.binsize;
% Q.Eb = Eb(alt>=2000);
% Q.Eb(Q.Eb <=0)= rand();
% Q.JHnew= JHnew(alt>=2000);
% Q.JLnew= JLnew(alt>=2000);
% Q.JH_DS =JH_DS(alt>=2000);
% Q.JL_DS =JL_DS(alt>=2000);
% Q.alt = alt(alt>=2000);
% Q.Zmes2 = Q.alt';

Q.f = 1e6./(Y.F);

% Analog measurements
% JHnewa = Y.JHa;
% JLnewa = Y.JLa;
% Eba = Y.Eba;
% ANalt = Y.alt_an;
% Q.Eba = Eba(alt>=50 & alt<6000);
% Q.Eba(Q.Eba <=0)= rand();
% Q.JHnewa= JHnewa(alt>=50 & alt<5000);
% Q.JLnewa= JLnewa(alt>=50 & alt<5000);
% % Q.ANalt = ANalt(alt>=50 & alt<5000);
% Q.Eba = Eba(ANalt>=1000 & ANalt <= 12000);
% Q.Eba(Q.Eba <=0)= rand();
% Q.JHnewa= JHnewa(ANalt>=1000 & ANalt <=12000);
% Q.JLnewa= JLnewa(ANalt>=1000 & ANalt <=12000);
% Q.ANalt = ANalt(ANalt>=1000);
% Q.Zmes = Q.ANalt';
% Q.Zmes1 = ANalt(ANalt>=1000 & ANalt <= 12000);
% Q.Zmes1 = Q.Zmes1';
%  Q.YYYa = Y.YYYa(ANalt>=100 & ANalt <= 5000);
%  Q.YYa  = Y.YYa(ANalt>=100 & ANalt <= 5000);


Q.BaJL = 0.2434; % change later
Q.BaJH = 0.2237;
Q.BaJLa =596;%0.297350746852139; % change later
Q.BaJHa = 307;
% Q.BaJLa = 10;%0.297350746852139; % change later
% Q.BaJHa = 20;%4.998109499057194e-04;
disp('Loaded RALMO measurements ')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define grid sizes
Q.Zmes1 = 500:10:7000;
Q.Zmes2 = 500:10:55000;
Q.Zmes = 500:10:55000;
Q.d_alti_Diff = length(Q.Zmes)-length(Q.Zmes2);
Q.Zret = 500:100:60000;% Retrieval grid
% Q.Zret = [Z1 Z2];% Retrieval grid
disp('Defined grids ')
% Yc = [Q.JHnewa;Q.JHnew]
% figure;semilogx(Yc,Q.Zmes./1000)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  a priori temperatures

% Q.Ta = Ta; Q.Ti = Ti; Q.Pressi = Pressi; Q.Nmol = Nmol; Q.rho = rho;
            [temp, press, dens, alt] = US1976(Q.date_in, Q.time_in, Q.Zret);
            Q.Ta = temp; % for now im adding 2K to test
            Q.Ti = interp1(Q.Zret,Q.Ta,Q.Zmes,'linear');
             lnpress = log(press);
            Pressi =interp1(Q.Zret,lnpress,Q.Zmes,'linear'); %% I am trying to make this looks like psonde
            Q.Pressi = exp(Pressi);
            Q.rho = Q.Pressi./(Rsp.*Q.Ti);
            Q.Nmol = (NA/M).* Q.rho ; % mol m-3
            
            
obj2 = Gravity(Q.Zmes, 46.82);
Q.grav = obj2.accel;
Q.MoR = (M./Q.Rgas).*ones(size(Q.Ti));
Q.z0 = 30000;            
[Q.Pdigi,p0A] = find_pHSEQ(Q.z0,Q.Zmes,Q.Ti,Q.Pressi,0,Q.grav',Q.MoR);  
disp('a priori temperature profile is loaded ')

[Tmsis, pmsis,zmsis]= msisRALMO;
%  [Tsonde,Zsonde,Psonde] = get_sonde_RS92(Q.date_in, Q.time_in);
%  Zsonde = Zsonde-491; % altitude correction
% 
% Q.Tsonde = interp1(Zsonde,Tsonde,Q.Zmes,'linear'); % this goes to Restimation and asr code
% Q.Psonde = interp1(Zsonde,Psonde,Q.Zmes,'linear'); % this goes asr 
  Q.Tsonde2 = interp1(zmsis,Tmsis,Q.Zret,'linear'); % this goes to CJL estimation
%%%%%

% Calculate the aerosol attenuation
[alphaAer] = asrSham(Q);
Q.alpha_aero = alphaAer;
% total transmission air + aerosol 
Q.Tr = Total_Transmission(Q);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% R is calibrated wrt sonde profiles
% [R,Ra,R_fit,Ra_fit] = Restimationnew(Q);
%  [R,Ra] = Rcalibration(Q); 
% Q.aa= aa;%1.148467566403494;%aa;
% Q.bb =bb;%22.634605327641157;%bb;
% Q.aa_an = -2.1e2;
% Q.bb_an =1.2e2;
% Q.Ttraditional_an = Q.aa_an.*log((Q.JHnewa -Q.BaJHa) ./(Q.JLnewa -Q.BaJLa))+Q.bb_an; 

Q.R = 0.7682;%R;%0.808780013344381;%R;%R;%0.17;
Q.Ra = 0.8740;%Ra;%1.042367710538608;%Ra; %%I'm hardcoding this for now. for some reason FM doesnt provide measurements close to real unless divide by 2
% Q.Ttraditional_digi = real(Q.bb./ (Q.aa-log((Q.JHnew -Q.BaJH) ./(Q.JLnew -Q.BaJL)))); 
%      lnQ = log(Q.y(1:Q.n1)./Q.y(Q.n1+1:end));
%                     Ttradi = real(Q.bb./(Q.aa-lnQ));
disp('R is calibrated ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Estimating background and lidar constant wrt a priori 

% [CJL, CJLa,CJHa,CJH] = estimations(Q);% Q.OVa = ones(1,length(Q.Ta));
 load('ovmodeldata.mat');
 OVnw = interp1(z,epsi,Q.Zret,'linear');
 OVnw(isnan(OVnw))=1;
 Q.OVa = OVnw;
% Q.OVa = ones(1,length(Q.Ta));
Q.OVlength = length(Q.OVa);
Q.COVa = OVCov(Q.Zret,Q.OVa);

Q.CL = 2.8e20;
Q.CovCL = (.1 .* (Q.CL)).^2;%sqrt(Q.CL);
Q.CLa = 1.9e17;
Q.CovCLa = (.1 .* (Q.CLa)).^2;%sqrt(Q.CL);
% Q.CHa = CJHa;
% Q.CovCHa = (0.1 .* (Q.CHa)).^2;%sqrt(Q.CL);

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
                        
xx = [Q.Tsonde2 Q.BaJH Q.BaJL Q.CL Q.OVa Q.BaJHa Q.BaJLa Q.CLa Q.deadtimeJH Q.deadtimeJL]; % now im retrieving log of CJL

[JLreal,JHreal,JLareal,JHareal]=forwardmodelTraman(Q,xx);
JLreal = NoiseP(JLreal);
JHreal = NoiseP(JHreal);
JLareal = awgn(JLareal,50,'measured');
JHareal = awgn(JHareal,50,'measured');
    Q.JHnew =JHreal;  Q.JLnew=JLreal ;  Q.JHnewa =JHareal ;   Q.JLnewa= JLareal;                     
                        Q.JHnew(Q.JHnew<=0)= round(rand(1)*10);
                        Q.JHnewa(Q.JHnewa<=0)= round(rand(1)*10);
                        Q.JLnew(Q.JLnew<=0)= round(rand(1)*10);
                        Q.JLnewa(Q.JLnewa<=0)= round(rand(1)*10);
% 
% JHreal = Q.JHnew'; JLreal = Q.JLnew';  JHrealan = Q.JHnewa';    JLrealan = Q.JLnewa';
% 
% %                         smmohtenJH = smooth(JHreal,10); % smoothing covariance to smooth the envelop cover
% %                         smmohtenJL = smooth(JLreal,10);
% %                         smmohtenJHa = smooth(JHrealan,10); % smoothing covariance to smooth the envelop cover
% %                         smmohtenJLa = smooth(JLrealan,10);
%                         % ysmoothen= [smmohtenJH' smmohtenJL']';



                        Q.y = [Q.JHnew Q.JLnew Q.JHnewa Q.JLnewa]';
Q.n1=length(Q.JHnew);
Q.n2=length(Q.JLnew);
Q.n3=length(Q.JHnewa);
Q.n4=length(Q.JLnewa);                      
                        
% Q.yvar = diag(ysmoothen);


% Variance need to be fixed as below: 
% below 2 km use the Var from the piecewise code
% above 2 km use the counts

% Q.yvar = diag(Q.y);
             [JHv,go] =bobpoissontest(Q.JHnew,Q.Zmes2,8);
             [JLv,go] =bobpoissontest(Q.JLnew,Q.Zmes2,8);
% 
% 
%             
             r1 = ones(1,go-1).* JHv(1);
             r2 = ones(1,go-1).* JHv(end);
             r3 = ones(1,go-1).* JLv(1);
             r4 = ones(1,go-1).* JLv(end);
             Q.JHv = [r1 JHv r2];
             Q.JLv = [r3 JLv r4];


 [JHav,go1] =bobpoissontest(Q.JHnewa,Q.Zmes1,8);
 [JLav,go2] =bobpoissontest(Q.JLnewa,Q.Zmes1,8);

            ar1 = ones(1,go1-1).* JHav(1);
            ar2 = ones(1,go1-1).* JHav(end);
            ar3 = ones(1,go2-1).* JLav(1);
            ar4 = ones(1,go2-1).* JLav(end);
            Q.JHav = [ar1 JHav ar2];
            Q.JLav = [ar3 JLav ar4];
            
%             slope = (((0.05-1).*Q.Zmes1)/(Q.Zmes1(end)))+1;
% slope1 = (((0.05-1).*Q.Zmes1)/(Q.Zmes1(end)))+1;

                for i = 1: length(Q.JLav)
                    if Q.Zmes2(i) <= 4000
                        Q.YYa(i) = Q.JLav(i);
                    else
                        Q.YYa(i) = 10.*Q.JLav(i);
                    end
                end
                
                for i = 1: length(Q.JHav)
                    if  Q.Zmes2(i) <= 4000
                        Q.YYYa(i) = Q.JHav(i);
                    else
                        Q.YYYa(i) = 10.*Q.JHav(i);
                    end
                end

            
            
        for i = 1: length(Q.JLv)
            if Q.Zmes2(i) <= 6000
                Q.YY(i) = Q.JLv(i);
            else
                Q.YY(i) = Q.JLnew(i);
            end
        end

        for i = 1: length(Q.JHv)
            if  Q.Zmes2(i) <= 6000
                Q.YYY(i) = Q.JHv(i);
            else
                Q.YYY(i) = Q.JHnew(i);
            end
        end

%         Q.Yvar =[YYY YY JHav JLav];
%         Q.Yvar =[JHreal JLreal];

% % HEre I linearlize the covariance
% %  slope = (((0.9-0.7).*Q.Zmes1)/(Q.Zmes1(end)));
%  slope = (((0.5-1).*Q.Zmes1)/(Q.Zmes1(end)))+1;
% %    Q.YYYa =  Q.JHav;% smmohtenJHa';
% %    Q.YYa  = Q.JLav;%smmohtenJLa';
%  Q.YYYa = Q.JHav;
%   Q.YYa  =Q.JLav;

            Q.Yvar =[Q.YYY Q.YY Q.YYYa Q.YYa];
%               Q.Yvar(Q.Yvar<=0)= round(rand(1)*10);
%            Q.Yvar =[smmohtenJH' smmohtenJL' Q.YYYa Q.YYa];
                Q.yvar = diag(Q.Yvar);
                
                



disp('Estimations for CJL, backgrounds and overlap done ')
disp('makeQ complete ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



end





