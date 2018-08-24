function collocations = collocate(t1, lat1, long1, t2, lat2, long2, maxdist, maxtime)

% collocate Return collocations between matrices
%
% collocate searches for collocations between the measurements in (t1, lat1,
% long1) and (t2, lat2, long2). Latitudes and longitudes should be in degrees,
% the time can be in any unit. 'collocate' considers footprints as points and
% defines a collocation according to a maximum distance ('maxdist', in km).
% The maximum time to consider a collocation is in 'maxtime' and should be in
% the same unit as t1 and t2.
%
% FORMAT collocations = collocate(t1, lat1, long1, t2, lat2, long2, ...
%               maxdist, maxtime)
%
% OUT M       Nx4 matrix. Each row corresponds to a collocation, and has the
%             rows and columns of the 1st and 2nd dataset respectively. 
%
% IN  t1      Array length L1 giving the times of the scanlines.
% IN  lat1    Matrix L1xW1 with latitude for L1 scanlines with W1 scans per
%             line. The latitude should be in degrees.
% IN  long1   Matrix L1xW1 with longitude (-180, 180), L1 scans, W1 scans/line.
% IN  t2      Array of length L2 giving the times of the scanlines.
% IN  lat2    Matrix L2xW2 with latitude, L2 scans, W2 scans/line.
% IN  long2   Matrix L2xW2 with longitude (-180, 180), L2 scans, W2 scans/line.
% IN  maxdist Max distance (km) to consider a collocation.
% IN  maxtime Max time (units as for t1, t2) to consider a collocation.

% Originally created by Gerrit Holl.
% $Id$

warning(['atmlab:' mfilename], 'old style function, being phased out, use OO way');


%% data checks

nrows1 = size(lat1, 1);
ncols1 = size(lat1, 2);
nrows2 = size(lat2, 1);
ncols2 = size(lat2, 2);
nel1 = numel(lat1);
nel2 = numel(lat2);

errid = 'atmlab:collocate';
% check dimensions
assert(size(long1, 1)==nrows1, errid, 'length long1 differs from length lat1');
assert(size(long2, 1)==nrows2, errid, 'length long2 differs from length long1');
assert(length(t1)==nrows1, errid, 'length t1 differs from length lat1');
assert(length(t2)==nrows2, errid, 'length t2 differs from length long2');
assert(size(long1, 2)==ncols1, errid, 'width long1 differs from width lat1');
assert(size(long2, 2)==ncols2, errid, 'width long2 differs from width lat2');

% check correct numbers
assert(max(abs(long1(:)))<=180, errid, 'Invalid data in long1');
assert(max(abs(lat1(:)))<=90, errid, 'Invalid data in lat1');
assert(max(abs(long2(:)))<=180, errid, 'Invalid data in long2');
assert(max(abs(lat2(:)))<=180, errid, 'Invalid data in lat2');

%% make t, rows, cols at the same grid --> no need for ind2sub

t1f = reshape(repmat(t1, [1 ncols1]), [1 nel1]);
rows1f = reshape(repmat((1:nrows1)', [1 ncols1]), [1 nel1]);
cols1f = reshape(repmat(1:ncols1, [nrows1 1]), [1 nel1]);

t2f = reshape(repmat(t2, [1 ncols2]), [1 nel2]);
rows2f = reshape(repmat((1:nrows2)', [1 ncols2]), [1 nel2]);
cols2f = reshape(repmat(1:ncols2, [nrows2 1]), [1 nel2]);

%% determine earth radius

earth_radius = constants('EARTH_RADIUS')/1e3; % km

%% find collocations

% arbitrary start for pre-alloc, but getting more if needed later
collocations = zeros(numel(lat1), 4, 'uint32');

% Bin the measurements into bins, where the 'data' is the index of the
% measurement. We only need to consider those bins where:
% - instrument 1 has any measurements in the cell
% - instrument 2 has any mearurements in the cell or a nearby cell
% "Nearby" cell means a neighbouring cell, except near the poles, where it
% can be much further away (because the cells are equirectangular)

gridsize = 2;

[grid1, lat_grid1, lon_grid1] = binning_fast(...
    struct(...
        'lat', lat1(:), ...
        'lon', long1(:), ...
        'data', uint32(1:numel(lat1)).', ...
        'gridsize', gridsize));
n_grid_lats = length(lat_grid1);
n_grid_lons = length(lon_grid1);
grid2 = binning_fast(...
    struct(...
        'lat', lat2(:), ...
        'lon', long2(:), ...
        'data', uint32(1:numel(lat2)).', ...
        'gridsize', gridsize));

% Check each cell where there is data for grid1 AND at least one
% neighbouring cell, or the cell itself, has data for grid2

count = 0;

% the width and height of the cells as a function of latitude
cell_width = 2 * pi * earth_radius * cosd(lat_grid1) / 360;
cell_height = 2 * pi * earth_radius / 360;

% how many cells of latitude to check for collocations
cells_in_lat_range = ceil(maxdist ./ cell_width);
c_lon = ceil(maxdist ./ cell_height);

for i = 1:size(grid1, 1) % latitude
    c_lat = cells_in_lat_range(i);
    for j = 1:size(grid1, 2) % longitude
        if any(grid1{i, j})
            
            % find indices of points in this grid-cell
            in_grid1 = grid1{i, j};
            
            % which range of grid-cells to look for collocations?
            
            % for longitude (cols), depends on cells_in_range
            cols = j-c_lat:j+c_lat;
            cols = mod(cols, n_grid_lons);
            cols(cols==0) = n_grid_lons;

            % for latitude (rows), no dependence on lat

            rows = i-c_lon:i+c_lon;
            % edges do not wrap: if rows < 1  
            rows(rows<1) = [];
            rows(rows>n_grid_lats) = [];
            
            % find indices of points in nearby grid-cells to consider
            in_grid2 = grid2(rows, cols);
            % flatten and convert to an array
            in_grid2 = vertcat(in_grid2{:});
            if isempty(in_grid2)
                continue
            end           
            
            % find combinations of points that are near each other
            for p1 = in_grid1'
                index1 = rows1f(p1);
                colno1 = cols1f(p1);
                shorttime = in_grid2(abs(t2f(in_grid2) - t1f(p1)) < maxtime);
                near = shorttime(sphdist(lat1(p1), long1(p1), ...
                    lat2(shorttime), long2(shorttime), ...
                    earth_radius) < maxdist);

                nnear = length(near);
                if nnear
                    index2 = rows2f(near)';
                    colno2 = cols2f(near)';
                    collocations(count+1:count+nnear, :) = ...
                        [repmat(index1, [nnear 1]) repmat(colno1, [nnear 1]) ...
                        index2 colno2];
                    count = count + nnear;
                end
            end % for each in grid1
        end % if we have any candidate-collocations in this cell
        if count > .8*size(collocations, 1) % pre-allocate more
            collocations = [collocations; ...
                zeros(size(collocations, 1), 4, 'uint32')];
        end
    end % for all grid rows
end % for all grid columns

% removing 0's
collocations(collocations(:, 1)==0, :)=[];
