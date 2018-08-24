function process_ccniwp_data(date1, date2, sat)

% Retrieve SPARE-ICE
%
% process_ccniwp_data(date1, date2, sat)

% TODO: correct for biases etc.
D = datasets();
% if isfield(D, 'col_syn_iwp')
%     datasets('delete', D.col_syn_iwp);
% end
% ccniwp = CollocatedNNIWP('name', 'col_syn_iwp', ...
%     'basedir', '/storage3/user_data/gerrit/products/passive_syn_iwp', ...
%     'subdir', '$YEAR4/$MONTH/$DAY', ...
%     'filename', '$SAT_$HOUR_$MINUTE.nc.gz');
% ccniwp.loadnets('/storage3/user_data/gerrit/neuralnets/avhrr_12345_mhs_345_lat_angles_all_global_MEAN_AVHRR_Y,1,2,3,4,5,B_BT,3,4,5,B_LZA,B_LAA,B_SZA,B_SAA,LAT1,_to_MEAN_IWP_2C,_noise0.00,_0.mat');
% ccniwp.overwrite = 2;
%ud = ccniwp.net.fit.userdata;

if ~isfield(D, 'col_syn_iwp')
    define_local_datasets();
end

if isempty(D.col_syn_iwp.net)
    D.col_syn_iwp.loadnets();
end

%X = struct();
allgrans = D.mhs.find_granules_for_period(date1, date2, sat);
%parfor i = 1:size(allgrans, 1)
    % FIXME: can now use D.retrieve_and_store_period!
for i = 1:size(allgrans, 1)
    logtext(atmlab('OUT'), 'Processing: %s\n', num2str(allgrans(i, :)));
%     if isnan(atmlab('SITE'))
%         logtext(1, 'Initialising\n');
%         startup;
%         ccniwp = CollocatedNNIWP('name', 'col_syn_iwp', ...
%             'basedir', '/storage3/user_data/gerrit/products/passive_syn_iwp', ...
%             'subdir', '$YEAR4/$MONTH/$DAY', ...
%             'filename', 'ccniwp_03_$SAT_$HOUR_$MINUTE.nc.gz', ...
%             'altfilename', '$SAT_$HOUR_$MINUTE.nc.gz', ...
%             'version', '0.3');
%         ccniwp.loadnets('/storage3/user_data/gerrit/neuralnets/avhrr_12345_mhs_345_lat_angles_elev_all_global_MEAN_AVHRR_Y,1,2,3,4,5,B_BT,3,4,5,B_LZA,B_LAA,B_SZA,B_SAA,LAT1,Surface_elevation,_to_MEAN_IWP_2C,_noise0.00,_0.mat');
% 
%         %ccniwp.loadnets('/storage3/user_data/gerrit/neuralnets/avhrr_12345_mhs_345_lat_angles_all_global_MEAN_AVHRR_Y,1,2,3,4,5,B_BT,3,4,5,B_LZA,B_LAA,B_SZA,B_SAA,LAT1,_to_MEAN_IWP_2C,_noise0.00,_0.mat');
%         %ccniwp.overwrite = 2;
%         
%     end
    %D = datasets();
    %D
    %D.col_syn_iwp.find_granule_by_datetime(allgrans(i, :), sat)
    try
        D.col_syn_iwp.retrieve_and_store_granule(allgrans(i, :), sat);
    catch ME
        switch ME.identifier
            case {'atmlab:find_granule_by_datetime', 'atmlab:collocate', 'atmlab:CollocatedDataset:noother'}
                logtext(atmlab('ERR'), 'Cannot retrieve for %s %s: %s\n', ...
                    'noaa18', num2str(allgrans(i, :)), ME.message);
                continue
            otherwise
                ME.rethrow();
        end
    end
    
%     t = getCurrentTask();
%     %D = datasets();
%     if ~isfield(X, sprintf('no%d', t.ID))
%         logtext(atmlab('OUT'), 'First run for %d\n', t.ID);
%         X.(sprintf('no%d', t.ID)) = true;
%     end
end
%{
    if ~isfield(D, 'mhs')
        startover();
        D = datasets();
    end
    if isfield(D, sprintf('col_syn_iwp%d', t.ID))
        ccniwp_local = D.(sprintf('col_syn_iwp%d', t.ID));
    else
        logtext(atmlab('OUT'), 'Creating ccniwp no %d\n', t.ID);
        ccniwp_local = CollocatedNNIWP('name', sprintf('col_syn_iwp%d', t.ID), ...
            'basedir', '/storage3/user_data/gerrit/products/passive_syn_iwp', ...
            'subdir', '$YEAR4/$MONTH/$DAY', ...
            'filename', '$SAT_$HOUR_$MINUTE.nc.gz');
        ccniwp_local.loadnets('/storage3/user_data/gerrit/neuralnets/avhrr_12345_mhs_345_lat_angles_all_global_MEAN_AVHRR_Y,1,2,3,4,5,B_BT,3,4,5,B_LZA,B_LAA,B_SZA,B_SAA,LAT1,_to_MEAN_IWP_2C,_noise0.00,_0.mat');
        ccniwp_local.overwrite = 2;
    end

    try
        ccniwp_local.retrieve_and_store_gran(allgrans(i, :), sat);
    catch ME
        switch ME.identifier
            case {'atmlab:find_granule_by_datetime', 'atmlab:collocate'}
                logtext(atmlab('ERR'), 'Cannot retrieve for %s %s: %s\n', ...
                    'noaa18', num2str(allgrans(i, :)), ME.message);
                continue
            otherwise
                ME.rethrow();
        end
    end
end
%}

%[result, additional_results, also] = D.collocation_mhs_avhrr.collocate_granule([2007, 1, 1, 1, 53], 'noaa18', 'noaa18', {D.associated_mhs_avhrr, D.collapsed_mhs_avhrr}, true);
%[M, cols] = D.associated_mhs_avhrr.merge_matrix(result, D.collocation_mhs_avhrr.cols, additional_results{1}, D.associated_mhs_avhrr.cols);
%[M, cols] = D.collapsed_mhs_avhrr.merge_matrix(M, cols, additional_results{2}, D.collapsed_mhs_avhrr.cols);

%[iwp, lat, lon] = ccniwp.retrieve(M, cols, 0.5);

%ccniwp.retrieve_and_store_gran([2007, 1, 1, 1, 53], 'noaa18');
% flds = structfun(@(X) safegetfield(X, 'chans', -1), ud.inputs, 'UniformOutput', false);
% fldsnms = fieldnames(flds);
% 
% [Mp, cp] = get_columns(M, cols, flds);
% for i = 1:length(fldsnms)
%     fld = fldsnms{i};
%     Mp(:, cp.(fld)) = ud.inputs.(fld).transform(Mp(:, cp.(fld)));
% end
% 
% lims.B_SZA = [0, 85];
% limmer = collocation_restrain(Mp, limstruct2limmat(lims, cp));
% Mp = Mp(limmer, :);
% M = M(limmer, :); % for lat/lon/time still ekep track
% 
% cloudy = cc.net.pat(Mp.');

end
