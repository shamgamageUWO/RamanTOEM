function M = colloc_process_data_hirscs_poes(~, M_c, ...
    ~, ~, data1, ~, ~, data2)

% colloc_process_data_hirscs_poes Gather collocation data to store for HIRSCS+MHS
%
% After collocating, and gathering information about the collocations, we
% want to collect some actual data: in this case, brightness temperatures.
%
% FORMAT
%
%   M = colloc_process_data_hirscs_poes(collocations, M_c, ...
%       name1, date1, data1, name2, date2, data2)
%
% IN
%
%   collocations    Nx4 matrix  (not used here)
%   M_c             matrix      As returned by colloc_process_poes_poes
%   name1           string      name of satellite 1 (ignored here)
%   date1           1x5 vector  Contains [year month day hour minute] for the
%                               start of the primary granule (ignored here)
%   data1           structure   Fields for brightness temperature should be
%                               present
%   name2           string      name of satellite 2 (ignored here)
%   date2           1x5 vector  As date1, but for secondary granule
%                               (ignored here)
%   data2           structure   As data1, but for secondary granule.
%
% OUT
%
%   M               Nxp matrix  Matrix containing p fields of information for
%                               all N collocations.
%
% $Id: colloc_process_data_hirscs_poes.m 7553 2012-04-27 19:08:16Z gerrit $

% prepare
c = colloc_constants('cols_hirscs_poes');
co = c.overlap;
c = c.data;
n = size(M_c, 1);
M = nan*zeros(n, c.NCOLS);

% row and column numbers

i1 = M_c(:, co.H_I);
r2 = M_c(:, co.MHS_ROW);
c2 = M_c(:, co.MHS_COL);

% index for direct addressing
i2 = sub2ind(size(data2.lat), r2, c2);

c = colloc_constants('cols_hirscs_poes');
c = c.data;

% reshape so that I can use direct addressing for brightness temperatures

tb2 = reshape(data2.tb, [numel(data2.lat) 5]);

M(:, c.VIS) = data1.vis(i1);
M(:, c.BT) = data1.bt(i1, :);
M(:, c.LC) = data1.lc(i1, :);
M(:, c.MHS) = tb2(i2, :);
