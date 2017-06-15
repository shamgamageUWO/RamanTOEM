function [Diff_JH,Diff_JL]= DifferentialCross(DiffInput,T)
tic
    % Diff _ JH _ O2
    for i =1: length(T)
        for k = 1: length(DiffInput.JHO2)
            if mod(DiffInput.JHO2(k),2) == 0
                gi = 0;
            else
                gi = 1;
            end
            
            diff_JHO2s(i,k) = ((DiffInput.effi_stokeO2_JH(k).* DiffInput.Const_O2*gi*DiffInput.B_O2*(DiffInput.v0+DiffInput.shift_JHO2_s(k))^4 * DiffInput.X_JHO2_s(k)* exp(-DiffInput.ErotJHO2(k)/ (DiffInput.kb*T(i))))./T(i)).*(10^-4);% SI m^2
            diff_JHO2as(i,k) = (DiffInput.effi_antiO2_JH(k) .* DiffInput.Const_O2*gi*DiffInput.B_O2*(DiffInput.v0+DiffInput.shift_JHO2_as(k))^4 * DiffInput.X_JHO2_as(k)* exp(-DiffInput.ErotJHO2(k)/ (DiffInput.kb*T(i)))./T(i)).* (10^-4);% convert the units to SI
            diff_JLO2s(i,k) = ((DiffInput.effi_stokeO2_JL(k).* DiffInput.Const_O2*gi*DiffInput.B_O2*(DiffInput.v0+DiffInput.shift_JLO2_s(k))^4 * DiffInput.X_JLO2_s(k)* exp(-DiffInput.ErotJLO2(k)/ (DiffInput.kb*T(i))))./T(i)).*(10^-4);% SI m^2
            diff_JLO2as(i,k) = (DiffInput.effi_antiO2_JL(k) .* DiffInput.Const_O2*gi*DiffInput.B_O2*(DiffInput.v0+DiffInput.shift_JLO2_as(k))^4 * DiffInput.X_JLO2_as(k)* exp(-DiffInput.ErotJLO2(k)/ (DiffInput.kb*T(i)))./T(i)).* (10^-4);% convert the units to SI
            
        end
    end

Diff_JHO2 = nansum(diff_JHO2s') + nansum(diff_JHO2as') ; % new unit is in m^2


   % Diff _ JL _ O2
%     for i =1: length(T)
%         for k = 1: length(DiffInput.JLO2)
%             if mod(DiffInput.JLO2(k),2) == 0
%                 gi = 0;
%             else
%                 gi = 1;
%             end
%             
%             diff_JLO2s(i,k) = ((DiffInput.effi_stokeO2_JL(k).* DiffInput.Const_O2*gi*DiffInput.B_O2*(DiffInput.v0+DiffInput.shift_JLO2_s(k))^4 * DiffInput.X_JLO2_s(k)* exp(-DiffInput.ErotJLO2(k)/ (DiffInput.kb*T(i))))./T(i)).*(10^-4);% SI m^2
%             diff_JLO2as(i,k) = (DiffInput.effi_antiO2_JL(k) .* DiffInput.Const_O2*gi*DiffInput.B_O2*(DiffInput.v0+DiffInput.shift_JLO2_as(k))^4 * DiffInput.X_JLO2_as(k)* exp(-DiffInput.ErotJLO2(k)/ (DiffInput.kb*T(i)))./T(i)).* (10^-4);% convert the units to SI
%             
%         end
%     end

Diff_JLO2 = nansum(diff_JLO2s') + nansum(diff_JLO2as') ; % new unit is in m^2





%    % Diff _ JH _ N2
%     for i =1: length(T)
%         for k = 1: length(DiffInput.JHN2)
%             if mod(DiffInput.JHN2(k),2) == 0
%                 gi = 6;
%             else
%                 gi = 3;
%             end
%             
%             diff_JHN2s(i,k) = ((DiffInput.effi_stokeN2_JH(k).* DiffInput.Const_N2*gi*DiffInput.B_N2*(DiffInput.v0+DiffInput.shift_JHN2_s(k))^4 * DiffInput.X_JHN2_s(k)* exp(-DiffInput.ErotJHN2(k)/ (DiffInput.kb*T(i))))./T(i)).*(10^-4);% SI m^2
%             diff_JHN2as(i,k) = (DiffInput.effi_antiN2_JH(k) .* DiffInput.Const_N2*gi*DiffInput.B_N2*(DiffInput.v0+DiffInput.shift_JHN2_as(k))^4 * DiffInput.X_JHN2_as(k)* exp(-DiffInput.ErotJHN2(k)/ (DiffInput.kb*T(i)))./T(i)).* (10^-4);% convert the units to SI
%             
%         end
%     end





 % Diff _ JL _ N2
    for i =1: length(T)
        for k = 1: length(DiffInput.JLN2)
            if mod(DiffInput.JLN2(k),2) == 0
                gi = 6;
            else
                gi = 3;
            end
            
            diff_JLN2s(i,k) = ((DiffInput.effi_stokeN2_JL(k).* DiffInput.Const_N2*gi*DiffInput.B_N2*(DiffInput.v0+DiffInput.shift_JLN2_s(k))^4 * DiffInput.X_JLN2_s(k)* exp(-DiffInput.ErotJLN2(k)/ (DiffInput.kb*T(i))))./T(i)).*(10^-4);% SI m^2
            diff_JLN2as(i,k) = (DiffInput.effi_antiN2_JL(k) .* DiffInput.Const_N2*gi*DiffInput.B_N2*(DiffInput.v0+DiffInput.shift_JLN2_as(k))^4 * DiffInput.X_JLN2_as(k)* exp(-DiffInput.ErotJLN2(k)/ (DiffInput.kb*T(i)))./T(i)).* (10^-4);% convert the units to SI
            diff_JHN2s(i,k) = ((DiffInput.effi_stokeN2_JH(k).* DiffInput.Const_N2*gi*DiffInput.B_N2*(DiffInput.v0+DiffInput.shift_JHN2_s(k))^4 * DiffInput.X_JHN2_s(k)* exp(-DiffInput.ErotJHN2(k)/ (DiffInput.kb*T(i))))./T(i)).*(10^-4);% SI m^2
            diff_JHN2as(i,k) = (DiffInput.effi_antiN2_JH(k) .* DiffInput.Const_N2*gi*DiffInput.B_N2*(DiffInput.v0+DiffInput.shift_JHN2_as(k))^4 * DiffInput.X_JHN2_as(k)* exp(-DiffInput.ErotJHN2(k)/ (DiffInput.kb*T(i)))./T(i)).* (10^-4);% convert the units to SI
            
        end
    end

Diff_JLN2 = nansum(diff_JLN2s') + nansum(diff_JLN2as') ; % new unit is in m^2
Diff_JHN2 = nansum(diff_JHN2s') + nansum(diff_JHN2as') ; % new unit is in m^2


Diff_JH = Diff_JHN2 + Diff_JHO2;
Diff_JL = Diff_JLN2 + Diff_JLO2;
                   
toc