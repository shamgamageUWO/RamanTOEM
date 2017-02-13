%
% function [deviate] = SLS_PoissonDeviate(distMean, numReqd)
%
% calculates deviates (random numbers) selected from a parent Poisson
% distribution with a mean of 0 and a variance of 1.
%
% INPUTS: distMean : the mean of the parent Poisson distribution
%         NumReqd : the number of random deviates required
%
% OUTPUT: deviates: a vector containing the num_required deviates.
%
%
% This program is based on function poidev on page 294 of Numerical Recipes
% in C, W.H. Press et al., Cambridge University Press, 1992
%
% The function has been modified to take advantage of the speed of matrix
% calculations in Matlab, however the calculation of the deviates is
% mathematically identical to that presented in the above text.
%
%
% P.S. Argall
% Oct 27, 2004
%
function [deviates] = PoissonDeviate(distMean, numReqd)
 
% if the distribution mean is less than 12 use direct method otherwise use
% rejection method
if distMean < 12
    g = exp(-distMean);
    deviates = -1*ones(1,numReqd);
    t = ones(size(deviates));
    while max(t) > g
        index = find(t > g);
        deviates(index) = deviates(index) + 1;
        t(index) = t(index) .* rand(1,length(index));
    end
else 
    %distribution mean is greater than 12 so use the rejection method as it
    %is quicker.

    sq = sqrt(2 * distMean);
    aLogMean = log(distMean);
    g = distMean * aLogMean - gammln(distMean + 1);
    for loop = 1:numReqd
        t = -6;
        while rand(1) > t
            em = -6;
            while em < 0
                y = tan(pi * rand);
                em = sq * y +distMean;
            end
            em = floor(em);
            t = 0.9*(1+y*y)*exp(em*aLogMean-gammln(em+1)-g);
        end
        deviates(loop) = em;
    end
end
return
 
 
%
% function result = gammln(xx)
%
% calculates the natural logarithm of the gamma function
%
% INPUTS: xx : value at which the ln of the gamma function is to be
%               calculated
%
% OUTPUT: result ln of gamma function evaluated at xx
%
% This program is based on function poidev on page 214 of Numerical Recipes
% in C, W.H. Press et al., Cambridge University Press, 1992
%
function result = gammln(xx)
cof = [76.18009172947146, -86.50532032941677, 24.01409824083091,...
       -1.231739572450155, 1.208650973866179e-3, -5.395239384953e-6];
y = xx; x=xx;
tmp = x + 5.5;
tmp = tmp - (x+0.5) * log(tmp);
ser = 1.000000000190015;
for j=1:6
    y = y + 1;
    ser=ser + cof(j)/y;
end
result = -tmp+log(2.5066282746310005*ser/x);
return
