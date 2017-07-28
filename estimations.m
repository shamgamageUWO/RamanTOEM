function [CJL, CJLa,CJHa] = estimations(Q)



Zi = Q.Zmes;
ind1 = Zi>=8000 & Zi< 10000;
ind2 = Zi>=1500 & Zi< 1700;
% ind3 = Zi
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Removing true background from the desaturated signal
SJH = Q.JHnew - Q.BaJH;
SJL = Q.JLnew - Q.BaJL;
SJHa = Q.JHnewa - Q.BaJHa;
SJLa = Q.JLnewa - Q.BaJLa;
% SJHa = Q.JHnewa;
% SJLa = Q.JLnewa;

    OVa = ones(1,length(Q.Ta));
    Q.OVlength = length(OVa);

%     x = [Q.Ta 0 0 1 OVa 0 0 1 1]; Run this to retrieve CJH independently
    x = [Q.Ta 0 0 1 OVa 0 0 1 Q.deadtimeJH Q.deadtimeJL]; % coupled analog channels


    [JL,JH,JLa,JHa]=forwardmodelTraman(Q,x);


    CJL = nanmean(SJL(ind1)./JL(ind1)');
%     CJH = nanmean(SJH(ind1)./JH(ind1)');
% 
    CJLa = nanmean(SJLa(ind2)./JLa(ind2)');
   CJHa = nanmean(SJHa(ind2)./JHa(ind2)');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Overlap estimation
    % %     JLwoOV = ((CJL.*JL))+ Bg_JL_real;
    % %     JHwoOV = ((Q.R.*CJL.*JH))+ Bg_JH_real;
    % %      OVz = (JLnew + JHnew)./(JLwoOV + JHwoOV)';
    %
    %     %  OVz = (JLnew + JHnew- Bg_JL_real- Bg_JH_real)./(JLwoOV + JHwoOV)';
    %     % figure;plot(Q.Zmes./1000,OVz,'b'); hold on;
%     
%     JLwoOV = ((CJL.*JL));
%     JHwoOV = ((Q.R.*CJL.*JH));
% %     
%     JLawoOV = ((CJLa.*JLa));
%     JHawoOV = ((Q.Ra.*CJLa.*JHa));
%    JHawoOV = ((CJHa.*JHa));

% %     
% %     % It is now mean of the overlap as the a priori
%      OVz1d = (Q.JLnew - Q.BaJL)./(JLwoOV )';
%      OVz2d = (Q.JHnew - Q.BaJH)./(JHwoOV )';
% %     
%     OVz1a = (Q.JLnewa - Q.BaJLa)./(JLawoOV )';
%      OVz2a = (Q.JHnewa - Q.BaJHa)./(JHawoOV )';
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