function [ Tr,alpha_aero_5] = ShamasrNew (Q)

% Inputs 
% JL+ JH Raman digital counts above 5km
% Number Density from Sonde
% molecular Exctinction (Transmission code)

% Function alpha_aero = diff [n/((Stot - Btot)R^2)]-alpha_mol


ind = Q.Zmes2>= 5000;
ind2 = Q.Zmes>= 5000;

JL_bgremoved = Q.JLnew(ind) -Q.BaJL;
JH_bgremoved = Q.JHnew(ind) -Q.BaJH;
S_t = JL_bgremoved + JH_bgremoved;

figure;
subplot(2,2,1)
plot(JL_bgremoved,Q.Zmes2(ind)./1000,'r',JH_bgremoved,Q.Zmes2(ind)./1000,'b',S_t,Q.Zmes2(ind)./1000,'g')
legend('JL','JH','total')
ylim( [5 10])

n1 = Q.rho(ind);
n2 = Q.Nmol(ind);

z = Q.Zmes(ind);
R_2 = z.^2; % Range

alpha_mol = Q.alpha_mol(ind2);

% Take the Ratio 

% Ratio = (S_t.* R_2')./n1';
Ratio = (S_t.* R_2)./n1;
Ratio2 = (S_t.* R_2)./n2;

subplot(2,2,2)
plot(Ratio,Q.Zmes2(ind)./1000)
legend('Ratio')
ylim( [5 10])

% Take the Log 
Log_Ratio = log(1./Ratio);
subplot(2,2,3)
plot(Log_Ratio,Q.Zmes2(ind)./1000)
legend('Log of 1/Ratio')
ylim( [5 10])

% Differentiate 
Diff_Ratio = real(diff(Log_Ratio./2));

subplot(2,2,4)
plot(Diff_Ratio)
legend('Derivative of Log of 1/Ratio')

% figure;plot(Diff_Ratio)
%   Diff_Ratio = [Diff_Ratio Diff_Ratio(end)];

% Remove molecular alpha
alpha_aero_5 = Diff_Ratio.*1e-4 - alpha_mol;

figure;plot(alpha_aero_5,Q.Zmes(ind2)./1000)
ylim( [5 10])
legend('alpha aero')
alpha_tot = [Q.alpha_aero(Q.Zmes< 5000); alpha_aero_5'];
 Tr = exp(-2.*cumtrapz(Q.Zmes,alpha_tot)); % total transmission
 Tr = Tr';


 figure;plot(Tr,Q.Zmes./1000,'r')
 legend('total transmission')
 ylim( [0 10])


