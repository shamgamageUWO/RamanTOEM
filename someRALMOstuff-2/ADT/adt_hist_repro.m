function adt_hist_repro

%%  configuration
config=setup('adt_hist.conf');

%% loop

for i=1:length(config.t)
    
    try
        config.t0=config.t(i);
        adt_hist(config);
    catch
        disp(sprintf('unknown error at %s',datestr(config.t(i),'yyyy-mm-dd HH:MM:SS')));
    end
    
end