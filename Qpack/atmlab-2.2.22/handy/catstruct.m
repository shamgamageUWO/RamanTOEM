function A = catstruct(varargin)
% CATSTRUCT - concatenate structures
%
%   X = CATSTRUCT(S1,S2,S3,...) concates the structures S1, S2, ... into one
%   structure X. 
%
%   Example:
%     A.name = 'Me' ; 
%     B.income = 99999 ; 
%     X = catstruct(A,B) 
%     % -> X.name = 'Me' ;
%     %    X.income = 99999 ;
%
%   CATSTRUCT(S1,S2,'sorted') will sort the fieldnames alphabetically.
%
%   If a fieldname occurs more than once in the argument list, only the last
%   occurence is used, and the fields are alphabetically sorted.
%
%   To sort the fieldnames of a structure A use:
%     A = CATSTRUCT(A,'sorted') ;
%
%   To concatenate two similar array of structs use simple concatenation:
%     A = dir('*.mat') ; B = dir('*.m') ; C = [A ; B] ;
%
%   When there is nothing to concatenate, the result will be an empty
%   struct (0x0 struct array with no fields). 
%
%   See also CAT, STRUCT, FIELDNAMES, STRUCT2CELL

% for Matlab R13 and up
% version 2.2 (oct 2008)
% (c) Jos van der Geest
% email: jos@jasen.nl
% Copyright (c) 2009, Jos van der Geest
% All rights reserved.

% History
% Created:  2005
% Revisions
%   2.0 (sep 2007) removed bug when dealing with fields containing cell
%                  arrays (Thanks to Rene Willemink) 
%   2.1 (sep 2008) added warning and error identifiers
%   2.2 (oct 2008) fixed error when dealing with empty structs (Thanks to
%                  Lars Barring)
% Modified by Salomon Eliassson. 2011
%       additions: Works recursively
%                  Allows empty arguments in varargin
% $Id: catstruct.m 8495 2013-06-18 08:20:05Z seliasson $

N = nargin ;

narginchk(1,Inf) ;

if ~isstruct(varargin{end}),
    if isequal(varargin{end},'sorted'),
        sorted = 1 ;
        N = N-1 ;
        if N < 1,
            A = struct([]) ;
            return
        end
    else
        error(['atmlab:' mfilename, ':badInput'],...
            'Last argument should be a structure, or the string "sorted".') ;
    end
else
    sorted = 0 ;
end

FN = cell(N,1) ;
VAL = cell(N,1) ;

for ii=1:N,
    X = varargin{ii} ;
    if ~isempty(X) % Added by Salomon (allow empty arguments)
        if ~isstruct(X),
            error('catstruct:InvalidArgument',...
                ['Argument #' num2str(ii) ' is not a structure.']) ;
        end
        % empty structs are ignored
        FN{ii} = fieldnames(X) ;
        VAL{ii} = struct2cell(X) ;
    end
end

% Added by Salomon --
FN = FN(~cellfun('isempty',FN));
VAL = VAL(~cellfun('isempty',VAL));

[FN,VAL] = recursive_catstruct(FN,VAL);
% --

FN = cat(1,FN{:}) ;
VAL = cat(1,VAL{:}) ;
[UFN,ind] = unique(FN) ;

if numel(UFN) ~= numel(FN),
    warning('catstruct:DuplicatesFound',...
        'Duplicate fieldnames found. Last value is used and fields are sorted') ;
    sorted = 1 ;
end

if sorted,
    VAL = VAL(ind) ;
    FN = FN(ind) ;
end

if ~isempty(FN),
    % This deals correctly with cell arrays
    A = cell2struct(VAL, FN, 1);
else
    A = struct([]) ;
end

%%%%%%%%%%%%%%%
% SUBFUNCTIONS
% 
function [FN,VAL] = recursive_catstruct(FN,VAL)
%% recursive_catstruct

% Look for structures in structure...
a = cell(size(FN,1),1);
for i =1:size(FN,1)
    % find which structures contain structures
    a{i}= FN{i}(cellfun(@isstruct,VAL{i}));
end

if all(cellfun('isempty',a))
    return
end

% get the unique structure names
F = unique(cat(1,a{:}));

for f = F'
    % find the lower level structure in the the other structures
    structs_index = cell2mat(cellfun(@(X)any(ismember(X,f)),a,'uniformoutput',0));
    
    if sum(structs_index)==1 % don't need to do more
        continue
    end 
    
    %logtext(atmlab('OUT'), 'Stucture element: ''%s'' will be dealt with recursively\n',f{1})
    % If this low level structure appears in more than 1 main level structure,
    % do another catstruct
    
    fnd = 1:length(structs_index);
    vargin = cell(sum(structs_index),1);
    for loop = fnd(structs_index)
        vargin{loop} = VAL{loop}{ismember(FN{loop},f)}; % this is the low level struct
    end
    merged_lowstruct.(f{1}) = catstruct(vargin{:});
end
if ~exist('merged_lowstruct','var'), return, end % nothing was done

% Just make a extra structure knowing that this will be appended last and will
% overwrite the others with the conflicting fields structure elements that are
% also structures
lowlvlF = fieldnames(merged_lowstruct);
for lF = lowlvlF'
    FN{end+1} = lF{1}; %#ok<AGROW>
    VAL{end+1} = merged_lowstruct.(lF{1}); %#ok<AGROW>
end
