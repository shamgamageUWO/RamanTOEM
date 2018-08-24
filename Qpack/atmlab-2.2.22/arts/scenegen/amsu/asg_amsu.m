%- asg_amsu performs 1-D radiative transfer simulations,
%  for AMSU setup, on states created from cloudsat files
%  Temperature,water vapour, (and ozone) are taken from
%  ECMWF, and N2 and 02 from climatologies
%
%  Format [K]=asg_amsu(data1,data2,leg,use_lats)
%
%  OUT    
%         K.Y    smilutated radiance (freq,los)
%         K.Q    simulated radiance (Q) (freq,los) 
%                %is reported only when stokes dimension
%                %is set to 2 
%         K.freq frequencies of simulated radiance
%         K.los  line of sights of simulated radiance
%         K.lat  latitude of the G data
%         K.G    G structure of atmospheric/cloud state   
%         
%  IN
%    
%         data1    path to a Cloudsat 2B-GEOPROF file 
%         data2    path to a Cloudsat ECMWF-AUX file
%         leg      leg of the data to be used
%         use_lats vector with latitudes where the data
%                  will be taken from 
%
%  Example usage
%          leg=1;use_lats=[-20 -13.15 -12.15];
%          leg=2;use_lats=[-20 -13.15 -12.15];
%          leg=3;use_lats=[12.15 13.15 20];
%          datadir='/home/bengt/CIWSIR/Dataset_gen/CloudSAT_data/';
%          data1=fullfile(datadir,...
%                '2006293172641_02554_CS_2B-GEOPROF_GRANULE_P_R03_E02.hdf');
%          data2=fullfile(datadir,...
%                '2006293172641_02554_CS_ECMWF-AUX_GRANULE_P_R03_E02.hdf');
%          [K]=asg_amsu(data1,data2,leg,use_lats)
%
%
% 2008-02-06   Created by Bengt Rydberg.

function [K]=asg_amsu(data1,data2,leg,use_lats)


fascod     = fullfile( atmlab('ARTS_XMLDATA_PATH'), 'atmosphere', 'fascod' ); 
artsdirpath='/home/bengt/ARTS/arts/';
workfolder =create_tmpfolder;


%- Init ASG structures
%
D = asgD;
%
clear G

%--- ASG settings -------------------------------------------------------------

%- A template for specifying random disturbances of atmospheric fields
%
RND.FORMAT    = 'param'; 
RND.SEPERABLE = 1;
RND.CCO       = 0.01;           % Cut-off for correlation values 
RND.TYPE      = 'rel';          % Relative disturbances as default
RND.DATALIMS  = [0];            % Do not allow negative values
%
RND.SI        = 0.4;            % 40 % std. dev. as default
%
RND.CFUN1     = 'exp';              % Exp. correlation function for p-dim.
RND.CL1       = [0.15 0.3 0.3]';    % Corr. length varies with altitude
RND.CL1_GRID1 = [1100e2 10e2 1e-3];    


%- Temperature field
%
G(1)                 = gfxmlin_GriddedField3( D, asgG, ...
                                fullfile( fascod, 'tropical.t.xml' ), ...
                                'Temperature field', 't' );
G(1).RNDMZ           = RND;
G(1).RNDMZ.TYPE      = 'abs';   % Change to absolute std. dev. of 3K
G(1).RNDMZ.DATALIMS  = [100 310];   % Allowed range of temperatures
G(1).RNDMZ.SI        = 1;
G(1).DIMADD          = 0;

%- Altitude field
%
G(2)                 = asgG;
G(2).NAME            = 'Altitude field'; 
G(2).SPCFC.P0        = 1013e2;
G(2).SPCFC.Z0        = gf_set( D, asgG, [], 0, [], ...
                               'Altitude at P0', 'Altitude', 'm' );
G(2).DIMADD          = 0;

%- Nitrogen 
%
G(3)                 = gf_set( D, asgG, [], 0.7814, [], ...
                               'Nitrogen', 'Volume mixing ratio', '-' );
G(3).PROPS           = 'N2-SelfContStandardType';

%- Water vapour
%
G(4)                 = gfxmlin_GriddedField3( D, asgG, ...
                                fullfile( fascod, 'tropical.H2O.xml' ), ...
                                'Water vapour', 'vmr' );
G(4).PROPS           = {'H2O-PWR98'};
                     
G(4).RNDMZ           = RND;
G(4).RNDMZ.SI        =0.1;
G(4).SPCFC.FIXED_RH  = 0;
G(4).DIMADD          = 0;

%- O2
%
G(5)                 = gfxmlin_GriddedField3( D, asgG, ...
                                fullfile( fascod, 'tropical.O2.xml' ), ...
                                'O2', 'vmr' );
G(5).PROPS           = {'O2-PWR93'};
G(5).DIMADD          = 0;

%- Ozone
%
G(6)                 = gfxmlin_GriddedField3( D, asgG, ...
                                fullfile( fascod, 'tropical.O3.xml' ), ...
                                'Ozone', 'vmr' );
G(6).PROPS           = 'O3';
G(6).RNDMZ           = RND;
G(6).RNDMZ.SI        = 0.2; 
G(6).DIMADD          = 0;                                                     



%if desired use temperature, humidity, and ozone from ecmwf
ecmwf=1;

% add data from cloudsat ECMWF data
C.DATA=data1;    
C.LEG=leg;
C.USE_LATS=use_lats;
C.DLAT=0.25; 
%latitude resolution,radar backscatter will be averaged over this length
%C.LAT_RES=0.25;
C.DIMADD=0;
C.P_LIMS=[400e2 80e2]; %pressure limits of cloud data

if ecmwf
   
   %read in temperature, humidity, and ozone from ecmwf
   grids_cs{2}=C.USE_LATS;
   [G1]=asg_cloudsat_ecmwf(data2,C.LEG,grids_cs);

   %merge it with with fascod data

   lims1{1}=[G1(1).GRID1(1) G1(1).GRID1(end)];
   lims1{2}=[G1(1).GRID2(1) G1(1).GRID2(end)];
   lims2{1}=[G1(1).GRID1(end) G(1).GRID1(end)];
   [G1]=gf_merge(D,G1,lims1,D,G,lims2);   

   %write over the old fields
   fields={'Temperature field','Water vapour','Ozone'};
   for i=1:length(fields)
       f1=find(strcmp({G.NAME},fields{i}));
       g1=find(strcmp({G1.NAME},fields{i}));
       G(f1).DATA=G1(g1).DATA;
       G(f1).GRID1=G1(g1).GRID1;
       G(f1).GRID2=G1(g1).GRID2;
       G(f1).SOURCE=G1(g1).SOURCE;
       G(f1).DIMS=[1 2];
   end
      
end


clear RND fascod G1 lims1 lims2 f1 g1 fields grids_cs leg use_lats

%------------------------------------------------------------------------------

%--- Qarts settings  ----------------------------------------------------------

Q = qarts;

%- Basic atmospheric variables
%
Q.P_GRID         = 100/16e3;      % Unit here is pressure decade
Q.ATMOSPHERE_DIM=1;

%-Surface
%
Q.Z_SURFACE=0;

%- Spectroscopic stuff
%
Q.ABS_LINES_FORMAT = nan;
Q.ABSORPTION       = 'LoadTable';
Q.OUTPUT_FILE_FORMAT='binary';
Q.INCLUDES{1}='amsub.arts';

%upper sideband channels (center frequencies)
F_GRID           = [85e9,89.9e9,150.9e9,184.31e9,186.31e9,190.31e9,200e9];
Q.STOKES_DIM=1;


%- DOIT variables
%
CB.METHOD                        = 'DOIT';
% Angular grids
CB.METHOD_PRMTRS.N_ZA_GRID       =  19;
CB.METHOD_PRMTRS.N_AA_GRID       =  10;
CB.METHOD_PRMTRS.ZA_GRID_OPT_FILE = fullfile(atmlab_example_data, ...
                                                           'doit_za_grid.xml');
CB.METHOD_PRMTRS.EPSILON         = [0.1 0.01 0.01 0.01];
CB.METHOD_PRMTRS.SCAT_ZA_INTERP  = 'linear';
CB.METHOD_PRMTRS.ALL_F           = 0;
CB.LIMITS                        =[5e3 15e3]; %dummy,later there is a check
Q.CLOUDBOX_DO                    = 1;
Q.CLOUDBOX                       = CB;

clear CB

%------------------------------------------------------------------------------
 

%properties for adding pnd fields
alpha=0;Ni=10;xnorm=50e-6;
[x_i,w_i]=gauss_laguerre(alpha,Ni,xnorm);
%x_i will be the diameter of the particles considered
%calculate ssp
for i=1:2
 if i==1
    f_grid=94e9;
 elseif i==2
    if length(F_GRID)==1
       f_grid=[F_GRID,F_GRID+1e6];
    else
       f_grid=[F_GRID];
    end
 end   
 F=create_ssp('sphere',f_grid,x_i/2);
 P(i).SSP=F;
 P(i).PSD='MH97';
 P(i).method='gauss-laguerre';
 P(i).x=x_i;
 P(i).w=w_i;
 P(i).x_norm=xnorm;
 P(i).shape='sphere';  
end
C.PROPS=P;

grids_cs{1}=G(5).GRID1; 

clear F f_grid P Ni alpha w_i x_i xnorm i

%- fullsky simulations
%
[Y,ydata,DY,G] = asg2y_1d_cloudsat(G,grids_cs,C,Q,workfolder)

delete_tmpfolder(workfolder)


for iv=1:length(C.USE_LATS)
    
    if Q.STOKES_DIM==2
       Y1=Y(1:2:end,iv);
       K(iv).Y=reshape(Y1,length(ydata.f),length(ydata.los));
       Q1=Y(2:2:end,iv);
       K(iv).Q=reshape(Q1,length(ydata.f),length(ydata.los));
    else
       Y1=Y(:,iv);
       K(iv).Y=reshape(Y1,length(ydata.f),length(ydata.los));
    end
    K(iv).freq=ydata.f;
    K(iv).los=ydata.los;
    K(iv).lat=C.USE_LATS(iv);

    %find the fields of interest
    fields={'Temperature field','Altitude field','Water vapour','IWC field'};
    fv=[];
    for fi=1:length(fields)
        fv=[fv,find(strcmp({G{iv}.NAME},fields{fi}))];
    end
    K(iv).G=G{iv}(fv);

end
