%+ P_MERGE: Merges two vertical profiles weighted by the uncertainties of the
%  individual profiles
%
%  Program interpolates the two profiles and uncertainties unto a common
%  grid and merges them using the formula for weigthed mean:
%  profile = (np1./(np1u.*np1u) + np2./(np2u.*np2u)) ./ ...
%            (1./(np1u.*np1u) + 1./(np2u.*np2u));
%
%  The uncertainties are also merged: 1/(u)^2 = 1/(u1)^2 + 1/(u2)^2
%
%  OUT	   new vertical profile and the error/uncertainties per level
%  IN      p1 = profile 1, p2 = profile 2, g1 = old grid of profile 1, g2 =
%  old grid of profile 2, ngrid = new common grid, p1u = uncertainties of
%  profile 1, uncertainties of profile 2.
%
%  Requirements: max(g2) must equal max(ngrid).
%                min(g1) must equal min(ngrid).
%                All grids must monotonic decreasing with max value in
%                index 1.
%                The grids to be merged must overlap!
%                The uncertainties must be in absolute terms!
%
%  Options: verbose: set to true or false if you want to see the data
%                    inside the function
%           debug:   set to true or false if you want to stop inside the
%                    function using "keyboard"
%+

% 2010-10-22 Created by Marston Johnston

function [vprofile,si] = p_merge(p1,p2,g1,g2,ngrid,p1u,p2u,verbose,debug)

if verbose || debug
    disp('Input data...');
    for p = 1:numel(p1), fprintf('g1(%d) = %f -> %f -> %f\n',p,g1(p),p1(p),p1u(p)); end
    for p = 1:numel(p2), fprintf('p2(%d) = %f %f -> %f\n',p,g2(p),p2(p),p2u(p)); end
end
vprofile = NaN(size(ngrid));
si       = NaN(size(ngrid));

% Find the degree of overlapp between the vectors. The grids must be
% monotonic decreasing

if all(diff(g1)<0) == true
    if verbose || debug, disp('Grid 1 is good'); end
else
    error('Grid 1 must be monotonic decreasing');
end

if all(diff(g2)<0) == true
    if verbose || debug, disp('Grid 2 is good'); end
else
    error('Grid 2 must be monotonic decreasing');
end

if all(diff(ngrid)<0) == true
    if verbose || debug, disp('ngrid is good'); end
else
    error('Ngrid must be monotonic decreasing');
end

% Find where each layer is in relation to the other
if max(round(g2)) == max(round(ngrid))
    layer1 = vec2col(g2);
    values1 = vec2col(p2);
    uncertainty1 = vec2col(p2u);
    layer2 = vec2col(g1);
    values2 = vec2col(g1);
    uncertainty2 = vec2col(p1u);
elseif max(round(g1)) == max(round(ngrid))
    layer1 = vec2col(g1);
    values1 = vec2col(p1);
    uncertainty1 = vec2col(p1u);
    layer2 = vec2col(g2);
    values2 = vec2col(p2);
    uncertainty2 = vec2col(p2u);
end
% Find the overlapping areas
if min(layer1) < max(layer2)
    if verbose, disp('There is an overlap!'); end
    i = min(layer1) <= ngrid & max(layer2) >= ngrid;
    iu1 = layer1 > max(layer2);
    iu2 = layer2 < min(layer1);
    % Find must be used here to get the indices
    ic1 = find(layer1 <= max(ngrid(i)));
    ic2 = find(layer2 >= min(ngrid(i)));
    % Add to the end points to ensure full data coverage. Making sure it
    % does not go past the end points!
    if ic1(1) > 1 && ic1(end) < numel(layer1)
        ic1 = [ic1(1)-1; ic1; ic1(end)+1];
    elseif ic1(1) == 1 && ic1(end) < numel(layer1)
        ic1 = [ic1; ic1(end)+1];
    elseif ic1(1) > 1 && ic1(end) == numel(layer1)
        ic1 = [ic1(1)-1; ic1];
    end
    if ic2(1) > 1 && ic2(end) < numel(layer2)
        ic2 = [ic2(1)-1; ic2; ic2(end)+1];
    elseif ic2(1) == 1 && ic2(end) < numel(layer2)
        ic2 = [ic2; ic2(end)+1];
    elseif ic2(1) > 1 && ic2(end) == numel(layer2)
        ic2 = [ic2(1)-1; ic2];
    end
else
    error('Warning: There are no overlapping areas!');
end
% Copy the unique parts
v1 = ismember(ngrid,layer1(iu1));
v2 = ismember(ngrid,layer2(iu2));
vprofile(v1) = values1(iu1);
vprofile(v2) = values2(iu2);
si(v1) = uncertainty1(iu1);
si(v2) = uncertainty2(iu2);
if verbose || debug
    disp('After copying the unique parts...');
    for p = 1:numel(values1), fprintf('layer1(%d) = %f %f\n',p,layer1(p),values1(p)); end
    for p = 1:numel(values2), fprintf('layer2(%d) = %f %f\n',p,layer2(p),values2(p)); end
    for p = 1:numel(vprofile), fprintf('vprofile(%d) = %f\n',p,vprofile(p)); end
    for p = 1:numel(si), fprintf('si(%d) = %f\n',p,si(p)); end
end
% Interpolate the common overlapp
if sum(i) > 0
    values_common1      = interp1( layer1(ic1), values1(ic1), ngrid(i) );
    uncertainty_common1 = interp1( layer1(ic1), uncertainty1(ic1), ngrid(i) );
    values_common2      = interp1( layer2(ic2), values2(ic2), ngrid(i) );
    uncertainty_common2 = interp1( layer2(ic2), uncertainty2(ic2), ngrid(i) );
    % Calculates the weigths
    w1 = 1 ./ (uncertainty_common1.^2);
    w2 = 1 ./ (uncertainty_common2.^2);
    ws = w1 + w2;
    % Calculate the the new profile values and uncertainty values
    vprofile(i) = ( w1.*values_common1 + w2.*values_common2 ) ./ ws;
    si(i)      = sqrt( 1 ./ ws );
end
if verbose || debug
    disp('After copying the common parts...');
    for p = 1:numel(values1), fprintf('layer1(%d) = %f %f\n',p,layer1(p),values1(p)); end
    for p = 1:numel(values2), fprintf('layer2(%d) = %f %f\n',p,layer2(p),values2(p)); end
    for p = 1:numel(vprofile), fprintf('vprofile(%d) = %f\n',p,vprofile(p)); end
    for p = 1:numel(si), fprintf('si(%d) = %f\n',p,si(p)); end
end

if debug, disp('Stopping in debug mode. Type return to continue!'), keyboard; end

% Some error checks!
if any(isnan(vprofile))
    for p = 1:numel(vprofile), fprintf('vprofile(%d) = %f\n',p,vprofile(p)); end
    error('Resulting profile includes nans');
end
if any(isnan(si))
    for p = 1:numel(si), fprintf('si(%d) = %f\n',p,si(p)); end
    error('Resulting uncertainties includes nans');
end