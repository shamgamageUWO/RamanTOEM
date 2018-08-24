function name_struct = cols_cell_to_cols_struct(cols, cols_in)

%% cols_cell_to_cols_struct Convert a cols-cell-array to a cols-structure
%
% Convert a cols cell-array such as {'B_LAT', 'B_LONG', 'B_TIME', 'MHS', 3:5, 'MEAN'}
% into a cols-structure such as S.B_LAT=1, S.B_LONG=2, S.B_TIME=3,
% S.MHS=4:6, S.MEAN=7.
%
% FORMAT
%
%   name_struct = cols_cell_to_cols_struct(col_defs, cols_in)
%
% IN
%
%   col_defs    structure   as colloc_constants('cols_cpr_mhs')
%   cols_in     cell-array  column-names and channel-numbers, as passed to
%                           collocation_read
%
% OUT
%
%   name_struct structure   the names and the correspoding column-numbers
%                           cumulatively
%
% $Id: cols_cell_to_cols_struct.m 7553 2012-04-27 19:08:16Z gerrit $

n = 1; i = 1;
while i <= length(cols_in)
    if i<length(cols_in) && isnumeric(cols_in{i+1})
        dn = length(cols_in{i+1});
        di = 2;
    else
        dn = length(structsearch(cols, cols_in{i}));
        di = 1;
    end
    name_struct.(cols_in{i}) = n:(n+dn-1);
    n = n + dn;
    i = i + di;
end