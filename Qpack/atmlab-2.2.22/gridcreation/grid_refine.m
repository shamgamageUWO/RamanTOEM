% GRID_REFINE Refine a grid by adding additional points
%
% This function refines a grid by adding additional points in such a way
% that each interval in the new grid is smaller than the desired value
% delta. All points of the original grid are retained. A typical
% application of this is to create a finer vertical grid for atmospheric
% profiles.
%
% The original grid og must be strictly monotonic (either increasing or
% decreasing, no duplicate values).
%
% See also PROFILE_REFINE, which uses this function.
%
% FORMAT ng = grid_refine(og, delta)
%
% OUT   ng      New (denser) grid.
% IN    og      Original grid.
%       delta   Desired maximum grid spacing.

% 2010-07-02 Created by Stefan Buehler

function ng = grid_refine(og, delta)

% Original grid must have at least two elements.
if length(og) < 2
    error( 'Original grid og must have at least two elements.' );
end

% Find out direction of grid and, if necessary, revert it so that it is
% always increasing. (Just to simplify things)
inverted = false;
dir = og(2)-og(1);
if dir < 0
    og = og(end:-1:1);
    inverted = true;
end

% Check that original grid is monotoneously increasing (even duplicate
% values are not allowed):
d = diff(og);
if min(d) <= 0
   error('Original grid og must be strictly monotonic.'); 
end

% Find out if the original grid is a row or column vector. We will turn
% round the result to match the original grid.
transpose = false;
[rows,cols] = size(og);
if (rows > cols)
    transpose = true;
end

% Now the actual work starts...

% Find out how many subdivisions are needed for each interval of the
% original grid.
nsub = ceil(d/delta);

% Calculate subdivision intervals:
sub = d./nsub;

% Create a cell array with the new grid points for each interval in the
% original grid. 
ng = arrayfun(@linspace, og(1:end-1), og(2:end)-sub, nsub,...
            'UniformOutput', false);
        
% Get rid of the cell array by concatenating all elements, and add the
% missing last element of the original grid.
ng = [ng{:}, og(end)];


% Turn round the result if the original grid was decreasing:
if inverted==true
    ng = ng(end:-1:1);
end

% Transpose the result, if necessary, to match the orientation (row or
% column vector) of the original grid.
if transpose==true
   ng = ng'; 
end


