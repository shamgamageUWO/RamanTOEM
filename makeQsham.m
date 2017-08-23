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

Q.deadtimeJL = 3.8e-9; % 4ns
Q.deadtimeJH = 3.8e-9; % 4ns
Q.CovDTJL = (0.01.*Q.deadtimeJL).^2;
Q.CovDTJH = (0.01 .*Q.deadtimeJH).^2;

Q.deltaT = 10; %2 K
Q.g0a=90*10^-3;%m % this is to create a priori overlap
Q.g0real=100*10^-3;%m % this is to create real overlap
Q.deltatime = 30;
Q.Rate = 1800; 

disp('All the constants are ready')

Q.Zmes1 = 500:37.5:6000;
Q.Zmes2 = 3000:37.5:65000;
Q.Zmes = 500:37.5:65000;
Q.Zret = 500:375:70000;

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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load raw measurements
% Q.BaJH = 0.43;
% Q.BaJL = 0.80
% [epsi,z] = Overlap(Q.Zret);
 load('ovmodeldata.mat');
OVnw = interp1(z,epsi,Q.Zret,'linear');
OVnw(isnan(OVnw))=1;
Q.OVa = OVnw;
%  Q.OVa = ones(1,length(Q.Ta));
Q.OVlength = length(Q.OVa);
Q.COVa = OVCov(Q.Zret,Q.OVa);

% Q.BaJHa = 161;
% Q.BaJLa = 65;
Q.deadtimeJL = 3.8e-9; % 4ns
Q.deadtimeJH = 3.8e-9; % 4ns
Q.CovDTJL = (0.01*Q.deadtimeJL).^2;
Q.CovDTJH = (0.01*Q.deadtimeJH).^2;

Q.CL = 3.7814e20;
Q.CovCL = (0.1 .* (Q.CL)).^2;%sqrt(Q.CL);
Q.CLa = 2e17;
Q.CovCLa = (0.1 .* (Q.CLa)).^2;%sqrt(Q.CL);



% Add noise to the measurement

     [Y] = makeY(Q);
% Digital measurements 2km above
        JHnew = Y.JH;
        JLnew = Y.JL;
        alt = Y.alt;
%         Eb = Y.Eb;
%         Q.binzise = Y.binsize;
%         Q.Eb = Eb(alt>=2000);
%         Q.Eb(Q.Eb <=0)= rand();
%         Q.JHnew= JHnew(alt>=2000);
%         Q.JLnew= JLnew(alt>=2000);
%         Q.alt = alt(alt>=2000);
%         Q.Zmes2 = Q.alt';
% 
%         % Analog measurements
        JHnewa = Y.JHa;
        JLnewa = Y.JLa;
%         Eba = Y.Eba;
        ANalt = Y.alt_an;
%         % Q.Eba = Eba(alt>=50 & alt<6000);
%         % Q.Eba(Q.Eba <=0)= rand();
%         % Q.JHnewa= JHnewa(alt>=50 & alt<5000);
%         % Q.JLnewa= JLnewa(alt>=50 & alt<5000);
%         % % Q.ANalt = ANalt(alt>=50 & alt<5000);
%         Q.Eba = Eba(ANalt>=100 & ANalt <= 3000);
%         Q.Eba(Q.Eba <=0)= rand();
%         Q.JHnewa= JHnewa(ANalt>=100 & ANalt <=3000);
%         Q.JLnewa= JLnewa(ANalt>=100 & ANalt <=3000);
%         Q.ANalt = ANalt(ANalt>=100);
%         Q.Zmes = Q.ANalt';
%         Q.Zmes1 = ANalt(ANalt>=100 & ANalt <= 3000);
%         Q.Zmes1 = Q.Zmes1';
%         %  Q.YYYa = Y.YYYa(ANalt>=100 & ANalt <= 5000);
%         %  Q.YYa  = Y.YYa(ANalt>=100 & ANalt <= 5000);
% 
% 
         Q.BaJL = Y.bgJL;%0.297350746852139; % change later
         Q.BaJH = Y.bgJH;%4.998109499057194e-04;
         Q.BaJLa = Y.bgJLa;%0.297350746852139; % change later
         Q.BaJHa = Y.bgJHa;%4.998109499057194e-04;
%         % Q.BaJLa = 10;%0.297350746852139; % change later
%         % Q.BaJHa = 20;%4.998109499057194e-04;
%         disp('Loaded RALMO measurements ')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


 N = length(JHnew);
% 
% % %% Fix off set 
 zAoffset = 10; % bins ie 10*3.75 = 37.5m 
JHnew= JHnew(1:N-zAoffset); % already in counts ./ (y2HzRaw./1e6);
JLnew = JLnew(1:N-zAoffset); % ./ (y2HzRaw./1e6);
JHnewa = JHnewa(1+zAoffset:end);
JLnewa = JLnewa(1+zAoffset:end);
ANalt=  ANalt(1+zAoffset:end);
alt =  alt(1:N-zAoffset);

%% Define grid sizes
% Q.Zmes1 = Q.ANalt';
Q.d_alti_Diff = length(Q.Zmes)-length(Q.Zmes2);
% Q.Zmes1 = Q.Zmes1(1+zAoffset:end);
% Q.Zmes2 = Q.Zmes2(1:Q.n1-zAoffset);
% Q.Zmes = Q.Zmes1;%[Q.Zmes1 Q.Zmes2];% Measurement grid
% Q.Zmes = Q.Zmes(1:N-zAoffset);
% Z1 = Q.Zmes(1):(Q.Zmes(2)-Q.Zmes(1))*10:10000;% Retrieval grid
% Q.Zret = Q.Zmes(1):(Q.Zmes(2)-Q.Zmes(1))*10:70000;% Retrieval grid
% Q.Zret = [Z1 Z2];% Retrieval grid
% disp('Defined grids ')
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







% Calculate the aerosol attenuation
[alphaAer] = asrSham(Q);
Q.alpha_aero = alphaAer;
% total transmission air + aerosol 
Q.Tr = Total_Transmission(Q);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% R is calibrated wrt sonde profiles
% [R,Ra,aa,bb] = Rcalibration(Q); 
% Q.aa= aa;%1.148467566403494;%aa;
% Q.bb =bb;%22.634605327641157;%bb;
% Q.aa_an = -2.1e2;
% Q.bb_an =1.2e2;
% Q.Ttraditional_an = Q.aa_an.*log((Q.JHnewa -Q.BaJHa) ./(Q.JLnewa -Q.BaJLa))+Q.bb_an; 

Q.R = 0.7913;%0.808780013344381;%R;%R;%0.17;
Q.Ra = 0.8639;%1.042367710538608;%Ra; %%I'm hardcoding this for now. for some reason FM doesnt provide measurements close to real unless divide by 2
% Q.Ttraditional_digi = real(Q.bb./ (Q.aa-log((Q.JHnew -Q.BaJH) ./(Q.JLnew -Q.BaJL)))); 
%      lnQ = log(Q.y(1:Q.n1)./Q.y(Q.n1+1:end));
%                     Ttradi = real(Q.bb./(Q.aa-lnQ));
% disp('R is calibrated ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Estimating background and lidar constant wrt a priori 
% 
% [CJL, CJLa,CJHa] = estimations(Q);% Q.OVa = ones(1,length(Q.Ta));
% load('ovmodeldata.mat');
% OVnw = interp1(z,epsi,Q.Zret,'linear');
% OVnw(isnan(OVnw))=1;
% Q.OVa = OVnw;
% % Q.OVa = ones(1,length(Q.Ta));
% Q.OVlength = length(Q.OVa);
% Q.COVa = OVCov(Q.Zret,Q.OVa);

% Q.CL = CJL;
% Q.CovCL = (0.1 .* (Q.CL)).^2;%sqrt(Q.CL);
% Q.CLa = CJLa;
% Q.CovCLa = (0.1 .* (Q.CLa)).^2;%sqrt(Q.CL);
% Q.CHa = CJHa;
% Q.CovCHa = (0.1 .* (Q.CHa)).^2;%sqrt(Q.CL);
xx = [Q.Ta+20 Q.BaJH Q.BaJL Q.CL Q.OVa Q.BaJHa Q.BaJLa Q.CLa Q.deadtimeJH Q.deadtimeJL]; % now im retrieving log of CJL

[JLreal,JHreal,JLareal,JHareal]=forwardmodelTraman(Q,xx);
JLreal = NoiseP(JLreal);
JHreal = NoiseP(JHreal);
JLareal = awgn(JLareal,50,'measured');
JHareal = awgn(JHareal,50,'measured');
% JLareal = NoiseP(JLareal.*1e3)./1e3;
% JHareal = NoiseP(JHareal.*1e3)./1e3;


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

% %%
%                         % this need to be done if there is any zeros in the real measurements
%                         % smooth the signal over 1
%                     

% 
% JHreal = Q.JHnew'; JLreal = Q.JLnew';  JHrealan = Q.JHnewa';    JLrealan = Q.JLnewa';
% 
%                         smmohtenJH = smooth(JHreal,100); % smoothing covariance to smooth the envelop cover
%                         smmohtenJL = smooth(JLreal,100);
%                         smmohtenJHa = smooth(JHrealan,100); % smoothing covariance to smooth the envelop cover
%                         smmohtenJLa = smooth(JLrealan,100);
%                         % ysmoothen= [smmohtenJH' smmohtenJL']';

 Q.JHnew =JHreal;  Q.JLnew=JLreal ;  Q.JHnewa =JHareal ;   Q.JLnewa= JLareal;
%                         Q.JHnew(Q.JHnew<=0)= round(rand(1)*10);
%                         Q.JHnewa(Q.JHnewa<=0)= round(rand(1)*10);
%                         Q.JLnew(Q.JLnew<=0)= round(rand(1)*10);
%                         Q.JLnewa(Q.JLnewa<=0)= round(rand(1)*10);
%                         Q.y = [Q.JHnew Q.JLnew Q.JHnewa Q.JLnewa]';
                        
                        
% Q.yvar = diag(ysmoothen);


% Variance need to be fixed as below: 
% below 2 km use the Var from the piecewise code
% above 2 km use the counts
Q.JLrealvar = Q.JLnew;
Q.JHrealvar = Q.JHnew;
Q.JLarealvar = Q.JLnewa;
Q.JHarealvar = Q.JHnewa;
%  Q.yvar = diag(Q.y);
 
 % Count Fix
for i = 1:length(Q.JLnew)
if Q.JLnew(i)<20
   Q.JLrealvar(i)=20;
   Q.JLnew(i)=Q.JLnew(i)+randn(1)*sqrt(Q.JLrealvar(i));
end
if Q.JHnew(i)<20
   Q.JHrealvar(i)=20;
   Q.JHnew(i)=Q.JHnew(i)+randn(1)*sqrt(Q.JHrealvar(i));
end
end


% for i = 1:length(Q.JLnewa)
% if Q.JLnewa(i)<15
%    Q.JLarealvar(i)=15;
%    Q.JLnewa(i)=Q.JLnewa(i)+randn(1)*sqrt(Q.JLarealvar(i));
% end
% if Q.JHnewa(i)<15
%    Q.JHarealvar(i)=15;
%    Q.JHnewa(i)=Q.JHnewa(i)+randn(1)*sqrt(Q.JHarealvar(i));
% end
% end
 
Q.JHnew(Q.JHnew<=0)= round(rand(1)*10);
Q.JHnewa(Q.JHnewa<=0)= round(rand(1)*10);
Q.JLnew(Q.JLnew<=0)= round(rand(1)*10);
Q.JLnewa(Q.JLnewa<=0)= round(rand(1)*10);
Q.y = [Q.JHnew Q.JLnew Q.JHnewa Q.JLnewa]';
 Yvar =[Q.JHrealvar Q.JLrealvar Q.JHarealvar Q.JLarealvar];
 Q.yvar = diag(Yvar);
%              [JHv,go] =bobpoissontest(smmohtenJH',Q.Zmes2,8);
%              [JLv,go] =bobpoissontest(smmohtenJL',Q.Zmes2,8);
% % 
% % 
% %             
%              r1 = ones(1,go-1).* JHv(1);
%              r2 = ones(1,go-1).* JHv(end);
%              r3 = ones(1,go-1).* JLv(1);
%              r4 = ones(1,go-1).* JLv(end);
%              Q.JHv = [r1 JHv r2];
%              Q.JLv = [r3 JLv r4];
% 
% 
%  [JHav,go1] =bobpoissontest(Q.JHnewa,Q.Zmes1,12);
%  [JLav,go2] =bobpoissontest(Q.JLnewa,Q.Zmes1,12);
% 
%             ar1 = ones(1,go1-1).* JHav(1);
%             ar2 = ones(1,go1-1).* JHav(end);
%             ar3 = ones(1,go2-1).* JLav(1);
%             ar4 = ones(1,go2-1).* JLav(end);
%             Q.JHav = [ar1 JHav ar2];
%             Q.JLav = [ar3 JLav ar4];
%             
%             slope = (((0.05-1).*Q.Zmes1)/(Q.Zmes1(end)))+1;
% slope1 = (((0.05-1).*Q.Zmes1)/(Q.Zmes1(end)))+1;

%                 for i = 1: length(Q.JLav)
%                     if Q.Zmes2(i) <= 3000
%                         Q.YYa(i) = Q.JLav(i);
%                     else
%                         Q.YYa(i) = 10.*Q.JLav(i);
%                     end
%                 end
%                 
%                 for i = 1: length(Q.JHav)
%                     if  Q.Zmes2(i) <= 3000
%                         Q.YYYa(i) = Q.JHav(i);
%                     else
%                         Q.YYYa(i) = 10.*Q.JHav(i);
%                     end
%                 end

            
            
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
% 
%         Q.Yvar =[Q.JHnew Q.JLnew Q.JHav Q.JLav];
% %         Q.Yvar =[JHreal JLreal];
% 
% % % HEre I linearlize the covariance
% % slope = (((0.0008-1).*Q.Zmes1)/(Q.Zmes1(end)))+1;
% % slope1 = (((0.0008-1).*Q.Zmes1)/(Q.Zmes1(end)))+1;
%    Q.YYYa =  Q.JHav;% smmohtenJHa';
%    Q.YYa  = Q.JLav;%smmohtenJLa';
% %  Q.YYYa = slope.*Q.JHav;
% %   Q.YYa  =slope1.*Q.JLav;
% 
%             Q.Yvar =[Q.YYY Q.YY Q.YYYa Q.YYa];
% %            Q.Yvar =[smmohtenJH' smmohtenJL' Q.YYYa Q.YYa];
%                 Q.yvar = diag(Q.Yvar);
                
                



% disp('Estimations for CJL, backgrounds and overlap done ')
disp('makeQ complete ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Q.n1=length(Q.JHnew);
        Q.n2=length(Q.JLnew);
        Q.n3=length(Q.JHnewa);
        Q.n4=length(Q.JLnewa);
figure;
subplot(1,2,1)
semilogx(Q.JLnew,Q.Zmes2./1000,'r',Q.JHnew,Q.Zmes2./1000,'b',JLnew,alt./1000,'-y',JHnew,alt./1000,'-g')

subplot(1,2,2)
semilogx(Q.JLnewa,Q.Zmes1./1000,'r',Q.JHnewa,Q.Zmes1./1000,'b',JLnewa, ANalt./1000,'-y',JHnewa, ANalt./1000,'-g')
end

