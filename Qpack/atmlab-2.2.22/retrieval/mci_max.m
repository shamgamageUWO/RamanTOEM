% MCI_MAX   Max probability retrieval by Monte Carlo integration (MCI)
%
%   This is a version of MCI retrieval. Standard retrievals are handled by
%   *mci*. In this version, the retrieval is simply the database case having
%   the highest a posterior probability. Or the highest weight in the
%   nomenclature of *mci*.
%
%   To keep thing simple, only index of the max probable case and its "weight"
%   are returned. Again in the nomneclature if *mci*, the actual solution is
%   Xb(:,imax).
%
% FORMAT   [imax,wmax] = mci_max(Yb,Se,Y)
%        
% OUT   imax   Index of Yb-columns giving best match with each *Y*
%       wmax   The weight corresponding to *imax*.
% IN    Yb     Measurements of the retrieval database
%       Se     Observation unvertainty covariance matrix.
%       Y      Measurements to be inverted.

% 2014-09-04   Created by Patrick Eriksson, based on the existing mci.m

function [imax,wmax] = mci_max(Yb,Se,Y)

% Some sizes
nb = size(Yb,2);
m  = size(Y,1);
ny = size(Y,2);

% Check that dimensions of Yb and Y are consistent:
if size(Y,1) ~= m
    error('Dimensions of Yb and Y do not match')
end

% Check that dimensions of Y and Se are consistent:
if size(Se,1) ~= m  |  size(Se,2) ~= m
    error('Dimensions of Se and Y do not match')
end

% Init output arguments
%
[imax,wmax] = deal( zeros( ny, 1 ) );


for i = 1 : ny

  w = exp( -0.5*chi2( repmat(Y(:,i),1,nb)-Yb, Se ) );

  % Find max weight, and if happen to be duplicates take first value
  [wm,im] = max( w );
  wmax(i) = wm(1);
  imax(i) = im(1);
  
end

