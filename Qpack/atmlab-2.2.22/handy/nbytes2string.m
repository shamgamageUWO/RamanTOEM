function s = nbytes2string(n, varargin)

% nbytes2string Give human-readable representation of no. of bytes
%
% IN
%
%   n       integer     number of bytes
%   SI      logical     if set and true, use SI (10^n) instead of 2^m
%
% OUT
%
%   string with human-readable format

SI = optargs(varargin, {false});

binary_names = {'bytes', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB', 'EiB', 'ZiB', 'YiB'};
SI_names = {'bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'};

if SI
    names = SI_names;
    factor = 2.^10;
else
    names = binary_names;
    factor = 10.^3;
end

i = 1;

while n > factor && i < length(names)
    n = n / factor;
    i = i + 1;
end

if i==1
    s = sprintf('%d %s', n, names{i});
else
    s = sprintf('%.3f %s', n, names{i});
end

end
