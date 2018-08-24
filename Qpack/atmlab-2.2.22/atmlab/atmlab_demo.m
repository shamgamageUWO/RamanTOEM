echo off
fprintf('Enlarge command window vertically as much as screen\n');
fprintf('allows, for best performance. And press a key.\n');
pause
echo on

more on

clc
%
%--- Demonstration of *atmlab* ------------------------------------------------
%
%- Global settings in Atmlab are handled by *atmlab*. 
%- To check out all present settings:
%
atmlab;


%- To get a specific field:
%
warea = atmlab( 'WORK_AREA' )
%
pause   % Press a key

clc
%
%- To set a specific field:
%
atmlab( 'WORK_AREA', '/stupid' ); 

atmlab;


%- Go back to original setting:
%
atmlab( 'WORK_AREA', warea ); 
%
%
pause   % Press a key


clc
%
%- Information on Atmlab settings are obtained by: help atmlab
%
pause   % Press a key
%
help atmlab
%
pause   % Press a key


clc
%
%--- What is found in Atmlab? ------------------------------------------------
%
%- Use *extra* list all Atmlab functions:
%
pause   % Press a key
%
extra
%
%
%- Use *lookfor* to search for a function for a specific task.
%
pause   % Press a key


clc
%
%--- Demonstration of *gridselect2D* ------------------------------------------
%
%- Create a test case by *peaks*
%
np = 101;
xf = linspace( -3, 3, np );
yf = linspace( -3, 3, np );
Af = peaks( np );
figure(1)
mesh( yf, xf, Af )
title( 'Data to fit with shorter grids' );
%
pause   % Press a key
%
%- Select shorter grids that represent data within an absolut accuracy 
%- of 0.1 using a piecewise linear represntation
%
[xc,yc,Ac] = gridselect2D( xf, yf, Af, 0.1, 'linear' );
size(Af)   % Original size
size(Ac)   % New size
%
mesh( yc, xc, Ac )
title( 'Data on coarser representation' );
%
pause   % Press a key

clc
%
%- Show representation error
%
Ac = interp2( yc, xc', Ac, yf, xf', 'linear');
mesh( yf, xf, Ac-Af )
title( 'Representation error (inside given limit everywhere!)' );
pause   % Press a key
%
clear xf yf Af xc yc Ac
close(1);



clc
%
%--- Qarts --------------------------------------------------------------------
%
%- Calculations with ARTS are controled by a structure, denoted as Q. The
%- function defining all existing fields is called *qarts*:
%
pause   % Press a key
%
Q = qarts
%
pause   % Press a key

clc
%
%- Field documentation is obtained by *qinfo*:
%
qinfo( @qarts, 'R_GEOID' )
%
pause   % Press a key

clc
%
%- Set field name to 'all' to list everything
%
pause   % Press a key
%
qinfo( @qarts, 'all' )
%
pause   % Press a key


clc
%
%- Trailing widcard can also be used:
%
qinfo( @qarts, 'P*' )
%
pause   % Press a key


clc
%
%- To call ARTS, use *arts*:
%
if ~isnan( atmlab( 'ARTS_PATH' ) )
  %
  arts( '-v' );
  %
else
  %
  %arts( '-v' );
  %
end
%
pause   % Press a key


clc
%
%- A detailed example on possible usage of Q structures, including 
%- practical calculations, is found in arts/qarts_demo.m.
%- The function will be displayed below.
%
pause   % Press a key
%
type qarts_demo
%
pause   % Press a key


clc
%
%- Ask if *qarts_demo* shall be run using the Atmlab function *yes_or_no*.
%- *qarts_demo* requires that both ARTS is available, and that
%- corresponding Atmlab settings are given.
%
if yes_or_no( 'Run *qarts_demo*' )
  qarts_demo;
end
%

clc
%
%--- End of demonstration -----------------------------------------------------
%
echo off