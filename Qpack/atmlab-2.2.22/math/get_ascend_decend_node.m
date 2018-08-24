function ascend = get_ascend_decend_node(latitude)
%% get_ascend_decend_node Gets ascending/dedcending node
% Purpose: Create a logical array, the same size as latitude -matrix that
% indicates whether a pixel is in the ascending mode containing whether a pixel
% is ascending or not. 
%
% FORMAT:  ascend = get_ascend_decend_node(latitude)
%
% IN: Latitude (ungridded (size = [scanline,scanposition]))
%
% OUT: ascend (logical). true for ascend, false for descend.
% 
% Note: 1) Latitude must have the dimensions size = [scanline,scanposition]
%       2) This is for ungridded data. I.e. the latitude-matrix is a matrix (or
%          vector) read straight from a satellite data file (therfore ungridded)
%       3) If there is only one latitude scanline or if it's empty, ascend = NaN
%       4) The node is based on the centre scanposition, i.e for amsub column
%          45, for CloudSat column 1. That means that the entire scanline will
%          always have the same node
%
% 2010-10-13 created by Salomon Eliasson

lat=latitude(:,round(end/2)); %always a vector
ascend=false(size(latitude));

if size(latitude,1)<=1
    ascend = NaN;
    return
end

% this line checks if the next latitude is higher or not (using indexing).
% the second last and last scanlines are set to be equally ascending or
% descending to their neighbouring point
i = 1:length(lat)-1;
ascend(i,:)=repmat(lat(i+1) > lat(i),1,size(ascend,2));
ascend(end,:) = ascend(end-1,:);
