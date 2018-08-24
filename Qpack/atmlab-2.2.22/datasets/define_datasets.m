function varargout = define_datasets(varargin)
% define datasets
%
% This function defines datasets. It has two modes:
%
% - no inputs and no outputs, just define datasets
% - one input 'check', return logical scalar to say if it has been defined
%
% See also: SatDataset, CollocatedDataset, FieldCopier, Collapser

% $Id: define_datasets.m 8941 2014-09-15 11:04:40Z olemke $
% Gerrit Holl

persistent defined;

if nargin > 0 && strcmp(varargin{1}, 'check')
    varargout{1} = ~isempty(defined);
    return
end

if ~isempty(defined)
    logtext(atmlab('OUT'), 'Datasets were already defined, doing nothing.\n');
    return
end

%% datasets generated elsewhere

SatDataset('name', 'amsua', ...
    'reader', @satreaders.poes_radiometer, ...
    'granule_duration', 6130, ...
    'sats', {'noaa15', 'noaa16', 'noaa17', 'noaa18', 'noaa19', 'metopa'});

SatDataset('name', 'amsub', ...
    'reader', @satreaders.poes_radiometer, ...
    'granule_duration', 6130, ...
    'sats', {'noaa15', 'noaa16', 'noaa17'}); 

SatDataset('name','avhrr_cmsaf_gac',...
    'reader', @satreaders.avhrr_cmsaf_gac, ...
    'granule_duration',7200);

SatDataset('name', 'avhrr', ...
    'reader', @satreaders.avhrr, ...
    'granule_duration', 6130);

SatDataset('name', 'calipso', ...
    'satname', 'calipso', ...
    'reader', @satreaders.calipso, ...
    'granule_duration', 5932);

SatDataset('name','cloud_cci',...
    'reader', @satreaders.cloud_cci, ...
    'granule_duration',7200);

SatDataset('name', 'cpr', ...
    'satname', 'cloudsat', ...
    'reader', @satreaders.cpr, ...
    'granule_duration', 5932);

SatDataset('name', 'CPR_RVOD', ...
    'satname', 'cloudsat', ...
    'reader', @satreaders.cpr, ...
    'granule_duration', 5932);

SatDataset('name', 'cprCloud', ...
    'satname', 'cloudsat', ...
    'reader', @satreaders.cpr, ...
    'granule_duration', 5932);

SatDataset('name', 'cprCloudLidar', ...
    'satname', 'cloudsat', ...
    'reader', @satreaders.cpr, ...
    'granule_duration', 5932);

SatDataset('name', 'CPR_1B', ...
    'satname', 'cloudsat', ...
    'reader', @satreaders.cpr, ...
    'granule_duration', 5932);

SatDataset('name', 'CPR_2C_ICE', ...
    'satname', 'cloudsat', ...
    'reader', @satreaders.cpr, ...
    'granule_duration', 5932);

SatDataset('name', 'CPR_ECMWF', ...
    'satname', 'cloudsat', ...
    'reader', @satreaders.cpr, ...
    'granule_duration', 5932);

SatDataset('name','dardar',...
    'satname', 'atrain', ...
    'reader', @satreaders.dardar, ...
    'granule_duration',5932);

SatDataset('name', 'hirs', ...
    'reader', @satreaders.poes_radiometer, ...
    'granule_duration', 6130, ...
    'sats', {'noaa15', 'noaa16', 'noaa17', 'noaa18', 'noaa19', 'metopa'});

SatDataset('name', 'gras_per_day', ...
    'reader', @satreaders.grasdir, ...
    'satname', 'any', ...
    'granule_duration', 86400);

SatDataset('name','isccp_dx',...
    'reader',@satreaders.isscp_dx,...
    'granule_duration',3*60); %data var 3:de timme och var 15:de km

SatDataset('name','isccp_d2',...
    'reader',@satreaders.isscp_d2);

SatDataset('name', 'mhs', ...
    'reader', @satreaders.poes_radiometer, ...
    'granule_duration', 6130, ...
    'sats', {'noaa18', 'noaa19', 'metopa'});

SatDataset('name', 'mirs', ...
    'reader', @satreaders.mirs, ...
    'granule_duration', 7200);
                
SatDataset('name', 'modis_aqua_L2', ...
    'reader', @satreaders.modis, ...
    'granule_duration', 300);

SatDataset('name', 'modis_L3'); % no reader defined yet

SatDataset('name', 'mspps', ...
    'reader', @satreaders.mspps, ...
    'granule_duration', 6130);

SatDataset('name', 'patmosx', ...
    'reader', @satreaders.patmosx, ...
    'granule_duration', 86400);

SatDataset('name', 'patmosxL3', ...
    'satname', 'NOAAx', ...
    'reader', @satreaders.patmosxL3);

SatDataset('name', 'saphir_l1a', ...
    'needs_starttimesfile', true, ...
    'reader', @satreaders.saphir, ...
    'satname', 'meghatropiques', ...
    'granule_duration', 7000); % FIXME: verify granule_duration

SatDataset('name', 'saphir_l1a2', ...
    'needs_starttimesfile', false, ...
    'reader', @satreaders.saphir, ...
    'satname', 'meghatropiques', ...
    'granule_duration', 7000); % FIXME: verify granule_duration

SatDataset('name', 'saphir_l2a', ...
    'needs_starttimesfile', true, ...
    'reader', @satreaders.saphir, ...
    'satname', 'meghatropiques', ...
    'granule_duration', 7000); % FIXME: verify granule_duration

SatDataset('name', 'ssmt2', ...
    'needs_starttimesfile', false, ...
    'reader', @satreaders.ssmt2, ...
    'granule_duration', 7000); % FIXME: verify granule_duration

GriddedDataset('name', 'CFSR', ...
    'reader', @satreaders.ncep_cfsr_day);

%% datasets generated here (non-collocated)

% dardarsub
HomemadeDataset('name', 'dardarsub', ...
                'satname', 'atrain', ...
                'granule_duration', 5932, ...
                'reader', @satreaders.dardarsub, ...
                'metadata',struct('height',(25080:-60:-1020)),...
                'members', struct(...
                    'iwc', struct(...
                        'type', 'float', ...
                        'dims', {{'HEIGHT', 436}}, ...
                        'atts', struct(...
                            'long_name', 'Retrieved Ice Water Content', ...
                            'units', 'kg m-3',...
                            'missing_value',-999)), ...
                    'ln_iwc_error', struct(...
                        'type', 'float', ...
                        'dims', {{'HEIGHT', 436}}, ...
                        'atts', struct(...
                            'long_name', 'Fractional error in IWC', ...
                            'units','ln(kg m-3)',...
                            'missing_value',-999)), ...
                    'vis_optical_depth', struct(...
                        'type', 'float', ...
                        'atts', struct(...
                            'long_name', 'Optical Thickness forward model',...
                            'units','-',...
                            'missing_value',-999)), ...
                    'vis_optical_depth_error', struct(...
                        'type', 'float', ...
                        'atts', struct(...
                            'long_name', 'Error in optical thickness forward model',...
                            'units','-',...
                            'missing_value',-999)), ...
                    'effective_radius',struct(...
                        'type','float',...
                        'dims', {{'HEIGHT', 436}}, ...                        
                        'atts', struct(...
                            'long_name','Retrieved effective radius', ...
                            'units','m',...
                            'missing_value',-999)), ...
                    'ln_effective_radius_error',struct(...
                        'type','float',...
                        'dims', {{'HEIGHT', 436}}, ...                        
                        'atts', struct(...
                            'long_name','Fractional error in effective radius', ...
                            'units','ln(m)',...
                            'missing_value',-999)), ...
                    'instrument_flag', struct(...
                        'type', 'byte', ...
                        'dims', {{'HEIGHT', 436}}, ...
                        'atts', struct(...
                            'long_name', 'Instrument flag (0==nothing/1==lidar/2==radar/3==radar+lidar)', ...
                            'units', 'dimensionless')), ...
                    'DARMASK_Simplified_Categorization', struct(...
                        'type', 'byte', ...
                        'dims', {{'HEIGHT', 436}}, ...
                        'atts', struct(...
                            'long_name', 'DARMASK Simplified Categorization',...
                            'description',['DARDAR flags (-9 -> ground, -1 -> don''t know, 0 -> clear, ' ...
                            '1 -> ice, 2 -> ice + supercooled, 3 ->liquid warm, 4 -> supercooled, 5 -> rain, '...
                            '6 -> aerosol, 7 -> maybe insects, 8 -> stratospheric feature)'], ...
                            'units', '-')), ...
                    'temperature', struct(...
                        'type', 'short', ...
                        'dims', {{'HEIGHT', 436}}, ...
                        'atts', struct(...
                            'long_name', 'Temperature from ECMWF', ...
                            'units', 'K', ...
                            'scale_factor', .01, ...
                            'add_offset', 100, ...
                            'missing_value', -999, ...
                            'valid_range', [0 40000])), ...
                    'time', struct(...
                        'type', 'float', ...
                        'atts', struct(...
                            'long_name', 'UTC time', ...
                            'units', 's',...
                            'missing_value',-999)), ...
                    'lat', struct(...
                        'type', 'float', ...
                        'atts', struct(...
                            'long_name','Latitude',...
                            'units', 'degree',...
                            'missing_value',-999)), ...
                    'lon', struct(...
                        'type', 'float', ...
                        'atts', struct(...
                            'long_name','Longitude',...
                            'units', 'degree',...
                            'missing_value',-999)), ...
                    'day_night_flag', struct(...
                        'type', 'byte', ...
                        'atts', struct(...
                            'long_name', 'Day Night Flag for lidar Night (1) Day (0)',...
                            'units','-',...
                            'missing_value',-999)), ...
                    'land_water_mask', struct(...
                        'type', 'byte', ...
                        'atts', struct(...
                            'long_name', 'Land Water Mask from Calipso files',...
                            'description',['Land Water Mask from Calipso files, '...
                                        'indicating the surface type at the laser '...
                                        'footprint 0=shallow ocean 1=land 2=coastlines '...
                                        '3=shallow inland water 4=intermittent water '...
                                        '5=deep inland water 6=continental ocean 7=deep ocean'],... 
                            'units','-'))));
    
    
                        
cmoiwp = CollocatedMicrowaveOnlyIWP('name', 'cmoiwp','granule_duration', 6130); % reader set in this constructor

% old versions thereof

for v = {'v0_0', 'v0_1', 'v0_2', 'v0_3', 'v0_4', 'v0_5', 'v0_6'}
    SatDataset('name', sprintf('cmoiwp_%s', v{1}), ...
    'granule_duration', cmoiwp.granule_duration, ...
    'reader', cmoiwp.reader);
end

% special case; collocated, but not in the standard system

HomemadeDataset('name', 'cdpc_2dcp', ...
                'granule_duration', 5932, ...
                'reader', @satreaders.cdpc2dcp, ...
                'members', struct(...
                    'POES_START', struct(...
                        'type', 'int', ...
                        'atts', struct(...
                            'long_name', 'AMSU-B/MHS granule starting time', ...
                            'units', 'seconds since 1970-01-01T00:00:00Z')), ...
                    'POES_TIME', struct(...
                        'type', 'int', ...
                        'atts', struct(...
                            'long_name', 'AMSU-B/MHS measurement time', ...
                            'units', 'seconds since 1970-01-01T00:00:00Z', ...
                            'valid_range', [0 intmax])), ...
                    'AMSUB_LINE', struct(...
                        'type', 'short', ...
                        'atts', struct(...
                            'long_name', 'AMSU-B/MHS scanline number')), ...
                    'AMSUB_POS', struct(...
                        'type', 'byte', ...
                        'atts', struct(...
                            'long_name', 'AMSU-B/MHS scanline position')), ...
                    'AMSUB_LAT', struct(...
                        'type', 'float', ...
                        'atts', struct(...
                            'long_name', 'AMSU-B/MHS latitude', ...
                            'units', 'degrees_north', ...
                            'valid_range', [-90 90])), ...
                    'AMSUB_LONG', struct(...
                        'type', 'float', ...
                        'atts', struct(...
                            'long_name', 'AMSU-B/MHS longitude', ...
                            'units', 'degrees_east', ...
                            'valid_range', [-180 180])), ...
                    'AMSUB_BT', struct(...
                        'type', 'float', ...
                        'dims', {{'AMSUB_CHANS', 5}}, ...
                        'atts', struct(...
                            'long_name', 'AMSU-B/MHS Brightness Temperature', ...
                            'units', 'Kelvin')), ...
                    'AMSUA_LINE', struct(...
                        'type', 'short', ...
                        'atts', struct(...
                            'long_name', 'AMSU-A scanline number')), ...
                    'AMSUA_POS', struct(...
                        'type', 'byte', ...
                        'atts', struct(...
                            'long_name', 'AMSU-A scanline position')), ...
                    'AMSUA_LAT', struct(...
                        'type', 'float', ...
                        'atts', struct(...
                            'long_name', 'AMSU-A latitude', ...
                            'units', 'degrees_north', ...
                            'valid_range', [-90 90])), ...
                    'AMSUA_LONG', struct(...
                        'type', 'float', ...
                        'atts', struct(...
                            'long_name', 'AMSU-A longitude', ...
                            'units', 'degrees_east', ...
                            'valid_range', [-180 180])), ...
                    'AMSUA_BT', struct(...
                        'type', 'float', ...
                        'dims', {{'AMSUA_CHANS', 15}}, ...
                        'atts', struct(...
                            'long_name', 'AMSU-A Brightness Temperature', ...
                            'units', 'Kelvin')), ...
                    'HIRS_LINE', struct(...
                        'type', 'short', ...
                        'atts', struct(...
                            'long_name', 'HIRS scanline number', ...
                            'missing_value', 0)), ...
                    'HIRS_POS', struct(...
                        'type', 'byte', ...
                        'atts', struct(...
                            'long_name', 'HIRS scanline position', ...
                            'missing_value', 0)), ...
                    'HIRS_LAT', struct(...
                        'type', 'float', ...
                        'atts', struct(...
                            'long_name', 'HIRS latitude', ...
                            'units', 'degrees_north', ...
                            'valid_range', [-90 90], ...
                            'missing_value', -9999)), ...
                    'HIRS_LONG', struct(...
                        'type', 'float', ...
                        'atts', struct(...
                            'long_name', 'HIRS longitude', ...
                            'units', 'degrees_east', ...
                            'valid_range', [-180 180], ...
                            'missing_value', -9999)), ...
                    'HIRS_BT', struct(...
                        'type', 'float', ...
                        'dims', {{'HIRS_CHANS', 20}}, ...
                        'atts', struct(...
                            'long_name', 'HIRS Brightness Temperature', ...
                            'units', 'Kelvin', ...
                            'missing_value', -9999)), ...
                    'CPR_LINERANGE', struct(...
                        'type', 'int', ...
                        'dims', {{'CPR_RANGE', 2}}, ...
                        'atts', struct(...
                            'long_name', 'CloudSat CPR line range within granule')), ...
                    'MIN_DIST', struct(...
                        'type', 'float', ...
                        'atts', struct(...
                            'long_name', 'Shortest distance CPR to AMSU-B/MHS', ...
                            'units', 'km', ...
                            'valid_range', [0 15.02])), ...
                    'MAX_DIST', struct(...
                        'type', 'float', ...
                        'atts', struct(...
                            'long_name', 'Longest distance CPR to AMSU-B/MHS', ...
                            'units', 'km', ...
                            'valid_range', [0 15.02])), ...
                    'MIN_INT', struct(...
                        'type', 'short', ...
                        'atts', struct(...
                            'long_name', 'Shortest time-interval CPR to AMSU-B/MHS (absolute)', ...
                            'units', 'seconds', ...
                            'valid_range', [0 900])), ...
                    'MAX_INT', struct(...
                        'type', 'short', ...
                        'atts', struct(...
                            'long_name', 'Longest time-interval CPR to AMSU-B/MHS (absolute)', ...
                            'units', 'seconds', ...
                            'valid_range', [0 900]))));
                        
%% Pseudo fields (fields created by postprocessing)
% 

D = datasets();

fields = listOfDatasetsFields();

D.cprCloud.pseudo_fields.Cloud_Types                = fields.cpr.Cloud_Types;
D.cprCloud.pseudo_fields.Cloud_Types.dependencies   = fieldnames(fields.cpr.Cloud_Types.dependencies_struct)';
D.cprCloud.pseudo_fields.Cloud_Types_multiLayer                = fields.cpr.Cloud_Types_multiLayer;
D.cprCloud.pseudo_fields.Cloud_Types_multiLayer.dependencies   = fieldnames(fields.cpr.Cloud_Types_multiLayer.dependencies_struct)';
D.cprCloud.reader_processor                         = @cpr_postprocessor;

D.cprCloudLidar.pseudo_fields.Cloud_Types_Lidar                 = fields.cpr.Cloud_Types_Lidar;
D.cprCloudLidar.pseudo_fields.Cloud_Types_Lidar.dependencies    = fieldnames(fields.cpr.Cloud_Types_Lidar.dependencies_struct)';
D.cprCloudLidar.pseudo_fields.Cloud_Types_Lidar_multiLayer              = fields.cpr.Cloud_Types_Lidar_multiLayer;
D.cprCloudLidar.pseudo_fields.Cloud_Types_Lidar_multiLayer.dependencies = fieldnames(fields.cpr.Cloud_Types_Lidar_multiLayer.dependencies_struct)';
D.cprCloudLidar.reader_processor                                = @cpr_postprocessor;

D.cloud_cci.pseudo_fields.iwp                   = fields.cloud_cci.iwp;
D.cloud_cci.pseudo_fields.iwp.dependencies      = fieldnames(fields.cloud_cci.iwp.dependencies_struct)';
D.cloud_cci.pseudo_fields.iwp_error             = fields.cloud_cci.iwp_error;
D.cloud_cci.pseudo_fields.iwp_error.dependencies= fieldnames(fields.cloud_cci.iwp_error.dependencies_struct)';
D.cloud_cci.pseudo_fields.ref_ice               = fields.cloud_cci.ref_ice;
D.cloud_cci.pseudo_fields.ref_ice.dependencies  = fieldnames(fields.cloud_cci.ref_ice.dependencies_struct)';
D.cloud_cci.pseudo_fields.cot_ice               = fields.cloud_cci.cot_ice;
D.cloud_cci.pseudo_fields.cot_ice.dependencies  = fieldnames(fields.cloud_cci.cot_ice.dependencies_struct)';
D.cloud_cci.reader_processor                    = @cloud_cci_postprocessor;

D.modis_aqua_L2.pseudo_fields.modis_IWP             = fields.modis.modis_IWP;
D.modis_aqua_L2.pseudo_fields.modis_IWP.dependencies= fieldnames(fields.modis.modis_IWP.dependencies_struct)';
D.modis_aqua_L2.pseudo_fields.modis_IWP_uncertainty             = fields.modis.modis_IWP_uncertainty;
D.modis_aqua_L2.pseudo_fields.modis_IWP_uncertainty.dependencies= fieldnames(fields.modis.modis_IWP_uncertainty.dependencies_struct)';
D.modis_aqua_L2.pseudo_fields.Re_ice                = fields.modis.Re_ice;
D.modis_aqua_L2.pseudo_fields.Re_ice.dependencies   = fieldnames(fields.modis.Re_ice.dependencies_struct)';
D.modis_aqua_L2.pseudo_fields.Re_ice_uncertainty                = fields.modis.Re_ice_uncertainty;
D.modis_aqua_L2.pseudo_fields.Re_ice_uncertainty.dependencies   = fieldnames(fields.modis.Re_ice_uncertainty.dependencies_struct)';
D.modis_aqua_L2.pseudo_fields.Tau_ice               = fields.modis.Tau_ice;
D.modis_aqua_L2.pseudo_fields.Tau_ice.dependencies  = fieldnames(fields.modis.Tau_ice.dependencies_struct)';
D.modis_aqua_L2.pseudo_fields.Tau_ice_uncertainty               = fields.modis.Tau_ice_uncertainty;
D.modis_aqua_L2.pseudo_fields.Tau_ice_uncertainty.dependencies  = fieldnames(fields.modis.Tau_ice_uncertainty.dependencies_struct)';
D.modis_aqua_L2.reader_processor                    = @modis_postprocessor;

D.dardarsub.pseudo_fields.dardar_IWP              = fields.dardarsub.dardar_IWP;
D.dardarsub.pseudo_fields.dardar_IWP.dependencies = fieldnames(fields.dardarsub.dardar_IWP.dependencies_struct)';
D.dardarsub.pseudo_fields.dardar_ln_IWP_error              = fields.dardarsub.dardar_ln_IWP_error;
D.dardarsub.pseudo_fields.dardar_ln_IWP_error.dependencies = fieldnames(fields.dardarsub.dardar_ln_IWP_error.dependencies_struct)';
D.dardarsub.reader_processor = @dardarsub_postprocessor;

%% Collocated datasets (the core)
    
% MW datasets

CollocatedDataset(D.mhs, D.mhs, ...
    'name', 'collocation_mhs_mhs', ...
    'distance', 15, ...
    'interval', 900);

CollocatedDataset(D.mhs, D.amsub, ...
    'name', 'collocation_mhs_amsub', ...
    'distance', 15, ...
    'interval', 900);

CollocatedDataset(D.amsub, D.mhs, ...
    'name', 'collocation_amsub_mhs', ...
    'distance', 15, ...
    'interval', 900);

CollocatedDataset(D.amsub, D.amsub, ...
    'name', 'collocation_amsub_amsub', ...
    'distance', 15, ...
    'interval', 900);

CollocatedDataset(D.mhs, D.saphir_l1a2, ...
    'name', 'collocation_mhs_saphir', ...
    'distance', 15, ...
    'interval', 900);

CollocatedDataset(D.amsub, D.saphir_l1a2, ...
    'name', 'collocation_amsub_saphir', ...
    'distance', 15, ...
    'interval', 900);

CollocatedDataset(D.ssmt2, D.ssmt2, ...
    'name', 'collocation_ssmt2_ssmt2', ...
    'distance', 40, ...
    'interval', 900);

CollocatedDataset(D.ssmt2, D.mhs, ...
    'name', 'collocation_ssmt2_mhs', ...
    'distance', 40, ...
    'interval', 900);

CollocatedDataset(D.ssmt2, D.amsub, ...
    'name', 'collocation_ssmt2_amsub', ...
    'distance', 40, ...
    'interval', 900);

CollocatedDataset(D.gras_per_day, D.amsua, ...
    'name', 'collocation_gras_amsua', ...
    'distance', 150, ...
    'interval', 3600);

% NB: not intended to be stored, only used on-the-fly; storing will explode
% storage requirements, repeating each AVHRR footprint many times!
CollocatedDataset(D.mhs, D.avhrr, ...
    'name', 'collocation_mhs_avhrr', ...
    'distance', 15, ...
    'interval', 30, ...
    'gridsize', 0.2); % for sure very many collocations -> smaller gridsize.  Should consider special algorithm or different solution altogether

% CPR as reference

CollocatedDataset(D.avhrr_cmsaf_gac, D.cpr,...
    'name','CollocatedDataset_avhrrCMSAF_cpr', ...
    'distance', 5, ...
    'interval', 300);

CollocatedDataset(D.cmoiwp_v0_4, D.cpr,...
    'name','CollocatedDataset_cmoiwp_v0_4_cpr',...
    'distance', 15, ...
    'interval', 900);

CollocatedDataset(D.cmoiwp_v0_3, D.cpr,...
    'name','CollocatedDataset_cmoiwp_v0_3_cpr',...
    'distance', 15, ...
    'interval', 900);

% calipso is a 5km product and must therefore be the primary dataset
CollocatedDataset(D.calipso, D.cpr,...
    'name', 'CollocatedDataset_calipso_cpr', ...
    'distance', 5, ...
    'interval',300);

CollocatedDataset(D.cpr, D.modis_aqua_L2,...
    'name', 'CollocatedDataset_cpr_modis', ...
    'distance', 2, ...
    'interval', 120);

CollocatedDataset(D.cpr, D.dardarsub,...
    'name', 'CollocatedDataset_cpr_dardarsub', ...
    'distance', 1, ...
    'interval', 1); % these are always collocated

CollocatedDataset(D.mhs, D.cpr,...
    'name','CollocatedDataset_mhs_cpr',...
    'distance', 15, ...
    'interval', 900); %16.6m/s

CollocatedDataset(D.amsub, D.cpr, ...
    'name', 'CollocatedDataset_amsub_cpr', ...
    'distance', 15, ...
    'interval', 900);

CollocatedDataset(D.mspps, D.cpr,...
    'name', 'CollocatedDataset_mspps_cpr', ...
    'distance', 20, ...
    'interval', 1200); % assume 20m/s

CollocatedDataset(D.mirs, D.cpr,...
    'name', 'CollocatedDataset_mirs_cpr', ...
    'distance', 60, ...
    'interval', 3000);

CollocatedDataset(D.patmosx, D.cpr,...
    'name', 'CollocatedDataset_patmosx_cpr', ...
    'distance', 8, ...
    'interval', 480);

% DARDAR as reference

CollocatedDataset(D.avhrr_cmsaf_gac, D.dardarsub,...
    'name','CollocatedDataset_avhrrCMSAF_dardarsub', ...
    'distance', 5, ...
    'interval', 300);

% calipso is a 5km product and must therefore be the primary dataset
CollocatedDataset(D.calipso, D.dardarsub,...
    'name', 'CollocatedDataset_calipso_dardarsub', ...
    'distance', 5, ...
    'interval',180);

CollocatedDataset(D.cmoiwp_v0_6, D.dardarsub,...
    'name','CollocatedDataset_cmoiwp_v0_6_dardarsub',...
    'distance', 15, ...
    'interval', 900);

CollocatedDataset(D.cloud_cci, D.dardarsub,...
    'name','CollocatedDataset_cloud_cci_dardarsub',...
    'distance', 2, ...
    'interval', 120); % same limits as for MODIS for better comparison of like-datasets

CollocatedDataset(D.cmoiwp_v0_4, D.dardarsub,...
    'name','CollocatedDataset_cmoiwp_v0_4_dardarsub',...
    'distance', 15, ...
    'interval', 900);


CollocatedDataset(D.dardarsub, D.modis_aqua_L2,...
    'name', 'CollocatedDataset_dardarsub_modis', ...
    'distance', 2, ...
    'interval', 120);

CollocatedDataset(D.hirs, D.dardarsub,...
    'name', 'CollocatedDataset_hirs_dardarsub', ...
    'distance', 15, ...
    'interval', 900);

CollocatedDataset(D.mhs, D.dardarsub,...
    'name', 'CollocatedDataset_mhs_dardarsub', ...
    'distance', 15, ...
    'interval', 900);

CollocatedDataset(D.mspps, D.dardarsub,...
    'name', 'CollocatedDataset_mspps_dardarsub', ...
    'distance', 15, ...
    'interval', 900);

CollocatedDataset(D.mirs, D.dardarsub,...
    'name', 'CollocatedDataset_mirs_dardarsub', ...
    'distance', 50, ...
    'interval', 3000);

CollocatedDataset(D.patmosx, D.dardarsub,...
    'name', 'CollocatedDataset_patmosx_dardarsub', ...
    'distance', 8, ...
    'interval', 480);

% ---------------------------------
% Collocated collocated datasets
% ---------------------------------

CollocatedDataset(D.CollocatedDataset_dardarsub_modis,D.cprCloud,...
    'name', 'CollocatedDataset_dardarsub_modis_cprCloud', ...
    'distance', 1,...
    'interval', 1);

CollocatedDataset(D.CollocatedDataset_dardarsub_modis,D.cprCloudLidar,...
    'name', 'CollocatedDataset_dardarsub_modis_cprCloudLidar', ...
    'distance', 1,...
    'interval', 1);

% NB: one collocated dataset uses a collapser as a reference and follows
% further down

%% AssociatedDatasets (FieldCopier, Collapser, etc.)
 
% ------
% POES
% ------

poes_cpr_selection = getSelection(fields.cpr, ...
                 {'ROIWP', 'dROIWP', 'IOROIWP', 'dIOROIWP', ...
                  'IWP_2C', 'dardar_IWP', 'dardar_ln_IWP_error', ...
                  'RO_liq_water_path', 'LO_RO_liquid_water_path', ...
                  'ECMWF_Surface_pressure', ...
                  'ECMWF_Skin_temperature', 'ECMWF_Temperature_2m', ...
                  'ECMWF_elevation'});
% not including due to memory: 'ECMWF_Pressure', 'ECMWF_Specific_humidity', 

AssociatedPOESPlusCPR(D.CollocatedDataset_mhs_cpr, fields.mhs, fields.amsua, fields.hirs, ...
    poes_cpr_selection, 'name', 'associated_CPR_MHS_AMSU_HIRS');

AssociatedPOESPlusCPR(D.CollocatedDataset_amsub_cpr, fields.amsub, fields.amsua, fields.hirs, ...
    poes_cpr_selection, 'name', 'associated_CPR_AMSUB_AMSUA_HIRS');

% -----------------------
% define FieldCopiers 
% -----------------------

FieldCopier(D.collocation_mhs_mhs, fields.mhs1, fields.mhs2, ...
    'name', 'associated_mhs_mhs');

FieldCopier(D.collocation_mhs_amsub, fields.mhs1, fields.amsub2, ...
    'name', 'associated_mhs_amsub');

FieldCopier(D.collocation_amsub_mhs, fields.amsub1, fields.mhs2, ...
    'name', 'associated_amsub_mhs');

FieldCopier(D.collocation_amsub_amsub, fields.amsub1, fields.amsub2, ...
    'name', 'associated_amsub_amsub');

FieldCopier(D.collocation_mhs_saphir, fields.mhs, fields.saphir, ...
    'name', 'associated_mhs_saphir');

FieldCopier(D.collocation_amsub_saphir, fields.amsub, fields.saphir, ...
    'name', 'associated_amsub_saphir');

FieldCopier(D.collocation_ssmt2_mhs, fields.ssmt2, fields.mhs, ...
    'name', 'associated_ssmt2_mhs');

FieldCopier(D.collocation_ssmt2_amsub, fields.ssmt2, fields.amsub, ...
    'name', 'associated_ssmt2_amsub');

FieldCopier(D.collocation_ssmt2_mhs, fields.ssmt2_1, fields.ssmt2_2, ...
    'name', 'associated_ssmt2_ssmt2');

FieldCopier(D.collocation_gras_amsua, fields.gras, fields.amsua, ...
    'name', 'associated_gras_amsua');

FieldCopier(D.CollocatedDataset_cloud_cci_dardarsub, ...
    getSelection(fields.cloud_cci,{'iwp','iwp_error','ref_ice','ref_uncertainty','cot_ice','cot_uncertainty'}),...
     getSelection(fields.dardarsub,{'dardar_IWP','dardar_ln_IWP_error','dardar_Re'}),...
     'name','cloud_cci_dardarsub_ice_clouds');

FieldCopier(D.CollocatedDataset_cpr_dardarsub, ...
    getSelection(fields.cpr,{'Cloud_Types'}),struct(),...
    'name','cpr_dardarsub_cloudTypes');

FieldCopier(D.CollocatedDataset_cpr_dardarsub, ...
    getSelection(fields.cpr,{'IWP_2C'}),getSelection(fields.dardarsub,{'dardar_ln_IWP_error','dardar_IWP'}),...
    'name','fields_2C_ice_dardarsub');

FieldCopier(D.CollocatedDataset_cpr_dardarsub, ...
    getSelection(fields.cpr,{'RO_liq_water_path'}),struct(),...
    'name','fields_CPR_LWP_added_to_dardar');

FieldCopier(D.CollocatedDataset_cpr_dardarsub, ...
    struct(),getSelection(fields.dardarsub,{'dardar_IWP',}),...
    'name','cpr_dardarsub_IWP');

FieldCopier(D.CollocatedDataset_dardarsub_modis, ...
    getSelection(fields.dardarsub,{'dardar_IWP','dardar_ln_IWP_error'}),...
    getSelection(fields.modis,{'modis_IWP','Re_ice','Tau_ice'}),...
    'name','dardarsub_modis_IWP'); % this will be deprecated when 'dardarsub_modis_ice_clouds' is fully run

FieldCopier(D.CollocatedDataset_dardarsub_modis, ...
    getSelection(fields.dardarsub,{'dardar_IWP','dardar_ln_IWP_error'}),...
    getSelection(fields.modis,{'modis_IWP','modis_IWP_uncertainty','Re_ice','Tau_ice'}),...
    'name','dardarsub_modis_ice_clouds'); % this will be deprecated

FieldCopier(D.CollocatedDataset_mhs_dardarsub, ...
    getSelection(fields.mhs,{'B_LZA','B_BT'}),...
    getSelection(fields.dardarsub,{'iwc'}),...
    'name','mhs_dardarsub');
                              
FieldCopier(D.CollocatedDataset_hirs_dardarsub, ...
    getSelection(fields.hirs,{'H_LZA','H_BT'}),...
    getSelection(fields.dardarsub,{'iwc'}),...
    'name','hirs_dardarsub');

% NB: do not try to store, too large
FieldCopier(D.collocation_mhs_avhrr, ...
    getfields(fields.mhs, 'B_BT', 'B_LZA', 'B_LAA', 'B_SZA', 'B_SAA'), ...
    getfields(fields.avhrr, 'AVHRR_Y', 'AVHRR_FLAG_3AB'), ...
    'name', 'associated_mhs_avhrr');

% ----------------------------
% FieldCopiers for collocated collocated datasets
% ----------------------------

FieldCopier(D.CollocatedDataset_dardarsub_modis_cprCloud,...
     D.dardarsub_modis_IWP.members, getSelection(fields.cpr,{'Cloud_Types'}),...
    'name','dardarsub_modis_cprCloud');

FieldCopier(D.CollocatedDataset_dardarsub_modis_cprCloudLidar, ...
    getSelection(D.dardarsub_modis_IWP.members,{'dardar_IWP','modis_IWP'}),getSelection(fields.cpr,{'Cloud_Types_Lidar_multiLayer','CloudPhase'}),...
    'name','dardarsub_modis_cprCloudLidar');

% -----------------------
% Collapser datasets
% -----------------------


% LIMITERS
limitators_scalar = {@(X)(X>=0)}; % meaning not flagged
%limitators_scalar_vectorised = {@(x)x};
limitators_profile = {@(X)(true(size(X, 1), 1))};
%limitators_profile_vectorised = {@(x)true(size(X))};
closest.fn = @(x, ~)(x(1)); %workaround, see this collapser
closest.ln = 'Only the closest measurement pair';
% ----------
% MHS -CPR
% ----------
%mw_global = {@(X)(X(:, D.CollocatedDataset_mhs_cpr.cols.DIST)<7.5), ...
%               @(X)(abs(X(:, D.CollocatedDataset_mhs_cpr.cols.INT))<600)};
mw_global_vec = {{{'DIST'}, @(X)(X<7.5)}, ...
                 {{'INT'}, @(X)(abs(X)<600)}};

% FIXME: put those back after bugfix
cpr_iwp_fields = vec2row({'ROIWP', 'IOROIWP', 'IWP_2C', 'dardar_IWP', 'RO_liq_water_path', 'LO_RO_liquid_water_path'});
%cpr_ecmwf_prof_fields = vec2row({'ECMWF_Temperature', 'ECMWF_Pressure', 'ECMWF_Specific_humidity'});
%cpr_ecmwf_prof_fields = vec2row({'ECMWF_Temperature'});
cpr_ecmwf_prof_fields = {};
cpr_ecmwf_scal_fields = vec2row({'ECMWF_Surface_pressure', 'ECMWF_Skin_temperature', 'ECMWF_Temperature_2m', 'ECMWF_elevation'});
for cprf = vec2row(union(cpr_iwp_fields, union(cpr_ecmwf_prof_fields, cpr_ecmwf_scal_fields)))
    f = cprf{1};
    appccs.(f).limitators = limitators_scalar;
    if ismember(f, union(cpr_iwp_fields, cpr_ecmwf_scal_fields))
        appccs.(f).limitators = limitators_scalar;

        %len = @length;
        len_vec = @(X, ~)(vec2col(sum(~isnan(X), 1)));
        %mn = @mean;        
        mn_vec = @(X, ~)(vec2col(nanmean(X, 1)));
        %st = @std;
        st_vec = @(X, ~)(vec2col(nanstd(X, 0, 1)));
        %cv = @(X)(std(X) ./ mean(X));
    elseif ismember(f, cpr_ecmwf_prof_fields)
        appccs.(f).limitators = limitators_profile;
        len = @(X, ~)(size(X, 1));
        len_vec = len;
        mn = @(X, ~)(mean(X, 1));
        mn_vec = mn;
        st = @(X, ~)(std(X, 0, 1));
        st_vec = st;
        %cv = @(X)(std(X, 0, 1) ./ mean(X, 1));
    end
    
    appccs.(f).processors.NO = len_vec;
    appccs.(f).stored.NO.type = 'short';
    appccs.(f).stored.NO.atts.long_name = 'Number of CloudSat footprints used for statistics inside AMSU-B/MHS';
    appccs.(f).stored.NO.atts.missing_value = 0;
    appccs.(f).processors.MEAN = mn_vec;
    appccs.(f).stored.MEAN.type = 'float';
    appccs.(f).stored.MEAN.atts.long_name = ['MHS-averaged ' fields.cpr.(f).atts.long_name];
    appccs.(f).stored.MEAN.atts.units = fields.cpr.(f).atts.units;
    appccs.(f).stored.MEAN.atts.missing_value = -1;
    appccs.(f).processors.STD = st_vec;
    appccs.(f).stored.STD.type = 'float';
    appccs.(f).stored.STD.atts.long_name = ['CPR-in-MHS standard deviation for ' fields.cpr.(f).atts.long_name];
    appccs.(f).stored.STD.atts.units = fields.cpr.(f).atts.units;
    appccs.(f).stored.STD.atts.missing_value = -1;
%     appccs.(f).processors.CV = cv;
%     appccs.(f).stored.CV.type = 'float';
%     appccs.(f).stored.CV.atts.long_name = ['Coefficient of variation of CPR ' fields.cpr.(f).atts.long_name];
%     appccs.(f).stored.CV.atts.missing_value = 0;
    
    if ismember(f, cpr_iwp_fields)
        for iwp = [1, 10, 40, 1000]
            fn = sprintf('FRAC%d', iwp);
            %appccs.(f).processors.(fn) = @(X)(sum(X>=iwp) / length(X));
            appccs.(f).processors.(fn) = @(X, ~)vec2col(sum(X>=iwp, 1) ./ sum(~isnan(X), 1));
            appccs.(f).stored.(fn).type = 'float';
            appccs.(f).stored.(fn).atts.long_name = sprintf('Cloud fraction according to %s >= %d %s', ...
                fields.cpr.(f).atts.long_name, iwp, fields.cpr.(f).atts.units);
            appccs.(f).stored.(fn).atts.missing_value = -1;
        end
    end
end
%appccs.ECMWF_Temperature.stored.NO.profile = false;

%appccs.ROIWP.limitators = limitators; % not flagged
%appccs.ROIWP.processors.NO = @length;
%appccs.ROIWP.stored.NO.type = 'int';
%appccs.ROIWP.stored.NO.atts.long_name = 'Number of CloudSat footprints used for statistics inside AMSU-B/MHS';
%appccs.ROIWP.processors.MEAN = @mean;
%appccs.ROIWP.stored.MEAN.type = 'float';
%appccs.ROIWP.stored.MEAN.atts.long_name = ['MHS-averaged ' fields.cpr.ROIWP.atts.long_name];
%appccs.ROIWP.stored.MEAN.atts.units = fields.cpr.ROIWP.atts.units;
%appccs.ROIWP.processors.STD = @std;
%appccs.ROIWP.stored.STD.type = 'float';
%appccs.ROIWP.stored.STD.atts.long_name = ['CPR-in-MHS standard deviation for ' fields.cpr.ROIWP.atts.long_name];
%appccs.ROIWP.stored.STD.atts.units = fields.cpr.ROIWP.atts.units;
%appccs.ROIWP.processors.CV = @(X)(std(X) ./ mean(X));
%appccs.ROIWP.stored.CV.type = 'int';
%appccs.ROIWP.stored.CV.atts.long_name = ['Coefficient of variation of CPR ' fields.cpr.ROIWP.atts.long_name];
%appccs.ROIWP.stored.CV.atts.missing_value = 0;
%
%for iwp = [1 10 100 1000]
%    fn = sprintf('FRAC%d', iwp);
%    appccs.ROIWP.processors.(fn) = @(X)(sum(X>=iwp) / length(X));
%    appccs.ROIWP.stored.(fn).type = 'float';
%    appccs.ROIWP.stored.(fn).atts.long_name = sprintf('Cloud fraction according to %s >= %d %s', ...
%        fields.cpr.ROIWP.atts.long_name, iwp, fields.cpr.ROIWP.atts.units);
%end

% -------
% cloud_cci
% -------
cloud_cci_global = {@(X)(X(:,D.CollocatedDataset_cloud_cci_dardarsub.cols.DIST)==min(X(:,D.CollocatedDataset_cloud_cci_dardarsub.cols.DIST)))};
vars = {'iwp','iwp_error','ref_ice','cot_ice'};
for V = vars
    cloud_cci.(V{1}).atts = fields.cloud_cci.(V{1}).atts;
    cloud_cci.(V{1}).processors.CLOSEST = closest.fn;
    cloud_cci.(V{1}).stored.CLOSEST.atts = fields.cloud_cci.(V{1}).atts;
    cloud_cci.(V{1}).stored.CLOSEST.atts.long_name  = [V{1} ': ' closest.ln];
    cloud_cci.(V{1}).stored.CLOSEST.type = D.cloud_cci.pseudo_fields.(V{1}).type;
    cloud_cci.(V{1}).limitators = limitators_scalar;
end

% Collapsed MODIS (will be depricated)
% ----------
modis_global = {@(X)(X(:,D.CollocatedDataset_dardarsub_modis.cols.DIST)==min(X(:,D.CollocatedDataset_dardarsub_modis.cols.DIST)))};
vars={'modis_IWP','Re_ice','Tau_ice'};
for V = vars
    modis.(V{1}).atts = fields.modis.(V{1}).atts;
    modis.(V{1}).processors.CLOSEST = closest.fn;
    modis.(V{1}).stored.CLOSEST.atts = fields.modis.(V{1}).atts;
    modis.(V{1}).stored.CLOSEST.atts.long_name  = [V{1} ': ' closest.ln];
    modis.(V{1}).stored.CLOSEST.type = D.modis_aqua_L2.pseudo_fields.(V{1}).type;
    modis.(V{1}).limitators = limitators_scalar;
end

% ----------
% Collapsed MODIS

additionalvars={'modis_IWP_uncertainty','Cloud_Multi_Layer_Flag','modis_IWP','Re_ice','Tau_ice'};
for V = additionalvars
    modis2.(V{1}).atts = fields.modis.(V{1}).atts;
    modis2.(V{1}).processors.CLOSEST = closest.fn;
    modis2.(V{1}).stored.CLOSEST.atts = fields.modis.(V{1}).atts;
    modis2.(V{1}).stored.CLOSEST.atts.long_name  = [V{1} ': ' closest.ln];
    modis2.(V{1}).stored.CLOSEST.type = fields.modis.(V{1}).type;
    modis2.(V{1}).limitators = limitators_scalar;
end

% -------
% amsua over gras
% -------

amsua_global_lim =  {@(X)(X(:, D.collocation_gras_amsua.cols.DIST)<100), ...
                 @(X)(abs(X(:, D.collocation_gras_amsua.cols.INT))<3600)};

            
% comment out, because I have no good way to handle the case where some
% channels are flagged but others are not; I don't want to skip an entire
% primary footprint because ONE of the channels is flagged, but I still
% need a value for each channel; handle this in the processors instead
%capsed_amsua.A_BT.limitators = limitators_scalar;
capsed_amsua.A_BT.processors.NO = @(X, ~)(sum(X>0, 1));
capsed_amsua.A_BT.stored.NO.type = 'int';
capsed_amsua.A_BT.stored.NO.atts.long_name = 'Number of AMSU-A used for stats within GRAS';
capsed_amsua.A_BT.stored.NO.atts.valid_min = 0;
%capsed_amsua.A_BT.stored.NO.profile = false;
capsed_amsua.A_BT.processors.MEAN = @(X, ~)(ignoreNeG(X, @mean, 1));
capsed_amsua.A_BT.stored.MEAN.type = 'float';
capsed_amsua.A_BT.stored.MEAN.atts.units = fields.amsua.A_BT.atts.units;
capsed_amsua.A_BT.stored.MEAN.atts.long_name = ['Mean ' fields.amsua.A_BT.atts.long_name];
capsed_amsua.A_BT.stored.MEAN.atts.valid_range = [200, 350];
capsed_amsua.A_BT.stored.MEAN.atts.missing_value = -9999;
capsed_amsua.A_BT.processors.STD = @(X, ~)(ignoreNeG(X, @std, 1));
capsed_amsua.A_BT.stored.STD.type = 'float';
capsed_amsua.A_BT.stored.STD.atts.units = fields.amsua.A_BT.atts.units;
capsed_amsua.A_BT.stored.STD.atts.long_name = ['Std. of ' fields.amsua.A_BT.atts.long_name];
capsed_amsua.A_BT.stored.STD.atts.valid_min = 0;
capsed_amsua.A_BT.stored.STD.atts.missing_value = -9999;
%capsed_amsua.A_BT.limitators.CLOSEST = {@(X)(X(:, D.collocation_gras_amsua.cols.DIST)==min(X(:, D.collocation_gras_amsua.cols.DIST)))};
capsed_amsua.A_BT.processors.CLOSEST = @(X, Y)(flagneg(X(Y(:, D.collocation_gras_amsua.cols.DIST)==min(Y(:, D.collocation_gras_amsua.cols.DIST)), :)));
%capsed_amsua.A_BT.processors.CLOSEST = @closest_nonneg;
capsed_amsua.A_BT.stored.CLOSEST.type = 'float';
capsed_amsua.A_BT.stored.CLOSEST.atts.units = fields.amsua.A_BT.atts.units;
capsed_amsua.A_BT.stored.CLOSEST.atts.long_name = ['Closest ' fields.amsua.A_BT.atts.long_name];
capsed_amsua.A_BT.stored.CLOSEST.atts.valid_range = capsed_amsua.A_BT.stored.MEAN.atts.valid_range;
capsed_amsua.A_BT.stored.CLOSEST.atts.missing_value = capsed_amsua.A_BT.stored.MEAN.atts.missing_value;
% FIXME: this one for use in gras/amsua.  Does not work yet.
% capsed_amsua.LAT2.incore = true;
% capsed_amsua.LAT2.processors.CLOSEST = capsed_amsua.A_BT.processors.CLOSEST;
% capsed_amsua.LAT2.stored.CLOSEST.type = D.collocation_gras_amsua.members.LAT2.type;
% capsed_amsua.LAT2.stored.CLOSEST.atts.units = D.collocation_gras_amsua.members.LAT2.atts.units;
% capsed_amsua.LAT2.stored.CLOSEST.atts.long_name = ['Closest ' D.collocation_gras_amsua.members.LAT2.atts.long_name];
% capsed_amsua.LAT2.stored.CLOSEST.atts.valid_range = D.collocation_gras_amsua.members.LAT2.atts.valid_range;
% capsed_amsua.LAT2.stored.CLOSEST.atts.missing_value = -9999;
% capsed_amsua.LON2.incore = true;
% capsed_amsua.LON2.processors.CLOSEST = capsed_amsua.A_BT.processors.CLOSEST;
% capsed_amsua.LON2.stored.CLOSEST.type = D.collocation_gras_amsua.members.LON2.type;
% capsed_amsua.LON2.stored.CLOSEST.atts.units = D.collocation_gras_amsua.members.LON2.atts.units;
% capsed_amsua.LON2.stored.CLOSEST.atts.long_name = ['Closest ' D.collocation_gras_amsua.members.LON2.atts.long_name];
% capsed_amsua.LON2.stored.CLOSEST.atts.valid_range = D.collocation_gras_amsua.members.LON2.atts.valid_range;
% capsed_amsua.LON2.stored.CLOSEST.atts.missing_value = -9999;

% ------
% avhrr
% ------

%avhrr_capsed.AVHRR_Y.processors.NO = @(X)(size(X, 1));
avhrr_capsed.AVHRR_Y.processors.NO = @(X, ~)(vec2col(par(sum(~isnan(X), 1), ':', ':', 3)));
avhrr_capsed.AVHRR_Y.stored.NO.type = 'short';
avhrr_capsed.AVHRR_Y.stored.NO.atts.long_name = 'Number of AVHRR footprints used for statistics inside AMSU-B/MHS';
avhrr_capsed.AVHRR_Y.stored.NO.atts.missing_value = 0;
avhrr_capsed.AVHRR_Y.stored.NO.profile = false;
%avhrr_capsed.AVHRR_Y.processors.MEAN = @(X)(mean(X, 1));
avhrr_capsed.AVHRR_Y.processors.MEAN = @(X, ~)(squeeze(nanmean(X, 1)));
avhrr_capsed.AVHRR_Y.stored.MEAN.type = 'float';
avhrr_capsed.AVHRR_Y.stored.MEAN.atts.long_name = 'MHS-averaged AVHRR BT';
avhrr_capsed.AVHRR_Y.stored.MEAN.atts.units = 'albedo or BT';
avhrr_capsed.AVHRR_Y.stored.MEAN.atts.missing_value = -1;
%avhrr_capsed.AVHRR_Y.processors.STD = @(X)(std(X, 0, 1));
avhrr_capsed.AVHRR_Y.processors.STD = @(X, ~)(squeeze(nanstd(X, 0, 1)));
avhrr_capsed.AVHRR_Y.stored.STD.type = 'float';
avhrr_capsed.AVHRR_Y.stored.STD.atts.long_name = 'AVHRR-in-MHS standard deviation';
avhrr_capsed.AVHRR_Y.stored.STD.atts.units = avhrr_capsed.AVHRR_Y.stored.MEAN.atts.units;
avhrr_capsed.AVHRR_Y.stored.STD.atts.missing_value = -1;
% avhrr_capsed.AVHRR_Y.processors.CV = @(X)(std(X, 0, 1) ./ mean(X, 1));
% avhrr_capsed.AVHRR_Y.stored.CV.type = 'float';
% avhrr_capsed.AVHRR_Y.stored.CV.atts.long_name = 'Coefficient of variation of AVHRR in MHS';
% avhrr_capsed.AVHRR_Y.stored.CV.atts.missing_value = 0;
% avhrr_capsed.AVHRR_FLAG_3AB.processors.MEAN = mn;
avhrr_capsed.AVHRR_FLAG_3AB.processors.MEAN = @(X, ~)vec2col(nanmean(X, 1));
avhrr_capsed.AVHRR_FLAG_3AB.stored.MEAN.type = 'float';
avhrr_capsed.AVHRR_FLAG_3AB.stored.MEAN.atts.long_name = 'MHS-averaged AVHRR BT';
avhrr_capsed.AVHRR_FLAG_3AB.stored.MEAN.atts.units = 'albedo or BT';
avhrr_capsed.AVHRR_FLAG_3AB.stored.MEAN.atts.missing_value = -1;
    

% -------------------
% COLLAPSED DATASETS
% --------------------

Collapser(D.associated_CPR_MHS_AMSU_HIRS, appccs, mw_global_vec, ...
    'name', 'collapsed_associated_CPR_MHS_AMSU_HIRS', ...
    'vectorised', true);

Collapser(D.associated_CPR_AMSUB_AMSUA_HIRS, appccs, mw_global_vec, ...
    'name', 'collapsed_associated_CPR_AMSUB_AMSUA_HIRS', ...
    'vectorised', true);

Collapser(D.dardarsub_modis_IWP,modis,modis_global, ...
    'name','dardarsub_modis_collapsedIWP'); % will be depricated by 'dardarsub_modis_closest_ice_clouds' in the future
 

Collapser(D.dardarsub_modis_ice_clouds,modis2,modis_global, ...
    'name','dardarsub_modis_closest_ice_clouds');

Collapser(D.dardarsub_modis_cprCloudLidar,getSelection(modis2,'modis_IWP'),modis_global, ...
    'name','dardarsub_modis_cprCloudLidar_closest');

Collapser(D.cloud_cci_dardarsub_ice_clouds,cloud_cci,cloud_cci_global, ...
    'name','cloud_cci_dardarsub_closest_ice_clouds');

Collapser(D.associated_gras_amsua, capsed_amsua, amsua_global_lim, ...
    'name', 'collapsed_gras_amsua');

Collapser(D.associated_mhs_avhrr, avhrr_capsed, ...
    {{{'DIST'}, @(X)(X<7.5)}, ...
     {{'INT'}, @(X)(abs(X)<60)}}, ...
     'vectorised', true, ...
     'name', 'collapsed_mhs_avhrr');

% this one uses some subfunctions, so is defined in its own file
define_c2dp('mhs');
define_c2dp('amsub');

%% CollocatedDatasets (and their AssociatedDatasets) depending on Collapsers

% name 'cacmah' short for collapsed_associated_CPR_MHS_AMSU_HIRS

CollocatedDataset(...
    D.collapsed_associated_CPR_MHS_AMSU_HIRS, ...
    D.avhrr, ...
    'name', 'Collocated_cacmah_avhrr', ...
    'distance', 10, ...
    'interval', 30);

% for fields, I want ROIWP_NO, ROIWP_MEAN, ...

% fields for fieldcopier cacmah avhrr, defined here because relies on other
% things defined in this namespace
%
% In this fieldcopier, I have:
% - fields from CollocatedDataset_mhs_cpr
% - fields from associated_CPR_MHS_AMSU_HIRS
% - fields from collapser
% total 73 fields!

fc1 = catstruct(...
        struct(...
            'MHS_START', D.CollocatedDataset_mhs_cpr.members.START1, ...
            'MHS_LINE', D.CollocatedDataset_mhs_cpr.members.LINE1, ...
            'MHS_POS', D.CollocatedDataset_mhs_cpr.members.POS1, ...
            'MHS_TIME', D.CollocatedDataset_mhs_cpr.members.TIME1, ...
            'MHS_LAT', D.CollocatedDataset_mhs_cpr.members.LAT1, ...
            'MHS_LON', D.CollocatedDataset_mhs_cpr.members.LON1), ...
        getfields(mem2fc(D.associated_CPR_MHS_AMSU_HIRS.members), ...
                  'B_LZA', 'B_LAA', 'B_SZA', 'B_SAA', 'B_BT', 'A_LONG', ...
                  'A_LAT', 'A_BT', 'A_POS', 'A_LINE', 'H_LONG', 'H_LAT', 'H_BT', 'H_POS', 'H_LINE'), ...
        collapsed2fc(appccs));

fc1.MHS_START.realname = 'START1';
fc1.MHS_LINE.realname = 'LINE1';
fc1.MHS_POS.realname = 'POS1';
fc1.MHS_TIME.realname = 'TIME1';
fc1.MHS_LAT.realname = 'LAT1';
fc1.MHS_LON.realname = 'LON1';

% FIXME: more from fc2?
fc2 = getfields(fields.avhrr, 'AVHRR_Y', 'AVHRR_FLAG_3AB');

FieldCopier(...
    D.Collocated_cacmah_avhrr, ...
    fc1, fc2, 'name', 'associated_cacmah_avhrr');
    
Collapser(D.associated_cacmah_avhrr, avhrr_capsed, mw_global_vec, ...
    'name', 'collapsed_cacmah_avhrr', ...
    'vectorised', true);
    

%% 
defined = true;
logtext(atmlab('OUT'), 'Datasets defined. Everything seems fine.\n');

end

function fields = listOfDatasetsFields()
%% listOfDatasetsFields
%
% Purpose: List fields belonging to satDatasets in here. This fields are to be
% used in the fieldCopiers

D = datasets();

%% helpers for AssociatedDataset definitions

sza.type = 'float';
sza.realname = 'sza';
sza.atts.long_name = 'Solar zenith angle';
sza.atts.units = 'degrees';
sza.atts.valid_range = [0 180];

saa.type = 'float';
saa.realname = 'saa';
saa.atts.long_name = 'Solar azimuth angle';
saa.atts.units = 'degrees';
saa.atts.valid_range = [0 360];

lza.type = 'float';
lza.realname = 'lza';
lza.atts.long_name = 'Local zenith angle';
lza.atts.units = 'degrees';
lza.atts.valid_range = [0 180];
lza.atts.missing_value = -9999;

laa.type = 'float';
laa.realname = 'laa';
laa.atts.long_name = 'Local azimuth angle';
laa.atts.units = 'degrees';
laa.atts.valid_range = [0 360];
laa.atts.missing_value = -9999;

%% Fields for datasets

%% AMSU-A
fields.amsua.A_LONG.type = 'float';
fields.amsua.A_LONG.realname = 'lon';
fields.amsua.A_LONG.atts.long_name = 'AMSU-A Longitude';
fields.amsua.A_LONG.atts.units = 'degrees_east';
fields.amsua.A_LONG.atts.valid_range = [-180 180];
fields.amsua.A_LAT.type = 'float';
fields.amsua.A_LAT.realname = 'lat';
fields.amsua.A_LAT.atts.long_name = 'AMSU-A Latitude';
fields.amsua.A_LAT.atts.units = 'degrees_north';
fields.amsua.A_LAT.atts.valid_range = [-90 90];
fields.amsua.A_TIME.type = 'int';
fields.amsua.A_TIME.realname = 'time';
fields.amsua.A_TIME.atts.long_name = 'AMSU-A measurement time';
fields.amsua.A_TIME.atts.units = 'seconds since 1970-01-01 00:00:00';
fields.amsua.A_LZA = lza;
fields.amsua.A_LAA = laa;
fields.amsua.A_SAA = saa;
fields.amsua.A_SZA = sza;
fields.amsua.A_BT.type = 'float';
fields.amsua.A_BT.realname = 'tb';
fields.amsua.A_BT.dims = {'AMSUA_CHANS', 15};
fields.amsua.A_BT.atts.long_name = 'AMSU-A Brightness Temperature';
fields.amsua.A_BT.atts.units = 'Kelvin';
fields.amsua.A_BT.atts.missing_value = -9999;
fields.amsua.A_LINE.type = 'int';
fields.amsua.A_LINE.realname = 'scanline_number';
fields.amsua.A_LINE.atts.long_name = 'AMSU-A scanline number';
fields.amsua.A_LINE.atts.valid_min = 1;
fields.amsua.A_POS.type = 'byte';
fields.amsua.A_POS.realname = 'scanline_position';
fields.amsua.A_POS.atts.long_name = 'AMSU-A scanline position';
fields.amsua.A_POS.atts.valid_range = [1 30];
fields.amsua.A_ELEV.type = 'int';
fields.amsua.A_ELEV.realname = 'elev';
fields.amsua.A_ELEV.atts.long_name = 'AMSU-A satellite elevation';
fields.amsua.A_ELEV.atts.units = 'km';
fields.amsua.A_ELEV.atts.valid_min = 0;
fields.amsua.A_SATLAT.type = 'float';
fields.amsua.A_SATLAT.realname = 'satlat';
fields.amsua.A_SATLAT.atts.long_name = 'AMSU-A satellite latitude';
fields.amusa.A_SATLAT.atts.units = 'degrees_north';
fields.amsua.A_SATLAT.atts.valid_range = [-90, 90];
fields.amsua.A_SATLON.type = 'float';
fields.amsua.A_SATLON.realname = 'satlon';
fields.amsua.A_SATLON.atts.long_name = 'AMSU-A satellite longitude';
fields.amusa.A_SATLON.atts.units = 'degrees_east';
fields.amsua.A_SATLON.atts.valid_range = [-180, 180];

%% AMSU-B
fields.amsub.B_LZA = lza;
fields.amsub.B_LAA = laa;
fields.amsub.B_SZA = sza;
fields.amsub.B_SAA = saa;
fields.amsub.B_BT.type = 'float';
fields.amsub.B_BT.realname = 'tb';
fields.amsub.B_BT.dims = {'AMSUB_CHANS', 5};
fields.amsub.B_BT.atts.long_name = 'AMSU-B Brightness Temperature';
fields.amsub.B_BT.atts.units = 'Kelvin';

fields.amsub1.LZA1 = lza;
fields.amsub1.LAA1 = laa;
fields.amsub1.SZA1 = sza;
fields.amsub1.SAA1 = saa;
fields.amsub1.BT1.type = 'float';
fields.amsub1.BT1.realname = 'tb';
fields.amsub1.BT1.dims = {'AMSUB_CHANS', 5};
fields.amsub1.BT1.atts.long_name = 'AMSU-B Brightness Temperature, primary';
fields.amsub1.BT1.atts.units = 'Kelvin';

fields.amsub2.LZA2 = lza;
fields.amsub2.LAA2 = laa;
fields.amsub2.SZA2 = sza;
fields.amsub2.SAA2 = saa;
fields.amsub2.BT2.type = 'float';
fields.amsub2.BT2.realname = 'tb';
fields.amsub2.BT2.dims = {'AMSUB_CHANS', 5};
fields.amsub2.BT2.atts.long_name = 'AMSU-B Brightness Temperature, primary';
fields.amsub2.BT2.atts.units = 'Kelvin';

%% AVHRR

fields.avhrr.AVHRR_Y.type = 'float';
fields.avhrr.AVHRR_Y.realname = 'y';
fields.avhrr.AVHRR_Y.dims = {'AVHRR_CHANS', 5};
fields.avhrr.AVHRR_Y.atts.long_name = 'AMSU-B measurement';
fields.avhrr.AVHRR_Y.atts.units = 'Albedo or Kelvin';
fields.avhrr.AVHRR_FLAG_3AB.type = 'byte';
fields.avhrr.AVHRR_FLAG_3AB.realname = 'flag_3_is_3A';
fields.avhrr.AVHRR_FLAG_3AB.atts.long_name = 'Channel 3 flag; 1=3A, 0=3B';

%% cloud_cci
fields.cloud_cci.cwp.type               = 'short'; % int16
fields.cloud_cci.cwp.atts.long_name     = 'cloud liquid water path';
fields.cloud_cci.cwp.atts.units         = 'g/m2';
fields.cloud_cci.cwp.atts.missing_value = -32767;
fields.cloud_cci.cwp.atts.valid_range   = [0 20000];
fields.cloud_cci.cwp.atts.description   = ...
    'Atmosphere mass content of cloud liquid water';
fields.cloud_cci.cwp_uncertainty.type               = 'short'; % int16
fields.cloud_cci.cwp_uncertainty.atts.long_name     = 'CWP uncertainty';
fields.cloud_cci.cwp_uncertainty.atts.units         = 'g/m2';
fields.cloud_cci.cwp_uncertainty.atts.missing_value = -32767;
fields.cloud_cci.cwp_uncertainty.atts.valid_range   = [0 40000];
fields.cloud_cci.cwp_uncertainty.atts.description   = ...
    ['Uncertainty of atmospheric mass content of cloud liquid water. '...
     'If iwp>0 then cwp_uncertainty = iwp_uncertianty'];
fields.cloud_cci.phase.type                 = 'byte'; %int8
fields.cloud_cci.phase.atts.long_name       = 'cloud phase flag';
fields.cloud_cci.phase.atts.units           = '';
fields.cloud_cci.phase.atts.missing_value   = -127;
fields.cloud_cci.phase.atts.valid_range     = [0 2];
fields.cloud_cci.phase.atts.description     = ...
    ['thermodynamic_phase_ofields.cloud_water_particles_at_cloud_top'...
    '[0 1 2] means clear/unknown liquid ice. (use cc_total for cloud masking)'];
fields.cloud_cci.cc_total.type              = 'byte';
fields.cloud_cci.cc_total.atts.long_name    = 'cloud fraction';
fields.cloud_cci.cc_total.atts.units        = '-';
fields.cloud_cci.cc_total.atts.missing_value= -128;
fields.cloud_cci.cc_total.atts.valid_range  = [0 1];
fields.cloud_cci.cc_total.atts.description  = ...
    ['Essentially a cloud flag. 0= cloud free, 1= cloudy. '...
    'This field name is used in the level products and then means total cloud cover'];
fields.cloud_cci.iwp.type                = 'short';
fields.cloud_cci.iwp.atts.long_name      = 'ice water path';
fields.cloud_cci.iwp.atts.units          = 'g/m^2';
fields.cloud_cci.iwp.atts.missing_value  = -32767;
fields.cloud_cci.iwp.atts.valid_range    = [0 20000];
fields.cloud_cci.iwp.dependencies_struct = getSelection(fields.cloud_cci,{'cwp','phase','cc_total'});
fields.cloud_cci.iwp.atts.description    = ...
    'cloud ice water path from AVHRR solar reflectance channels';

fields.cloud_cci.iwp_error.type               = 'short'; % int16
fields.cloud_cci.iwp_error.atts.long_name     = 'IWP uncertainty';
fields.cloud_cci.iwp_error.atts.units         = 'g/m^2';
fields.cloud_cci.iwp_error.atts.missing_value = -32767;
fields.cloud_cci.iwp_error.atts.valid_range   = [0 40000];
fields.cloud_cci.iwp_error.dependencies_struct = getSelection(fields.cloud_cci,{'cwp_uncertainty','phase','cc_total'});
fields.cloud_cci.iwp_error.atts.description   = ...
    'Uncertainty of atmospheric mass content of cloud ice';
 
fields.cloud_cci.ref.type                = 'short';
fields.cloud_cci.ref.atts.long_name      = 'effective radius';
fields.cloud_cci.ref.atts.units          = 'micron';
fields.cloud_cci.ref.atts.missing_value  = -32767;
fields.cloud_cci.ref.atts.valid_range    = [0 200];
fields.cloud_cci.ref.atts.description    = ...
    'effective radius of cloud condensed water particles at cloud top';
fields.cloud_cci.ref_uncertainty.type                = 'short';
fields.cloud_cci.ref_uncertainty.atts.long_name      = 'uncertainty in effective radius retrieval';
fields.cloud_cci.ref_uncertainty.atts.units          = 'micron';
fields.cloud_cci.ref_uncertainty.atts.missing_value  = -32767;
fields.cloud_cci.ref_uncertainty.atts.valid_range    = [0 200];
fields.cloud_cci.ref_uncertainty.atts.description    = ...
    'uncertainty in effective radius of cloud condensed water particles at cloud top';
fields.cloud_cci.ref_ice.type                = 'short';
fields.cloud_cci.ref_ice.atts.long_name      = 'effective radius';
fields.cloud_cci.ref_ice.atts.units          = 'micron';
fields.cloud_cci.ref_ice.atts.missing_value  = -32767;
fields.cloud_cci.ref_ice.atts.valid_range    = [0 200];
fields.cloud_cci.ref_ice.dependencies_struct = getSelection(fields.cloud_cci,{'ref','phase','cc_total'});
fields.cloud_cci.ref_ice.atts.description    = ...
    'ice particle effective radius at cloud top';

fields.cloud_cci.cot.type               = 'short';
fields.cloud_cci.cot.atts.long_name     = 'cloud optical thickness';
fields.cloud_cci.cot.atts.units         = '-';
fields.cloud_cci.cot.atts.missing_value = -32767;
fields.cloud_cci.cot.atts.valid_range   = [0 3200];
fields.cloud_cci.cot.atts.description   = ...
    'atmosphere optical thickness due to cloud';
fields.cloud_cci.cot_uncertainty.type               = 'short';
fields.cloud_cci.cot_uncertainty.atts.long_name     = 'Uncertainty in tau_c';
fields.cloud_cci.cot_uncertainty.atts.units         = '-';
fields.cloud_cci.cot_uncertainty.atts.missing_value = -32767;
fields.cloud_cci.cot_uncertainty.atts.valid_range   = [0 3200];
fields.cloud_cci.cot_uncertainty.atts.description   = ...
    'Uncertainty in atmosphere optical thickness due to cloud';
fields.cloud_cci.cot_ice.type                = 'short';
fields.cloud_cci.cot_ice.atts.long_name      = 'cloud optical thickness of ice cloud';
fields.cloud_cci.cot_ice.atts.units          = '-';
fields.cloud_cci.cot_ice.atts.missing_value  = -32767;
fields.cloud_cci.cot_ice.atts.valid_range    = [0 3200];
fields.cloud_cci.cot_ice.dependencies_struct   = getSelection(fields.cloud_cci,{'cot','phase','cc_total'});
fields.cloud_cci.cot_ice.atts.description    = ...
    'atmosphere optical thickness due to ice cloud';

%% CLOUDSAT DATASETS
% ---------

% CLD-CLASS-LIDAR
fields.cpr.CloudFraction.type                = 'float';
fields.cpr.CloudFraction.dataset             = D.cprCloudLidar;
fields.cpr.CloudFraction.atts.long_name      = 'Cloud Fraction';
fields.cpr.CloudFraction.atts.units          = 'none';
fields.cpr.CloudFraction.atts.missing_value  = -99;
fields.cpr.CloudFraction.atts.valid_range    = [0 1];
fields.cpr.CloudFraction.atts.description    = ...
    'Cloud fraction within CloudSat foot print determined from CALIPSO lidar measurements';
fields.cpr.CloudPhase.type               = 'byte';
fields.cpr.CloudPhase.dataset            = D.cprCloudLidar;
fields.cpr.CloudPhase.atts.long_name     = 'Cloud Phase';
fields.cpr.CloudPhase.atts.units         = 'none';
fields.cpr.CloudPhase.atts.missing_value = -9;
fields.cpr.CloudPhase.atts.valid_range   = [0 3];
fields.cpr.CloudPhase.atts.description   = ...
    'Cloud phase identified by using CALIPSO feature, temperature, and radar reflectivity 1-ice, 2-mixed, 3-water';
fields.cpr.CloudPhaseConfidenceLevel.type                = 'byte';
fields.cpr.CloudPhaseConfidenceLevel.dataset             = D.cprCloudLidar;
fields.cpr.CloudPhaseConfidenceLevel.atts.long_name      = 'Cloud phase confidence level';
fields.cpr.CloudPhaseConfidenceLevel.atts.units          = 'none';
fields.cpr.CloudPhaseConfidenceLevel.atts.missing_value  = -9;
fields.cpr.CloudPhaseConfidenceLevel.atts.valid_range    = [0 10];
fields.cpr.CloudPhaseConfidenceLevel.atts.description    = ...
    ['Confidence level assigned to the cloud phase for '...
    'each layer. It has a value ranging from 0 to 10. '...
    '10 indicates the highest confidence level. If confidence '...
    'level is below 5, use the cloud phase with a caution. '];
fields.cpr.CloudLayerType.type               = 'byte';
fields.cpr.CloudLayerType.dataset            = D.cprCloudLidar;
fields.cpr.CloudLayerType.atts.long_name     = 'Cloud layer type';
fields.cpr.CloudLayerType.atts.units         = 'none';
fields.cpr.CloudLayerType.atts.missing_value = -9;
fields.cpr.CloudLayerType.atts.valid_range   = [0 8];
fields.cpr.CloudLayerType.atts.description   = ...
    ['Cloud type for each layer. 0 = Not determined 1 = cirrus, 2 = Altostratus, '...
    '3 = Altocumulus 4 = Stratus, 5 = Stratocumulus, 6= Cumulus 7 = Deep Convection, 8 = Nimbostratus Cloud'];
fields.cpr.CloudTypeQuality.type                = 'float';
fields.cpr.CloudTypeQuality.dataset             = D.cprCloudLidar;
fields.cpr.CloudTypeQuality.atts.long_name      = 'Cloud type quality';
fields.cpr.CloudTypeQuality.atts.units          = 'none';
fields.cpr.CloudTypeQuality.atts.missing_value  = -99;
fields.cpr.CloudTypeQuality.atts.valid_range    = [0 1];
fields.cpr.CloudTypeQuality.atts.description    = ...
    'Cloud Type Quality decided based on fuzzy-logic classification';
fields.cpr.Cloud_Types_Lidar.type               = 'byte';
fields.cpr.Cloud_Types_Lidar.dataset            = D.cprCloudLidar;
fields.cpr.Cloud_Types_Lidar.atts.long_name     = 'Cloud types derived using radar and lidar';
fields.cpr.Cloud_Types_Lidar.atts.units         = 'none';
fields.cpr.Cloud_Types_Lidar.atts.missing_value = -9;
fields.cpr.Cloud_Types_Lidar.atts.valid_range   = [0 10];
fields.cpr.Cloud_Types_Lidar.dependencies_struct= getSelection(fields.cpr,{'CloudFraction','CloudLayerType','CloudTypeQuality'});
fields.cpr.Cloud_Types_Lidar.atts.description   = ...
    ['Single cloud class for entire column. 0 = Cloud free (CloudFraction=0 throughout profile),'...
    '1 = cirrus, 2 = Altostratus, 3 = Altocumulus, 4 = Stratus, 5 = Stratocumulus, 6= Cumulus,'...
    '7 = Deep Convection, 8 = Nimbostratus Cloud, 9 = Mixed (all profiles with more than one cloudtype),'...
    '10 = Not determined (equivalent to CloudLayerType = 0) '...
    'Note: if any CloudTypeQuality < 0.5 in the column the cloud type '...
    'is assinged to missing_value, as are all clouds that have a cloud fraction between 0<cf<1'];
fields.cpr.Cloud_Types_Lidar_multiLayer.type               = 'byte';
fields.cpr.Cloud_Types_Lidar_multiLayer.dataset            = D.cprCloudLidar;
fields.cpr.Cloud_Types_Lidar_multiLayer.atts.long_name     = 'Cloud types derived using radar and lidar';
fields.cpr.Cloud_Types_Lidar_multiLayer.atts.units         = 'none';
fields.cpr.Cloud_Types_Lidar_multiLayer.atts.missing_value = -9;
fields.cpr.Cloud_Types_Lidar_multiLayer.atts.valid_range   = [0 10];
fields.cpr.Cloud_Types_Lidar_multiLayer.dependencies_struct= getSelection(fields.cpr,{'CloudFraction','CloudLayerType','CloudTypeQuality'});
fields.cpr.Cloud_Types_Lidar_multiLayer.atts.description   = ...
    sprintf(['0 = Cloud free\n1 = cirrus\n2 = Altostratus\n3 = Altocumulus\n4 = Stratus\n5 = Stratocumulus\n6= Cumulus\n'...
    '8 = Deep Convection\n7 = Nimbostratus Cloud\n10 = Not determined (equivalent to CloudLayerType = 0)\n'...
    'Note:\n1) If the CloudTypeQuality < 0.5 the clouds is assinged a missing_value.\n'...
    '2) All clouds that have a cloud fraction between 0<cf<1 are assigned missing values.\n'...
    '3) A cloud covering more than one verticle bin in the original data is regarded as one '...
    'cloud here e.g., [6 5 5 1 1] -> [6 5 1]. This is because of a strangity in the original '...
    'data were if e.g., deep convection or Nimbotratus exist in the profile, they only fills the first bin\n'...
    '4) If there are several clouds in a profile, the lowest cloud is listed first\n'...
    'I''ve switched the Deep convective index with the NimboStratus index since it \n'...
    'is obviously wrong (judged by looking at 4 years of data)']); %

% CLD-CLASS
fields.cpr.cloud_scenario.type               = 'short';
fields.cpr.cloud_scenario.dataset            = D.cprCloud;
fields.cpr.cloud_scenario.atts.long_name     = 'Cloud Scenario';
fields.cpr.cloud_scenario.atts.units         = 'none';
fields.cpr.cloud_scenario.atts.missing_value = 0;
fields.cpr.cloud_scenario.atts.description   = ...
    'See table 5 (page 42) in 2B_CLDCLASS_PDICD_5.0.pdf on this dataset';

fields.cpr.Cloud_Types.type                 = 'byte';
fields.cpr.Cloud_Types.dataset              = D.cprCloud;
fields.cpr.Cloud_Types.atts.long_name       = 'Cloud Types';
fields.cpr.Cloud_Types.atts.units           = 'none';
fields.cpr.Cloud_Types.atts.missing_value   = 127;
fields.cpr.Cloud_Types.dependencies_struct  = getSelection(fields.cpr,{'cloud_scenario'});
fields.cpr.Cloud_Types.atts.description     = ...
    ['A condensed version of cloud scenario, where the only single '...
     'cloud types per profile are retrieved, i.e. if there are multiple '...
     'cloudtypes in the same column, the cloudtype is called mixedCloud Types = '...
     'No cloud (0), Ci (1), As (2), Ac (3), St (4), Sc (5), Cu (6), Ns (7), DC (8), mixed (9)'];

fields.cpr.Cloud_Types_multiLayer.type                 = 'byte';
fields.cpr.Cloud_Types_multiLayer.dataset              = D.cprCloud;
fields.cpr.Cloud_Types_multiLayer.atts.long_name       = 'Cloud Types derived using RADAR only';
fields.cpr.Cloud_Types_multiLayer.atts.units           = 'none';
fields.cpr.Cloud_Types_multiLayer.atts.missing_value   = -9;
fields.cpr.Cloud_Types_multiLayer.dependencies_struct  = getSelection(fields.cpr,{'cloud_scenario'});
fields.cpr.Cloud_Types_multiLayer.atts.description     = ...
    sprintf(['A condensed version of cloud scenario. Several cloud types per profile are possible'...
          'No cloud (0), Ci (1), As (2), Ac (3), St (4), Sc (5), Cu (6), Ns (7), DC (8)']);
 
% 2C-ICE
fields.cpr.IWP_2C.realname           = 'ice_water_path';
fields.cpr.IWP_2C.dataset            = D.CPR_2C_ICE;
fields.cpr.IWP_2C.type               = 'float';
fields.cpr.IWP_2C.atts.long_name     = 'retrieved IWP';
fields.cpr.IWP_2C.atts.units         = 'g/m^2';
fields.cpr.IWP_2C.atts.missing_value = -7777;
% fields.cpr.IWP_2C_error.realname       = 'ice_water_path_uncertainty'; % Appears to always be 0
% fields.cpr.IWP_2C_error.dataset        = D.CPR_2C_ICE;
% fields.cpr.IWP_2C_error.type           = 'float';
% fields.cpr.IWP_2C_error.atts.long_name = 'IWP uncertainty';
% fields.cpr.IWP_2C_error.atts.units     = '%';
fields.cpr.IWC_2C.realname       = 'IWC';
fields.cpr.IWC_2C.dataset        = D.CPR_2C_ICE;
fields.cpr.IWC_2C.type           = 'float';
fields.cpr.IWC_2C.atts.long_name = 'retrieved IWC';
fields.cpr.IWC_2C.atts.units     = 'mg/m^3';
fields.cpr.IWC_2C_error.realname       = 'IWC_uncertainty';
fields.cpr.IWC_2C_error.dataset        = D.CPR_2C_ICE;
fields.cpr.IWC_2C_error.type           = 'float';
fields.cpr.IWC_2C_error.atts.long_name = 'IWC uncertainty';
fields.cpr.IWC_2C_error.atts.units     = '%';
% 2B-CWC-RO
fields.cpr.Data_quality.type                = 'short';
fields.cpr.Data_quality.atts.long_name      = 'data quality';
fields.cpr.Data_quality.atts.units          = 'none';
fields.cpr.Data_quality.atts.missing_value  = 127;
fields.cpr.Data_quality.atts.description    = ...
    'If 0, then data is of good quality, otherwise treat as bitfield with 8 flags';
fields.cpr.dROIWP.type           = 'float';
fields.cpr.dROIWP.realname       = 'RO_ice_water_path_uncertainty';
fields.cpr.dROIWP.atts.long_name = 'CloudSat Radar-Only CPR IWP uncertainty';
fields.cpr.dROIWP.atts.units     = 'g/m^2';
fields.cpr.dIOROIWP.type             = 'float';
fields.cpr.dIOROIWP.realname         = 'IO_RO_ice_water_path_uncertainty';
fields.cpr.dIOROIWP.atts.long_name   = 'CloudSat Radar-Only Ice-Only CPR IWP uncertainty';
fields.cpr.dIOROIWP.atts.units       = 'g/m^2';
fields.cpr.Height.type           = 'short';
fields.cpr.Height.atts.long_name = 'Height of range bin in Reflectivity/Cloud Mask above reference surface (~ mean sea level)';
fields.cpr.Height.atts.units     = 'm';
fields.cpr.IOROIWP.type              = 'float';
fields.cpr.IOROIWP.realname          = 'IO_RO_ice_water_path';
fields.cpr.IOROIWP.atts.long_name    = 'CloudSat Radar-Only Ice-Only CPR IWP';
fields.cpr.IOROIWP.atts.units        = 'g/m^2';
fields.cpr.IO_RO_ice_water_path      = fields.cpr.IOROIWP;
fields.cpr.IO_RO_ice_water_path.type = 'short';
fields.cpr.RO_ice_water_content.type             = 'short';
fields.cpr.RO_ice_water_content.atts.long_name   = 'ice water content';
fields.cpr.RO_ice_water_content.atts.units       = 'g/m^3';
fields.cpr.RO_ice_water_content_uncertainty.type             = 'short';
fields.cpr.RO_ice_water_content_uncertainty.atts.long_name   = 'ice water content uncertainty';
fields.cpr.RO_ice_water_content_uncertainty.atts.units       = '%';
fields.cpr.RO_ice_water_content_uncertainty.atts.description = ...
    ['Fractional uncertainty in the RO retrieved IWC (from the ice-only retrieval), expressed in percent '...
     'and rounded to the nearest integer. A value of 250 indicates an uncertainty >= 250%.'];
fields.cpr.RO_liq_water_content.type             = 'short';
fields.cpr.RO_liq_water_content.atts.long_name   = 'liquid water content';
fields.cpr.RO_liq_water_content.atts.units       = 'g/m^3';
fields.cpr.RO_liq_water_content.atts.missing_value = -9;
fields.cpr.RO_liq_water_content_uncertainty.type             = 'short';
fields.cpr.RO_liq_water_content_uncertainty.atts.long_name   = 'liquid water content uncertainty';
fields.cpr.RO_liq_water_content_uncertainty.atts.units       = '%';
fields.cpr.RO_liq_water_content_uncertainty.atts.missing_value = -9;
fields.cpr.RO_liq_water_content_uncertainty.atts.description = ...
    ['Fractional uncertainty in the RO retrieved LWC (from the liquid-only retrieval), expressed in percent '...
     'and rounded to the nearest integer. A value of 250 indicates an uncertainty >= 250%.'];
fields.cpr.ROIWP.type                = 'float';
fields.cpr.ROIWP.realname            = 'RO_ice_water_path';
fields.cpr.ROIWP.atts.long_name      = 'CloudSat Radar-Only CPR IWP';
fields.cpr.ROIWP.atts.units          = 'g/m^2';
fields.cpr.RO_ice_water_path         = fields.cpr.ROIWP;
fields.cpr.RO_ice_water_path.type    = 'short'; %int16
fields.cpr.RO_liq_water_path.type    = 'short';
fields.cpr.RO_liq_water_path.atts.long_name = 'Radar-only liquid water path';
fields.cpr.RO_liq_water_path.atts.units = 'g/m^2';
fields.cpr.RO_liq_water_path.atts.missing_value = -9;
fields.cpr.LO_RO_liquid_water_path.type = 'short';
fields.cpr.LO_RO_liquid_water_path.atts.long_name = 'Radar-only liquid-only liquid water path';
fields.cpr.LO_RO_liquid_water_path.atts.units = 'g/m^2';

% 2B-CWC-RVOD
fields.cpr.RVOD_ice_water_path.type              = 'int';
fields.cpr.RVOD_ice_water_path.dataset           = D.CPR_RVOD;
fields.cpr.RVOD_ice_water_path.atts.long_name    = 'RVOD ice water path';
fields.cpr.RVOD_ice_water_path.atts.units        = 'g/m^2';
fields.cpr.RVOD_ice_water_path.atts.missing_value = -3333;
fields.cpr.RVOD_liq_water_path.type              = 'int';
fields.cpr.RVOD_liq_water_path.dataset           = D.CPR_RVOD;
fields.cpr.RVOD_liq_water_path.atts.long_name    = 'Radar Visible Opticle Depth liquid water path';
fields.cpr.RVOD_liq_water_path.atts.units        = 'g/m^2';
fields.cpr.RVOD_liq_water_path.atts.missing_value = -3333;

% ECMWF_AUX
fields.cpr.ECMWF_Temperature.type = 'float';
fields.cpr.ECMWF_Temperature.dataset = D.CPR_ECMWF;
fields.cpr.ECMWF_Temperature.realname = 'Temperature';
fields.cpr.ECMWF_Temperature.atts.long_name = 'ECMWF temperature';
fields.cpr.ECMWF_Temperature.atts.units = 'K';
fields.cpr.ECMWF_Temperature.atts.missing_value = -999;
%fields.cpr.ECMWF_Temperature.atts
fields.cpr.ECMWF_Pressure.type = 'float';
fields.cpr.ECMWF_Pressure.dataset = D.CPR_ECMWF;
fields.cpr.ECMWF_Pressure.realname = 'Pressure';
fields.cpr.ECMWF_Pressure.atts.long_name = 'ECMWF pressure';
fields.cpr.ECMWF_Pressure.atts.units = 'Pa';
fields.cpr.ECMWF_Pressure.atts.missing_value = -999;
%fields.cpr.ECMWF_Pressure.atts
fields.cpr.ECMWF_Specific_humidity.type = 'float';
fields.cpr.ECMWF_Specific_humidity.dataset = D.CPR_ECMWF;
fields.cpr.ECMWF_Specific_humidity.realname = 'Specific_humidity';
fields.cpr.ECMWF_Specific_humidity.atts.long_name = 'ECMWF Specific humidity';
fields.cpr.ECMWF_Specific_humidity.atts.units = 'kg/kg';
fields.cpr.ECMWF_Specific_humidity.atts.missing_value = -999;
%fields.cpr.ECMWF_Specific_humidity.atts
fields.cpr.ECMWF_Surface_pressure.type = 'float';
fields.cpr.ECMWF_Surface_pressure.dataset = D.CPR_ECMWF;
fields.cpr.ECMWF_Surface_pressure.realname = 'Surface_pressure';
fields.cpr.ECMWF_Surface_pressure.atts.long_name = 'ECMWF surface pressure';
fields.cpr.ECMWF_Surface_pressure.atts.units = 'Pa';
fields.cpr.ECMWF_Surface_pressure.atts.missing_value = -999;
%fields.cpr.ECMWF_Surface_pressure.atts
fields.cpr.ECMWF_Skin_temperature.type = 'float';
fields.cpr.ECMWF_Skin_temperature.dataset = D.CPR_ECMWF;
fields.cpr.ECMWF_Skin_temperature.realname = 'Skin_temperature';
fields.cpr.ECMWF_Skin_temperature.atts.long_name = 'ECMWF skin temperature';
fields.cpr.ECMWF_Skin_temperature.atts.units = 'K';
fields.cpr.ECMWF_Skin_temperature.atts.missing_value = -999;
%fields.cpr.ECMWF_Skin_temperature.atts
fields.cpr.ECMWF_Temperature_2m.type = 'float';
fields.cpr.ECMWF_Temperature_2m.dataset = D.CPR_ECMWF;
fields.cpr.ECMWF_Temperature_2m.realname = 'Temperature_2m';
fields.cpr.ECMWF_Temperature_2m.atts.long_name = 'ECMWF 2m temperature';
fields.cpr.ECMWF_Temperature_2m.atts.units = 'K';
fields.cpr.ECMWF_Temperature_2m.atts.missing_value = -999;
%fields.cpr.ECMWF_Temperature_2m.atts
fields.cpr.ECMWF_elevation.type = 'short';
fields.cpr.ECMWF_elevation.dataset = D.CPR_ECMWF;
fields.cpr.ECMWF_elevation.realname = 'DEM_elevation';
fields.cpr.ECMWF_elevation.atts.long_name = 'ECMWF DEM surface elevation';
fields.cpr.ECMWF_elevation.atts.units = 'm';
fields.cpr.ECMWF_elevation.atts.missing_value = 9999;
%fields.cpr.ECMWF_elevation.atts

% dardarsub as sibling for cpr defined AFTER dardar_sub

%% DARDAR_SUB
fields.dardarsub.HEIGHT.realname         = 'height';
fields.dardarsub.HEIGHT.type             = 'float';
fields.dardarsub.HEIGHT.atts.long_name   = 'Height';
fields.dardarsub.HEIGHT.atts.units       = 'm';
fields.dardarsub.HEIGHT.atts.description = 'This field is only available as meta data';
fields.dardarsub.iwc.type            = 'float';
fields.dardarsub.iwc.atts.long_name  = 'Retrieved Ice Water Content, the mass of ice per unit';
fields.dardarsub.iwc.atts.units       = 'kg m-3';
fields.dardarsub.ln_iwc_error.realname      = 'ln_iwc_error';
fields.dardarsub.ln_iwc_error.type          = 'float';
fields.dardarsub.ln_iwc_error.atts.long_name= '1-sigma random error in natural logarithm of IWC';
fields.dardarsub.ln_iwc_error.atts.units     = 'ln(kg m-3)';
fields.dardarsub.dardar_IWP.type                = 'float'; % is enough since max IWP ca. 14000 g/m^2
fields.dardarsub.dardar_IWP.atts.long_name      = 'DARDAR Ice Water Path';
fields.dardarsub.dardar_IWP.atts.units          = 'kg/m^2';
fields.dardarsub.dardar_IWP.atts.missing_value  = -999;
fields.dardarsub.dardar_IWP.dependencies_struct = getSelection(fields.dardarsub,{'iwc','HEIGHT'});
fields.dardarsub.dardar_IWP.atts.description    = ...
    'Column integrated ''iwc''';
fields.dardarsub.dardar_ln_IWP_error.type                = 'float';
fields.dardarsub.dardar_ln_IWP_error.atts.long_name      = 'DARDAR ln_IWP_error';
fields.dardarsub.dardar_ln_IWP_error.atts.units          = 'fractional error';%'ln(kg/m^2)';
fields.dardarsub.dardar_ln_IWP_error.atts.missing_value  = -999;
fields.dardarsub.dardar_ln_IWP_error.dependencies_struct = getSelection(fields.dardarsub,{'iwc','HEIGHT','ln_iwc_error'});
fields.dardarsub.dardar_ln_IWP_error.atts.description    = ...
    'Column integrated ''ln_iwc_error''';
fields.dardarsub.INSTR_FLAG.realname         = 'instrument_flag';
fields.dardarsub.INSTR_FLAG.type             = 'short';
fields.dardarsub.INSTR_FLAG.atts.long_name   = 'Instrument flag (0==nothing/1==lidar/2==radar/3==radar+lidar)';
fields.dardarsub.INSTR_FLAG.atts.units       = '-';
fields.dardarsub.VOD.realname        = 'vis_optical_depth';
fields.dardarsub.VOD.type            = 'float';
fields.dardarsub.VOD.atts.long_name  = 'visible optical depth';
fields.dardarsub.VOD.atts.unit       = 'dimless';
fields.dardarsub.VOD.atts.description= ['Visible optical depth, defined as the (dimensionless) line ',...
                                    'integral of the ice cloud visible extinction along a vertical path ',...
                                    'through the entire atmosphere.'];
fields.dardarsub.VOD_ERROR.realname         = 'vis_optical_depth_error';
fields.dardarsub.VOD_ERROR.type             = 'float';
fields.dardarsub.VOD_ERROR.atts.long_name   = 'visible optical depth error';
fields.dardarsub.VOD_ERROR.atts.units       = '-';
fields.dardarsub.VOD_ERROR.atts.description = 'Visible optical depth error';
fields.dardarsub.dardar_Re.realname             = 'effective_radius';
fields.dardarsub.dardar_Re.type                 = 'float';
fields.dardarsub.dardar_Re.atts.long_name       = 'Retrieved effective radius';
fields.dardarsub.dardar_Re.atts.units           = 'm';
fields.dardarsub.dardar_Re.atts.missing_value   = -999;
fields.dardarsub.dardar_Re_error.realname           = 'ln_effective_radius_error';
fields.dardarsub.dardar_Re_error.type               = 'float';
fields.dardarsub.dardar_Re_error.atts.long_name     = 'Fractional error in effective radius';
fields.dardarsub.dardar_Re_error.atts.units         = 'ln(m)';
fields.dardarsub.dardar_Re_error.atts.missing_value = -999;

%% CPR siblingfields from dardarsub

ddfields = fieldnames(fields.dardarsub);
for ddfield = vec2row(ddfields)
    if strncmpi(ddfield{1}, 'dardar', 6)
        fname = ddfield{1};
    else
        fname = ['dardar_' ddfield{1}];
    end
    fields.cpr.(fname) = fields.dardarsub.(ddfield{1});
    fields.cpr.(fname).dataset = D.dardarsub;
end

%% GRAS
%  We will need (at least) the following parameters from the netCDF file:
% - temp
% - temp_sigma
% - shum  (specific humidity)
% - geop (geopotential height)

fields.gras.G_TEMP.type = 'float';
fields.gras.G_TEMP.realname = 'temp';
fields.gras.G_TEMP.atts.long_name = 'GRAS Temperature';
fields.gras.G_TEMP.atts.units = 'Kelvin';
fields.gras.G_TEMP.atts.valid_range = [150, 350];
fields.gras.G_TEMP.atts.note = 'Attributes copied from original';
fields.gras.G_TEMP_SIGMA.type = 'float';
fields.gras.G_TEMP_SIGMA.realname = 'temp_sigma';
fields.gras.G_TEMP_SIGMA.atts.long_name = 'GRAS Estimated error (1-sigma) for temperature';
fields.gras.G_TEMP_SIGMA.atts.units = 'kelvin';
fields.gras.G_TEMP_SIGMA.atts.valid_range = [0, 5];
fields.gras.G_TEMP_SIGMA.atts.note = 'Attributes copied from original';
fields.gras.G_SHUM.type = 'float';
fields.gras.G_SHUM.realname = 'shum';
fields.gras.G_SHUM.atts.long_name = 'GRAS Specific humidity';
fields.gras.G_SHUM.atts.units = 'gram / kilogram';
fields.gras.G_SHUM.atts.valid_range = [0, 50];
fields.gras.G_SHUM.atts.note = 'Attributes copied from original';
fields.gras.G_SHUM_SIGMA.type = 'float';
fields.gras.G_SHUM_SIGMA.realname = 'shum_sigma';
fields.gras.G_SHUM_SIGMA.atts.long_name = 'GRAS Estimated  error (1-sigma) in specific humidity';
fields.gras.G_SHUM_SIGMA.atts.units = 'gram / kilogram';
fields.gras.G_SHUM_SIGMA.atts.valid_range = [0, 5];
fields.gras.G_SHUM_SIGMA.atts.note = 'Attributes copied from original'; 
fields.gras.G_GEOP.type = 'float';
fields.gras.G_GEOP.realname = 'geop';
fields.gras.G_GEOP.atts.long_name = 'GRAS Geopotential height above geoid for P,T,H';
fields.gras.G_GEOP.atts.units = 'geopotential metres';
fields.gras.G_GEOP.atts.valid_range = [-1000, 100000];
fields.gras.G_GEOP.atts.note = 'Attributes copied from original';
fields.gras.G_GEOP_SIGMA.type = 'float';
fields.gras.G_GEOP_SIGMA.realname = 'geop_sigma';
fields.gras.G_GEOP_SIGMA.atts.long_name = 'GRAS Estimated error (1-sigma) for geopotential height';
fields.gras.G_GEOP_SIGMA.atts.units = 'geopotential metres';
fields.gras.G_GEOP_SIGMA.atts.valid_range = [0, 500];
fields.gras.G_GEOP_SIGMA.atts.note = 'Attributes copied from original';
fields.gras.G_PRESSURE.type = 'float';
fields.gras.G_PRESSURE.realname ='press';
fields.gras.G_PRESSURE.atts.long_name ='Pressure';
fields.gras.G_PRESSURE.atts.units = 'hPa';
fields.gras.G_PRESSURE.atts.valid_range =[1.0e-4, 1100.0];
fields.gras.G_PRESSURE.atts.note = 'Attributes copied from original';
fields.gras.G_PRESSURE_SIGMA.type = 'float';
fields.gras.G_PRESSURE_SIGMA.realname ='press_sigma';
fields.gras.G_PRESSURE_SIGMA.atts.long_name ='Estimated error (1-sigma) for pressure';
fields.gras.G_PRESSURE_SIGMA.atts.units = 'hPa';
fields.gras.G_PRESSURE_SIGMA.atts.valid_range =[0.0, 5.0];
fields.gras.G_PRESSURE_SIGMA.atts.note = 'Attributes copied from original';

%% HIRS
fields.hirs.H_LONG.type = 'float';
fields.hirs.H_LONG.realname = 'lon';
fields.hirs.H_LONG.atts.long_name = 'HIRS Longitude';
fields.hirs.H_LONG.atts.units = 'degrees_east';
fields.hirs.H_LONG.atts.valid_range = [-180 180];
fields.hirs.H_LONG.atts.missing_value = -9999;
fields.hirs.H_LAT.type = 'float';
fields.hirs.H_LAT.realname = 'lat';
fields.hirs.H_LAT.atts.long_name = 'HIRS Latitude';
fields.hirs.H_LAT.atts.units = 'degrees_north';
fields.hirs.H_LAT.atts.valid_range = [-90 90];
fields.hirs.H_LAT.atts.missing_value = -9999;
fields.hirs.H_TIME.type = 'int';
fields.hirs.H_TIME.realname = 'time';
fields.hirs.H_TIME.atts.long_name = 'HIRS measurement time';
fields.hirs.H_TIME.atts.units = 'seconds since 1970-01-01 00:00:00';
fields.hirs.H_TIME.atts.missing_value = 0;
fields.hirs.H_TIME.atts.valid_min = 0;
fields.hirs.H_LZA = lza;
fields.hirs.H_LAA = laa;
fields.hirs.H_BT.type = 'float';
fields.hirs.H_BT.realname = 'tb';
fields.hirs.H_BT.dims = {'HIRS_CHANS', 20};
fields.hirs.H_BT.atts.long_name = 'HIRS Brightness Temperature';
fields.hirs.H_BT.atts.units = 'Kelvin';
fields.hirs.H_BT.atts.missing_value = -9999;
%fields.hirs.H_BT.atts.valid_min = 0; % asking for trouble i.e. exact flag
fields.hirs.H_LINE.type = 'int';
fields.hirs.H_LINE.realname = 'scanline_number';
fields.hirs.H_LINE.atts.long_name = 'HIRS scanline number';
fields.hirs.H_LINE.atts.missing_value = 0;
fields.hirs.H_LINE.atts.valid_min = 1;
fields.hirs.H_POS.type = 'byte';
fields.hirs.H_POS.realname = 'scanline_position';
fields.hirs.H_POS.atts.long_name = 'HIRS scanline position';
fields.hirs.H_POS.atts.missing_value = 0;
fields.hirs.H_POS.atts.valid_range = [1 56];

%% MHS
% very similar to AMSU-B
fields.mhs = fields.amsub;
fields.mhs.B_BT.dims = {'MHS_CHANS', 5};
fields.mhs.B_BT.atts.long_name = 'MHS Brightness Temperature';

fields.mhs1 = fields.amsub1;
fields.mhs1.BT1.dims = {'MHS_CHANS', 5};
fields.mhs1.BT1.atts.long_name = 'MHS Brightness Temperature, primary';

fields.mhs2 = fields.amsub2;
fields.mhs2.BT2.dims = {'MHS_CHANS', 5};
fields.mhs2.BT2.atts.long_name = 'MHS Brightness Temperature, secondary';

%% MODIS
fields.modis.Cloud_Water_Path.type                = 'short';
fields.modis.Cloud_Water_Path.atts.long_name      = 'Column Cloud Water Path two-band retrieval using band 7 and either band 1, 2, or 5 .';
fields.modis.Cloud_Water_Path.atts.units          = 'g/m^2';
fields.modis.Cloud_Water_Path.atts.valid_range    = [0 10000];
fields.modis.Cloud_Water_Path.atts.missing_value  = -9999;
fields.modis.Cloud_Water_Path.atts.description    = ...
    ['Daytime only: Source data at 1-km is subsampled at 5-km. Note that all cloud phases '...
    '(liquid water, ice, and undetermined phase) are represented in the parameter;'...
    'users must read the Cloud Phase (Retrieval Processing Path) Flag in the '...
    'Cloud_Quality_Assurance SDS to determine the cloud phase represented by each pixel.'];
fields.modis.Cloud_Water_Path_Uncertainty.type                = 'short';
fields.modis.Cloud_Water_Path_Uncertainty.atts.long_name      = 'Cloud Water Path Relative Uncertainty (Percent)';
fields.modis.Cloud_Water_Path_Uncertainty.atts.units          = '%';
fields.modis.Cloud_Water_Path_Uncertainty.atts.valid_range    = [0 20000];
fields.modis.Cloud_Water_Path_Uncertainty.atts.missing_value  = -9999;
fields.modis.Cloud_Water_Path_Uncertainty.atts.description    = 'Relative uncertainty of Cloud_Water_Path';
fields.modis.Cloud_Effective_Radius.type                = 'short'; % this field needs to be scaled by 0.01
fields.modis.Cloud_Effective_Radius.atts.long_name      = ['Cloud particle effective radius (??m) derived from a two-channel '...
                                       'retrieval using MODIS band 7 and either band 1, 2, or 5'];
fields.modis.Cloud_Effective_Radius.atts.units          = 'micron';
fields.modis.Cloud_Effective_Radius.atts.valid_range    = [0 10000];
fields.modis.Cloud_Effective_Radius.atts.missing_value  = -9999;
fields.modis.Cloud_Effective_Radius.atts.scale_factor   = 0.01;
fields.modis.Cloud_Effective_Radius.atts.description    = ...
    ['Source data at 1-km is subsampled at 5-km. Note that all cloud phases'...
    '(liquid water, ice, and undetermined phase) are represented in the parameter;'...
    'users must read the Cloud Phase (Retrieval Processing Path) Flag '...
    'in the Cloud_Quality_Assurance SDS to determine the cloud phase represented '...
    'by each pixel. SDS name changed to clarify application.'];

fields.modis.Cloud_Effective_Radius_Uncertainty.type                = 'short';
fields.modis.Cloud_Effective_Radius_Uncertainty.atts.long_name      = 'Relative uncertainty in Cloud Effective Radius (Percent)';
fields.modis.Cloud_Effective_Radius_Uncertainty.atts.units          = '%';
fields.modis.Cloud_Effective_Radius_Uncertainty.atts.valid_range    = [0 20000];
fields.modis.Cloud_Effective_Radius_Uncertainty.atts.missing_value ...
    = -9999;
fields.modis.Cloud_Effective_Radius_Uncertainty.atts.scale_factor ...
    = 0.01;
fields.modis.Cloud_Effective_Radius_Uncertainty.atts.description    = ...
    'Relative uncertainty of Cloud Effective Radius';

fields.modis.Cloud_Multi_Layer_Flag.type              = 'byte';
fields.modis.Cloud_Multi_Layer_Flag.atts.long_name    = 'Cloud Multi Layer Identification From MODIS Shortwave Observations';
fields.modis.Cloud_Multi_Layer_Flag.atts.units        = 'none';
fields.modis.Cloud_Multi_Layer_Flag.atts.valid_range  = [0 9];
fields.modis.Cloud_Multi_Layer_Flag.atts.missing_value=0;
fields.modis.Cloud_Multi_Layer_Flag.atts.description  = ...
    [' Flag for multi-layer multi-phase cloud situations. Values 2 through 8',...
 'indicate the success of various multi-layer cloud tests. Value of 0',...                
 'indicates no retrieval, value of 1 indicates single layer cloud. The',...
 'other values are of increasing confidence level. The value of 2 is',...
 'of absolute lowest confidence and often can be ignored as it  is a result',...          
 'of cloud phase comparison test, which is not always trustworthy.'];

fields.modis.Cloud_Optical_Thickness.type                = 'short'; % this field needs to be scaled by 0.01
fields.modis.Cloud_Optical_Thickness.atts.long_name      = ['Cloud optical thickness at 0.66 ??m derived from a two-channel retrieval'...
                                       'using MODIS band 7 and either band 1, 2, or 5.'];
fields.modis.Cloud_Optical_Thickness.atts.units          = '-';
fields.modis.Cloud_Optical_Thickness.atts.valid_range    = [0 10000];
fields.modis.Cloud_Optical_Thickness.atts.missing_value  = -9999;
fields.modis.Cloud_Optical_Thickness.atts.scale_factor   = 0.01;
fields.modis.Cloud_Optical_Thickness.atts.description    = ...
    ['Source data at 1-km is subsampled at 5-km. Note that all cloud phases '...
    '(liquid water, ice, and undetermined phase) are represented in the parameter;'...
    'users must read the Cloud Phase (Retrieval Processing Path) Flag in the '...
    'Cloud_Quality_Assurance SDS to determine the cloud phase represented by each pixel.'];

fields.modis.Cloud_Optical_Thickness_Uncertainty.type                = 'short';
fields.modis.Cloud_Optical_Thickness_Uncertainty.atts.long_name      = 'Relative uncertainty in Cloud Optical Thickness (Percent)';
fields.modis.Cloud_Optical_Thickness_Uncertainty.atts.units          = '%';
fields.modis.Cloud_Optical_Thickness_Uncertainty.atts.valid_range    = [0 20000];
fields.modis.Cloud_Optical_Thickness_Uncertainty.atts.missing_value  = -9999;
fields.modis.Cloud_Optical_Thickness_Uncertainty.atts.scale_factor ...
    = 0.01;
fields.modis.Cloud_Optical_Thickness_Uncertainty.atts.description    = ...
    'Relative uncertainty of Cloud Optical Thickness';

fields.modis.Cloud_Phase_Optical_Properties.type                = 'byte';
fields.modis.Cloud_Phase_Optical_Properties.atts.long_name      = 'Cloud Phase Determination Used in Optical Thickness/Effective Radius Retrieval';
fields.modis.Cloud_Phase_Optical_Properties.atts.units          = '-';
fields.modis.Cloud_Phase_Optical_Properties.atts.valid_range    = [0 4];
fields.modis.Cloud_Phase_Optical_Properties.atts.missing_value  = 0;
fields.modis.Cloud_Phase_Optical_Properties.atts.description = ...
    ['Daytime only. Cloud Phase as determined by the '...
     'Cloud Optical Property algorithm. Note that this phase flag is '...
     'identical for both the primary retrieval and the 1.6/2.1 ??m retrieval.'...
     '[(0=fill, 1=clear, 2=liquid water cloud, 3=ice cloud,4=undetermined phase cloud)'];
                            
fields.modis.Quality_Assurance_1km.type             = 'byte';
fields.modis.Quality_Assurance_1km.atts.long_name   = 'QA Flags at 1x1 km resolution';
fields.modis.Quality_Assurance_1km.description      = 'For details see http://modis-atmos.gsfc.nasa.gov/reference_atbd.html';
     
fields.modis.modis_IWP.type                 = 'short';
fields.modis.modis_IWP.atts.long_name       = 'MODIS IWP';
fields.modis.modis_IWP.atts.units           = 'g/m^2';
fields.modis.modis_IWP.atts.valid_range     = [0 10000];
fields.modis.modis_IWP.atts.missing_value   = -9999;
fields.modis.modis_IWP.dependencies_struct  = getSelection(fields.modis,{'Cloud_Water_Path','Quality_Assurance_1km','Cloud_Phase_Optical_Properties'});
fields.modis.modis_IWP.atts.description     = ...
    ['''Cloud_Water_Path'' where the ''Cloud_Phase_Optical_Properties'''...
    'have the value ''3'' (ice clouds) and the ''Quality_Assurance_1km'' flag is set to good'];
fields.modis.modis_IWP_uncertainty.type                = 'short';
fields.modis.modis_IWP_uncertainty.atts.long_name      = 'modis_IWP Relative Uncertainty (Percent)';
fields.modis.modis_IWP_uncertainty.atts.units          = '%';
fields.modis.modis_IWP_uncertainty.atts.valid_range    = [0 20000];
fields.modis.modis_IWP_uncertainty.atts.missing_value  = -9999;
fields.modis.modis_IWP_uncertainty.dependencies_struct = getSelection(fields.modis,{'Cloud_Water_Path_Uncertainty','Quality_Assurance_1km','Cloud_Phase_Optical_Properties'});
fields.modis.modis_IWP_uncertainty.atts.description    = ...
    'Relative uncertainty of Cloud_Water_Path';

fields.modis.Re_ice.type                 = 'short';
fields.modis.Re_ice.atts.long_name       = 'modis_Effective_Radius_ice';
fields.modis.Re_ice.atts.units           = 'micron';
fields.modis.Re_ice.atts.valid_range     = [0 10000];
fields.modis.Re_ice.atts.missing_value   = -9999;
fields.modis.Re_ice.atts.scale_factor    = 0.01;
fields.modis.Re_ice.dependencies_struct  = getSelection(fields.modis,{'Cloud_Effective_Radius','Quality_Assurance_1km','Cloud_Phase_Optical_Properties'});
fields.modis.Re_ice.atts.description     = ...
    ['''Cloud_Effective_Radius'' where the ''Cloud_Phase_Optical_Properties'' '...
    'have the value ''3'' (ice clouds) and the ''Quality_Assurance_1km'' flag is set to good'];
fields.modis.Re_ice_uncertainty.type                = 'short';
fields.modis.Re_ice_uncertainty.atts.long_name      = 'Re_ice Relative Uncertainty (Percent)';
fields.modis.Re_ice_uncertainty.atts.units          = '%';
fields.modis.Re_ice_uncertainty.atts.valid_range    = [0 20000];
fields.modis.Re_ice_uncertainty.atts.missing_value  = -9999;
fields.modis.Re_ice_uncertainty.atts.scale_factor   = 0.01;
fields.modis.Re_ice_uncertainty.dependencies_struct = getSelection(fields.modis,{'Cloud_Effective_Radius_Uncertainty','Quality_Assurance_1km','Cloud_Phase_Optical_Properties'});
fields.modis.Re_ice_uncertainty.atts.description    = ...
    'Relative uncertainty of Re_ice';

fields.modis.Tau_ice.type                = 'short';
fields.modis.Tau_ice.atts.long_name      = 'modis Cloud Optical Depth';
fields.modis.Tau_ice.atts.units          = 'none';
fields.modis.Tau_ice.atts.valid_range    = [0 10000];
fields.modis.Tau_ice.atts.missing_value  = -9999;
fields.modis.Tau_ice.atts.scale_factor   = 0.01;
fields.modis.Tau_ice.dependencies_struct = getSelection(fields.modis,{'Cloud_Optical_Thickness','Quality_Assurance_1km','Cloud_Phase_Optical_Properties'});
fields.modis.Tau_ice.atts.description    = ...
    ['''Cloud_Optical_Depth'' where the ''Cloud_Phase_Optical_Properties'' have the value '...
    '''3'' (ice clouds) and the ''Quality_Assurance_1km'' flag is set to good'];

fields.modis.Tau_ice_uncertainty.type                = 'short';
fields.modis.Tau_ice_uncertainty.atts.long_name      = 'Relative uncertainty in Tau_ice (Percent)';
fields.modis.Tau_ice_uncertainty.atts.units          = '%';
fields.modis.Tau_ice_uncertainty.atts.valid_range    = [0 20000];
fields.modis.Tau_ice_uncertainty.atts.missing_value  = -9999;
fields.modis.Tau_ice_uncertainty.atts.scale_factor   = 0.01;
fields.modis.Tau_ice_uncertainty.dependencies_struct = getSelection(fields.modis,{'Cloud_Optical_Thickness_Uncertainty','Quality_Assurance_1km','Cloud_Phase_Optical_Properties'});
fields.modis.Tau_ice_uncertainty.atts.description    = ...
    'Relative uncertainty of Tau_ice';

%% SAPHIR
for i = 1:6
    fn = sprintf('TB%d', i);
    fields.saphir.(fn).type = 'float';
    fields.saphir.(fn).realname = sprintf('TbCh%d', i);
    fields.saphir.(fn).atts.long_name = sprintf('Saphir Brightness Temperature, channel %d', i);
    fields.saphir.(fn).atts.units = 'Kelvin';
    fields.saphir.(fn).atts.missing_value = -9999;
end

fields.saphir.IncidencAngle.type = 'float';
fields.saphir.IncidencAngle.atts.long_name = sprintf('SAPHIR incidence angle');

% ---------

%% SSM/T-2
% (vs. others)

fields.ssmt2.SSMT2_BT.type = 'float';
fields.ssmt2.SSMT2_BT.dims = {'SSMT2_CHANS', 5};
fields.ssmt2.SSMT2_BT.realname = 'tb';
fields.ssmt2.SSMT2_BT.atts.long_name = 'SSM T/2 Brightness Temperature';
fields.ssmt2.SSMT2_BT.atts.units = 'Kelvin';
fields.ssmt2.SSMT2_channel_quality_flag.type = 'float';
fields.ssmt2.SSMT2_channel_quality_flag.dims = fields.ssmt2.SSMT2_BT.dims;
fields.ssmt2.SSMT2_channel_quality_flag.realname = 'channel_quality_flag';
fields.ssmt2.SSMT2_channel_quality_flag.atts.long_name = 'SSM T/2 channel quality flag';

% (vs. self)

% use same field-names but with _1, _2 added

fn = fieldnames(fields.ssmt2);
for i = 1:length(fn)
    fields.ssmt2_1.([fn{i} '_1']) = fields.ssmt2.(fn{i});
    fields.ssmt2_2.([fn{i} '_2']) = fields.ssmt2.(fn{i});
end

%% Collocated datasets

% CACMEH = collapsed_associated_CPR_MHS_AMSU_HIRS, its parent, and the
% other fieldcopiers belonging to its parent
%
% Note that fieldnames here belong to the fields as returned by
% 

fields.cacmeh.MHS_LAT = CollocatedDataset.members_const.LAT1;
fields.cacmeh.MHS_LAT.realname = 'LAT1';
fields.cacmeh.MHS_LAT.atts.long_name = 'MHS Latitude';
fields.cacmeh.MHS_LON = CollocatedDataset.members_const.LON1;
fields.cacmeh.MHS_LON.realname = 'LON1';
fields.cacmeh.MHS_LON.atts.long_name = 'MHS Latitude';
fields.cacmeh.MHS_START = CollocatedDataset.members_const.START1;
fields.cacmeh.MHS_START.realname = 'START1';
fields.cacmeh.MHS_START.atts.long_name = 'MHS starting time';
fields.cacmeh.MHS_BT = fields.mhs.B_BT;
fields.cacmeh.MHS_BT.realname = 'B_BT';

% NOTE: unfinished.

end

function S = getSelection(S,desired)
%% getSelection
%
% PURPOSE
% function to extract some fields from a structure that contains more fields than
% is needed (since only the fields used are should be in the fieldCopier)
%
% IN
%    S = structure containing the names of data variables that can be read by
%       the fieldCopier, such that fieldnames(S) are the names of the datafields
%       you can read from a data file.
%    
%    desired = {'fields','to','extract'};
%
% USAGE
% e.g., S = getSelection(fields.cloud_cci,fieldnames(fields.cloud_cci),{'iwp','iwp_error'})
%
% Salomon Eliasson

if ~iscell(desired)
    desired = {desired};
end

S = getfields(S, desired{:});

end

function S = collapsed2fc(S)
% convert a structure prepared for a collapser back to one for fieldcopier
%
% useful if fields from a collapser are to be fieldcopied when the
% collapser is used as a base for a new collocated dataset

C = cellfun(...
    @(fn) ...
            cellfun(@(procn) {[procn '_' fn], S.(fn).stored.(procn)}, ...
                    fieldnames(S.(fn).stored), ...
                    'UniformOutput', false), ...
            fieldnames(S), ...
            'UniformOutput', false);
% convert nested cell to flat input for struct
C = vertcat(C{:});
C = vertcat(C{:});
C = flat(C.');
S = struct(C{:});
end

function S = mem2fc(S)
% prepare a fc members-field for another fc's input-field
%
% In practice, this means removing 'realname' and 'dataset'
%
% IN
%
%   S   input structure

S = structfun(...
    @(X) rmfield(X, intersect({'realname', 'dataset'}, fieldnames(X))), ...
    S, ...
    'UniformOutput', false);

end

function stat = ignoreNeG(M, func, dim)
% like ignoreNaN, but ignores where data are negative
M(M<0) = nan;
stat = ignoreNaN(M, func, dim);
end

function C = flagneg(C)
% flag negative data
C(C<0) = nan;
end
