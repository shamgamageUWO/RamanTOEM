function ismar_import_arts_simulation(directory,basename,index)
% Function for importing the different arts-xml-output of a single
% simulation into matlab and combine them to one mat-file. The mandatory
% output of a arts-simulation for the ISMAR retrieval consist of a xml-file 
%   for each of the following arts workspace variables:
%   
%   - doit_i_field1D_spectrum
%   - f_grid
%   - scat_za_grid
%   - atm_fields_compact
%   - pnd_field
%   - scat_meta_array
%   - part_species,
%   - scat_data_per_part_species
%   - cloudbox_limits
%
%   The inputfiles must be named: BASENAME.VARIABLE_NAME.INDEX.xml
%
% Additional output of a arts-simulation for the ISMAR retrieval consist of 
% following quantities
%   - surface_radiation_parameter, which is an empty array if the surface
%                   is a blackbody, or it is a structure of an 
%                   gridded_field6 if the reflectivities are given, or it
%                   is a structure of a gridded_field5 if the complex
%                   refraction indices are given. See for additional
%                   information the ARTS documentation.
%   - surface_properties, an array of the two arts workspace variable
%                   z_surface and t_surface. 1st component is z_surface and
%                   the 2nd is t_surface
%   - lat_lon_time, a vector consisting of the geographical position of the
%                   simulation (1st component is latitude, 2nd is longitude)
%                   and the simulated time (third component) in a numeric
%                   format
% If the additional quantities are not given, then they will saved as empty
% arrays. 
%
%--------------------------------------------------------------------------
%Input:
%   - directory, the location of the xml-files of the ARTS-simulations as 
%                   a string
%   - basename, the first part of the name of the xml-file till the variable 
%                   name
%   - index, a vector with the indices of the different simulations. index
%                   can be excluded, if all simulations with the samebase
%                   should be imported.
%
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   WORKS ONLY WITH ARTS 2.2!!!!!!!   
%
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   30.9.2014, Manfred Brath


%% main variable identifier (strings)


%intensity field
i_str='doit_i_field1D_spectrum';

%frequenca grid
f_str='f_grid';

%angular grid
ang_str='scat_za_grid';

%atmosphere data
atm_str='atm_fields_compact';

%particle number density (pnd) field 
pnd_str='pnd_field';

%scattering meta array
sma_str='scat_meta_array';

%part species
p_str='part_species';

% number of different scatterer per species (scat_data_per_part_species)
sdp_str='scat_data_per_part_species';

% Cloudbox limits
cld_str='cloudbox_limits';


%put variable identifier into one cell array
vid={i_str; f_str; ang_str; atm_str; pnd_str; sma_str; p_str; sdp_str; cld_str};

%% Auxillary variable identifier (strings)

%Surface radiation parameter
srp_str='surface_radiation_parameter';

%Position in Space and time
llt_str='lat_lon_time';

%Surface properties
sur_str='surface_properties';


%put variable identifier into one cell array
vid_aux={srp_str; llt_str; sur_str};

%% control screen

disp('   ')
disp('------------------------------------------------------------------------------')
disp([' ==>> Script: ',mfilename,' <<=='])
disp('------------------------------------------------------------------------------')
disp('   ')
disp('  ')
disp('===========================')
disp(['directory: ',directory])
disp(['basename: ',basename])
disp('   ')

%% look for index 

if nargin<3
    
    %list of the xml-files
    dir_list=dir([directory,'/',basename,'*.xml']);
    
    if isempty(dir_list)
        disp('  ')
        disp('===========================')
        disp('==>>  no files found!')
        disp('===========================')
        disp('  ')
        index=[];
        
    else
       
        temp=nan(length(dir_list),1);

        %Get index from filenames
        for i=1:length(dir_list)

            name=dir_list(i).name;
            idx=strfind(name,'.');
            temp(i)=str2double(name( (idx(end-1)+1) : (idx(end)-1) ));

        end
        
        index=unique(temp);
    end
    
end

%% arts files are converted into matlab-files

%Flaf, that scat_meta_array has been loaded
flag_sma=0;

for j=1:length(index)
    
    disp('   ')
    disp(['Index = ',num2str(index(j)+1),' of ',num2str(length(index))])
    
    dir_list=dir([directory,'/',basename,'*.',num2str(index(j)),'.xml']);

    if isempty(dir_list)
        disp('  ')
        disp('===========================')
        disp('==>>  no files found!')
        disp('===========================')
        disp('  ')
        continue
    end

    %Memory for checking, if all neccessary files are there.
    mem=zeros(1,length(vid));
    
    %Go through main variable list to load and set variable names           
    for ii=1:length(vid)
    
        for i=1:length(dir_list)

            name=dir_list(i).name;
            check=strfind(name,['.',vid{ii,:}]);

            if ~isempty(check) 

                idx=ii;
                
                mem(ii)=1;
                
                disp(vid{idx,1})
                disp(name)
                disp('  ')
                
%                 dummy=xmlLoad([directory,'/',name]); %#ok<NASGU>
%                 eval([vid{idx,1},'=dummy;']);

                % To gain speed, it is not needed to always load the 
                % scattering_meta_array, because it must not change for one 
                % simulation run. Therefore just check if it is there and
                % then use the already loeded version.              
                if ii==6 && flag_sma==0
                    sma_dummy=xmlLoad([directory,'/',name]); %#ok<NASGU>
                    eval([vid{idx,1},'=sma_dummy;']);
                    flag_sma=1;

                elseif ii==6 && flag_sma==1
                    eval([vid{idx,1},'=sma_dummy;']);
                else
                    dummy=xmlLoad([directory,'/',name]); %#ok<NASGU>
                    eval([vid{idx,1},'=dummy;']);
                end
                
                break
            end

        end

        
    end
    
    
    if sum(mem)~=length(vid)
        
        disp('  ')
        disp('===========================')
        disp(['==>> for index=',num2str(index(j)),' files are missing or'])
        disp('there are more files with the same index than number of variables')
        disp('==>> continue with next index...')
        disp('===========================')
        disp('  ')
        continue
    end
    
    %%Go through auxillary variable list
    
    for ii=1:length(vid_aux)
        
        dummy=[]; %#ok<NASGU>
        
        for i=1:length(dir_list)
            
            name=dir_list(i).name;
             
            %set variable names            
            check=strfind(name,vid_aux{ii,:});


            if ~isempty(check) 
                               
                %Load Data
                dummy=xmlLoad([directory,'/',name]); %#ok<NASGU>
                
                break
            end
        end
        
        %Put dummy to the variable name
        disp(vid_aux{ii,1})
        eval([vid_aux{ii,1},'=dummy;']);
    end
    
      
    
    
    
        
    %% save in matfile
    variables=[vid;vid_aux];
    savename=[directory,'/',basename,'_combined_',num2str(index(j)),'.mat'];
    save(savename,variables{:})

    %%delete the single artsfiles
    for i=1:length(dir_list)
        delete([directory,'/',dir_list(i).name])
    end
end

