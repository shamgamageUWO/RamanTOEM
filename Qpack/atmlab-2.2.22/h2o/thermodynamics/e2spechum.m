% E2SPECHUM   Converts the water vapor pressure to a specific humidity
%
%  Converts water vapor pressure (e) to specific humidity (q) according to 
%  equation 3.57 and 3.59 on page 80 of Atmospheric Science An Introductory 
%  Survey. John M. Wallace & Peter V. hobbs 2nd Edition 
%
%  FORMAT [q] = e2spechum(e,P)
%
%  OUT	   q = specific humidity [kg/kg].
%  IN      e = vapor pressure of water [Pa]
%          P = total Pressure in [Pa]

% 2010-08-18 Created by Marston Johnston

function [q] = e2spechum(e,P)

rqre_element_math(e,P);

eps = 0.622;

q = (eps * e) ./ (P-(1-eps) .* e);

