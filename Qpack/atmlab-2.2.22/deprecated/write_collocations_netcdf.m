function write_collocations_netcdf(year, month, day, S, D, M, ...
    sat1, sensor1, ~, sensor2, info)

% write_collocations Write collocation data to netcdf file
%
% (Note: name write_collocations_netcdf is TEMPORARY)
%
% Write collocation data for year/month/day in structure S to a netcdf file.
% The filename is determined from the satellite and sensors used.
%
% FORMAT
%   
%   write_collocations(year, month, day, S, D, M, sat1, sensor1, sat2, sensor2)
%
% IN
%
%   year    (numeric)   Year for which S contains collocations
%   month   (numeric)   Month for which S contains collocations
%   day     (numeric)   Day for which S contains collocations
%   S       structure   As returned by collocate_date, structure whose
%                       field(s) describe the collocations between the sensors
%                       in question. (-1 means none)
%   D       structure   As returned by collocate_date, for the data (-1=none)
%   M       structure   As returned by collocate_date, for the mean data
%                       (-1 means none)
%   sat1    string      Primary satellite under consideration
%   sensor1 string      Sensor at primary satellite
%   sat2    string      Secondary satellite under consideration; not used,
%                       because those should be the fieldnames in S/D/M
%   sensor2 string      Sensor at secondary satellite.
%   info    structure   (optional) Additional global attributes,
%                       may overwrite default ones
%
% OUT
%
%   none (but writes a file)
%
% $Id: write_collocations_netcdf.m 7553 2012-04-27 19:08:16Z gerrit $

% FIXME: update to new-style
warning(['atmlab:' mfilename], 'old style function, being phased out, use OO way');

if ~exist('info', 'var')
    info = struct;
end
cols = colloc_constants(['cols_' sensor1 '_' sensor2]);

fields = fieldnames(S);
for i = 1:length(fields) % for each satellite
    satname = fields{i};
    if strcmp(satname, 'version') % but not for version
        continue
    end
    
    switch number_sats_in_dataset(['collocation_' sensor1 '_' sensor2])
        case 1
            s = satname;
        case 2
            s = {sat1, satname};
    end
    fn = find_datafile_by_date([year month day], s, ...
        ['collocation_' sensor1 '_' sensor2]);
    
    if strcmp(fn(end-1:end), 'gz') % take off this part
        fn(end-2:end) = '';
    end
    
    outdir = fileparts(fn);
    temp_out = tempname(atmlab('WORK_AREA'));
    if ~exist(outdir, 'dir')
        logtext(atmlab('OUT'), 'Creating %s\n', outdir);
        mkdir(outdir);
    end
    
    %% create the file
    
    logtext(atmlab('OUT'), 'Writing %s\n', temp_out);
    ncid = netcdf.create(temp_out, 'NC_CLOBBER'); % overwrite existing
    %cleanupObj = onCleanup(@() cleanup(temp_out, ncid)); % FIXME...
    
    %% define the dimensions
    
    ncollocs = size(S.(satname), 1);
    dim_collocs = netcdf.defDim(ncid, 'Collocations', ncollocs);
    if isstruct(M) % also mean-data
        try
            dim_meancollocs = netcdf.defDim(ncid, 'Averaged_collocations', size(M.(satname), 1));
        catch ME
            switch ME.identifier
                case {'MATLAB:netcdf:defDim:onlyOneUnlimitedDimensionAllowed', ...
                        'MATLAB:netcdf:defDim:eunlimit:onlyOneUnlimitedDimensionAllowed', ... 
                        'MATLAB:imagesci:netcdf:libraryFailure'}
                    dim_meancollocs = dim_collocs;
                otherwise
                    ME.rethrow();
            end
        end
    end
    
    %% put global attributes
    
    utc_time = java.lang.System.currentTimeMillis;
    [utc_date{1:6}] = unixsecs2date(utc_time/1000);
    utc_datestr = sprintf('%04d-%02d-%02dT%02d:%02d:%02dZ', ...
        [utc_date{1:5} round(utc_date{6})]);
    global_atts = struct(...
        'Conventions', 'CF-1.4', ...
        'title', 'Collocations', ...
        'history', [datestr(now, 'YYYY-mm-dd') ' Collocations generated from scratch'], ...
        'date', utc_datestr, ...
        'institution', ['Department of Space Science, Lule' char(unicode2native('å')) ' University of Technology, Kiruna, Sweden'], ...
        'source', 'Collocation codes, part of atmlab', ...
        'references', 'Holl et al. (2010)', ...
        'software_version', atmlab_version, ...
        'maxdist_km', colloc_config('distance'), ...
        'maxtime_s', colloc_config('interval'), ...
        'primary_satellite', sat1, ...
        'primary_sensor', sensor1, ...
        'primary_version', S.version{1}, ...
        'secondary_satellite', satname, ...
        'secondary_sensor', sensor2, ...
        'secondary_version', S.version{2}, ...
        'start_time', double(date2unixsecs(year, month, day)));
    % add caller-contributed ones
    warning('off', 'catstruct:DuplicatesFound')
    global_atts = catstruct(global_atts, info);
    % convert to cell-array
    global_atts = mat2cell([fieldnames(global_atts) struct2cell(global_atts)], ...
        ones(1, length(fieldnames(global_atts))), 2).';
    addncattributes(ncid, global_atts);
    
    %% define variables, variable attributes, additional dimensions
    
    colloc_vars = intersect(fieldnames(cols.overlap), fieldnames(cols.stored));
    data_vars = intersect(fieldnames(cols.data), fieldnames(cols.stored));
    if isfield(cols, 'meandata')
        mean_vars = intersect(fieldnames(cols.meandata), fieldnames(cols.stored));
    else
        mean_vars = {};
    end
    vars = [colloc_vars; data_vars; mean_vars];
    vartypes = [repmat({'overlap'}, size(colloc_vars)); ...
        repmat({'data'}, size(data_vars)); ...
        repmat({'meandata'}, size(mean_vars))];
    varids = zeros(size(vars));
    dims = struct();
    for j = 1:length(vars)
        varname = vars{j};
        type = cols.stored.(varname).type;
        atts = cols.stored.(varname).atts;
        % determine length dimension: all collocs or mean collocs?
        switch vartypes{j}
            case {'overlap', 'data'}
                dim_n = dim_collocs;
            case 'meandata'
                dim_n = dim_meancollocs;
            otherwise
                error('atmlab:write_collocations_netcdf', 'Unknown vartype: %s', vartypes{j});
        end
        % check if we have other dimensions besides the length
        if isfield(cols.stored.(varname), 'dims') && ~isempty(S.(satname))
            dimname = cols.stored.(varname).dims{1};
            dimsize = cols.stored.(varname).dims{2};
            try
                if ~isfield(dims, dimname)
                    dims.(dimname) = netcdf.defDim(ncid, dimname, dimsize);
                end
            catch ME
                switch ME.identifier
                    case 'MATLAB:netcdf:defDim:nameIsAlreadyInUse'
                        % no problem
                    otherwise
                        ME.rethrow();
                end
            end
            thisdim = [dim_n dims.(dimname)];
        else
            thisdim = dim_n;
        end
        % define variable and put attributes
        varid = netcdf.defVar(ncid, varname, type, thisdim);
        varids(j) = varid;
        for k = fieldnames(atts)'
            netcdf.putAtt(ncid, varid, k{1}, atts.(k{1}));
        end
    end
    
    %% write data
    
    % end define mode
    
    netcdf.endDef(ncid);
    
    if isempty(S.(satname))
        logtext(atmlab('OUT'), 'Nothing to write\n');
    else
        % put vars
        logtext(atmlab('OUT'), 'Writing: ');
        
        for j = 1:length(vars)
            varname = vars{j};
            fprintf(atmlab('OUT'), '%s ', varname);
            
            vartype = vartypes{j};
            varid = varids(j);
            switch vartype
                case 'overlap'
                    netcdf.putVar(ncid, varid, S.(satname)(:, cols.(vartype).(varname)));
                case 'data'
                    netcdf.putVar(ncid, varid, D.(satname)(:, cols.(vartype).(varname)));
                case 'meandata'
                    if isempty(M.(satname))
                        logtext(atmlab('ERR'), 'Warning: No meandata\n');
                    else
                        netcdf.putVar(ncid, varid, M.(satname)(:, cols.(vartype).(varname)));
                    end
            end
        end
        fprintf(atmlab('OUT'), '\n');
    end
    logtext(atmlab('OUT'), 'Finalising\n');
    logtext(atmlab('OUT'), 'Gzipping to %s and removing uncompressed\n', outdir);
    netcdf.close(ncid);
    gzipped_filename = gzip(temp_out, outdir);
    movefile(gzipped_filename{1}, [fn '.gz']);
    logtext(atmlab('OUT'), 'Done\n');

end
end

function cleanup(temp_out, ncid)
logtext(atmlab('OUT'), 'Cleaning up\n');
try
    netcdf.close(ncid);
catch ME
    switch ME.identifier
        case {'MATLAB:netcdf:inq:notNetcdfID', 'MATLAB:netcdf:close:notNetcdfID', ...
                'MATLAB:netcdf:close:ebadid:notNetcdfID'} % already closed
        otherwise
            ME.rethrow();
    end
end
delete(temp_out);
end
