function [diff_N2s,diff_N2as,deri_diff_N2s,deri_diff_N2as,J]= reproductionofN2
% Note:- the differential cross section here is not the real diff cross. it
% is the summation over nitrogen term in 10.23 equation

T = 300;
J = [3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22];
effi_stoke = ones(length(J),1);
effi_anti = ones(length(J),1);


% Constants 
h = 6.6262 *10^-27; %erg-s
c = 2.9979*10^10; %cm/s
kb = 1.3807*10^-16; % erg/K
B_N2 = 1.98957;% cm-1
B_O2 = 1.43768;%cm-1
D_N2 = 5.76*10^-6;%cm-1
D_O2 = 4.85*10^-6; %cm-1
r_N2 = 0.51*10^-48; %cm^6
r_O2 = 1.27*10^-48; %cm^6
n_N2 = 1; % relative volume abundance
n_O2 = .2095;
v0 = 1/ (6.934*10^-5); %cm-1 355nm
kb_SI = 1.38064852*10^-23; %Boltzman SI

% For  N2 / Antistokes / diff_cros
I_N2 = 1;
I_O2 = 0;
Const_N2 = (112* pi^4* h*c*r_N2*n_N2 )/((2*I_N2+1)^2 * kb *15);






                    for i =1: length(T)
                        for k = 1: length(J)
                           if mod(J(k),2) == 0
                               gi = 6;
                           else 
                               gi = 3;
                           end
                           
                           Eas(k) = (B_N2*J(k) *(J(k)+1) - D_N2*(J(k)^2)*(J(k)+1)^2)*h*c;
                           shift_N2_as(k) = B_N2 * 2 * (2*(J(k)+2)-1) - D_N2 * (3 * (2*(J(k)+2)-1) + (2*(J(k)+2)-1)^3);
                           Xas(k) = ((J(k)+2)*((J(k)+2)-1))/(2*(J(k)+2)-1);
                           diff_N2as(i,k) = ((effi_anti(k) .* Const_N2*gi*B_N2*(v0+shift_N2_as(k))^4 * Xas(k)* exp(-Eas(k)/ (kb*T(i))))./T(i)).* (10^-4);% convert the units to SI
                           deri_diff_N2as(i,k) = (diff_N2as(i,k).* (Eas(k)./kb_SI -T(i)))./(T(i).^2);

                        end
                        
                    end

                    newwavelength_as = 10^7./(shift_N2_as + v0);


                    % For  N2 / Stokes / diff_cros


                    for i =1: length(T)
                        for k = 1: length(J)
                           if mod(J(k),2) == 0
                               gi = 6;
                           else 
                               gi = 3;
                           end

                           Es(k) = (B_N2*J(k) *(J(k)+1) - D_N2*(J(k))^2*(J(k)+1)^2)*h*c;
                           shift_N2_s(k) = - B_N2 * 2 * (2*J(k)+3) + D_N2 * (3 * (2*J(k)+3) + (2*J(k)+3)^3);
                           Xs(k) = ((J(k)+1)*(J(k)+2))/(2*J(k)+3);
                           diff_N2s(i,k) = ((effi_stoke(k).* Const_N2*gi*B_N2*(v0+shift_N2_s(k))^4 * Xs(k)* exp(-Es(k)/ (kb*T(i))))./T(i)).*(10^-4);
                           deri_diff_N2s(i,k) = (diff_N2s(i,k).* (Es(k)./kb_SI -T(i)))./(T(i).^2);
                        end                      
                    end

                     newwavelength_s = 10^7./(shift_N2_s + v0);

                    
         



