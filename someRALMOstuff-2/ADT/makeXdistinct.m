% 
% [x ind]=makeXdistinct(x)
% 
function [x ind]=makeXdistinct(x)

% remove nan's
nind=find(isnan(x)==0);

% sort the vector
[x sind]=sort(x(nind));

% find indices of distinct neighbours
ind=find(diff(x)~=0);

% add the last element
[i j]=size(ind);
if i>j
    ind=[ind; length(x)];
else
    ind=[ind length(x)];
end

% create the new x and the indices
x=x(ind);
ind=nind(sind(ind));    