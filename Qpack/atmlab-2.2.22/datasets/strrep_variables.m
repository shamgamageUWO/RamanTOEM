function s_out = strrep_variables(s, satname, datevec)

% strrep_variables Replace 'magic' variables
%
% NOTE: DEPRECATED!  Inside SatDataset, use self.repvar.

%
% Replace the 'magic' variables:
%
% $YEAR4
% $YEAR2
% $MONTH
% $DAY
% $DOY
% $SAT  or  $SAT1 and $SAT2
% $HOUR
% $MINUTE
%
% FORMAT
%
%   s_out = strrep_variables(s, satname, datevec)
%
% IN
%
%   s       string  where magic is replaced
%   satname string/ name of satellite/satellites
%           cellstr
%   datevec vector  date-vector [year month day]
%
% OUT
%
%   s_out   string  with magic replaced
%
% $Id: strrep_variables.m 8516 2013-06-26 21:33:48Z gerrit $

year = num2str(datevec(1), '%04d');
month = num2str(datevec(2), '%02d');
day = num2str(datevec(3), '%02d');
if length(datevec)>3
    hour = num2str(datevec(4), '%02d');
    minute = num2str(datevec(5), '%02d');
else
    hour = '0';
    minute = '0';
end
year02 = year(3:4);
doy = num2str(round(dayofyear(datevec(1), datevec(2), datevec(3))), '%03d');

to_replace = {'$YEAR4', year, '$MONTH', month, '$DAY', day, ...
    '$YEAR2', year02, '$DOY', doy, '$HOUR', hour, '$MINUTE', minute};

if iscellstr(satname)
    to_replace = [to_replace {'$SAT1', satname{1}, '$SAT2', satname{2}}];
else
    if strfind(s, '$SAT1')
        warning('atmlab:strrep_variables', ...
            ['replacing $SAT, but having $SAT1; are you sure you don''t ' ...
             'want to pass TWO satellites?']);
    end
    to_replace = [to_replace {'$SAT', satname}];
end

s_out = strrep_multi(s, to_replace{:});

end
