% LOOP_ANNEAL Loop annealing algorithm until desired accuracy
% reached
%
% This is a higher level function, that uses the lower level
% function find_best_freq_set_anneal.
%
% It starts by calling find_best_freq_set_anneal with n_start
% frequencies and storing the result. Then it calles it over again
% with one frequency more, and so on until the desired accuracy is
% reached.
%
% FORMAT R = loop_anneal(H, y_mono, n_start, n_incr, acc, C)
%
% OUT R       An array of structures. Each structure has elements sb, Wb,
%             eb, h, which correspond to the output arguments of
%             find_best_freq_set_anneal.
% IN  n_start The starting number of frequencies. (You should take
%             at least one per channel.)
%     n_incr  By how much to increment n in each iteration.
%     acc     The desired accuracy, at which the looping is
%             stopped. This is the RMS error in the solution, as
%             returned by find_best_freq_set_anneal in eb.
%     H, y_mono, C  Parameters of find_best_freq_set_anneal. 

% 2008-09-25 Created by Stefan Buehler. 

function R = loop_anneal(H, y_mono, n_start, n_incr, acc, C)


% Check input
if nargin == 6
  % Control parameter C is provided! If C is not provided,
  % find_best_freq_set_anneal will use default values
  %
  % Set values
  % Set verbosity of find_best_freq_set_anneal to 0:
  C.verb = 1;
end

disp('****************************************')
disp(sprintf('Starting with n = %d.', n_start))

go_on = true;
i = 1;
n = n_start;
while go_on
  
   if nargin == 6
     % Control parameter C is provided!
     [sb, Wb, eb, h] = find_best_freq_set_anneal(H,...
                                                 y_mono,...
                                                 n,...
                                                 C);
   else 
     [sb, Wb, eb, h] = find_best_freq_set_anneal(H,...
                                              y_mono,...
                                              n);
   end
   
  R(i).sb = sb;
  R(i).Wb = Wb;
  R(i).eb = eb;
  R(i).h  = h;
  
  disp('****************************************')

  if nargin == 6
     % Control parameter C is provided!
     if (C.use_rel_error)
       disp(sprintf('n = %d, acc = %g [fractional]', n, eb))
     else
       disp(sprintf('n = %d, acc = %g K', n, eb))
     end
   end

  if eb<=acc
    go_on = false;
  else
    i = i+1;
    n = n+n_incr;
  end
end

