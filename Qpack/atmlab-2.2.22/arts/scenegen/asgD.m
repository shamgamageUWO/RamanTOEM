% ASGD   Definition of the gformat as applied for the arts scnene generator
%
%    To create a definition structure:
%       D = asgD;
%
%    To obtain information of the fields of D:
%       qinfo( @asgD )
%
% FORMAT   [D,I] = asgD
%        
% OUT   D   Gformat definition structure.
%       I   Includes same fields as D, where the content of each field
%           is a description string (used by *qinfo*).

% 2007-10-19   Created by Patrick Eriksson


function [D,I] = asgD
  
%------------------------------------------------------------------------------
D.DIM = 4;
I.DIM = [ ...
'Type ''help gformat'' for obtaining the definition of this field.',...
'The arts scene generator (ASG) operates with 4 dimensions: ',...
'#   1. Pressure',...
'#   2. Latitude',...
'#   3. Longitude',...
'#   4. Case',...
'The last dimension can be used to store multiple realisations of the ',...
'same quantity (to be used in e.g. batch calculations). It is allowed ',...
'that the number of cases differs inside G. The last case is then used ',...
'to match data from other G items having more cases.'
];
%------------------------------------------------------------------------------
D.GRID1_NAME = 'Pressure';
I.GRID1_NAME = [ ...
'Type ''help gformat'' for obtaining the definition of this field.',...
'#   Dimension 1 is for ASG defined to be pressure.'
];
%------------------------------------------------------------------------------
D.GRID1_UNIT = 'Pa';
I.GRID1_UNIT = [ ...
'Type ''help gformat'' for obtaining the definition of this field.',
];
%------------------------------------------------------------------------------
D.GRID2_NAME = 'Latitude';
I.GRID2_NAME = [ ...
'Type ''help gformat'' for obtaining the definition of this field.',...
'#   Dimension 2 is for ASG defined to be latitude.'
];
%------------------------------------------------------------------------------
D.GRID2_UNIT = 'deg';
I.GRID2_UNIT = [ ...
'Type ''help gformat'' for obtaining the definition of this field.',
];
%------------------------------------------------------------------------------
D.GRID3_NAME = 'Longitude';
I.GRID3_NAME = [ ...
'Type ''help gformat'' for obtaining the definition of this field.',...
'#   Dimension 3 is for ASG defined to be longitude.'
];
%------------------------------------------------------------------------------
D.GRID3_UNIT = 'deg';
I.GRID3_UNIT = [ ...
'Type ''help gformat'' for obtaining the definition of this field.',
];
%------------------------------------------------------------------------------
D.GRID4_NAME = 'Case';
I.GRID4_NAME = [ ...
'Type ''help gformat'' for obtaining the definition of this field.',...
'#   Dimension 4 is for ASG defined to be "case".'
];
%------------------------------------------------------------------------------
D.GRID4_UNIT = '-';
I.GRID4_UNIT = [ ...
'Type ''help gformat'' for obtaining the definition of this field.',
];
%------------------------------------------------------------------------------
