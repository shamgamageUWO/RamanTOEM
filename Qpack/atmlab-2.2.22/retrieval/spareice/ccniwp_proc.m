function data = ccniwp_proc(~, data, ~)
if isempty(data.lat)
    data.Surface_elevation = [];
    data.Surface_elevation_std = [];
    data.CFSR_Skin_temperature = [];
else
    data.Surface_elevation = vec2col(get_surface_elevation(data.LAT, data.LON));
    data.Surface_elevation_std = vec2col(get_surface_elevation(data.LAT, data.LON, 1));
    
    [ye, mo, da, ho, mi, se] = unixsecs2date(data.TIME);
    dv = [ye, mo, da, ho, mi, se];
    [~, I] = sortrows(dv);
    D = datasets();
    S = D.CFSR.read_from_grid(data.LAT(I), data.LON(I), dv(I, :), {'TMP_L1'});
    data.CFSR_Skin_temperature(I) = S.TMP_L1;
    data.CFSR_Skin_temperature = vec2col(data.CFSR_Skin_temperature);
end
end
