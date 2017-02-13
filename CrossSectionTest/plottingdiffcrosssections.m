% Inputs 
function[JL,JH]= plottingdiffcrosssections(T)
J_low = [3,4,5,6,7,8,9];
J_high = [10,11,12,13,14,15];
J_lowO2 = [5,7,9,11,13];
J_highO2 = [15,17,19,21];


[diff_O2Ls,diff_O2Las,deri_diff_O2Ls,deri_diff_O2Las] = RR_differentialO2_JL(J_lowO2,T); % JL Oxygen 
[diff_O2Hs,diff_O2Has,deri_diff_O2Hs,deri_diff_O2Has] = RR_differentialO2_JH(J_highO2,T);% JH Oxygen
[diff_N2Ls,diff_N2Las,deri_diff_N2Ls,deri_diff_N2Las] = RR_differentialN2_JL(J_low,T);% JL Nitrogen
[diff_N2Hs,diff_N2Has,deri_diff_N2Hs,deri_diff_N2Has] = RR_differentialN2_JH(J_high,T);% JH Nitrogen

%% Plot O2 and N2, stokes and antistokes crosssection terms seperately for JL and JH and their derivatives
% % figure;
% % subplot1=subplot(2,2,1);
% % plot(nansum(diff_O2Ls'),T,'g',nansum(diff_O2Las'),T,'b',nansum(diff_O2Hs'),T,'r',nansum(diff_O2Has'),T,'y')
% % xlabel('cross section (m^2)')
% % ylabel('Temperature(K)')
% % box(subplot1,'on');
% % % Create legend
% % legend(subplot1,'show');
% % 
% % 
% % subplot2=subplot(2,2,2);
% % plot(nansum(diff_N2Ls'),T,'g',nansum(diff_N2Las'),T,'b',nansum(diff_N2Hs'),T,'r',nansum(diff_N2Has'),T,'y')
% % xlabel('cross section (m^2)')
% % ylabel('Temperature(K)')
% % box(subplot2,'on');
% % % Create legend
% % legend(subplot2,'show');
% % 
% % subplot3=subplot(2,2,3);
% % plot(nansum(deri_diff_O2Ls'),T,'g',nansum(deri_diff_O2Las'),T,'b',nansum(deri_diff_O2Hs'),T,'r',nansum(deri_diff_O2Has'),T,'y')
% % xlabel('cross section derivative (m^2/K)')
% % ylabel('Temperature(K)')
% % box(subplot3,'on');
% % % Create legend
% % legend(subplot3,'show');
% % 
% % subplot4=subplot(2,2,4);
% % plot(nansum(deri_diff_N2Ls'),T,'g',nansum(deri_diff_N2Las'),T,'b',nansum(deri_diff_N2Hs'),T,'r',nansum(deri_diff_N2Has'),T,'y')
% % xlabel('cross section derivative (m^2/K)')
% % ylabel('Temperature(K)')
% % box(subplot4,'on');
% % % Create legend
% % legend(subplot4,'show');
% % 
% % %% Plot O2 and N2, summation of stokes and antistokes terms for JL and JH and their derivatives
% % figure;
% % subplot5=subplot(2,2,1);
% % plot(nansum(diff_O2Ls')+ nansum(diff_O2Las'),T,'b',nansum(diff_O2Hs')+nansum(diff_O2Has'),T,'y')
% % xlabel('cross section (m^2)')
% % ylabel('Temperature(K)')
% % box(subplot5,'on');
% % % Create legend
% % legend(subplot5,'show');
% % 
% % subplot6=subplot(2,2,2);
% % plot(nansum(diff_N2Ls')+nansum(diff_N2Las'),T,'b',nansum(diff_N2Hs')+nansum(diff_N2Has'),T,'y')
% % xlabel('cross section (m^2)')
% % ylabel('Temperature(K)')
% % box(subplot6,'on');
% % % Create legend
% % legend(subplot6,'show');
% % 
% % subplot7=subplot(2,2,3);
% % plot(nansum(deri_diff_O2Ls')+nansum(deri_diff_O2Las'),T,'b',nansum(deri_diff_O2Hs')+nansum(deri_diff_O2Has'),T,'y')
% % xlabel('cross section derivative (m^2/K)')
% % ylabel('Temperature(K)')
% % box(subplot7,'on');
% % % Create legend
% % legend(subplot7,'show');
% % 
% % subplot8=subplot(2,2,4);
% % plot(nansum(deri_diff_N2Ls')+nansum(deri_diff_N2Las'),T,'b',nansum(deri_diff_N2Hs')+nansum(deri_diff_N2Has'),T,'y')
% % xlabel('cross section derivative (m^2/K)')
% % ylabel('Temperature(K)')
% % box(subplot8,'on');
% % % Create legend
% % legend(subplot8,'show');
% % 
% % %% Plot summation of stokes and antistokes of O2 and N2 terms, for JL and JH and their derivatives
% % figure;
% % subplot9=subplot(1,2,1);
% % plot(nansum(diff_O2Ls')+ nansum(diff_O2Las')+nansum(diff_N2Ls')+nansum(diff_N2Las'),T,'b',nansum(diff_N2Hs')+nansum(diff_N2Has')+nansum(diff_O2Hs')+nansum(diff_O2Has'),T,'y')
% % xlabel('cross section (m^2)')
% % ylabel('Temperature(K)')
% % box(subplot9,'on');
% % % Create legend
% % legend(subplot9,'show');
% % 
% % subplot10=subplot(1,2,2);
% % plot(nansum(deri_diff_O2Ls')+ nansum(deri_diff_O2Las')+nansum(deri_diff_N2Ls')+nansum(deri_diff_N2Las'),T,'b',nansum(deri_diff_N2Hs')+nansum(deri_diff_N2Has')+nansum(deri_diff_O2Hs')+nansum(deri_diff_O2Has'),T,'y')
% % xlabel('cross section derivative (m^2/K)')
% % ylabel('Temperature(K)')
% % box(subplot1,'on');
% % % Create legend
% % legend(subplot10,'show');

%% Plotting normalized values
JL = nansum(diff_O2Ls')+ nansum(diff_O2Las')+nansum(diff_N2Ls')+nansum(diff_N2Las');
JH = nansum(diff_N2Hs')+nansum(diff_N2Has')+nansum(diff_O2Hs')+nansum(diff_O2Has');
figure;
plot(T,JL,'r',T,JH,'b')
% hold on;
% Q = (JH./nansum(JH))./(JL./nansum(JL));
% plot(T,Q,'g')
% hold off;