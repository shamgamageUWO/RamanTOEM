% ASG_HYDROSTAT   Calculates hydrostatic equilibrium for ASG data
%
%    The function demands that *G* contains temperature and water vapour
%    data. These quantities are found by searching for the names 'Temperature'
%    and 'Water vapour', respectively. If several items exist, the first one is
%    used. The number of cases created will match the maximum number of cases
%    among the involved variables (altitude, temperature and water vapour).
%
%    The G array must further contain an item for altitudes. The field NAME
%    is expected to start as 'Altitude'. This is item of G can be empty,
%    beside the field SPCFC, where settings for this functions is stored,
%    as described below.
%
%    Hydrostatic equilibrium is calculated for each geographical position
%    individually. The reference point (see *pt2z*) is taken from
%    G.SPCFC. The same pressure of the reference point is applied for all
%    positions, and is taken from G.SPCFC.P0 (should be a scalar). The
%    altitude of the reference point is described by G.SPCFC.Z0, which is
%    expected to be a surface described in gformat. The input can here be
%    for lower data dimension. For example, a constant altitude can be set
%    as:
%       G(i).SPCFC.Z0        = gf_set( D, asgG, [], 0, [], ...
%                                     'Altitude at P0', 'Altitude', 'm' );
%
% FORMAT   G = asg_hydrostat( G, Q )
%        
% OUT   G   Expanded gformat array, appended with an item holding
%           altitudes. Name set to 'Altitude'.
% IN   
%       G   Data (in gformat).
%       Q   Qarts setting structure.

% 2007-10-09   Created by Patrick Eriksson

function G = asg_hydrostat( G, Q )


%- Locate position of 'Altitude field'
%
% Take first index if several found
%
iz = min( find( strncmp( lower({G.NAME}), 'altitude', 8 ) ) );
%
if isempty( iz )
  error( 'Could not locate any altitude data in G.' );
end
%
%rqre_field( G(iz).SPCFC, 'P0', false, 'G.SPCFC' );
%rqre_field( G(iz).SPCFC, 'Z0', false, 'G.SPCFC' );
%qcheck( @asgG, G(iz).SPCFC.Z0 );


%- Locate also position of temperature and water vapour
%
it = min( find( strncmp( lower({G(:).NAME}), 'temperature', 11 ) ) );
if isempty( it )
  error( 'Could not locate temperature in G.' );
end
%
iw = min( find( strcmp( lower({G(:).NAME}), 'h2o' ) ) );
if isempty( iw )
  error( 'Could not locate water vapour in G.' );
end


%- Set string fields
%
G(iz).NAME      = 'Altitude field';
G(iz).SOURCE    = 'asg_hydrostat';
G(iz).DATA_NAME = 'Altitude';
G(iz).DATA_UNIT = 'm';


%- Latitudes
%
if G(it).DIM>=2
  lats = G(it).GRID2;
else
  lats = 45;
end


%- Re-grid SPCFC.ZO
%
Z0 = asg_dimadd( G(iz).SPCFC.Z0, Q );
Z0 = asg_regrid( Z0, Q );


%- Run HSE
%
G(iz).DIM = G(it).DIM;
%
G(iz).GRID1 = G(it).GRID1; 
G(iz).GRID2 = G(it).GRID2; 
G(iz).GRID3 = G(it).GRID3; 
%
nc = max( [ size(G(it).DATA,4), size(G(it).DATA,4), size(G(iw).DATA,4) ] );
%
if nc > 1
  if G(iz).DIMS(end) ~= 4
    G(iz).DIMS(end+1) = 4;
  end
  G(iz).GRID4       = 1:nc; 
end
%
G(iz).DATA = zeros( size(G(it).DATA,1), size(G(it).DATA,2), ...
                    size(G(it).DATA,3), nc );
%
for ic = 1 : nc
  
  %- Find matching temperature case (take last case if necessary)
  ic_t = size(G(it).DATA,4);
  %
  if ic <= ic_t
    ic_t = ic;  
  end

  %- Find matching water vapour case (take last case if necessary)
  ic_w = size(G(iw).DATA,4);
  %
  if ic <= ic_w
    ic_w = ic;  
  end
  for ilon = 1 : size(G(it).DATA,3)
    for ilat = 1 : size(G(it).DATA,2)

      G(iz).DATA(:,ilat,ilon,ic) = pt2z( G(it).GRID1, ...
                                         G(it).DATA(:,ilat,ilon,ic_t), ...
                                         G(iw).DATA(:,ilat,ilon,ic_w), ...
                                         G(iz).SPCFC.P0, ...
                                         Z0.DATA(1,ilat,ilon), ...
                                         lats(ilat) );
      end
  end
end


