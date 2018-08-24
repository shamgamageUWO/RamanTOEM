function datasets_init
% DATASETS_INIT list paths and regexp for datasets in Paris Observatory
%
% PURPOSE: See datasets_config
%
% Created by Carlos Jimenez
% $Id: datasets_init.m 2011-09-23 $

datasets_config('sat2netcdf', '/storage4/home/gerrit/downloads/sat2netcdf-0.4.jar');

% to find a datafile: search in basedir/subdir, first try filename with string
% substitution, otherwise list all and try to match regexp.

% to list all granules: listdir basedir/subdir, match regexp, limit to
% matching period

% variables: YEAR, YEAR02, MONTH, DAY, DOY, SAT, SAT1, SAT2
% regexp-output: year, doy, day, hour, minute , end. (end if the file ending)


%% MAIN DATABASE DIR
whereami = '~jimenez/Work/Data/RTStudyData/Collocations';

%% CLOUDSAT DATA SETS

datasets_config('cpr_subdir', '$YEAR4/$DOY');
datasets_config('cpr_regexp', '(?<year>\d{4})(?<doy>\d{3})(?<hour>\d{2})(?<minute>\d{2})\d{2}_.+(?<end>.{8}$)');

datasets_config('cloudsat_2B_GEOPROF_basedir', [ whereami,'/cloudsat/2B-GEOPROF.R04/'] );
datasets_config('cloudsat_2B_GEOPROF_subdir', datasets_config('cpr_subdir'));
datasets_config('cloudsat_2B_GEOPROF_regexp', datasets_config('cpr_regexp'));


datasets_config('cloudsat_2B_CWC_RO_basedir', [ whereami,'/cloudsat/2B-CWC-RO.R04/'] );
datasets_config('cloudsat_2B_CWC_RO_subdir', datasets_config('cpr_subdir'));
datasets_config('cloudsat_2B_CWC_RO_regexp', datasets_config('cpr_regexp'));


datasets_config('cloudsat_ECMWF_AUX_basedir', [ whereami,'/cloudsat/ECMWF-AUX.R04/'] );
datasets_config('cloudsat_ECMWF_AUX_subdir', datasets_config('cpr_subdir'));
datasets_config('cloudsat_ECMWF_AUX_regexp', datasets_config('cpr_regexp'));


datasets_config('cloudsat_2C_PRECIP_COLUMN_basedir', [ whereami,'/cloudsat/2C-PRECIP-COLUMN.R04/'] );
datasets_config('cloudsat_2C_PRECIP_COLUMN_subdir', datasets_config('cpr_subdir'));
datasets_config('cloudsat_2C_PRECIP_COLUMN_regexp', datasets_config('cpr_regexp'));


%% COLLOCATION DATA SETS

datasets_config('collocation_cpr_mhs_basedir', [ whereami,'/collocations_cloudsat_poes']);
datasets_config('collocation_cpr_mhs_subdir', '$YEAR4/$MONTH/$DAY');
datasets_config('collocation_cpr_mhs_filename', 'collocations_$SAT.nc.gz');
datasets_config('firstline_data', [ whereami, '/granules_firstline/firstline_$SAT_$SENSOR.mat']);



