% FIND_BEST_FREQ_SET_ANNEAL
%
% Find best combination of n frequencies. (The number of
% frequencies to use is fix and given.)
%
% The idea of this function is from three sources mostly:
% a. http://en.wikipedia.org/wiki/Simulated_annealing. 
% b. Numerical recipes.
% c. Frank Evans description of his pseudo-K approach.
%
% The algorithm, very roughly, is this:
% 1. Pick random selections of frequency
% 2. For each frequency set, calculate a weight matrix by
%    multilinear regression.
% 3. Optimize for the best frequency set by simulated annealing
%
% The optional input structure C can be used to set some control
% parameters for the simulated annealing algorithm.
%
% C.Nblock: The calculation is done in blocks. After each block,
%           the statistics are evaluated, and the temperature is
%           adjusted. This gives the maximum number of moves
%           (iterations) in one block. 
%
% C.Nsucc:  Desired number of successfull moves in one block. If
%           Nsucc is reached, the block is terminated, even if
%           Nblock is not reached. This makes the algorithm faster
%           at high temperatures, where most moves are accepted.
%
% C.Tfact:  If the error did not decrease in the last block
%           (compared to the block before), then the new
%           temperature T will be given by T*Tfact.
%
% C.verb:   If 0, not output.
%           If 1, only text output.
%           If 2, text and plot output.
% 
% C.use_rel_error: Flag, if true then use relative error instead
%                  of absolute error.
%
%
% FORMAT [sb, Wb, eb, h] = find_best_freq_set_anneal(H,y_mono,n[,C])
%
% OUT sb = The solution as a logical array.
%     Wb = The associated weight matrix.
%     eb = The associated error.
%     h  = A structure containing the history of the annealing
%          run. This is useful for making plots of the convergence
%          behaviour.
%
% IN  H        Sensor response matrix
%     y_mono   A batch of monochromatic Tbs (dimension must match
%              y_ref and H)
%     n        Size of frequency set to test
%     C        An optional structure with control parameters. 

% 2008-09-25 Created by Stefan Buehler. 

function [sb, Wb, eb, h] = find_best_freq_set_anneal(H, y_mono, n, C)


%------------- Set overall control parameters. ----------

% Default options
def = struct(...
    'Nblock', 10000, ...       % Maximum number of cases in one block.
    'Nsucc',  100, ...         % Desired number of successfull cases in one block.
    'Tfact',  0.9, ...         % Temperature reduction factor.
    'verb',   1, ...           % Verbosity.
    'use_rel_error', false ... % Use absolute error by default.
    );        

% Check input
if nargin < 4
  % Control parameter structure missing, use default.
  C = def;
else
  % User gave C structure, check which elements are present.
  if ~isstruct(C)
    error('Input argument ''C'' is not a structure.')
  end
  fs = {'Nblock', 'Nsucc', 'Tfact', 'verb', 'use_rel_error'};
  for nm=1:length(fs)
    if ~isfield(C,fs{nm})
      C.(fs{nm}) = def.(fs{nm}); 
    end
  end
end

% Control structure is now set for sure. Assign to convenient
% internal names.

% Maximum number of cases in one block:
Nblock = C.Nblock;

% Alternatively required number of successfull cases in one block:
Nsucc = C.Nsucc;

% Temperature reduction factor:
Tfact  = C.Tfact;

% Verbosity:
verb = C.verb;

% Relative error or absolute error minimization:
use_rel_error = C.use_rel_error;

%--------------------------------------------------------


% Important dimensions:

x = size(H);
n_channels = x(1);
n_fmono    = x(2);

% The first dimension of y_mono is the number of monochromatic
% frequencies times the number of viewing angles, since spectra for
% different viewing angles are appended in the output vector y.

x = size(y_mono);
n_views = x(1)/n_fmono;
n_cases = x(2);

if verb>0
    disp(sprintf('==================================================='));
    disp(sprintf('Dimensions of the input fields \n'));
    disp(sprintf('==================================================='));
    disp(sprintf('H:      n_channels: %d, n_fmono %d\n',n_channels,n_fmono));...
    disp(sprintf('y_mono: n_cases: %d, n_y_mono: %d n_views: %d\n',n_cases,x(1),n_views));
    disp(sprintf('==================================================='));
end
    

if(mod(x(1),n_fmono) ~= 0)
    error('check dimensions/size of ''y_mono''!');
end
% FIXME: check orientation of y_mono
clear x;

% Carrying the view dimension through the entire calculation would
% make everything very complicated. Especially the calculation of
% regression weights would no longer be straightforward.
% So instead, we choose a different approach here: We treat the
% measurement at different views as if they were different
% atmospheric cases. That means we have to do some re-shaping of
% the input variable y_mono here.
% Original y_mono[n_fmono*n_views, n_cases]
% New      y_mono[n_fmono, n_cases*n_views]

y_mono_resh = reshape(y_mono,[n_fmono, n_cases*n_views]);


% Reference y:
y_ref = H * y_mono_resh;

% Initial guess.
s = logical(zeros(1,n_fmono));
for i=1:n
  % Pick random frequency among those that are not yet active.
  r = pick_random_freq(~s);

  % Activate.
  s(r) = 1;
end


% History inside one block:
e_shorthist = zeros(1,Nblock);


% Find out initial temperature. We do this by doing Nblock random
% state changes.
for i=1:Nblock
  sn = neighbour(s);  
  W  = weights(sn, y_ref, H, y_mono_resh);
  e  = test_freq_set(sn, y_ref, W, y_mono_resh, use_rel_error);
  e_shorthist(i) = e;
  s = sn;
end
% From Vicente et al.
% We want to sete Tstart such that at the beginning almost all
% moves are accepted. (Divide by ln(acceptance probability).)
T = -mean(abs(diff(e_shorthist)))/log(0.99);

% Save mean energy and other statistical parameters of this initial
% block as start of the history series

h.t_hist     = NaN(1,1000);
h.e_hist     = NaN(1,1000);
h.e_std_hist = NaN(1,1000);
h.e_min_hist = NaN(1,1000);
h.e_max_hist = NaN(1,1000);

h.t_hist(1)     = T;
h.e_hist(1)     = mean(e_shorthist);
h.e_std_hist(1) = std(e_shorthist);
h.e_min_hist(1) = min(e_shorthist);
h.e_max_hist(1) = max(e_shorthist);

if verb>0
  disp(sprintf('mean(abs(delta_e)) = %g', mean(abs(diff(e_shorthist)))));
  disp(sprintf('T(start) = %g', T));
end

% Initialize best state energy:
eb = h.e_max_hist(1);


k = 1;


go_on = true;
while go_on
  
  % Do a block of steps at a time
  n_succ = 0;                           % Count successful steps
  for i=1:Nblock

    % Select neighbour.
    sn = neighbour(s);  
    
    % Calculate weights.
    W  = weights(sn, y_ref, H, y_mono_resh);

    % Calculate error (= energy).
    en = test_freq_set(sn, y_ref, W, y_mono_resh, use_rel_error);
    
    % Energy difference:
    de = en - e;
    
    % Update best state, if this one is better.
    if en < eb
      sb = sn;
      Wb = W;
      eb = en;
    end

    % Probability of this state:
    Pk = exp(-de/T);
    
    if rand(1,1) < Pk
      s = sn;
      e = en;      
      
      n_succ = n_succ + 1;   
    end
    
    e_shorthist(i) = e;    

    if n_succ >= Nsucc
      break
    end
  end
    
  k = k+1;
  
  h.t_hist(k)     = T;
  h.e_hist(k)     = mean(e_shorthist(1:i));
  h.e_std_hist(k) = std(e_shorthist(1:i));
  h.e_min_hist(k) = min(e_shorthist(1:i));
  h.e_max_hist(k) = max(e_shorthist(1:i));

  if verb>0
    if (use_rel_error)
      disp(sprintf('T = %g, e_min = %g, e_mean = %g, e_max = %g [fractional errors]',...
                   h.t_hist(k),...    
                   h.e_min_hist(k),...    
                   h.e_hist(k),...    
                   h.e_max_hist(k) ))
    else
      disp(sprintf('T = %g K, e_min = %g K, e_mean = %g K, e_max = %g K',...
                   h.t_hist(k),...    
                   h.e_min_hist(k),...    
                   h.e_hist(k),...    
                   h.e_max_hist(k) ))
    end
  end
    
  % Display results
  if verb>1
    figure(1)
    semilogy([h.e_min_hist(1:k); ...
              h.e_hist(1:k); ...
              h.e_max_hist(1:k)]');
    xlabel('Iteration')
    if (use_rel_error)
      ylabel('RMS error [fractional]')
    else
      ylabel('RMS error [K]')
    end
  
    figure(2)
    semilogy(h.t_hist(1:k));
    xlabel('Iteration')
    if (use_rel_error)
      ylabel('Temperature [fractional]')
    else
      ylabel('Temperature [K]')
    end
      
    figure(3)
    loglog(h.t_hist(1:k), h.e_hist(1:k), '.');
    xlabel('Temperature [K]')
    if (use_rel_error)
      ylabel('RMS error [fractional]')
    else
      ylabel('RMS error [K]')
    end
  end

  % Should we decrease T? - Not if the mean error is still
  % decreasing. 
  if h.e_hist(k) >= h.e_hist(k-1)
    T = T * Tfact;
  end
  
  % Should we continue? - We use as stop criterion that there were
  % no more successful moves
  if n_succ == 0
    go_on = false;
  end
end
  

if verb>0
  disp('Best combination:')
  if (use_rel_error)
    disp(sprintf('RMS error:   %g [fractional]', eb))
  else
    disp(sprintf('RMS error:   %g [K]', eb))
  end
end

