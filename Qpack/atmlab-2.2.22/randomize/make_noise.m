% MAKE_NOISE   Create noise vectors with desired covariance
%
% Usage:
% noise = make_noise(n,S)
%
% Input:
% n : How many vectors to generate
% S : Covariance matrix
%
% Output:
% noise : noise vectors, dimensions [dim(S),n]
%
% 2005-07-22 Stefan Buehler

function noise = make_noise(n,S)

% We use the Cholesky decomposition to generate random vectors with
% the right correlation. This trick is stolen from Patrick's
% randmvar_normal function in atmlab.
noise = chol(S)'*randn(length(S),n);

