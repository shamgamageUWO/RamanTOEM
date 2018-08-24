% COVMAT3D   Creation of 1D-3D covariance matrices
%
%   Converts specification data to a covariance matrix. The covariance is
%   described by the structure *D*. Correlation up to 3 dimensions are
%   handled. The dimensions are here denoted as 1, 2 and 3, in order to be
%   general. The physical meaning of these dimensions differ. For e.g. gas
%   species they correspond to pressure/altitude, latitude and longitude.  For
%   atmospheric data *dtype* shall be set to 'atm', which result in that
%   log10(p) is used as vertical coordinate (assumed to be dim 1). All pressure
%   grids are converted (including e.g. CL1_GRID1). A consequence is that
%   correlation lengths shall be given in pressure decades. For the Earth's
%   atmosphere one pressure decade is roughly 16 km.
%
%   The data are assumed to be stored with dimension 1 as innermost "loop",
%   dimension 2 next etc. For 3D case, the data order is as follows:
% 
%       [(x1,y1,z1) (x2,y1,z2) ...(xn,y1,z1) (x1,y2,z) ... (x1,y1,z2) ...]'
%
%   The main field of D is FORMAT, specifying the format used (only one
%   option implemented so far):
%
%      D.FORMAT = 'param' 
%      ---
%      The covariance matrix is here described following the format of 
%      *covmat3d_from_cfun*. The function *covmat3d_from_cfun* is also
%      used for handling most general 2D and 3D cases. For 1D, 
%      *covmat1d_from_cfun* is used. The D-format of *covmat3d_from_cfun*
%      is used strictly for these two cases.
%      It is further possible to add the field SEPERABLE to D. If this
%      field is true, the function *covmat_partstat_corr* is used.
%      Correlation lengths (D.CL1 etc.) are here throughout described as 
%      for 1D. Otherwise as above, such as scalar SI and CL1 are allowed.
%      A simple example:
%         D.FORMAT    = 'param'; 
%         D.SEPERABLE = 1;
%         D.CCO       = 0.01; 
%         D.CFUN1     = 'exp';
%         D.CL1       = 0.2;
%         D.CFUN2     = 'lin';
%         D.CL2       = 1;          
%   
% FORMAT   S = covmat3d(dim,D,grid1,grid2,grid3,dtype)
%              or
%          S = covmat3d(dim,D,G,dtype)
%
% OUT   S       Covariance matrix.
% IN    dim     Dimensionality.
%       D       Specification data.
%       grid1   Retrieval grid in dimension 1.
%       G       In this argument pattern, this argument shall be an
%               ArrayOfVectors, where first vector is used as grid1 etc.
%               Can hold more grids than needed considering *dim*.
% OPT   grid2   Retrieval grid in dimension 2. Not needed if *dim* < 2.
%       grid3   Retrieval grid in dimension 3. Not needed if *dim* < 3.
%       dtype   Type of data. Only specified options are [] and 'atm'. See
%               above for details. Default is [].

% 2006-08-21   Created by Patrick Eriksson.

function S = covmat3d(dim,D,grid1,grid2,grid3,dtype)
                                                                          %&%
                                                                          %&%
%--- Simple checks of input                                               %&%
%                                                                         %&%
rqre_nargin( 3, nargin );                                                 %&%
rqre_alltypes( dim, {@istensor0,@iswhole} );                              %&%
rqre_in_range( dim, 1, 3 );                                               %&%
rqre_datatype( D, @isstruct );                                            %&%
%
if iscell( grid1 )    %--- Argument pattern 2 --------------------
  if nargin > 3
    dtype = grid2;
    if nargin > 4                                                         %&%
      error('To many input arguments for argument pattern 2.');           %&%
    end                                                                   %&%
  else
    dtype = [];
  end
  G = grid1;
elseif isvector( grid1 )   %--- Argument pattern 1 ---------------
  rqre_nargin( 2+dim, nargin );                                           %&%
  rqre_datatype( grid1, @istensor1 );                                     %&%
  G{1} = grid1;
  if dim >= 2
    rqre_datatype( grid2, @istensor1 );                                   %&%
    G{2} = grid2;
    if dim == 3
      rqre_datatype( grid3, @istensor1 );                                 %&%
      G{3} = grid3;
    end
  end
  if nargin < 6
    dtype = [];
  end
else                                                                      %&%
  error('Unknown type of input argument 3.');                             %&%
end


%--- Unit conversions
%
if isempty(dtype)
  %
elseif strcmp(dtype,'atm')
  G{1} = log10(G{1});
  if isfield(D,'SI_GRID1'),  D.SI_GRID1  = log10(D.SI_GRID1);   end
  if isfield(D,'CL1_GRID1'), D.CL1_GRID1 = log10(D.CL1_GRID1);  end
  if isfield(D,'CL2_GRID1'), D.CL2_GRID1 = log10(D.CL2_GRID1);  end
  if isfield(D,'CL3_GRID1'), D.CL3_GRID1 = log10(D.CL3_GRID1);  end
else
  error(sprintf('Unknown option for *dtype* (%s).',dtype));
end



%--- Parameterised version ---------------------------------------------------
%
% Some extra flexibility is offered for 1D and SEPERABLE option. Both row and
% column vectors are allowed.
% 
if strcmp( D.FORMAT, 'param' )

  %- Check consistency inside D
  %
  for id = 1 : length(G)
    if ~isscalar(D.SI) & size(D.SI,id)~=length(D.(sprintf('SI_GRID%d',id)))
      error( sprintf( 'Inconsistency between D.SI and D.SI_GRID%d.', id ) );
    end
    if ~isfield( D, 'SEPERABLE' )  |  ~D.SEPERABLE
    if ~isscalar(D.CL1) & size(D.CL1,id)~=length(D.(sprintf('CL1_GRID%d',id)))
      error( sprintf( 'Inconsistency between D.CL1 and D.CL1_GRID%d.', id ) );
    end
    if length(G)>=2  &  ...
       ~isscalar(D.CL2) & size(D.CL2,id)~=length(D.(sprintf('CL2_GRID%d',id)))
      error( sprintf( 'Inconsistency between D.CL2 and D.CL2_GRID%d.', id ) );
    end          
    if length(G)>=3  &  ...
       ~isscalar(D.CL3) & size(D.CL3,id)~=length(D.(sprintf('CL3_GRID%d',id)))
      error( sprintf( 'Inconsistency between D.CL3 and D.CL3_GRID%d.', id ) );
    end          
    end
  end
  

  if dim == 1               % 1D is handled separately. 
    %  
    if isscalar( D.SI )  
      Std = D.SI;
    elseif isvector( D.SI )
      Std = [ vec2col(D.SI_GRID1) vec2col(D.SI) ];
    else
      error( 'Not allowed format for D.SI.' );
    end
    %
    if isscalar( D.CL1 )
      Cl = D.CL1;
    elseif isvector( D.CL1 )
      Cl = [ vec2col(D.CL1_GRID1) vec2col(D.CL1) ];
    else
      error( 'Not allowed format of D.CL1 for 1D.' );
    end
    %
    S = covmat1d_from_cfun( G{1}, Std, D.CFUN1, Cl, D.CCO );
    %
  else    % 2D and 3D
    %
    % Most general option:
    if ~( isfield( D, 'SEPERABLE' )  &  D.SEPERABLE )
      S = covmat3d_from_cfun( dim, D, G{1:dim} );
      %
    else % Seperable option:
      %
      if isscalar( D.CL1 )    % Correlation for dim 1
        Cl = D.CL1;
      elseif isvector( D.CL1 )
        Cl = [ vec2col(D.CL1_GRID1) vec2col(D.CL1) ];
      else
        error( 'Not allowed format of D.CL1 for 2D/3D and D.SEPERABLE.' );
      end
      C{1} = covmat1d_from_cfun( G{1}, [], D.CFUN1, Cl, D.CCO );
      %
      if isscalar( D.CL2 )    % Correlation for dim 2
        Cl = D.CL2;
      elseif isvector( D.CL2 )
        Cl = [ vec2col(D.CL2_GRID1) vec2col(D.CL2) ];
      else
        error( 'Not allowed format of D.CL2 for 2D/3D and D.SEPERABLE.' );
      end
      C{2} = covmat1d_from_cfun( G{2}, [], D.CFUN2, Cl, D.CCO );
      %
      if dim == 3             % Correlation for dim 3
        if isscalar( D.CL3 )
          Cl = D.CL3;
        elseif isvector( D.CL3 )
          Cl = [ vec2col(D.CL3_GRID1) vec2col(D.CL3) ];
        else
          error( 'Not allowed format of D.CL3 for 3D and D.SEPERABLE.' );
        end
        C{3} = covmat1d_from_cfun( G{3}, [], D.CFUN3, Cl, D.CCO );
      end
      %
      if isscalar( D.SI )     % Standard devaition
        si = D.SI;
      else
        x = repmat( vec2col(grid1), length(grid2), 1 );          
        y = repmat( vec2row(grid2), length(grid1), 1 );
        y = y(:);
        if dim == 2
          si = interpd( [x,y], D.SI, D.SI_GRID1, D.SI_GRID2, 'linear' );
        else
          if dim == 3
            x = repmat( x, length(grid3), 1 );
            y = repmat( y, length(grid3), 1 );
            z = repmat( vec2row(grid3), length(grid1)*length(grid2), 1 );
            z = z(:);
            si = interpd( [x,y,z], D.SI, D.SI_GRID1, D.SI_GRID2, ...
                                                  D.SI_GRID3, 'linear' );
          end
        end
      end
      %
      S  = covmat_partstat_corr( si, C{1:dim} );
    end
  end
  

%--- Unknown version
else
  error( sprintf( 'Unknown choice for D.FORMAT (%s).', D.FORMAT ) );
end