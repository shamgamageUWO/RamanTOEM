%------------------------------------------------------------------------
% NAME:     auramls_read_l2gp
%
%           Read L2GP hdf5-eos data from EOS-MLS. For info about
%           the MLS data see the Level 2 data and quality description
%           document available from the MLS web site at
%                 http://mls.jpl.nasa.gov   
%
% FORMAT:   P = auramls_read_l2gp( filename )
%
% IN:       filename    full path to MLS L2GP file
%
% OUT:      P           L2GP structure. These fields are returned, with 
%                       example on size:
%                             L2GPVALUE: [47x3495 double]
%                         L2GPPRECISION: [47x3495 double]
%                               QUALITY: [3495x1 double]
%                                STATUS: [3495x1 double]
%                              LATITUDE: [3495x1 double]
%                             LONGITUDE: [3495x1 double]
%                           CHUNKNUMBER: [3495x1 double]
%                                  TIME: [3495x1 double]
%                        LOCALSOLARTIME: [3495x1 double]
%                      SOLARZENITHANGLE: [3495x1 double]
%                    ORBITGEODETICANGLE: [3495x1 double]
%                      LINEOFSIGHTANGLE: [3495x1 double]
%                              PRESSURE: [47x1 double]
%------------------------------------------------------------------------

% HISTORY: 2004.08.01  Created by Carlos Jimenez
%                      Institute of Atmospheric and Environmental Science,
%                      School of GeoSciences, The University of Edinburgh      
%                      Crew Building, Mayfield Road, Edinburgh EH9 3JN 
%                      Telephone / Fax: +44 (0) 131 650 5098  / 662 0478       
%                      http://www.geos.ed.ac.uk/contacts/homes/cjimenez
%
%          2005.09.11  Update to make independent of MLS-struc
%
%          2006-03-27  

function P = auramls_read_l2gp( filename )


%=== De-activation of older input argument
%
do_column = 0;


%=== file exist and can be read?
%
if ~exist( filename, 'file' );
   error('File could not be found.');
end
%
if isempty( findstr( filename, 'L2GP' ) )
  error('File is not L2GP data.');
end
%
if ~isempty( findstr( filename, 'L2GP' ) ) & ... 
                                        ~isempty( findstr( filename, 'DGG' ) ) 
  error('Sorry, but this diagnostic L2GP data cannot be read.');
end


%= Find product
%
product = filename( findstr( filename, 'L2GP' )+5:end );
product = product( 1 : min(findstr(product,'_'))-1 );



%== read hdf-eos5
%
P = read_hdf5eos( filename, product, do_column );

return



%------------------------------------------------------------------------
%                               SUB-FUNCTIONS
%------------------------------------------------------------------------

function P = read_hdf5eos( filename, group, do_column )


day = strfind( filename, 'd' );
day = day(end);
day = str2num( filename( day +1 : day + 3) );


%=== reading the most useful fields, user can add more
%    if desired here


%== Preparing from column

if do_column

  group = [ group, ' column'];

end


%== Can we read this field?

try
  double(hdf5read(filename, ...
       ['/HDFEOS/SWATHS/' group '/Data Fields/L2gpValue']));
catch
  P = [];
  return
end 

%== Data Fields

P.L2GPVALUE=double(hdf5read(filename, ...
       ['/HDFEOS/SWATHS/' group '/Data Fields/L2gpValue']));
P.L2GPPRECISION=double(hdf5read(filename, ...
       ['/HDFEOS/SWATHS/' group '/Data Fields/L2gpPrecision']));
P.QUALITY=double(hdf5read(filename, ...
       ['/HDFEOS/SWATHS/' group '/Data Fields/Quality']));
P.STATUS=double(hdf5read(filename, ...
       ['/HDFEOS/SWATHS/' group '/Data Fields/Status']));

%== Geolocation fields

P.LATITUDE=double(hdf5read(filename, ...
       ['/HDFEOS/SWATHS/' group '/Geolocation Fields/Latitude']));
P.LONGITUDE=double(hdf5read(filename, ...
       ['/HDFEOS/SWATHS/' group '/Geolocation Fields/Longitude']));
P.CHUNKNUMBER=double(hdf5read(filename, ...
       ['/HDFEOS/SWATHS/' group '/Geolocation Fields/ChunkNumber']));
P.TIME=double(hdf5read(filename, ...
       ['/HDFEOS/SWATHS/' group '/Geolocation Fields/Time']));
P.LOCALSOLARTIME=double(hdf5read(filename, ...
       ['/HDFEOS/SWATHS/' group '/Geolocation Fields/LocalSolarTime']));
P.SOLARZENITHANGLE=double(hdf5read(filename, ...
       ['/HDFEOS/SWATHS/' group '/Geolocation Fields/SolarZenithAngle']));
P.ORBITGEODETICANGLE=double(hdf5read(filename, ...
       ['/HDFEOS/SWATHS/' group '/Geolocation Fields/OrbitGeodeticAngle']));
P.LINEOFSIGHTANGLE=double(hdf5read(filename, ...
       ['/HDFEOS/SWATHS/' group '/Geolocation Fields/LineOfSightAngle']));



if ~do_column & ~strcmp( group, 'TPPressureWMO' )
  P.PRESSURE=double(hdf5read(filename, ...
       ['/HDFEOS/SWATHS/' group '/Geolocation Fields/Pressure']));
end

return


