% SPECHUM2E   Converts specific humidity to water vapour pressure
%
%  Converts specific humidity (q) to water vapor pressure (e) according to
%  equation 3.57 and 3.59 on page 80 of Atmospheric Science An Introductory 
%  Survey. John M. Wallace & Peter V. hobbs 2nd Edition 
%
%  FORMAT [e] = spechum2e(q,P)
%
%  OUT	   e = vapor pressure of water [Pa]
%  IN      q = specific humidity [kg/kg].
%          P = total Pressure in [Pa]

% 2013-02-28 Created by Patrick Eriksson

function [e] = spechum2e(q,P)

rqre_element_math(q,P);

eps = 0.622;

e = (q.*P) ./ (eps+(1-eps)*q);


