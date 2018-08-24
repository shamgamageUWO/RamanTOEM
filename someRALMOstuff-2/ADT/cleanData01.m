function [altv, mrv, errv] = cleanData01(altv, mrv, errv, maxalt, SmoothIt, SmoothPoints)
%
% Removes unrealistic data - modified on 5 March 2009
%
% altv      - alude vector [m]
% mrv       - mixing ratio vector [g/kg]
% errv      - relative error 
% maxalt    - altitude where to cut the data - use 12 km
% SmoothIt  - 0/1 binary - indicates to use smoothing by moving average or not
% SmoothPoits - how many points to use when smoothing - use 3 to 5

    mrv (mrv>25)    = NaN; errv(mrv>25)     = NaN; 
    mrv (mrv<1e-5)  = NaN; errv(mrv<1e-5)   = NaN;
    mrv (errv>0.5) = NaN; errv(errv>0.5)  = NaN;
    mrv (errv<=0)   = NaN; errv(errv<=0)    = NaN;
    
  
    if SmoothIt
        warning off
        try
            warning off
            mrv             = smooth(mrv ,SmoothPoints,'moving');
            errv            = smooth(errv,SmoothPoints,'moving');
            warning on
        catch
            rethrow(lasterror);
        end
        mrv (mrv>25)    = NaN; errv(mrv>25)    = NaN;
        mrv (mrv<=1e-5) = NaN; errv(mrv<=1e-5) = NaN; 
        mrv (errv>0.25) = NaN; errv(errv>0.25)  = NaN;
        mrv (errv<=0)   = NaN; errv(errv<=0)   = NaN;
    end
    
    %Clips the data up to 12 km - modified on 5 March 2009
    altv    = altv(altv<=maxalt);
    mrv     = mrv (altv<=maxalt);
    errv    = errv(altv<=maxalt);
    %Makes both colums to have NaN if only one has initially
    mrv (isnan(mrv) | isnan(errv)) = NaN;
    errv(isnan(mrv) | isnan(errv)) = NaN;
    %Finds first/second NaN and cuts to it
    secondNaNindex = find(isnan(mrv),2,'first');
    if isempty(secondNaNindex)
        secondNaNindex = length(altv);
    end
    altv    = altv(1:secondNaNindex);
    mrv     = mrv (1:secondNaNindex);
    errv    = errv(1:secondNaNindex);    
    
end

% On 05 May 2009 row 12 changed max allowed error from 0.5 to 0.11
% On 09 Oct 2009 changed to clean data with error worser then 25 % (instead 11%)
 