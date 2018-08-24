function value = datasets_config(varargin)

% datasets_config Defines datasets and associated info
%
% This m-file interacts with a <a href="matlab:help prstnt_struct">persistent structure</a>
% and defines a number of <a href="matlab:help SatDataset">SatDataset</a>s.
%
% Site-specific information for those datasets can be set by adding
% datasets_init to your path. This is executed when datasets_config is run
% for the first time.
%
% For example settings, see site-specific/kiruna/datasets_init.m. If adding
% a new dataset, it is recommended to also set defaults in the
% site-specific initialisation, so that others can use it directly and that
% it can serve as an example to people at other sites.

% Created by Gerrit
% $Id: datasets_config.m 7564 2012-05-02 14:24:45Z gerrit $

persistent A

persistent initialised

if isempty(initialised)
    addsite
    if exist('datasets_init', 'file')==2
        logtext(atmlab('OUT'), 'datasets_config first run, initialising...\n');
        initialised = true;
        datasets_init;
    else
        warning('atmlab:datasets:datasets_config', ...
                'Cannot find datasets_init, not initialising');
    end
        
end

try
    [A,value] = prstnt_struct( A, @datasets_defs, varargin );
catch ME
    switch (ME.identifier)
        % see if any aliases can be identified
        case 'atmlab:input:undefined'
            varargin{1} = replace_aliases(varargin{1});
            [A,value] = prstnt_struct( A, @datasets_defs, varargin);
        otherwise
            ME.rethrow();
    end
end

end


function A = datasets_defs

%% define locations of tools and meta-stuff

A.sat2netcdf = nan;
A.firstline_data = ''; % contains global default
A.blacklist = nan;

%% define datasets
%
% See also atmlab/site-specific/kiruna/datasets_init.m


%% deprecated style!
if atmlab('LEGACY_MODE')
    
    A.amsua_basedir = nan;
    A.amsua_subdir = nan;
    A.amsua_regexp = nan;
    A.amsua_filename = nan;
    
    A.amsub_basedir = nan;
    A.amsub_subdir = nan;
    A.amsub_regexp = nan;
    A.amsub_filename = nan;
    
    A.avhrr_basedir = nan;
    A.avhrr_subdir = nan;
    A.avhrr_regexp = nan;
    A.avhrr_filename = nan;
    
    
    A.cpr_basedir = nan;
    A.cpr_subdir = nan;
    A.cpr_regexp = nan;
    A.cpr_filename = nan;
    
    A.cloudsat_1B_CPR_basedir = nan;
    A.cloudsat_1B_CPR_subdir = nan;
    A.cloudsat_1B_CPR_regexp = nan;
    A.cloudsat_1B_CPR_filename = nan;
    
    A.cloudsat_2B_GEOPROF_basedir = nan;
    A.cloudsat_2B_GEOPROF_subdir = nan;
    A.cloudsat_2B_GEOPROF_regexp = nan;
    A.cloudsat_2B_GEOPROF_filename = nan;
    
    A.cloudsat_2B_CWC_RO_basedir = nan;
    A.cloudsat_2B_CWC_RO_subdir = nan;
    A.cloudsat_2B_CWC_RO_regexp = nan;
    A.cloudsat_2B_CWC_RO_filename = nan;
    
    A.cloudsat_2B_CWC_RVOD_basedir = nan;
    A.cloudsat_2B_CWC_RVOD_subdir = nan;
    A.cloudsat_2B_CWC_RVOD_regexp = nan;
    A.cloudsat_2B_CWC_RVOD_filename = nan;
    
    A.cloudsat_2C_PRECIP_COLUMN_basedir = nan;
    A.cloudsat_2C_PRECIP_COLUMN_subdir = nan;
    A.cloudsat_2C_PRECIP_COLUMN_regexp = nan;
    A.cloudsat_2C_PRECIP_COLUMN_filename = nan;
    
    A.cloudsat_ECMWF_AUX_basedir = nan;
    A.cloudsat_ECMWF_AUX_subdir = nan;
    A.cloudsat_ECMWF_AUX_regexp = nan;
    A.cloudsat_ECMWF_AUX_filename = nan;
    
    
    A.hirs_basedir = nan;
    A.hirs_subdir = nan;
    A.hirs_regexp = nan;
    A.hirs_filename = nan;
    
    A.hirscs_basedir = nan;
    A.hirscs_subdir = nan;
    A.hirscs_regexp = nan;
    A.hirscs_filename = nan;
    
    %old
    A.mhs_basedir = nan;
    A.mhs_subdir = nan;
    A.mhs_regexp = nan;
    A.mhs_filename = nan;
    
    
    % old
    A.mspps_basedir = nan;
    A.mspps_subdir = nan;
    A.mspps_regexp = nan;
    A.mspps_filename = nan;
    
    
    % OLD STYLE
    A.collocation_cpr_mhs_basedir = nan;
    A.collocation_cpr_mhs_subdir = nan;
    A.collocation_cpr_mhs_regexp = nan;
    A.collocation_cpr_mhs_filename = nan;
    
    A.collocation_cpr_mhs_hdf5_basedir = nan;
    A.collocation_cpr_mhs_hdf5_subdir = nan;
    A.collocation_cpr_mhs_hdf5_regexp = nan;
    A.collocation_cpr_mhs_hdf5_filename = nan;
    
    A.collocation_cpr_mhs_legacy_basedir = nan;
    A.collocation_cpr_mhs_legacy_subdir = nan;
    A.collocation_cpr_mhs_legacy_regexp = nan;
    A.collocation_cpr_mhs_legacy_filename = nan;
    
    A.collocation_cpr_mhs_data_legacy_basedir = nan;
    A.collocation_cpr_mhs_data_legacy_subdir = nan;
    A.collocation_cpr_mhs_data_legacy_regexp = nan;
    A.collocation_cpr_mhs_data_legacy_filename = nan;
    
    A.collocation_cpr_mhs_meandata_legacy_basedir = nan;
    A.collocation_cpr_mhs_meandata_legacy_subdir = nan;
    A.collocation_cpr_mhs_meandata_legacy_regexp = nan;
    A.collocation_cpr_mhs_meandata_legacy_filename = nan;
    
    A.collocation_mhs_mhs_basedir = nan;
    A.collocation_mhs_mhs_subdir = nan;
    A.collocation_mhs_mhs_regexp = nan;
    A.collocation_mhs_mhs_filename = nan;
    
    
    A.collocation_mhs_mhs_hdf5_basedir = nan;
    A.collocation_mhs_mhs_hdf5_subdir = nan;
    A.collocation_mhs_mhs_hdf5_regexp = nan;
    A.collocation_mhs_mhs_hdf5_filename = nan;
    
    A.collocation_mhs_mhs_legacy_basedir = nan;
    A.collocation_mhs_mhs_legacy_subdir = nan;
    A.collocation_mhs_mhs_legacy_regexp = nan;
    A.collocation_mhs_mhs_legacy_filename = nan;
    
    A.collocation_mhs_mhs_data_legacy_basedir = nan;
    A.collocation_mhs_mhs_data_legacy_subdir = nan;
    A.collocation_mhs_mhs_data_legacy_regexp = nan;
    A.collocation_mhs_mhs_data_legacy_filename = nan;
    
    A.collocation_cpr_avhrr_basedir = nan;
    A.collocation_cpr_avhrr_subdir = nan;
    A.collocation_cpr_avhrr_regexp = nan;
    A.collocation_cpr_avhrr_filename = nan;
    
    A.collocation_cpr_avhrr_hdf5_basedir = nan;
    A.collocation_cpr_avhrr_hdf5_subdir = nan;
    A.collocation_cpr_avhrr_hdf5_regexp = nan;
    A.collocation_cpr_avhrr_hdf5_filename = nan;
    
    
    A.collocation_cpr_avhrr_legacy_basedir = nan;
    A.collocation_cpr_avhrr_legacy_subdir = nan;
    A.collocation_cpr_avhrr_legacy_regexp = nan;
    A.collocation_cpr_avhrr_legacy_filename = nan;
    
    A.collocation_hirscs_mhs_basedir = nan;
    A.collocation_hirscs_mhs_subdir = nan;
    A.collocation_hirscs_mhs_regexp = nan;
    A.collocation_hirscs_mhs_filename = nan;
    
    A.collocation_hirscs_mhs_hdf5_basedir = nan;
    A.collocation_hirscs_mhs_hdf5_subdir = nan;
    A.collocation_hirscs_mhs_hdf5_regexp = nan;
    A.collocation_hirscs_mhs_hdf5_filename = nan;
    
    A.collocation_hirscs_mhs_legacy_basedir = nan;
    A.collocation_hirscs_mhs_legacy_subdir = nan;
    A.collocation_hirscs_mhs_legacy_regexp = nan;
    A.collocation_hirscs_mhs_legacy_filename = nan;
    
    A.collocation_hirscs_mhs_data_legacy_basedir = nan;
    A.collocation_hirscs_mhs_data_legacy_subdir = nan;
    A.collocation_hirscs_mhs_data_legacy_regexp = nan;
    A.collocation_hirscs_mhs_data_legacy_filename = nan;
    
    A.collocation_amsua_amsua_basedir = nan;
    A.collocation_amsua_amsua_subdir = nan;
    A.collocation_amsua_amsua_regexp = nan;
    A.collocation_amsua_amsua_filename = nan;
    
    A.collocation_hirs_hirs_basedir = nan;
    A.collocation_hirs_hirs_subdir = nan;
    A.collocation_hirs_hirs_regexp = nan;
    A.collocation_hirs_hirs_filename = nan;
    
    A.collocation_collocation_cpr_mhs_avhrr_basedir = nan;
    A.collocation_collocation_cpr_mhs_avhrr_subdir = nan;
    A.collocation_collocation_cpr_mhs_avhrr_regexp = nan;
    A.collocation_collocation_cpr_mhs_avhrr_filename = nan;
    
    A.collocation_collocation_cpr_mhs_avhrr_hdf5_basedir = nan;
    A.collocation_collocation_cpr_mhs_avhrr_hdf5_subdir = nan;
    A.collocation_collocation_cpr_mhs_avhrr_hdf5_regexp = nan;
    A.collocation_collocation_cpr_mhs_avhrr_hdf5_filename = nan;
    
    A.collocation_collocation_cpr_mhs_avhrr_legacy_basedir = nan;
    A.collocation_collocation_cpr_mhs_avhrr_legacy_subdir = nan;
    A.collocation_collocation_cpr_mhs_avhrr_legacy_regexp = nan;
    A.collocation_collocation_cpr_mhs_avhrr_legacy_filename = nan;
end
end
