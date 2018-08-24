function [cross, along, eccentricity] = calculate_footprint_size_amsu(type, n)

% calculate_footprint_size_amsu Calculate approximate footprint edge
%
% Calculates the semi-major axis, the semi-minor axis and the eccentricity of
% an ellipse approximating the edge of the AMSU footprint, according to the
% method found in bennartz00:_optim_convol_amsu_b_amsu_jaot, depending on the
% scan position.
%
% FORMAT
%
%   [cross, along, eccentricity] = calculate_footprint_size_amsu(type, n)
%
% IN
%
%   type    string  'amsua' or 'amsub'
%   n       scalar  channel number
%
% OUT
%
%   cross   scalar  cross-track size (km)
%   along   scalar  along-track size (km)
%   ecc     scalar  eccentricity for ellipse
%
% $Id: calculate_footprint_size_amsu.m 6679 2010-12-10 19:56:54Z gerrit $
        
switch type
    case {'b', 'amsub'}
        if n > 45
            n = 91 - n;
        end
        cross = .5 * (79.08 + 2.84 * n - 14.78 * n^0.666);
        along = .5 * (28.72 - 0.90 * n + 0.094 * n^1.5);

    case {'a', 'amsua'}
        if n > 15
            n = 31 - n;
        end

        cross = .5 * (230.65 + 12.39 * n - 95.06 * n^0.5);
        along = .5 * (83.01 - 7.28 * n + 1.28 * n^1.5);
    otherwise
        error('atmlab:calculate_footprint_size_amsu', ...
            'Invalid sensor: %s', type)
end

a = max(cross, along);
b = min(cross, along);

eccentricity = sqrt(a.^2 - b.^2) / a;
