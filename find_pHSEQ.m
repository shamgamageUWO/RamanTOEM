function [pHSEQ,commp0,pinde] = find_pHSEQ(z0,z,T,p,n0,grav,MoR)
%find_pHSEQ
% Find pressure under assumption of hydrostatic equilibrium (HSEQ)
%
% -Usage-
%	[pHSEQ,commp0,pinde] = find_pHSEQ(z0,z,T,p,n0,grav,MoR);
%
% -Inputs-
%	z0 - height to integrate up/down from
%	z - height
%	T - temperature
%	p - pressure profile, to find p0 value
%	n0 - if .NE. 0 then use this value of number density at z0 to find p0.
%	grav - gravity
%	MoR - mass ./ gas constant (z, T, p, grav and MoR are all on the same grid)
%
% -Outputs-
%	pHSEQ - pressure profile
%	commp0 - pressure at height z0
%	pinde - index of the height z0
%
% Last Modified: 09 July 2014


boltz = 1.3806488e-23;  % m^2*kg*s^-2 K^-1

% find index of p_0 value; if outside range pick 1st or last as appropriate
if z0 < z(1)
    pinde = 1;
elseif z0 > z(end)
    pinde = length(z);
else
    pind = find(z < z0);
    pinde = pind(end) + 1;
end

% allows p_0 value
if n0 == 0
    commp0 = p(pinde);
else
    commp0 = n0.*boltz.*T(pinde); %p(pinde); force p to be consistent with T/n
end

%integrate for p
dz = z(2)-z(1);
if pinde == 1
    pHSEQ = commp0.*exp(-dz.*cumtrapz(MoR.*grav./T));
elseif pinde == length(z)
    intgd = -dz.*cumtrapz(flip(MoR.*grav./T(1:pinde)));
    pHSEQ = commp0.*exp(flip(-intgd));
else
    intgu = -dz.*cumtrapz(MoR(pinde:end).*grav(pinde:end)./T(pinde:end));
    intgd = -dz.*cumtrapz(flip(MoR(1:pinde).*grav(1:pinde)./T(1:pinde)));
    ppch = zeros(size(z));
    ppch(1:pinde) = commp0.*exp(flip(-intgd));
    ppch(pinde+1:end) = commp0.*exp(intgu(2:end));
    pHSEQ = ppch;
end

return
