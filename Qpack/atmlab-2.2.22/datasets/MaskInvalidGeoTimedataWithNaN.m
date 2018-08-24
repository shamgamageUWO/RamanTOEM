function S = MaskInvalidGeoTimedataWithNaN(S)
% MaskInvalidGeoTimedataWithNaN Mask invalid geodata and time data with NaN
% Purpose: To remove invalid data that can't be used by the collocation
% codes anyway.
%
% NOTE: This is an interal function to many of the satreaders.<dataset>.m
%       This means that the input data is assumed to follow the
%       conventions set up in the collocatio toolbox (fields must be called
%       'lat','lon','time'), i.e. -180<=lon<=180,  -90<=lat<=90,
%       0<=time.
%
%
% IN
%     S         struct                  output structure from
%                                       satreaders.<datasets>
%
% OUT
%     S         struct                  Same structure, but filtered
%
% USAGE: S = removeInvalidGeoTimedata(S)

% $Id: MaskInvalidGeoTimedataWithNaN.m 8541 2013-07-18 22:11:52Z gerrit $
% Salomon Eliasson

errId = ['atmlab:' mfilename ':badInput'];
if isempty(S.lat)
    warning(errId,'Data struct is empty')
    return
end
assert(isequal(size(S.lat),size(S.lon)),errId,'S.lat, and S.lon must be the same size')
assert(isequal([size(S.lat,1),1],size(S.time)),errId,...
    'S.time must be a vector of the same length as the geodata')

ltindex = S.lat >= -90 & S.lat <= 90;
lnindex = S.lon >= -180 & S.lon <= 180;
tindex  = S.time >= 0;

index = ltindex & lnindex;

if any(~(index(:))) || any(~tindex)
    if logical(sum(~index(:)))
        logtext(atmlab('OUT'),...
            'Flagging %d data values (%.2f%%) due to invalid (lat, lon, or time) \n',...
            sum(~index(:)),100*sum(~index(:))/length(index(:)))
    end
    %for F = fieldnames(S)'
    for F = {'time','lat','lon'} % I can't be garanteed that the data is atleast single (to fit NaN)
        if strcmp(F{1},'time')
            S.time(~tindex)     = NaN;
            continue
        end
        if isequal(size(S.(F{1}),1),size(index,1))
            S.(F{1})(~index)    = NaN;
            S.(F{1})(~tindex,:) = NaN;
        end
    end
    
end

end
