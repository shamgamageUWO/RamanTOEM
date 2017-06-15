% Save Differential crosssection values in to a mat file

T = [ 90:500];
DiffInput  = Diff_cross_fun;
[Diff_JH,Diff_JL]= DifferentialCross(DiffInput,T);

figure;plot(Diff_JH,T,'b',Diff_JL,T,'r')
xlabel( ' Diff Crosssection (m^-2)')
ylabel('Temperature (K)')
legend('JH','JL')

filename = 'DiffCrossSections.mat';
save(filename)