% PICK_RANDOM_FREQ  Pick a random frequency.
%
% This picks a random element among those elements of the mask s for
% which s is true.
%
% The active frequencies are specified by a logical array s.
%
% FORMAT i = pick_random_freq(s)
%
% OUT  i   The chosen frequency.
% IN   s   The frequencies to choose from.

% 2008-09-24 Created by Stefan Buehler. 

function i = pick_random_freq(s)

% The active frequencies:
f_active = find(s);

% How many active frequencies?
nactive  = length(f_active);

% Choose random element in active.
i_active = ceil(rand(1)*nactive);

% Return index of this frequency.
i = f_active(i_active);

