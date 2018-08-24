% GRID_FOR_1LINE   Grid for observation of a single transition
%
%    The function creates a grid that is suitable for observations of a single
%    transition, particularly for ground-based measurements. 
%
%    The grid covers [f0+df1,f0+df2]. The part [f0-1.5*FWHM,f0+1.5*FWHM] is
%    covered by a grid with equidistant spacing of df_fine. The ranges between
%    the centre part and grid edges are covered by a logarithmically spaced
%    grid. This grid is equidistant in log-space, where df_log gives the
%    spacing. For example, the default value of 0.1 signifies that the range
%    between 10 and 100 MHz is covered by 10 points.
%
% FORMAT   g = grid_for_1line(f0,fwhm,df1,df2[,df_fine,df_log])
%        
% OUT   g
% IN    f0        Line centre.
%       fwhm      FWHM for Doppler broadening (pr correspondingly)
%       df1       Starting point for grid, in distance from f0. E.g. -500e6
%                 for a grid starting 0.5 GHz below f0.
%       df2       End point for grid, in distance from f0. E.g. 500e6
%                 for a grid ending 0.5 GHz above f0.
% OPT   df_fine   Grid spacing for fine part around line centre. Default 
%                 is FWHM/5.
%       df_log    Spacing in logarithmic part. See above. Default is 0.1.

% 2009-11-09   Created by Patrick Eriksson.

function g = grid_for_1line(f0,fwhm,df1,df2,varargin)
%
[df_fine,df_log] = optargs( varargin, { fwhm/5, 0.1 } );

g1 = [ 0 : df_fine : 1.5*fwhm-df_fine/2 ];

l1 = log10( g1(end)+df_fine );
l2 = log10( max( abs( [ df1, df2 ] ) ) );

g2 = logspace( l1, l2, ceil((l2-l1)/df_log) );

g = f0 +symgrid( [ g1 g2 ] );

ind = find( g>=f0+df1 & g<=f0+df2 );

if ~isempty(ind)
  g = g(ind);
end