function Td = dew_point_temperature(ew)
% DEW_POINT_TEMPERATURE  Dewpoint temperature Td
%       
%       dewpoint or dewpoint temperature is the temperature to
%       which a given air parcel must be cooled at constant
%       pressure and constant water vapor content in order
%       for saturation to occur.
%       (http://amsglossary.allenpress.com/glossary/search?id=dewpoint1)
%       As such if e is the partial vapor pressure at T , the dew point
%       must satisfy the equation ews(T) = ew 
%
% FORMAT    Td = dew_point_temperature(ew)
%       
% ACCURACY  This function is as accurate as the function <e2T_eq_water>
%           The function is based on the inverse of the Sonntag method
%           which estimate saturated vapor pressure using temperature.
%           For more details see the function <e2T_eq_water>
%
% OUT   Td  dewpoint temperature [K],
% IN    ew  equilibrium water vapor pressure [Pa], a scalar or a vector
%
% EXAMPLE:
%       Td = dew_point_temperature(1500)
%       Td = 286.1712
%
% 2009-08-15   Created by Isaac Moradi.

Td = e2T_eq_water(ew);