function S = find_info_from_granule(dataset, fname)

% find_info_from_granule Extract info from a granule filename
%
% FIXME DOC! Explanation below related to old-style, before 2012-02-01.
% New style is configured differently!
%
% For a given dataset and filename, return a structure with information
% extracted from the filename, such as year, month, day. This is just a
% short wrapper around <a href="matlab:help regexp">regexp</a>. If no information
% can be extracted, the result is an empty structure. All structure members
% are string, e.g. no conversions from string to number is done. Members
% that could have been matched but weren't are set to []. Valid
% datasets are those that have a datasets_config('DATASET_regexp') defined,
% which means most of the datasets returned by <a href="matlab:help list_datasets">list_datasets</a>.
% The returned fields are at most those names defined in
% datasets_config('DATASET_regexp').
% Common fields are: year, month, day, doy. But anything matched by the
% regular expression is a field. 
%
% More information about regular expressions at <a href="http://en.wikipedia.org/wiki/Regular_expression">Wikipedia</a>
%
% FORMAT
%
%   S = find_info_from_granule(dataset, fname)
%
% IN
%
%   dataset     string      describing the dataset
%   fname       string      the filename
%
% OUT
%
%   S           structure   members such as 'year', 'month', etc. describe
%                           matched info.
%
% EXAMPLES
%
% Note: these examples depend on particular settings in datasets_config, in
% particular those set by site-specific/kiruna/datasets_init.m
%
% >> find_info_from_granule('cpr', '2006333114032_03133_CS_2B-CWC-RO_GRANULE_P_R04_E02.hdf.zip')
% 
% ans = 
% 
%       year: '2006'
%        doy: '333'
%       hour: '11'
%     minute: '40'
% 
% >> find_info_from_granule('mhs', '56037363.NSS.MHSX.NP.D09284.S1310.E1456.B0348485.GC.gz')
% 
% ans = 
% 
%        hour: '13'
%     satname: []
%      minute: '10'
%        year: []
%       month: []
%         day: []
%
% >> find_info_from_granule('mhs', '/storage3/data/mhs/noaa18_mhs_2009/08/09/56037363.NSS.MHSX.NP.D09284.S1310.E1456.B0348485.GC.gz')
% 
% ans = 
% 
%        hour: '13'
%     satname: 'noaa18'
%      minute: '10'
%        year: '2009'
%       month: '08'
%         day: '09'
%
%
% Feel free to change the regular expressions to return additional
% information, but be sure not to break any existing matches.
% Have fun.
%
% $Id: find_info_from_granule.m 7553 2012-04-27 19:08:16Z gerrit $

D = datasets;
if isfield(D, dataset)
    matchy = D.(dataset).re;
else
    matchy = datasets_config([dataset '_regexp']);
end
S = regexp(fname, matchy, 'names');
