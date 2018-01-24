% Temperature Covariance test

% % % % % Input : US Temperatures
% % % % % Output : Temperature covariance
function [S_OV]=OVCov(Zj,OV)
 Zj = Zj';
% ind = Zj<15000;
 m = length(OV);
 n = m;
 S_OV =zeros(n,n);
 lengthcT = 1000; % =3000; % only need m of these
 lc = lengthcT.*ones(1,m);
 l = size(OV);
 
  Tfac = 1;
  Tmodvar = (Tfac.*ones(l)).^2;
% %  
%  ll = size(OV);
%  Tfac2 =0.0001;
%  Tmodvar2 = (Tfac2.*ones(1,ll(2)-l(2))).^2;
% 
%  vars2 = [Tmodvar Tmodvar2];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 
%  
% deltaZ = 2000;
% ind = Zj<=15000;
% ind2 = Zj>15000 & Zj<17000;
% ind3 = Zj>=17000;
% % 
% l1=length(Zj(ind));
% l2=length(Zj(ind2));
% l3 = length(Zj(ind3));
% % % 
% % % L = Zj(ind);
% % % L2 = Zj(ind2);
% % % L3 = Zj(ind3);
% OVstdl = 0.012;
% OVstd2 = 0.00001;
% 
% h1 = OVstdl.* ones(1,l1);
% h3 = OVstd2.* ones(1,l3);
% 
% % 
% a = (OVstdl + OVstd2 )/deltaZ;
% pl(1) = a* 250; % change these to general form
% for i = 1:6  % change these to general form
% pl(i+1)= pl(1)*(i+1);
% end
% ppl=fliplr(pl);
% OV_dia  =[h1 ppl h3];
% 
% 
% Tmodvar = (OV_dia.*ones(l)).^2;
% % LL = 1:deltaZ;
% % pl = a.*LL;
% 
% plot(Zj,OV_dia,'b')
% % hold off
vars2 = Tmodvar ;
 
 
 
 
 

for i = 1:m
    for j = 1:m
         if Zj(i)< 60000 % this is to force the ov to go to 1.
%             disp('ok')
            sigprod = sqrt(vars2(i).*vars2(j));
            diffz = Zj(i) - Zj(j);
            sumlc = lc(i) + lc(j);
            shape(3) = (1-(1-exp(-1)).*2.*abs(diffz)./sumlc);
            
            if shape(3) < 0
                shape(3) = 0;
            end
            
            S_OV(i,j) = sigprod.*shape(3);
            %         if i==j
            %          Sa_T(i,j) = Ta(i);
            %         end
         else
             S_OV(i,i) = 1e-5;
         end
    end
end


%  S_OV(n,n) = vars2(n);
 
%   figure;plot(S_OV,Zj)

% Sa_T(n-2,n-2) = vars2(n-2);
% Sa_T(n-1,n-1) = vars2(n-1);

%   figure;plot(S_aT,Zj)

        