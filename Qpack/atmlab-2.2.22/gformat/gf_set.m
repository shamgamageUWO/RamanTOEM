% GF_SET   Direct setting of gformat data
%
%    To set a new G to a scalar and set some of the gformat fields:
%      G = gf_set( [], 1e3, [], [], [], 'SOURCE', 'Set manually', 'NAME', 'X' );
%
% FORMAT   G = gf_set(G,data,grids,grid_names,grid_units,field1,string1,...)
%        
% OUT   G              Modified gformat structure.
% IN    G              Original gformat structure.
% IN    data           Data to be inserted.
%       grids          Grids corresponding to data, given as an array of 
%                      vectors.
% OPT   grid_names     Empty (default) or an array of strings with name of 
%                      each grid.
%       grid_units     Empty (default) or an array of strings with unit of 
%                      each grid.
%       field/string   Combinations of field names and strings.      

% 2007-10-17   Created by Patrick Eriksson.

function G = gf_set(G,data,grids,grid_names,grid_units,varargin)
%
if nargin < 4, grid_names = []; end
if nargin < 5, grid_units = []; end


%- Check input                                                             %&%
%                                                                          %&%
rqre_nargin( 1, nargin );                                                  %&%
rqre_datatype( data, @isnumeric );                                         %&%
rqre_datatype( grids, {@isempty,@iscell} );                                %&%
rqre_datatype( grid_names, {@isempty,@iscellstr} );                        %&%
rqre_datatype( grid_units, {@isempty,@iscellstr} );                        %&%
if isodd( length( varargin ) )                                             %&%
  error( ['The number of input arguments after *grid_units* ',...          %&%
                                    'must be an even number.'] );          %&%
end                                                                        %&%

G = gf_set_data( G, data,grids,grid_names );

if ~isempty( varargin )
  G = gf_set_fields( G, varargin{:} );
end