function datasets_init
% DATASETS_INIT define paths and regexp for datasets in Kiruna
%
% 
%
% Created by Gerrit Holl
% $Id: datasets_init.m 8749 2013-12-07 17:27:33Z seliasson $

%datasets_config('sat2netcdf', '/storage4/home/gerrit/downloads/2010/05/sat2netcdf-0.4.jar');

% to find a datafile: search in basedir/subdir, first try filename with string
% substitution, otherwise list all and try to match regexp.

% to list all granules: listdir basedir/subdir, match regexp, limit to
% matching period

% variables: YEAR, YEAR02, MONTH, DAY, DOY, SAT, SAT1, SAT2
% regexp-output: year, doy, day, hour, minute , end. (end if the file ending)

if ~define_datasets('check')
    define_datasets;
end

D = datasets;

%% datasets generated elsewhere

% -------
% active
% -------
D.calipso.basedir = '/storage3/data/calipso/CAL_LID_L2_05kmCLay-Prov-V3-01';
D.calipso.subdir = '$YEAR4/$MONTH/$DAY';
D.calipso.re = '(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})T(?<hour>\d{2})-(?<minute>\d{2})-(?<second>\d{2})Z';

D.cpr.basedir = '/storage3/data/cloudsat/2B-CWC-RO.R04';
D.cpr.subdir = '$YEAR4/$DOY';
D.cpr.re = '(?<year>\d{4})(?<doy>\d{3})(?<hour>\d{2})(?<minute>\d{2})\d{2}_(?<granule_number>\d{5})_CS_(?<product_name>[\dA-Z\-]*)_(?<subset>[A-Z]*)_(?<id>[A-Z])_(?<release>R[0-9]{2})_(?<epoch>E\d{2})(?<end>\.hdf.zip)';

D.CPR_RVOD.basedir = '/storage3/data/cloudsat/2B-CWC-RVOD.R04';
D.CPR_RVOD.subdir = D.cpr.subdir;
D.CPR_RVOD.re = D.cpr.re;

D.cprCloud.basedir = '/storage3/data/cloudsat/2B-CLDCLASS.R04';
D.cprCloud.subdir = D.cpr.subdir;
D.cprCloud.re = D.cpr.re;

D.cprCloudLidar.basedir = '/storage3/data/cloudsat/2B-CLDCLASS-LIDAR.R04';
D.cprCloudLidar.subdir = D.cpr.subdir;
D.cprCloudLidar.re = D.cpr.re;

D.CPR_2C_ICE.basedir = '/storage3/data/cloudsat/2C-ICE.R04';
D.CPR_2C_ICE.subdir = D.cpr.subdir;
D.CPR_2C_ICE.re = D.cpr.re;

D.CPR_ECMWF.basedir = '/storage3/data/cloudsat/ECMWF-AUX.R04';
D.CPR_ECMWF.subdir = D.cpr.subdir;
D.CPR_ECMWF.re = D.cpr.re;

D.dardar.basedir = '/storage3/data/dardar';
D.dardar.subdir = '$YEAR4/$YEAR4_$MONTH_$DAY';
D.dardar.re = 'DARDAR-CLOUD_v(?<version>.+)_(?<year>\d{4})(?<doy>\d{3})(?<hour>\d{2})(?<minute>\d{2})';

% Matlab doesn't seem to support nested groups, so have to stick with
% |-approach instead. Same regexp works for all POES.
poes_re = '(?<satname>[a-z0-9]{6})_(?<type>[a-z0-9]+)_(?<year>\d{4})/(?<month>\d{2})/(?<day>\d{2})/[A-Z0-9.]+\.S(?<hour>\d{2})(?<minute>\d{2})|\.S(?<hour>\d{2})(?<minute>\d{2})';

% ---------
% Passive
% --------

D.avhrr.basedir = '/storage3/data/avhrr';
D.avhrr.subdir = '$SAT_gac_$YEAR4/$MONTH/$DAY';
D.avhrr.re = poes_re;

D.avhrr_cmsaf_gac.basedir = '/storage3/data/cmsaf_avhrr_gac_cwp/';
D.avhrr_cmsaf_gac.subdir = '$YEAR4/$MONTH/$DAY';
D.avhrr_cmsaf_gac.re = 'RR_AVHRR_L2_cp_(?<satname>[A-Z0-9]{6})_(?<year>\d{4})(?<month>\d{2})(?<day>\d{2})_(?<hour>\d{2})(?<minute>\d{2})_v(?<version>\d{1})';

D.amsua.basedir = '/storage3/data/amsu';
D.amsua.subdir = '$SAT_amsua_$YEAR4/$MONTH/$DAY';
D.amsua.re = poes_re;

D.amsub.basedir = '/storage3/data/amsu';
D.amsub.subdir = '$SAT_amsub_$YEAR4/$MONTH/$DAY';
D.amsub.re = poes_re;

D.cloud_cci.basedir = '/storage3/data/cloud_cci/ESACCI-L2_CLOUD-CLD_PRODUCTS-AVHRRGAC';
D.cloud_cci.subdir = '$SAT/$YEAR4/$MONTH/$DAY';
D.cloud_cci.re = '(?<year>\d{4})(?<month>\d{2})(?<day>\d{2})(?<hour>\d{2})(?<minute>\d{2})';

D.gras_per_day.basedir = '/storage5/data/gras';
D.gras_per_day.subdir = ''; % subdirs are the actual 'granules'
D.gras_per_day.filename = '$YEAR4-$MONTH-$DAY';
D.gras_per_day.re = '(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})';

D.hirs.basedir = '/storage3/data/hirs';
D.hirs.subdir = '$SAT_hirs_$YEAR4/$MONTH/$DAY';
D.hirs.re = poes_re;

D.isccp_dx.basedir = '/storage3/data/isccp/dx/';
D.isccp_dx.subdir = '$YEAR4/$MONTH/$DAY';
D.isccp_dx.re = 'ISCCP\.DX\.[0-2]\.(?<satname>.+)\.(?<year>\d{4})\.(?<month>\d{2})\.(?<day>\d{2})\.zip';

D.mirs.basedir = '/storage3/data/mirs/';
D.mirs.subdir = '$SAT_$YEAR4/$MONTH/$DAY';
D.mirs.re = '\.D(?<year02>\d{2})(?<doy>\d{3})\.S(?<hour>\d{2})(?<minute>\d{2})\.E';

D.mhs.basedir = '/storage3/data/mhs';
D.mhs.subdir = '$SAT_mhs_$YEAR4/$MONTH/$DAY';
D.mhs.re = poes_re;

D.modis_aqua_L2.basedir = '/storage3/data/modis/MYD06_L2/';
D.modis_aqua_L2.subdir = '$YEAR4/$MONTH/$DAY';
D.modis_aqua_L2.re = 'MYD06_L2\.A(?<year>\d{4})(?<doy>\d{3})\.(?<hour>\d{2})(?<minute>\d{2})\.(?<version>\d{3})';

D.modis_L3.basedir = '/storage3/data/modis/$SAT08_M3';
D.modis_L3.subdir = '$YEAR4';
D.modis_L3.re = '(?<satname>[A-Z]{3})08_M3.A(?<year>\d{4})(?<doy>\d{3})\.(?<version>\d{3})';

D.mspps.basedir = '/storage3/data/mspps/';
D.mspps.subdir = '$SAT_orbital_$YEAR4/$MONTH/$DAY';
D.mspps.re = '(?<satname>[a-z0-9]{6})_(?<type>[a-z0-9]+)_(?<year>\d{4})/(?<month>\d{2})/(?<day>\d{2})/[A-Z0-9.]+\.S(?<hour>\d{2})(?<minute>\d{2})|\.S(?<hour>\d{2})(?<minute>\d{2})';

D.patmosx.basedir = '/storage3/data/patmosx/level2b/';
D.patmosx.subdir = '$SAT_$YEAR4';
D.patmosx.re = 'patmosx_(?<satname>[a-z0-9]{3})_asc_(?<year>\d{4})_(?<doy>\d{3})_v(?<version>\d{2}).+(?<end>.{7})$';

D.saphir_l1a.basedir = '/storage3/data/meghatropiques/saphir_l1a';
D.saphir_l1a.subdir = '$YEAR4/$MONTH/$DAY';
D.saphir_l1a.re = 'MT1SAPSL1A__(?<version>\d\.\d{2})_\d_\d\d_I_(?<year>\d{4})_(?<month>\d\d)_(?<day>\d\d)_(?<orbitno>\d{5})_(?<orbitno2>\d{5})_00\.h5\.gz$';

D.saphir_l1a2.basedir = '/storage3/data/meghatropiques/saphir_l1a2';
D.saphir_l1a2.subdir = '$YEAR4/$MONTH/$DAY';
D.saphir_l1a2.re = 'MT1SAPSL1A2_(?<version>\d\.\d{2})_\d\d\d_\d_\d\d_I_(?<year>\d{4})_(?<month>\d\d)_(?<day>\d\d)_(?<hour>\d\d)_(?<minute>\d\d)_(?<second>\d\d)_(?<year2>\d{4})_(?<month2>\d\d)_(?<day2>\d\d)_(?<hour2>\d\d)_(?<minute2>\d\d)_(?<second2>\d\d)_(?<orbitno>\d{5})_(?<orbitno2>\d{5})_\d\d\d_\d\d_\d\d_.{3}_\d\d\.h5\.gz$';

D.saphir_l2a.basedir = '/storage3/data/meghatropiques/saphir_l2a';
D.saphir_l2a.subdir = '$YEAR4/$MONTH/$DAY';
D.saphir_l2a.re = 'MT1SAPS_(?<version>\d\.\d{2})_\d_\d\d_I_(?<year>\d{4})_(?<month>\d\d)_(?<day>\d\d)_(?<orbitno>\d{5})_(?<orbitno2>\d{5})_00_GP_\d\.\d\d_L2A\.h5';

D.ssmt2.basedir = '/storage3/data/ssmt_ngdc';
D.ssmt2.subdir = '$SAT/$YEAR4/$MONTH/$DAY';
D.ssmt2.filename = '$SAT$YEAR4$MONTH$DAY$HOUR$MINUTE.T2.gz';
D.ssmt2.re = '(?<satname>F[0-9]{2})(?<year>\d{4})(?<month>\d{2})(?<day>\d{2})(?<hour>\d{2})(?<minute>\d{2})\.T2\.gz';

D.CFSR.basedir = '/storage3/user_data/gerrit/reanalysis_per_day';
D.CFSR.subdir = '$YEAR4/$MONTH/$DAY';
D.CFSR.filename = 'T_surf.nc';
D.CFSR.re = D.CFSR.filename;

%% Non-collocated home-made

D.dardarsub.basedir = '/storage3/data/dardar_subsel';
D.dardarsub.subdir = '$YEAR4/$MONTH/$DAY';
D.dardarsub.re = D.dardar.re;

D.cmoiwp.basedir = sprintf('/storage4/user_data/gerrit/cmoiwp/v%03.1f', D.cmoiwp.version);
D.cmoiwp.subdir = '$YEAR4/$MONTH/$DAY';
D.cmoiwp.filename = '$SAT_$YEAR4_$MONTH_$DAY_$HOUR_$MINUTE.nc.gz';
D.cmoiwp.re = '(?<satname>[a-z0-9]{6})_(?<year>\d{4})_(?<month>\d{2})_(?<day>\d{2})_(?<hour>\d{2})_(?<minute>\d{2})';

for v = {'v0_0', 'v0_1', 'v0_2', 'v0_3', 'v0_4', 'v0_5', 'v0_6'}
    ds = D.(sprintf('cmoiwp_%s', v{1}));
    ds.basedir = sprintf('/storage4/user_data/gerrit/cmoiwp/%s', strrep(v{1}, '_', '.'));
    ds.subdir = D.cmoiwp.subdir;
    ds.filename = D.cmoiwp.filename;
    ds.re = D.cmoiwp.re;
end

D.c2dp_mhs.basedir = '/storage3/user_data/gerrit/collocated_datasets/c2dp';
D.c2dp_mhs.subdir = '$YEAR4/$MONTH/$DAY';
D.c2dp_mhs.filename = 'c2dp_fullday_$SAT.nc.gz';

D.c2dp_amsub.basedir = D.c2dp_mhs.basedir;
D.c2dp_amsub.subdir = D.c2dp_mhs.subdir;
D.c2dp_amsub.filename = D.c2dp_mhs.filename;

D.cdpc_2dcp.basedir = '/storage3/user_data/gerrit/collocated_datasets/cdpc_2dcp';
D.cdpc_2dcp.subdir = '$YEAR4/$DOY';

%% Level 3 DATASETS (not for collocating)
D.patmosxL3.basedir   = '/storage3/data/patmosx/level3';
D.patmosxL3.subdir    = '$YEAR4/$MONTH/';
D.patmosxL3.re        = 'patmosx_aft_mor_.+(?<year>\d{4})';

%% COLLOCATION DATA SETS

% MW datasets

D.collocation_mhs_mhs.basedir   = '/storage4/user_data/gerrit/collocated_datasets/poes/mhs_mhs';
D.collocation_mhs_mhs.subdir    = '$YEAR4/$MONTH/$DAY';
D.collocation_mhs_mhs.filename  = 'collocations_$SAT1_$SAT2.nc.gz';

D.collocation_amsub_mhs.basedir   = '/storage4/user_data/gerrit/collocated_datasets/poes/amsub_mhs';
D.collocation_amsub_mhs.subdir    = '$YEAR4/$MONTH/$DAY';
D.collocation_amsub_mhs.filename  = 'collocations_$SAT1_$SAT2.nc.gz';

D.collocation_mhs_amsub.basedir   = '/storage4/user_data/gerrit/collocated_datasets/poes/mhs_amsub';
D.collocation_mhs_amsub.subdir    = '$YEAR4/$MONTH/$DAY';
D.collocation_mhs_amsub.filename  = 'collocations_$SAT1_$SAT2.nc.gz';

D.collocation_amsub_amsub.basedir   = '/storage4/user_data/gerrit/collocated_datasets/poes/amsub_amsub';
D.collocation_amsub_amsub.subdir    = '$YEAR4/$MONTH/$DAY';
D.collocation_amsub_amsub.filename  = 'collocations_$SAT1_$SAT2.nc.gz';

D.collocation_mhs_saphir.basedir = '/storage3/user_data/gerrit/collocated_datasets/mhs_saphir';
D.collocation_mhs_saphir.subdir = '$YEAR4/$MONTH/$DAY';
D.collocation_mhs_saphir.filename = 'collocations_$SAT.nc.gz';

D.collocation_amsub_saphir.basedir = '/storage3/user_data/gerrit/collocated_datasets/amsub_saphir';
D.collocation_amsub_saphir.subdir = '$YEAR4/$MONTH/$DAY';
D.collocation_amsub_saphir.filename = 'collocations_$SAT.nc.gz';

D.collocation_ssmt2_ssmt2.basedir = '/storage3/user_data/gerrit/collocated_datasets/ssmt2_ssmt2';
D.collocation_ssmt2_ssmt2.subdir = '$YEAR4/$MONTH/$DAY';
D.collocation_ssmt2_ssmt2.filename = 'collocations_$SAT1_$SAT2.nc.gz';

D.collocation_ssmt2_mhs.basedir = '/storage3/user_data/gerrit/collocated_datasets/ssmt2_mhs';
D.collocation_ssmt2_mhs.subdir = '$YEAR4/$MONTH/$DAY';
D.collocation_ssmt2_mhs.filename = 'collocations_$SAT1_$SAT2.nc.gz';

D.collocation_ssmt2_amsub.basedir = '/storage3/user_data/gerrit/collocated_datasets/ssmt2_amsub';
D.collocation_ssmt2_amsub.subdir = '$YEAR4/$MONTH/$DAY';
D.collocation_ssmt2_amsub.filename = 'collocations_$SAT1_$SAT2.nc.gz';

D.collocation_gras_amsua.basedir = '/storage3/user_data/gerrit/collocated_datasets/gras_amsua';
D.collocation_gras_amsua.subdir = '$YEAR4/$MONTH/$DAY';
D.collocation_gras_amsua.filename = 'collocations_$SAT.nc.gz';

% CPR as reference

D.CollocatedDataset_avhrrCMSAF_cpr.basedir   = '/storage4/user_data/seliasson/collocations_avhrrCMSAF_cpr/core';
D.CollocatedDataset_avhrrCMSAF_cpr.subdir    = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_avhrrCMSAF_cpr.filename  = 'collocations_avhrrCMSAF_cpr_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_calipso_cpr.basedir     = '/storage4/user_data/seliasson/collocations_calipso_cpr/core';
D.CollocatedDataset_calipso_cpr.subdir      = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_calipso_cpr.filename    = 'collocations_calipso_cpr_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_cmoiwp_v0_4_cpr.basedir      = '/storage4/user_data/seliasson/collocations_cmoiwp_v0_4_cpr/core';
D.CollocatedDataset_cmoiwp_v0_4_cpr.subdir       = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_cmoiwp_v0_4_cpr.filename     = 'collocations_cmoiwp_v0_4_cpr_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_cmoiwp_v0_3_cpr_cpr.basedir  = '/storage4/user_data/seliasson/collocations_cmoiwp_v0_3_cpr/core';
D.CollocatedDataset_cmoiwp_v0_3_cpr_cpr.subdir   = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_cmoiwp_v0_3_cpr_cpr.filename  = 'collocations_cmoiwp_v0_3_cpr$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_cpr_dardarsub.basedir   = '/storage4/user_data/seliasson/collocations_cpr_dardarsub/core';
D.CollocatedDataset_cpr_dardarsub.subdir    = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_cpr_dardarsub.filename  = 'collocations_cpr_dardarsub_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_cpr_modis.basedir   = '/storage4/user_data/seliasson/collocations_cpr_modis/core';
D.CollocatedDataset_cpr_modis.subdir    = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_cpr_modis.filename  = 'collocations_cpr_modis_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_mhs_cpr.basedir   = '/storage4/user_data/gerrit/collocated_datasets/mhs_cpr';
D.CollocatedDataset_mhs_cpr.subdir    = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_mhs_cpr.filename  = 'collocations_$SAT.nc.gz';

D.CollocatedDataset_amsub_cpr.basedir = '/storage4/user_data/gerrit/collocated_datasets/amsub_cpr';
D.CollocatedDataset_amsub_cpr.subdir    = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_amsub_cpr.filename  = 'collocations_$SAT.nc.gz';

D.CollocatedDataset_mspps_cpr.basedir   = '/storage4/user_data/seliasson/collocations_mspps_cpr/core';
D.CollocatedDataset_mspps_cpr.subdir    = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_mspps_cpr.filename  = 'collocations_mspps_cpr_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_mirs_cpr.basedir   = '/storage4/user_data/seliasson/collocations_mirs_cpr/core';
D.CollocatedDataset_mirs_cpr.subdir    = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_mirs_cpr.filename  = 'collocations_mirs_cpr_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_patmosx_cpr.basedir   = '/storage4/user_data/seliasson/collocations_patmosx_cpr/core';
D.CollocatedDataset_patmosx_cpr.subdir    = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_patmosx_cpr.filename  = 'collocations_patmosx_cpr_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

% DARDAR as reference

D.CollocatedDataset_avhrrCMSAF_dardarsub.basedir   = '/storage4/user_data/seliasson/collocations_avhrrCMSAF_dardarsub/core';
D.CollocatedDataset_avhrrCMSAF_dardarsub.subdir    = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_avhrrCMSAF_dardarsub.filename  = 'collocations_avhrrCMSAF_dardarsub_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_calipso_dardarsub.basedir     = '/storage4/user_data/seliasson/collocations_calipso_dardarsub/core';
D.CollocatedDataset_calipso_dardarsub.subdir      = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_calipso_dardarsub.filename    = 'collocations_calipso_dardarsub_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_cmoiwp_v0_6_dardarsub.basedir      = '/storage4/user_data/seliasson/collocations_cmoiwp_v0_6_dardarsub/core';
D.CollocatedDataset_cmoiwp_v0_6_dardarsub.subdir       = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_cmoiwp_v0_6_dardarsub.filename     = 'collocations_cmoiwp_v0_6_dardarsub_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_cmoiwp_v0_4_dardarsub.basedir      = '/storage4/user_data/seliasson/collocations_cmoiwp_v0_4_dardarsub/core';
D.CollocatedDataset_cmoiwp_v0_4_dardarsub.subdir       = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_cmoiwp_v0_4_dardarsub.filename     = 'collocations_cmoiwp_v0_4_dardarsub_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_cloud_cci_dardarsub.basedir    = '/storage4/user_data/seliasson/cloud_cci_dardarsub/core';
D.CollocatedDataset_cloud_cci_dardarsub.subdir     = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_cloud_cci_dardarsub.filename   = 'core_cloud_cci_dardarsub_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_dardarsub_modis.basedir   = '/storage4/user_data/seliasson/dardarsub_modis/core';
D.CollocatedDataset_dardarsub_modis.subdir    = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_dardarsub_modis.filename  = 'core_dardarsub_modis_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_hirs_dardarsub.basedir   = '/storage4/user_data/seliasson/collocations_hirs_dardarsub/core';
D.CollocatedDataset_hirs_dardarsub.subdir    = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_hirs_dardarsub.filename  = 'collocations_hirs_dardarsub_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_mhs_dardarsub.basedir   = '/storage4/user_data/seliasson/collocations_mhs_dardarsub/core';
D.CollocatedDataset_mhs_dardarsub.subdir    = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_mhs_dardarsub.filename  = 'collocations_mhs_dardarsub_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_mspps_dardarsub.basedir   = '/storage4/user_data/seliasson/collocations_mspps_dardarsub/core';
D.CollocatedDataset_mspps_dardarsub.subdir    = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_mspps_dardarsub.filename  = 'collocations_mspps_dardarsub_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_mirs_dardarsub.basedir   = '/storage4/user_data/seliasson/collocations_mirs_dardarsub/core';
D.CollocatedDataset_mirs_dardarsub.subdir    = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_mirs_dardarsub.filename  = 'collocations_mirs_dardarsub_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_patmosx_dardarsub.basedir   = '/storage4/user_data/seliasson/collocations_patmosx_dardarsub/core';
D.CollocatedDataset_patmosx_dardarsub.subdir    = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_patmosx_dardarsub.filename  = 'collocations_patmosx_dardarsub_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

% -------------------------------
% Collocated collocated datasets
% -------------------------------

D.CollocatedDataset_dardarsub_modis_cprCloud.basedir    = '/storage4/user_data/seliasson/dardarsub_modis_cprCloud/core';
D.CollocatedDataset_dardarsub_modis_cprCloud.subdir     = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_dardarsub_modis_cprCloud.filename   = 'core_dardarsub_modis_cprCloud_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_dardarsub_modis_cprCloudLidar.basedir  = '/storage4/user_data/seliasson/dardarsub_modis_cprCloudLidar/core';
D.CollocatedDataset_dardarsub_modis_cprCloudLidar.subdir   = '$YEAR4/$MONTH/$DAY'; 
D.CollocatedDataset_dardarsub_modis_cprCloudLidar.filename = 'core_dardarsub_modis_cprCloudLidar_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.Collocated_cacmah_avhrr.basedir = '/storage4/user_data/gerrit/collocated_datasets/cacmah_avhrr';
D.Collocated_cacmah_avhrr.subdir = '$YEAR4/$MONTH/$DAY';
D.Collocated_cacmah_avhrr.filename = 'cacmah_avhrr_$SAT1_$SAT2.nc.gz';

D.associated_cacmah_avhrr.basedir = '/storage4/user_data/gerrit/collocated_datasets/cacmah_avhrr';
D.associated_cacmah_avhrr.subdir = '$YEAR4/$MONTH/$DAY';
D.associated_cacmah_avhrr.filename = 'cacmah_avhrr_fulldata_$SAT1_$SAT2.nc.gz';

D.collapsed_cacmah_avhrr.basedir = '/storage4/user_data/gerrit/collocated_datasets/cacmah_avhrr';
D.collapsed_cacmah_avhrr.subdir = '$YEAR4/$MONTH/$DAY';
D.collapsed_cacmah_avhrr.filename = 'cacmah_avhrr_collapsed_$SAT1_$SAT2.nc.gz';

%% Associated datasets
% ----------------------

D.associated_CPR_MHS_AMSU_HIRS.basedir = '/storage3/user_data/gerrit/collocated_datasets/mhs_cpr';
D.associated_CPR_MHS_AMSU_HIRS.subdir = '$YEAR4/$MONTH/$DAY';
D.associated_CPR_MHS_AMSU_HIRS.filename = 'fulldata_$SAT.nc.gz';

D.associated_CPR_AMSUB_AMSUA_HIRS.basedir = '/storage3/user_data/gerrit/collocated_datasets/amsub_cpr';
D.associated_CPR_AMSUB_AMSUA_HIRS.subdir = '$YEAR4/$MONTH/$DAY';
D.associated_CPR_AMSUB_AMSUA_HIRS.filename = 'fulldata_$SAT.nc.gz';

D.associated_mhs_mhs.basedir = '/storage3/user_data/gerrit/collocated_datasets/poes/mhs_mhs';
D.associated_mhs_mhs.subdir = D.collocation_mhs_mhs.subdir;
D.associated_mhs_mhs.filename = 'fulldata_$SAT1_$SAT2.nc.gz';
D.associated_mhs_amsub.basedir = '/storage3/user_data/gerrit/collocated_datasets/poes/mhs_amsub';
D.associated_mhs_amsub.subdir = D.collocation_mhs_amsub.subdir;
D.associated_mhs_amsub.filename = 'fulldata_$SAT1_$SAT2.nc.gz';
D.associated_amsub_mhs.basedir = '/storage3/user_data/gerrit/collocated_datasets/poes/amsub_mhs';
D.associated_amsub_mhs.subdir = D.collocation_amsub_mhs.subdir;
D.associated_amsub_mhs.filename = 'fulldata_$SAT1_$SAT2.nc.gz';
D.associated_amsub_amsub.basedir = '/storage3/user_data/gerrit/collocated_datasets/poes/amsub_amsub';
D.associated_amsub_amsub.subdir = D.collocation_amsub_amsub.subdir;
D.associated_amsub_amsub.filename = 'fulldata_$SAT1_$SAT2.nc.gz';

D.associated_ssmt2_amsub.basedir = D.collocation_ssmt2_amsub.basedir;
D.associated_ssmt2_amsub.subdir = D.collocation_ssmt2_amsub.subdir;
D.associated_ssmt2_amsub.filename = 'fulldata_$SAT1_$SAT2.nc.gz';

D.associated_ssmt2_mhs.basedir = D.collocation_ssmt2_mhs.basedir;
D.associated_ssmt2_mhs.subdir = D.collocation_ssmt2_mhs.subdir;
D.associated_ssmt2_mhs.filename = 'fulldata_$SAT1_$SAT2.nc.gz';

D.associated_ssmt2_ssmt2.basedir = D.collocation_ssmt2_ssmt2.basedir;
D.associated_ssmt2_ssmt2.subdir = D.collocation_ssmt2_ssmt2.subdir;
D.associated_ssmt2_ssmt2.filename = 'fulldata_$SAT1_$SAT2.nc.gz';

D.associated_mhs_saphir.basedir = '/storage3/user_data/gerrit/collocated_datasets/mhs_saphir';
D.associated_mhs_saphir.subdir = '$YEAR4/$MONTH/$DAY';
D.associated_mhs_saphir.filename = 'fulldata_$SAT.nc.gz';

D.associated_gras_amsua.basedir = D.collocation_gras_amsua.basedir;
D.associated_gras_amsua.subdir = D.collocation_gras_amsua.subdir;
D.associated_gras_amsua.filename = 'fulldata_$SAT.nc.gz';

D.associated_amsub_saphir.basedir = '/storage3/user_data/gerrit/collocated_datasets/amsub_saphir';
D.associated_amsub_saphir.subdir = '$YEAR4/$MONTH/$DAY';
D.associated_amsub_saphir.filename = 'fulldata_$SAT.nc.gz';

D.cloud_cci_dardarsub_ice_clouds.basedir   = '/storage4/user_data/seliasson/cloud_cci_dardarsub/ice_clouds';
D.cloud_cci_dardarsub_ice_clouds.subdir    = '$YEAR4/$MONTH/$DAY';
D.cloud_cci_dardarsub_ice_clouds.filename  = 'fields_cloud_cci_dardarsub_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.cloud_cci_dardarsub_closest_ice_clouds.basedir  = '/storage4/user_data/seliasson/cloud_cci_dardarsub/closest_ice_clouds';
D.cloud_cci_dardarsub_closest_ice_clouds.subdir   = '$YEAR4/$MONTH/$DAY';
D.cloud_cci_dardarsub_closest_ice_clouds.filename = 'collapsed_cloud_cci_dardarsub_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.collapsed_associated_CPR_MHS_AMSU_HIRS.basedir = D.associated_CPR_MHS_AMSU_HIRS.basedir;
D.collapsed_associated_CPR_MHS_AMSU_HIRS.subdir = D.associated_CPR_MHS_AMSU_HIRS.subdir;
D.collapsed_associated_CPR_MHS_AMSU_HIRS.filename = 'collapsed_$SAT.nc.gz';

D.collapsed_associated_CPR_AMSUB_AMSUA_HIRS.basedir = D.associated_CPR_AMSUB_AMSUA_HIRS.basedir;
D.collapsed_associated_CPR_AMSUB_AMSUA_HIRS.subdir = D.associated_CPR_AMSUB_AMSUA_HIRS.subdir;
D.collapsed_associated_CPR_AMSUB_AMSUA_HIRS.filename = D.collapsed_associated_CPR_MHS_AMSU_HIRS.filename;

D.collapsed_gras_amsua.basedir = D.associated_gras_amsua.basedir;
D.collapsed_gras_amsua.subdir = D.associated_gras_amsua.subdir;
D.collapsed_gras_amsua.filename = 'collapsed_$SAT.nc.gz';

D.cpr_dardarsub_IWP.basedir     = '/storage4/user_data/seliasson/collocations_cpr_dardarsub/cpr_dardarsub_IWP';
D.cpr_dardarsub_IWP.filename    = 'collocations_cpr_dardarsub_$YEAR4_$MONTH_$DAY.nc.gz';
D.cpr_dardarsub_IWP.subdir      = '$YEAR4/$MONTH/$DAY';

D.cpr_dardarsub_cloudTypes.basedir  = strrep(D.cpr_dardarsub_IWP.basedir,'IWP','cloudTypes');
D.cpr_dardarsub_cloudTypes.filename = D.cpr_dardarsub_IWP.filename;
D.cpr_dardarsub_cloudTypes.subdir   = D.cpr_dardarsub_IWP.subdir;

% -  this will be deprecated when 'dardarsub_modis_ice_clouds' is fully run
D.dardarsub_modis_IWP.basedir   = '/storage4/user_data/seliasson/dardarsub_modis/IWP';
D.dardarsub_modis_IWP.filename  = 'fields_dardarsub_modis_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';
D.dardarsub_modis_IWP.subdir    = '$YEAR4/$MONTH/$DAY';

D.dardarsub_modis_collapsedIWP.basedir  = '/storage4/user_data/seliasson/dardarsub_modis/collapsedIWP';
D.dardarsub_modis_collapsedIWP.filename = 'collapsed_dardarsub_modis_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';
D.dardarsub_modis_collapsedIWP.subdir   = '$YEAR4/$MONTH/$DAY';
% --

D.dardarsub_modis_ice_clouds.basedir   = '/storage4/user_data/seliasson/dardarsub_modis/ice_clouds';
D.dardarsub_modis_ice_clouds.filename  = 'fields_dardarsub_modis_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';
D.dardarsub_modis_ice_clouds.subdir    = '$YEAR4/$MONTH/$DAY';

D.dardarsub_modis_closest_ice_clouds.basedir  = '/storage4/user_data/seliasson/dardarsub_modis/closest_ice_clouds';
D.dardarsub_modis_closest_ice_clouds.filename = 'collapsed_dardarsub_modis_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';
D.dardarsub_modis_closest_ice_clouds.subdir   = '$YEAR4/$MONTH/$DAY';

D.dardarsub_modis_cprCloud.basedir  = '/storage4/user_data/seliasson/dardarsub_modis_cprCloud/IWP_per_cloudType';
D.dardarsub_modis_cprCloud.subdir   = '$YEAR4/$MONTH/$DAY';
D.dardarsub_modis_cprCloud.filename = 'fields_dardarsub_modis_cprCloud_$YEAR4_$MONTH_$DAY.nc.gz';

D.dardarsub_modis_cprCloudLidar.basedir = '/storage4/user_data/seliasson/dardarsub_modis_cprCloudLidar/IWP_per_cloudType-lidar';
D.dardarsub_modis_cprCloudLidar.subdir  = '$YEAR4/$MONTH/$DAY';
D.dardarsub_modis_cprCloudLidar.filename= 'fields_dardarsub_modis_cprCloudLidar_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.dardarsub_modis_cprCloudLidar_closest.basedir = '/storage4/user_data/seliasson/dardarsub_modis_cprCloudLidar/closest';
D.dardarsub_modis_cprCloudLidar_closest.subdir  = '$YEAR4/$MONTH/$DAY';
D.dardarsub_modis_cprCloudLidar_closest.filename= 'closest_dardarsub_modis_cprCloudLidar_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.fields_2C_ice_dardarsub.basedir  = '/storage4/user_data/seliasson/collocations_cpr_dardarsub/2C-ICE_dardarsub';
D.fields_2C_ice_dardarsub.filename = 'fields_2C-ICE_dardarsub_$YEAR4_$MONTH_$DAY.nc.gz';
D.fields_2C_ice_dardarsub.subdir   = D.cpr_dardarsub_IWP.subdir;

D.fields_CPR_LWP_added_to_dardar.basedir  = '/storage4/user_data/seliasson/collocations_cpr_dardarsub/LWP';
D.fields_CPR_LWP_added_to_dardar.subdir   = '$YEAR4/$MONTH/$DAY';
D.fields_CPR_LWP_added_to_dardar.filename = 'LWP_$YEAR4_$MONTH_$DAY.nc.gz';

D.hirs_dardarsub.basedir    = strrep(D.CollocatedDataset_hirs_dardarsub.basedir,'core',D.hirs_dardarsub.name);
D.hirs_dardarsub.subdir     = '$YEAR4/$MONTH/$DAY';
D.hirs_dardarsub.filename   = 'collocations_hirs_dardarsub_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.mhs_dardarsub.basedir    = strrep(D.CollocatedDataset_mhs_dardarsub.basedir,'core',D.mhs_dardarsub.name);
D.mhs_dardarsub.subdir     = '$YEAR4/$MONTH/$DAY';
D.mhs_dardarsub.filename   = 'collocations_mhs_dardarsub_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

datasets_config('firstline_data', '/storage3/data/granules_firstline/firstline_$SAT_$SENSOR.mat');

datasets_config('blacklist', '/storage3/user_data/gerrit/blacklist_$SAT_$SENSOR.dat');

%% DEPRECATED STYLE

if atmlab('LEGACY_MODE')
    datasets_config('amsua_basedir', '/storage3/data/amsu');
    datasets_config('amsua_subdir', '$SAT_amsua_$YEAR4/$MONTH/$DAY');
    % Matlab doesn't seem to support nested groups, so have to stick with
    % |-approach instead. Same regexp works for all POES.
    datasets_config('amsua_regexp', '(?<satname>[a-z0-9]{6})_(?<type>[a-z0-9]+)_(?<year>\d{4})/(?<month>\d{2})/(?<day>\d{2})/[A-Z0-9.]+\.S(?<hour>\d{2})(?<minute>\d{2})|\.S(?<hour>\d{2})(?<minute>\d{2})');
    
    datasets_config('amsub_basedir', '/storage3/data/amsu');
    datasets_config('amsub_subdir', '$SAT_amsub_$YEAR4/$MONTH/$DAY');
    datasets_config('amsub_regexp', datasets_config('amsua_regexp'));
    
    datasets_config('avhrr_basedir', '/storage3/data/avhrr');
    datasets_config('avhrr_subdir', '$SAT_gac_$YEAR4/$MONTH/$DAY');
    datasets_config('avhrr_regexp', datasets_config('amsua_regexp'));
    
    
    % OLD STYLE
    datasets_config('cpr_basedir', '/storage3/data/cloudsat/2B-CWC-RO.R04');
    datasets_config('cpr_subdir', '$YEAR4/$DOY');
    datasets_config('cpr_regexp', '(?<year>\d{4})(?<doy>\d{3})(?<hour>\d{2})(?<minute>\d{2})\d{2}_.+(?<end>.{8}$)');
    
    % same regexp works for all CloudSat's
    datasets_config('cloudsat_1B_CPR_basedir', '/storage3/data/cloudsat/1B-CPR.R04/');
    datasets_config('cloudsat_1B_CPR_subdir', datasets_config('cpr_subdir'));
    datasets_config('cloudsat_1B_CPR_regexp', datasets_config('cpr_regexp'));
    
    datasets_config('cloudsat_2B_GEOPROF_basedir', '/storage3/data/cloudsat/2B-GEOPROF.R04/' );
    datasets_config('cloudsat_2B_GEOPROF_subdir', datasets_config('cpr_subdir'));
    datasets_config('cloudsat_2B_GEOPROF_regexp', datasets_config('cpr_regexp'));
    
    datasets_config('cloudsat_2B_CWC_RO_basedir', datasets_config('cpr_basedir'));
    datasets_config('cloudsat_2B_CWC_RO_subdir', datasets_config('cpr_subdir'));
    datasets_config('cloudsat_2B_CWC_RO_regexp', datasets_config('cpr_regexp'));
    
    datasets_config('cloudsat_2B_CWC_RVOD_basedir', '/storage3/data/cloudsat/2B-CWC-RVOD.R04/');
    datasets_config('cloudsat_2B_CWC_RVOD_subdir', datasets_config('cpr_subdir'));
    datasets_config('cloudsat_2B_CWC_RVOD_regexp', datasets_config('cpr_regexp'));
    
    
    datasets_config('cloudsat_2C_PRECIP_COLUMN_basedir', '/storage3/data/cloudsat/2C-PRECIP-COLUMN.R04/');
    datasets_config('cloudsat_2C_PRECIP_COLUMN_subdir', datasets_config('cpr_subdir'));
    datasets_config('cloudsat_2C_PRECIP_COLUMN_regexp', datasets_config('cpr_regexp'));
    
    datasets_config('cloudsat_ECMWF_AUX_basedir', '/storage3/data/cloudsat/ECMWF-AUX.R04');
    datasets_config('cloudsat_ECMWF_AUX_subdir', datasets_config('cpr_subdir'));
    datasets_config('cloudsat_ECMWF_AUX_regexp', datasets_config('cpr_regexp'));
    
    
    datasets_config('hirs_basedir', '/storage3/data/hirs');
    datasets_config('hirs_subdir', '$SAT_hirs_$YEAR4/$MONTH/$DAY');
    datasets_config('hirs_regexp', datasets_config('amsua_regexp'));
    
    datasets_config('hirscs_basedir', '/storage3/data/hirscs');
    datasets_config('hirscs_subdir', 'LC_$SAT');
    datasets_config('hirscs_filename', 'HIRS.$SAT.Y$YEAR2.D$DOY.nc.gz');
    datasets_config('hirscs_regexp', '\.Y(?<year02>\d{2})\.D(?<doy>\d{3})\.');
    
    datasets_config('mhs_basedir', '/storage3/data/mhs');
    datasets_config('mhs_subdir', '$SAT_mhs_$YEAR4/$MONTH/$DAY');
    datasets_config('mhs_regexp', datasets_config('amsua_regexp'));
    
    
    % OLD STYLE
    datasets_config('collocation_cpr_mhs_basedir', '/storage4/user_data/gerrit/archived/201011_collocations_cloudsat_mhs');
    datasets_config('collocation_cpr_mhs_subdir', '$YEAR4/$MONTH/$DAY');
    datasets_config('collocation_cpr_mhs_filename', 'collocations_$SAT.nc.gz');
    
    datasets_config('collocation_cpr_mhs_hdf5_basedir', '/local/gerrit/data/collocations_hdf5/collocations_cloudsat_mhs');
    datasets_config('collocation_cpr_mhs_hdf5_subdir', '');
    datasets_config('collocation_cpr_mhs_hdf5_filename', '$SAT_$YEAR4.h5');
    
    datasets_config('collocation_cpr_mhs_legacy_basedir', '/storage4/user_data/gerrit/archived/20100308_collocations_cloudsat_poes/');
    datasets_config('collocation_cpr_mhs_legacy_subdir', '$YEAR4/$MONTH/$DAY');
    datasets_config('collocation_cpr_mhs_legacy_filename', 'collocations_$SAT.mat');
    
    datasets_config('collocation_cpr_mhs_data_legacy_basedir', '/storage4/user_data/gerrit/archived/20100308_collocations_cloudsat_poes/');
    datasets_config('collocation_cpr_mhs_data_legacy_subdir', '$YEAR4/$MONTH/$DAY');
    datasets_config('collocation_cpr_mhs_data_legacy_filename', 'collocations_data_$SAT.mat');
    
    datasets_config('collocation_cpr_mhs_meandata_legacy_basedir', '/storage4/user_data/gerrit/archived/20100308_collocations_cloudsat_poes/');
    datasets_config('collocation_cpr_mhs_meandata_legacy_subdir', '$YEAR4/$MONTH/$DAY');
    datasets_config('collocation_cpr_mhs_meandata_legacy_filename', 'collocations_meandata_$SAT.mat');
    
    datasets_config('collocation_mhs_mhs_basedir', '/storage4/user_data/gerrit/archived/201007-201203_collocations_poes_poes');
    datasets_config('collocation_mhs_mhs_subdir', '$YEAR4/$MONTH/$DAY');
    datasets_config('collocation_mhs_mhs_filename', 'collocations_$SAT1_$SAT2.nc.gz');
    
    datasets_config('collocation_mhs_mhs_legacy_basedir', '/storage4/user_data/gerrit/collocations_mhs_mhs');
    datasets_config('collocation_mhs_mhs_legacy_subdir', '$YEAR4/$MONTH/$DAY');
    datasets_config('collocation_mhs_mhs_legacy_filename', 'collocations_$SAT1_$SAT2.mat');
    
    datasets_config('collocation_mhs_mhs_data_legacy_basedir', '/storage4/user_data/gerrit/archived/201011_collocations_mhs_mhs');
    datasets_config('collocation_mhs_mhs_data_legacy_subdir', '$YEAR4/$MONTH/$DAY');
    datasets_config('collocation_mhs_mhs_data_legacy_filename', 'collocations_data_$SAT1_$SAT2.mat');
    
    datasets_config('collocation_cpr_avhrr_basedir', '/storage4/user_data/gerrit/archived/201011_collocations_cpr_avhrr');
    datasets_config('collocation_cpr_avhrr_subdir', '$YEAR4/$MONTH/$DAY');
    datasets_config('collocation_cpr_avhrr_filename', 'collocations_$SAT.nc.gz');
    
    datasets_config('collocation_hirscs_mhs_basedir', '/storage4/user_data/gerrit/archived/201007_collocations_hirscs_mhs');
    datasets_config('collocation_hirscs_mhs_subdir', '$YEAR4/$MONTH/$DAY');
    datasets_config('collocation_hirscs_mhs_filename', 'collocations_$SAT1_$SAT2.nc.gz');
    
    datasets_config('collocation_hirscs_mhs_legacy_basedir', '/storage4/user_data/gerrit/collocations_hirscs_mhs');
    datasets_config('collocation_hirscs_mhs_legacy_subdir', '$YEAR4/$MONTH/$DAY');
    datasets_config('collocation_hirscs_mhs_legacy_filename', 'collocations_$SAT1_$SAT2.mat');
    
    datasets_config('collocation_hirscs_mhs_data_legacy_basedir', '/storage4/user_data/gerrit/collocations_hirscs_mhs');
    datasets_config('collocation_hirscs_mhs_data_legacy_subdir', '$YEAR4/$MONTH/$DAY');
    datasets_config('collocation_hirscs_mhs_data_legacy_filename', 'collocations_data_$SAT1_$SAT2.mat');
    
    datasets_config('collocation_amsua_amsua_basedir', '/storage4/user_data/gerrit/archived/201106_collocations_amsua_amsua');
    datasets_config('collocation_amsua_amsua_subdir', '$YEAR4/$MONTH/$DAY');
    datasets_config('collocation_amsua_amsua_filename', 'collocations_$SAT1_$SAT2.nc.gz');
    
    datasets_config('collocation_hirs_hirs_basedir', '/storage4/user_data/gerrit/archived/201106_collocations_hirs_hirs');
    datasets_config('collocation_hirs_hirs_subdir', '$YEAR4/$MONTH/$DAY');
    datasets_config('collocation_hirs_hirs_filename', 'collocations_$SAT1_$SAT2.nc.gz');
    
    
    datasets_config('collocation_collocation_cpr_mhs_avhrr_basedir', '/storage4/user_data/gerrit/archived/201010_collocations_collocation_cpr_mhs_avhrr');
    datasets_config('collocation_collocation_cpr_mhs_avhrr_subdir', '$YEAR4/$MONTH/$DAY');
    datasets_config('collocation_collocation_cpr_mhs_avhrr_filename', 'collocations_$SAT1_$SAT2.nc.gz');
end
end
