classdef CollocationRetrievalDatabaseProduct < handle
    properties (Abstract)
        dbname;
        date1;
        date2;
        sat1;
        sat2;
        fields;
        collocation_limits;
        collocation_filters;
    end
    methods
        function getdata(self, varargin)
            D = datasets();
            [self.data, self.localcols] = D.(self.dbname).read(self.date1, self.date2, ...
                {self.sat1, self.sat2}, ...
                self.fields, ...
                self.collocation_limits, ...
                self.collocation_filters);
%             N = size(self.data, 2);
%             [dat, I] = sortrows(self.data, self.localcols.TIME1);
%             [ye, mo, da, ho, mi, se] = unixsecs2date(dat(:, self.localcols.TIME1));
%             cf = D.CFSR;
%             S = cached_evaluation(@cf.read_from_grid, dat(:, self.localcols.LAT1), dat(:, self.localcols.LON1), [ye, mo, da, ho, mi, se], {'TMP_L1'});
%             self.data(I, N+1) = S.TMP_L1;
%             self.localcols.CFSR_Skin_temperature = N+1;
        end
    end
end
