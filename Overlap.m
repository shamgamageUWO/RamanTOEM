%Overlap function for RALMO approximated 
% Reference: Analytical function for lidar geomentrical compression
% form-factor calculations

% I am using the 3rd equation given in the set of equation18 

% constants needed are listed below with the reference
% Operational Raman lidar for water vapor, aerosol, and temperature vertical profiling
% T = 300mm - Telescope diameter
% g0 = 140mm - Beam diameter
% delta = 100* 10^-3 mrad - Beam divergence
% phi = 0.2 mrad - telescope FOV
% d0 = 200mm ; assume distance between telescope and the beam
% Theta = 15* 10^-6; assume 15microrad


function [epsi,z] = Overlap(Zi,g0)
dz = Zi(2)-Zi(1);
z = Zi(1):dz:10000;

T = 300*10^-3;%m
% g0 = 9*10^-3;%m
delta = 100*10^-6;%rad
phi = 0.2*10^-3;% rad
f = 1;%m
s = phi*f;
d0 = 200*10^-3; 
Theta = 15* 10^-6;


Z = (g0+T)./z;
eR = (delta+Z).*f;
VR = f.*(d0-Theta.*z)./z;
O = (s^2) ./ ((delta+ Z).^2);

SiR1 = 2*acos((s^2 + 4.*VR.^2-eR.^2)./(4*VR*s));

SiR2 = 2*acos((eR.^2 + 4.*VR.^2-s^2)./(4.*VR.*eR));


epsi = real((SiR1 - sin(SiR1))*s^2 + (SiR2 - sin(SiR2)).*eR.^2)./(2*pi*eR.^2);

% figure;
% plot(real(epsi),z)
% %  plot(z,SiR1,'r',z,SiR2,'b')
% %  plot(z,O,'r',z,eR,'b',z,VR,'g')
% xlabel('Overlap Function') % x-axis label
% ylabel('altitude(m)') % y-axis label
% title('Overlap Function'); % Create title


