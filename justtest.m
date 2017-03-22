random_sample1 = poissrnd(10,1,2000);
SQ = sqrt(random_sample1);
l = 2000; % length of the data set
k = 20; % sample size 

for i = k+1:l-k
        StanD(i-k) = std(random_sample1(i-k:i+k));
%         pause
end

figure;plot(StanD,SQ(k+1:l-k))
mean(random_sample1)
var(random_sample1)