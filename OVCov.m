% Temperature Covariance test

% % % % % Input : US Temperatures
% % % % % Output : Temperature covariance
function [S_OV]=OVCov(Zj,OV)
 
%  ind = Zj<15000;
 m = length(OV);
 n = m;
 S_OV =zeros(n,n);
 lengthcT = 6000; % =3000; % only need m of these
 lc = lengthcT.*ones(1,m);
 
 l = size(OV);
 Tfac = 1;
 Tmodvar = (Tfac.*ones(l)).^2;
 
%  ll = size(OV);
%  Tfac2 =0.0001;
%  Tmodvar2 = (Tfac2.*ones(1,ll(2)-l(2))).^2;

 vars2 = Tmodvar;




for i = 1:m
    for j = 1:m
%         if Zj<15000 % this is to force the ov to go to 1.
            
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
%         else
%             S_OV(i,i) = 1;
%         end
    end
end


 S_OV(n,n) = vars2(n);
 
%  figure;plot(S_OV,Zj)

% Sa_T(n-2,n-2) = vars2(n-2);
% Sa_T(n-1,n-1) = vars2(n-1);

%   figure;plot(S_aT,Zj)

        