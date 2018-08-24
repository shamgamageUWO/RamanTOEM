function [Z,Y,X] = binning_fast(in,lonspace)
%% BINNING_FAST bins ungridded data onto a grid
%
% Purpose:
% Bins ungridded data to a cell grid using d = in.gridsize. Each bin will contain a
% vector of values for that bin.
%
% The structure elements lon,lat,data (or X,Y,Z) must be the same size, and the function
% will preserve the variable class.
%
% IN
%   in       struct containing:
%               MANDITORY:
%                   Z/data         [data matrix]     of any class. size(data,1)
%                                                  must be the same length
%                                                  as lat lon, but data may
%                                                  have 2 dimensions or more, e.g.
%                                                  lvls, seasons, etc.
%
%                   X/lon          [lon matrix]      of any class
%                   Y/lat          [lat matrix]      of any class
%
%                 either:
%                   gridsize     [%f] or [%f %f]   scalar for square
%                                                       scaling. 2 values
%                                                       if you want to have
%                                                       separate lat,lon
%                                                       resolutions
%
%
%
%                             or
%                  newY/newlat        [lat vector]      bin into new lat grid
%                  newX/newlon        [lon vector]      bin into new lon grid
%
%              OPTIONAL
%                  region        [blcorner,trcorner] (lat1,lon1,lat2,lon2)
%
%
%
%          If region is given, the function will only bin the data within the
%          given region. Particularily useful if you have high resolution data
%          in a region. The default grid domain is assumed to be global
%          otherwise.
%
%  lonspace    %f     Optional for lat/lon data to indicate the desired longitude format
%                     lonspace = 360 for lon=0:360,
%                     lonspace = 180 for lon=-180:180
%                     lonspace = 0 do nothing (default)
%
%           If lonspace is not given, the function automatically picks a format
%           depending on if there are any longitude values larger than 180
%           (lon>180). This may be important if your input data does not cover both
%           hemispheres.
%
%  counts   %f (e.g. true=1)
%           Optional logical for if you only want the number of counts per bin, e.g. to see how
%           often a certain combination of X-Y happens (numel per box).
%
% Out:
%                   1) Z  ( cell (size(Y,X)) or counts) %data
%                   2) Y  ( vector )          %lat
%                   3) X  ( vector )          %lon
%
% USAGE: [Z,Y,X] = binning_fast(struct('data',data,'lat',lat,'lon',lon...
%                             'newlat',[-80+.5:80-.5],'newlon',[-180+.5:180-.5]))
%
%        or
%         [Z,Y,X] = binning_fast(struct('Z',data,'X',x,'Y',y,'newX',[1:10],'newX',[1:10]))
%
% NOTE:
%       1) Including newlon and newlat causes the function to ignore: in.gridsize
%                                                                    in.region
%                                                                    lonspace
%
%       2) A useful function to get statistics (e.g numel, mean, sum, etc) on
%       the binned data is binned_statistics.
%
% See also: bin, bin_nd, binned_statistics
%
% Created by Oliver Lemke and Salomon Eliasson
% $Id$

[in,lonlat] = check_input(in);

if nargin==1, lonspace=0;end
[in,Y,X] = outputlatlons(in,lonspace,lonlat);

if ~in.counts
    % data might be 2D or more e.g. levels,etc
    sz = size(in.Z);
    in.Z = in.Z(:,:); %collapse data
end

in = regionchop(in);

% setup new GRIDSIZE
d(1) = mean(diff(Y));
d(2) = mean(diff(X));

%% assign index value
Yindex = floor( (in.Y - (min(Y)-d(1)/2)) /d(1) ) + 1;
Xindex = floor( (in.X - (min(X)-d(2)/2)) /d(2) ) + 1;

% make sure Xindex and Yindex don't exceed maximum
Yindex(Yindex>length(Y))=length(Y);
Xindex(Xindex>length(X))=length(X);


%% GET COUNTS
Z = cell(length(Y), length(X));
counts = zeros (size(Z), 'uint32');
for i = 1:length(in.X)
    iY = Yindex(i);
    iX = Xindex(i);
    counts(iY, iX) = counts(iY, iX) + 1;
end

if in.counts
    % If you only want the counts you can leave now
    Z = counts;
    return
end

indata = in.Z;

%% PREALLOCATE DATA
for i = 1:size(counts,1)
    for j = 1:size(counts,2)
        Z{i, j} = zeros ([counts(i, j), sz(2:end)], class(indata));
    end
end

%% LOOP DATA
for i = 1:size(indata,1)
    iY = Yindex(i);
    iX = Xindex(i);
    Z{iY, iX}(counts(iY, iX),:) = indata(i,:);
    counts(iY, iX) = counts(iY, iX) - 1;
end
end
%% Subfunctions
% ||
% VV

function [in,lonlat] = check_input(in)

lonlat = all(isfield(in,{'lat','lon'}));
if ~isfield(in,'counts') % if you only want the counts
    in.counts = 0;
end

if lonlat
    in.X = in.lon;
    in.Y = in.lat;
    in = rmfield(in,{'lon','lat'});
    if ~in.counts
        in.Z = in.data;
        in = rmfield(in,'data');
    end
    if isfield(in,'newlon')
        in.newX = in.newlon;
        in.newY = in.newlat;
        in = rmfield(in,{'newlon','newlat'});
    end
end

errId = ['atmlab:' mfilename ':badInput'];
assert(all(isfield(in,{'Y','X','Z'})) || all(isfield(in,{'Y','X','counts'})),...
    errId,'''lat'',''lon'',''data'' (or ''X'',''Y'',''Z'') are required input fields')

assert(isfield(in,'gridsize') || all(isfield(in,{'newX','newY'})),...
    errId,'Either field ''gridsize'' or fields ''newY/newlat'' and ''newX/newlon'' are required' )

if ~in.counts
    if isequal(numel(in.Z),numel(in.Y),numel(in.X))
        in.Z = in.Z(:); in.Y = in.Y(:); in.X = in.X(:);
    end

    assert(isequal(size(in.X,1),size(in.Y,1),size(in.Z,1)),...
    errId, ['data,Y,X must all have the same first dimension. Found: ' ...
    'data %d, Y %d, X %d'], size(in.Z, 1), size(in.Y, 1), size(in.X, 1));
else
    if isequal(numel(in.Y),numel(in.X))
        in.Y = in.Y(:); in.X = in.X(:);
    end
    assert(isequal(size(in.X,1),size(in.Y,1)),...
    errId, ['data,Y,X must all have the same first dimension. Found: ' ...
    ' Y %d, X %d'], size(in.Y,1), size(in.X, 1));
end



if lonlat
    assert(~(any([in.newX(:)>360;in.newX(:)<-180;in.newY(:)>90;in.newY(:)<-90])),...
        errId,'lat/lon values are unphysical')
    
    if ~(max(diff(in.newY))-min(diff(in.newY))<1e-4 && ...
            max(diff(in.newX))-min(diff(in.newX))<1e-4)
        warning(['atmlab:' mfilename, ':WonkyNewgrid'],[...
            'vectors in fields: ''newY'' and ''newX'' are not monotonously spaced. ',...
            'The output grid will be monotonously spaced, ',...
            'based on mean(diff(newY)) and  mean(diff(newX))'])
    end
    if isfield(in,'gridsize')
        warning(errId,'fields ''newX'' and ''newY'' cancel ''gridsize''')
    end
    if isfield(in,'region')
        warning(errId,'Region specified by newY and newX has presedence over in.region\n')
    end
end

%internally span a region, so that values outside this region can be kicked out
% [blcorner,trcorner] (lt1,ln1,lt2,ln2). This should be safe for both
% centered and non-centered grids
dlt = mean(diff(in.newY))/2;  dln = mean(diff(in.newX))/2;
in.region = [min(in.newY)-dlt,min(in.newX)-dln,max(in.newY)+dlt,max(in.newX)+dln];

end
function in = regionchop(in)
% Get rid of all data outside of region

lt1 = in.Y > in.region(1);
ln1 = in.X > in.region(2);
lt2 = in.Y < in.region(3);
ln2 = in.X < in.region(4);

index = ln1 & ln2 & lt1 & lt2;

in.Y = in.Y(index);
in.X = in.X(index);

if ~in.counts
    in.Z = in.Z(index,:);
end

end
function [in,Y,X] = outputlatlons(in,lonspace,lonlat)
%% fix the latlons
% Sets up lat lon and adjusts in.X to the requested (if requested)
% longitude regime (0:360 or -180:180)
%
errId = ['atmlab:' mfilename ':badInput'];

if lonlat
    testmore = in.X>180; %logical for any lons > 180
    testless = in.X<0; %logical for any lons < 0
    
    if lonspace==360
        in.X(testless) = in.X(testless)+360;
        in.f360=true;
    elseif lonspace==180
        in.X(testmore) = in.X(testmore)-360;
        in.f360=false;
    elseif lonspace==0
        in.f360 = any(testmore(:));
    else
        error(errId,...
            'lonspace must be 180, 360 or 0 (default (do nothing))')
    end
    
    if in.f360 && ~isfield(in,'region')
        in.region = [-90 0 90 360];
    elseif ~in.f360 && ~isfield(in,'region')
        in.region = [-90 -180 90 180];
    end
end

if any(isfield(in,{'newX','newX'}))
    Y = in.newY;
    X = in.newX;
    if lonspace~=0
        warning(errId,'fields ''newY'' and ''newX'' make lonspace irrelevant')
    end
    return
end

d = in.gridsize;
assert(numel(d)<=2,errId,'''gridsize'' should contain 1 or 2 values')

if isscalar(d), d = [d,d]; end
assert(isnumeric(in.region),errId,'in.region must be a numeric vector of coordinates')

Y = in.region(1)+0.5*d(1):d(1):in.region(3)-0.5*d(1);
X = in.region(2)+0.5*d(2):d(2):in.region(4)-0.5*d(2);

end
