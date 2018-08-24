%
% calculate the specific humidity [g/kg]
%
% s=rh2spez(T,rh,p);
%
% T: Temperature [K]
% rh: relative humidity [%]
% p: pressure [hPa]
%
%
function s=rh2spez(T,rh,p)

% scaled temperature
t=300./T;

% ratio of the molecular weight of dry air and water
eps=0.622;

% saturation vapour pressure
es=2.408e11.*t.^5.*exp(-22.644*t);

% vapour pressure
e=rh.*es/100;

% specific humidity
s=e.*eps./(p-(1-eps).*e)*1000;