function weights = area_weighting(varargin)
% AREA_WEIGHTING returns a matrix of weights for geodata based on latitude
%
% In   
%       lat:       [%f ...]            latitude  vector
%       lon:       [%f ...]            longitude  vector
% 
% OPT:  vec        logical             true if the weighting matrix should
%                                      be a vector (same size as latitude)
%                                  
%
% Out: A matrix of area wieghts the same size as se.datafield;
%      where each element is cosd(latitude)
%
% USAGE: weights = area_weighting('lat',[%f,...],'lon',[...]) %for 2D output
%        or
%        weights = area_weighting('lat',[%f,...],'vec',true) %for 1D output
% Created by Salomon Eliasson
% $Id$ 

errID = 'atmlab:area_weighting:badInput';
for arg = 1:2:length(varargin)
    S.(varargin{arg}) = varargin{arg+1};
end
assert(isfield(S,'lat'),errID,'input ''lat'' is missing')
assert(isfield(S,'lon') || isfield(S,'vec'),errID,....
    'input ''lon'' is required to make weighting matrix if logical ''vec'' is not set')

if isfield(S,'vec') && S.vec
    weights = cosd(S.lat);
else
    S.lat = sort(S.lat,'descend');
    [y,latmatrix] = meshgrid(S.lon,S.lat);
    weights = cosd(latmatrix);
end