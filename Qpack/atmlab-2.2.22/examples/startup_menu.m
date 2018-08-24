% STARTUP_MENU   Menu to start different environments at startup.
%
%    This is an example how it is possible to select different configurations
%    of Matlab in a rather simple way. The function shows also example on
%    how some default settings of Matlab can be changed. The function is
%    neither perfect or complete. Copy it if you like it and make the
%    modifications you want.
%
%    If you always want to run this function at startup, there are two
%    options:
%      1. Rename this function to startup.m and make sure it is found
%         by Matlab at startup.
%      2. Call this function from your existing startup.m.
%
%    If you want to change the environment during a Matlab session, give
%    the environment number as input and execute this function (if it is
%    still in the search path).
%
% FORMAT   startup_menu( [choice] )
%        
% OPT   choice  If given, no menu is displayed and the input argument is
%               taken as the choice from the menu. No type and ragne checks
%               are performed, and an invalid choice will give a crash without
%               proper error message.

% 2002-12-19   Created by Patrick Eriksson.

function startup_menu( choice )


%=== Clean the path
%
path(pathdef);


if nargin == 0

  choice = local_ASCIImenu( 'What to run?', { ...
                 'Pure Matlab',                 ...       % 1
                 'Only default settings',       ...       % 2 
                 'WWW',                         ...       % 3
                 'Qpack',                       ...       % 4
                 'Qsmr',                        ...       % 5
                 'Atmlab',                      ...       % 6
                 'Qoso'                     } );          % 7 

end


switch choice

  case 1
    package = 'pure Matlab';   
    cd /home/patrick

  case 2
    package = 'only default settings';   
    startup_general_defs;
    cd /home/patrick

  case 3
    package = 'WWW';
    cd /home/patrick/HTML/WWW

  case 4
    package = 'Qpack';
    startup_general_defs;
    cd /home/patrick/ARTS/arts1/ami
    init;
    cd /home/patrick/ARTS/Qpack
    qpack_startup;
    cd Samples

  case 5
    package = 'Qsmr';
    startup_qsmr;

  case 6
    package = 'Atmlab';
    cd /home/patrick/ARTS/atmlab/atmlab
    atmlab_init;
    cd ..

  case 7
    package = 'Qoso';
    startup_general_defs;
    cd /home/patrick/Projects/Onsala/Qoso
    qoso_startup;

end


disp( sprintf('\n\n----- Welcome to %s -----\n\n', package ) );



%
% Various general default settings.
%

function startup_general_defs


  %=== These lines turn off the menu and toolbar in the plot windows
  %
  if strcmp(computer,'SOL2')
    set(0,'DefaultFigureMenuBar','none');
  elseif strcmp(computer,'LNX86') | strcmp(computer,'GLNX86')
    set(0,'DefaultUimenuVisible','off');
    set(0,'DefaultFigureToolbar','none');
  else
    error('Unknown computer type.');
  end
    
    
  %=== Give default values for plot windows
  %
  ax_size   = 12;	        %size of axes text
  ax_weight = 'bold';	        %normal or bold axes text
  %
  tx_size   = 12;	        %size of text
  tx_weight = 'normal';	        %normal or bold text



  %=== Set coler order for plot lines
  %
  corder = [
  0.00 0.00 1.00		%blue
  1.00 0.00 0.00		%red
  0.00 1.00 0.00		%green
  1.00 0.00 1.00
  0.00 1.00 1.00
  1.00 1.00 0.00
  ];


  %=== Printing
  %
  %= Set paper size to A4
  set(0,'DefaultFigurePaperType','A4');
  %
  %= Give printed figures the same size as on the screen
  set(0,'DefaultFigurePaperPositionMode','auto');


  %==========================================================================
  % Set some values defined above
  %
  %=== Set default values for plot windows
  set(0,'DefaultAxesFontWeight',ax_weight);
  set(0,'DefaultAxesFontSize',ax_size);
  set(0,'DefaultTextFontWeight',tx_weight);
  set(0,'DefaultTextFontSize',tx_size);
  set(0,'DefaultAxesColorOrder',corder);

return



% 
% The code below is copied, with some improvements, from menu.m
%

function k = local_ASCIImenu( xHeader, xcItems )


%-------------------------------------------------------------------------
% Calculate the number of items in the menu
%-------------------------------------------------------------------------
numItems = length(xcItems);

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
        disp( [ '      ' int2str(n) ') ' xcItems{n} ] )
    end
    disp(' ')
    % Prompt for user input
    k = input('Select a menu number: ');
    % Check input:
    % 1) make sure k has a value
    if isempty(k), k = -1; end;
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




