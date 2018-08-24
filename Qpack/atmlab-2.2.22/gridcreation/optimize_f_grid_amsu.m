% OPTIMIZE_F_GRID_AMSU
%
% Optimitation of the frequency grid for an ARTS calculation.
%
% This function is for AMSU-type instruments, i.e., instruments
% with double sideband receivers.
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

function fi = optimize_f_grid_amsu(H, y_mono, acc)

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
    
    % Calculate all possible results with frequency pairs added.
    rms_err = ones(length(fpool), length(fpool)) * 1e99; 
    max_err = ones(length(fpool), length(fpool)) * 1e99; 
    for i1=1:length(fpool)-1
      for i2=i1+1:length(fpool)

        % Add test frequency pairs.
        fi_test = [fi, fpool(i1), fpool(i2)];

        % fi_test must be properly sorted.
        fi_test = sort(fi_test);
        
        % Select the new H matrix for testing.
        H_test = H(ichan,fi_test);

        % FIXME: Remove?!
        %          nn = find(H_test ~= 0);
        %          H_test(nn) = H_test(nn) ./ H_test(nn);
        
        % H_test has to be correctly normalized. (This is important, if
        % we just remove frequencies, without re-normalizing, we can
        % never get a good result, unless we use all original
        % frequencies.)
        
        % The sum of H_test for each channel.
        H_norm = sum(H_test);
        
        % It is possible that the frequency we are checking here
        % is not relevant to this channel. In this case, we
        % should simply skip it. We can recognize this case by
        % H_norm being zero.
        if (H_norm==0)
          continue;
        end

        % Normalize by dividing by the sum.
        H_test = H_test / H_norm;
        
        % Calculate result with this set of frequencies.
        y_test = H_test * y_mono(fi_test,:);
        
        % Difference to reference case.
        diff = y_test - y_ref(ichan,:);
        
        rms_err(i1,i2) = rms(diff);
        max_err(i1,i2) = max(abs(diff(:)));          
      end
    end

    % Find the i1/i2 for which rms_err is minimal:
    [besti1, besti2] = find(rms_err == min(rms_err(:)));

    % If besti1 and besti2 are not scalars, it means that no
    % additional pair really improves things. (So we hit here all
    % the frequencies that are not relevant to the band.)
    if length(besti1)>1
      error(['We ran into a dead-end. No other frequency pair ' ...
             'improves this channel.'])
    end
    
    
    % Set this_acc for accuray test.
    this_acc = rms_err(besti1, besti2);
    
    % Add these indices to fi, and remove them from fpool:
    fi = [fi, fpool(besti1), fpool(besti2)];
    fpool = [fpool(1:besti1-1),...
             fpool(besti1+1:besti2-1),...
             fpool(besti2+1:end)];
    
    % Some output:
    disp(sprintf('%dth frequency pair added has indices %d/%d, rms = %g, max = %g.',...
                 length(fi)/2,...
                 fi(end-1), fi(end),...
                 rms_err(besti1, besti2),...
                 max_err(besti1, besti2)));
    
    %      H(ichan,fi)
    
    %      keyboard
  end                                   % While loop
end                                     % Channel loop.

% fi should be properly sorted.
fi = sort(fi);

