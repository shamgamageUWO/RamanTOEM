% ISATMDATA   Determines if the variable is of atmdata type
%
%   Atmdata is a format for storing atmospheric climatology data. The gformat 
%   is used where the dimensions are pressure, latitude, longitude, day and
%   hour. That is, up to five dimensions can be used.
%
%   Three options exist for the day dimension:
%      'mjd'     : Modified julian date.
%      'doy'     : Day of the year. Valid range is [1,367[. See also *mjd2doy*.
%      'datenum' : Matlab's datenum (with default pivot year).
%
%   The valid range for hour is [0,24]. This dimesion refers to local
%   (solar) time.
%
%   The identification of atmdata is performed by checking the TYPE field and
%   grid names. These fields of G must be set as follows: 
%     TYPE = 'atmdata'
%     GRID1_NAME = 'pressure'
%     GRID2_NAME = 'latitude'
%     GRID3_NAME = 'longitude'
%     GRID4_NAME = 'doy', 'mjd' or 'datenum'
%     GRID5_NAME = 'hour'. 
  
%   Only used grids are checked (determined by G(i).DIM). No distinction is 
%   made between lower- and upper-case letters.
%
%   There is NO check of actual data beside the grid names.
%
%   Functions specific for atmdata are named as atmdata_xxx. MJD is expected
%   when the input of these functions include any date.
%
% FORMAT   b = isatmdata( G )
%        
% OUT   b     True or false.
% IN    G     A gformat structure (array).

% 2010-01-07   Created by Patrick Eriksson.

function b = isatmdata( G )

b = false;

if ~isstruct(G) ||  ~isfield(G,'DIM'), return, end

Gt = atmdata_empty( max( G(:).DIM ) );

if ~all( isfield( G, fieldnames(Gt) ) ), return, end

for i = 1 : length(G)

  if ~strcmp( lower(G(i).TYPE), 'atmdata' )
    return
  end

  for d = 1 : min([ G(i).DIM 3 ] )
    gname = sprintf( 'GRID%d_NAME', d );
    if ~strcmp( lower(G(i).(gname)), lower(Gt.(gname)) )
      return
    end
  end
  if G(i).DIM >= 4
    gname = sprintf( 'GRID%d_NAME', 4 );
    if ~any( strcmp( lower(G(i).(gname)), {'doy','mjd','datenum'} ) )
      return
    end
    if G(i).DIM >= 5
      gname = sprintf( 'GRID%d_NAME', 5 );
    if ~strcmp( lower(G(i).(gname)), lower(Gt.(gname)) )
      return
    end
  end
  end
    
    
end

b = true;

