% ASG_DEMO2   A simple demonstration how to use ASG
%
%    Gives an example on basic usage of ASG
%
%    The example generates an atmospheric state
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
% FORMAT [G,FS]=asg_demo2(sensor,cs_file,ecmwf_file,leg,lat,lat_res,dlat)
%
% OUT     G    structure with atmospheric variables on gformat data
%         FS   structure specifying some settings
%
% IN      
%         sensor  the choice of instrument determines
%              which gas species to include in G
%              can be odin  or amsu 
%      
%         cs_file Cloudsat file from where to read data
%
%         ecmwf_file Cloudsat aux-file from where to read data         
%
%         leg  leg of cloudsat orbit to consider
%              1=(-90,0);2=(-90,90);3=[0,90]
%
%         lat  latitude of CloudSat data to consider 
%
%         lat_res cloud lattude resolution to use
%
%         dlat defines latitide/longitude extension of cloud
%                 

% Created by Bengt Rydberg
function [G,FS]=asg_demo2(sensor,cs_file,ecmwf_file,leg,lat,lat_res,dlat)

error( 'Can not be used presently. Not yet updated.' );

%SET BASIC PROPERTIES 

%SET CLOUD VARIABLES
%-

%DEFINE FILE FROM WHERE TO READ DATA
FS.DATA=cs_file;

%DEFINE FROM WHAT LEG OF CLOUDSAT-ORBIT DATA WILL BE TAKEN FROM
%Leg1=(-90,0);Leg2=(-90,90);Leg3=[0,90]
FS.LEG=leg;

%DEFINE FROM WHICH LATITUDES TO READ DATA
FS.USE_LATS=lat;


%DEFINE WHICH LATITUDE RESOLUTION TO USE  
FS.LAT_RES=lat_res; 

%define pressure limits from where to consider Cloudsat data
FS.P_LIMS=[900e2 80e2];
dim=3;
FS.DIM=dim;

if dim==3
     
   %define the method to expand cloudsat data from 2-d to 3-d 
   FS.DIMADD.METHOD='iaaft';
   
   %define how large latitude sections that will be considered
   FS.DLAT=dlat;

   %define longitude grid to use for cloud properties 
   FS.LON_GRID=[-dlat/2:FS.LAT_RES:dlat/2];

end

%define properties for converting radar backscatter IWC/LWC fields
f_grid=94e9;
FS.PROPS=asg_ssp(f_grid);

%END OF CLOUD VARIABLES SETTINGS

%SET ATMOSPHERIC PROPERTIES (no cloud) 
%-

%define from where to read data
%the baseline here is that gas fields are read from fascod tropical 
%climatology(ftc)
%however for H2O and O3 ECMWF data are here merged with Fascod data(ecmwfftc) 
%N2 is here fixed by giving it a numerical value 
%This in order to show some different options

fascod     = fullfile( atmlab('ARTS_XMLDATA_PATH'),...
                           'atmosphere', 'fascod' );
CS.FILE=ecmwf_file;

%define from what leg of cloudsat-orbit data will be taken from
CS.LEG=FS.LEG;

CS.INSTRUMENT=sensor;


%grids_cs will be the grids of the atmospheric variables (not for clouds)
%however the grids will later be set tighter around the cloudbox
%depending on the FS structure 
p_grid=z2p_simple([0:1e3:25e3 35e3 45e3 60e3]);
CS.GRIDS{1}=p_grid; 
CS.GRIDS{2}=sort([-90 90 FS.USE_LATS-10 FS.USE_LATS+10 ...
                 FS.USE_LATS-5 FS.USE_LATS+5 ...
                 FS.USE_LATS-dlat/2 FS.USE_LATS FS.USE_LATS+dlat/2]);

if dim==3
  lon_grid=[FS.LON_GRID(1) 0 FS.LON_GRID(end)];
  CS.GRIDS{3}=unique(sort([-180 -10  -5 lon_grid 5 10 180]));
end


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
   abs_models{2}='O3';
   abs_models{3}='ClO';
   abs_models{4}='N2O';
   abs_models{5}={'O2','O2-PWR98'};
   abs_models{6}='HNO3';
   abs_models{7}='N2-SelfContMPM93';
    
end 
 
if strcmp('amsu',sensor)  

   %gases to include for amsu
   gases=[{'H2O'},{'O3'},{'O2'},{'N2'}];

   %absorption models amsu
   abs_models{1}='H2O-PWR98';
   abs_models{2}='O3';
   abs_models{3}='O2-PWR93';
   abs_models{4}='N2-SelfContStandardType';

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
RND.SI        = 0.1;                % 40% std. dev. as default
%
RND.CFUN1     = 'exp';              % Exp. correlation function for p-dim.
RND.CL1       = [0.15 0.3 0.3]';    % Corr. length varies with altitude
RND.CL1_GRID1 = [1100e2 10e2 1e-3];    
%
RND.CFUN2     = 'lin';              % Linear correlation function for lat-dim.
RND.CL2       = 0.5;                % Corr. length 0.5 deg everywhere
%
RND.CFUN3     = 'lin';              % Linear correlation function for lat-dim.
RND.CL3       = 0.5;                % Corr. length 0.5 deg everywhere

%describe perturbations for each variable
for i=1:length(atmfields)
  
  if strcmp(atmfields(i).type,'temperature')

     atmfields(i).RND=RND;
     atmfields(i).RND.TYPE='abs';
     atmfields(i).RND.SI=1;
   
  elseif strcmp(atmfields(i).gas,'H2O')

     atmfields(i).RND=RND;
     atmfields(i).RND.SI=0.1;
 
  elseif strcmp(atmfields(i).gas,'O3')
     
     atmfields(i).RND=RND;
     atmfields(i).RND.SI=0.2;

  elseif strcmp(atmfields(i).gas,'ClO') | strcmp(atmfields(i).gas,'N2O') | ...
         strcmp(atmfields(i).gas,'HNO3') 

     atmfields(i).RND=RND;
  
  else
     
     atmfields(i).RND=[];
 
  end

end
 
%Read basic data 


clim='subarctic-summer';
clear G H
for i=1:length(atmfields)

     %D=asgD;
     
     G(i)=asgG;

     %G = gf_empty( 3 )



    if strcmp(atmfields(i).type,'temperature')

       if strcmp(atmfields(i).source,'ftc') | ...
          strcmp(atmfields(i).source,'ecmwfftc') 
          %G1 = gfin_artsxml( asgD, [], ...
          %                   fullfile( fascod, [clim,'.t.xml'] ), ...
          %                   'Temperature field','t_field' );
          G1 = gf_artsxml(fullfile( fascod, [clim,'.t.xml'] ), ...
                             'Temperature field','t_field' );
          
 
       end
         
       if strcmp(atmfields(i).source,'ecmwfftc') 
       
          H=asg_cloudsat_ecmwf(CS.FILE,CS.LEG,CS.GRIDS,{'DEM_elevation'});
         
          for j=1:length(H)
              if strcmp(H(j).NAME,'Water vapour')          
                H(j).NAME='H2O';
              end
              if strcmp(H(j).NAME,'Ozone')          
                H(j).NAME='O3';
              end
          end
   
       end

     end
  
     if strcmp(atmfields(i).type,'altitude')
     
        %altitude field is here just initialised
        G(i).NAME            = 'Altitude field'; 
        G(i).DATA_NAME       = 'Altitude field';
        G(i).DATA_UNIT       = 'm';
        %G(i).SPCFC.P0       = 1013e2;
        %G(i).SPCFC.P0       = G(1).GRID1(1); 
        G(i).SPCFC.P0        =CS.GRIDS{1}(1);
        grids=[{G(1).GRID1(1)} {0} {0} {0}]; 
        %G(i).SPCFC.Z0=gf_set( asgD, asgG,grids , 0, [], ...
        %                       'Altitude at P0', 'Altitude', 'm' );
        G(i).SPCFC.Z0=gf_set( asgG,0,grids,[],[]);
        G(i).SPCFC.Z0.DIMS=[];
        G(i).SPCFC.Z0.GRID1=[];
        G(i).SPCFC.Z0.GRID2=[];
        G(i).SPCFC.Z0.GRID3=[];
        G(i).SPCFC.Z0.GRID4=[];

     end 
       
     if strcmp(atmfields(i).type,'surface altitude')
          
        if strcmp(atmfields(i).source,'ecmwf')
          
           ind=find(strcmp('DEM_elevation',{H.NAME}));
           G(i)=H(ind);
           G(i).DATA_NAME='Surface altitude';
           G(i).NAME='Surface altitude';
           G(i).DIMADD.METHOD='expand';
                   
        end
       
     end
            
     
     if strcmp(atmfields(i).type,'gas_species')

        if strcmp(atmfields(i).source,'ftc') |  ...
           strcmp(atmfields(i).source,'ecmwfftc')               
           sourcefile= fullfile( fascod, [clim,'.',...
                                 atmfields(i).gas,'.xml'] );
           %G1= gfin_artsxml( asgD, [],sourcefile,atmfields(i).gas,...
           %                  'vmr_field' );

           G1= gf_artsxml( sourcefile,atmfields(i).gas,...
                            'vmr_field' );

           
           %G1 = gf_artsxml( fullfile( fascod, [clim,'.t.xml'] ), ...
           %                  'Temperature field','t_field' );
         
          
        end
            
        if strcmp(atmfields(i).source,'ecmwfftc')

           if ~exist('H')

              H=asg_cloudsat_ecmwf(CS.FILE,CS.LEG,CS.GRIDS,...
                                       {'DEM_elevation'});
           end
        end   
            
        if isnumeric(atmfields(i).source)

           grids=[{G(1).GRID1} {0} {0} {0}];
           data=atmfields(i).source*ones(length(grids{1}),1);
           %G(i)= gf_set( asgD, asgG, grids, data, [], ...
           %              atmfields(i).gas, 'Volume mixing ratio', '-' );
           %keyboard
           G(i)= gf_set( gf_empty( 1 ),data,grids,[],[]);
           G1= gf_set(  asgG,data,grids,[],[]);
  
         %G(i).SPCFC.Z0=gf_set( asgG,0,grids,[],[]);
       
        end

     end
        
     if strcmp(atmfields(i).source,'ftc') |  ...
        strcmp(atmfields(i).source,'ecmwfftc')   

         G(i).NAME=G1.NAME;
         G(i).DIMS=1;
         G(i).DATA=G1.DATA;
         G(i).DATA_NAME=G1.DATA_NAME;
         G(i).DATA_UNIT=G1.DATA_UNIT;
         G(i).GRID1=G1.GRID1;
         %G(i).GRID2=G1.GRID2;
         %G(i).GRID3=G1.GRID3;
         G(i).SOURCE=G1.SOURCE;
            
     end
     
     if strcmp(atmfields(i).source,'ecmwfftc')
     
        %merge data from ecmwf and fascod
        G(i)=merge_data2(asgD,G(i).NAME,G(i),H);

     end
 
 
    G(i).PROPS=atmfields(i).abs_models;

     
    G(i).RNDMZ=atmfields(i).RND;

end


keyboard


%rename H2O field 
ind1=find(strcmp('H2O',{G.NAME}));
G(ind1).NAME='Water vapour';
G(ind1).SPCFC.FIXED_RH=0;  
G(ind1).SPCFC.MOD_RH=0;  

%-------------------------------------------------------------------------------
%CREATE FULLSKY SCENARIOUS
workfolder =create_tmpfolder;

warning off
[Gfs,lon] = asg_create_gfs(G,CS.GRIDS,FS,workfolder);
delete_tmpfolder(workfolder)
warning on

FS.USE_LONS=lon;
G=Gfs;
%CHECK OUT IF THE CLOUDS ARE OVER LAND OR OCEAN
%FS.L_OR_S=land_or_sea(FS.USE_LATS,FS.USE_LONS); %1 is over land



%-------------------------------------------------------------------------------
%sub-functions
%

function G=merge_data2(D,field,G,H)
 
    S=G;
    ind1=find(strcmp(field,{G.NAME}));
    ind2=find(strcmp(field,{H.NAME}));
    lims1{1}=[H(ind2).GRID1([1 end])];
    lims1{2}=[H(ind2).GRID2([1 end])];
    m1=min(find(H(ind2).GRID1(end)>G(ind1).GRID1));
    lims2{1}=[G(ind1).GRID1(m1) G(ind1).GRID1(end)];
    addpath /home/bengt/ARTS/atmlab_sep08/atmlab/gformat
    G(ind1)=gf_merge(asgD,H(ind2),lims1,asgD,G(ind1),lims2);
    rmpath /home/bengt/ARTS/atmlab_sep08/atmlab/gformat
    G(ind1).DIMADD=S(ind1).DIMADD;

return

%-------------------------------------------------------------------------------

function P=asg_ssp(f_grid)
 %properties for adding pnd fields
 alpha=0;Ni=10;xnorm=50e-6;
 [x_i,w_i]=gauss_laguerre(alpha,Ni,xnorm);
 Nj=3;xnormw=10e-6;
 [x_k,w_k]=gauss_laguerre(alpha,Nj,xnormw);
 %x_i will be the diameter of the particles considered
 %calculate ssp
 for i=1:2

  if i==1 
   F=create_ssp('sphere',f_grid,x_i/2);
   P(i).x=x_i;
   P(i).w=w_i;
   P(i).x_norm=xnorm;
   P(i).PSD='MH97';
  else
   T_grid=[273 283 293 303 313];
   for i1=1:length(f_grid)
     for j1=1:length(T_grid)
       rfr_index(i1,j1) = sqrt(eps_water_liebe93( f_grid(i1), T_grid(j1) ));
     end
   end
   F=create_ssp('sphere',f_grid,x_k,T_grid,rfr_index);
   P(i).x=x_k;
   P(i).w=w_k;
   P(i).x_norm=xnormw;
   P(i).PSD='Water';
  end
  P(i).SSP=F;
  P(i).method='gauss-laguerre';
  P(i).shape='sphere';  
 end

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
