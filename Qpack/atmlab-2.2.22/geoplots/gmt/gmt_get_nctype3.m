function nc_type = gmt_get_nctype3(variable)
% GMT_GET_NCTYPE3  Returns the netcdf type of var
% Returns the netcdf type of var for necdf3
%
% OUT nc_type    string containing the netcdf type
% IN  var    input data whos type will be determined
%
% Created by Salomon Eliasson
% $Id: gmt_get_nctype.m 6862 2011-04-17 20:27:55Z seliasson $


str = struct('logical','BYTE','int8','BYTE',...
'int16' ,'SHORT',...
'int32' ,'INT',...
'single','FLOAT',...
'double','DOUBLE',...
'int64' ,'INT64');

notsupported={'uint8','uint16','uint32','uint64'};

assert(~ismember(class(variable),notsupported),['atmlab:' mfilename ''],....
    'data type: ''%s'' is not supported by netcdf3',class(variable))

if isfield(str,class(variable))
    nc_type = str.(class(variable));
else
    error(sprintf('gmtlab:%s:input',mfilename),...
        'Class %s has no corresponding netcdf type',class(variable))
end

