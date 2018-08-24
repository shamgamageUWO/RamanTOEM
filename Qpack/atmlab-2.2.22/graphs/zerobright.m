function zerobright()
% ZEROBRIGHT Rescale and centre colourmap so that brightest colour shows 0
%
% Rescale and centre the colourmap for the currently active figure so that
% the brightest colour will correspond to the value 0.  This is
% particularly useful when the colourmap contains the colour white and
% colours on one side of white are quite different from colours on the
% other side of white.  In this case, the effect of applying zerobright is
% that negative values get one colour, positive values another, and values
% around zero will be white.
%
% The function takes no input arguments and has no output arguments.
%
% See also: zerowhite, zerowhite2

oldcmap = colormap();
datarange = caxis();
ncolours = size(oldcmap, 1);

if sign(datarange(1)) == sign(datarange(2))
    error(['atmlab:' mfilename ':nonzero'], ...
        'Data do not contain zero');
end

[~, current_white] = max(mean(oldcmap, 2)); 
current_zero_pos = abs(datarange(1)/diff(datarange)) * size(oldcmap, 1);

% match 1:current_white to 1:current_zero_pos
current_zero_pos * size(oldcmap, 1);
oldcmap(1:current_white, :);

low = interp1(1:current_white, ...
              oldcmap(1:current_white, :), ...
              linspace(1, current_white, current_zero_pos));

hi = interp1(vec2col(1:ncolours - current_white), ...
             oldcmap(current_white+1:ncolours, :), ...
             linspace(1, ncolours-current_white, ncolours - current_zero_pos));

colormap([low; hi]);

end
