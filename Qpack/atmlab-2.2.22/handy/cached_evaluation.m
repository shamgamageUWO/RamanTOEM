function varargout = cached_evaluation(func, varargin)

% Wrapper around CachedData.evaluate
%
% Using a persistent 1 GiB cached object, evaluate and cache expressions.
%
%   [out1, out2, ...] = cached_evaluation(@func, in1, in2, ...)
%
% is equivalent to
%
%   [out1, out2, ...] = func(in1, in2, ...)
%
% except that the results are cached.
%
% For more information, see CachedData/evaluate.

persistent cd

if isequal(cd, [])
    cd = CachedData();
    cd.maxsize = 2.^30; % 1 GiB
end

nout = nargout;
[varargout{1:nout}] = cd.evaluate(nout, func, varargin{:});

end
