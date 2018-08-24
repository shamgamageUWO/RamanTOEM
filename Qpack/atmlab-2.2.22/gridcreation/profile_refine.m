% PROFILE_REFINE Refine atmospheric profiles by adding additional grid
% points.
%
% This function is intended for the interpolation of atmospheric profiles
% to a finer vertical grid. It uses GRID_REFINE to find the actual points
% for the new grid. 
%
% The input variable profs holds the profile data, where each column is a
% quantity (p,t,z,vmrs,...) and each row corresponds to a pressure level.
%
% The first column must hold the pressure profile, which is used for the
% interpolation of the other columns. The interpolation is done in ln(p),
% consistent with the general ARTS standard.
%
% See also: GRID_REFINE, which does most of the difficult work here.
%
% FORMAT rprofs = profile_refine(profs, delta_ln_p)
%
% OUT   rprofs       Profiles interpolated to the new grid.
% IN    profs        The profiles to interpolate. 
%       delta_ln_p   Desired maximum grid spacing. This must be in ln(Pa)
%                    units!

% 2010-07-02 Created by Stefan Buehler

function rprofs = profile_refine(profs, delta_ln_p)

% Get pressure grid. Note the ln!
lnp = log(profs(:,1));

% We do no error checking on p here, since this is done by
% grid_refine.

% But check the delta_ln_p value to catch some of the cases where
% the user uses pressure directly. (An ln(Pa) of 10 correspons
% roughly to an altitude difference of 70 km.)
if delta_ln_p > 10
    error(['You specified an extremely larege delta_ln_p value. ',...
           'Are you sure that your value is in ln(Pa) units?']);
end

% Get data to interpolate.
data = profs(:,2:end);

% Refine log-p grid.
lnp_refined = grid_refine(lnp, delta_ln_p);

% Do the interpolation.
data_refined = interp1(lnp, data, lnp_refined);

% Store grid and data in output variable rprofs.
% Note the exp()!
rprofs = [exp(lnp_refined), data_refined];

