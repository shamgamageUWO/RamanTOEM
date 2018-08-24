%ASG_CLOUDSAT_ECMWF reads in cloudsat ecmwf data
%
%  reads in temperature, humidity, and ozone on
%  gformat data. The ecmwf data from the cloudsat
%  files only extends up to approximately 25 km.
%
%  OUT G        gformat data 
%  
%  IN  data     name of datafiles
%      leg      leg of cloudsat
%      grids_cs grids
%  OPT aux      auxilirary data (see gfin_cloudsat_ecmwf)
%
% example usage:
%  leg=2;
%  datadir='/home/bengt/CIWSIR/Dataset_gen/CloudSAT_data/Data/';
%  data=[datadir,'2006166131201_00702_CS_ECMWF-AUX_GRANULE_P_R03_E00.hdf'];
%  latitude=[-90 90];
%  [G]=asg_cloudsat_ecmwf(data,leg,latitude,aux)

function [G]=asg_cloudsat_ecmwf(data,leg,grids_cs,aux)



if leg==2

    [G,D]=gfin_cloudsat_ecmwf([],[],data,aux,leg,[-90 90]);

else
    %read in both leg 1 and 3
    
    [G1,D]=gfin_cloudsat_ecmwf([],[],data,aux,1,[-90 0]);
    [G2,D]=gfin_cloudsat_ecmwf([],[],data,aux,3,[0 90]);
    
    %merge leg 1 and 3

    for i=1:length(G1)
        G(i)=G1(i);
        G(i).DATA=[G2(i).DATA G1(i).DATA];
        G(i).GRID2=[vec2col(G2(i).GRID2)' vec2col(G1(i).GRID2)'];
    end

end


if any(strcmp(aux,'DEM_elevation'))
   dem=1;
   ind=find(strcmp({G(:).NAME},'DEM_elevation'));
   indv=find(G(ind).DATA==-9999);
   G(ind).DATA(indv)=0;
end

%get the ecmwf data on a pressure grid
%G(1) holds pressure data on an altitude grid
%G(2:end) holds atmospheric data on an altitude grid
%
%take the pressure grid closest to 0 degree latitude
%as the pressure grid to interpolate the data on

lat_ind=min( find( abs(G(1).GRID2)==min( abs(G(1).GRID2) ) ) );
p_grid_ecmwf=G(1).DATA(:,lat_ind);

%remove negative values of this grid
p_grid_ecmwf=p_grid_ecmwf( find( p_grid_ecmwf>0 ) );

%create a lower resolution lat_grid_ecmwf
%lat_grid_ecmwf=[G(1).GRID2(1) G(1).GRID2(2:500:end-1)  G(1).GRID2(end)]; 
for i=1:length(grids_cs{2})
    [m1,ind1]=min(abs(G(1).GRID2-grids_cs{2}(i)));
    lat_grid_ecmwf(i)= G(1).GRID2(ind1);
end

%now interpolate the data on this p_grid_ecmwf
%and lat_grid_ecmwf
%interp linearly and extrap to the closest value 
  
if dem
 ilen=length(G)-2;
else
 ilen=length(G)-1;
end

for i=1:ilen

    G(i+1).GRID1=p_grid_ecmwf;
    G(i+1).GRID2=grids_cs{2};
    
    DATA=zeros(length(p_grid_ecmwf),length(lat_grid_ecmwf));
    DATA_extrap=zeros(length(p_grid_ecmwf),length(lat_grid_ecmwf));
    
    for j=1:length(lat_grid_ecmwf)
        ind_j=min(find(lat_grid_ecmwf(j)==G(1).GRID2));
        ind_p=find(G(1).DATA(:,ind_j)>0);
        
        DATA_extrap(:,j)=interp1(log(G(1).DATA(ind_p,ind_j)),...
                          G(i+1).DATA(ind_p,ind_j),...
                          log(p_grid_ecmwf),'nearest','extrap');
        
        DATA(:,j)=interp1(log(G(1).DATA(ind_p,ind_j)),...
                          G(i+1).DATA(ind_p,ind_j),...
                          log(p_grid_ecmwf));
    end

    DATA(find(isnan(DATA)))=DATA_extrap(find(isnan(DATA)));
    G(i+1).DATA=DATA;

end
 
if dem
 G=G(2:5);
 indg=find(G(4).GRID2(1:end-1)-G(4).GRID2(2:end)~=0);
 G(4).DATA=interp1(G(4).GRID2(indg),G(4).DATA(indg),...
                   grids_cs{2},'nearest','extrap');
 G(4).GRID2=grids_cs{2};
 %plot(grids_cs{2},de,G(4).GRID2,G(4).DATA,'r')
else
 G=G(2:4);
end

G(1).NAME= 'Temperature field';
G(1).DATA_UNIT='K';

%now the units for humidity and ozone are specific humidity
%we want them in vmr

Ma=28.966; %molecular mass of dry air
Mw=18.016; %molecular mass of water
Mo=47.998; %molecular mass of ozone 

h2o_vmr=Ma/Mw*G(2).DATA.* (1./(1-G(2).DATA*(1+Ma/Mw)));

%h2o_unk is a for calculating ozone vmr
h2o_unk=(1-G(2).DATA)./(Ma/Mw*G(2).DATA+1-G(2).DATA);

G(2).DATA=h2o_vmr; 
G(2).NAME='Water vapour';
G(2).DATA_NAME='Volume mixing ratio';

G(3).DATA=G(3).DATA.*(Ma*h2o_unk+Mw*h2o_vmr)/Mo;
G(3).NAME='Ozone';
G(3).DATA_NAME='Volume mixing ratio';

D.GRID1_NAME='Pressure';
D.GRID1_UNIT='Pascal';



G0 = gf_empty( 3 );
field={G(:).NAME};
ind=find(strcmp(field,{'Temperature field'}));
H1=G0;
H1=gf_set_fields(H1,'TYPE','atm_data','NAME',G(ind).NAME,...
               'SOURCE',G(ind).SOURCE,'DATA_NAME',G(ind).DATA_NAME,...
               'DATA_UNIT',G(ind).DATA_UNIT);
H1=gf_set(H1,G(ind).DATA,[{G(ind).GRID1},{G(ind).GRID2'},{}]);     
H1=gf_set_fields(H1,'GRID1_NAME','pressure',...
               'GRID1_UNIT','Pa','GRID2_NAME','latitude',...
               'GRID2_UNIT','degree');

H1(2)=G0;
ind=find(strcmp(field,{'Water vapour'}));
H1(2)=G0;
H1(2)=gf_set_fields(H1(2),'TYPE','atm_data','NAME','H2O',...
               'SOURCE',G(ind).SOURCE,'DATA_NAME','vmr',...
               'DATA_UNIT','1');
H1(2)=gf_set(H1(2),G(ind).DATA,[{G(ind).GRID1},{G(ind).GRID2'},{}]);     
H1(2)=gf_set_fields(H1(2),'GRID1_NAME','pressure',...
               'GRID1_UNIT','Pa','GRID2_NAME','latitude',...
               'GRID2_UNIT','degree');

H1(3)=G0;
ind=find(strcmp(field,{'Ozone'}));
H1(3)=G0;
H1(3)=gf_set_fields(H1(3),'TYPE','atm_data','NAME','O3',...
               'SOURCE',G(ind).SOURCE,'DATA_NAME','vmr',...
               'DATA_UNIT','1');
H1(3)=gf_set(H1(3),G(ind).DATA,[{G(ind).GRID1},{G(ind).GRID2'},{}]);     
H1(3)=gf_set_fields(H1(3),'GRID1_NAME','pressure',...
               'GRID1_UNIT','Pa','GRID2_NAME','latitude',...
               'GRID2_UNIT','degree');
        
if length(field)>3
 for i=4:length(field)
   H1(i)=G0;
   if strcmp(field(i),'DEM_elevation')
      H1(i)=gf_set_fields(H1(i),'TYPE','atm_data','NAME',...
               'surface altitude','SOURCE',G(i).SOURCE,...
               'DATA_NAME',G(i).DATA_NAME,'DATA_UNIT','m');
      H1(i)=gf_set(H1(i),G(i).DATA',[{} {G(i).GRID2'} {} ]) ;
      H1(i)=gf_set_fields(H1(i),'GRID1_NAME','latitude',...
               'GRID1_UNIT','degree');
   else
      H1(i)=gf_set_fields(H1(i),'TYPE','atm_data','NAME',...
               G(i).NAME,'SOURCE',G(i).SOURCE,...
               'DATA_NAME',G(i).DATA_NAME,'DATA_UNIT',G(i).DATA_UNIT);
      H1(i)=gf_set(H1(i),G(i).DATA,[{G(i).GRID1} {G(i).GRID2} {G(i).GRID3} ]); 
   end
 end
end 

G=H1;

% GFIN_CLOUDSAT_ECMWF reads in cloudsat data on gformat
%
%          G(1) will holds pressure data.
%          G(2) will holds temperature data.
%          G(3) will holds humidity data.
%          G(4) will holds ozone data.
%          If it is desired G(1+i) will holds
%          auxilirary data
%
% FORMAT   G=gfin_cloudsat_ecmwf( D, G, data, aux, leg,latitude)
% 
% IN       D        G format definition structure 
%                   can be empty
%          G        original gformat data
%                   can be empty             
%          data     name of a cloudsat file
% OPT      leg      options 1,2, or 3 see cloudsat_read
%                   for definitions
%                   default is 2
%          latitude latitude region to be read in [lat1 lat2]
%                   default is [0 5] 
%          aux      auxilirary data,options can for instance be
%                   {'DEM_elevation','Longitude','TAI_start','Profile_time'}
%                   default are none
%
%example usage on how to read in data from
%a cloudsat 2B-GEOPROF file
%
%datadir='/home/bengt/CIWSIR/Dataset_gen/CloudSAT_data/Data/';
%data=[datadir,'2006166131201_00702_CS_ECMWF-AUX_GRANULE_P_R03_E00.hdf'];
%leg=2;
%latitude=[0 5];
%[G,D]=gfin_cloudsat_ecmwf([],[],data,[],leg,latitude,[]);
%
%2007-12-04 created by Bengt Rydberg 

function [G,D]=gfin_cloudsat_ecmwf( D, G, data, aux, leg, latitude)


if ~isempty(G) & isempty(D)
   error('If G is defined D must be defined')
end

%- Default values
%
if isempty(D)
  D.DIM        = 3;
  D.GRID1_NAME = 'Altitude';
  D.GRID1_UNIT = 'm';
  D.GRID2_NAME = 'Latitude';
  D.GRID2_UNIT = 'deg';
  D.GRID3_NAME = 'Longitude';
  D.GRID3_UNIT = 'deg';
  G            = asgG;
  G.DIMADD     = [];
end

fields= {'EC_height','Latitude','Pressure',...
                    'Temperature','Specific_humidity','Ozone'};

%leg_DEFAULT      = 2;
%latitude_DEFAULT = [0 5];
%name_DEFAULT     = 'ECMWF_temperature';
%type_DEFAULT     = 'K';
%dims_DEFAULT     = [1 2];
%aux_DEFAULT      = [];
%set_defaults;

[aux]= optargs({aux},{[]} );



if D.DIM < 3
  error( 'D.DIM must be >= 3 to accommodate data of type cloudsat type.' );
end

for id = 1 : D.DIM
    gname = lower( D.(sprintf('GRID%d_NAME',id)) );
    if strncmp( gname, 'altitude', 8 )
      dims(1) = id;
    elseif strncmp( gname, 'latitude', 8 )
      dims(2) = id;
    elseif strncmp( gname, 'longitude', 8 )
      dims(3) = id;
    end
    
end

if any( dims == 0 )
    error( [ 'Setting of *dims* failed. Altitude, latitude or ',...
             'longitude was nof found among the grid names.' ] );
end

if ~isempty(aux)
   for i=1:length(aux)
       if isempty(find(strcmp(aux(i),fields)))
          fields{end+1}=aux{i};
       end
   end
end

%read data 
P = cloudsat_read(data,fields,'leg',leg,'lat',latitude);

if ischar(P)
   error('error in reading the file')
end

for i=1:length(fields)
    if strcmp(fields{i},'EC_height')
       P.(fields{i})=flipud( vec2col( P.(fields{i}) ) );
    elseif strcmp(fields{i},'Latitude')
       P.(fields{i})=vec2col( P.(fields{i}) )';
    else
       P.(fields{i}) = flipud(P.(fields{i})');
    end
end


kvec=1:(length(fields)-2);

H=G;
for ik=kvec
    ind=2+ik;
    H(ik).NAME=fields{ind};
    H(ik).DATA_UNIT='?';
    H(ik).DATA_NAME=fields{ind};
    y=P.(fields{ind});
    
    %find out dimensionality of loaded data
    S=[size(y)==size(P.Latitude)];
    if S(1)==1 & S(2)==1 
       %data is a vector 
       for id = 1 : length(dims)
           gname = sprintf( 'GRID%d', dims(id) );
           if id == 1
	      [H(ik).(gname)] = [];
           elseif id == 2
	      [H(ik).(gname)] = vec2col(P.Latitude)';
           elseif id == 3
              [H(ik).(gname)] = [];
           end
       end
       H(ik).DIMS=dims(2);
       H(ik).DATA=y; 
    elseif  S(1)==1 & S(2)==0
       %data is a scalar
       H(ik).GRID1=[];
       H(ik).GRID2=[];
       H(ik).GRID3=[]; 
       H(ik).DIMS=[]; 
       H(ik).DATA=y;   
    elseif  S(1)==0 & S(2)==1
       %data is a matrix
        for id = 1 : length(dims)
           gname = sprintf( 'GRID%d', dims(id) );
           if id == 1
              [H(ik).(gname)] = P.EC_height;
           elseif id == 2
	      [H(ik).(gname)] = vec2col(P.Latitude)';
           elseif id == 3
              [H(ik).(gname)] = [];
           end
       end
       if dims(1)~=1 | dims(2)~=2 | dims(3)~=3
	  %data is y(z,lat) change order if necessary
	  grid_ind=[dims(1) dims(2)];
	  if grid_ind(1)>grid_ind(2)
             y=y';
          end
       end
       H(ik).DATA=y;
       H(ik).DIMS=sort([dims(1) dims(2)]);
   else
       error('unknown dimensionality of data')
   end

   H(ik).SOURCE=data;
end
 
G=H;
