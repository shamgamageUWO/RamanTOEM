function DiffInput  = Diff_cross_fun

% Constants 
DiffInput.effi_stokeN2_JH = [0.22742041,0.61706630,1,0.66219893,0.26342483,0.00549319,0];
DiffInput.effi_antiN2_JH = [0.20278330,0.57977270,0.99609541,0.71343372,0.31181249,0.02739112,0];

DiffInput.effi_stokeO2_JH = [0.37619836,0.98166707,0.53912801,0.0511171,0];
DiffInput.effi_antiO2_JH = [0.34586496,0.94294973,0.59074973,0.08572700,0];

DiffInput.effi_stokeO2_JL = [0.02301580,0.48028012,1,0.43039766,0.00583559];
DiffInput.effi_antiO2_JL = [0.02098297,0.47166835,1,0.44867305,0.01345647];

DiffInput.effi_stokeN2_JL = [0.00025546,0.23878872,0.63072501,1,0.64955950,0.25355097,0.00289517];
DiffInput.effi_antiN2_JL = [0,0.23299892,0.62055134,1,0.66708875,0.27132321,0.00944014];

DiffInput.h = 6.6262 *10^-27; %erg-s
DiffInput.c = 2.9979*10^10; %cm/s
DiffInput.kb = 1.3807*10^-16; % erg/K
DiffInput.B_N2 = 1.98957;% cm-1
DiffInput.B_O2 = 1.43768;%cm-1
DiffInput.D_N2 = 5.76*10^-6;%cm-1
DiffInput.D_O2 = 4.85*10^-6; %cm-1
DiffInput.r_N2 = 0.51*10^-48; %cm^6
DiffInput.r_O2 = 1.27*10^-48; %cm^6
DiffInput.n_N2 = .7808; % relative volume abundance
DiffInput.n_O2 = .2095;
DiffInput.v0 = 1/ (3.547*10^-5); %cm-1 355nm
DiffInput.kb_SI = 1.38064852*10^-23; %Boltzman SI
DiffInput.I_N2 = 1;
DiffInput.I_O2 = 0;
DiffInput.Const_N2 = (112* pi^4* DiffInput.h*DiffInput.c*DiffInput.r_N2*DiffInput.n_N2 )/((2*DiffInput.I_N2+1)^2 * DiffInput.kb *15);
DiffInput.Const_O2 = (112* pi^4* DiffInput.h*DiffInput.c*DiffInput.r_O2*DiffInput.n_O2 )/((2*DiffInput.I_O2+1)^2 * DiffInput.kb *15);


%Q numbers
JHO2= [15,17, 19, 21,0];
JLO2 = [5,7,9,11,13];
JHN2 =[10,11,12,13,14,15,0];
JLN2 =[3,4,5,6,7,8,9];

% rotational energy
DiffInput.ErotJHO2=[];
DiffInput.ErotJLO2=[];
DiffInput.ErotJHN2=[];
DiffInput.ErotJLN2=[];

% JH_O2
for i = 1:length(JHO2)
  
    DiffInput.ErotJHO2(i)= (DiffInput.B_O2.*JHO2(i) *(JHO2(i)+1) - DiffInput.D_O2.*(JHO2(i)^2).*(JHO2(i)+1)^2)*DiffInput.h*DiffInput.c;
    DiffInput.shift_JHO2_as(i) = DiffInput.B_O2 * 2 * (2*(JHO2(i)+2)-1) - DiffInput.D_O2 * (3 * (2*(JHO2(i)+2)-1) + (2*(JHO2(i)+2)-1)^3);
    DiffInput.shift_JHO2_s(i) =  -DiffInput.B_O2 * 2 * (2*JHO2(i)+3) + DiffInput.D_O2 * (3 * (2*JHO2(i)+3) + (2*JHO2(i)+3)^3);
    DiffInput.X_JHO2_as(i) = ((JHO2(i)+2)*((JHO2(i)+2)-1))/(2*(JHO2(i)+2)-1);
    DiffInput.X_JHO2_s(i) = ((JHO2(i)+1)*(JHO2(i)+2))/(2*JHO2(i)+3);
    
end

% JH_N2

for i = 1:length(JHN2)
DiffInput.ErotJHN2(i)= (DiffInput.B_N2.*JHN2(i) *(JHN2(i)+1) - DiffInput.D_N2.*(JHN2(i)^2).*(JHN2(i)+1)^2)*DiffInput.h*DiffInput.c;
DiffInput.shift_JHN2_as(i) = DiffInput.B_N2 * 2 * (2*(JHN2(i)+2)-1) - DiffInput.D_N2 * (3 * (2*(JHN2(i)+2)-1) + (2*(JHN2(i)+2)-1)^3);
DiffInput.shift_JHN2_s(i) =  -DiffInput.B_N2 * 2 * (2*JHN2(i)+3) + DiffInput.D_N2 * (3 * (2*JHN2(i)+3) + (2*JHN2(i)+3)^3);
DiffInput.X_JHN2_as(i) = ((JHN2(i)+2)*((JHN2(i)+2)-1))/(2*(JHN2(i)+2)-1);
DiffInput.X_JHN2_s(i) = ((JHN2(i)+1)*(JHN2(i)+2))/(2*JHN2(i)+3);

end 



% JL_O2
for i = 1:length(JLO2)
    
    DiffInput.ErotJLO2(i)= (DiffInput.B_O2.*JLO2(i) *(JLO2(i)+1) - DiffInput.D_O2.*(JLO2(i)^2).*(JLO2(i)+1)^2)*DiffInput.h*DiffInput.c;
    DiffInput.shift_JLO2_as(i) =DiffInput.B_O2 * 2 * (2*(JLO2(i)+2)-1) - DiffInput.D_O2 * (3 * (2*(JLO2(i)+2)-1) + (2*(JLO2(i)+2)-1)^3);
    DiffInput.shift_JLO2_s(i) =  -DiffInput.B_O2 * 2 * (2*JLO2(i)+3) + DiffInput.D_O2 * (3 * (2*JLO2(i)+3) + (2*JLO2(i)+3)^3);
    DiffInput.X_JLO2_as(i) = ((JLO2(i)+2)*((JLO2(i)+2)-1))/(2*(JLO2(i)+2)-1);
    DiffInput.X_JLO2_s(i) = ((JLO2(i)+1)*(JLO2(i)+2))/(2*JLO2(i)+3);
    
end


% JL_N2
for i = 1:length(JLN2)
    
    DiffInput.ErotJLN2(i)= (DiffInput.B_N2.*JLN2(i) *(JLN2(i)+1) - DiffInput.D_N2.*(JLN2(i)^2).*(JLN2(i)+1)^2)*DiffInput.h*DiffInput.c;
    DiffInput.shift_JLN2_as(i) = DiffInput.B_N2 * 2 * (2*(JLN2(i)+2)-1) - DiffInput.D_N2 * (3 * (2*(JLN2(i)+2)-1) + (2*(JLN2(i)+2)-1)^3);
    DiffInput.shift_JLN2_s(i) =  -DiffInput.B_N2 * 2 * (2*JLN2(i)+3) + DiffInput.D_N2 * (3 * (2*JLN2(i)+3) + (2*JLN2(i)+3)^3);
    DiffInput.X_JLN2_as(i) = ((JLN2(i)+2)*((JLN2(i)+2)-1))/(2*(JLN2(i)+2)-1);
    DiffInput.X_JLN2_s(i) = ((JLN2(i)+1)*(JLN2(i)+2))/(2*JLN2(i)+3);
end



  

DiffInput.JHO2 = JHO2;
DiffInput.JLO2 = JLO2;
DiffInput.JHN2 = JHN2;
DiffInput.JLN2 = JLN2;



        



