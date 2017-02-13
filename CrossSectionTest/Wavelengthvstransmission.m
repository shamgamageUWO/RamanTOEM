
%function [effi_stoke_JLN2,effi_anti_JLN2,shift_JLN2_as,shift_JLN2_s,diff_N2JLs,diff_N2JLas,effi_stoke_JHN2,effi_anti_JHN2,shift_JHN2_as,shift_JHN2_s,diff_N2JHs,diff_N2JHas]=Wavelengthvstransmission 
T = [300];
c = [1 0];

figure1 = figure('Color',[1 1 1]);
axes1 = axes('Parent',figure1);
hold(axes1,'on');

for i=1:length(T)
    
% J_low = [1,2,3,4,5,6,7,8,9];
% J_high = [10,11,12,13,14,15];
% J_lowO2 = [1,3,5,7,9,11,13];
% J_highO2 = [15,17,19,21];
J_low = [3,4,5,6,7,8,9];
J_high = [10,11,12,13,14,15];
J_lowO2 = [5,7,9,11,13];
J_highO2 = [15,17,19,21];

% Nitrogen

[effi_stoke_JLN2,effi_anti_JLN2,shift_JLN2_as,shift_JLN2_s,diff_N2JLs,diff_N2JLas]= RR_differentialN2_JL_transmission(J_low,T(i));
[effi_stoke_JHN2,effi_anti_JHN2,shift_JHN2_as,shift_JHN2_s,diff_N2JHs,diff_N2JHas]= RR_differentialN2_JH_transmission(J_high,T(i));

h1=stem(shift_JLN2_s,(diff_N2JLs)./1e-34,'b');
h2=stem(shift_JLN2_as,(diff_N2JLas)./1e-34,'b');
h3=stem(shift_JHN2_s,(diff_N2JHs)./1e-34,'b'); 
h4=stem(shift_JHN2_as,(diff_N2JHas)./1e-34,'b');

% stem(shift_JLN2_s,(diff_N2JLs)./max(diff_N2JLs),'DisplayName','Nitrogen','Color',[1 c(i) 0]);
% stem(shift_JLN2_as,(diff_N2JLas)./max(diff_N2JLas),'Color',[1 c(i) 0]);
% stem(shift_JHN2_s,(diff_N2JHs)./max(diff_N2JHs),'Color',[1 c(i) 0]); 
% stem(shift_JHN2_as,(diff_N2JHas)./max(diff_N2JHas),'Color',[1 c(i) 0]);


% stem(shift_JLN2_s,effi_stoke_JLN2,'DisplayName','Nitrogen','Color','r');
% stem(shift_JLN2_as,effi_anti_JLN2,'r');
% stem(shift_JHN2_s,effi_stoke_JHN2,'r'); 
% stem(shift_JHN2_as,effi_anti_JHN2,'r');

% Oxygen
[effi_stoke_JLO2,effi_anti_JLO2,shift_JLO2_as,shift_JLO2_s,diff_O2JLs,diff_O2JLas]= RR_differentialO2_JL_transmission(J_lowO2,T(i));
[effi_stoke_JHO2,effi_anti_JHO2,shift_JHO2_as,shift_JHO2_s,diff_O2JHs,diff_O2JHas]= RR_differentialO2_JH_transmission(J_highO2,T(i));



% stem(shift_JLO2_s,effi_stoke_JLO2,'DisplayName','Oxygen','Color','b','Marker','x');
% stem(shift_JLO2_as,effi_anti_JLO2,'b','Marker','x');
% stem(shift_JHO2_s,effi_stoke_JHO2,'b','Marker','x'); 
% stem(shift_JHO2_as,effi_anti_JHO2,'b','Marker','x');

% stem(shift_JLO2_s,(diff_O2JLs)./max(diff_O2JLs),'DisplayName','Oxygen','Color',[0 0 c(i)],'Marker','x');
% stem(shift_JLO2_as,(diff_O2JLas)./max(diff_O2JLas),'Color',[0 0 c(i)],'Marker','x');
% stem(shift_JHO2_s,(diff_O2JHs)./max(diff_O2JHs),'Color',[0 0 c(i)],'Marker','x'); 
% stem(shift_JHO2_as,(diff_O2JHas)./max(diff_O2JHas),'Color',[0 0 c(i)],'Marker','x');
% 
h5=stem(shift_JLO2_s,(diff_O2JLs)./1e-34,'r','Marker','x');
h6=stem(shift_JLO2_as,(diff_O2JLas)./1e-34,'r','Marker','x');
h7=stem(shift_JHO2_s,(diff_O2JHs)./1e-34,'r','Marker','x'); 
h8=stem(shift_JHO2_as,(diff_O2JHas)./1e-34,'r','Marker','x');
% 
% ylabel('Normalized Intensity')
% xlabel('Frequency Shift (cm-1)')
% % Uncomment the following line to preserve the Y-limits of the axes
% % ylim(axes1,[0 1.1]);
% box(axes1,'on');
% % Set the remaining axes properties
% set(axes1,'FontSize',16);


end

hold off;
% print('improvedExample','-dpng','-r300');
% [diff_O2Ls,diff_O2Las,deri_diff_O2Ls,deri_diff_O2Las] = RR_differentialO2_JL(J_lowO2,T); % JL Oxygen 
% [diff_O2Hs,diff_O2Has,deri_diff_O2Hs,deri_diff_O2Has] = RR_differentialO2_JH(J_highO2,T);% JH Oxygen


