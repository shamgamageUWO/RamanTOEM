% DEMO_VENUS_RO   Simulates a Venus radio experiment
%
%    The demo covers a satellite in a orbit around Venus. 
%
%    A high number of quantities are calculated, see the figure that are
%    created automatically. The demo is slow as extensive line-by-line 
%    calculations are involved.
%
% FORMAT   demo_venus_ro([workfolder])
%
% See *arts_radioocc_1D* for definition of the output arguements.
%
% OPT   workfolder   Default is to use a temporary folder for the
%                    calculations. If you specify a folder with this
%                    argument, you will find the control and data files in
%                    this folder after the calculations are finished.

% Patrick Eriksson 2013-10-17

function [R,T,O,A] = demo_venus_ro(workfolder)
%
if nargin < 1, workfolder = []; end

%-------
% O part
%-------

% Satellite orbit altitude. Note that the satellite is assumed to be in a
% circular orbit around the planet.
%
O.tra_altitude = 1000e3;
O.tra_movement = 'disappearing';

% The closest distance Earth - Venus is about 38e12.  
O.rec_altitude = 38e12;
O.rec_movement = 'none';

% These are the two frequencies of Venus-Express. Select one.
%
%O.frequency    = 2.3e9;     
O.frequency    = 8.4e9;   % This one gives much lower impact of free
                          % electrons, but higher gas absorption


% For higher accuracy, decrease these values, particularly lraytrace.
% lmax mainly affects the accuracy for the tangent point determination
%
O.lmax         = 10e3;
O.lraytrace    = 100;

% Surface altitude 
%
% Here of not important as the rays don't get below about 45 km
%
O.z_surface    = 1e3;

% These settings determine end point of occultation, how dense calculations
% that are performed etc. See *arts_radioocc_1D_power* for details.
%
% These actual settings gives a rough overview
%
O.z_impact_max = 200e3;
O.z_impact_dz  = 1e3;
O.z_impact_min = 45e3;
O.z_impact4t0  = O.z_impact_max;  % Sets reference point for time
O.f_sampling   = 4;

% We want attenuation
O.do_atten      = true;

% This one is a bit tricky. Free elctron gets index 1. The "basespecies"
% follow, and get index 2, 3 .... The water species are included last.
% These indexes will extract attenuation due to CO2, H2SO4 and SO2 
O.do_absspecies = [2 3 5]; 

  
%-------
% A part
%-------

% Don't change these (if you don't switch planet)!
%
A.planet       = 'venus';
A.atmfunc      = @qarts_add_venus_planettbox;

A.atmo         = 3;               % Atmospheric scenario
%
A.basespecies  = [3,4,7,15];      % This is CO2-PWR, H2SO4, N2 and SO2
A.h2ospecies   = 1;               % Level of water vapour
A.hdospecies   = 3;               % Level of HDO
A.Necase       = 2;               % Free electron case. Note that 5-6 needs
%                                 % atm=0-2, while 0-4 to needs atmo=3-4
A.interp_order = 1;               % Linear interpolation of fields (higher
%                                   values risky
A.pmin         = 1e-6;            % Min pressure to consider. This value
                                  % crops around 200 km


% Here we need to a special solution, to avoid the need to manually generate
% "linefiles" 
%
Q = qarts;

% Increasing df gives better accuracy (more transitions are included in the
% calculation, but gives slower calculations). 5 GHz is a bit low, but
% selected to make the calculations a bit faster. 10 GHz should be sufficient if
% not max accuracy is demanded. However, if the absorption is totally dominated
% by continuum terms, df can in principle be zero.
df = 5e9;
%
Q.ABS_WSMS{end+1} = sprintf( ['abs_linesReadFromSplitArtscat(abs_lines,',...
    'abs_species,"spectroscopy/Perrin/",%.2e,%.2e)'], ...
                                 max([O.frequency-df,0]), O.frequency+df );
Q.ABS_WSMS{end+1} = 'abs_lines_per_speciesCreateFromLines';
if df > O.frequency
  Q.ABS_WSMS{end+1} = sprintf( ...
           'abs_lines_per_speciesAddMirrorLines(max_f=%.6e)', df-O.frequency );
end

%- Perform calculation
%
[R,T] = arts_radioocc_1D( Q, O, A, workfolder );



%- Plot results

tstring = sprintf( 'Venus: Atmosphere %d, Necase %d, %.2f GHz', ...
                                           A.atmo, A.Necase, O.frequency/1e9 );
fs = 14;

figure(1)
clf  
plot( R.bangle, R.z_tan/1e3 )
%
grid
xlabel( 'Bending angle [deg]', 'FontSize', fs );
ylabel( 'Tangent height [km]', 'FontSize', fs );
title( tstring, 'FontSize', fs+2 )
axis([-1e-3 1e-3 80 200])


figure(2)
clf  
clonefig(1,2)
axis([0 7.5 35 95])


figure(3)
clf  
plot( R.l_optpath-R.l_geometric, R.slta/1e3 )
%
grid
xlabel( 'Excess range [m]', 'FontSize', fs );
ylabel( 'Straight-line tangent altitude [km]', 'FontSize', fs );
title( tstring, 'FontSize', fs+2 )


figure(4)
clf  
plot( -10*log10(R.tr_atmos), R.z_tan/1e3, 'r-', ...
      -10*log10(R.tr_defoc), R.z_tan/1e3, 'b-', 'LineWidth', 2 );
%
grid
xlabel( 'Attenuation [dB]', 'FontSize', fs );
ylabel( 'Tangent height [km]', 'FontSize', fs );
title( tstring, 'FontSize', fs+2 )
legend( ' Absorption', ' Defocusing' );
axis([0 22 35 105])
ax = axis;
db0 = -10*log10( R.tr_space(1) );  
text( ax(2)/4, ax(3)+0.7*diff(ax(3:4)), sprintf(['Free space loss is ',...
'%.1f dB, and is basically \nconstant during the occultation'], db0 ));


figure(5)
clf  
plot( -10*log10(R.tr_absspecies), R.z_tan/1e3 );
%
grid
xlabel( 'Attenuation [dB]', 'FontSize', fs );
ylabel( 'Tangent height [km]', 'FontSize', fs );
title( tstring, 'FontSize', fs+2 )
legend( 'CO2', 'H2SO4', 'SO2' );
axis([0 6 35 80])

figure(6)
clf  
plot( T.t, T.bangle )
%
grid
xlabel( 'Relative time [s]', 'FontSize', fs );
ylabel( 'Bending angle [deg]', 'FontSize', fs );
title( tstring, 'FontSize', fs+2 )

