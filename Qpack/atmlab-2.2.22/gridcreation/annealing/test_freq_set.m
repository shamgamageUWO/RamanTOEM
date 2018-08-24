% TEST_FREQ_SET
%
% Test a frequency selection.
%
% FORMAT e = test_freq_set(s, y_ref, H, y_mono)
%
% OUT e = RMS error of this selection, compared to reference
%
% IN  s       frequency set (type logical, dimension must match H)
%     y_ref   reference Tbs, result of H*y_mono
%     H       Weight matrix
%     y_mono  a batch of monochromatic Tbs (dimension must match
%             y_ref and w)
%     use_rel_error Flag: If true then use relative error instead
%                   of absolute error.

function e = test_freq_set(s, y_ref, H, y_mono, use_rel_error)

% Number of channels:
x = size(H);
nchannels = x(1);

%keyboard

H_red = H(:,s);

% Normalize correctly
%for i=1:nchannels
%  H_norm = sum(H_red(i,:));
%  H_red(i,:) = H_red(i,:) / H_norm;
%end
% We do no longer normalize, since the matrix H contains the
% correct weights, calculated by linear regression. (And in fact
% H is also explicitly normalized to one.)

y_mono_red = y_mono(s,:);

y_test = H_red * y_mono_red;

if (use_rel_error)
%  disp('Using relative error!')
  d = (y_test - y_ref)./y_ref;  
else
%  disp('Using absolute error!')
  d = y_test - y_ref;  
end

e = rms(d);
