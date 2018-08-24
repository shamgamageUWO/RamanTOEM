% LAND_SEA_MASK   Returns land-water masks of various sizes
%
% Returns a land-water mask of various sizes. For backward compatibility,
% when called without arguments, returns a 1-degree land-sea-mask from
% arts-xml-data. In all other cases, returns a land-water-mask at the
% indicated resolution from atmlab-data (obtained with GMT).
%
%
% NOTE: To get a collection of all AVAILABLE land-water-masks, call this
% function with a single argument, being a string of length 1 equal to '?'
% (ASCII character number 63).
%
% NOTE: The new land-sea masks (obtained with GMT), the last longitude
% value is a repetition of the first, so the 1-deg mask from GMT contains
% one column more than the previous 1-deg mask in atmlab-xml-data. To
% configure this, you need to checkout the svn repo 'atmlab-data' and set
% the environment variable ATMLAB_DATA_PATH appropiately.
%
% For implementation notes (how to add masks etc.), see
% atmlab-data/land_water_mask/README
%
% FORMAT   [lat,lon,M] = land_sea_mask(gridsize)
%
% IN
%
%   gridsize    string      size of the grid (The available grids are '1min','5min','60min','1deg')
%        
% OUT   lat   Latitude grid for M.
%       lon   Longitude grid for M.
%       M     Mask matrix, with nonzero (may be 1) for land and 0 for sea.
%             Is of type logical or uint8.
%    ----- or -----
%       cell array of strings: valid resolutions
%
% EXAMPLE
%
%   >> [lat lon M] = land_sea_mask('5min');         
%   >> pcolor(lon, lat, double(M)); shading('flat');
%  ------- or -----------
%   >> gmt_plot(struct('data',M,'lat',lat,'lon',lon))
%
% WARNING
%
%   Beware of memory issues! The 1-min mask is a 10801x21601 matrix.
%   That's 233 MB in uint8, almost 1.9 GB when converted to double.
%
% $Id: land_sea_mask.m 8570 2013-08-10 18:36:48Z seliasson $
% Created by Gerrit Holl


function varargout = land_sea_mask(varargin)

switch nargin
    case 0
        [varargout{1:3}] = land_sea_mask_old;
    otherwise
        gridsize = varargin{1};
        if strcmp(gridsize, '?')
            S = dir(fullfile(atmlab('ATMLAB_DATA_PATH'), 'land_water_mask'));
            [~, ~, ~, ~, tokenStr]= regexp({S.name}, 'land_water_mask_(.*)\.png');
            varargout{1} = cellfun(@(v) v{1}, tokenStr(~cellfun(@isempty, tokenStr)));
        else
            [varargout{1:3}] = land_sea_mask_new(varargin{:});
        end
end

end 
function [lat, lon, M] = land_sea_mask_new(gridsize)

atmlab('require', {'ATMLAB_DATA_PATH'});
maskdir = fullfile(atmlab('ATMLAB_DATA_PATH'), 'land_water_mask');
maskfile = fullfile(maskdir, sprintf('land_water_mask_%s.png', strrep(gridsize,'60min','1deg')));
latlon = fullfile(maskdir, sprintf('land_water_mask_%s_latlon.nc', strrep(gridsize,'60min','1deg')));

% since strjoin only comes to matlab in 2013, I do it by hand here
x = land_sea_mask('?');
y = cellfun(@(x)(['"' x '", ']),x,'uniformoutput',0); y=[y{:}];

assert(any(strcmp(gridsize,{'1min','5min','60min','1deg'})),['atmlab:' mfilename],...
    'Grid="%s" is not available\nThe available gridsizes are %s',gridsize,y(1:end-2))
nc = loadncfile(latlon);
lat = nc.lat;
lon = nc.lon;
M = imread(maskfile);

end

function [lat, lon, data] = land_sea_mask_old

atmlab( 'require', {'ARTS_XMLDATA_PATH'} );

logtext(atmlab('OUT'),['Loading 1 degree landmask from ARTS_XML_DATA. '...
    'If you want another gridsize input e.g., gridsize = ''5min''\n'])
M = xmlLoad( fullfile(atmlab('ARTS_XMLDATA_PATH'), 'planets','Earth', ...
    'ERA40', sprintf('LandSeaMask_ERA40_1.0Degree.xml.gz') ) );

lat = M.grids{1};
lon = M.grids{2};
data = 255 * cast( M.data, 'uint8' );
end
