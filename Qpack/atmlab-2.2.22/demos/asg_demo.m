% ASG_DEMO   A simple demonstration how to use ASG
%
%    Gives an example on basic usage of ASG
%
%    The example generates two atmospheric states
%    including clouds.
%    In the example radar data from Cloudsat
%    is used to create cloud structure.
%    ECMWF and Fascod climatological
%    data is used to create other atmospheric 
%    parameters.
%    A lot of default settings are made in this
%    demo, which may be re-considered depending
%    on what output data should be used for
%
% FORMAT [G]=asg_demo([ dim,instrument ])
%
% OUT     G    structure with atmospheric variables on gformat data
%         FS   structure specifying some settings
%
% IN      file1 cloudsat level 2-b geoprof file 
%         file2 cloudsat ecmwf-aux file 
% OPT     sensor  
%              the choice of instrument determines
%              which gas species to include in G
%              can be odin (default) or amsu 
%         dim  
%              desired dimensionality of data
%              can be 1 (pressure) or 3(pressure,latitude,longitude)
%              default=3 
%         leg  
%              the leg of Cloudsat-orbit data will be taken from
%              1,2(default),or 3 
%         use_lats 
%              the center latitudes 
%              
%         lat_res 
%              latitude resolution to use
%              default=0.25 degrees 
%         dlat  
%              defines how large latitude sections that will be considered
%              default=4 degrees
% 

% Created by Bengt Rydberg

function [G,FS]=asg_demo(file1,file2, varargin )
%

[sensor,dim,leg,use_lats,lat_res,dlat] = ...
      optargs( varargin, {'odin',3,2,13,0.25,4} );

if sensor~='odin' & sensor~='amsu'
  error('sensor can only be odin or amsu')
end

if dim~=1 & dim~=3
 error('dim must be 1 or 3')
end

if ~isscalar(leg)
 error('leg must be a scalar')
end

if leg~=1 & leg~=2 & leg~=3
 error('leg must be 1,2, or 3')
end

if ~isvector(use_lats)
 error('use_lats must be a vector')
end

if leg==1
   if any(use_lats<-90) | any(use_lats>0)
      error('if leg=1 use_lats must be within (-90 - 0)')
   end
elseif leg==2
   if any(use_lats<-90) | any(use_lats>90)
      error('if leg=2 use_lats must be within (-90 - 90)')
   end
else
  if any(use_lats<0) | any(use_lats>90)
      error('if leg=3 use_lats must be within (0 - 90)')
  end
end
if ~isscalar(dlat)
 error('dlat must be a scalar')
end
 

%SET BASIC PROPERTIES 

%SET CLOUD VARIABLES
%-

%DEFINE FILE FROM WHERE TO READ DATA
%toppath = fileparts( fileparts( which( 'atmlab_init' ) ) );
%datapath=fullfile(toppath,'demos','data');
%cloudsatfile='2006224035643_01541_CS_2B-GEOPROF_GRANULE_P_R04_E01.hdf';
%FS.DATA=fullfile(datapath,cloudsatfile);
FS.DATA=file1;

%DEFINE FROM WHAT LEG OF CLOUDSAT-ORBIT DATA WILL BE TAKEN FROM
%Leg1=(-90,0);Leg2=(-90,90);Leg3=[0,90]
FS.LEG=leg;

%DEFINE FROM WHICH LATITUDES TO READ DATA
FS.USE_LATS=use_lats;

%DEFINE WHICH LATITUDE RESOLUTION TO USE 
%data will be binned to this resolution 
FS.LAT_RES=lat_res; 

%define pressure limits from where to consider Cloudsat data
FS.P_LIMS=[900e2 80e2];

FS.DIM=dim;

if dim==3
     
   %define the method to expand cloudsat data from 2-d to 3-d 
   FS.DIMADD.METHOD='iaaft';
   
   %define how large latitude sections that will be considered
   FS.DLAT=dlat;

   %define longitude grid to use for cloud properties 
   FS.LON_GRID=[-1:FS.LAT_RES:1];

end

%define properties for converting radar backscatter IWC/LWC fields

f_grid=94e9;
lambda=constants('SPEED_OF_LIGHT')/f_grid;

%first ice particles

P(1).PSD='MH97';
P(1).shape='sphere';
P(1).method='gauss-laguerre';
P(1).F_GRID=f_grid;
%settings for gauss-laguerre 
alpha=0;Ni=10;xnorm=50e-6;
[x_i,w_i]=gauss_laguerre(alpha,Ni,xnorm);
%x_i will be the diameter of the particles considered
P(1).x=x_i;
P(1).w=w_i;
P(1).x_norm=xnorm;
P(1).T_grid=173:10:273;
%calculate radar back-scattering per particle
for i=1:length(P(1).T_grid)
     m=sqrt(eps_ice_liebe93( f_grid, P(1).T_grid(i) ));
     [y(:,i)]=mie_back(m,lambda,x_i);
end
P(1).radar_back=y;

% water particles

P(2).PSD='Water';
P(2).shape='sphere';
P(2).method='gauss-laguerre';
P(2).F_GRID=f_grid;
%settings for gauss-laguerre 
Nj=3;xnormw=10e-6;
[x_k,w_k]=gauss_laguerre(alpha,Nj,xnormw);
%x_k will be the diameter of the particles considered
P(2).x=x_k;
P(2).w=w_k;
P(2).x_norm=xnormw;
 
P(2).T_grid=[273:10:313];
clear y
%calculate radar back_scattering per particle
for i=1:length(P(2).T_grid)
     m=sqrt(eps_water_liebe93( f_grid, P(2).T_grid(i) ));
     [y(:,i)]=mie_back(m,lambda,x_k);
end
P(2).radar_back=y;

FS.PROPS=P;
%END OF CLOUD VARIABLES SETTINGS



%SET ATMOSPHERIC PROPERTIES (no cloud) 
%-

%grids_cs will be the grids of the atmospheric variables (not for clouds)
%however the grids will later be set tighter around the cloudbox
%depending on the FS structure 
p_grid=z2p_simple([-1e3:1e3:25e3 30e3:5e3:70e3]);
CS.GRIDS{1}=p_grid; 
CS.GRIDS{2}=sort([-90 -50 -30:10:30 50 90 FS.USE_LATS]);

if dim==3
  lon_grid=[FS.LON_GRID(1) 0 FS.LON_GRID(end)];
  CS.GRIDS{3}=unique(sort([-180 -150 -10  -5 lon_grid 5 10 150 180]));
end


%define from where to read data
%the baseline here is that gas fields are read from fascod climatology (ftc)
%however for H2O and O3 ECMWF data are here merged with Fascod data(ecmwfftc) 
%N2 is here fixed by giving it a numerical value 
%to show some different options

fascod     = fullfile( atmlab('ARTS_XMLDATA_PATH'),...
                           'atmosphere', 'fascod' );
clim='tropical';
%atmdatadir=fullfile(fascod,clim);

%ecmwffile='2006224035643_01541_CS_ECMWF-AUX_GRANULE_P_R04_E01.hdf';
%CS.FILE=fullfile(datapath,ecmwffile);
CS.FILE=file2;

%define from what leg of cloudsat-orbit data will be taken from
CS.LEG=FS.LEG;

CS.INSTRUMENT=sensor;

%mandatory fields to include

fields=[{'temperature'},{'Altitude'},{'Surface altitude'}];
atmfields(1).type='temperature';
atmfields(1).source='ecmwfftc';
atmfields(2).type='altitude';
atmfields(2).source='';
atmfields(3).type='surface altitude';
atmfields(3).source='ecmwf';

%define which gas types to include (depends on choice of instrument)

if strcmp('odin',sensor)

   %gases to include for Odin 
   gases=[{'H2O'},{'O3'},{'ClO'},{'N2O'},{'O2'},{'HNO3'},{'N2'}];
   %ABSORPTION MODELS
   abs_models{1}={'H2O','H2O-ForeignContStandardType',...
                  'H2O-SelfContStandardType'};
   abs_models{2}={'O3'};
   abs_models{3}={'ClO'};
   abs_models{4}={'N2O'};
   abs_models{5}={'O2','O2-PWR98'};
   abs_models{6}={'HNO3'};
   abs_models{7}={'N2-SelfContMPM93'};
end

if strcmp('smiles',sensor)

   %gases to include for Odin 
   gases=[{'H2O'},{'O3'},{'ClO'},{'N2O'},{'O2'},{'HNO3'},{'N2'},{'HCl'}];
   %ABSORPTION MODELS
   abs_models{1}={'H2O','H2O-ForeignContStandardType',...
                  'H2O-SelfContStandardType'};
   abs_models{2}={'O3'};
   abs_models{3}={'ClO'};
   abs_models{4}={'N2O'};
   abs_models{5}={'O2','O2-PWR98'};
   abs_models{6}={'HNO3'};
   abs_models{7}={'N2-SelfContMPM93'};
   abs_models{8}={'HCl'};
end
 
 
if strcmp('amsu',sensor)  

   %gases to include for amsu
   gases=[{'H2O'},{'O3'},{'O2'},{'N2'}];

   %absorption models amsu
   abs_models{1}={'H2O-PWR98'};
   abs_models{2}={'O3'};
   abs_models{3}={'O2-PWR93'};
   abs_models{4}={'N2-SelfContStandardType'};

end


len=length(atmfields);

for i=1:length(gases) 

  atmfields(len+i).type='gas_species';
  atmfields(len+i).abs_models=abs_models{i};
  atmfields(len+i).gas=gases{i};

  if strcmp(gases{i},'H2O') | strcmp(gases{i},'O3')

     atmfields(len+i).source='ecmwfftc';
  
  elseif strcmp(gases{i},'N2')

     atmfields(len+i).source=0.7814;
  
  else

     atmfields(len+i).source='ftc'; 
   
  end

end


%Baseline for parameters describing how perturbations will be performed

RND.FORMAT    = 'param'; 
RND.SEPERABLE = 1;
RND.CCO       = 0.01;               % Cut-off for correlation values 
RND.TYPE      = 'rel';              % Relative disturbances as default
RND.DATALIMS  = [0];                % Do not allow negative values
%
RND.SI        = 0.4;                % 40% std. dev. as default
%
RND.CFUN1     = 'exp';              % Exp. correlation function for p-dim.
RND.CL1       = [0.15 0.3 0.3]';    % Corr. length varies with altitude
RND.CL1_GRID1 = [1100e2 10e2 1e-3];    
%
RND.CFUN2     = 'lin';              % Linear correlation function for lat-dim.
RND.CL2       = 0.5;                % Corr. length 0.5 deg everywhere
%
RND.CFUN3     = 'lin';              % Linear correlation function for lon-dim.
RND.CL3       = 0.5;                % Corr. length 0.5 deg everywhere

%describe perturbations for each variable
for i=1:length(atmfields)
  
  if strcmp(atmfields(i).type,'temperature')

     atmfields(i).RND=RND;
     atmfields(i).RND.TYPE='abs';
     atmfields(i).RND.SI=1; %1 K noise added
      

  elseif strcmp(atmfields(i).gas,'H2O')

     atmfields(i).RND=RND;
     atmfields(i).RND.SI=0.1; 
 
  elseif strcmp(atmfields(i).gas,'O3')
     
     atmfields(i).RND=RND;
     atmfields(i).RND.SI=0.2;

  elseif strcmp(atmfields(i).gas,'ClO') | strcmp(atmfields(i).gas,'N2O') | ...
         strcmp(atmfields(i).gas,'HNO3') | strcmp(atmfields(i).gas,'HCl') 

     atmfields(i).RND=RND;
  
  else
     
     atmfields(i).RND=[];
 
  end

end
 
%CS.ATMFIELDS=atmfields;

%end of clear sky variables settings
%--------------------------------------------------

%Read basic data 


clear G H G1

G0 = gf_empty( 3 );
G0.PROPS=[];
G0.DIMADD.METHOD='expand';
G0.RNDMZ=[];
G0.SPCFC=[];
G0.SURFACE=0;


for i=1:length(atmfields)
     
    G(i)=G0;

    if strcmp(atmfields(i).type,'temperature')

       if strcmp(atmfields(i).source,'ftc') | ...
          strcmp(atmfields(i).source,'ecmwfftc') 

          G1 = gf_artsxml(fullfile( fascod, [clim,'.t.xml'] ), ...
                             'Temperature field','t_field' );
          G(i)=gf_set_fields(G(i),'TYPE',G1.TYPE,'NAME',G1.NAME,...
               'SOURCE',G1.SOURCE,'DATA_NAME',G1.DATA_NAME,...
               'DATA_UNIT',G1.DATA_UNIT);
          G(i)=gf_set(G(i),G1.DATA,[{G1.GRID1},{},{}]);     
          G(i)=gf_set_fields(G(i),'GRID1_NAME',G1.GRID1_NAME,...
                'GRID1_UNIT',G1.GRID1_UNIT);
          G(i).RNDMZ=atmfields(i).RND;
       end
         
       if strcmp(atmfields(i).source,'ecmwfftc') 
       
          H=asg_cloudsat_ecmwf(CS.FILE,CS.LEG,CS.GRIDS,{'DEM_elevation'});

       end

     end
  
     if strcmp(atmfields(i).type,'altitude')
     
        %altitude field is here just initialised
        G(i)=gf_set_fields(G(i),'TYPE','atm_data','NAME','altitude field',...
             'DATA_NAME','altitude','DATA_UNIT','m');
        G(i).SPCFC.P0        = 1013e2;
        grids=[{ G(i).SPCFC.P0} {} {}]; 
        G(i).SPCFC.Z0=gf_set( G(i),0,grids);
        G(i).SPCFC.Z0=gf_set_fields(G(i).SPCFC.Z0,'NAME','Altitude at P0',...
                      'DATA_UNIT','m','GRID1_NAME','pressure',...
                      'GRID1_UNIT','Pa');      
     end 
       
     if strcmp(atmfields(i).type,'surface altitude')
          
        if strcmp(atmfields(i).source,'ecmwf')
  
           ind=find(strcmp({H.NAME},'surface altitude'));  
           G(i)=gf_set_fields(G(i),'TYPE',H(ind).TYPE,...
               'NAME',H(ind).NAME,'SOURCE',H(ind).SOURCE,...
               'DATA_NAME',H(ind).DATA_NAME,'DATA_UNIT',...
                H(ind).DATA_UNIT);
           G(i)=gf_set(G(i),H(ind).DATA,[{H(ind).GRID1} {} {} ]); 
           G(i)=gf_set_fields(G(i),'GRID1_NAME',H(ind).GRID1_NAME,...
               'GRID1_UNIT',H(ind).GRID1_UNIT);


        end
       
     end
            
     
     if strcmp(atmfields(i).type,'gas_species')

        if strcmp(atmfields(i).source,'ftc') |  ...
           strcmp(atmfields(i).source,'ecmwfftc')               
           sourcefile= fullfile( fascod, [clim,'.',...
                                 atmfields(i).gas,'.xml'] );
          
           G1= gf_artsxml( sourcefile,atmfields(i).gas,'vmr_field');
           G(i)=gf_set_fields(G(i),'TYPE','atmdata','NAME',G1.NAME,...
               'DATA_NAME',G1.DATA_NAME,'DATA_UNIT','1');
           G(i)=gf_set(G(i),G1.DATA,[{G1.GRID1},{},{}]);     
           G(i)=gf_set_fields(G(i),'GRID1_NAME',G1.GRID1_NAME,...
                'GRID1_UNIT',G1.GRID1_UNIT);
           G(i).PROPS=atmfields(i).abs_models;
           G(i).RNDMZ=atmfields(i).RND;
       
          
        end
            
        if strcmp(atmfields(i).source,'ecmwfftc')

           if ~exist('H')

              H=asg_cloudsat_ecmwf(CS.FILE,CS.LEG,CS.GRIDS,...
                                       {'DEM_elevation'});

           end
        end   
            
        if isnumeric(atmfields(i).source)
           
           G(i)=gf_set_fields(G(i),'NAME',atmfields(i).gas,...
               'SOURCE','set manually','DATA_NAME','Volume mixing ratio',...
               'DATA_UNIT','1');
           grids=[{G(1).GRID1} {} {}];
           data=atmfields(i).source*ones(length(grids{1}),1);
           G(i)= gf_set(  G(i),data,grids);
           G(i)=gf_set_fields(G(i),'GRID1_NAME',G1.GRID1_NAME,...
                'GRID1_UNIT',G1.GRID1_UNIT);
           G(i).PROPS=atmfields(i).abs_models;
           G(i).RNDMZ=atmfields(i).RND;
       
        end

     end

     if strcmp(atmfields(i).source,'ecmwfftc')
     
        %merge data from ecmwf and fascod
        G(i)=merge_data2(G(i).NAME,G(i),H); 
     end

end

%H2O field 
ind1=find(strcmp('H2O',{G.NAME}));
G(ind1).SPCFC.FIXED_RH=0;  
G(ind1).SPCFC.MOD_RH=1;  


%-------------------------------------------------------------------------------
%CREATE FULLSKY SCENARIOUS
workfolder =create_tmpfolder;

warning off

[Gfs,FS] = asg_create_gfs(G,CS.GRIDS,FS,workfolder);

delete_tmpfolder(workfolder)
warning on


G=Gfs;



%CHECK OUT IF THE CLOUDS ARE OVER LAND OR OCEAN
%FS.L_OR_S=land_or_sea(FS.USE_LATS,FS.USE_LONS); %1 is over land



%-------------------------------------------------------------------------------
%sub-functions
%

function G=merge_data2(field,G,H)

    %merge 2-dim data (pressure x latitude (H))
    %with 1-dim data (pressure (G))
    %into 2 dim-data 
    ind1=find(strcmp(field,{G.NAME}));
    ind2=find(strcmp(field,{H.NAME}));
    %find the min p_index of the 1-d data where
    %the 2-d data have no info   
    m1=min(find(H(ind2).GRID1(end)>G(ind1).GRID1));
    %now merge the data
    data=G(ind1).DATA(m1:end)*ones(size(H(ind2).DATA,2),1)';
    %the new p_grid
    grid1=[H(ind2).GRID1',G(ind1).GRID1(m1:end)']';
    G(ind1).DIM=2;
    G(ind1)=gf_set(G(ind1),[H(ind2).DATA', data']',...
            [{grid1} {vec2col(H(ind2).GRID2)} ]);
    G(ind1)=gf_set_fields(G(ind1),'GRID1_NAME',H(ind2).GRID1_NAME,...
             'GRID1_UNIT',H(ind2).GRID1_UNIT,...
             'GRID2_NAME',H(ind2).GRID2_NAME,...
             'GRID2_UNIT',H(ind2).GRID2_UNIT);
 
return

%-------------------------------------------------------------------------------

%Find out if we are over land or ocean 
function [l_or_s]=land_or_sea(lat_fs,lon_fs)
  [lat,lon,M]=land_sea_mask;
  for ip=1:length(lat_fs)
    if lon_fs(ip)<0
      l_data=round(360+lon_fs(ip));
    else
      l_data=round(lon_fs(ip));
    end
    lat_ind=find(round(lat_fs(ip))==lat);
    lon_ind=find(l_data==lon);
    l_or_s(ip)=M(lat_ind,lon_ind);
  end

return
