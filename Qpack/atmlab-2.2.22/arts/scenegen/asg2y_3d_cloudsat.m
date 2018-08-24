% ASG2Y_3D_cloudsat   Performs 3D scattering calculations based on ASG data 
%
%    Calculates spectrum/spectra considering scattering, where the spatial
%    structure of the clouds is taken from radar data.
%
%    Reads in Cloudsat radar data from selected parts
%    of the orbits based on the fields of *C*.
%    The radar data are shifted in latitude
%    to be centered around 0 degrees.
%    Prepares data for the function *asg2y_3d_1dbz_scene*
%    which is later called 
%
%    FORMAT [Y,ydata,DY,G1] = asg2y_3d_cloudsat(Gcs,grids_cs,C,Q,workfolder)
%
% OUT   y           As returned by *arts_y*.
%       ydata       As returned by *arts_y*.
%       dy          As returned by *arts_y*.
%       G1          modified G format data
% IN    Gcs         Specification of clear sky fields, in gformat.
%       grids_cs    Initial grids for clear sky fields. These grids are used
%                   as put into Q before calling *asg_atmgrids*. Obtained
%                   grids are used e.g. when calling *asg_rndmz* for clear 
%                   sky fields. 
%                   The input is given as an array of vectors, where element  
%                   1 corresponds to Q.P_GRID, element 2 Q.LAT_GRID and 
%                   element 3 Q.LON_GRID. 
%       C           A cloud definition structure with fields
%         DATA           name of datafile to be read in
%         LEG            leg of cloudsat data 
%         USE_LATS       latitude midpoints
%         DLAT           latitude (scalar)
%         LAT_RES        latitude resolution (scalar)
%         LON_GRID       longitude grid 
%         C.P_LIMS       pressure limits
%         DIMADD         (see asg_dimadd)
%         PROPS
%                    a psd and ssp defintiion structure 
%                    C.PROPS(1) corresponds to the radar frequency             
%                    C.PROPS(2) corresponds to the instrument frequencys 
%                    with fields                    
%             SSP    single scattering properties data
%             PSD    particle size distribution, only 'MH97' works
%             method psd method, only 'gauss-laguerre' works
%             x      particle sizes (see help gauss_laguerre)
%             w      weights
%             x_norm normalistaion factor 
%             shape  particle shape, only 'sphere' works 
%                
%       Q           Qarts structure. See above.
%       workfolder  Used as input to *asg2q*.

%  2007-11-26 created by XXX

function [Y,ydata,DY,G1] = asg2y_3d_cloudsat(Gcs,grids_cs,C,Q,workfolder)
  
  
%- Load CloudSat data
%
C.AUX       = {'DEM_elevation','Longitude','TAI_start','Profile_time'};
lat_limits  = [ C.USE_LATS(1)-C.DLAT/2 C.USE_LATS(end)+C.DLAT/2 ];
%make sure we read in also just outside lat_limits
lat_out     = [ lat_limits(1)-0.1 lat_limits(end)+0.1 ];
[Gdbz,Ddbz] = gfin_cloudsat_dBZe([],[],C.DATA,C.AUX,[],C.LEG,lat_out,[]);


%- reduce the latitude resolution
%  bin the data on a desired grid
%
grids{1} = Gdbz(1).GRID1;
grids{1} = Gdbz(1).GRID1( find( Gdbz(1).GRID1>0 & Gdbz(1).GRID1<24e3 ) );
grids{2} = lat_limits(1) : C.LAT_RES : lat_limits(end);
%
% Make sure that end points not have slipped outside covered range due to
% numerical problems.
%grids{2}(1)   = lat_limits(1);
%grids{2}(end) = lat_limits(end);
%
[Gdbz,Ddbz]=gf_bin(Ddbz,Gdbz,grids,[1 2]);

% Switch to pressure grid. Sort data in order to get decreasing pressures and
% increasing latitudes.
%
tai_ind=find(strcmp({Gdbz.NAME},'TAI_start'));
pt_ind=find(strcmp({Gdbz.NAME},'Profile_time'));
dbz_ind=find(strcmp({Gdbz.NAME},'Radar_Reflectivity'));

mjd1=date2mjd(1993,1,1,0,0,0);

sec_of_day=60*60*24;
mjd=mjd1+(Gdbz(tai_ind).DATA+mean(Gdbz(pt_ind).DATA))/sec_of_day;
DOY = mjd2doy(mjd);
Gdbz(dbz_ind).GRID1= z2p_cira86(Gdbz(dbz_ind).GRID1,mean(lat_limits),DOY );
Ddbz.GRID1_NAME='Pressure';
Ddbz.GRID1_UNIT='Pa';
%

% Set DIMADD or similar fields based on fields of C.
%
grids_dbz{3} = C.LON_GRID;
Gdbz(dbz_ind).DIMADD=C.DIMADD;
%

%- Set Gdbz.GRID1
%
% Find part of P.??? that is inside C.P_LIMS.
%
limits=[fliplr(C.P_LIMS);lat_limits];
[Gdbz(dbz_ind),Ddbz]=gf_crop(Ddbz,Gdbz(dbz_ind),limits,[1 2]);
grids_dbz{1} = Gdbz(dbz_ind).GRID1;
%

%add the psd and ssp properties of the assumed particles
% 
Gdbz(dbz_ind).PROPS=C.PROPS;

%- Init Gcs1 (as Gcs but only holding a single case)
%
% Batch data are compacted below.
%
Gcs1 = Gcs;

%- Make simulations for each selected latitude
%
for ip = 1 : length(C.USE_LATS)

  %- Extract clear sky fileds
  %
  for ig = 1 : length(Gcs)
    if any( Gcs(ig).DIMS == 4 )
      icase         = rem( ip-1, size(Gcs(ig).DATA,4) ) + 1;
      Gcs1(ig).DATA = Gcs(ig).DATA(:,:,:,icase);
      Gcs1(ig).DIMS = setdiff( Gcs(ig).DIMS, 4 );
    end
  end
  
  
  %- Extract CloudSat data
  %  
  lat  = [C.USE_LATS(ip)-C.DLAT/2 C.USE_LATS(ip)+C.DLAT/2];
  limits=[fliplr(C.P_LIMS);lat];
  [G(ip),Ddbz]=gf_crop(Ddbz,Gdbz(dbz_ind),limits,[1 2]);  
  
  %place the grid on 0 degree latitude
  G(ip).GRID2= round( [G(ip).GRID2-mean(G(ip).GRID2)]*1000)/1000;
  grids_dbz{2} = G(ip).GRID2;

  %- Temperature and water vapor
  %
  % add the possibility to include ECMWF data
    
 
  %- Make calculations
  %
  [y,ydata,dy,G1{ip}] = asg2y_3d_1dbz_scene( Gcs1, grids_cs, G(ip), ...
					                               grids_dbz, Q,workfolder );
  %
  if ip == 1
    Y  = zeros( length(y), length(C.USE_LATS) );
    DY = zeros( length(y), length(C.USE_LATS) );
  end
  %
  Y(:,ip)  = y;
  DY(:,ip) = dy;
  
end

