function [CJL, CJLa,OV] = estimations(Q)



Zi = Q.Zmes;
ind1 = Zi>=8000 & Zi< 10000;
ind2 = Zi>=4000 & Zi< 6000;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Removing true background from the desaturated signal
SJH = Q.JHnew - Q.BaJH;
SJL = Q.JLnew - Q.BaJL;
SJHa = Q.JHnewa - Q.BaJHa;
SJLa = Q.JLnewa - Q.BaJLa;

    OVa = ones(1,length(Q.Ta));
    Q.OVlength = length(OVa);

    x = [Q.Ta 0 0 1 OVa 0 0 1];

    [JL,JH,JLa,JHa,A_Zi,B_Zi,Diff_JL_i,Diff_JH_i,Ti]=forwardmodelTraman(Q,x);


    CJL = nanmean(SJL(ind1)./JL(ind1)');
    CJH = nanmean(SJH(ind1)./JH(ind1)');

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
    
    JLwoOV = ((CJL.*JL));
    JHwoOV = ((Q.R.*CJL.*JH));
    
%     JLawoOV = ((CJLa.*JLa));
%     JHawoOV = ((Q.Ra.*CJLa.*JHa));
    % It is now mean of the overlap as the a priori
    OVz1 = (Q.JLnew - Q.BaJL)./(JLwoOV )';
    OVz2 = (Q.JHnew - Q.BaJH)./(JHwoOV )';
%     OVza1 = (Q.JLnewa - Q.BaJLa)./(JLawoOV )';
%     OVza2 = (Q.JHnewa - Q.BaJHa)./(JHawoOV )';
    
    OVz = (OVz1+OVz2)./2;
    OVz = smooth(OVz,5);
    
    OV = interp1(Q.Zmes,OVz,Q.Zret); % this is to smooth
    OV(OV>=1)=1;
    h = find(OV==1);
    OV(h(1):end)=1;
%  plot(Q.Zret./1000,OV,'y')
% hold off;
% legend('Before interpolation','After interpolation','Final OV smoothed')

