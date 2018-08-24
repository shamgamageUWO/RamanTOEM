% WEIGHTS Calculate the appropriate weight for each frequency.
%
% We do this by linear regression over all atmospheric cases.
%
% For each channel, we allow only those frequencies for which H is
% nonzero to contribute. (For clear-sky, out of band frequencies
% could probably also be used, but this certainly does not
% generalize well to cloudy cases.)
%
% If there are negative weights, then these weights are set to
% zero, and the regression is repeated without these channels.
%
% At the end, the weights are normalized so that the sum of all
% weights for one channel is exactly 1, as done by Moncet et al.,
% 2008. This should improve robustness and generalizability.
%
% FORMAT W = weights(s, y_ref, H, y_mono)
%
% OUT W       A matrix of channel weights. (Which can be used
%             instead of H, but without normalization)
%
% IN  s       Frequency set (type logical, dimension must match H)
%     y_ref   Reference Tbs, result of H*y_mono
%     H       Original measurement response matrix. We need this
%             to decide which frequencies should contribute to
%             which channel. 
%     y_mono  A batch of monochromatic Tbs (dimension must match
%             y_ref and s)

function W = weights(s, y_ref, H, y_mono)

s_y_ref  = size(y_ref);
s_y_mono = size(y_mono);
s_H      = size(H);

n_chan = s_y_ref(1);

if  n_chan ~= s_H(1)
  error('y_ref and H not consistent!');
end

if s_y_ref(2) ~= s_y_mono(2)
  error('Atmospheric case number in *y_ref* and *y_mono* inconsistent!');
end

% Number of atmospheric cases:
n_cases = s_y_ref(2);

if length(s) ~= s_y_mono(1)
  error('Frequency number in *s* and *y_mono* inconsistent!');
end

% Number of monochromatic frequencies:
n_freqs = length(s);

% Loop channels
W = H*0;
for i=1:n_chan

  % We need a loop here to ignore frequencies that would give negative
  % weights
  ignored = logical(zeros(1,n_freqs));
  
  all_ok = false;
  
  while ~all_ok
  
    % Find out, which of the active frequencies are relevant for this
    % channel.
    relevant = H(i,:) > 0;
    
    % Subset of active frequencies for this channel.
    % They must be:
    % - part of the tested frequency set *s*
    % - part of the relevant frequencies for this channel
    %   *relevant*
    % - not part of the frequencies that gave negative weights *ignored*    
    now_active = s & relevant & ~ignored;
    
    % Indices of the now active frequencies:
    i_now_active = find(now_active);

    % Number of active frequencies:
    n_active_freqs = length(i_now_active);

    % Construct design matrix (see multiple regression in Matlab online
    % help):
    %X = [ones(n_cases,1), y_mono(s,:)'];
    X = y_mono(now_active,:)';

    % Do least square fit for the weights, using backslash operator:
    w = X\y_ref(i,:)';

    % We do not want negative weights. We identify them, add them
    % to the ignore list, and repeat the regression.
    neg_weights = find(w<0);
    
    if length(neg_weights) == 0
      all_ok = true;
%      disp('All freqs ok.')
    else
      ignored(i_now_active(neg_weights)) = 1;    
%      disp('Ignoring some freqs.')
    end
    
  end

  % Construct matrix W, which we can use instead of matrix H. The
  % dimensionof W is still the same as that of H, so most elements
  % are zero!
  W(i,now_active) = w';

  % Set weight for those channels that we ignored to avoid negative
  % weights to zero:
  W(i,ignored) = 0;
  
  % Normalize weight sum to 1:
  weight_sum = sum(W(i,now_active));
  W(i,now_active) = W(i,now_active) / weight_sum;
end

