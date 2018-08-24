function S = dardarsub(file, varargin)
% read dardarsub data
%
% format as other satreaders.-functions.
% For info on the common format, see <a href="matlab:help SatDataset/reader">SatDataset/reader</a>.
%
% NOTE: This function only reads the sub selected data saved as netcdf
% on our servers. For regular DARDAR data use satreaders.dardar
%
% $Id: dardarsub.m 8720 2013-10-21 20:41:39Z gerrit $
% Salomon Eliasson

core_fields   = {'time','lat','lon'};
extra_fields  = optargs(varargin, {{}});
all_fields    = [core_fields(:); extra_fields(:)];

% HEIGHT
% If height is needed, generate it separately since it is not in datafile
if ismember('HEIGHT',all_fields)
    wantH=true; all_fields = all_fields(~ismember(all_fields,'HEIGHT'));
else wantH=false;
end

[S,~,attr] = loadncvar(file, all_fields );

% -----------
% Add offsets and scale the data if this is provided
for F = fieldnames(S)'
    if isfield(attr.(F{1}),'scale_factor')
        S.(F{1}) = (S.(F{1})*double(attr.(F{1}).scale_factor))+ ...
            double(attr.(F{1}).add_offset);
    end
end

D = datasets;
if wantH
    S.HEIGHT = D.dardarsub.metadata.height;
end


% get additional stuff
info = D.dardarsub.find_info_from_granule(file);

date = dayofyear_inverse(str2double(info.year), str2double(info.doy));
S.epoch = round(date2unixsecs(date.year, date.month, date.day));


S.path = file;
S.version = info.version;

if isfield(S,'height')
    logtext(1,'Saving memory: extracting height vector from repetitive height matrix...\n')
    S.height = S.height(:,1);
end

S = MaskInvalidGeoTimedataWithNaN(S);
end
