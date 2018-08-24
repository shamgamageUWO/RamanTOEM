% SSMI_READ_1TBFILE   Loads Tb data from one file.
%
%    This is the core file to read SSM/I brightness temperatures.
%
%    The function reads data from files with names:
%       fxx_Tb_yyddd_ppZ.hdf
%    and corresponding geolocation files (_ln_ and _hn_, instead of _Tb_),
%    where 
%       xx    is the satellite id number
%       yyddd is the date; year(yy) and day (ddd)
%       pp    is the pass number (01-29)
%       Z     is direction (A-ascending or D-descending)
%
%     Files can be obtained from ghrc.msfc.nasa.gov by anonymous access.
%     The files are found in folders:
%       cd pub/data/ssmi-fXX/current-tb/hdf-swath/YY.DDD
%
%     See further the document SSMI-TBs.pdf found on the web, or at the
%     ftp given above.
%
%     The function reads all data in the file that match given limits, set
%     by the optional arguments. For example, to limit the latitude range
%     considered, set e.g. *lats* = [-30 30]. Default values give all
%     data flagged to be OK.
%
% FORMAT   C = ssmi_read_1tbfile(infolder,satnr,year,filedoy,passnr,
%                                          [channels,doys,tods,lats,lons,sfts])
%        
% OUT   C   Structure with fields:
%              TB    Brightness temperature
%              LAT   Latitude
%              LON   Longitude
%              SFT   Surface type
%              PSD   Pass direction ('a'=ascending, 'd'=descending)
%           All fields, except PSD, are vectors.
% IN    infolder   Path to folder with HDf files.
%       satnr      Satellite id number (e.g. 15).
%       filedoy    File day of year .
%       passnr     Pass number.
% OPT   channels   Channels to read:
%                     1 : 19 GHz V
%                     2 : 19 GHz H
%                     3 : 22 GHz V
%                     4 : 37 GHz V
%                     5 : 37 GHz H
%                     6 : 85 GHz V
%                     7 : 85 GHz H
%                  Default is 1:7.
%        doys      Day of year to keep. Default is *fildoy* + [-1 1].
%        tods      Time of day to keep [s]. Default is 0 to 25 h (in seconds).
%        lats      Latitudes to keep. Default is [-90 90].
%        lons      Longitudes to keep. Default is [-180 180].
%        sfts      Surface types to keep:
%                     <0 : Missing or questionable data.
%                      0 : Land.
%                      1 : Vegetation/land.
%                      2 : Near-coast.
%                      3 : Ice.
%                      4 : Possible ice.
%                      5 : Water.
%                      6 : Coast.
%                      7 : Not used.

% 2004-03-16   Created by Patrick Eriksson.


function C = ssmi_read_1tbfile(infolder,satnr,year,filedoy,passnr,varargin)
%
[channels,doys,tods,lats,lons,sfts] = optargs( varargin, ...
{ 1:7, filedoy+[-1 1], [0 25*60*60], [-90 90], [-180 180], [-99 99] } );
%
rqre_nargin( 5, nargin );                                               %&%


%= Create file names
%
filestart = fullfile( infolder, ['f',int2str(satnr),'_'] );
fileendA  = sprintf( '_%02d%03d_%02dA.hdf', year, filedoy, passnr );
fileendD  = sprintf( '_%02d%03d_%02dD.hdf', year, filedoy, passnr );

%= Check if it is an ascending or descending passage
%
filetb    = [ filestart, 'Tb', fileendA ];
if exist( filetb, 'file' )
  fileend = fileendA;
  passdir = 'a';
else
  filetb    = [ filestart, 'Tb', fileendD ];
  if exist( filetb, 'file' )
    fileend = fileendD;
    passdir = 'd';
  else
    error( sprintf('Could not find Tb file matching %s', ...
                                             filetb(1:(length(filetb)-5) ) ) );
  end
end

%= Check that geolocation files exist and read data
%
filehn    = [ filestart, 'hn', fileend ];
fileln    = [ filestart, 'ln', fileend ];
%
if any( channels ) <= 5  &  ~exist( fileln, 'file' )
  error( sprintf('Could not find file %s', fileln ) );
else
  DOY_ln = hdfread( fileln, 'Data-Set-2' );
  TOD_ln = hdfread( fileln, 'Data-Set-3' );
  LAT_ln = double( hdfread( fileln, 'Data-Set-4' ) ) / 100;
  LON_ln = double( hdfread( fileln, 'Data-Set-5' ) ) / 100;
  SFT_ln = hdfread( fileln, 'Data-Set-6' );
end
%
if any( channels ) >= 6  &  ~exist( filehn, 'file' )
  error( sprintf('Could not find file %s', filehn ) );
else
  DOY_hn = double( hdfread( filehn, 'Data-Set-2' ) );
  TOD_hn = double( hdfread( filehn, 'Data-Set-3' ) );
  LAT_hn = double( hdfread( filehn, 'Data-Set-4' ) ) / 100;
  LON_hn = double( hdfread( filehn, 'Data-Set-5' ) ) / 100;
  SFT_hn = hdfread( filehn, 'Data-Set-6' );
end


%= Loop channels
%
for i = 1 : length(channels)
  
  %= Read data and convert to K
  %
  TB = double( hdfread( filetb, ...
                              sprintf( 'Data-Set-%d', channels(i)+3) ) ) / 100;

  if channels(i) <= 5
    DOY = repmat( DOY_ln, 1, 64 );
    TOD = repmat( TOD_ln, 1, 64 );   
    LAT = LAT_ln;
    LON = LON_ln;
    SFT = SFT_ln;
  else
    DOY = repmat( DOY_hn, 1, 128 );
    TOD = repmat( TOD_hn, 1, 128 );   
    LAT = LAT_hn;
    LON = LON_hn;
    SFT = SFT_hn;
  end

  ind = find( TB>=1 & DOY>=doys(1) & DOY<=doys(2) & TOD>=tods(1) & ...
       TOD<=tods(2) & LAT>=lats(1) & LAT<=lats(2) & LON>=lons(1) & ...
       LON<=lons(2) & SFT>=sfts(1) & SFT<=sfts(2) );

  C{i}.TB  = TB(ind);
  C{i}.LAT = LAT(ind);
  C{i}.LON = LON(ind);
  C{i}.SFT = SFT(ind);
  C{i}.PSD = passdir;
end


