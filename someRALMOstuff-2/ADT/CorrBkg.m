function signal = CorrBkg(signal, bkg_bins, usemedian, matrixmethod)
% Corrects for background
% signal = CorrBkg(signal, bkg_bins, usemedian, matrixmethod)
% works with matrix, where columns are files, rows are bins
%   bkg_bins      - bins from the end to average for bkg estimate
%   usemedian     - 1 to use median (50% percentile) instead of mean - PC signal
%   matrix method - 1 to use matices, 0 to use for loop - good for big data 

if ~isnan(signal)
    if matrixmethod
        if usemedian
            bkg = median(signal(end-bkg_bins:end,:));   % estimates the background - from each column
        else
            bkg = mean  (signal(end-bkg_bins:end,:));
        end
        bkgmat      = repmat(bkg,length(signal),1);   %creates put bkg from each column in vector with equal values - the bkg
        signal      = signal-bkgmat;
    else
        for col = 1:size(signal,2),
            if usemedian
                bkg = nanmedian( signal( (end - bkg_bins):end, col) );
            else
                bkg = nanmean  ( signal((end - bkg_bins):end, col) );
            end
            signal(:,col) = signal(:,col) - bkg;
        end
        
    end
else
    
end
end