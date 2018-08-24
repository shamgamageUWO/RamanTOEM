% CONSTANTS   Phyiscal and math constants
%
%    This function returns physical constants. It gives an 
%    error message, if the constant is not defined. If no constant is
%    given, the function's list of available constants are shown.
%
%    The following constants are defined:
%        
%       AVOGADRO                   [1/mol]
%       BOLTZMANN_CONST            [J/K]
%       CBGR                       [K] Temperature of cosmic background 
%                                      radiation 
%       DEG2RAD                    [rad] Conversion from degrees to radians
%       EARTH_MASS                 [kg] Mass of the earth.
%       EARTH_RADIUS               [m] Equatorial radius of the earth.
%       EARTH_RADIUS_MEAN          [m] Mean radius of the earth.
%       EARTH_STANDARD_GRAVITY     [m/s^2] As defined from CGPM in m/s^2
%       EARTHORBIT_RADIUS          [m] Radius of the Earth orbit, around the Sun
%       GAS_CONST                  [J.K-1.mol-1] Universal gas constant.
%       GAS_CONST_DRY_AIR          [J.kg-1e4.K-1] Gas constant for dry air
%     
%       GAS_CONST_WATER_VAPOR      [J.kg-1.K-1] Gas constant for water vapor
%       GRAVITATIONAL_CONSTANT     [m3.kg-1.s-3] The gravitational constant, G
%       LATENT_HEAT_VAPORIZATION   [J.kg-1] Latent heat of vaporization of
%                                           water vapor (at 373.15K)
%
%       LATENT_HEAT_VAPORIZATION_273 [J.kg-1] Latent heat of vaporization of
%                                           water vapor at 273K
%       NAUTICAL_MILE              [m] 1 nautical mile 
%       PLANCK_CONST               [Js]
%       RAD2DEG                    [deg] Conversion from radians to degrees
%       SPECIFIC_HEAT_CP_DRY_AIR   [J.kg-1.K-1] Specific heat at constant 
%                                               pressure, at sea level and 0C
%       SPECIFIC_HEAT_CV_DRY_AIR   [J.kg-1.K-1] Specific heat at constant 
%                                               pressure 
%       SPEED_OF_LIGHT             [m/s]
%       STEFANBOLTZMANN            [J.K-1.m-2.s-1] Total blackbody emission
%                                                  is STEFANBOLTZMANN*T^4
%       SUN_RADIUS                 [m] Sun radius
%        
% FORMAT   [const,unit] = constants(name)
%
% OUT   const   Value of the constant.
%       unit    String name of the associated unit.
%
% IN    name    Name of the constant (if empty, the list of constants 
%               are shown).
  

% 2002-12-12   Created by Claudia Emde and Patrick Eriksson.
% 2011-12-7    modified by Salomon Eliasson
% 2014-02-12   miodified by Carlos Jimenez
%               'GAS_CONST_DRY_AIR' from 287.040 to 287.058

% $Id: constants.m 8778 2014-02-12 13:27:55Z carlos $

% constants that changed values since 2011-12-7
%
%Boltzmann_const
%1.380662e-23 -> 1.3806488e-23
% Planck constant
% 6.626180e-34 -> 6.62606957e-34
% Avogadro constant
% 6.0225e23 -> 6.02214129e23
% CBGR
% 2.735 -> 2.725
% EARTH_RADIUS
% 6.378e6 -> 6.3781e6 (and write that this is the equatorial radius)
% EARTHORBIT_AXIS
% 1.495e11 -> 1.49598261e11 (aplies to the semi-maxis axis of the
%                            orbit (1.00000261AU) 
% SUN_RADIUS
% 6.960e8 -> 6.955e8
% DEG2RAD
% 0.01745329251994 -> pi/180
% RAD2DEG
% 57.2957795130823 -> 180/pi
% GAS_CONST_DRY_AIR
% 287-> 287.04
% SPECIFIC_HEAT_CONST_PRES
% 1005 -> 1003.5
% LATENT_HEAT_VAPORIZATION
% This is not a constant, but depends on the temperature

function [const,unit] = constants(name)

% You can add new constants here. The names should be self-explanatory
% and the constants are sorted alphabetically. You also have to add the 
% name of the constant in the help section above, so that the help command 
% gives out a complete list of constants. Aslo add their name to the
% subfunction below so they will be included in the output structure of all
% available constants (if nargin ==0). In the switch case, remember to also
% list along with the constant's value, its unit, and a reference.

if nargin ==0
    const = ifnargin0;
    return
end
   
switch name

case 'AVOGADRO'
    %ref: http://physics.nist.gov/cgi-bin/cuu/Value?na|search_for=avogadro
    const = 6.02214129e23;
    unit  = 'mol^{-1}';
    
case 'BOLTZMANN_CONST'
    %ref: http://en.wikipedia.org/wiki/Boltzmann_constant
    const = 1.3806488e-23;
    unit  = 'JK^{-1}';
    
case 'CBGR'
    %ref: http://en.wikipedia.org/w/index.php?title=Cosmic_background_radiation&oldid=480943337
    const = 2.725;
    unit = 'K';
    
case 'DEG2RAD'
    const = pi/180;
    unit = 'rad';
    
case 'EARTH_MASS'
    %ref: http://en.wikipedia.org/wiki/Earth_mass
    const = 5.97219e24;
    unit  = 'kg';
 
 case 'EARTH_RADIUS'
    %ref: http://en.wikipedia.org/wiki/Earth (equatorial radius)
    const = 6.3781e6;
    unit  = 'm';
    
case 'EARTH_RADIUS_MEAN'
    %ref: http://en.wikipedia.org/wiki/Earth (mean radius)
    const = 6.371e6;
    unit  = 'm';
    
case 'EARTH_STANDARD_GRAVITY'
    % ref: http://en.wikipedia.org/wiki/Standard_gravity
    const = 9.80665;
    unit  = 'ms^{-2}';
        
case 'EARTHORBIT_RADIUS'
    % ref: http://en.wikipedia.org/wiki/Earth (Semi-major axis)
    const = 1.49598261e11;
    unit  = 'm';
    
case 'GAS_CONST'
    %ref: http://en.wikipedia.org/wiki/Gas_constant
    const = 8.3144621;
    unit  = 'JK^{-1}mol{-1}';
    
case 'GAS_CONST_DRY_AIR'
    %ref: http://en.wikipedia.org/wiki/Gas_constant
    const = 287.058;
    unit  = 'Jkg^{-1}K^{-1}';
    
case 'GAS_CONST_WATER_VAPOR'
    % ref: http://en.wikipedia.org/wiki/Water_vapor
    const = 461.5; 
    unit  = 'Jkg^{-1}K^{-1}';
    
 case 'GRAVITATIONAL_CONSTANT'
    % ref: http://prl.aps.org/abstract/PRL/v111/i10/e101102
    % (This value is slightly higher than te ne given by eg. Wikipedia, but
    % is a new measurement (2013) that should be more accurate.)
    const = 6.67545e-11;
    unit  = 'm^3kg^{-1}s^{-2}';
 
 case 'LATENT_HEAT_VAPORIZATION'
    % ref: http://en.wikipedia.org/wiki/Enthalpy_of_vaporization
    error(['atmlab:' mfilename ':notConstant'],....
        ['The latent heat vaporization is a strong function of temperature.\n',...
        'Use ''LATENT_HEAT_VAPORIZATION_273'' for the correct value at 273.15 degress celcius'])
    const = 2257e3;
    unit  = 'Jkg^{-1}';
 
case 'LATENT_HEAT_VAPORIZATION_273'
    %http://en.wikipedia.org/w/index.php?title=Water_%28data_page%29&oldid=487536389
    const = 2496.5e3;
    unit  = 'Jkg^{-1}';
    
case 'NAUTICAL_MILE'
    % ref: http://en.wikipedia.org/wiki/Nautical_mile
    const = 1852;
    unit  = 'm';
    
case 'PLANCK_CONST'
    %ref: http://en.wikipedia.org/wiki/Planck_constant
    const = 6.62606957e-34;
    unit  = 'Js';
    
case 'RAD2DEG'
    const = 180/pi;
    unit = 'deg';

case 'SPECIFIC_HEAT_CP_DRY_AIR'
    %ref: 56
    const = 1003.5; 
    unit  = 'Jkg^{-1}K^{-1}';
    
case 'SPECIFIC_HEAT_CV_DRY_AIR'
    % ref: 
    const = 718;
    unit  = 'Jkg^{-1}K^{-1}';
    
case 'SPEED_OF_LIGHT'
    %ref: http://en.wikipedia.org/wiki/Speed_of_light
    const = 2.99792458e8;
    unit  = 'ms^{-1}';
    
case 'STEFANBOLTZMANN'
    const = 2*pi^5*constants('BOLTZMANN_CONST')^4 / ...
                (15*constants('PLANCK_CONST')^3*constants('SPEED_OF_LIGHT')^2);
    unit = 'JK^{-4}m^{-2}s^{-1}';

case 'SUN_RADIUS'
    % ref: http://en.wikipedia.org/wiki/Sun
    const = 6.955e8;
    unit  = 'm';

otherwise
    error(['atmlab:' mfilename ':badInput'],['Unknown constant: ', name])
end      

% make sure there's something for unit
if ~exist('unit','var'), unit = ''; end




function const_struct = get_constants_struct
% A structure with the same information as the switch case (+units)

name  = { ...
    'AVOGADRO', 'BOLTZMANN_CONST', 'CBGR', 'DEG2RAD', ...
    'EARTH_MASS', 'EARTH_RADIUS', 'EARTH_RADIUS_MEAN', ...
    'EARTH_STANDARD_GRAVITY', 'EARTHORBIT_RADIUS',...
    'GAS_CONST', 'GAS_CONST_DRY_AIR', 'GAS_CONST_WATER_VAPOR', ...
    'GRAVITATIONAL_CONSTANT', ...
    'LATENT_HEAT_VAPORIZATION_273', 'NAUTICAL_MILE', 'PLANCK_CONST', 'RAD2DEG',...
    'SPECIFIC_HEAT_CP_DRY_AIR', 'SPECIFIC_HEAT_CV_DRY_AIR', ...
    'SPEED_OF_LIGHT', 'STEFANBOLTZMANN', 'SUN_RADIUS' ...
};

value = cell(1,length(name));
unit  = cell(1,length(name));

for i = 1:length(name)
    [value{i},unit{i}] = constants(name{i});
end

const_struct = struct('name',name,'value',value,'unit',unit);




function const_struct = ifnargin0
% if you only want to see what constants there are

const_struct = get_constants_struct;
fprintf('The constants listed in this function are:\n\n')
for i = 1:length(const_struct),
    fprintf('%s = %d [%s]\n',...
        const_struct(i).name,const_struct(i).value,const_struct(i).unit);
end
fprintf('\nUSAGE: e.g. 6378000 = constants(''EARTH_RADIUS'') or\n')
fprintf('USAGE: e.g. [6378000,''m''] = constants(''EARTH_RADIUS'')\n')
