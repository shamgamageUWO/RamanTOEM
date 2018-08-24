function value = datasets_constants(c)

% datasets_constants Defines (pseudo)-constants for datasets
%
% This m-file defines values required by functions in the datasets subsystem.
% It differs from datasets_config in the manner that the values here should
% not normally be changed. If called without arguments, returns
% the entire structure containing all properties and values.
%
% FORMAT
%
%   value = datasets_constants(c)
%
% IN
%
%   c   string      the property asked for (optional)
%
% OUT
%
%   v   (any)       the value of property c or the entire struct
%
% $Id: datasets_constants.m 8251 2013-03-01 14:04:24Z gerrit $


%% all POES satellites with MHS/AMSUB

A.POES_satellite_names = {'noaa15', 'noaa16', 'noaa17', 'noaa18', 'noaa19', 'metopa'};
A.POES_satellite_numbers = [15 16 17 18 19 29499]; % for metopa, use NORAD number
A.POES_satellites_amsub = {'noaa15', 'noaa16', 'noaa17', 'N15', 'N16', 'N17'};
A.POES_satellites_mhs = {'noaa18', 'noaa19', 'metopa', 'N18', 'N19', 'MA'};

%% all sats with SSMT2

A.DMSP_satellite_names = {'F11', 'F12', 'F14', 'F15'};

%% define what reading function to use for what sensor

A.read_cpr = @satreaders.cpr_2BCWCRO;
A.read_mhs = @satreaders.poes_radiometer;
A.read_amsua = @satreaders.poes_radiometer;
A.read_amsub = @satreaders.poes_radiometer;
A.read_hirs = @satreaders.poes_radiometer;
A.read_avhrr = @satreaders.avhrr;
A.read_hirscs = @satreaders.hirscs;
A.read_collocation_cpr_poes = @satreaders.collocation_cpr_mhs;
A.read_collocation_cpr_mhs = @satreaders.collocation_cpr_mhs;

%% define approximate granule durations

% by sensor rather than by satellite, because not all sensors are saved in
% the same chunks; in particular, stored collocations belong to a certain
% satellite (pair), but are stored per day

A.granule_duration_mhs = 6130; % seconds; upper estimate
A.granule_duration_amsua = 6130;
A.granule_duration_amsub = 6130;
A.granule_duration_hirs = 6130;
A.granule_duration_avhrr = 6130; 

A.granule_duration_cpr = 5932; % seconds

A.granule_duration_hirscs = 86400; % one granule per da
A.granule_duration_collocation_cpr_poes = 86400;
A.granule_duration_collocation_cpr_mhs = 86400;

%% define viewing angles

% source:
% NOAA KLM User's Guide, Appendix J
% http://www.ncdc.noaa.gov/oa/pod-guide/ncdc/docs/klm/html/j/app-j.htm

A.angles_avhrr_gac = linspace(-55.37, 55.37, 409);
A.angles_mhs = linspace(-49.4444, 49.4444, 90);
A.angles_amsub = linspace(-48.95, 48.95, 90);

%% define flags to pass to sat2netcdf

A.sat2netcdf_flags = '-nogui -latlon -temperature -quality -calibration -metadata';

if exist('c', 'var')
    value = A.(c);
else
    value = A;
end


