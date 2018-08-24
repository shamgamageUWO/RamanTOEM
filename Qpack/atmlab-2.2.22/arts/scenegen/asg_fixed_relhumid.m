% ASG_FIXED_RELHUMID   Sets a fixed relative humidity
%
%    Water VMR profiles are set to the selected relative humidity inside
%    selected altitude range. This is done for all items of G where 
%    G.NAME starts with 'Water'.
%
%    The calculations are controled by the following fields
%       SPCFC.FIXED_RH    Boolean
%       SPCFC.RH          Relative humidity [-] (not %, a value around 1)
%       SPCFC.RH_BRAKEP   Brake point [Pa or m]
%       SPCFC.RH_TOPP     Top altitude [Pa or m]
%
%    Nothing is done if H2O.FIXED_RH is false. Otherwise:
%
%    The profiles are set to SPCFC.RH up to the altitude corresponding to
%    SPCFC.RH_BRAKEP. A linear transition to the original profile is 
%    performed between SPCFC.RH_BRAKEP and SPCFC.RH_TOPP.
%
%    Two options exist for SPCFC.RH_BRAKEP and SPCFC.RH_TOPP:
%       1. Given as pressure levels.
%       2. Distance to local tropopause
%    Option 1 is assumed if SPCFC.RH_TOPP <=  SPCFC.RH_BRAKEP, and vice versa.
%    Read header of *tropoapuse* before selecting option 2.
%
%    The relative humidity with respect to water is considered for 
%    temperatures above 0C, and the humidity with respect to ice for 
%    lower temperatures.
%
% FORMAT   G = asg_fixed_relhumid( D, G )
%        
% OUT   G   Modified ASG data.
% IN    D   Gformat definition structure.
%       G   ASG data.

% 2007-10-19   Created by Patrick Eriksson

function G = asg_fixed_relhumid( D, G )


%- Find temperature 
%
it = min( find( strncmp( lower({G.NAME}), 'temperature', 11 ) ) );
%
if isempty( it )
  error( 'Could not locate any temperature data in G.' );
end


%- Find water species
%
ih2o = find( strncmp( lower({G.NAME}), 'water', 5 ) );
%
if isempty( it )
  error( 'Could not locate any water vapour data in G.' );
end


iz = [];


for ig = ih2o
  
  rqre_field( G(ig).SPCFC, 'FIXED_RH', 0, 'G.SPCFC for water' );

  if ~G(ig).SPCFC.FIXED_RH
    continue       % ---->
  end
  
  rqre_field( G(ig).SPCFC, 'RH', 0, 'G.SPCFC' );
  rqre_in_range( G(ig).SPCFC.RH, 0, 2, 'G.SPCFC.RH',  );
  rqre_field( G(ig).SPCFC, 'RH_BRAKEP', 0, 'G.SPCFC' );
  rqre_field( G(ig).SPCFC, 'RH_TOPP', 0, 'G.SPCFC' );

  if G(ig).SPCFC.RH_TOPP >  G(ig).SPCFC.RH_BRAKEP
    do_z = 1;
  else
    do_z = 0;
  end

  %- Find altitude 
  %
  if do_z  &  isempty(iz)
    %
    iz = min( find( strncmp( lower({G.NAME}), 'altitude', 8 ) ) );
    %
    if isempty( iz )
      error( 'Could not locate any altitude data in G.' );
    end
    %
    if isempty( G(iz).DATA )
      error( 'Empty G.DATA for altitude field.' );
    end
  end
  
  
  for ic = 1:size(G(ig).DATA,4)
    
    %- Find matching temperature case (take last case if necessary)
    ic_t = size(G(it).DATA,4);
    %
    if ic <= ic_t
      ic_t = ic;  
    end

    %- Find matching temperature case (take last case if necessary)
    ic_z = size(G(iz).DATA,4);
    %
    if ic <= ic_z
      ic_z = ic;  
    end

    for ilon = 1:size(G(ig).DATA,3)
      for ilat = 1:size(G(ig).DATA,2)
          
        %- Find range of interest and obtain relavant data
        %
        if do_z
          z = interpp( G(iz).GRID1, G(iz).DATA(:,ilat,ilon,ic_z), G(ig).GRID1 );
          t = interpp( G(it).GRID1, G(it).DATA(:,ilat,ilon,ic_t), G(ig).GRID1 );
          z   = z - tropopause( z, t );
          ind = find( z <= G(ig).SPCFC.RH_TOPP ); 
          z   = z(ind);
          t   = t(ind);
        else
          ind = find( G(ig).GRID1 >= G(ig).SPCFC.RH_TOPP );
          t = interpp( G(it).GRID1, G(it).DATA(:,ilat,ilon,ic_t), ...
                                                            G(ig).GRID1(ind) );
        end
        %
        ei = e_eq_ice( t );
        ew = e_eq_water( t );
        
        %- Determine relative weight for ew
        %
        ww = t >= 273.15;
        
        %- VMR for selected relative humidity
        %
        vmr = G(ig).SPCFC.RH * ( ww.*ew + (1-ww).*ei ) ./ G(ig).GRID1(ind);
          
        %- Determine weight for vmr
        %
        if do_z
          ww = ( z - G(ig).SPCFC.RH_TOPP ) /...
                         ( G(ig).SPCFC.RH_BRAKEP - G(ig).SPCFC.RH_TOPP );
        else
          ww = ( log10(G(ig).GRID1(ind)) - log10(G(ig).SPCFC.RH_TOPP) ) /...
               ( -log10(G(ig).SPCFC.RH_TOPP) + log10(G(ig).SPCFC.RH_BRAKEP)  );
        end
        %
        ww(find(ww>1)) = 1;

        %- Create new profile
        %
        G(ig).DATA(ind,ilat,ilon,ic) = vec2col(ww.*vmr) + ...
	                vec2col((1-ww)).*G(ig).DATA(ind,ilat,ilon, ...
                                                          ic);
      end
    end
  end
end
