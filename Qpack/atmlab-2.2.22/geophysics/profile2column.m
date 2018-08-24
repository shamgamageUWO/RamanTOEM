% PROFILE2COLUMN Calculates column values for profiles
% 
%   Returns the cumulative columns or the columns at a single threshold 
%   altitude z0. Integration is done by the trapezoidal rule.
%   
%   The concentrations are given as a nxm matrix where n is
%   number of altitude levels(first element has the lowest altitude) 
%   and m number of measurements. The altitudes
%   can either be given as a single column vector(nx1) or a nxm matrix.
%   If the altitudes are given as a vector z0 is scalar, if they are 
%   given as a matrix z0 must be a vetor of length m.
%
%   The function is made with ground based mesurements in mind, if your data
%   has more than two dimensions see example:
%
%   example: X is 4 dimensional matrix containing concentration at points
%   in a lat,lon,p,t grid. Z is a 4 dimensional matrix containing altitude
%   at point lat,lon,p,t. Note that altitudelevels are the second last
%   dimension of the X and Z matrix.
%
%   for n = number of latitudes
%       for m = number of longitudes
%           CC(n,m,:) = profile2column(Z(n,m,:,:),X(n,m,:,:))
%       end
%   end
%
%   
%   
% FORMAT   [CC]	= PROFILE2COLUMN(Z,X)
%		or
%          [CC] = PROFILE2COLUMN(Z,X[,z0])
%     
% OUT   CC   	The cululative column of concentration [m^-2] or the 
%               column value at threshold altitude z0.
% IN    Z       The altitude vector [m] or altitude matrix Z(1) is the lowest
%               altitude.
%       X       Concentration matrix [m^-3].
% OPT   z0	    Threshold altitude[m] or threshold altitude vector.
%

% 2010-09-24   Created by Ole Martin Christensen.

function [CC] = profile2column( Z,X,varargin )
%
Z = squeeze(Z);							
X = squeeze(X);
rqre_datatype( Z, @istensor2 );                                          %&%
rqre_datatype( X, @istensor2 );                                          %&%
z0 = optargs(varargin,{[]});                                             %&%

if size(Z,2) == 1;
    CC = cumtrapz(Z,X);
else
    CC = zeros(size(X));
    for n = 1:size(Z,2)
        CC(:,n) = cumtrapz(Z(:,n),X(:,n));
    end
end

%Subtract away the column beneath the threshold value
if ~isempty(z0)
    if size(Z,2) == 1
        c = CC(end,:) - interp1(Z,CC,z0);
    else
        c = zeros(size(X,2),1);
        for n = 1:size(Z,2)
            c(n) = CC(end,n) - interp1(Z(:,n),CC(:,n),z0(n));
        end
    end
    CC = c;      
end




