% GF2GRIDDEDFIELD   CONVERTS A GFORMAT STRUCTURE INTO A GRIDDED FIELD
%
%    Converts data having the G format into data having the arts xml 
%    GriddedField format to use with e.g. xmlStore.
%
% FORMAT  [GF,type] = gf2griddedfield( G )
%        
% OUT   GF      GriddedField
%       type    String diescribing the type.
% IN    file    GFormat struckt

% 2011-02-08   Created by Ole Martin Christensen.

function [GF,type] = gf2griddedfield(G)

if atmlab('STRICT_ASSERT')
  rqre_nargin( 1, nargin );
  %
  if ~isgformat(G)
    error('Input data must be a GFormat structure');
  end
  if G.DIM < 1 || G.DIM > 4
    error('Input data must have atleast one and maximum four dimensions')
  end
end


GF.name  = G.NAME;
GF.data  = G.DATA;
GF.dataname = G.DATA_NAME;
for i = 1:G.DIM
    n= num2str(i);
    GF.grids{i} = eval(['G.GRID' n]);
    GF.gridnames{i} = eval(['G.GRID' n '_NAME']);
end
type = ['GriddedField', num2str(G.DIM)];


