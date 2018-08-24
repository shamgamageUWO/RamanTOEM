function S0 = CloudFilter(S0)
%%
% select channel
channel = 9;

% filter width in m
dz = 30;

% degree of polinomial
K = 3;

% filter width in bins
F = round(dz / S0.Channel(channel).BinSize);

% make odd
if mod(F,2)==0
    F = F+1;
end

% build second derivative
[B G] = sgolay(K,F);
%%
% loop over each signal
disp('detecting clouds ...')
for i=1:length(S0.Channel(channel).Time)
    
    % write to new vector
    x = S0.Channel(channel).Signal(:,i);
    z = S0.Channel(channel).Range;
    
    % preallocate vectors
    [xf y yy]=deal(nan(size(x)));
    
%     % calculate smoothed signal of x
%     P = 0;
%     for k=F:length(x)-F
%         
%         xf(k) = factorial(P)*G(:,P+1)'*x(k-floor(F/2):k+floor(F/2));
%         
%     end
    
    % calculate first derivative of x
    P = 1;
    for k=F:length(x)-F
        
        y(k) = factorial(P)*G(:,P+1)'*x(k-floor(F/2):k+floor(F/2));
        
    end
    
%     % calculate second derivative of x
%     P = 2;
%     for k=F:length(x)-F
%         
%         yy(k) = factorial(P)*G(:,P+1)'*x(k-floor(F/2):k+floor(F/2));
%         
%     end
    
    % find peaks in y with a value higher than 0.05
    ind = find(y(3:end)-y(2:end-1)<0 & y(1:end-2)-y(2:end-1)<0 & y(2:end-1)>0.05)+1;
    
    % write results to S0 structure
    S0.CloudBase(i).z = z(ind);
    
    
%     clf
%     
%     subplot(3,1,1)
%     plot(z,x)
%     hold on
%     plot(z,xf,'r')
%     plot(z(ind),xf(ind),'ro')
%     grid on
%     xlim([0 15000])
%     
%     subplot(3,1,2)
%     plot(z,y)
%     hold on
%     plot(z(ind),y(ind),'ro')
%     grid on
%     xlim([0 15000])
%     
%     subplot(3,1,3)
%     plot(z,yy)
%     hold on
%     plot(z(ind),yy(ind),'ro')
%     grid on
%     xlim([0 15000])
%     
%     input('continue')
    
end
%%