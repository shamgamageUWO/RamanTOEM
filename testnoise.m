% This code is used to test the poisson noise in the synthetic measurements
% are correct or not.
% Idea here  sqrt(Count(11) = std(Counts(1: 21))
% example: if the value of the count at z= 1km is 100, sqrt of that point
% is 10. and the std of the counts from 0-2km should approximately be 10.
% Z=1km is like the point in the center and you can pick the altitude you
% want to choose to find std. 

%% Input : synthetic measurements and the altitude range (Note that you these measurements should have poisson noise added. For that you can use NoiseP.m code)
% Outout : figure of std and sqrt

% ***NOTE *** the x axix is in log scale just to see the difference of sqrt
% and std values clearly. you can change it if you want to. 

function testnoise(SynMes,alt)

% Find the sqrt of the synthetic measurements
SQ = sqrt(SynMes);
l= length(SynMes); % length of the vector

 n = [6]; % number of points considering for std calculation
% Note: n=2 means, we take the sqrt of 3rd count and std of first 5 counts.
m = length(n);


figure;

for j = 1:m
    for i = n(j)+1:l-n(j)
        StanD(i-n(j)) = std(SynMes(i-n(j):i+n(j)));
%         pause
    end
    
    alti = alt(n(j)+1:l-n(j));
    
    subplot(1,m,j)
    
%     plot(SQ(n(j)+1:l-n(j)),StanD,'b')
  plot(alti./1000,SQ(n(j)+1:l-n(j)),'b')
    hold on;
    plot(alti./1000,StanD,'r')
    
    xlabel('alt')
    ylabel('sigma')
    legend('Sqrt','STD')
    title({'number of points considered',n(j)});
    hold off; 
%     clear STD
end  

end

 