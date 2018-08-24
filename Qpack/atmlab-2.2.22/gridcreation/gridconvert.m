% GRIDCONVERT   Conversion of grid unit
%
%    This function allows a change of grid unit. The conversion of a grid g
%    can be expressed as:
%
%       g = -(postcs==1) * mapfun( -(precs==1)*g )
%
%    To convert a pressure grid to increasing "pressure decades":
%       g = gridconvert( g, 0, @log10, 1 );
%    The reversed conversion is:
%       g = gridconvert( g, 1, @pow10 );
%
% FORMAT   g = gridconvert( g, precs, mapfun, postcs )
%        
% OUT   g        Transformed grid.
% IN    g        Original grid.
% OPT   precs    Change sign before applying *mapfun*. Defult is false.
%       mapfun   Mapping function. No mapping if empty, which is default.
%       postcs   Change sign after applying *mapfun*. Defult is false.

% 2007-10-17   Created by Patrick Eriksson.


function g = gridconvert( g, varargin )
%
[precs,mapfun,postcs] = optargs( varargin, { false, [], false } );
%                                                                          %&%
rqre_datatype( g, @istensor1 );                                            %&%
rqre_datatype( precs, @isboolean );                                        %&%
rqre_datatype( mapfun, {@isempty,@isfunction_handle} );                    %&%
rqre_datatype( postcs, @isboolean );                                       %&%


if precs
  g = -g;
end

if ~isempty( mapfun )
  g = feval( mapfun, g );
end

if postcs
  g = -g;
end
    


