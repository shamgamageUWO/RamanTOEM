function [alt_v_abs abs_v] = cleanAEdata(dabs, config)

if isempty(dabs)
    alt_v_abs = [];
    abs_v = [];
    return
end

maxalt_abs = config.ini.dABS.maxalt;

% Extract the altitude and signal
alt_v_abs   = dabs.r;         % altitude for attenuated backscatter
abs_v(:,:)  = dabs.EsR2(:,:); % attenuated backscatter - variable, could be really variable, or to have its own altitude vector - this is to be presented on teh vertical profile

alt_v_abs   = alt_v_abs(alt_v_abs<=maxalt_abs);% restricts the length of the vector
alt_v_abs   = round(alt_v_abs);
abs_v       = abs_v(alt_v_abs<=maxalt_abs,:);  % restricts the length of the vector
%abs_v((abs_v(:,:)<1e-5))    = NaN;  % removes very small numbers
%abs_v(isinf(abs_v(:,:)))    = NaN;  % removes inf values

% Interpolation on fixed altitude points -> [alt_f_abs abs_f]
warning off
try
    abs_f  = interp1(alt_v_abs, abs_v, alt_f_abs,'linear');
catch
    abs_f = nan;
end

for i=1:size(abs_f,2)
    abs_f(:,i) = smooth(abs_f(:,i),3,'moving');
end
warning on
%abs_f(abs_f(:,:)<1e-5)   = NaN;
%abs_f(isinf(abs_f(:,:))) = NaN;

