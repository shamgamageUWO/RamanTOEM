% ASG_ZEROPAD  Add zeros in ASG data so that the fields
%              are defined everywhere
%
%              zeros are added at the edges
%              (as example lat=-90 and lat=90)
%              and just outside the defined
%              region of the original G data,
%              where the grids will be defined
%              by values of DX.
%
% FORMAT   G = asg_zeropad( G, Q ,DX )
%        
% OUT   G   Extrapolated ASG data.
% IN    
%       G   ASG data.
%       Q   Qarts setting structure.
% Opt.  DX  vector. 
%           DX(1) corresponds pressure.
%           DX(2) to latitude.
%           DX(3) to longitude.
%           default is [1 0.01 0.01]
%           As example G.GRID1+DX(1) will
%           be a new grid point where the data
%           will be set to zeros.
%
% 2007-11-13   Created by Bengt Rydberg

function G=asg_zeropad(G,Q,varargin)
%
DX = optargs( varargin, { [1 0.01 0.01] } );


%- Basic checks of input
%
qcheck( @qarts, Q );
%
rqre_in_range( Q.ATMOSPHERE_DIM, 1, 3 );

%- New grids for p, lat and lon .
%
expandg = { [1.1e5 1e-9], [-90 90], [-180 180] };

for ig = 1 : length(G)

  %- Do nothing if DATA field is empty.
  %
  if isempty( G(ig).DATA )
    continue;
  end
  for i=1:G(ig).DIM
      gname = sprintf( 'GRID%d', i );
      grid=G(ig).(gname);
      gname=sprintf( 'GRID%d_NAME', i );
      if strcmp(lower(G(ig).(gname)),'pressure') 
	    grid_add=[grid(1)+DX(i) grid(end)-DX(i)];
      else
        grid_add=[grid(1)-DX(i) grid(end)+DX(i)];
      end    
      grid=sort([vec2col(grid)' grid_add expandg{i}])';
      if strcmp(G.(gname),'Pressure')
	    grid=flipud(grid);
      end
      gname = sprintf( 'GRID%d', i );
      G(ig).(gname)=grid;

      %add the zeros
      if isvector(G(ig).DATA)
	     G(ig).DATA=vec2col(G(ig).DATA);
      end
      data_size=size(G(ig).DATA);
      data_size(i)= data_size(i)+4;
      data=zeros(data_size);    
      %shift dimensions  
      data_dim=dimens(data);     
      old_data=shiftdim(G(ig).DATA,i-1);
      data=shiftdim(data,i-1);    
      data(3:end-2,:,:)=old_data;
      %shift back dimensions
      G(ig).DATA=shiftdim(data,data_dim-i+1);
      if isvector(G(ig).DATA)
	     G(ig).DATA=vec2col(G(ig).DATA);
      end
   end
end 
