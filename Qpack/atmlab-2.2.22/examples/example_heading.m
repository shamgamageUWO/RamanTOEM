% FUNCNAME   A template for function headers.
%
%    The line above gives a very short summary of the function. Write the 
%    line carefully as it is used by Matlab for special purposes. For example, 
%    the default for the *lookfor* function is to only look at the first 
%    comment line.
%
%    Below the first line follows a description of the function, with 
%    paragraphs separated with empty rows.
%
%    The format described here differs in two aspects from the format used by
%    MathWorks. First, the output and input arguments are described below by a
%    parameter list (instead of a free text), pretty much as normally done in
%    e.g. C programming. Second, reference to variables and functions are here
%    indicated as * * (instead of using capital letters).  For example, "input
%    argument *b* must be a string, which as passed on to the function
%    *some_fun*". An exception is the first line of the header where the Matlab
%    style is used. Another difference to the Matlab style is that the function
%    declaration is put after the header part (instead of at the top).
%
%    The function is first described by giving the format. Optional input
%    arguments are given inside square brackets ([]). The output and input
%    arguments are then listed following the example below. 
%
%    It is good practice to give optional input arguments clear default 
%    values, which should be given in the function header. It is normally
%    better to start the function by setting not given input to the default
%    values, than putting more complicated if statements in the code. 
%    This strategy should also be less likely to give unexpected side-effects
%    if more input arguments are added. Example on how to set default 
%    values are given inside the function below.
%
%    Notice that the history log is not part of the header, and there should
%    be an empty line before the log.
%
% FORMAT   [a1,a2] = example_heading(b,c[,d,e])
%        
% OUT   a1   A descrition of the variable.
%       a2   A descrition of the variable.
% IN    b    A descrition of the variable. The description can run over 
%            several lines. 
%       c    A descrition of the variable.
% OPT   d    A descrition of the variable. Default is false.
%       e    A descrition of the variable. Default is 1.

% 2002-12-07   Created by Patrick Eriksson 
% 2002-12-09   A big improvement by PE.


function [a1,a2] = example_heading(b,c,d,e)
%
[b,c,d,e] = funcinput( varargin, 2, {false,[]} )

%- Input checks                                                       %&%
%                                                                     %&%
% The comment string %&% marks lines that can be removed for          %&%
% 'operational applications'. See README.                             %&%
%                                                                     %&%
rqre_datatype( b, {@ischar} );                                        %&%
rqre_datatype( c, {@ischar,@istensor2} );                             %&%
rqre_datatype( d, {@isboolean} );                                     %&%
rqre_datatype( e, {@istensor0} );                                     %&%
rqre_in_range( e, 1, 3 );                                             %&%

%- ...
%
a1 = d;
a2 = e;