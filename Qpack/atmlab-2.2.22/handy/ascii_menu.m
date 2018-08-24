% ASCII_MENU   User selection by an ASCII menu.
%
%    Works as MENU, but always shows an ASCII menu and allows the definition
%    of a default answer.
%
%    The function ensures that the answer is valid. With a default option
%    an empty input selects the default value.
%
%    Command window example:
%    >> K = ASCII_MENU('Choose a color',2,'Red','Blue','Green')
%    displays on the screen:
%
%      ----- Choose a color -----
%
%         1) Red
%         2) Blue (default)
%         3) Green
%
%         Select a menu number:
%
%
% FORMAT   k = ascii_menu( xHeader, defNumber, varargin )
%
% OUT      k
% IN       xHeader     Header text for menu.
%          defNumber   Index for default value. [] means no default.
%          varargin    Menu items.

% HISTORY: 2003-03-07  Created by Patrick Eriksson

% The main part of the code is copied from an internal 
% sub-function of menu.m.


function k = ascii_menu( xHeader, defNumber, varargin )


if isempty( defNumber )
  default = 0;
else
  default = 1;
end



%-------------------------------------------------------------------------
% Calculate the number of items in the menu
%-------------------------------------------------------------------------
numItems = length(varargin);

%-------------------------------------------------------------------------
% Continuous loop to redisplay menu until the user makes a valid choice
%-------------------------------------------------------------------------
while 1,
    % Display the header
    disp(' ')
    disp(['----- ',xHeader,' -----'])
    disp(' ')
    % Display items in a numbered list
    for n = 1 : numItems
      if default  &  defNumber == n
        disp( [ '      ' int2str(n) ') ' varargin{n}, ' (default)'] )
      else
        disp( [ '      ' int2str(n) ') ' varargin{n} ] )
      end
    end
    disp(' ')
    % Prompt for user input
    k = input('Select a menu number: ');
    % Check input:
    % 1) make sure k has a value, or set to default
    if isempty(k)
      if default 
        k = defNumber;
      else
        k = -1; 
      end
    end;
    % 2) make sure the value of k is valid
    if  (k < 1) | (k > numItems) ...
        | ~strcmp(class(k),'double') | rem(k,1) ~= 0 ...
        | ~isreal(k) | (isnan(k)) | isinf(k),
        % Failed a key test. Ask question again
        disp(' ')
        disp('Invalid selection. Try again.')
    else
        % Passed all tests, exit loop and return k
        return
    end % if k...
end % while 1
