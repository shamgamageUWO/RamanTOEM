% AMSU_CHANNELS  Returns information about the AMSU A and B channels
%
%    The function describes the main properties of the AMSU A and B
%    channels.
%
%    The bands of each channel are centered at v0 +- dv1 +- dv2,
%    and each band has the width *bwidth*.
%
% FORMAT   [v0,nbands,dv1,dv2,bwidth,nedt] = amsu_channels( channelnrs )
%        
% OUT   v0           Centre frequency of channels
%       nbands       Number of bands for the channels (1, 2 or 4)
%       dv1          First order band seperation
%       dv2          Second order band seperation
%       nedt         Std dev for thermal noise [K]
% IN    channelnrs   Vector with channel numbers 

% 2003-10-01   Created by Patrick Eriksson


function [v0,nbands,dv1,dv2,bwidth,nedt] = amsu_channels( channelnrs )


A = [
23800        0     0    1  270     0.30	; ...   % 1
31400        0     0    1  180     0.30	; ...   % 2
50300        0     0    1  180     0.40	; ...   % 3
52800        0     0    1  400     0.25	; ...   % 4
53596      115     0    2  170     0.25	; ...   % 5
54400        0     0    1  400     0.25	; ...   % 6
54940        0     0    1  400     0.25	; ...   % 7
55500        0     0    1  330     0.25	; ...   % 8
57290.344    0     0    1  330     0.25	; ...   % 9
57290.344  217     0    2  78      0.40	; ...   % 10
57290.344  322.2  48    4  36      0.40	; ...   % 11
57290.344  322.2  22    4  16      0.60	; ...   % 12
57290.344  322.2  10    4  8       0.80	; ...   % 13
57290.344  322.2   4.5  4  3       1.20	; ...   % 14
89000        0     0    1  6000    0.50	; ...   % 15
89000      900     0    2  1000    0.37	; ...   % 16
150000     900     0    2  1000    0.84	; ...   % 17
183310    1000     0    2  500     1.06	; ...   % 18
183310    3000     0    2  1000    0.70	; ...   % 19
183310    7000     0    2  2000    0.60	; ...   % 20
];


v0     = A( channelnrs, 1 ) * 1e6;
nbands = A( channelnrs, 4 );
dv1    = A( channelnrs, 2 ) * 1e6;
dv2    = A( channelnrs, 3 ) * 1e6;
bwidth = A( channelnrs, 5 ) * 1e6;
nedt   = A( channelnrs, 6 );