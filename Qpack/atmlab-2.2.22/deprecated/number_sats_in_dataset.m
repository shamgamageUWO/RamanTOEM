function n = number_sats_in_dataset(d)

% number_sats_in_dataset Number of satellites used to characterise dataset
%
% Some datasets, such as collocations_mhs_mhs, need 2 satellites to
% characterise it; most need only one. This function gives the answer.
%
% FORMAT
%
%   n = number_sats_in_dataset(d)
%
% IN
%
%   d   string      dataset name
%
% OUT
%
%   n   number      number of satellites to characterise
%
% $Id: number_sats_in_dataset.m 7553 2012-04-27 19:08:16Z gerrit $

if strfind(datasets_config([d '_filename']), '$SAT1') % needs two
    n = 2;
else
    n = 1;
end