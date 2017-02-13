function ct = NoiseP(ctrue)
%
%function ct = NoiseP(ctrue)
%add poisson noise to counts

for i = 1:length(ctrue)
   ct(i) = PoissonDeviate(ctrue(i),1);
end

return
