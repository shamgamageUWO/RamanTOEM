function [diff_O2s,diff_O2as]= RR_differentialO2_JL(J,T)

% Note:- the differential cross section here is not the real diff cross. it
% is the summation over nitrogen term in 10.23 equation

effi_stoke = [0.02301580,0.48028012,1,0.43039766,0.00583559];
effi_anti = [0.02098297,0.47166835,1,0.44867305,0.01345647];

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
n_N2 = .7808; % relative volume abundance
n_O2 = .2095;
v0 = 1/ (3.547*10^-5); %cm-1 355nm
kb_SI = 1.38064852*10^-23; %Boltzman SI
% For  N2 / Antistokes / diff_cros
I_N2 = 1;
I_O2 = 0;
Const_O2 = (112* pi^4* h*c*r_O2*n_O2 )/((2*I_O2+1)^2 * kb *15);



                    for i =1: length(T)
                        for k = 1: length(J)
                           if mod(J(k),2) == 0
                               gi = 0;
                           else 
                               gi = 1;
                           end

                           Eas(k) = (B_O2*J(k) *(J(k)+1) - D_O2*(J(k)^2)*(J(k)+1)^2)*h*c;
%                            shift_O2_as(k) = B_O2 * 2 * (2*(J(k)-2)-1) - D_O2 * (3 * (2*(J(k)-2)-1) + (2*(J(k)-2)-1)^3);
%                            Xas(k) = ((J(k)-2)*((J(k)-2)-1))/(2*(J(k)-2)-1);
                            shift_O2_as(k) = B_O2 * 2 * (2*(J(k)+2)-1) - D_O2 * (3 * (2*(J(k)+2)-1) + (2*(J(k)+2)-1)^3);
                            Xas(k) = ((J(k)+2)*((J(k)+2)-1))/(2*(J(k)+2)-1);
                           diff_O2as(i,k) = ((effi_anti(k) .* Const_O2*gi*B_O2*(v0+shift_O2_as(k))^4 * Xas(k)* exp(-Eas(k)/ (kb*T(i))) )./T(i)).* (10^-4);% convert the units to SI
%                            deri_diff_O2as(i,k) = (diff_O2as(i,k).* (Eas(k)./kb -T(i)))./(T(i).^2);
 Es(k) = (B_O2*J(k) *(J(k)+1) - D_O2*(J(k))^2*(J(k)+1)^2)*h*c;
                           shift_O2_s(k) = -B_O2 * 2 * (2*J(k)+3) + D_O2 * (3 * (2*J(k)+3) + (2*J(k)+3)^3);
                           Xs(k) = ((J(k)+1)*(J(k)+2))/(2*J(k)+3);
                           diff_O2s(i,k) = ((effi_stoke(k).* Const_O2*gi*B_O2*(v0+shift_O2_s(k))^4 * Xs(k)* exp(-Es(k)/ (kb*T(i))))./T(i)).*(10^-4);
%                            deri_diff_O2s(i,k) = (diff_O2s(i,k).* (E

                        end
                    end

                    newwavelength_as = 10^7./(shift_O2_as + v0);


                    % For  N2 / Stokes / diff_cros


%                     for i =1: length(T)
%                         for k = 1: length(J)
%                            if mod(J(k),2) == 0
%                                gi = 0;
%                            else 
%                                gi = 1;
%                            end
%                            
%                            Es(k) = (B_O2*J(k) *(J(k)+1) - D_O2*(J(k))^2*(J(k)+1)^2)*h*c;
%                            shift_O2_s(k) = -B_O2 * 2 * (2*J(k)+3) + D_O2 * (3 * (2*J(k)+3) + (2*J(k)+3)^3);
%                            Xs(k) = ((J(k)+1)*(J(k)+2))/(2*J(k)+3);
%                            diff_O2s(i,k) = ((effi_stoke(k).* Const_O2*gi*B_O2*(v0+shift_O2_s(k))^4 * Xs(k)* exp(-Es(k)/ (kb*T(i))))./T(i)).*(10^-4);
% %                            deri_diff_O2s(i,k) = (diff_O2s(i,k).* (Es(k)./kb -T(i)))./(T(i).^2);
%                         end
%                     end

                    newwavelength_s = 10^7./(shift_O2_s + v0);

                    
        



