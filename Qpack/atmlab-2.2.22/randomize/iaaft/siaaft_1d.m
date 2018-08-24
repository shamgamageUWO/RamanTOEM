function [bestSurrogate, spectralDiffBest] = siaaft_loop_1d_experimental(fourierCoeff, sortedValues, counterThresshold, iterativeCounterAmplitude, iterativeDenomAmplitude, algorithmVersion)
% INPUT: 
% fourierCoeff:              The 1 dimensional Fourier coefficients that describe the
%                            structure and implicitely pass the size of the matrix.
% sortedValues:              A vector with all the wanted amplitudes (e.g. LWC of LWP
%                            values) sorted in acending order.
% counterThresshold:         The number of unsuccesful iterations before
%                            the algorithm stops.
% iterativeCounterAmplitude: The fraction of amplitude adaptations is give
%                            by iterativeCounterAmplitude/iterativeDenomAmplitude.
%                            For some algorithm versions 2/4 can be a bit
%                            different that 1/2. Please look in the code.
% iterativeDenomAmplitude:   See variable iterativeCounterAmplitude above.
% algorithmVersion:          There are 4 different algorithm versions. 
%                            1: Partially stochastic version (default)
%                            2: Deterministic version
%                            3: Fully stochastic version (where the exact
%                               fraction of amplitude adaptations is
%                               performed).
%                            4: Fully stochastic version (more efficient,
%                               but not exactly the right fraction of
%                               amplitude adaptations.
% 
% OUTPUT:
% bestSurrogate:    The 1D SIAAFT surrogate time series
% spectralDiffBest: The RMS difference between the specified Fourier
%                   spectrum (from the template) and the spectrum of the
%                   surrogate.

% input checking
if (nargin < 3)
    counterThresshold = 1e4; % Number of iterative steps with no approvement before the algorithm stops.
end
if (nargin < 5)
    iterativeCounterAmplitude = 1;
    iterativeDenomAmplitude   = 5;
end
if (nargin < 6)
    algorithmVersion = 1;
end

% Settings
verbose = 0;   % Boolean indicating whether to write to the command window or not.
makePlots = 0; % Best used together during debugging (together with verbose).

% Initialise function
noValues = length(fourierCoeff);
% amplitudeDiff = 1;
spectralDiff = 1;
spectralDiffBest = 100;
standardDeviation = std(sortedValues);
noAdaptedValues = floor(noValues*iterativeCounterAmplitude/iterativeDenomAmplitude);

indices = init_regular_indices(iterativeCounterAmplitude, iterativeDenomAmplitude, noValues);
noIndices = size(indices,2);

% Set limits for plots.
if makePlots
    xmin = 1;
    xmax = noValues;
    ymin = sortedValues(1);
    ymax = sortedValues(end);
end

% The method starts with a randomized uncorrelated surrogate time series
% with the amplitudes (PDF) of sorted_values.
[dummy,index] = sort(rand(size(sortedValues)));
surrogate(index) = sortedValues;

% Main intative loop
counter = 1; % Counts the number of iterations in every stage.
number = 1;  % The index to the vector to use from the matrix indices (for algorithmVersion 1 and 2).
% counterSpec = 1;
% maxCounter = 1e4;

for stageCounter=1:2
    if (stageCounter == 2)
        % In this second stage all amplitudes and coefficients are used
        % in the iteration, just like in the original iaaft algorithm.
        disp('Second stage')
        iterativeCounterAmplitude = iterativeDenomAmplitude;
        noAdaptedValues = noValues;        
        % use the best surrogate as the new one.
        surrogate = bestSurrogate;   % The best surrogate of the first phase is the starting surrogate of the second phase
        spectralDiffBest = 100;      % make the second phase use the old surrogate as its best one up to now.
        counter = 1;
        indices = (1:noValues)';     % use all indices, not just a fraction, in the second stage.
        noIndices = 1;
        number = 1;
        counterThresshold = 100; % In the second round with the IAAFT algorithm, it doesn't help to iterate after convergence has stopped.
    end
    
    bestCounter = 0; % This counter counts the number of iteration, and is set to zero each time a new better fitting surrogate is found.
    while ( bestCounter < counterThresshold )
        % addapt the power spectrum
        x=ifft(surrogate);
        phase = angle(x);
        difference = sqrt( mean( (abs(x)-abs(fourierCoeff)).^2  ) );
        spectralDiff = difference/standardDeviation;
% 	    spectralDiffg(counterSpec) = spectralDiff;
%         counterSpec = counterSpec + 1;

        % If the calculation of the power spectrum reveals that the
        % surrogate time series from the previous iteration with perfect
        % amplitudes had the best power spectrum up to now, save this
        % surrogate and its accuracy and reset bestCounter.
        if ( (spectralDiff < spectralDiffBest) & (counter > 1) )
            fprintf(1, 'SpectralDiffBest: %e, bestCounter:, %d\n', spectralDiff, bestCounter);
            spectralDiffBest  = spectralDiff;
%             amplitudeDiffBest = amplitudeDiff;
            bestSurrogate     = surrogate;
            bestCounter = 0;
%            phaseCounter;
        else
            bestCounter = bestCounter + 1;
        end
           
        x = fourierCoeff .* exp(i*phase);
        surrogate = fft(x);
	
        % Plot surrogate after spectral adaptation.
        if ( verbose ), spectralDiff, end        
        if ( makePlots )
            subplot(3,1,1);
            plot(real(surrogate))
            title('Surrogate after spectal adaptation')
            axis([xmin xmax ymin ymax])        
            drawnow
        end
            
        % Adapt the amplitude distribution
        [dummy, index] = sort(real(surrogate)); % We need only the indices. The first value of index points to the highest value, etc.
 
        switch algorithmVersion
            case 1
                % random selection of noIndices vectors with regularly ordered indices
                number = ceil(rand(1)*noIndices);
                surrogate(index(indices(:,number)))=sortedValues(indices(:,number));	                        
            case 2
                % deterministic selection of noIndices vectors with regularly ordered indices
                number = increment(number, 1, 1, noIndices);
                surrogate(index(indices(:,number)))=sortedValues(indices(:,number));	        
            case 3
                % Fully random indices, with exactly the right fraction of amplitude adaptations.
                if (iterativeCounterAmplitude == iterativeDenomAmplitude)
                    surrogate(index) = sortedValues;
                else
                    [dummy, indices] = sort(rand(size(surrogate)));
                    indices = indices(1:noAdaptedValues);
                    surrogate(index(indices))=sortedValues(indices);
                end
            case 4
                % Fully random indices, more efficient version of algorithmVersion 3.
                if (iterativeCounterAmplitude == iterativeDenomAmplitude)
                    surrogate(index) = sortedValues;
                else                
                    indices = ceil(rand(noAdaptedValues,1)*noValues);
                    surrogate(index(indices))=sortedValues(indices);
                end
        end
        
        % Plot surrogate after amplitude adaptation.        
        if ( verbose ), amplitudeDiff, end       
        if ( makePlots )
            subplot(3,1,2);
            plot(real(surrogate))
            title('Surrogate after amplitude adaptation')
            axis([xmin xmax ymin ymax])        
            drawnow
        end
      
        counter=counter+1;
%        bestCounter;
        drawnow % Allows escaping the while loop with ^c.
	end % while not conveged   
end % for the 2 stages.

surrogate = double(surrogate);
