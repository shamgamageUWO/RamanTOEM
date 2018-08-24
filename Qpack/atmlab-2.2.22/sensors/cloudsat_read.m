% CLOUDSAT_READ   Reads CloudSat HDF data files.
%
%    The function reads data from single files. The data are provided as a
%    single structure having field names taken from the HDF data. For
%    example, 
%       P=cloudsat_read(filename,{'Latitude','Longitude','Sigma_Zero'})
%    gives
%       P =
%            Latitude: [37081x1 double]
%           Longitude: [37081x1 double]
%          Sigma_Zero: [37081x1 double]
%
%    Some field names are renamed as the corresponding name in HDF can not
%    be used in matlab. For example, 'Sigma-Zero' is renamed to
%    'Sigma_Zero'.
%
%    Data for field name renaming and unit conversions are hard-coded. The
%    following file types are handled so far:
%       2B-GEOPROF
%
%    Data are scaled to consider scaling factors and "non-standard"
%    units. The data are returned using the following units:
%      g, m, dB and deg
%
%    The data are returned as double precision variables, sorted in such
%    way that each row corresponds to a position. For example, the cloud 
%    mask at position i is: P.CPR_Cloud_mask(i,:)
%
%    The fields existing in a file are obtained as
%       fieldnames = cloudsat_read(filename,[],'fields');
%
%    The reading can be restricted in several ways.  To only read data for
%    the positions with index *ind*:
%       P = cloudsat_read(filename,[],'index',ind);
%    To only read data inside latitudes [-30,30]:
%       P = cloudsat_read(filename,[],'lat',[-30 30]);
%    To only read data inside longitudes [0,180]:
%       P = cloudsat_read(filename,[],'lon',[0 180]);
%    Note that the range [-180,180] is used for longitudes. To only read 
%    data inside leg 2:
%       P = cloudsat_read(filename,[],'leg',2);
%    The orbit is divided into legs, where the start and end of the orbit
%    an latitude turning points are taken as limits of the legs. An orbit
%    has accordingly three legs, where e.g. leg 1 extends from the orbit 
%    start to the turning point in the South pole area.
%       The latitude, longitude and leg options can be combined in pairs,
%    such as:
%       P = cloudsat_read(filename,[],'leg',2,'lat',[-30 30]);
%
%   The reading can be restricted to a rectangular latitude/longitude area.
%   To read "tropical" data for the eastern hemisphere:
%        fieldnames = cloudsat_read(filename,[],'lat',[-30 30],'lon',[0 180]);
%   Longitude limits can be left out. Default for longitude limits is 
%   [-180 180]. 
%
%    The function is based on CPR_L1B_rdr2 (unknown author). Send bug
%    reports, suggestions or improvements to patrick.eriksson@chalmers.se
%
% FORMAT   P = cloudsat_read(filename[,fieldlist,choice1,c1arg,choice2,c2arg])
%        
% OUT   P
% IN    filename    Name of file to read.
% OPT   fieldlist   Name of fields to read, as a cell array of strings.
%                   Default is [], which results in that all fields are
%                   read.
%       choice1     Optional choice 1. See above.
%       c1arg       Arguments for optional choice 1. See above.
%       choice2     Optional choice 2. See above.
%       c2arg       Arguments for optional choice 2. See above.
%
% INFO: If you want to instead read the cloudsat data as it is (i.e. no scaling,
%       converting, etc.), use read_cloudsat_hdf directly. The function also
%       outputs the variable attributes of the fields you wish to retrieve as a
%       second output argument 
%
% $Id: cloudsat_read.m 7716 2012-07-09 09:36:13Z gerrit $
% 2007-10-24   Created by Patrick Eriksson.


function P = cloudsat_read(filename,fieldlist,choice1,c1arg,choice2,c2arg)
  
%- Check input
%
if ~ischar( filename )
  error( 'Input argument *filename* must be a string' );
end
%
if ~exist( filename, 'file' );
  P = 'File not found.';
  return
end
%
%
if nargin < 2
  fieldlist = [];
end
%
if ~( isempty( fieldlist )  |  iscellstr( fieldlist ) )
  error( ...
     'Input argument *fieldlist* must be empty or a cell array of strings.' );
end
%
if nargin < 3
  choice1 = [];
elseif ~ischar( choice1 )
  error( 'Input argument *choice1* must be a string' );
else
  choice1 = lower( choice1 );
  %
  if ~( strcmp(choice1,'fields')  |  strcmp(choice1,'index')  |  ...
        strcmp(choice1,'lat')     |  strcmp(choice1,'lon')  |  ...
        strcmp(choice1,'leg') )
    error( ['Valid options for *choice1* are: ''fields'', ''index'', ',...
            '''lat'', ''lon'' and ''leg''.'] );
  end
end
%
if nargin < 5
  choice2 = [];
elseif ~ischar( choice2 )
  error( 'Input argument *choice2* must be a string' );
else
  choice2 = lower( choice2 );
  %
  if ~( strcmp(choice2,'lat')     |  strcmp(choice2,'lon')  |  ...
        strcmp(choice2,'leg') )
    error( ['Valid options for *choice1* are: ''lat'', ''lon'', ',...
            'and ''leg''.'] );
  end
end


%- Get information about the file 
%
fileinfo = hdfinfo( filename, 'eos' );
%
allfields = { fileinfo.Swath.GeolocationFields.Name, ...
             fileinfo.Swath.DataFields.Name };

%- Handle empty *fieldlist* and choice1=='fields* option
%
if isempty( fieldlist )  |  strcmp( choice1, 'fields' )

  if strcmp( choice1, 'fields' )
    P = rename_fields( allfields, 1 );
    return
  end

  hdfnames  = allfields;
  fieldlist = rename_fields( hdfnames, 1 );

else
  hdfnames = rename_fields( fieldlist );
end


%- Determine index for data points to keep
%
iout = [];
%
if ~isempty( choice1 )
  
  %- Index pre-defined
  if strcmp( choice1, 'index' )
    iout = c1arg;
    clear c1arg;
  
  %- Filtering according to leg, lat and lon
  else

    P = cloudsat_read( filename, {'Latitude','Longitude'} );
    
    %- leg
    if strcmp( choice1, 'leg' )  |  strcmp( choice2, 'leg' )
      if strcmp( choice1, 'leg' )
        if ~( isnumeric(c1arg) & isvector(c1arg) & length(c1arg)==1 )
          error( '*c1arg* must for ''leg'' option be a vector of length 1.' );
        end
        leg = c1arg;
      else
        if ~( isnumeric(c2arg) & isvector(c2arg) & length(c2arg)==1 )
          error( '*c2arg* must for ''leg'' option be a vector of length 1.' );
        end
        leg = c2arg;
      end
      %
      if leg == 1
        i1     = 1;
        [u,i2] = min( P.Latitude );
      elseif leg == 2
        [u,i1] = min( P.Latitude ); i1 = i1 + 1;
        [u,i2] = max( P.Latitude );
      elseif leg == 3
        [u,i1] = max( P.Latitude ); i1 = i1 + 1;
        i2     = length( P.Latitude );
      else
        error( 'Possible choices for leg index are 1, 2 and 3.' );
      end
      inleg        = zeros( length(P.Latitude), 1 );
      inleg(i1:i2) = 1;
    else
      inleg = ones( length(P.Latitude), 1 );
    end   
  
    %- latitude
    if strcmp( choice1, 'lat' )  |  strcmp( choice2, 'lat' )
      if strcmp( choice1, 'lat' )
        if ~( isnumeric(c1arg) & isvector(c1arg) & length(c1arg)==2 )
          error( '*c1arg* must for ''lat'' option be a vector of length 2.' );
        end
        latlims = c1arg;
      else  
        if ~( isnumeric(c2arg) & isvector(c2arg) & length(c2arg)==2 )
          error( '*c2arg* must for ''lat'' option be a vector of length 2.' );
        end
        latlims = c2arg;
      end
    else
      latlims = [-90 90 ];
    end   

    %- longitude
    if strcmp( choice1, 'lon' )  |  strcmp( choice2, 'lon' )
      if strcmp( choice1, 'lon' )
        if ~( isnumeric(c1arg) & isvector(c1arg) & length(c1arg)==2 )
          error( '*c1arg* must for ''lon'' option be a vector of length 2.' );
        end
        lonlims = c1arg;
      else  
        if ~( isnumeric(c2arg) & isvector(c2arg) & length(c2arg)==2 )
          error( '*c2arg* must for ''lon'' option be a vector of length 2.' );
        end
        lonlims = c2arg;
      end
    else
      lonlims = [-180 180 ];
    end   

    iout = inleg & ...
        P.Latitude  >= latlims(1) & P.Latitude  <= latlims(2) & ...
        P.Longitude >= lonlims(1) & P.Longitude <= lonlims(2);
    
    if isempty(iout)
      P = 'No data matching reading restrictions.';
      return
    end
  end
end



%- Read data
%
% The reading routines cause a lot of warnings (at least in Matlab 7). Turn
% off these warnings temporariliy.
%
% Some files appear to be corrupted and cause error. Use try/catch.
%
warning( 'off', 'MATLAB:hdfwarn:generic' );
P = [];

%
try
    P = read_cloudsat_hdf(fileinfo.Filename,fieldlist);
    for F = fieldlist
        % convention to make everything double
        if ~ischar(P.(F{1}))
            P.(F{1}) = double(P.(F{1}));
        end
        % convention to make all vectors column vectors
        if isvector(P.(F{1}))
            P.(F{1}) = P.(F{1})(:);
        end
        % apply conditions
        if ~isempty(iout) && ( isvector(P.(F{1})) || ismatrix(P.(F{1})) )
            P.(F{1}) = P.(F{1})(iout,:);
        end
    end
catch ME
    P = sprintf('Error while reading file.: %s\n',ME.message);
    warning('MATLAB:hdfwarn:generic','%s',P);
end

if ischar( P )
  return
end


%- Factor and offset 
%
attributes = strvcat(fileinfo.Swath.Attributes.Name);
for it=1:length(fieldlist)
  ifactor = strmatch([hdfnames{it} '.factor'],attributes);
  ioffset = strmatch([hdfnames{it} '.offset'],attributes);
  iunit   = strmatch([hdfnames{it} '.units'],attributes);
  if ~isempty(iunit)
    unit=fileinfo.Swath.Attributes(iunit).Value;
    unit=unitconv(unit,hdfnames{it});
  else
    unit=1;
  end

  if ~isempty(ifactor) & ~isempty(ioffset) 
     factor = double(fileinfo.Swath.Attributes(ifactor).Value(1));
     offset = double(fileinfo.Swath.Attributes(ioffset).Value(1));
     P.(fieldlist{it}) = (P.(fieldlist{it})/factor - offset)*unit;
  end
end

  
return




%--- Sub functions ---------------------------------------------------------

%--- Conversion of field names
%
% Renaming information stored in internal variable *table*. Default is
% conversion from matlab to HDF names.
%
% OUT   names       Renamed field names
% IN    names       Original field names
%       backwards   Set to true for conversion to matlab names. Default
%                   is false.
%  
function names = rename_fields( names, backwards )

  if nargin < 2, backwards = 0; end  

  %- Renaming table
  %
  % HDF name in column 1, matlab name in column 2
  %
  table{1} = { 'Sigma-Zero', 'Sigma_Zero' };
  
  if backwards
    iout = 2;
    iin  = 1;
  else
    iout = 1;
    iin  = 2;
  end

  for it = 1 : length(table)
    ind = find( strcmp( names, table{it}{iin} ) );
    if ~isempty( ind )
      names{ind} = table{it}{iout};
    end
  end

return


%--- Unit conversion 
%
% Conversion information stored in internal variable *table*. 
%  
function u=unitconv(unit,field)

% Make sure that *unit* is a row vector (can be column for old HDF versions)
%
unit = vec2row( unit );
  
if strcmp(unit,['mg m^{-3}']) |  strcmp(unit,['mg/m^3'])
   u=1e-3;
elseif strcmp(unit,['um'])
   u=1e-6;
elseif strcmp(unit,['degrees'])
   u=1;
elseif strcmp(unit,['m'])  |  strcmp(unit,['/m'])
   u=1;
elseif strcmp(unit,['meters'])
   u=1;
elseif strcmp(unit,['dBZe'])  |  strcmp(unit,['dbz'])  |  strcmp(unit,['dBZ'])
   u=1;
elseif strcmp(unit,['dB*100'])
   u=1e-2;
elseif strcmp(unit,['km'])
   u=1e3;
elseif strcmp(unit,['1/km'])  |  strcmp(unit,['/km'])
   u=1e-3;
elseif strcmp(unit,['seconds'])
   u=1;
elseif strcmp(unit,['--'])  |  strcmp(unit,['none'])  |  strcmp(unit,['None'])
   u=1;
elseif strcmp(unit,['%'])
   u=1;
elseif strcmp(unit,['g m^{-2}'])  |  strcmp(unit,['g/m^2'])
   u=1;
elseif strcmp(unit,['K'])
   u=1;
elseif strcmp(unit,['L^{-1}'])
   u=1e3;
elseif strcmp(unit,['cm^{-3}'])
   u=1e6;
elseif strcmp(unit,['Pa'])
   u=1;
elseif strcmp(unit,['kg/kg']) |  strcmp(unit,['kg kg**-1']) 
   u=1;
else 
   u=1;
   warning( 'cloudsat_read:unknownUnit', ...
        ['Could not identify field type unit in subfunction unitconv. ',...
	     'No unit conversion performed for ',field,'. ',...
	     'Unit is in ',unit,'.'] );
end

return
