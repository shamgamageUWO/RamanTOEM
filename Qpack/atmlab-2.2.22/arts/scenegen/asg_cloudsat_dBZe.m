% ASG_CLOUDSAT_DBZE reads in cloudsat data on gformat
%
%          G(1) will holds radar reflectivity data.
%          If it is desired G(1+i) will holds
%          auxilirary data
%
% FORMAT   G=asg_cloudsat_dbze( G, data, leg, latitude, z_grid, aux ,dBZemin)
% 
% IN      
%          G        original gformat data
%                   can be empty             
%          data     name of a cloudsat file
%          leg      options 1,2, or 3 see cloudsat_read
%                   for definitions
%          latitude latitude region to be read in [lat1 lat2] 
% OPT      z_grid   the data will be binned on this grid
%                   default is the mean of the cloudsat
%                   array of grids
%          aux      auxilirary data,options can for instance be
%                   {'DEM_elevation','Longitude','TAI_start','Profile_time'}
%                   default are none
%          dBZemin  Lowest value of dBZe to be considered
%                   default is -50  
%
%example usage on how to read in data from
%a cloudsat 2B-GEOPROF file
%
%datadir='/home/bengt/CIWSIR/Dataset_gen/CloudSAT_data/Data/';
%data=[datadir,'2006166131201_00702_CS_2B-GEOPROF_GRANULE_P_R04_E00.hdf'];
%z_grid=[0:1e3:20e3]'; 
%aux={'DEM_elevation','Longitude','TAI_start','Profile_time'};
%leg=2;
%latitude=[0 5];
%[G,D]=gfin_cloudsat_dBZe([],data,aux,[],leg,latitude,[]);
%
%2007-11-05 created by Bengt Rydberg 

function [G]=asg_cloudsat_dBZe(G,data,leg,latitude,varargin)

[z_grid,aux,dBZemin]=optargs(varargin,{[],[],-50});

fields= {'Latitude','Height','Radar_Reflectivity',...
                    'CPR_Cloud_mask','Longitude'};

name = 'Radar_Reflectivity';
type = 'dBZe';
dims = [1 2];

D.DIM=3;
D.GRID1_NAME='altitude';
D.GRID2_NAME='latitude';
D.GRID3_NAME='longitude';


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
   error('the selected cloudsat file was not found')
end

%The data in P is a function of (lat,alt) and the altitude is decreasing,
%but we want is as function of (alt,lat) and increasing altitude,
%therefore we transpose the data and flip it upside down
%note that nothing happens with the latitude vector
%since the flipud will be performed on a row vector for latitude 

for i=1:length(fields)
    P.(fields{i}) = flipud(P.(fields{i})');
end


% The code was: else exist('z_grid','var') 
% Correct that it shall be a "pure" else?yes
if ~exist('z_grid','var') 
   P.z_grid=mean(P.Height')';
else 
   if ~isempty(z_grid)
      P.z_grid=z_grid;
   else
      P.z_grid=mean(P.Height')';
   end
end

%remove noisy data not to be identified as clouds
cind=zeros(size(P.CPR_Cloud_mask));
cind(find(P.CPR_Cloud_mask>=20))=1;%cloudy data
P.Radar_Reflectivity=P.Radar_Reflectivity.*cind-(cind-1)*dBZemin;
P.Radar_Reflectivity(find(P.Radar_Reflectivity<dBZemin))=dBZemin;



if length(fields)>4
   kvec=[1 5:length(fields)];
else
  kvec=1;
end


for ik=kvec
    if ik==1
       ind=3;
       H=G;
       H.DATA_UNIT='dBZe';
       i=1;
    else
      ind=ik;
      H(end+1)=H(end);
      i=length(H);
      H(i).DATA_UNIT='?';
    end
    H(i).NAME=fields{ind};
    H(i).DATA_NAME=fields{ind};
    y=P.(fields{ind});
    %find out dimensionality of loaded data
    S=[size(y)==size(P.Latitude)];
    if S(1)==1 & S(2)==1 
       %data is a vector 
       for id = 1 : length(dims)
           gname = sprintf( 'GRID%d', dims(id) );
           if id == 1
	      [H(i).(gname)] = [];
           elseif id == 2
	      [H(i).(gname)] = vec2col(P.Latitude)';
           elseif id == 3
              [H(i).(gname)] = [];
           end
       end
       H(i).DIMS=dims(2);
       H(i).DATA=y;
    elseif  S(1)==1 & S(2)==0
       %data is a scalar
       H(i).GRID1=[];
       H(i).GRID2=[];
       H(i).GRID3=[];
       H(i).DIMS=[];
       H(i).DATA=y;
    elseif  S(1)==0 & S(2)==1
       %data is a matrix
       y1=zeros(length(P.z_grid),size(y,2));
       warning off;
       %bin the data on altitude grid
       for iy=1:size(y,2)
           y1(:,iy)=binning(P.z_grid,P.Height(:,iy),y(:,iy));
       end
       y=y1;
       warning on;
       if ik~=1
	  warning(['the data in fields ',fields{ind},' has been binned',...
                  ' to fit on a z_grid']);
       end
       for id = 1 : length(dims)
           gname = sprintf( 'GRID%d', dims(id) );
           if id == 1
              [H(i).(gname)] = P.z_grid;
           elseif id == 2
	      [H(i).(gname)] = vec2col(P.Latitude)';
           elseif id == 3
              [H(i).(gname)] = [];
           end
       end
       if dims(1)~=1 | dims(2)~=2 | dims(3)~=3
	  %data is y(z,lat) change order if necessary
	  grid_ind=[dims(1) dims(2)];
	  if grid_ind(1)>grid_ind(2)
             y=y';
          end
       end
       H(i).DATA=y;
       H(i).DIMS=sort([dims(1) dims(2)]);
   else
       error('unknown dimensionality of data');
   end

   H(i).SOURCE=data;
end
 
G=H;


G0 = gf_empty( 3 );
field={G(:).NAME};
ind=find(strcmp(field,{'Radar_Reflectivity'}));
H1=G0;
H1=gf_set_fields(H1,'TYPE','atm_data','NAME',G(ind).NAME,...
               'SOURCE',G(ind).SOURCE,'DATA_NAME',G(ind).DATA_NAME,...
               'DATA_UNIT',G(ind).DATA_UNIT);
H1=gf_set(H1,G(ind).DATA,[{G(ind).GRID1},{G(ind).GRID2'},{}]);     
H1=gf_set_fields(H1,'GRID1_NAME','altitude',...
               'GRID1_UNIT','m','GRID2_NAME','latitude',...
               'GRID2_UNIT','degree');

ind=find(strcmp(field,{'Longitude'}));
H1(2)=G0;
H1(2)=gf_set_fields(H1(2),'TYPE','atm_data','NAME',G(ind).NAME,...
               'SOURCE',G(ind).SOURCE,'DATA_NAME',G(ind).DATA_NAME,...
               'DATA_UNIT','degree');
H1(2)=gf_set(H1(2),G(ind).DATA',[{G(ind).GRID2'}]);     
H1(2)=gf_set_fields(H1(2),'GRID1_NAME','latitude',...
               'GRID1_UNIT','degree');

ind=find(strcmp(field,{'DEM_elevation'}));
H1(3)=G0;
H1(3)=gf_set_fields(H1(3),'TYPE','atm_data','NAME',G(ind).NAME,...
               'SOURCE',G(ind).SOURCE,'DATA_NAME',G(ind).DATA_NAME,...
               'DATA_UNIT','m');
H1(3)=gf_set(H1(3),G(ind).DATA',[{G(ind).GRID2'}]);     
H1(3)=gf_set_fields(H1(3),'GRID1_NAME','latitude',...
               'GRID1_UNIT','degree');

ind1=find(strcmp(field,{'TAI_start'}));
ind2=find(strcmp(field,{'Profile_time'}));
sec_of_day=60*60*24;
mjd1=date2mjd(1993,1,1,0,0,0)+(G(ind1).DATA+G(ind2).DATA)/sec_of_day;
H1(4)=G0;
H1(4)=gf_set_fields(H1(3),'TYPE','mjd','NAME','mjd',...
               'SOURCE',G(ind1).SOURCE,'DATA_NAME','mjd',...
               'DATA_UNIT','days');
H1(4)=gf_set(H1(4),mjd1',[{G(ind2).GRID2'}]);     
H1(4)=gf_set_fields(H1(4),'GRID1_NAME','latitude',...
               'GRID1_UNIT','degree');

G=H1;