function M = colloc_process_data_x_to_x(~, M_c, ...
    ~, sensor1, ~, data1, ...
    ~, sensor2, ~, data2)

% colloc_process_data_x_to_x Gather collocation data to store for identical sensors
%
% After collocating, and gathering information about the collocations, we
% want to collect some actual data.
%
% FORMAT
%
%   M = colloc_process_data_x_to_x(collocations, M, ...
%       name1, date1, data1, name2, date2, data2)
%
% IN
%
%   collocations    Nx4 matrix  As returned by collocate
%   M_c             matrix      As returned by colloc_process_poes_poes
%   sat1
%   sensor1         string      name of satellite 1
%   date1           1x5 vector  Contains [year month day hour minute] for the
%                               start of the primary granule (ignored here)
%   data1           structure   Fields for brightness temperature should be
%                               present
%   sat2
%   sensor2         string      name of satellite 2
%   date2           1x5 vector  As date1, but for secondary granule
%                               (ignored here)
%   data2           structure   As data1, but for secondary granule.
%
% OUT
%
%   M               Nxp matrix  Matrix containing p fields of information for
%                               all N collocations.
%
% $Id: colloc_process_data_x_to_x.m 7553 2012-04-27 19:08:16Z gerrit $

% Created by Gerrit Holl
%
% $Id: colloc_process_data_x_to_x.m 7553 2012-04-27 19:08:16Z gerrit $

% prepare
c = colloc_constants(sprintf('cols_%s_%s', sensor1, sensor2));

% row and column numbers
r1 = M_c(:, c.overlap.I1);
r2 = M_c(:, c.overlap.I2);
c1 = M_c(:, c.overlap.C1);
c2 = M_c(:, c.overlap.C2);

% index for direct addressing
i1 = sub2ind(size(data1.lat), r1, c1);
i2 = sub2ind(size(data2.lat), r2, c2);

% reshape so that I can use direct addressing for brightness temperatures

tb1 = reshape(data1.tb, numel(data1.lat), []);
tb2 = reshape(data2.tb, numel(data2.lat), []);

%% store info

M = [tb1(i1, :) tb2(i2, :)];
