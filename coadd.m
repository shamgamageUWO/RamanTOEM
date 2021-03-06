function [qc, zc] = coadd(q, z, layer)
%
% function [qc, zc] = coadd(q, z, layer)
%
% Purpose       : To co-add vectors of quatities and heights
% Precondition  : q is a vector of some quantity over height
%                 z is the vector of heights over witch q is taken
%                 layer is the thinkness of each layer to bin to
% Postcondition : if qc is a vector of the average of q in each bin
%                 zc is a vector of the average of z in each bin

% confirm that q and z are the same length
if (length(z) ~= length(q) )
   error('COADD -- Vectors must be the same length');
end %if

% Trucate q and z to multiples of the layer width
l = floor(length(q) / layer) * layer;
q = q(1:l);
z = z(1:l);

% Reshape q and z so that the bins from each layer are in the
% same column
qc = reshape(q, layer, l/layer);
zc = reshape(z, layer, l/layer);

% find the mean of each layer
qc = (nansum(qc))';
zc = (mean(zc))';