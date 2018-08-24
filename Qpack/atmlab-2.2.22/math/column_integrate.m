function INT = column_integrate(in,field)
%% COLUMN_INTEGRATE
% Purpose: To column integrate any data. (e.g. IWC -> IWP). Assumes that missing
%          data is represented by negative numbers (or NaNs)
%
% IN: 1) in = structure containing all data fields
%     2) field = {'data','z'}; The first field is the data, the second is the
%     height (z) component (same size as the data). Z component can be either ascending or descending
%
% OUT: INT = column integrated in.(field{1})
%
% NOTE: The data and height fields must be the same size! e.g. you may need
% to use repmat on the height variable
%
% NOTE: See at the bottom of the file what the indexed loops look like when they
% are expanded. Indexing the loops is much more efficient. E.g. Indexing here is
% a factor 300 times faster (600s -> 2s for one day of CloudSat data)
%
% USAGE: IWP = column_integrate(in,{'RO_ice_water_content','Height'})
%
% $Id: column_integrate.m 8371 2013-04-23 15:42:12Z gerrit $
% Salomon Eliasson

D = field{1};
H = field{2};
assert(isequal(size(in.(D)),size(in.(H))),['atmlab:' mfilename ':badInput'],...
'data component in.%s is not the same size as the z-component in.%s',D,H)

logtext(atmlab('OUT'),'Column integrating in.%s over z-component: in.%s...\n',D,H)
if any(~strcmp('double',{class(in.(D)),class(in.(H))}))
    in.(D) = double(in.(D));
    in.(H) = double(in.(H));
end

%% Mask missing data (i.e., defined as less than zero) with NaNs
in.(D)(in.(D) < 0)=NaN;
in.(H)(in.(H) < 0)=NaN;

h = 1:size(in.(D),2)-1;
INT = nansum(abs((in.(H)(:,h)-in.(H)(:,h+1))).*(in.(D)(:,h)+in.(D)(:,h+1))/2,2)';


%% See below for expanded loops
% for i = 1:size(in.(D),1)
%     %% In the dimension along the swath/ day
%     for h = 1:size(in.(D),2)-1
%         %% z_2-z_1 * (m_2+m_1)/2
%         PROFILE(h) = (in.(H)(i, h) - in.(H)(i, h+1)) * ...
%             (in.(D)(i, h) + in.(D)(i, h+1)) / 2;
%     end
%     INT(i) = sum(PROFILE);
% end
