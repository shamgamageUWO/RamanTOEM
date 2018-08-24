function uth=amsub_tb2uth(tb18,viewangle,icewater)
% AMSUB_TB2UTH calculates UTH from AMSU-B channel 18 Tb
%
% PURPOSE   The function  is based on the scaling method presented by
%           Buehler and John (2005) using the relation:
%           ln(UTH)= a +b*Tb
%           where Tb is the brightness temperature at 183 +/- 1GHz
%
%  IN
%         tb18                      brightnesstemperature for channel 18        
%         viewangle                 viewing angle (of nadir) under which the
%                                   instruments measures (0 = nadir)
%         icewater (optional flag)  Set 'w' for UTH with respece to water,
%                                   'i' for UTH with respect to ice. If
%                                   nothing is given, provide UTH with
%                                   respect to water.
%
%  OUT    uth                       calculated by the scaling method
%                                   presented by Buehler and John (2005):
%
%
% USAGE
%         uth=amsub_tb2uth(tb18,viewangle,icewater)

% $Id: amsub_tb2uth.m 7584 2012-05-09 14:37:10Z seliasson $
% Author: Mathias Milz and Salomon Eliasson

errId = ['atmlab:' mfilename 'badInput'];
assert(nargin>=2,errId,'At least 2 argumnents required!')
assert(isequal(size(tb18),size(viewangle)),errId,...
    '''tb18'' and ''viewangle'' must be the same size!')
if nargin < 3
    icewater='w';
end


% From Table 1 in Buehler et. al 2005

% WATER
aw=[16.474 16.472 16.476 16.479 16.479 16.483 16.488 16.490 16.496 ...
    16.501 16.503 16.514 16.527 16.540 16.552 16.561 16.572 16.585 ...
    16.599 16.612 16.628 16.649 16.665 16.681 16.709 16.740 16.766 ...
    16.789 16.806 16.842 16.874 16.907 16.932 16.972 17.003 17.036 ...
    17.063 17.105 17.156 17.201 17.252 17.308 17.375 17.439 17.501];

bw=[-0.0702169 -0.0702106 -0.0702271 -0.0702456 -0.0702506 -0.0702774 ...
    -0.0703084 -0.0703243 -0.0703634 -0.0703988 -0.0704219 -0.0704853 ...
    -0.0705569 -0.0706315 -0.0707031 -0.0707656 -0.0708374 -0.0709191 ...
    -0.0710062 -0.0710919 -0.0711956 -0.0713153 -0.0714210 -0.0715289 ...
    -0.0716877 -0.0718609 -0.0720197 -0.0721669 -0.0722922 -0.0724969 ...
    -0.0726909 -0.0728922 -0.0730668 -0.0733017 -0.0735100 -0.0737274 ...
    -0.0739261 -0.0741909 -0.0745019 -0.0747932 -0.0751160 -0.0754690 ...
    -0.0758780 -0.0762869  -0.0766990];

% ICE
ai=[18.341 18.339 18.342 18.345 18.344 18.348 18.353 18.354 18.359 ...
    18.363 18.362 18.371 18.381 18.391 18.401 18.407 18.416 18.426 ...
    18.436 18.448 18.462 18.478 18.490 18.503 18.525 18.552 18.575 ...
    18.592 18.605 18.637 18.664 18.695 18.715 18.750 18.778 18.805 ...
    18.823 18.859 18.901 18.940 18.983 19.031 19.088 19.142 19.195];

bi=[-0.0764737 -0.0764688 -0.0764834 -0.0764992 -0.0765034 -0.0765274 ...
    -0.0765550 -0.0765713 -0.0766039 -0.0766340 -0.0766454 -0.0766984 ...
    -0.0767557 -0.0768198 -0.0768812 -0.0769315 -0.0769950 -0.0770628 ...
    -0.0771351 -0.0772143 -0.0773052 -0.0774066 -0.0774960 -0.0775902 ...
    -0.0777226 -0.0778808 -0.0780199 -0.0781414 -0.0782481 -0.0784375 ...
    -0.0786102 -0.0787986 -0.0789501 -0.0791631 -0.0793542 -0.0795464 ...
    -0.0797062 -0.0799444 -0.0802151 -0.0804762 -0.0807632 -0.0810812 ...
    -0.0814447 -0.0818039 -0.0821763];

% corresponding angles
ang=[0.5500 1.6500 2.7500 3.8500 4.9500 6.0500 7.1500 8.2500 9.3500 ...
    10.4500 11.5500 12.6500 13.7500 14.8500 15.9500 17.0500 18.1500 ...
    19.2500 20.3500 21.4500 22.5500 23.6500 24.7500 25.8500 26.9500 ...
    28.0500 29.1500 30.2500 31.3500 32.4500 33.5500 34.6500 35.7500 ...
    36.8500 37.9500 39.0500 40.1500 41.2500 42.3500 43.4500 44.5500 ...
    45.6500 46.7500 47.8500 48.9500];


uth = zeros(size(tb18));
% LOOP over the viewing angles
for k = 1:length(viewangle)
    % Find the CLOSET ANGLE in the lookup table to the angles given as input.
    % Pick closest_angle(1) since sometimes there are two answers. 1e-3 for
    % precision error
    closest_angle=find(abs(ang-viewangle(k)) - min(abs(ang-viewangle(k))) < 1e-3);
    if strcmp(icewater,'i')
        uth(k)  =  100.0 * exp( ai(closest_angle(1)) + bi(closest_angle(1)) * tb18(k) );
    end
    if strcmp(icewater,'w')
        uth(k)  =  100.0 * exp(aw(closest_angle(1)) + bw(closest_angle(1)) * tb18(k) );
    end
end

end