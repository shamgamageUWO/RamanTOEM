% 
% clear all;
% 
Zj = 500:250:40000;
deltaZ = 2000;
ind = Zj<=15000;
ind2 = Zj>15000 & Zj<17000;
ind3 = Zj>=17000;

l=length(Zj(ind));
l2=length(Zj(ind2));
l3 = length(Zj(ind3));
% 
% L = Zj(ind);
% L2 = Zj(ind2);
% L3 = Zj(ind3);
OVstdl = 1;
OVstd2 = 0.001;

h1 = OVstdl.* ones(1,l);
h3 = OVstd2.* ones(1,l3);


figure;
% H = plot( [Zj(ind) Zj(ind3)],[h1 h3],'r');
% hold on;

a = (OVstdl + OVstd2 )/deltaZ;

pl(1) = a* 250;

for i = 1:6
pl(i+1)= pl(1)*(i+1);

end
ppl=fliplr(pl);
OV_dia  =[h1 ppl h3];

% LL = 1:deltaZ;
% pl = a.*LL;

plot(Zj,OV_dia,'b')
% hold off
