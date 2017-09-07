function [CJL, CJLa,CJHa,CJH] = estimations(Q)



Zi = Q.Zmes;
ind1 = Zi>=8000 & Zi< 10000;
ind2 = Zi>=1500 & Zi< 1700;
% ind3 = Zi
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Removing true background from the desaturated signal
SJH = Q.JH_DS - Q.BaJH;
SJL = Q.JL_DS - Q.BaJL;

SJHa = Q.JHnewa - Q.BaJHa;
SJLa = Q.JLnewa - Q.BaJLa;
% SJHa = Q.JHnewa;
% SJLa = Q.JLnewa;

    OVa = ones(1,length(Q.Ta));
    Q.OVlength = length(OVa);
    
% [Tsonde,Zsonde,Psonde] = get_sonde_RS92(Q.date_in,Q.time_in);
% Ti = interp1(Zsonde,Tsonde,Q.Zret,'linear'); % T on data grid (digital)
%     x = [Q.Ta 0 0 1 OVa 0 0 1 1]; Run this to retrieve CJH independently
    x = [Q.Tsonde2 0 0 1  1 OVa 0 0 1 1 Q.deadtimeJH Q.deadtimeJL]; % coupled analog channels


[JL,JH,JLa,JHa]=forwardmodelTraman(Q,x);
  
yJL= SJL(ind1);
xJL=JL(ind1);
yJH= SJH(ind1);
xJH =JH(ind1);

fL = fittype({'x'});
fitJL = fit(xJL',yJL,fL,'Robust','on');
CJL = fitJL(1);

fH = fittype({'x'});
fitJH = fit(xJH',yJH,fH,'Robust','on');
CJH = fitJH(1);

yJLa = SJLa(ind2);
xJLa = JLa(ind2);
yJHa = SJHa(ind2);
xJHa = JHa(ind2);

fLa = fittype({'x'});
fitJLa = fit(xJLa',yJLa,fLa,'Robust','on');
CJLa = fitJLa(1);

fHa = fittype({'x'});
fitJHa = fit(xJHa',yJHa,fHa,'Robust','on');
CJHa = fitJHa(1);

% When using Z = 8km and Za = 1.5km
% CJL= SJL(187)./JL(187);
% CJH= SJH(187)./JH(187);
% CJLa = SJLa(14)./JLa(14);
% CJHa = SJHa(14)./JHa(14);

%  figure;
%  subplot(1,2,1)
%  semilogx(SJH,Q.Zmes2./1000,'b',CJH.*JH,Q.Zmes2./1000,'m')
%  hold on;
%  semilogx(SJL,Q.Zmes2./1000,'black',CJL.*JL,Q.Zmes2./1000,'b')
%  legend('JH real','JH Syn (CJH)','JL real','JL Syn')
% % 
%  subplot(1,2,2)
%  semilogx(SJLa,Q.Zmes1./1000,'black',CJLa.*JLa,Q.Zmes1./1000,'b')
%  hold on;
%  semilogx(SJHa,Q.Zmes1./1000,'m',CJHa.*JHa,Q.Zmes1./1000,'g')
%  legend('JL ana real','JLana','JH ana real','JH ana Syn (CJH)')
% 
% %     CJL = nanmean(SJL(ind1)./JL(ind1)');
% %     CJH = nanmean(SJH(ind1)./JH(ind1)');
% % 
%     CJLa = nanmean(SJLa(ind2)./JLa(ind2)');
%    CJHa = nanmean(SJHa(ind2)./JHa(ind2)');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Overlap estimation
    % %     JLwoOV = ((CJL.*JL))+ Bg_JL_real;
    % %     JHwoOV = ((Q.R.*CJL.*JH))+ Bg_JH_real;
    % %      OVz = (JLnew + JHnew)./(JLwoOV + JHwoOV)';
    %
    %     %  OVz = (JLnew + JHnew- Bg_JL_real- Bg_JH_real)./(JLwoOV + JHwoOV)';
    %     % figure;plot(Q.Zmes./1000,OVz,'b'); hold on;
%     
%      JLwoOV = ((CJL.*JL));
%      JHwoOV1 = ((Q.R.*CJL.*JH));
%      JHwoOV2 = ((CJH.*JH));
% % %     
%     JLawoOV = ((CJLa.*JLa));
%      JHawoOV1 = ((Q.Ra.*CJLa.*JHa));
%     JHawoOV2 = ((CJHa.*JHa));

% %     
% %     % It is now mean of the overlap as the a priori
%       OVz1d = (Q.JLnew - Q.BaJL)./(JLwoOV )';
%       OVz2d = (Q.JHnew - Q.BaJH)./(JHwoOV1 )';
%       OVz3d = (Q.JHnew - Q.BaJH)./(JHwoOV2 )';
% 
%    
%       
%       
%      OVz1a = (Q.JLnewa - Q.BaJLa)./(JLawoOV )';
%      OVz2a = (Q.JHnewa - Q.BaJHa)./(JHawoOV1 )';
%      OVz3a = (Q.JHnewa - Q.BaJHa)./(JHawoOV2 )';
%    figure;plot(Q.Zmes2./1000,OVz1d,'r',Q.Zmes2./1000,OVz2d,'b',Q.Zmes2./1000,OVz3d,'g')
%   figure;plot(Q.Zmes1./1000,OVz1a,'r',Q.Zmes1./1000,OVz3a,'g',Q.Zmes2./1000,OVz1d,'m',Q.Zmes2./1000,OVz3d,'black')

% %     
% %     OVzd = (OVz1d+OVz2d)./2;
% %     OVzd = smooth(OVzd,5);
% %     
% %     OVza = (OVz1a+OVz2a)./2;
% OVza = OVz1a;
% %     OVza = smooth(OVza,10);
%     normfac = OVza(end);
%     OVnw = OVza./normfac;
% %     plot(Q.Zmes1./1000,OVnw,'y')
%     
% %      OVza(OVza>=1)=1;
% %     OVz = [OVza;OVzd]; 
%      OV = interp1(Q.Zmes1,OVnw,Q.Zret); % this is to smooth
%      OV(isnan(OV))=1;
%     OV(OV>=1)=1;
%     h = find(Q.Zret>=4500);
% %     h = find(OV==1);
%     OV(h(1):end)=1;
%   plot(Q.Zret./1000,OV,'y')
% hold off;
% legend('Before interpolation','After interpolation','Final OV smoothed')

% figure;semilogx(Q.JLnewa,Q.Zmes1./1000,(CLa.*OV(1:Q.n3)).*JLa,Q.Zmes2./1000);