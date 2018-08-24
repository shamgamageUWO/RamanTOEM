function h = fill_between(x, y1, y2, c)
% fill_between Fill area between f(x, y1) and f(x, y2)
%
% FORMAT
%
%   h = fill_between(x, y1, y2, c
%
% IN
%
%   x       independent coordinate
%   y1      lower end of to-be-filled area
%   y2      upper end of to-be-filled area
%   c       colour
%
% OUT
%
%   h       handle to patch object
%
% See also: fill

x = vec2col(x);
y1 = vec2col(y1);
y2 = vec2col(y2);
h = fill([x; x(end:-1:1)], [y1; y2(end:-1:1)], c);

end
