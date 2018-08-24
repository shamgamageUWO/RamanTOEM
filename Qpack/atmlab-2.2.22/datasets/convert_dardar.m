function convert_dardar(dt1, dt2)
    % convert full dardar to subselected dardar
    %
    % Fields are defined by dataset 'dardarsub'
    %
    % FORMAT
    %
    %   convert_dardar(dt1, dt2)
    %
    % IN
    %
    %   dt1     datevec, starting date
    %   dt2     datevec, ending date
    %
    %
    % $Id: convert_dardar.m 8250 2013-03-01 12:34:40Z gerrit $
    
    D = datasets;
    dd_full = D.dardar;
    dd_sub = D.dardarsub;
    
    tostore = fieldnames(dd_sub.members);
    [grans, paths] = dd_full.find_granules_for_period(dt1, dt2, '');

    builtins = {'time', 'lat', 'lon'};
    
    for i = 1:size(grans, 1);
        dt = grans(i, :);
                
        [~, bs] = fileparts(paths{i});
        dd_sub.filename = [bs '_selection.nc.gz'];
        ff = fullfile(dd_sub.find_datadir_by_date(dt), dd_sub.filename);
        if exist(ff, 'file') && ~dd_sub.overwrite
            logtext(atmlab('OUT'), 'Already exists, skipping: %s\n', ff);
            continue
        end
        data = dd_full.read_granule(dt, '', ...
            setdiff(tostore, builtins), ...
            false, false, false); % (no duplicate removing, no force-on-error, no reloading)
        
        ncols = sum(cellfun(@(f) size(data.(f), 2), tostore));
        nrows = size(data.time, 1);
%         data.height = repmat(data.height, [nrows 1]);
        % Apply factor and offset where appropriate. So far hardcoded for
        % temperature only, if more fields should then systematic searching
        % ought to be implemented
        data.temperature = int16(round(...
            (data.temperature - dd_sub.members.temperature.atts.add_offset)/(dd_sub.members.temperature.atts.scale_factor)));
        data.temperature(data.temperature<0) = dd_sub.members.temperature.atts.missing_value;

        M = zeros(nrows, ncols);
        nc = 1;
        
        for k = 1:length(tostore)
            fld = tostore{k};
            w = size(data.(fld), 2);
            rng = nc:(nc+w-1);
            M(:, rng) = data.(fld);
            cc.(fld) = rng;
            nc = nc + w;
        end
        
        dd_sub.cols = cc;
        
        info = struct();
        info.title = 'Reduced DARDAR data';
        dd_sub.store(dt(1:3), '', M, info);
    end
    
end
