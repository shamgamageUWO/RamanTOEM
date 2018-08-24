% OPTIMIZE_F_GRID_HIRS
%
% Optimitation of the frequency grid for an ARTS calculation.
%
% This function is for HIRS-type instruments, i.e., instruments with a
% single response function for each channel, not heterodyne receivers.
%
% This method is very general. The only assumptions made are:
% a) y_mono contains a batch of radiances for differen
% atmospheric cases.
% b) H*y_mono(i) gives a measurement vector y(i).
%
% The task is then to find a subset of frequency indices for
% which the result is similar to the result for all frequencies.
%
% In contrast to optimize_za_grid, the optimization is done over a
% whole batch of atmospheric cases, not just one. Another important
% difference is that the accuray limit should be given in the same
% unit as y_mono (usually Kelvin).
%
% Note the dopairs flag!
%
% FORMAT  fi = optimize_za_grid(H, y_mono, acc)
%
% OUT   fi           a set of frequency indices.
% IN    
%       H            H matrix.
%       y_mono  A set of radiance vectors, each vector with a
%                    number of elements fitting the number of
%                    columns of H. 
%       acc          Desired accuracy [same unit as y_mono]

% 2008-09-01 Created by Stefan Buehler

function fi = optimize_f_grid_hirs(H, y_mono, acc)

% Important dimensions:

x = size(H);
nchannels = x(1);
nfmono    = x(2);

x = size(y_mono);
if (x(1)~=nfmono)
  error('Dimensions of H and y_mono do not match!')
end
ncases = x(2);

clear x;


% Calculate the correct reference result:
y_ref = H*y_mono;


% The frequency index vector that we want to derive.
fi = [];


% The pool of frequencies to choose from.
fpool = 1:nfmono;

% We optimize the channels separately.
for ichan=1:nchannels

  disp(sprintf('Channel %d.',ichan))

  % The accuracy we have already reached.
  this_acc = 1e99;
  
  % Do the following until accuracy is good enough
  while (this_acc>acc && length(fpool)>0 )
    
    % Calculate all possible results with one frequency added.
    rms_err = ones(1, length(fpool)) * 1e99; 
    max_err = ones(1, length(fpool)) * 1e99; 
    for i=1:length(fpool)

      % Add test frequencies one by one.
      fi_test = [fi, fpool(i)];

      % fi_test must be properly sorted.
      fi_test = sort(fi_test);
      
      % Select the new H matrix for testing.
      H_test = H(ichan,fi_test);
      
      % H_test has to be correctly normalized. (This is important, if
      % we just remove frequencies, without re-normalizing, we can
      % never get a good result, unless we use all original
      % frequencies.)
      
      % The sum of H_test for each channel.
      H_norm = sum(H_test);

      % Normalize by dividing by the sum.
      H_test = H_test / H_norm;
      
      % Calculate result with this set of frequencies.
      y_test = H_test * y_mono(fi_test,:);
      
      % Difference to reference case.
      diff = y_test - y_ref(ichan,:);
      
      rms_err(i) = rms(diff);
      max_err(i) = max(abs(diff(:)));
    end
    
    figure(1)
    plot(fpool, rms_err,'o');
    figure(2)
    plot(fpool, max_err,'o');

    % Find the i for which rms_err is minimal:
    besti = find(rms_err == min(rms_err));

    this_acc = rms_err(besti);
    
    % Add this index to fi, and remove it from fpool:
    fi = [fi, fpool(besti)];
    fpool = [fpool(1:besti-1), fpool(besti+1:end)];
    
    % Some output:
    disp(sprintf('%dth frequency added has index %d, rms = %g, max = %g.',...
                 length(fi),...
                 fi(end),...
                 rms_err(besti),...
                 max_err(besti)));
    keyboard
  end                                   % While loop
end                                     % Channel loop.

% fi should be properly sorted.
fi = sort(fi);

