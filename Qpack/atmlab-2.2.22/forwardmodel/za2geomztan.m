%------------------------------------------------------------------------
% NAME:    za2geomztan
%
%          Converts a vector of zenith angles to geometrical tangent altitudes.
%
% FORMAT:  z_tan = za2geomztan(r_geoid,z_plat,za)
%
% RETURN:  z_tan     tangent altitudes corresponding to za.
% IN:      r_geoid   Geoid radius.
%          z_plat    Platform altitude (above geoid).
%          za        zenith angles. 
%------------------------------------------------------------------------

% HISTORY: 2004-09-11   Adapted from AMI function za2geomztan

function z_tan =  za2geomztan(r_geoid,z_plat,za);


z_tan = (r_geoid+z_plat)*sin(constants('DEG2RAD')*za) - r_geoid;


