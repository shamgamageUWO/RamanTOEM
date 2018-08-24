% YES_OR_NO   Prompts a question and only allows only 'y' or 'n' as answer.
%
%    The question string S shall only contain the question without any
%    ? character. If s='Do you like money', the prompted question is:
%
%          Do you like money [y,n]?:
%
% FORMAT   bool = answer_is_yes( s )
%
% OUT      bool   If anser is y, bool=1, else bool=0.
% IN       s      String with question.

% HISTORY: 2002-03-10  Created by Patrick Eriksson
%          2003-03-05  Copied from AMI to Atmlab by PE

function bool = yes_or_no( s )

response = 'w';

while length(response)~=1 | (response~='y' & response~='n')
  response = lower( input([s,' [y,n]?: '],'s') );
end

if response == 'y'
  bool = 1;
else
  bool = 0;
end


