function out = resample_geodata(in,field,newgrid)
% RESAMPLE_GEODATA regrid the data to a new gridsize or fitting to new lat lons
%
% PURPOSE:  To resample GRIDDED data according a given gridsize or lat/lon
%           vectors. The data is regridded using matlabs INTERPOLATION
%           functions if the grid resolution should be FINER and the data
%           is RESAMPLED using area wieghting averages using a local plane
%           assumption if the grid resolution should be COARSER.
%
%
%
% IN:
%
%   in          struct      contains: lat,lon,field1,etc (maybe more fields)
%                           opt: interpolation = 'str'; default='linear'
%                                for interpolation method in interp2.
%
%   field       %s          {'field1',etc}; The field/s  you want to regrid
%
%   newgrid     %f, or [%f %f], {[newlat],[newlon]} (e.g. newlat = -90:5:90)
%
%              a) Either make a sqaure grid using a scalar %f. e.g 1deg ->
%                 2deg (Assumes centered data!)
%
%              b) or a 2 element vector [%f %f] means [latstep, lonstep]
%                 e.g. 1*1 -> 1.25*2.75 (Assumes centered data!)
%
%              c) or {[newlat],[newlon]} if you want to match to a predefined
%              lat lon grid. (Use this if your data is NOT centered)
%
% OUT:         struct       Original structure 'in' with lat, lon, and specified fields
%                           replaced with their regridded versions
%
%
% NOTE:     - Interpolation is linear, unless specified by in.interpolation.
%           - With a combination of conditions
%                 1) regridding to a very coarse resolution
%                 2) the finer grid resolution doesn't cleanly fit in the larger grid.
%             the local plane assumption will cause some errors, the remedy is
%             to include area weighting depending on latitude. This is 
%             yet to be implemented. 
%           - The input data and the newgrid (if full vectors) must be
%           equidegree (homogeneous spacing)
%           - If you use new grid = [latstep, lonstep], both have to be higher or lower
%           than the resolution of the input data, otherwise the
%           interpolation function is applied also to the coarser grid, but
%           this will throw a warning.
%
%         Important:  (but does not apply is you provide new lat lons in regrid{} )
%                   - It is assumed that the grid values are centered!!
%                   - For the interpolation/resampling it is always assumed
%                   that the whole world is in the data.
%
%
% USAGE:         out = resample_geodata(in,{'CC','HCC','MCC','LCC','P','T','Q'},3);
%         e.g.   out = resample_geodata(in,{'CC','HCC','MCC','LCC','P','T','Q'},[3,5]);
%                out = resample_geodata(in,{'CC','HCC','MCC','LCC','P','T','Q'},...
%                        {[ newlats ],[ newlons ]} );
%
%                1st example: Someone wants to resample 7 data fields
%                in one go to a 3x3 deg grid (the common lat lons are in the structure)
%                2nd example: Same as above but to a 3x5 deg grid
%                3rd example: Same as above but match the data to certain
%                             lat lons
%
% IMPORTANT: data fields must have the dimensions data(lat,lon,.....), or
%                                                 data(lon,lat,.....)
%
% Created by Salomon Eliasson
% $Id: regrid_dataset.m 6417 2011-04-21 06:44:37Z seliasson $

errID = ['atmlab:' mfilename ':badInput'];
assert(nargin==3,errID,'Incorrect number of input arguments')
if ~iscell(field), field={field}; end

% rename the structure so nothing is lost after this function
out = in;

% CHECK input
sz                                  = check_input(in,field,newgrid,errID);

% ASSEMBLE_newgrid
[newlat,newlon]                     = assemble_newgrid(in.lat,in.lon,newgrid,errID);

% STANDARDIZE "new grid" internally
[rg_flags,newlat,newlon]            = standardize_geodata(newlat,newlon);

% LEAVE function if nothing needs to be done
if isequal(in.lat(:),newlat(:)) && isequal(in.lon(:),newlon(:))
    warning(errID,['input grid is identical to requested new grid.\n'...
        'Leaving data untouched'])
    out = in; return
end

% CHECK WHICH test
out.method                          = which_test(in.lat,in.lon,newlat,newlon);

% PRINT to screen what is about to happen
if strcmp(out.method,'shift grid')
    logtext(1,'shifting the grid, keeping the same resolution\n')
else
    logtext(1,'Changing grid from %.3fx%.3f to %.3fx%.3f deg by method: %s\n',...
        mean(abs(diff(in.lat))),mean(abs(diff(in.lon))),...
        mean(diff(newlat)),mean(diff(newlon)),....
        out.method)
end

if ~strcmp(out.method,'interpolate') && isfield(in,'interpolation')
    warning(errID,'Will not interpolate, but instead use method: %s',out.method)
elseif strcmp(out.method,'interpolate')
    if isfield(in,'interpolation')
        intm = in.interpolation;
    else
        intm = 'linear';
    end
end

%% LOOP over FIELDS to regrid
for F = field
    fsz = size(in.(F{1}));

    % COLLAPSE data onto the 3rd dimesion
    data = in.(F{1})(:,:,:);
    
    % STANDARDIZE "input" data internally
    [flags,lat,lon,data]  = standardize_geodata(in.lat,in.lon,data);

    % CHECK for every field
    assert(isequal(fsz(1:2),sz(1:2)),...
        errID,'All input fields for processing don''t have matching lat lon dims')
   
    
    % USE appropriate METHOD
    switch out.method
        case 'interpolate'
            % successfully tested for 4D data and lon=0:360, lat = end:-1:1
            data = interpolate_grid(struct('lat',lat,'lon',lon,'data',data,'method',intm),newlat,newlon);
        case 'coarse grid'
            % successfully tested for 4D data and lon=0:360, lat = end:-1:1
            data = coarser_grid(struct('lat',lat,'lon',lon,'data',data),newlat,newlon);
        case 'coarse grid with area weighting'
            % successfully tested for 4D data and lon=0:360, lat = end:-1:1
            data = coarser_grid_withAreaweighting(struct('lat',lat,'lon',lon,'data',data),newlat,newlon);
        case 'shift grid'
            % successfully: regular, 4D, 
            data = interpolate_grid(struct('lat',lat,'lon',lon,'data',data,'method',intm),newlat,newlon);
        case 'interp and averaging'
            data = fine_and_coarse(struct('lat',lat,'lon',lon,'data',data),newlat,newlon,true);
        case 'averaging and iterp'
            data = fine_and_coarse(struct('lat',lat,'lon',lon,'data',data),newlat,newlon,false);
        otherwise
            error('atmlab:resample_geodata:Bug','Shouldn''t be here')
    end
    
    % REORDER data to original sorting order
    if flags.lat_descend
        data = data(end:-1:1,:,:);
    end
    if flags.lon_descend
        data = data(:,end:-1:1,:);
    end
    if rg_flags.lon360 % the picked newgrid decides...
        [~,lnindex] = sort(newlon+(newlon<0)*360);
        data = data(:,lnindex,:);
    end
    if flags.permute
        data = permute(data,[2,1,3]);
    end

    % RESHAPE data back to original format
    out.(F{1}) = reshape(data,[size(data,1),size(data,2),fsz(3:end)]);
end

out.lat = newlat;
out.lon = newlon;

% REORDER lat lons if need be
if rg_flags.lat_descend
    out.lat = out.lat(end:-1:1);
end
if rg_flags.lon_descend
    out.lon = out.lon(end:-1:1);
end
if rg_flags.lon360
    out.lon = sort(out.lon+(out.lon<0)*360);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUNFUNCTIONS bellow here
%
function sz = check_input(in,field,newgrid,errID)
%% CHECK_input assorted list of input checks

assert(isstruct(in) && ischar(field{1}) && ...
    (isnumeric(newgrid) || iscell(newgrid)),...
    errID,'Incorrect input argument types')

if iscell(newgrid)
    assert(~any([isempty(newgrid{1}),isempty(newgrid{2})]),...
        errID,'Lat or Lon vector is empty')
    
end

assert(~any(~isfield(in,{'lat','lon'})),errID,'"lat,lon" are required fields')
assert(all(ismember(field,fieldnames(in))),errID,'One or more of the specified data fields is missing');
assert(~isequal([size(in.(field{1}),1),size(in.(field{1}),2)],size(in.lat),size(in.lon)),...
    errID,'function only works on regular grids, i.e. data(lat,lon,...) or data(lon,lat,...)')
assert(max(diff(in.lat))-min(diff(in.lat))<0.1&&max(diff(in.lon))-min(diff(in.lon))<0.1,...
    errID,'The input data must be equidegree (constant spacing)')
assert( (isequal(in.lat,sort(in.lat)) || isequal(in.lat,sort(in.lat,'descend')) ) && ...
    (isequal(in.lon,sort(in.lon)) || isequal(in.lon,sort(in.lon,'descend')) ),...
    errID,'both lat & lon must be ascending or descending')
sz = size(in.(field{1}));
assert(isequal([length(in.lat),length(in.lon)],[sz(1),sz(2)]) || ...
    isequal([length(in.lat),length(in.lon)],[sz(2),sz(1)]),...
    errID, 'data must have the dimensions data(lat,lon,.....), or data(lon,lat,.....)');

if ~iscell(newgrid)
    assert(min(in.lat)>-90 & max(in.lat)<90 ,errID,'Latitudes are not centers')
    if min(in.lon)<0
        assert(~(all(ismember([-180,180],in.lon))),errID,'Longitudes are probably not centers')
    else
        assert(~(all(ismember([0,360],in.lon))),errID,'Longitudes are probably not centers')
    end
else
   assert(length(newgrid)==2,...
        errID,'if newgrid is a cell, it must contatin 2 vectors {[LATs] , [LONs]}')
    
end


function [newlat,newlon] = assemble_newgrid(LAT,LON,newgrid,errID)
%% ASSEMBLE_newgrid
% in:    LAT             orig latvector
%        LON             orig lonvector
%        newgrid         numeric or cell
%
% out:  newlat,newlon vectors to map to, and logical descn flagging is the
%       are in ascending order or not

if iscell(newgrid)
    % E.g. for mapping one dataset to anothers lat/lons
    newlat = newgrid{1};
    newlon = newgrid{2};
    assert(max(diff(newlat))-min(diff(newlat))<0.1&&max(diff(newlon))-min(diff(newlon))<0.1,...
        errID,'The input newgrid must be equidegree (constant spacing)')
    
else
    % make newlat newlon based on range given by in.lat,in.lon (centered)
    g=newgrid; if isscalar(g), g = [g,g]; end
    dn = mean(abs(diff(LON))); dt = mean(abs(diff(LAT)));
    
    % LATITUDES
    if min(LAT) == LAT(1)
        newlat = LAT(1)-dt/2+g(1)/2 : g(1) : LAT(end)+dt/2-g(1)/2;
        flt = newlat(end)~=LAT(end)+dt/2-g(1)/2;
    else
        newlat = LAT(1)+dt/2-g(1)/2 : -g(1) : LAT(end)-dt/2+g(1)/2;
        flt = newlat(end)~=LAT(end)-dt/2+g(1)/2;
    end
    
    % LONGITUDES
    if min(LON) == LON(1)
        newlon = LON(1)-dn/2+g(2)/2 : g(2) : LON(end)+dn/2-g(2)/2;
        fln = newlon(end)~=LON(end)+dn/2-g(2)/2;
    else
        newlon = LON(1)+dn/2-g(2)/2 : -g(2) : LON(end)-dn/2+g(2)/2;
        fln = newlon(end)~=LON(end)-dn/2+g(2)/2;
    end
    
    % do they FIT ?
    if flt
        warning(errID,['Requested latitude range does not fit into original latitude range\n',...
            'Suggest to give the latitude vector direcly in newgrid = {[lats][lons]}'])
    end
    if fln
        warning(errID,['Requested longitude range does not fit into original longitude range\n',...
            'Suggest to give the longitude vector direcly in newgrid = {[lats][lons]}'])
    end
end

function method = which_test(LAT,LON,newlat,newlon)
%% CHECK_WHICH_test_to_use
% IN:  lat lons of both grids to decide which method to use
% OUT: string name of the method to use

% first test is to see if the edges of the input grid match the edges of
% the new grid

eps = 1e-5; %this corresponds to 1 meter at the equator

% diff averages
dnlt = mean(diff(newlat));
dnln = mean(diff(newlon));
dlt  = mean(diff(LAT));
dln  = mean(diff(LON));

% temporay vectors
nltb   = newlat - dnlt/2;
nltt   = newlat + dnlt/2;
nlnb   = newlon - dnln/2;
nlnt   = newlon + dnln/2;
ltb    = LAT    - dlt/2;
ltt    = LAT    + dlt/2;
lnb    = LAT    - dln/2;
lnt    = LON    + dln/2;

% LOGICALS

%to a finer grid
cond1   = dlt > dnlt; %length(LAT) < length(newlat);
cond2   = dln > dnln; %length(LON) < length(newlon);

%to a coarser grid
cond3   = dlt < dnlt; %length(LAT) > length(newlat);
cond4   = dln < dnln; %length(LON) > length(newlon);

% same resolution
cond5   = abs(dlt-dnlt)<eps; %length(LAT) == length(newlat);
cond6   = abs(dln-dnln)<eps; %length(LON) == length(newlon);

% exact fit
onLatEdges = ismember(nltb(1),ltb) && ismember(nltt(end),ltt);
onLonEdges = ismember(nlnb(1),lnb) && ismember(nlnt(end),lnt);
fitlt      = dnlt/dlt == floor(dnlt/dlt);         %dnlt = n*dlt; n interger
fitln      = dnln/dln == floor(dnln/dln);         %dnln = n*dln; n interger

if (cond1 && ~cond4) || (cond2 && ~cond3)
    % to a FINER grid
    
    method = 'interpolate';
elseif (cond3 && ~cond2) || (cond4 && ~cond1)
    % to a COARSER grid

    if fitlt && fitln && onLatEdges && onLonEdges
    
        % fit together nicely, this is much faster
        method = 'coarse grid';
    else
        % overlapping gridboxes
        method = 'coarse grid with area weighting';
    end
elseif cond5 && cond6 
    % SAME resolution but DIFFERENT grid
    method = 'shift grid';
elseif cond1 && cond4
    % to a COMBINATION of both methods (INTERP & AVERAGING)
    method = 'interp and averaging';
elseif cond2 && cond3
    % to a COMBINATION of both methods (AVERAGING & INTERP)
    method = 'averaging and iterp';
else
    error('atmlab:resample_geodata:Bug','Shouldn''t be here')
end

function DATA = interpolate_grid(in,newlat,newlon)
%% INTERPOLATE_GRID interpolate data to a smaller grid.

% EXPAND the new lat lons so they encompass orig latlon
data = in.data;

LON=in.lon(:)';
LAT=in.lat(:)';
dn = mean(diff(LON));
dt = mean(diff(LAT));

while LON(1)>=newlon(1)
    LON = [LON(1)-dn,LON,LON(end)+dn];
    data = [data(:,end,:),data,data(:,1,:)];
end
while LAT(1)>=newlat(1)
    LAT = [LAT(1)-dt,LAT,LAT(end)+dt];
    data = [data(1,:,:);data;data(end,:,:)];
end

% do the INTERPOLATION
[X,Y] = meshgrid(LON,LAT);
[XI,YI] = meshgrid(newlon,newlat);
if islogical(data)
    DATA = false([length(newlat),length(newlon),size(data,3)]);
else
    DATA = zeros([length(newlat),length(newlon),size(data,3)],class(data));
end

fprintf('Using interpolation method: %s\n',in.method)
for i = 1:size(data,3)
    DATA(:,:,i) = interp2(X,Y,data(:,:,i),XI,YI,in.method);
end

function data = coarser_grid(in,lat,lon)
%% coarser_grid by averaging.
%
% Purpose: To make gridded data more sparse if the grids fit nicely into each other.
% NOTE: Biases may be introduced because I am using nanmean. The solution
%       is to also output the number of values used in the averaging for
%       each grid (not doing that right now. Add feature if needed)

% PUT lat/lons LAST and make lat lons both size(lat,lon)
tmpdata = permute(in.data,[3,1,2]); 
tmplon  = repmat(in.lon,length(in.lat),1);
tmplat  = repmat(in.lat,1,length(in.lon));

% COLLAPSE data (transposed), lat, lon to simulate UNGRIDDED data
tmpdata = binning_fast(struct('data',tmpdata(:,:)','lon',tmplon(:),'lat',tmplat(:),...
    'newlon',lon,'newlat',lat));

% TAKE the grid MEAN for each level (e.g. {[4x288]} -> {[1x288]}).
if any(isnan(tmpdata(:))), warning(['atmlab:' mfilename ':calculation'],...
        'There are NaNs in the data, and these may lead to biases on the coarser grid'); end
tmpdata = binned_statistics(tmpdata,{@nanmean});

if ndims(in.data)==2
    data = cell2mat(tmpdata.mean);
elseif ndims(in.data)==3
    % make into MATRIX(lat,lat,...)
    % this loop is because cell2mat doesn't work if cells contain vectors. It
    % doesn't work in conjuction with repmat, it just scrambled
    data = zeros(length(lat),length(lon),size(in.data,3));
    for i = 1:length(lat)
        for j = 1:length(lon)
            data(i,j,:) = tmpdata.mean{i,j};
        end
    end
end

function data = coarser_grid_withAreaweighting(in,lat,lon)
%% COARSER_GRID make a coarse grid from a finer grid
% method: Uses area weighting for grids that don't fit nicely into each
% other and assumes local plane assumption, which is good as long as the
% grids are not too large (see help resample_data).
% NOTE: Biases may be introduced because I am using nanmean. The solution
%       is to also output the number of values used in the averaging for
%       each grid (not doing that right now. Add feature if needed)


% preallocate
if ~islogical(in.data)
    data = zeros([length(lat),length(lon),size(in.data,3)],class(in.data));
else data = false([length(lat),length(lon),size(in.data,3)]);
end

polyWeightSum = @(d,w,i)(nansum(d(i).*w(i))./nansum(w(i)));

% DETERMINE new grid BOUNDARIES from grid spacing
gn = mean(diff(lon)); gt = mean(diff(lat));
dn = mean(diff(in.lon)); dt = mean(diff(in.lat));
if isnan(gt), gt = (in.lat(end)-in.lat(1) + dt);end %incase there's only one latitude
if isnan(gn), gn = (in.lon(end)-in.lon(1) + dn);end %incase there's only one longitude

lattop = lat+gt/2+dt;
latbot = lat-gt/2;
lontop = lon+gn/2+dn;
lonbot = lon-gn/2;

%LOOP over larger grid
for ii = 1:length(lat)
    for jj=1:length(lon)
        
        % GET lats lons in or tangent to grid(i,j)
        ilon = in.lon >= lonbot(jj) & in.lon < lontop(jj);
        ilat = in.lat >= latbot(ii) & in.lat < lattop(ii);
        
        % find WEIGHTS
        % A = [x,y,width,height] x,y = bottom corner
        A = [lonbot(jj),latbot(ii),gn,gt];
        [x,y] = meshgrid(in.lon(ilon)-dn/2,in.lat(ilat)-dt/2);
        B = [ x(:), y(:), repmat(dn,length(y(:)),1), repmat(dt,length(x(:)),1)];
        weights = rectint(A,B);

        % get data SUBSET
        d = in.data(ilat,ilon,:);
        
        % COLLAPSE data on the lat/lon dimensions to match output from rectint
        d = permute(d,[3,1,2]);
        
        for kk = 1:size(d,1)
            data(ii,jj,kk)    = polyWeightSum(d(kk,:),weights,~isnan(d(kk,:)));
        end
    end
end

function data = fine_and_coarse(in,newlat,newlon,method)

data = interpolate_grid(in,newlat,newlon);
warning('atmlab:resample_geodata:incomplete',...
    ['Using interpolation (interp2) for grids that are finer in one dimension '...
    'and coarser in the other. This is NO GOOD for the dimension that is coarser, '...
    'because of linear interpolation.'])
return

% Code to fix this problem incomplete below:

% %'interp and averaging' = true
% sz = size(in.data);
% if method
%     lp = [sz(2),sz(1)];
% else lp = [sz(1),sz(2)];
% end
% 
% % first INTERPOLATE
% if method
%     data = zeros(length(newlat),sz(2),sz(3),class(in.data));
% else data = zeros(sz(1),length(newlon),sz(3),class(in.data));
% end
% 
% for i = 1:lp(1)
%     if method
%         data(:,i,:) = interp1(in.lat,squeeze(in.data(:,i,:)),newlat,'linear','extrap');
%     else
%         data(i,:,:) = interp1(in.lon,squeeze(in.data(i,:,:)),newlon,'linear','extrap');
%     end
% end
% 
% % then COARSEGRID
% for i = 1:lp(2)
%     if method
%         data(i,:,:) = ;
%     else
%         %
%     end
% end