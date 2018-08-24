function [outdata,outlat,outlon,weights] = regionize(data,lat,lon,corner,trim)
%% regionize
%
% PURPOSE: function that nan's out all data outside a given region bounds (or several regions)
%
% IN: data %2 or more dims starting with (lat,lon,...) or (lon,lat,...)
%     lat  %vector
%     lon  %vector
%     corner = [blcorner,trcorner;blcorner,trcorner] % each corner is [lat,lon]
%     trim   = true or false 
%          (1=trim data and lat lons outside the region (default), 0=don't)
%
%     NOTE REGARDING corner: If you want to use a predefined region, use
%            e.g. corner = getPredefinedRegion('tropics') %look into function region list
%
%     NOTE REGARDING trim: If you need the size of data matrix to remain unchanged, input trim=0
%
% OUT:    outdata
%         outlat
%         outlon
%         weights % takes care of grids that are overlapping the edges
%         flags = 
%
% USAGE: [data,lat,lon,weights,flags] = regionize(data,lat,lon,corner)
% 
% NOTE: 1) If the data is gridded the spacing between lats and lon must be
%          equidegree.
%       2) Gridded data that is partly in and partly out of a region is
%          included in outdata. Use the 3rd output argument to weight the
%          data according to how much of the gridbox is in the region
%
%
% Created by Salomon Eliasson
% $Id: regionize.m 8740 2013-11-06 13:17:18Z seliasson $

errID = 'atmlab:regionize:badInput';
assert(nargin>=4,errID,'Not enought input arguments')

% Default action is to trim away NaNs out side region
if nargin==4, trim = true; end 

[outdata,outlat,outlon,isgridded,flags] = setup(data,lat,lon);

if isgridded
    % for the sake of grids overlapping the edges
    dlt = mean(diff(unique(lat)));
    dln = mean(diff(unique(lon)));
    
    
    sz = size(outdata);

    z.data = outdata(:,:,:);  %collapse to 3Doutdata;

    % NaN away everything that is not a region
    z.lat = repmat(outlat,1,length(outlon));
    z.lon = repmat(outlon,1,length(outlat))';
    
    [logical_field,periphery] = get_logicalfield(z,corner,dlt,dln);
    
    % Find weights for data on periphery of regions
    weights = findWeightsOnPeriphery(z.lat,z.lon,periphery,corner,dlt,dln);
    weights(logical_field) = 1;

    % Nan away everything outside region
    tmp =  permute(z.data,[3,1,2]); tsz = size(tmp);
    tmp = tmp(:,:);
    tmp(:,~logical_field&~periphery) = NaN;
    z.data = permute(reshape(tmp,tsz),[2,3,1]);
    
    %Trim away NaNs outside the region
    if trim
        [z.data,outlon,outlat,weights] = trimAwayNaNs_gridded(z.data,outlon,outlat,weights,corner,[dlt,dln]);
    end
    
    % Reshape the data array back to the original lat/lon format (first 2 dims)
    [outdata,outlat,outlon,weights] = useFlags(z.data,outlon,outlat,weights,flags);
    
    %resurrect matrix size to the original format
    outdata = reshape(outdata,[size(outdata,1),size(outdata,2),sz(3:end)]);
    
else
    z.data        = outdata(:);
    z.lat         = outlat(:);
    z.lon         = outlon(:);
    logical_field = get_logicalfield(z,corner,0,0); %dlt and dln = 0 
    
    outlat        = z.lat(logical_field);
    outlon        = z.lon(logical_field);
    outdata       = z.data(logical_field);
    
    if trim
       [outdata,outlon,outlat] = trimAwayNaNs_ungridded(outdata,outlon,outlat,corner); 
    end
end

%%%%%%%%%%%%%%%%%
%% SUBFUNCTIONS
%      |||||
%      VVVVV
function [outdata,outlat,outlon,ig,flags] = setup(data,lat,lon)
%% setup

errID = 'atmlab:reginize:badInput';

a = size(data);
ig = ~isequal(a,size(lat),size(lon));              % is gridded or not

if ~ig
    outlon = lon(:);
    outlat = lat(:);
   outdata = data(:);
   flags = [];
   return
end


assert(isequal(a(1:2),[length(lat),length(lon)]) || isequal(a(1:2),[length(lon),length(lat)]),...
    errID,'Dimensions of data must be of form (lat,lon,...) or (lon,lat,...)')


% make sure conventions are followed
[flags,outlat,outlon,outdata] = standardize_geodata(lat(:),lon(:),data);

function [logical_field,periphery] = get_logicalfield(in,corner,dlt,dln)
%% get_logicalfield

% fit exactly 
logical_field=false([size(in.data,1),size(in.data,2)]);
for i = 1:size(corner,1)
    lt1 = in.lat >= corner(i,1) + dlt/2;
    lt2 = in.lat <= corner(i,3) - dlt/2;
    ln1 = in.lon >= corner(i,2) + dln/2;
    ln2 = in.lon <= corner(i,4) - dln/2;

    logical_field = logical_field | ( ln1&ln2&lt1&lt2 );
end

% on the periphery of the region
periphery=false([size(in.data,1),size(in.data,2)]);
for i = 1:size(corner,1)
    lt1 = in.lat >= corner(i,1) - dlt/2;
    lt2 = in.lat <= corner(i,3) + dlt/2;
    ln1 = in.lon >= corner(i,2) - dln/2;
    ln2 = in.lon <= corner(i,4) + dln/2;

    periphery = periphery | ( ln1&ln2&lt1&lt2 );
end
periphery(logical_field)=false;

function weights = findWeightsOnPeriphery(lat,lon,periphery,C,dlt,dln)
%% findWeightsOnPeriphery
%
% First NaNs away grids that are not on the perifery
% Then loops over these points to find out how how they overlap the
% region boundaries
%
% C = corners ([blcorner,trcorner;blcorner,trcorner]), dlt & dln are the gridsizes

sz      = size(lat);
weights = zeros(sz);
num     = 1:length(lat(:));
num     = reshape(num,sz);
num     = num(periphery);

% Now loop over remaining points. Loop also over the regions
AREA = 0;
for i = num'
    for j = 1:size(C,1)
        A = [lon(i)-dln/2,lat(i)-dlt/2,dln,dlt];
        B = [C(j,2),C(j,1),C(j,4)-C(j,2),C(j,3)-C(j,1)];
        AREA = AREA + rectint(A,B);
    end
    weights(i) = AREA/(dlt*dln); % normalized area. Max = 1;
    AREA = 0;
end

function [data,lon,lat,weights] = trimAwayNaNs_gridded(data,lon,lat,weights,corner,gsize)
%% Trim dataset to get rid of NaNs outside the regions
% If you don't need weights, make the 4th argument empty []
% gsize is the size of the grid [dlat,dlon]

gh = gsize/2; %half boxwidth

% Use the corner input to trim away the data
if ndims(data)==2
    data = data(lat>=min(corner(:,1))-gh(1) & lat<=max(corner(:,3))+gh(1),...
        lon>=min(corner(:,2))-gh(2) & lon<=max(corner(:,4))+gh(2));
elseif ndims(data==3)
        data = data(lat>=min(corner(:,1))-gh(1) & lat<=max(corner(:,3))+gh(1),...
        lon>=min(corner(:,2))-gh(2) & lon<=max(corner(:,4))+gh(2),:);
end

if ~isempty(weights)
    weights = weights(lat>=min(corner(:,1))-gh(1) & lat<=max(corner(:,3))+gh(1),...
        lon>=min(corner(:,2)) -gh(2) & lon<=max(corner(:,4))+gh(2));
end
lat = lat(lat>=min(corner(:,1))-gh(1) & lat<=max(corner(:,3))+gh(1));
lon = lon(lon>=min(corner(:,2))-gh(2) & lon<=max(corner(:,4))+gh(2));

function [data,lon,lat,weights] = trimAwayNaNs_ungridded(data,lon,lat,corner)
%% Trim dataset to get rid of NaNs outside the regions
% If you don't need weights, make the 4th argument empty []
% gsize is the size of the grid [dlat,dlon]

% Use the corner input to trim away the data
if ndims(data)==2
    data = data(lat>=min(corner(:,1)) & lat<=max(corner(:,3)) &...
        lon>=min(corner(:,2)) & lon<=max(corner(:,4)));
elseif ndims(data==3)
        data = data(lat>=min(corner(:,1)) & lat<=max(corner(:,3)) &...
        lon>=min(corner(:,2)) & lon<=max(corner(:,4)),:);
end

lat = lat(lat>=min(corner(:,1)) & lat<=max(corner(:,3)));
lon = lon(lon>=min(corner(:,2)) & lon<=max(corner(:,4)));

function [data,lat,lon,weights] = useFlags(data,lon,lat,weights,flags)
%% useFlags

% if the orig lons are in the 0:360 regime. Put them BACK
if flags.lon360
    lon = lon +(lon < 0)*360;
    [lon,lnindex] = sort(lon);
    data    = data(:,lnindex,:);
    weights = weights(:,lnindex);
end
%
if flags.lon_descend
    [lon,lnindex]  = sort(lon,'descend');
    data = data(:,lnindex,:);
    weights = weights(:,lnindex);
end

% If the orig lats are DESCENDING. Put them BACK
if flags.lat_descend
    [lat,ltindex]  = sort(lat,'descend');
    data = data(ltindex,:,:);
    weights = weights(ltindex,:);
end

% If orig data was data(lat,lon,...), Permute BACK
if ~flags.permute
    data = permute(data,[2,1,3]);
    weights = permute(weights,[2,1]);
end 
