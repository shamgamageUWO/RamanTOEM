function M = colloc_process_meandata_cpr_mhs(~, M_coll, M_data, ~, ~, ~, ~)

% colloc_process_meandata_cpr_mhs Get averaged CPR per MHS pixel
%
% Considering collocations along with collocation data, get averaged
% information per MHS pixel.
%
% Because this function has the same format as other
% colloc_process_meandata_*, some of the arguments are ignored.
%
% FORMAT
%
%   M = process_meandata_cpr_mhs(collocations, M_coll, M_data, ...
%       date1, data1, date2, data2)
%
% IN
%
%   (ignored)
%   M_coll  matrix  As returned by process_cpr_mhs
%   M_data  matrix  As returned by process_data_cpr_mhs
%
% OUT
%
%   M       matrix  Containing averaged data.
%
% $Id$

c = colloc_constants('cols_cpr_mhs');

% find unique ones

[uniques, firsts] = unique(M_coll(:, [c.overlap.B_TIME c.overlap.B_C]), 'rows', 'first');
lasts = [firsts(2:end)-1; size(M_coll, 1)];

M = nan*zeros(size(uniques, 1), c.meandata.NCOLS);

j = 0; % counter increases only when there is data
for i = 1:size(uniques, 1) % need to be done in loop due to mean/std/etc.
    first = firsts(i);
    last = lasts(i);
    M_coll_part = M_coll(first:last, :);
    M_data_part = M_data(first:last, :);
    CS_in_MHS = M_coll_part(:, c.overlap.B_DIST) < colloc_config('distance_for_average_MHS');
    CS_in_HIRS = M_coll_part(:, c.overlap.H_DIST) < colloc_config('distance_for_average_HIRS');
    flagged = M_data_part(:, c.data.ROIWP) < 0;
    
    if all(flagged | ~CS_in_MHS) % don't bother, all are flagged
        continue
    end
    
    fine = CS_in_MHS & ~flagged;
    
    j = j + 1;
    M(j, c.meandata.FIRST) = first;
    M(j, c.meandata.LAST) = last;
    M(j, c.meandata.NO) = sum(fine);
    M(j, c.meandata.MEAN) = mean(M_data_part(fine, c.data.ROIWP));
    M(j, c.meandata.SD) = std(M_data_part(fine, c.data.ROIWP));
    M(j, c.meandata.CV) = M(j, c.meandata.SD) ./ M(j, c.meandata.MEAN);
    M(j, c.meandata.FRAC) = sum(M_data_part(fine, c.data.ROIWP)>0) / M(j, c.meandata.NO);
    M(j, c.meandata.INHIRS) = sum(fine&CS_in_HIRS);
end

rest = isnan(M(:, 1));
M(rest, :) = [];
