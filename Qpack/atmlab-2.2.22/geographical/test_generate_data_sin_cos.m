function [gridded,ungridded] = test_generate_data_sin_cos(sz)
%% test_generate_data_sin_cos
% GENERATES DATA gridded and ungridded in a sin cos pattern
%
% IN 
%         sz            the resolution of the data
%
%
%
% OUT 
%        gridded       structure containing gridded data (data,lat,lat)
%        ungridded     structure containing ungridded data (data,lat,lat)
%
%
%
%  USAGE 
%        [gridded,ungridded] = test_generate_data_sin_cos(sizeGrid)
%
%
%  Created by Salomon Eliasson

if ~exist('sz','var')
    sz = 1;
end

gridded.lat    = -90+sz/2:sz:90-sz/2;
gridded.lon    = -180+sz/2:sz:180-sz/2;
gridded.data   = zeros(length(gridded.lat),length(gridded.lon));
ungridded.data = zeros(length(gridded.lat)*length(gridded.lon),1);
ungridded.lon  = zeros(size(ungridded.data));
ungridded.lat  = zeros(size(ungridded.data));

ln = length(gridded.lon);
lt = length(gridded.lat);
ug=1;
for j=0:lt-1
    for i=0:ln-1

        gridded.data(j+1,i+1)=sin(((i+lt)/ln)*pi+pi/2)* cos((j/lt)*pi+pi/2)*100+160;
        
        if nargout==2
            ungridded.data(ug) = gridded.data(j+1,i+1);
            ungridded.lat(ug)  = j - 90;
            ungridded.lon(ug)  = i - 180;
            ug = ug+1;
        end
    end
end