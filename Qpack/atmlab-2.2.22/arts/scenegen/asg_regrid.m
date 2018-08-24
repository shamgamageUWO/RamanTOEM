% ASG_REGRID   Re-gridding of ASG data.
%
%    The data are re-gridded to match Q.P_GRID, Q.LAT_GRID and Q.LON_GRID. 
%    These grids must be set before calling this function (that is, scalar
%    input is not allowed as for *asg_atmgrids*).
%
%    Interpolation in pressure is performed after conversion to pressure
%    decades. Nothing is done if the DATA field is empty. 
%
% FORMAT   G = asg_regrid( G, Q )
%        
% OUT   G   Re-gridded ASG data.
% IN    
%       G   gformat data data.
%       Q   Qarts setting structure.

% 2007-10-08   Created by Patrick Eriksson


function G = asg_regrid( G, Q )


%- Basic checks
%
% D and G are partially checked inside gf functions.
% Full check of D, G and Q is only made in *asg_chdim* for efficiency reasons.


%- Create array with new grids. 
%
grids = [ {vec2col(Q.P_GRID)} {vec2col(Q.LAT_GRID)} {vec2col(Q.LON_GRID)} ];


%- Switch to pressure decades
%
grids{1} = gridconvert( grids{1}, false, @log10, true );

 for ig = 1 : length(G)

  %- Do nothing if DATA or DIMS field is empty.
  
  if ~isempty( G(ig).DATA )  &  ~isempty( G(ig).DIM ) 
  
    dim = G(ig).DIM;
    %change G.GRID1 to pressure decade
    if strcmp(lower(G(ig).GRID1_NAME),'pressure')
       grid1=gridconvert( vec2col(G(ig).GRID1), false, @log10, true );
       G(ig).GRID1=grid1;
    
    
     if dim==3
       G(ig).GRID1=vec2col(G(ig).GRID1);
       G(ig).GRID2=vec2col(G(ig).GRID2);
       G(ig).GRID3=vec2col(G(ig).GRID3);
       G(ig)= gf_regrid(G(ig), grids );
       
     elseif dim==2
       G(ig).GRID1=vec2col(G(ig).GRID1);
       G(ig).GRID2=vec2col(G(ig).GRID2);
       G(ig)= gf_regrid(G(ig), [{grids{1}} {grids{2}}] );
     
     else
       G(ig).GRID1=vec2col(G(ig).GRID1);
       G(ig)= gf_regrid(G(ig), [{grids{1}}] );

     end
      %switch back from pressure decades
       grid1=gridconvert( vec2col(G(ig).GRID1), true, @pow10);
       G(ig).GRID1=grid1;
     
    end
    %try
    %  G(ig) = gf_regrid( G(ig), { grids });
    %catch
    %  fprintf( '%s\n\n', lasterr );
    %  error( sprintf('Message above applies to G(%d).',ig) );
    %end
    
  end
  
end

  
%- Back to Pa
%
%G        = gf_grid_convert( D, G, 1, 1, @pow10 );

