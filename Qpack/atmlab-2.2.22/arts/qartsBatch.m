% QARTSBATCH   Defines setting fields for ARTS batch calculations
%
%    The function provides default values for all recognised fields and a
%    description of each field. To list default values just type 'qartsBatch'.
%
%    This function is organised in such way that *qcheck* and *qinfo*
%    can be used.
%
% FORMAT   [B,I] = qartsBatch
%        
% OUT   B  Setting structure with default values for all recognised fields.
%       I  Includes same fields as B, where the content of each field
%          is a description string (used by *qinfo*).

% 2005-05-26   Created by Patrick Eriksson.


function [B,I] = qartsBatch
 

%-----------------------------------------------------------------------------
B.DATA = {};
I.DATA = [ ...
'Batch data. This field is a cell array where each element shall have the ',...
'the fields:', ...
'#   WSV  : The ARTS WSV to which the data shall be transfered.', ...
'#   TYPE : The ARTS data type of the WSV.', ...
'#   X    : The actual batch data. This variable shall accordingly be of ', ...
'one dimension higher than the WSV type. ', ...
'# For example, if *sensor_los* shall be modified, then you do something ', ...
'like:', ...
'#   Q.BATCH.DATA{1}.WSV  = ''sensor_los'';', ...
'#   Q.BATCH.DATA{1}.TYPE = ''Matrix'';', ...
'#   Q.BATCH.DATA{1}.X    = 113.3+randn(5,1,1)*0.05;'
];
%-----------------------------------------------------------------------------
B.N = {};
I.N = [ ...
'Number of batch cases to run.'
];
%-----------------------------------------------------------------------------
B.WSM = {};
I.WSM = [ ...
'Series of WSM calls to finish *ybatch_calc_agenda*.'
];
%-----------------------------------------------------------------------------

