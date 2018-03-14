function [asr] = myasr(Q)

[Y] = makeY(Q);

Eb = Y.Eb - Y.bgEb; % background removed Eb
Z = Y.Ebalt;
ind = Z>= 15000 & Z<=40000; 
Eb_highalt = Eb(ind);
z = Z(ind);

figure;plot(Eb_highalt,z./1000)
fit3 = fit(Eb_highalt,z,'exp1');
a = fit3.a;
b = fit3.b;

NewEb = log(Z./a)./b;

figure;plot(Eb,Z./1000,'r',NewEb,Z./1000,'b')

asr = Eb./NewEb;

figure;plot(asr,Z./1000)
