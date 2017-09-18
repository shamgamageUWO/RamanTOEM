function [VarA,go] =bobpoissontest(Counts,alt)
lzDA = length(Counts);
go = 12; %12; %24
stop = go-1;
% j = 0;
zCountsA = alt;
N2ctsA = Counts;
% WVctsD = X.yf(2*mchanA+1:2*mchanA+mchanD);
% N2ctsD = X.yf(2*mchanA+mchanD+1:end);

j = 0;
for i = go:lzDA-stop
    j = j + 1;
    [pp,spp,ppregress] = fitlinenp(zCountsA(i-stop:i+stop),N2ctsA(i-stop:i+stop));
    tmp = pp(1).*zCountsA(i-stop:i+stop) + pp(2);
    stdA(j) = std(N2ctsA(i-stop:i+stop) - tmp);
% xks1 = (N2ctsA(i-stop:i+stop) - mean(N2ctsA(i-stop:i+stop)))./stdA(i);
% h1(j) = kstest(xks1);
end

VarA =stdA.^2;

% figure
% semilogx(stdA.^2,zCountsA(go:lzDA-stop),Counts(go:lzDA-stop),alt(go:lzDA-stop),'r')
% legend('Variance', ' Counts')

% figure;
% plot((stdA.^2)./Counts,alt)

%ylim([0 zCounts(lzDA-stop)])