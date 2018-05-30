% Temperature Covariance test

% % % % % Input : US Temperatures
% % % % % Output : Temperature covariance
function [S_aT]=TestTempCov(Zj,Ta)
 
 
 m = length(Ta);
 n = m;
 
 lengthcT = 1000; % =3000; % only need m of these
   Tfac = 35;
   Tmodvar = (Tfac.*ones(size(Ta))).^2;
%    Tmodvar = (0.3.*Ta).^2;
 vars2 = Tmodvar;
 lc = lengthcT.*ones(1,m);
 S_aT =zeros(n,n);

for i = 1:m
    for j = 1:m
        
        sigprod = sqrt(vars2(i).*vars2(j));
        diffz = Zj(i) - Zj(j);
        sumlc = lc(i) + lc(j);
        shape(3) = (1-(1-exp(-1)).*2.*abs(diffz)./sumlc);
        
        if shape(3) < 0
            shape(3) = 0;
        end
        
        S_aT(i,j) = sigprod.*shape(3);
%         if i==j
%          Sa_T(i,j) = Ta(i);
%         end
    end
end
 


% Sa_T(n-2,n-2) = vars2(n-2);
% Sa_T(n-1,n-1) = vars2(n-1);
 S_aT(n,n) = vars2(n);
%   figure;plot(S_aT,Zj)

        