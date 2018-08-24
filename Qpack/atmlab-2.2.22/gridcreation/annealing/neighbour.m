% NEIGHBOUR  Find neighbour for simulated annealing algorithm.
%
% We will change one active frequency to a random passive
% frequency.
%
% (I tried more sophisticated neighbour schemes, but they worked
% less good, because they constrained the search too much.)
%
% The frequency selections are represented by arrays of type
% logical, where active frequencies are flagged true, inactive
% frequencies are flagged false.
%
% FORMAT snew = neighbour(sold)
%
% OUT snew   New frequency selection.
% IN  sold   Old frequency selection.

% 2008-09-24 Created by Stefan Buehler. 

function snew = neighbour(sold)

% Pick random active frequency
r_active = pick_random_freq(sold);

% Pick random inactive frequency
r_inactive = pick_random_freq(~sold);

% Activate inactive frequency and inactivate active frequency
snew = sold;
snew(r_active) = 0;
snew(r_inactive) = 1;
