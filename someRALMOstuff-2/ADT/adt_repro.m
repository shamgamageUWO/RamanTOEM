function adt_repro

%%  configuration
config=setup('adt_gim.conf');

%% loop

for i=1:length(config.t)
    
    try
        config.t0=config.t(i);
        adt(config);
    catch me
        warning(sprintf('error when treating %s: %s',datestr(config.t(i),'yyyy-mm-dd HH:MM:SS'),me.message));
    end
    
end