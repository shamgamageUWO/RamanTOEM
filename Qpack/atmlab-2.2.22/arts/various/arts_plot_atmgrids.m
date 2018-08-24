% ARTS_PLOT_ATMGRIDS   Makes figure for 1D-3D with atmospheric grids.
%
%     The function produces figures to visualize the atmsopheric grids,
%     the geoid, the ground, the cloud box and the atmospheric fields.
%
%     The variables work as their ARTS counterparts. The exception is for
%     1D where *lat_grid* shall contain two values, which determines how
%     long (in latitude) the plotted atmosphere shall be extended.
%
%     Examples on how to use this function is found in ARTS, at
%     doc/uguide/Figs/fm_definitions/mkfigs_atm_dims.m
%
% FORMAT   [h,hs] = arts_plot_atmgrids(dim,lat_grid,lon_grid,z_field,
%                                       r_geoid,[z_ground,cb_lims,mark_fields])
%        
% OUT   h         Handles to plot symbols.
%       hs        Text suitable to put in legend.
% IN    dim       Atmospheric dimension (1-3).
%       lat_grid  As the WSV with the same name, except for 1D. See above.
%       lon_grid  As the WSV with the same name.
%       z_field   As the WSV with the same name.
%       r_geoid   As the WSV with the same name.
% OPT   z_ground  As the WSV with the same name. If the variable is empty,
%                 which is default, the geoid and the ground are not plotted.
%       cb_lims   As the WSV cloudbox_limits. The cloud box is turned off
%                 with cb_lims=[], which is also default.
%       mark_fields  Flag to indicate atmospheric fields with black dot at
%                 crossings of grids. Default is 0.

% 2003-03-04   Created by Patrick Eriksson.

function [h,hs] = arts_plot_atmgrids(dim,lat_grid,lon_grid,z_field,...
                                          r_geoid,z_ground,cb_lims,mark_fields)

%= Check input                                                   %&%
%                                                                %&%
rqre_nargin(5,nargin);                                           %&%
%                                                                %&%
if ~isscalar( dim )  |  dim < 1  |  dim > 3                      %&%
  error( ['The atmospheric dimensionality must be a ',...        %&%
                                  'scalar between 1 and 3.' ] ); %&%
end                                                              %&%
%                                                                %&%
if dim == 1  & ( ~isvector( lat_grid )   |  ...                  %&%
                                       length( lat_grid ) ~= 2 ) %&%
  error('For 1D, *lat_gid* must be a vector of length 2.');      %&%
end                                                              %&%
                                                                 %&%


if nargin < 6
  z_ground = [];
end
%
if nargin < 7
  cb_lims = [];
end
%
if nargin < 8
  mark_fields = 0;
end



%= Check if plot is hold
%
figure(gcf);
figstat = ishold;
%
if ~ishold
  clf
end


%= Plotting symbols
%
ps_grids     = 'k:';
ps_ground{1} = 'r-';
ps_ground{2} = 'LineWidth';
ps_ground{3} = 2;
ps_geoid     = 'b-.';
ps_cloudb    = 0.7*ones(1,3);
ps_field     = 'k.';
%
hs{1} = 'Atmospheric grids';
hs{2} = 'Ground';
hs{3} = 'Geoid';
if ~isempty( cb_lims )
  hs{4} = 'Cloud box';
  do_cb = 1;
else
  do_cb = 0;
end
if mark_fields
  hs{4+do_cb} = 'Atmospheric field';
end


nz = size(z_field,1);


switch dim

  %- 1D
  case 1
    %
    if ~isempty( cb_lims )
      [x1,y1] = surf_segment2D( lat_grid, ... 
                                        [r_geoid(1)+z_field(cb_lims{1}+1), ...
                                         r_geoid(1)+z_field(cb_lims{1}+1) ] );
      [x2,y2] = surf_segment2D( lat_grid, ...
                                        [r_geoid(1)+z_field(cb_lims{2}+1), ...
                                         r_geoid(1)+z_field(cb_lims{2}+1) ] );
      h(4) = patch( [x1 fliplr(x2)], [y1 fliplr(y2)], ps_cloudb);
      set( h(4), 'EdgeColor', ps_cloudb );
      hold on
    end
    %
    for j = 1 : nz
      [x,y] = surf_segment2D( lat_grid, ...
                            [ r_geoid(1)+z_field(j), r_geoid(1)+z_field(j) ] );
      h(1) = plot( x, y, ps_grids );
      hold on
      %
      if mark_fields
        i0 = round( length(x)/2 );
        h(4+do_cb) = plot( x(i0), y(i0), ps_field );
      end

    end
    %
    if ~isempty( z_ground )
      [x,y] = surf_segment2D( lat_grid, ...
                          [ r_geoid(1)+z_ground(1), r_geoid(1)+z_ground(1) ] );
      h(2) = plot( x, y, ps_ground{:} );
      %
      [x,y] = surf_segment2D( lat_grid, [ r_geoid(1), r_geoid(1) ] );
      h(3) = plot( x, y, ps_geoid );
    end

  %- 2D
  case 2
    %
    if ~isempty( cb_lims )
      ind     = (cb_lims{3}+1):(cb_lims{4}+1);
      [x1,y1] = surf_segment2D( lat_grid(ind), ...
                                     r_geoid(ind)+z_field(cb_lims{1}+1,ind)' );
      [x2,y2] = surf_segment2D( lat_grid(ind), ...
                                     r_geoid(ind)+z_field(cb_lims{2}+1,ind)' );
      h(4) = patch( [x1 fliplr(x2)], [y1 fliplr(y2)], ps_cloudb );
      set( h(4), 'EdgeColor', ps_cloudb );
      hold on
    end
    %
    for j = 1 : nz
      [x,y] = surf_segment2D( lat_grid, r_geoid+z_field(j,:)' );
      h(1) = plot( x, y, ps_grids );
      hold on
    end
    %
    for j = 1 : length( lat_grid )
      [x,y] = atmplot_pol2cart( [ r_geoid(j)+z_field(1,j), ...
                           r_geoid(j)+z_field(nz,j) ], lat_grid(j)*ones(1,2) );
      plot( x, y, ps_grids );
      %
      if mark_fields
        for k = 1 : nz
          [x,y] = atmplot_pol2cart( r_geoid(j)+z_field(k,j), lat_grid(j) );
          h(4+do_cb) = plot( x, y, ps_field );
        end
      end
    end
    %
    if ~isempty( z_ground )
      [x,y] = surf_segment2D( lat_grid, r_geoid+z_ground );
      h(2) = plot( x, y, ps_ground{:} );
      %
      [x,y] = surf_segment2D( lat_grid, r_geoid );
      h(3) = plot( x, y, ps_geoid );
    end

  %- 3D
  case 3
    %
    for j = 1 : length( lat_grid )
      for k = 1 : length( lon_grid )
        [x,y,z] = atmplot_sph2cart( [ r_geoid(j,k)+z_field(1,j,k), ...
                                r_geoid(j,k)+z_field(nz,j,k) ], ...
			        lat_grid(j)*ones(1,2), lon_grid(k)*ones(1,2) );
      	h(1) = plot3( z, x, y, ps_grids );
        hold on
      	%
      	if mark_fields
      	  for l = 1 : nz
      	    [x,y,z] = atmplot_sph2cart( r_geoid(j,k)+z_field(l,j,k), ...
                                                    lat_grid(j), lon_grid(k) );
      	    h(4+do_cb) = plot3( z, x, y, ps_field );
      	  end
      	end
      end
    end
    %
    for j = 1 : length( lat_grid )
      if ~isempty( z_ground )
        [x,y,z] = surf_segment3D( lat_grid(j), lon_grid, ...
                                               r_geoid(j,:)+z_ground(j,:,:) );
        h(2) = plot3( z, x, y, ps_ground{:} );
        %
        [x,y,z] = surf_segment3D( lat_grid(j), lon_grid, r_geoid(j,:) );
        h(3) = plot3( z, x, y, ps_geoid );
      end
      %
      for k = 1 : nz
        [x,y,z] = surf_segment3D( lat_grid(j), lon_grid, ...
                                      r_geoid(j,:)+squeeze(z_field(k,j,:))' );
        plot3( z, x, y, ps_grids );
      end
    end
    %
    for j = 1 : length( lon_grid )
      if ~isempty( z_ground )

        [x,y,z] = surf_segment3D( lat_grid, lon_grid(j), ...
                                                  r_geoid(:,j)+z_ground(:,j) );
        plot3( z, x, y, ps_ground{:} );
        %
        [x,y,z] = surf_segment3D( lat_grid, lon_grid(j), r_geoid(:,j) );
        plot3( z, x, y, ps_geoid );
      end
      %
      for k = 1 : nz
        [x,y,z] = surf_segment3D( lat_grid, lon_grid(j), ...
                                       r_geoid(:,j)+squeeze(z_field(k,:,j))' );
        plot3( z, x, y, ps_grids );
      end
    end
    %
    set( gca, 'Ydir', 'rev' );
    view([37 30]);

end


%= Set equal axis
%
axis equal


%= Set hold off if this was status at the start
%
if ~figstat
  hold off
end



function [x,y] = surf_segment2D(lat,r)

  % Nominal latitude step length
  nom_dlat = 0.2;

  x = [];
  y = [];

  for j = 2 : length( lat )

    lat1 = lat(j-1);
    lat3 = lat(j);

    lats = linspace( lat1, lat3, max([ 2, ceil( (lat3-lat1) / nom_dlat ) ] ) );

    slope = ( r(j) - r(j-1) ) / ( lat3 - lat1 );

    rs    = r(j-1) + slope * ( lats - lat1 );
      
    [xv,yv] = atmplot_pol2cart( rs, lats );

    x = [ x xv ];
    y = [ y yv ];

  end
return



function [x,y,z] = surf_segment3D(lat,lon,r)

  % Nominal latitude step length
  nom_dang = 0.5;

  x = [];
  y = [];
  z = [];

  if length(lon) == 1
    for j = 2 : length( lat )
      lat1 = lat(j-1);
      lat3 = lat(j);
      lats = linspace( lat1, lat3, max([ 2, ceil( (lat3-lat1) / nom_dang ) ]));
      slope = ( r(j) - r(j-1) ) / ( lat3 - lat1 );
      rs    = r(j-1) + slope * ( lats - lat1 );
      [xv,yv,zv] = atmplot_sph2cart( rs, lats, lon );
      x = [ x xv ];
      y = [ y yv ];
      z = [ z zv ];
    end
  else
    for j = 2 : length( lon )
      lon1 = lon(j-1);
      lon3 = lon(j);
      lons = linspace( lon1, lon3, max([ 2, ceil( (lon3-lon1) / nom_dang ) ]));
      slope = ( r(j) - r(j-1) ) / ( lon3 - lon1 );
      rs    = r(j-1) + slope * ( lons - lon1 );
      [xv,yv,zv] = atmplot_sph2cart( rs, lat, lons );
      x = [ x xv ];
      y = [ y yv ];
      z = [ z zv ];
    end
  end
return