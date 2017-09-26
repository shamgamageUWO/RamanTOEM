z0= 30000;
n0=0;
kb = 1.38064852*10^-23;
Rsp = 287;
Rgas = 8.3145;
NA = 6.02214129 *(10^23) ;% Avergadro Number mol?1
M = 28.9645 * (10^-3); 


[Tsonde,Zsonde,Psonde] = get_sonde_RS92(20110909, 23);
Psonde = Psonde(1:2086);
Tsonde = Tsonde(1:2086);
Zsonde = Zsonde(1:2086);
obj = Gravity(Zsonde, 46.82); % run gravity model
grav = obj.accel;
MoR = (M./Rgas).*ones(size((Tsonde)));
[pHSEQ,commp0,pinde] = find_pHSEQ(z0,Zsonde,Tsonde,Psonde,n0,grav',MoR);
figure;plot(pHSEQ,Zsonde./1000,'r',Psonde,Zsonde./1000,'b')


z01 = 40000;
[Tmsis, pmsis,zmsis]= msisRALMO;
obj2 = Gravity(zmsis, 46.82);
grav2 = obj2.accel;
MoR2 = (M./Rgas).*ones(size(Tmsis));
[pHSEQ2,commp02,pinde2] = find_pHSEQ(z01,zmsis,Tmsis,pmsis,n0,grav2',MoR2);
figure;plot(pHSEQ2,zmsis./1000,'r',pmsis,zmsis./1000,'b')
