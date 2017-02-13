% Inputs 
T = 200:10:330; % Temperatures from 200 to 300 K
dt= 0.1;
dT = T+dt;
J_low = [3,4,5,6,7,8,9];
J_high = [10,11,12,13,14,15];
J_lowO2 = [5,7,9,11,13];
J_highO2 = [15,17,19,21];


[diff_O2Ls,diff_O2Las,deri_diff_O2Ls,deri_diff_O2Las] = RR_differentialO2_JL(J_lowO2,T); % JL Oxygen 
[diff_O2Hs,diff_O2Has,deri_diff_O2Hs,deri_diff_O2Has] = RR_differentialO2_JH(J_highO2,T);% JH Oxygen
[diff_N2Ls,diff_N2Las,deri_diff_N2Ls,deri_diff_N2Las] = RR_differentialN2_JL(J_low,T);% JL Nitrogen
[diff_N2Hs,diff_N2Has,deri_diff_N2Hs,deri_diff_N2Has] = RR_differentialN2_JH(J_high,T);% JH Nitrogen

[diff_O2Lsdt,diff_O2Lasdt,deri_diff_O2Lsdt,deri_diff_O2Lasdt] = RR_differentialO2_JL(J_lowO2,dT); % JL Oxygen 
[diff_O2Hsdt,diff_O2Hasdt,deri_diff_O2Hsdt,deri_diff_O2Hasdt] = RR_differentialO2_JH(J_highO2,dT);% JH Oxygen
[diff_N2Lsdt,diff_N2Lasdt,deri_diff_N2Lsdt,deri_diff_N2Lasdt] = RR_differentialN2_JL(J_low,dT);% JL Nitrogen
[diff_N2Hsdt,diff_N2Hasdt,deri_diff_N2Hsdt,deri_diff_N2Hasdt] = RR_differentialN2_JH(J_high,dT);% JH Nitrogen

%% 
JL = nansum(diff_O2Ls')+ nansum(diff_O2Las')+nansum(diff_N2Ls')+nansum(diff_N2Las');
JH = nansum(diff_N2Hs')+nansum(diff_N2Has')+nansum(diff_O2Hs')+nansum(diff_O2Has');
JLdt = nansum(diff_O2Lsdt')+ nansum(diff_O2Lasdt')+nansum(diff_N2Lsdt')+nansum(diff_N2Lasdt');
JHdt = nansum(diff_N2Hsdt')+nansum(diff_N2Hasdt')+nansum(diff_O2Hsdt')+nansum(diff_O2Hasdt');

analytical_deri_JL = nansum(deri_diff_O2Ls')+ nansum(deri_diff_O2Las')+nansum(deri_diff_N2Ls')+nansum(deri_diff_N2Las');
analytical_deri_JH = nansum(deri_diff_N2Hs')+nansum(deri_diff_N2Has')+nansum(deri_diff_O2Hs')+nansum(deri_diff_O2Has');

for i = 1:length(T)
    d_JL_T(i) = (JLdt(i)-JL(i))/dt;
    d_JH_T(i) = (JHdt(i)-JH(i))/dt;
    
end

figure;
subplot(1,2,1)
plot(d_JL_T,T,'r',d_JH_T,T,'b')
ylabel('Temperature (K)')
xlabel('derivative of differential crosssection')

subplot(1,2,2)
plot(analytical_deri_JL,T,'r',analytical_deri_JH,T,'b')
ylabel('Temperature (K)')
xlabel('derivative of differential crosssection')
