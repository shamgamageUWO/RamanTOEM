% ASG2Q   Maps ASG data to qarts structure
%
%    The function searches the input gformat data and sets corresponding qarts
%    fields. Data type is primarily determined by the field NAME, as follows:
%
%        NAME                  ARTS variable
%        ----                  ----
%        temperature           t_field
%        altitude              z_field
%        vmr                   vmr_field
%        volume mixing ratio   vmr_field
%        geoid radius          r_geoid
%        surface altitude      z_surface
%
%    The NAME text string can include uppercase lettters. Not all these
%    variables must be covered. There can only exist one element in G that 
%    gives a match, beside for vmr data. 
%
%    For vmr, each match adds a species to ABS_SPECIES. For such cases, G
%    must contain the field TAG that must match ABS_SPECIES.TAG directly.
%    ABS_SPECIES.RETRIEVE is set to false.
%
%
% FORMAT   Q = asg2q( G, Q, workfolder )
%        
% OUT   Q            Qarts structure with some fields set.
% IN    G            ASG data.
%       Q            Original qarts structure.
%       workfolder   Folder where created files shall be saved.

% 2010-01-25   Created by Patrick Eriksson


function Q = asg2q( G, Q, workfolder )

%- Basic checks of input                                                    %&%
%                                                                           %&%
rqre_nargin( 3, nargin );                                                   %&%
if isempty(workfolder)  |  ~exist(workfolder,'dir')                         %&%
  error( 'Empty or not existing folder in *workfolder*.' );                 %&%
end                                                                         %&%
                                                                            %&%
                                                                            %&%
%- Check that atmospheric grids are set                                     %&%
%                                                                           %&%
if ~qarts_isset( Q.ATMOSPHERE_DIM )                                         %&%
  error( 'Q.ATMOSPHERE_DIM must be set.' );                                 %&%
end                                                                         %&%
if ~qarts_isset( Q.P_GRID )                                                 %&%
  error( 'Q.P_GRID must be set.' );                                         %&%
end                                                                         %&%
%                                                                           %&%
dim    = qarts_get( Q.ATMOSPHERE_DIM );
p_grid = qarts_get( Q.P_GRID );
np     = length( p_grid );
%                                                                           %&%
rqre_in_range( dim, 1, 3, 'Q.ATMOSPHERE_DIM' );                             %&%
if ~istensor1(p_grid)  |  np < 2                                            %&%
  error( 'Q.P_GRID must be a tensor1 with length > 1.' );                   %&%
end                                                                         %&%
%                                                                           %&%
if dim >= 2 
  if ~qarts_isset( Q.LAT_GRID )                                             %&%
    error( 'Q.LAT_GRID must be set.' );                                     %&%
  end                                                                       %&%
  %lat_grid = qarts_grid( Q.LAT_GRID );
  lat_grid = Q.LAT_GRID;
  nlat     = length( lat_grid );  
  if ~istensor1(lat_grid)  |  nlat < 2                                      %&%
    error( 'Q.LAT_GRID must be a tensor1 with length > 1.' );               %&%
  end                                                                       %&%
  if Q.ATMOSPHERE_DIM >= 3 
    if ~qarts_isset( Q.LON_GRID )                                           %&%
      error( 'Q.LON_GRID must be set.' );                                   %&%
    end                                                                     %&%
    %lon_grid = qarts_grid( Q.LON_GRID );
    lon_grid = Q.LON_GRID;
    nlon     = length( lon_grid );  
    if ~istensor1(lon_grid)  |  nlon < 2                                    %&%
      error( 'Q.LON_GRID must be a tensor1 with length > 1.' );             %&%
    end                                                                     %&%
  end
end


%- Determine expected variable sizes
%
if Q.ATMOSPHERE_DIM == 1
  sfield = [ np    1    1    1 ];
  ssurf  = [ 1     1    1    1 ];
elseif Q.ATMOSPHERE_DIM == 2
  sfield = [ np   nlat  1    1 ];
  ssurf  = [ 1    nlat  1    1 ];
else
  sfield = [ np   nlat nlon  1 ];
  ssurf  = [ 1    nlat nlon  1 ];
end



%--- Clear sky profiles -------------------------------------------------------

%- t_field
%
i = find( strncmp( lower({G.NAME}), 'temperature', 11 ) );
%
if ~isempty(i)
  if length(i) > 1                                                          %&%
    error('Multiple matches between G.NAME and ''temperature'' was found'); %&%
  end                                                                       %&% 
  if G(i).DIM ~= dim                                                        %&%
    error( sprintf('Wrong dimension of G(%d).',i) );                        %&%
  end                                                                       %&%
  s = [ size(G(i).DATA) 1 1 ];                                              %&%
  if any( s(1:4) ~= sfield )                                                %&%
    error( sprintf('Wrong size of G(%d).DATA',i) );                         %&%
  end                                                                       %&%
  %                                                                         %&%
  Q.T_FIELD = fullfile( workfolder, 't_field.xml' );
  xmlStore( Q.T_FIELD, G(i).DATA, 'Tensor3' );
  %
end


%- z_field
%
i = min( find( strncmp( lower({G.NAME}), 'altitude', 8 ) ) );
%
if ~isempty(i)
  if length(i) > 1                                                          %&%
    error('Multiple matches between G.NAME and ''altitude'' was found');    %&%
  end                                                                       %&% 
  if G(i).DIM ~= dim                                                        %&%
    error( sprintf('Wrong dimension of G(%d).',i) );                        %&%
  end                                                                       %&%
  s = [ size(G(i).DATA) 1 1 ];                                              %&%
  if any( s(1:4) ~= sfield )                                                %&%
    error( sprintf('Wrong size of G(%d).DATA',i) );                         %&%
  end                                                                       %&%
  %                                                                         %&%
  Q.Z_FIELD = fullfile( workfolder, 'z_field.xml' );
  xmlStore( Q.Z_FIELD, G(i).DATA, 'Tensor3' );
  %
end



%- vmr_field
%
%ind = find( strcmp( lower({G.DATA_NAME}), {'vmr' 'volume mixing ratio'} ) );
ind = find( strcmp( lower({G.DATA_NAME}), {'volume mixing ratio'} ) );
%
if ~isempty(ind)
  %
  vmr_field = zeros( [ length(ind) sfield ] );
  %
  for i = 1 : length(ind)
    if G(ind(i)).DIM ~= dim                                                 %&%
      error( sprintf('Wrong dimension of G(%d).',ind(i)) );                 %&%
    end                                                                     %&%
    s = [ size(G(ind(i)).DATA) 1 1 ];                                       %&%
    if any( s(1:4) ~= sfield )                                              %&%
      error( sprintf('Wrong size of G(%d).DATA',ind(i)) );                  %&%
    end                                                                     %&%
    %                                                                       %&%
    vmr_field(i,:,:,:)        = G(ind(i)).DATA;
    if i==1
       Q.ABS_SPECIES=[];
    end
    Q.ABS_SPECIES(i).TAG      = G(ind(i)).PROPS;
    Q.ABS_SPECIES(i).RETRIEVE = false;
  end
  %
  Q.VMR_FIELD = fullfile( workfolder, 'vmr_field.xml' );
  xmlStore( Q.VMR_FIELD, vmr_field, 'Tensor4' );
  %
end





%--- Surface and geoid -----------------------------------------------------

%- r_geiod
%
i = find( strcmp( lower({G.NAME}), 'geoid radius' ) );
%
if ~isempty(i)
  if length(i) > 1                                                          %&%
    error('Multiple matches between G.NAME and ''geoid radius'' was found');%&%
  end                                                                       %&% 
  if G(i).DIM ~= dim-1                                                      %&%
    error( sprintf('Wrong dimension of G(%d).',i) );                        %&%
  end                                                                       %&%
  s = [ size(G(i).DATA) 1 1 ];                                              %&%
  if any( s(1:4) ~= ssurf )                                                 %&%
    error( sprintf('Wrong size of G(%d).DATA',i) );                         %&%
  end                                                                       %&%
  %                                                                         %&%
  Q.R_GEOID = fullfile( workfolder, 'r_geoid.xml' );
  xmlStore( Q.R_GEOID, G(i).DATA, 'Matrix' );
  %
end


%- z_surface
%
i = min( find( strcmp( lower({G.NAME}), 'surface altitude' ) ) );
%
if ~isempty(i)
  if length(i) > 1                                                          %&%
    error( ...                                                              %&%
      'Multiple matches between G.NAME and ''surface altitude'' was found');%&%
  end                                                                       %&% 
  if G(i).DIM ~= dim-1                                                      %&%
    error( sprintf('Wrong dimension of G(%d).',i) );                        %&%
  end                                                                       %&%
  s = [ size(G(i).DATA) 1 1 ];                                              %&%
  if any( s(1:4) ~= ssurf )                                                 %&%
    error( sprintf('Wrong size of G(%d).DATA',i) );                         %&%
  end                                                                       %&%
  %                                                                         %&%
  Q.Z_SURFACE = fullfile( workfolder, 'z_surface.xml' );
  xmlStore( Q.Z_SURFACE, G(i).DATA, 'Matrix' );
  %
end


%--- Cloud box variables -----------------------------------------------------

ind = find( strncmp( lower({G.DATA_NAME}), 'particle', 8 ) );
%

if ~isempty(ind)
  Q.CLOUDBOX_DO        = true;
  Q.CLOUDBOX.PND_FIELD = [];
  Q.CLOUDBOX.SCAT_DATA = [];
  %
  for i = 1 : length(ind)
    if G(ind(i)).DIM ~= dim                                                 %&%
      error( sprintf('Wrong dimension of G(%d).',ind(i)) );                 %&%
    end                                                                     %&%
    s = [ size(G(ind(i)).DATA) 1 1 ];                                       %&%
    if any( s(1:4) ~= sfield )                                              %&%
      error( sprintf('Wrong size of G(%d).DATA',ind(i)) );                  %&%
    end                                                                     %&%
    %  
    Q.CLOUDBOX.SCAT_DATA{i} = ...
                         fullfile( workfolder, sprintf('scat_data%d.xml',i) );
    xmlStore( Q.CLOUDBOX.SCAT_DATA{i}, G(ind(i)).PROPS, ...
                                                     'SingleScatteringData' );
    Q.CLOUDBOX.PND_FIELD{i} = ...
                     fullfile( workfolder, sprintf('pnd_field_raw%d.xml',i) );
    A.data= G(ind(i)).DATA;
    A.grids{1}= G(ind(i)).GRID1;
    A.grids{2}= G(ind(i)).GRID2;
    A.grids{3}= G(ind(i)).GRID3;
    A.gridnames{1}='pressure';
    A.gridnames{2}='latitude';
    A.gridnames{3}='longitude';
    xmlStore(Q.CLOUDBOX.PND_FIELD{i},A,'GriddedField3');  
 end

else
 Q.CLOUDBOX_DO        = false;
end





