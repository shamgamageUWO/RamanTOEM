% ASGG   Returns an empty ASG structure
%
%    To create an empty structure:
%       G = asgG;
%
%    To obtain information of the fields of G:
%       qinfo( @asgG )
%
% FORMAT   [G,I] = asgG
%        
% OUT   G   An empty ASG structure.
%       I   Includes same fields as G, where the content of each field
%           is a description string (used by *qinfo*).

% 2007-10-19   Created by Patrick Eriksson

function [G,I] = asgG

%------------------------------------------------------------------------------
G.NAME = []; 
I.NAME = [
'Type ''help gformat'' for obtaining the definition of this field.'
];
%------------------------------------------------------------------------------
G.DIMS = []; 
I.DIMS = [
'Type ''help gformat'' for obtaining the definition of this field.'
];
%------------------------------------------------------------------------------
G.DATA = []; 
I.DATA = [
'Type ''help gformat'' for obtaining the definition of this field.',...
'Inside this ASG, this field can be initialized to a scalar for any ', ...
'variable having pressure as first dimension (such as atmospheric fields, ',...
'but not e.g. the geoid radius).'
];
%------------------------------------------------------------------------------
G.DATA_NAME = '-'; 
I.DATA_NAME = [
'Type ''help gformat'' for obtaining the definition of this field.'
];
%------------------------------------------------------------------------------
G.DATA_UNIT = '-'; 
I.DATA_UNIT = [
'Type ''help gformat'' for obtaining the definition of this field.'
];
%------------------------------------------------------------------------------
G.GRID1 = []; 
I.GRID1 = [
'Type ''help gformat'' for obtaining the definition of this field. ', ...
'And type ''qinfo(@asgD)'' for definition of data inside ASG.'
];
%------------------------------------------------------------------------------
G.GRID2 = []; 
I.GRID2 = [
'Type ''help gformat'' for obtaining the definition of this field.', ...
'And type ''qinfo(@asgD)'' for definition of data inside ASG.'
];
%------------------------------------------------------------------------------
G.GRID3 = []; 
I.GRID3 = [
'Type ''help gformat'' for obtaining the definition of this field.', ...
'And type ''qinfo(@asgD)'' for definition of data inside ASG.'
];
%------------------------------------------------------------------------------
G.GRID4 = []; 
I.GRID4 = [
'Type ''help gformat'' for obtaining the definition of this field.', ...
'And type ''qinfo(@asgD)'' for definition of data inside ASG.'
];
%------------------------------------------------------------------------------
G.SOURCE = 'Set by user'; 
I.SOURCE = [
'Type ''help gformat'' for obtaining the definition of this field.'
];
%------------------------------------------------------------------------------
G.PROPS = []; 
I.PROPS = [
'ASG field. Used to store description of basic proporties of the ',...
'quantities. The field is defined as follows:',...
'#   Absorption species : Absorption tag data, such as ',...
'{''H2O-*-495e9-510e9'',''H2O-MPM89''}',...
'#   Cloud particles : Name of file with single scattering data.'
];
%------------------------------------------------------------------------------
G.DIMADD        = [];
G.DIMADD.METHOD = 'expand'; 
I.DIMADD        = [
'ASG field. Describes how data are expanded to higher ',...
'dimensionality, or is interpolated or binned to lower dimension. ',...
'The field is a structure described in *asg_dimadd*.'
];
%------------------------------------------------------------------------------
G.RNDMZ = []; 
I.RNDMZ = [
'ASG field. Describes how data are "randomized". ',...
'The field is a structure described in *asg_rndmz*.'
];
%------------------------------------------------------------------------------
G.SPCFC = []; 
I.SPCFC = [
'ASG field. Describes quantity specific operations. Used by varoius',...
'functions, such as *asg_hydrostat*.'
];
%------------------------------------------------------------------------------
G.SURFACE = false; 
I.SURFACE = [
'ASG field. False for atmospheric fields. True for "surfaces", which ',...
'that the pressure dimensions not is used.'
];
%------------------------------------------------------------------------------
