function x_ave=BinAverage(x,Nbin)

% Bin averaging 
% Works with fixed vertical scale
% Averages over defined bins by Nbin
% x         - input signal to be bin averaged 
% Nbin      - number bins to averge over

x1=1;x2=1;
i=1;
x_ave    = NaN( size(x) ); % initialization matrix

while x2<(length(x))
    x2=x1+Nbin;
    if x2 <= length(x)
        x_ave(i,:)   =   mean( x(x1:x2,:),1 );
    end
    x1=x2+1;
    i=i+1;
end

x_ave = x_ave(1:i-2,:); % clean rested NaN rows form the initialization 

% while x2<(length(x)),
%     x2=x1+Nbin-1;
%     if x2 <= length(x)
%         x_ave(i,1)   =   mean( x(x1:x2) );
%     else
%         x_ave(i,1)   =   mean( x(x1:end) );
%     end
%     x1=x2+1;
%     i=i+1;
% end