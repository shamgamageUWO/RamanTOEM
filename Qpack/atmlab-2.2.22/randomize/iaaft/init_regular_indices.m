function [indices] = init_regular_indices(counter, denom, noValues)
% This function returns a matrix with indices for use in the SIAAFT
% algorithm. These indices are to be used with a vector of length noValues.
% The number of indices is noValues*counter/denom, i.e. the fraction is
% counter/denom(inator).

noRep = ceil(noValues/denom);
lengthIndices = noRep*counter;
indices = zeros(lengthIndices, denom);
    
for di = 1:denom
	if ( counter+di-1 <= denom )
        baseIndices = (di:di+counter-1)';
	else
        baseIndices1 = di:denom;
        baseIndices2 = 1:di+counter-denom-1;
        baseIndices  = [baseIndices2 baseIndices1]';
	end

	for i=1:noRep
        bi = (i-1)*counter+1;
        ei = i*counter;
        indices(bi:ei, di) = baseIndices + (i-1)*denom;
	end
	
	ei = lengthIndices;
	while (indices(ei, di) > noValues )
        indices(ei, di) = indices(1, di);
        ei = ei - 1;
	end
end