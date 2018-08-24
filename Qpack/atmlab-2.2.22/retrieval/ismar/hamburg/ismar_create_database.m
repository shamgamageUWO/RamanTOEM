% Function for creating the database for the ISMAR-Retrieval. The database 
% will be stored as mat-files. Of course, each preprocessed ARTS-simulation
% has to be a mat-file. The database will consist of:
%
% -the grids
%   case_index
%   pressure
%   channel_no
%   looking_direction
%   scattering_element_index
%   polarization
%
% -the channel definition, 
%   channel_def(channel_no), which consists of the center frequencies and 
%                           the offsets of the sidebands
%
% -the properties of the scattering elements
%   mass(scattering_element_index)
%   dmax(scattering_element_index), maximum Dimension
%   volume(scattering_element_index)
%   scattering_element_type(scattering_element_index), an cell array with a
%                           tag according to the arts method 
%                           "ParticleSpeciesSet"
%
% -the atmospheric data
%   temperature(case_index, pressure)
%   atltitude(case_index, pressure)
%   pnd_field(case_index, pressure, scattering_element_index)
%   t_b(case_index, pressure, channel_no, looking_direction, polarization)
%
% -the surface properties
%   surface_altitude(case_index)
%   surface_temperature(case_index)
%   surface_type(case_index), a cell array of strings
%   surface_reflectivity(case_index,channel_no,looking_direction,
%                     Dimension of polarization,Dimension of polarization),
%                     the two last dimensions are the 2x2 reflection
%                     matrices of a two dimensional stokes vector with the
%                     first component being the vertical and the second
%                     component being the horizontal polarization
%
% - the simulated position in space and time
%   lat(case_index), Latitude of the simulation
%   lon(case_index), Longitude of the simulation
%   time(case_index), Simulated time
%
%                           
% The
% single preprocessed ARTS-simulations will be combined to one database and 
% regridded to common grids of pressure coordinates and looking direction.
% Additionally, the doit_i_field1D_spectrum will be converted to brightness 
% temperature (Planck Tb) and then mapped to the ISMAR channels. 
% All simulations for the database must consist of the same scattering
% elements. This means all simulations to be put into the database must have
% the same scattering meta data. Each ARTS-simulation must consist of the
% into matlab converted workspace variables
%   
%   - atm_fields_compact
%   - cloudbox_limits
%   - f_grid
%   - doit_i_field1D_spectrum, here called i_field
%   - part_species
%   - pnd_field
%   - scat_data_per_part_species
%   - scat_meta_array
%   - scat_za_grid
%
% and three additional created variables:
%   - lat_lon_time, a vector consisting of the geographical position of the
%                   simulation (1st component is latitude, 2nd is longitude)
%                   and the simulated time (third component) in a numeric
%                   format
%   - surface_properties, an array of the two arts workspace variable
%                   z_surface and t_surface. 1st component is z_surface and
%                   the 2nd is t_surface
%   - surface_radiation_parameter, which is an empty array if the surface
%                   is a blackbody, or it is a structure of an 
%                   gridded_field6 if the reflectivities are given, or it
%                   is a structure of a gridded_field3 if the complex
%                   refraction indices are given. See for additional
%                   information the ARTS documentation.
%
%--------------------------------------------------------------------------
%
%Input:
%   - input_folder, the location of the single ARTS-simulations as a string
%   - input_file_identifier, if you want specific  files within the input
%                           folder, you can choose them by common name
%                           parts and wildcards(*). If not wanted, leave it
%                           empty.
%   - output_folder, the location where the created data base is to be put.  
%   - output_name, name of the database.   
%
%   30.9.2014, Manfred Brath


function ismar_create_database(input_folder,input_file_identifier,...
                                output_folder,output_name)
                            
                            
disp('   ')
disp('------------------------------------------------------------------------------')
disp([' ==>> Function: ',mfilename,' <<=='])
disp('------------------------------------------------------------------------------')
disp('   ')


%% Standard grids

%pressuregrid for regridding according for flight altitude in pressure
log_P=(linspace(log10(105000),3.5,75));
pressure=10.^log_P; %[Pa]


%angular resolution
d_angle=5; %[°]

%looking_direction_grid for regridding
looking_direction=0:d_angle:180; %[°]


%Sensor Properties
[~,channel_def]=ismar_freq2ch_simple();
channel_no=1:(size(channel_def,1)); %#ok<*NASGU>


%polarization
polarization={'vertical','horizontal'};


%% create data base


%get list of mat-files
directory_path=[input_folder,'/',input_file_identifier];
dlist=dir(directory_path);

%switch, needed later for allocating matrices
pre_allocate_flag=0;


for i=1:length(dlist) %Loop over the file list

    %filename
    name=dlist(i).name;
    
    %Check for only files
    if dlist(i).isdir==1
        continue
    end
    
    %Load data
    load([input_folder,'/',name])
    
    disp(['Index ',num2str(i),' of ',num2str(length(dlist))])
    
    
    %% Atmospheric stuff--------------------------------------------------

    %pressure grid
    p_grid=atm_fields_compact.grids{1,2};
    
    %transpose pnd-field
    pnd_field=pnd_field';
                
    %atmospheric data
    atm=atm_fields_compact.data';
    
    %cut atm and p_grid to cloudbox size
    p_pnd=p_grid(cloudbox_limits{1,1}+1:cloudbox_limits{1,2}+1); %#ok<*USENS>
    atm_pnd=atm(cloudbox_limits{1,1}+1:cloudbox_limits{1,2}+1,:);

    %Temperature
    t_pnd=squeeze(atm_pnd(:,1));

    %Altitude in m
    h_pnd=squeeze(atm_pnd(:,2));
    
    
    %% scattering stuff---------------------------------------------------
    
    %get volume, area etc. from scat_meta_data
    volume=nan(1,length(scat_meta_array));
    density=nan(1,length(scat_meta_array));
    dmax=nan(1,length(scat_meta_array));
    area=nan(1,length(scat_meta_array));
    for j=1:length(scat_meta_array)

        temp=scat_meta_array{1,j};
        volume(j)=temp.volume;      
        density(j)=temp.density;
        dmax(j)=temp.diameter_max;
        area(j)=temp.area_projected;

    end

    %Mass
    mass=volume.*density;

    %Diameter
    d=(6.*volume./pi).^(1/3);
    
    
    
    
    %allocate matrix
    se_type=cell(1,length(scat_meta_array));
    
    %build scattering element type array
    idx_start=1;
    LS=length(scat_data_per_part_species);
    
    for j=1:LS

        %get last index of species
        idx_end=idx_start+scat_data_per_part_species{1,j}-1;

        indices=idx_start:idx_end;
        
        se_type(1,indices)=repmat(part_species(1,j),1,length(indices));

        %New start index for the next species
        idx_start=idx_end+1;
    end

    %scattering element index
    scattering_element_index=1:length(scat_meta_array);

    %% Convert I-field to brightness temperature and map to channels------
    
    %Size of intensity_matrix
    qI=size(doit_i_field1D_spectrum);
    
    
    %rewrite doit_i_field1D_spectrum to vertical and horizontal polarization
    doit_i_field1D_spectrum_v=(doit_i_field1D_spectrum(:,:,:,1)+doit_i_field1D_spectrum(:,:,:,2))./2;
    doit_i_field1D_spectrum_h=(doit_i_field1D_spectrum(:,:,:,1)-doit_i_field1D_spectrum(:,:,:,2))./2;
    
    doit_i_field1D_spectrum(:,:,:,1)=doit_i_field1D_spectrum_v;
    doit_i_field1D_spectrum(:,:,:,2)=doit_i_field1D_spectrum_h;
    
        
    
    %Allocate matrices
    t_b=nan(qI);


    for j=1:length(f_grid)

       
        %Factor 2 is needed for consistence with temperature
        t_bv=i2planckTb(abs(doit_i_field1D_spectrum_v(j,:,:)),f_grid(j))*2;
        t_bh=i2planckTb(abs(doit_i_field1D_spectrum_h(j,:,:)),f_grid(j))*2;

        t_b(j,:,:,1)=t_bv;
        t_b(j,:,:,2)=t_bh;

    end  
    
    %Map brightness temperature to channels
    [t_bch]=ismar_freq2ch_simple(t_b);
    
    
    
    %% surface stuff------------------------------------------------------
    
    %Altitude of surface
    surface_altitude=surface_properties{1,1};
    
    %Surface temperature
    surface_temperature=surface_properties{1,2};
    
    
    %Get size of brightness temperature array
    qT=size(t_b);
    
    %EM-properties of surface
    if isempty(surface_radiation_parameter)
        reflectivity=zeros(qT(1),qT(3),2,2);
        
        surftype='blackbody';
    
    elseif length(surface_radiation_parameter.grids)==6 
       
        rtemp=surface_radiation_parameter.data;
        %As the surface should be only 1 point, there should be no change
        %in the geographical position. Therefore the dimension of rtemp
        %will be reduced to 4.
        rtemp=mean(mean(rtemp,6),5);
        
        %Shift the 2 stokes dimensions to the last 2 dimensions.
        reflectivity=permute(rtemp,[1,4,2,3]);
                
        surftype='misc';
    
    elseif length(surface_radiation_parameter.grids)==3
        
        %Refractive index as gridded field 3
        ntemp=surface_radiation_parameter.data;
        
        %convert to complex numbers
        ntemp_cmpl=ntemp(:,:,1)+1i*ntemp(:,:,2);
        
        qn=size(ntemp_cmpl);
        
        if  qn(2)>1
           t_ncmpl=surface_radiation_parameter.grids{1,2};
           
           %interpolate to surface temperature
           n_cmpl=interp1(t_ncmpl,ntemp_cmpl',surface_temperature,'nan');
           n_cmpl=n_cmpl';
                    
        else
            
           n_cmpl=ntemp_cmpl;                         
            
        end
        
        %Calculate reflectivity
        [THETA,N_CMPL]=meshgrid(scat_za_grid,n_cmpl);
        [Rv,Rh]=fresnel(1,N_CMPL,THETA);
        
        reflectivity=zeros(qT(1),qT(3),2,2);
        reflectivity(:,:,1,1)=Rv;
        reflectivity(:,:,1,1)=Rh;        
                
        surftype='flat';

    end
    
    %Map reflectivity to channels
    reflectivity=ismar_freq2ch_simple(reflectivity);
    
    
    
   
    
    %% Auxillary Stuff----------------------------------------------------
    
    if isempty(lat_lon_time)
        lat=nan;
        lon=nan;
        time=nan;
    else
        lat=lat_lon_time(1);
        lon=lat_lon_time(2);
        time=lat_lon_time(3);       
    end
    disp('....')
    
    
    %% regrid-------------------------------------------------------------
    
    %logarithmic p_grid
    log_p_pnd=log10(p_pnd);
    
    %regrid pnd_field
    pnd_field_rg=interp1(log_p_pnd,pnd_field,log_P,'linear',nan);
    
    %regrid Temperature
    t_pnd_rg=interp1(log_p_pnd,t_pnd,log_P,'linear',nan);
    
    %regrid Temperature
    h_pnd_rg=interp1(log_p_pnd,h_pnd,log_P,'linear',nan);
    
    %regrid to a about common pressure grid T_bch
    temp=permute(t_bch,[2,1,3,4]);
    temp_rg=interp1(log_p_pnd,temp,log_P,'linear',nan);
    t_bch_rg=permute(temp_rg,[2,1,3,4]);
        
    %regrid to common looking direction T_bch
    temp=permute(t_bch_rg,[3,2,1,4]);
    temp_rg=interp1(scat_za_grid,temp,looking_direction,'linear',nan);
    t_bch_rg=permute(temp_rg,[3,2,1,4]);
    
    %regrid to common looking direction reflectivity
    temp=permute(reflectivity,[2,1,3,4]);
    temp_rg=interp1(scat_za_grid,temp,looking_direction,'linear',nan);
    reflectivity_rg=permute(temp_rg,[2,1,3,4]);
    
    
    %% Put in the allcases matrix-----------------------------------------
    
    if pre_allocate_flag==0
        %allocate matrices
        database.pnd_field=nan([length(dlist),size(pnd_field_rg)]);
        database.temperature=nan([length(dlist),length(pressure)]);
        database.altitude=nan([length(dlist),length(pressure)]);
        
        database.t_b=nan([length(dlist),size(t_bch_rg)]);
                
        database.mass=nan(length(dlist),length(scat_meta_array));
        database.dmax=nan(length(dlist),length(scat_meta_array));
        database.volume=nan(length(dlist),length(scat_meta_array));
        database.area=nan(length(dlist),length(scat_meta_array));
                       
        database.lat=nan(length(dlist),1);
        database.lon=nan(length(dlist),1);
        database.time=nan(length(dlist),1);
        
        database.surface_altitude=nan(length(dlist),1);
        database.surface_temperature=nan(length(dlist),1);
        database.surface_type=cell(length(dlist),1);
        database.surface_reflectivity=nan([length(dlist),size(reflectivity_rg)]);
        
        %switch on button
        pre_allocate_flag=1;
    end
    
    %Variables All cases
    database.pnd_field(i,:,:)=pnd_field_rg;  
    database.temperature(i,:)=t_pnd_rg(:)';
    database.altitude(i,:)=h_pnd_rg(:)';
    
    database.t_b(i,:,:,:,:)=t_bch_rg;
    
    database.mass(i,:)=mass(:)';
    database.dmax(i,:)=dmax(:)';
    database.volume(i,:)=volume(:)';
    database.area(i,:)=area(:)';
    
    database.lat(i)=lat;
    database.lon(i)=lon;
    database.time(i)=time;
    
    database.surface_altitude(i)=surface_altitude;
    database.surface_temperature(i)=surface_temperature;
    database.surface_type{i,1}=surftype;
    database.surface_reflectivity(i,:,:,:,:)=reflectivity_rg;

    
    
end

%Case index
case_index=1:length(dlist);

%Grids
database.case_index=case_index;
database.pressure=pressure;
database.channel_no=channel_no;
database.looking_direction=looking_direction;
database.scattering_element_index=scattering_element_index;
database.polarization=polarization;


%quasi grids
database.channel_def=channel_def;
database.scattering_element_type=se_type;
database.mass=mean(database.mass,1);
database.dmax=mean(database.dmax,1);
database.volume=mean(database.volume,1);
database.area=mean(database.area,1);

%check
stdMass=sum(std(database.mass,[],1));
stdDmax=sum(std(database.dmax,[],1));
stdVolume=sum(std(database.volume,[],1));
stdArea=sum(std(database.area,[],1));

if stdMass~=0 || stdDmax~= 0 || stdVolume~=0 || stdArea~=0
    error(['amtlab:' mfilename],'It seems that there is an unwanted variance in scattering elements...')
end


%% store the results

output_filename=[output_folder,'/',output_name];


save(output_filename, '-struct', 'database','-v7.3');

          

