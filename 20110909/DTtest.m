
DT = 4e-9;
Nob_MHz = 1:10:150;
Nob_Counts = Nob_MHz.*1800.*(3.75./150); 
Nt = Nob_Counts./(1-DT.*Nob_MHz.*1e6);

PD = ((Nt-Nob_Counts)./Nt).*100;

figure;
plot(Nob_MHz,PD)
grid on;
xlabel('MHz')
ylabel('Percent Difference')