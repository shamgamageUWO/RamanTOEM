% Temperature Covariance test

% % % % % Input : US Temperatures
% % % % % Output : Temperature covariance
function [S_rh]=RHCov(Zj,Ta)
 
 
 m = length(Ta);
 n = m;
 
 lengthcT = 1000; % =3000; % only need m of these
%  Tfac = 1;
%   Tmodvar = (Tfac.*ones(size(Ta))).^2;
   Tmodvar = (.1.*Ta).^2;
 vars2 = Tmodvar;
 lc = lengthcT.*ones(1,m);
 S_rh =zeros(n,n);

for i = 1:m
    for j = 1:m
%          if Zj(i)< 15000 
        sigprod = sqrt(vars2(i).*vars2(j));
        diffz = Zj(i) - Zj(j);
        sumlc = lc(i) + lc(j);
        shape(3) = (1-(1-exp(-1)).*2.*abs(diffz)./sumlc);
        
        if shape(3) < 0
            shape(3) = 0;
        end
        
        S_rh(i,j) = sigprod.*shape(3);
%         if i==j
%         else 
%           S_rh(i,j) = 1e-8;
%          end
    end
end
 


% Sa_T(n-2,n-2) = vars2(n-2);
% Sa_T(n-1,n-1) = vars2(n-1);
 S_rh(n,n) = vars2(n);
%   figure;plot(S_aT,Zj)

        