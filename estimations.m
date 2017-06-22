function [CJL, CJH,Bg_JL_real,Bg_JH_real,bg_JL_std,bg_JH_std,bg_length1,bg_length2,OV] = estimations(Q)

% [JHnew,JLnew,alt,JLwithoutBG,JHwithoutBG,bg_JL_mean,bg_JH_mean,bg_JL_std,bg_JH_std,Eb,bg_length]=rawcountsRALMOnew(Q);
[Y]= makeY(Q);
JHnew = Y.JH;
JLnew= Y.JL;
alt = Y.alt;
bg_JL_mean=  Y.bgJL;
bg_JH_mean = Y.bgJH;
bg_JL_std = Y.bg_JL_std;
bg_JH_std = Y.bg_JH_std;
bg_length1 = Y.bg_length1;
bg_length2 = Y.bg_length2;
JHnew= JHnew(alt>=1500);
JLnew= JLnew(alt>=1500);
alt = alt(alt>=1500);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HEre I'm trying to make an estimation of true background
Bg_JL_real =  (bg_JL_mean); % this is an estimation of obs background
Bg_JH_real =  (bg_JH_mean);

% Bg_JL_real = Bg_JL_obs/(1+Q.deadtime*Bg_JL_obs);
% Bg_JH_real = Bg_JH_obs/(1+Q.deadtime*Bg_JH_obs);
% Bg_JL_real = Bg_JL_obs/(1+Q.deadtime*Bg_JL_obs);
% Bg_JH_real = Bg_JH_obs/(1+Q.deadtime*Bg_JH_obs);

Zi = alt;
    ind = Zi>=8000 & Zi< 10000;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Removing true background from the desaturated signal
SJH = JHnew - Bg_JH_real;
SJL = JLnew - Bg_JL_real;


    OVa = ones(1,length(Q.Ta));
    Q.OVlength = length(OVa);

    x = [Q.Ta 0 0 1 OVa];

    %          x = [Q.Ta 0 0 log(1) OVa];
    % run the FM with backgrounds = 1; OV = 1; 
    [JL,JH,A_Zi,B_Zi,Diff_JL_i,Diff_JH_i,Ti]=forwardmodelTraman(Q,x);


    CJL = nanmean(SJL(ind)./JL(ind)');
    CJH = nanmean(SJH(ind)./JH(ind)');


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Overlap estimation
% %     JLwoOV = ((CJL.*JL))+ Bg_JL_real;
% %     JHwoOV = ((Q.R.*CJL.*JH))+ Bg_JH_real;
% %     
% %      OVz = (JLnew + JHnew)./(JLwoOV + JHwoOV)';
    JLwoOV = ((CJL.*JL));
    JHwoOV = ((Q.R.*CJL.*JH));
    % It is now mean of the overlap as the a priori
    OVz1 = (JLnew - Bg_JL_real)./(JLwoOV )';
    OVz2 = (JHnew - Bg_JH_real)./(JHwoOV )';
    OVz = (OVz1+OVz2)./2;
   OVz = smooth(OVz,5);
% 
%     %  OVz = (JLnew + JHnew- Bg_JL_real- Bg_JH_real)./(JLwoOV + JHwoOV)';
%     % figure;plot(Q.Zmes./1000,OVz,'b'); hold on;
    OV = interp1(Q.Zmes,OVz,Q.Zret); % this is to smooth

% OV = ones(1,length(Q.Ta));
% plot(Q.Zret./1000,OV,'r')
        OV(OV>=1)=1;
        h = find(OV==1);
        OV(h(1):end)=1;
%  plot(Q.Zret./1000,OV,'y')
% hold off;
% legend('Before interpolation','After interpolation','Final OV smoothed')

