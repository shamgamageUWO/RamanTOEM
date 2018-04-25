function ext = Aerosol2method (Q)

% Inputs 
% JL+ JH Raman digital counts above 5km
% Number Density from Sonde
% molecular Exctinction (Transmission code)

% Function alpha_aero = diff [n/((Stot - Btot)R^2)]-alpha_mol


ind = Q.Zmes2>= 5000;
ind2 = Q.Zmes>= 5000;

JL_bgremoved = Q.JLnew(ind) -Q.BaJL;
JH_bgremoved = Q.JHnew(ind) -Q.BaJH;
Mo = JL_bgremoved + JH_bgremoved;

figure;
subplot(2,2,1)
plot(JL_bgremoved,Q.Zmes2(ind)./1000,'r',JH_bgremoved,Q.Zmes2(ind)./1000,'b',Mo,Q.Zmes2(ind)./1000,'g')
legend('JL','JH','total')
ylim( [5 12])

Nair = Q.rho(ind);
Nair = Nair';
n2 = Q.Nmol(ind);

z = Q.Zmes(ind);
z =z';
dz=diff([z(1)-(z(2)-z(1)); z]);


ExtMo  = Q.alpha_mol(ind2);

% Take the Ratio 

X = log(Nair./z.^2./Mo');

subplot(2,2,2)
plot(X,Q.Zmes2(ind)./1000)
legend('Ratio')
ylim( [5 12])

% design window size
% w0=100;
% z0=5000;
% z_ref=12000;
% A=w0/exp(z_ref/z0);
% w=A*exp(z/z0);
% w=ceil(w);

w = 100.*ones(1,length(z));

% calculate the derivative order P=1
Xd=nan(size(X));
P=1;
i=1;
while z(i)<12000
        
    if i<w(i)+1 || i>length(X)-w(i)-1
        i=i+1;
        continue
    end
    
    % design the SG filter
    [B,G]=sgolay(3,2*w(i)+1);
    
    Xd(i)=G(:,P+1)'*X(i-w(i):i+w(i))/dz(i);
    
    i=ceil(i+w(i)/3);
    
end

ind=find(isnan(Xd)==0);




% calculate extinction
ext.z = z(ind);
ext.ext = .5*Xd(ind) - ExtMo(ind)';
ext.relerr = nan(size(z));

subplot(2,2,3)
plot(ext.ext,ext.z./1000,'r')
 legend('alpha aerosol')
 ylim( [4 12])

 
alpha_aero_5 = interp1(ext.z ,ext.ext,Q.Zmes(ind2),'linear');
 
alpha_aero = [Q.alpha_aero(Q.Zmes< 5000); alpha_aero_5'];

subplot(2,2,4)
plot(alpha_aero,Q.Zmes./1000,'r',Q.alpha_aero,Q.Zmes./1000,'b')
 legend('alpha aerosol new','alpha aerosol old')
 ylim( [0 12]) 

alpha_tot = alpha_aero + Q.alpha_mol';
Tr = exp(-2.*cumtrapz(Q.Zmes,alpha_tot)); % total transmission

figure;
plot(Tr,Q.Zmes./1000,'r')
hold on;
plot(Q.Tr,Q.Zmes./1000,'g')
hold off
 legend('Total Transmission new', 'Total Transmission old')
 ylim( [4 12]) 
 
 
 
 
% 
% % Take the Log 
% Log_Ratio = log(1./Ratio);
% subplot(2,2,3)
% plot(Log_Ratio,Q.Zmes2(ind)./1000)
% legend('Log of 1/Ratio')
% ylim( [5 10])
% 
% % Differentiate 
% Diff_Ratio = real(diff(Log_Ratio./2));
% 
% subplot(2,2,4)
% plot(Diff_Ratio)
% legend('Derivative of Log of 1/Ratio')
% 
% % figure;plot(Diff_Ratio)
% %   Diff_Ratio = [Diff_Ratio Diff_Ratio(end)];
% 
% % Remove molecular alpha
% alpha_aero_5 = Diff_Ratio.*1e-4 - alpha_mol;
% 
% figure;plot(alpha_aero_5,Q.Zmes(ind2)./1000)
% ylim( [5 10])
% legend('alpha aero')
% alpha_tot = [Q.alpha_aero(Q.Zmes< 5000); alpha_aero_5'];
%  Tr = exp(-2.*cumtrapz(Q.Zmes,alpha_tot)); % total transmission
%  Tr = Tr';
% 
% 

% 
% 
