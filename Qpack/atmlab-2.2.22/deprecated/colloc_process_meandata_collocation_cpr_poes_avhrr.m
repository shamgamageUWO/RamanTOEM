function M_m = colloc_process_meandata_collocation_cpr_poes_avhrr(collocations, M_c, M_d, ...
    name1, date1, data1, ...
    name2, date2, data2)

% colloc_process_meandata_collocation_cpr_poes_avhrr Get averaged info
%
% Considering collocations along with collocation data, get averaged
% AVHRR information per MHS pixel.
%
% Because this function has the same format as other
% colloc_process_meandata_*, some of the arguments are ignored.
%
% FORMAT
%
%   M = process_meandata_collocation_cpr_poes_avhrr(collocations, M_coll, M_data, ...
%       date1, data1, date2, data2)
%
% IN
%
%   collocations    matrix      As returned by collocate
%   M_coll          matrix      As returned by process_cpr_mhs
%   M_data          matrix      As returned by process_data_cpr_mhs
%   name1           string      name of satellite 1
%   date1           1x5 vector  Contains [year month day hour minute] for the
%                               start of the primary granule
%   data1           structure   Fields for brightness temperature should be
%                               present
%   name2           string      name of satellite 2
%   date2           1x5 vector  As date1, but for secondary granule
%   data2           structure   As data1, but for secondary granule.
%
% OUT
%
%   M_m     matrix  Containing averaged data.
%
% $Id: colloc_process_meandata_collocation_cpr_poes_avhrr.m 7553 2012-04-27 19:08:16Z gerrit $

c = colloc_constants('cols_collocation_cpr_mhs_avhrr');

% find unique ones

[uniques, firsts] = unique(M_c(:, c.overlap.CPR_MHS_MEAN_ROW), 'rows', 'first');
lasts = [firsts(2:end)-1; size(M_c, 1)];

M_m = nan*zeros(size(uniques, 1), c.meandata.NCOLS);


j = 0; % counter increases only when there is data
for i = 1:size(uniques, 1) % need to be done in loop due to mean/std/etc.
    first = firsts(i);
    last = lasts(i);
    M_c_part = M_c(first:last, :);
    M_d_part = M_d(first:last, :);
    AVHRR_in_MHS = M_c_part(:, c.overlap.DIST_MHS_AVHRR) < colloc_config('distance_for_average_MHS');
    % put flags to nan
    temps = M_d_part(:, c.data.AVHRR);
    flagged = temps < 0 | isnan(temps);
    flagged_measurement = all(flagged, 2); % all channels flagged
    if all(flagged_measurement | ~AVHRR_in_MHS) % don't bother, all are flagged
        continue
    end
    
    % put flags to nan
    temps(flagged) = nan;
    M_d_part(:, c.data.AVHRR) = temps;
    
    fine = repmat(AVHRR_in_MHS, [1 6]) & ~flagged;
    
    j = j + 1;
    M_m(j, c.meandata.FIRST) = first;
    M_m(j, c.meandata.LAST) = last;
    M_m(j, c.meandata.NO) = sum(fine);
    M_m(j, c.meandata.MEAN) = ignoreNaN(M_d_part(:, c.data.AVHRR), @mean, 1);
    M_m(j, c.meandata.SD) = ignoreNaN(M_d_part(:, c.data.AVHRR), @std, 1);
end

rest = isnan(M_m(:, 1));
M_m(rest, :) = [];
