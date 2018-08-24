function [combifilter,tooCold,diffFilter]=amsub_cloudfilter(tb18, tdiff, viewangle)
%% AMSUB_CLOUDFILTER gets a cloud/surface filter for passive microwave
%
% PUPOSE
%           Performs a cloud filter according to a given angle dependent
%           threshold for Tb18 and the difference between channels 19/20
%           and 18
%
% IN
%       tb18            vect        Channel 18 brightness temperature
%       tdiff           vect        Difference vector:
%                                   ch20 - ch18, or ch19 - ch18
%       viewangle       vect        satellite viewangle. (0=nadir)
%
% OUT
%       combifilter     vect        filter, true where the data (not too
%                                   cold & not cloud filtered) are OK
%
%       tooCold         vect        filter, true where the tb18 is warmer
%                                   than the angular dependent cutoff temp 
%
%       diffFilter     vect        filter, true where tdiff > 0 (angular
%                                    dependent) 
%
% $Id: amsub_cloudfilter.m 7909 2012-10-09 06:44:36Z seliasson $
% Mathias Milz and Salomon Eliasson

% angles are in buehler et. al 2005
ang=[0.5500 1.6500 2.7500 3.8500 4.9500 6.0500 7.1500 8.2500 9.3500 ...
    10.4500 11.5500 12.6500 13.7500 14.8500 15.9500 17.0500 18.1500 ...
    19.2500 20.3500 21.4500 22.5500 23.6500 24.7500 25.8500 26.9500 ...
    28.0500 29.1500 30.2500 31.3500 32.4500 33.5500 34.6500 35.7500 ...
    36.8500 37.9500 39.0500 40.1500 41.2500 42.3500 43.4500 44.5500 ...
    45.6500 46.7500 47.8500 48.9500];

% These thresholds are to protect against the measurement being
% contaminated by the surface or clouds simply being too thick
thresh_tb = [ 240.1 240.1 240.1 240.1 240.1 240.1 240.1 239.9 239.9 ...
    239.8 239.8 239.7 239.7 239.6 239.6 239.5 239.4 239.3 ...
    239.2 239.2 239.1 239.0 238.8 238.7 238.6 238.5 238.3 ...
    238.2 238.0 237.8 237.6 237.4 237.2 237.0 236.7 236.6 ...
    236.4 236.1 235.8 235.5 235.2 234.9 234.4 233.9 233.3 ];

TB = zeros(size(viewangle),'single');

% LOOP over the viewing angles
for k = 1:length(viewangle)
    % Find the CLOSET ANGLE in the lookup table to the angles given as input.
    % Pick closest_angle(1) since sometimes there are two answers
    closest_angle=find(abs(ang-viewangle(k))<= min(abs(ang-viewangle(k))));
    TB(k) = thresh_tb(closest_angle(1));
end

tooCold = tb18 > TB;
diffFilter = tdiff > 0;

combifilter = tooCold & diffFilter; %i.e. surface & cloud

end