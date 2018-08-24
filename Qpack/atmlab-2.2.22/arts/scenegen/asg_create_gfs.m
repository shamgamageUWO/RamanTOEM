% ASG_CREATE_GFS   Creates atmopsheric states including clouds 
%                  based on various input data 
%
%    Creates atmospheric states including clouds, where the spatial
%    structure of the clouds is taken from radar data.
%
%    Reads in Cloudsat radar data from selected parts
%    of the orbits based on the fields of *C*.
%    
%    Prepares data for the sub-function *asg_gen_state*
%    where realisations of atmospheric states are performed,
%    which can either be 1 or 3-d.
%
%    FORMAT [H,C] = asg_create_gfs(Gcs,grids_cs,C,workfolder)
%
% OUT   H           Modified G format data
%       C           Modified C data 
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
%         DIM            desired dimensionality of data
%         DIMADD         (see asg_dimadd)
%         PROPS
%                    a psd and ssp defintiion structure 
%                    C.PROPS(1) corresponds to the radar frequency             
%                    C.PROPS(2) corresponds to the instrument frequencys 
%                    with fields                    
%             radar_back    single scattering properties data
%             PSD    particle size distribution, only 'MH97' and 'Water' works
%             method psd method, only 'gauss-laguerre' works
%             x      particle sizes (see help gauss_laguerre)
%             w      weights
%             x_norm normalistaion factor 
%             shape  particle shape, only 'sphere' works 
%
%
%        Examle usage:                
%        visit asg_demo to see an example how to use this function


%  2009-05-18 created by Bengt Rydberg

function [H,C] = asg_create_gfs(Gcs,grids_cs,C,workfolder)
  
  
%- Load CloudSat data
%
dim=C.DIM;
C.AUX       = {'DEM_elevation','Longitude','TAI_start','Profile_time'};
if dim==3
 lat_limits  = [ C.USE_LATS(1)-C.DLAT/2 C.USE_LATS(end)+C.DLAT/2 ];
end
if dim==1
  lat_limits = [C.USE_LATS(1)-C.LAT_RES C.USE_LATS(end)+C.LAT_RES]; 
end

%make sure we read in also just outside lat_limits
lat_out     = [ lat_limits(1)-C.LAT_RES-0.1 lat_limits(end)+C.LAT_RES+0.1 ];

[PATHSTR,name1,EXT,VERSN] = fileparts(C.DATA);
if strcmp('.zip',EXT)
   unzip(C.DATA,workfolder)
   C.DATA=fullfile(workfolder,name1);
end

[Gdbz] = asg_cloudsat_dBZe([],C.DATA,C.LEG,lat_out,[],C.AUX,[]);

%find out what longitudes and doys USE_LATS correspond to
for li=1:length(C.USE_LATS)
 [lat_m,lat_ind(li)]=min( abs(Gdbz(2).GRID1-C.USE_LATS(li)));
end
lon_ind=find(strcmp({Gdbz.NAME},'Longitude'));
C.USE_LONS=Gdbz(lon_ind).DATA(lat_ind);
mjd_ind=find(strcmp({Gdbz.NAME},'mjd'));
doy=mjd2doy(Gdbz(mjd_ind).DATA(lat_ind));
C.MJD=Gdbz(mjd_ind).DATA(lat_ind);

%- reduce the latitude resolution
%  bin the data on a desired grid
%
grids{1} = Gdbz(1).GRID1;
grids{1} = Gdbz(1).GRID1( find( Gdbz(1).GRID1>0 & Gdbz(1).GRID1<24e3 ) );

if dim==3
   grids{2} = lat_limits(1) : C.LAT_RES : lat_limits(end);
else
   grids{2}= sort([C.USE_LATS C.USE_LATS+C.LAT_RES C.USE_LATS-C.LAT_RES]);
end


Gdbz(1).DATA=10.^(Gdbz(1).DATA/10);
[Gdbz]=asg_bin(Gdbz(1),grids,[1 2]);



if dim==1
 for i=1:length(C.USE_LATS)
   l_ind(i)=find(Gdbz.GRID2==C.USE_LATS(i));
 end
 Gdbz.DATA=Gdbz.DATA(:,l_ind);
 Gdbz.GRID2=Gdbz.GRID2(l_ind);
end

%switch back to dBZ
Gdbz.DATA=10*log10(Gdbz.DATA);
Gdbz.DATA(find(Gdbz.DATA<=-50))=-50;


% Switch to pressure grid. 
Gdbz.GRID1= z2p_cira86(Gdbz.GRID1,mean(lat_limits),doy(1) );
Gdbz.GRID1_NAME='Pressure';
Gdbz.GRID1_UNIT='Pa';


%- Set Gdbz.GRID1
%
% Get out part of Gdbz that is inside the selected 
%C.P_LIMS and latitude limits .
%
grids_dbz{1} = Gdbz.GRID1;
if dim==3

 limits=[fliplr(C.P_LIMS);lat_limits];
 [Gdbz]=asg_crop(Gdbz,limits,[1 2]);

else
 
 limits=[fliplr(C.P_LIMS)];
 [Gdbz]=asg_crop(Gdbz,limits,[1]);
 if length(Gdbz.GRID2)<2
   Gdbz.DATA=Gdbz.DATA';
 end

end
 
%

%add the psd and radar backscatter properties of the assumed particles
% 
Gdbz.PROPS=C.PROPS;

% Set DIMADD based on fields of C.
%
if dim==3
 grids_dbz{3} = C.LON_GRID;
 Gdbz.DIMADD=C.DIMADD;
else
 Gdbz.DIMADD=[];
end
%

%- Prepare data for each selected latitude
%
for ip = 1 : length(C.USE_LATS)
 
  Gcs1 = Gcs;
  %- Extract CloudSat data
  %  
  if dim==3

   lat  = [C.USE_LATS(ip)-C.DLAT/2 C.USE_LATS(ip)+C.DLAT/2];
   limits=[fliplr(C.P_LIMS);lat];
   [G(ip)]=asg_crop(Gdbz,limits,[1 2]);
   grids_dbz{2} = G(ip).GRID2;

  else

   G(ip)=Gdbz;
   G(ip).DATA=Gdbz.DATA(:,ip);
   G(ip).GRID2= Gdbz.GRID2(ip);

  end 

  
  Q = qarts;
  Q.P_GRID=grids_cs{1};

  if dim==3

   lim1=round(C.USE_LATS(ip)-C.DLAT/2);
   lim2=round(C.USE_LATS(ip)+C.DLAT/2);
   if ip==1
      lat_grid=grids_cs{2};
   end
   %the lat grid around the cloudbox
   add_lat_grid=[ lim1-3 lim1-1 lim1-0.01 lim1 ...
                 C.USE_LATS(ip)-1 C.USE_LATS(ip) C.USE_LATS(ip)+1 ...
                 lim2 lim2+0.01 lim2+1 lim2+3];
   grids_cs{2}=unique(sort([lat_grid,add_lat_grid])); 

   Q.LAT_GRID=grids_cs{2};
   Q.LON_GRID=grids_cs{3}; 
   Q.ATMOSPHERE_DIM = 3;
   
  else

   Q.ATMOSPHERE_DIM = 1;
   Q.LAT_GRID=C.USE_LATS(ip);
   
  end 
 
  %- Generate a single scene
  %
  %see sub-function

  [H{ip}] = asg_gen_state( Gcs1, grids_cs, G(ip), ...
					      grids_dbz, Q,dim);
  
  
end

clear G
G=H;


function [G] = ...
        asg_gen_state(Gcs,grids_cs,Gdbz,grids_dbz,Q,dim)



 %- Create clear sky fields
 %
 if dim==3
    Gcs = asg_dimadd( Gcs, Q );
 end

 %regrid data

 Gcs = asg_regrid( Gcs, Q );
 Gcs = asg_rndmz( Gcs );
 Gcs = asg_hydrostat( Gcs, Q );


 %- Determine grids for dbz field
 %
 
 Q.P_GRID   = grids_dbz{1};
 if dim==3
    Q.LAT_GRID = grids_dbz{2};
    Q.LON_GRID = grids_dbz{3};
 end
 %
 
 %- Create final dbz field(s)
 %
 

 if dim==3
  Gdbz.DATA=10.^(Gdbz.DATA/10);
  Gdbz = asg_dimadd( Gdbz, Q );
  Gdbz = asg_regrid( Gdbz, Q );
  Gdbz.DATA=10*log10(Gdbz.DATA);
  %pad the data with "zeros" around the dbz field, to make sure interpolation
  %will cause no cloud "enlarging" 
  Gdbz = asg_zeropad( Gdbz, Q);
  Gdbz.DATA([1:2 end-1:end],:,:)=-50;
  Gdbz.DATA(:,[1:2 end-1:end],:)=-50;
  Gdbz.DATA(:,:,[1:2 end-1:end])=-50;
 end

 
 %- Make re-gridding of fields so cloud and atmospheric variables match
 %
 %
 
 if dim==1
    Q.ATMOSPHERE_DIM=1;
 end

 Q.P_GRID=250/16e3;
 if dim==3
   Q.LAT_GRID=0.001;
   Q.LON_GRID=0.001;
 end

 %dummy fields
 Gdbz.RNDMZ=[];
 Gdbz.SPCFC=[];
 Gdbz.SURFACE=[];
 len=length(Gcs);
 Gcs(len+1)=Gdbz;
  

 
 [grid1a] = gf_get_grid( Gcs(1), 1 );
 [grid1b] = gf_get_grid( Gdbz, 1 );
 grid1=flipud(vec2col(sort(union(grid1a,grid1b))));
 grid1 = gridconvert( grid1, false, @log10, true );
 grid1 = gridthinning( grid1, Q.P_GRID );
 Q.P_GRID = gridconvert( grid1, true, @pow10 );
 
 if dim==3
  [grid1a] = gf_get_grid( Gcs(1), 2 );
  [grid1b] = gf_get_grid( Gdbz, 2 );
  grid1=vec2col(sort(union(grid1a,grid1b)));
  grid1 = gridthinning( grid1, Q.LAT_GRID );
  Q.LAT_GRID=grid1;

  [grid1a] = gf_get_grid( Gcs(1), 3 );
  [grid1b] = gf_get_grid( Gdbz, 3 );
  grid1=vec2col(sort(union(grid1a,grid1b)));
  grid1 = gridthinning( grid1, Q.LON_GRID );
  Q.LON_GRID=grid1;
 end

 ind=strcmp(lower({Gcs.NAME}),'radar_reflectivity');
 Gcs(ind).DATA=10.^(Gcs(ind).DATA/10);
 Gcs = asg_regrid( Gcs, Q );
 Gcs(ind).DATA=10*log10(Gcs(ind).DATA);
 Gcs = asg_hydrostat( Gcs, Q );  

 %extract iwc and particle number fields(pnd) fields 
 Gcs = asg_dbz2pnd( Gcs, Q ,Gcs(end).PROPS);

 %- Modify water vapour to match cloud distribution
 %
 ind1=find(strcmp('h2o',lower({Gcs.NAME})));
 if  0 %Gcs(ind1).SPCFC.MOD_RH 

   Gcs=asg_iwc_relhumid(Gcs,Q);

   Gcs = asg_hydrostat( Gcs, Q );

 end

G=Gcs;

return