function [d, attr] = read_clavrx_hdf(hdfFile, sdsName)
% READ_CLAVRX_HDF Generic reader for CLAVR-x HDF data.
%
% D = read_clavrx_hdf(HDFFILE, SDSNAME) reads in data from an SDS array
% named SDSNAME in an HDF file HDFFILE.
%
% [D, ATTR] = read_clavrx_hdf(HDFFILE, SDSNAME) stores SDSNAME's attributes
% into ATTR as a struct array.
%
% When SDSNAME is a cell array of strings, D and ATTR become struct
% variables, whose field names are elements of the SDSNAME cell array.
%
% Missing elements in the HDF data are replaced with NaNs. Replacement of
% NaNs with original values for missing data can be achieved by using
% attributes stored in ATTR for that SDS variable.
%
% Example:
%
% >> [d, attr] = read_clavrx_hdf( ...
%     'NSS.GHRR.NJ.D98195.S1931.E2125.B1823335.GC.obs.hdf', ...
%     {'ch1_reflectance', 'ch2_reflectance'});
%
% >> d
% d = 
%
%   ch1_reflectance: [13724x409 double]
%   ch2_reflectance: [13724x409 double]
%
% >> attr
% attr = 
%
%   ch1_reflectance: [1x12 struct]
%   ch2_reflectance: [1x12 struct]

% LAST MODIFICATION: "$Id: read_clavrx_hdf.m 6482 2011-05-06 05:27:46Z seliasson $"
% Author: Aleksandar Jelenak <Aleksandar.Jelenak@noaa.gov>

% Error checking.
error(nargchk(2, 2, nargin));
error(nargoutchk(1, 2, nargout));

if ~(iscellstr(sdsName) || (ischar(sdsName) && (size(sdsName, 1) == 1)))
   error('Input argument SDSNAME must be a cell array of strings or a string!');
end

% Query the contents of the HDF file.
s = hdfinfo(hdfFile);

% Turn sdsName into a column vector of cell strings.
if iscellstr(sdsName)
   sdsName = sdsName(:);
else
   sdsName = cellstr(sdsName);
end

oneSds = length(sdsName) == 1;

% Start looping over elements of sdsName.
for i=1:length(sdsName)

   % Look for the SDS var using user-supplied name.
   sdsIdx = strmatch(sdsName{i}, {s.SDS(:).Name}, 'exact');
   if isempty(sdsIdx)
      error('SDS variable "%s" not found in "%s"!', sdsName{i}, hdfFile);
   end

   % Read in the data.
   x = double(hdfread(s.SDS(sdsIdx)));

   % Unscale it, if needed.
   scaled = read_clavrx_hdf_read_attr(s.SDS(sdsIdx), 'SCALED');
   if scaled
      sclMiss = double(read_clavrx_hdf_read_attr(s.SDS(sdsIdx), 'SCALED_MISSING'));
      % miss = double(read_clavrx_hdf_read_attr(s.SDS(sdsIdx), 'MISSING'));
      sclMin = double(read_clavrx_hdf_read_attr(s.SDS(sdsIdx), 'SCALED_MIN'));
      sclMax = double(read_clavrx_hdf_read_attr(s.SDS(sdsIdx), 'SCALED_MAX'));
      rngMin = double(read_clavrx_hdf_read_attr(s.SDS(sdsIdx), 'RANGE_MIN'));
      rngMax = double(read_clavrx_hdf_read_attr(s.SDS(sdsIdx), 'RANGE_MAX'));

      % Find all SCALED_MISSING elements.
      %sclMissIdx = find(x == sclMiss);
      sclMissIdx = x == sclMiss; % salomon
      
      % Unscale the data.
      if scaled == 1
         x = (rngMax-rngMin)/(sclMax-sclMin)*(x-sclMin)+rngMin;
      elseif scaled == 2
         x = 10.^x;
      else
         error('SDS "%s" has unsupported scaling type: %d', sdsName{i}, scaled);
      end

      % Set the missing elements.
      x(sclMissIdx) = NaN;
   end

   if oneSds
      d = x;
   else
      d.(sdsName{i}) = x;
   end
   clear x;

   % Return SDS attributes if the user has supplied a second output variable.
   if nargout == 2
      if oneSds
         attr = s.SDS(sdsIdx).Attributes;
      else
         attr.(sdsName{i}) = s.SDS(sdsIdx).Attributes;
      end
   end

end

return

%
% Internal function
%
function val = read_clavrx_hdf_read_attr(s, attrName)

attrIdx = strmatch(attrName, {s.Attributes(:).Name}, 'exact');
if isempty(attrIdx)
   warning('clavrx:badinput','read''Attribute "%s" for SDS variable "%s" not found!', attrName, s.Name);
   val = NaN;
else
   val = s.Attributes(attrIdx).Value;
end

return
