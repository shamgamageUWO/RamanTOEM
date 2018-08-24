function y=nanmean(x,d)

if nargin==1
    d=1;
end

[m,n]=size(x);

if d==1
    for i=1:n
        y(i) = mean(x(~isnan(x(:,i)),i));
    end
elseif d==2
    for i=1:m
        y(i,1) = mean(x(i,~isnan(x(i,:))));
    end
end