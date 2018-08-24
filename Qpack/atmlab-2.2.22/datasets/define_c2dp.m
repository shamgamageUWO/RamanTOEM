function define_c2dp(tp)
% Define CloudSat-2D-POES collapsed dataset

D = datasets();
if isequal(tp, 'amsub')
    core = D.CollocatedDataset_amsub_cpr;
    add = D.associated_CPR_AMSUB_AMSUA_HIRS;
else
    core = D.CollocatedDataset_mhs_cpr;
    add = D.associated_CPR_MHS_AMSU_HIRS;
end

global_lims = {@(X)(select_closest(X, core.cols, 15))};
c2d.LINE2.processors.RANGE = @(x)(vec2row(x([1 end])));
c2d.LINE2.incore = true;
c2d.LINE2.dims = {'NO_CS', 2};
c2d.LINE2.stored.RANGE.type = 'int'; % CS-granule 37081, too large for 'short'
c2d.LINE2.stored.RANGE.atts.long_name = 'CloudSat profile range 15 closest within granule';
c2d.LINE2.stored.RANGE.atts.valid_range = [1 40000];
c2d.DIST.processors.MIN = @(x)min(x);
c2d.DIST.processors.MAX = @(x)max(x);
c2d.DIST.incore = true;
c2d.DIST.stored.MIN.type = 'float';
c2d.DIST.stored.MIN.atts.long_name = 'Distance closest CloudSat profile to AMSU-B/MHS centerpoint';
c2d.DIST.stored.MIN.atts.units = 'km';
c2d.DIST.stored.MIN.atts.valid_range = [0 15.02];
c2d.DIST.stored.MAX.type = 'float';
c2d.DIST.stored.MAX.atts.long_name = 'Distance furthest CloudSat profile to AMSU-B/MHS centerpoint';
c2d.DIST.stored.MAX.atts.units = 'km';
c2d.DIST.stored.MAX.atts.valid_range = [0 15.02];
c2d.INT.incore = true;
c2d.INT.processors.MIN = @(x)min(abs(x));
c2d.INT.stored.MIN.type = 'short'; % [-900, 900]
c2d.INT.stored.MIN.atts.long_name = 'Shortest time-interval CloudSat AMSU-B/MHS';
c2d.INT.stored.MIN.atts.units = 'seconds';
c2d.INT.stored.MIN.atts.valid_range = [0 900];
c2d.INT.processors.MAX = @(x)max(abs(x));
c2d.INT.stored.MAX.type = 'short';
c2d.INT.stored.MAX.atts.long_name = 'Longest time-interval CloudSat AMSU-B/MHS';
c2d.INT.stored.MAX.atts.units = 'seconds';
c2d.INT.stored.MAX.atts.valid_range = [0 900];
Collapser(add, c2d, global_lims, ...
    'name', ['c2dp_' tp]);


end

function III = select_closest(M, cols, N)
% get logical with N closest collocs in M, described by cols
M = M(:, cols.DIST);
[~, I] = sort(M);
II = sort(I(1:min(N, length(M))));
III = false(size(M));
III(II) = true;
end

% function y = range_from_sel(x, n, filler)
% % ensure x is at least length n, fill rest with filler
% y = filler * ones(1, n);
% y(1:length(x)) = x;
% end
