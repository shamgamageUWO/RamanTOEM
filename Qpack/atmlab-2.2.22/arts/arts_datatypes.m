% ARTS_DATATYPES   Mapping between ARTS data types and container dimensionality
%
%    This function can be used to automatically determine the name or
%    dimensionality of an ARTS data type. Its main purpose is to determine
%    the variable group for when going up one step in dimensionality.
%
%    For example:
%       [oa,datagroup] = arts_datatypes('Vector');
%       arts_datatypes(oa+1,datagroup)
%    gives 
%       'Matrix'
%    and
%       [oa,datagroup] = arts_datatypes('ArrayOfString');
%       arts_datatypes(oa+1,datagroup)
%    gives 
%       'ArrayOfArrayOfString'
%
% FORMAT   [oa,datagroup] = arts_datatypes( artstype )
%        
% OUT   oa          Variable dimensionality. 0 returned for aray variables
%                   not part of 'num' and 'int' types.
%       datagroup   Type of data. Defined choices are:
%                      'num'  : Numeric, Vector, Matrix, Tensor3 ... Tensor7
%                      'int'  : Index, ArrayOfIndex
%                   *artstype* returned for all other array variables.
% IN    artstype    ARTS variable group
%
%   or
%
% FORMAT   [artstype] = arts_datatypes( oa, datagroup )
%        
% OUT   artstype    ARTS variable group
% IN    oa          As output argument above with same name.
%       datagroup   As output argument above with same name.

% 2005-05-26   Created by Patrick Eriksson.


function [oa,datagroup] = arts_datatypes( ia, datagroup )


numtypes = {
'Numeric' , ...
'Vector' , ...
'Matrix' , ...
'Tensor3' , ...
'Tensor4' , ...
'Tensor5' , ...
'Tensor6' , ...
'Tensor7'
};

inttypes = {
'Index', ...
'ArrayOfIndex'
};



if nargin == 1
  %
  i         = find( strcmp( numtypes, ia ) );
  datagroup = 'num';
  %
  if isempty(i)
    i         = find( strcmp( inttypes, ia ) );
    oa        = i - 1;
    datagroup = 'int';
  else
    oa = i - 1;
  end
  %
  if isempty(i)  & strncmp( ia, 'ArrayOf', 7 )
    i         = 1;
    oa        = 0; 
    datagroup = ia;
  end

  if isempty(i)
    error( sprintf('The type %s was not found.', ia ) );
  end


else
  %
  rqre_datatype( datagroup, @ischar );                               %&%
  %
  if strcmp( lower(datagroup), 'num' )
    % 
    oa  = numtypes{ia+1};

  elseif strcmp( lower(datagroup), 'int' )
    % 
    oa  = inttypes{ia+1};

  elseif strncmp( datagroup, 'ArrayOf', 7 )
    % 
    for i = 1:ia
      datagroup = sprintf( 'ArrayOf%s', datagroup );
    end
    %
    oa = datagroup;
    
  else
     error( sprintf('Unknown datagroup (%s)',datagroup) );
  end

end