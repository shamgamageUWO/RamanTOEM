function result = FileAverage02(sig, Nfile)
% File average ver.2
% result = FileAverage02(sig, Nfile , mode)
% Averages over number columns of a matrix. Uses for loop for big matrices
% Works with 'sig' matrix: rows - bins, columns - files
% Nfile - defines the number columns to average over
%       - Nfile = -1 then averages all availiable input columns
%  
% 'result' matrix
% Nfile = 5;
% sig   = s_ave; % the signal 

n_  = ceil(size(sig,2)/Nfile); 
result = NaN( size(sig,1), n_);

for ind = 1:n_
    in = (ind-1)*Nfile+1;
    fi = ind*Nfile;
    if fi > size(sig,2)
        result(:,ind)   =   nanmean( sig(:,in:end),2 );
    else
        result(:,ind)   =   nanmean( sig(:,in:fi),2 );
    end
end
end