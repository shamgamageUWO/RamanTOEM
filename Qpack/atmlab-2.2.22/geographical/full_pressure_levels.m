function P = full_pressure_levels(sp,A,B)
%% FULL_PRESSURE_LEVELS Calculate Pressure matrix based on surface pressure
%
% Calculate Pressure matrix based on surface pressure and number of model
% levels. 
%
% Note: Assumes the bottom of the atmosphere is at level 60/91
%       A and B coincide to half pressure levels, and the output is in full pressure levels
%
% IN
%     sp     [%f,...]              surface pressure matrix (2D)
%     A,B    %f                    A-B coefficients values vecs on the
%                                  pressure interval levels.
%                                  i.e. length(A) = nlvls-1 
%
% OUT
%     out = p(lvls,:,:)            Pressure values on model levels
%
% USAGE: P = full_pressure_levels(sp,A,B)
%
% $Id: full_pressure_levels.m 7095 2011-08-03 06:32:00Z seliasson $
% Created Marston Johnston

sp = squeeze(sp);
assert(ndims(sp)==2,'atmlab:full_pressure_levels:BadInput','sp must be 2D')
nlev = length(A)-1;
ph = zeros([size(sp),nlev+1]);
P = zeros([nlev,size(sp)]);

for lev = nlev:-1:1 % begin from bottom
    ph(:,:,lev+1) = A(lev+1) + B(lev+1)*sp(:,:);
    ph(:,:,lev) = A(lev) + B(lev)*sp(:,:);
    P(lev,:,:) = (ph(:,:,lev) + ph(:,:,lev+1))*0.5; % Full pressure level
end
