function S = netcdf_dataset(ds, file, varargin)
    % read homegrown netcdf-stored dataset such as dardarsub, CMIWP, ...
    %
    % format as other satreaders.-functions.
    %
    % For info on the common format, see <a href="matlab:help SatDataset/reader">SatDataset/reader</a>.
    %
    % $Id: satreaders.dardarsub.m 7600 2012-05-14 13:21:10Z seliasson $

    core_fields   = {'time','lat','lon'};
    extra_fields  = optargs(varargin, {{}});
    all_fields    = [core_fields(:); extra_fields(:)];

    [S, attr] = loadncvar(file, all_fields);
    %C(1:2*length(attr)) = deal([attr{:}]);
    %strattr = struct(C{:});
    strattr = attr;
    
    % get additional stuff
    info = ds.find_info_from_granule(file);
    
    if isfield(info, 'doy')
        date = dayofyear_inverse(str2double(info.year), str2double(info.doy));
        date = [date.year date.month date.day];
    else
        date = [str2double(info.year) str2double(info.month) str2double(info.day)];
    end
    S.epoch = round(date2unixsecs(date(1), date(2), date(3)));
    
    S.path = file;
    S.version = strattr.version;

    S = MaskInvalidGeoTimedataWithNaN(S);
end
