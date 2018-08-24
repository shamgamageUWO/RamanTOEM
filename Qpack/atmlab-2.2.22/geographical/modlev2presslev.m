function [data] = modlev2presslev(iarray,P,pgrid,nlev)
% MODELEV2PRESSLEV converts model levels to pressure levels using linear interpolation
%
% IN
%     iarrray  [%f,...]            input matrix 2D or greater
%     P        [%f,...]            pressure values on model level. Must be same
%                                  size as iarray. [Pa]
%     pgrid                        vector containing new presure vertical
%                                  coordintates. Should be within the model's 
%                                  own domain [Pa]
%     nlev     %f                  Number of model vertical levels
%
% OUT
%     out = data                   Interpolated data to the new pressure grid
%
% NOTE
%     * MUST have the input dimensions data(lev,....) 
%
% USAGE: out = modlev2presslev(data(lev,...),P(lev,...),pgrid)
%
% $Id: modlev2presslev.m 7194 2011-11-07 12:38:15Z seliasson $ 
% Created Marston Johnston


assert(nargin == 4,['atmlab:' mfilename ':badInput'],...
    'incorrect number of arguments')
assert(isequal(size(iarray),size(P)),['atmlab:' mfilename ':badInput'],...
    '''iarray'' and ''P'' must be the same size')
assert(isvector(pgrid),['atmlab:' mfilename ':badInput'],...
    'pgrid must be a vector')
assert(all(pgrid >= min(P(:)))&&all(pgrid <= max(P(:))),...
    ['atmlab:' mfilename ':badInput'],...
    'pgrid is out side the domain if the pressure matrix')
assert(isequal(size(iarray,1),nlev),...
    ['atmlab:' mfilename ':dimError'],...
    'Dimension 1 must equal to number of levels');

% Get the size of the input array
sz = size(iarray);
% Change the pressure level dimension to the new grid. 
sz(1) = length(pgrid);
% compress the array to 2D
iarray = iarray(:,:); 
P = P(:,:);
pAr = NaN(sz);
pAr = pAr(:,:);
for a = 1:size(iarray,2)
    ivalues = iarray(:,a);
    igrid   = P(:,a);
    ovalues = interp1(log10(igrid),ivalues,log10(pgrid));
    pAr(:,a) = ovalues;
end
data = reshape(pAr,sz);