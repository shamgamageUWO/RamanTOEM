function [dJHdc,dJLdc] = deriC(Q,x,forwardmodelTraman)
m = length(Q.Zret);
CJL = x(m+3);
% DT_JL = x(end); % deadtimes
% N = 2*m+6 ;


    [y_JL,y_JH]=forwardmodelTraman(Q,x);

    if ~isempty(find(isnan(x)) == 1)
        'after FM: Nans in retrieval vector derivCounts'
        stop
    end
%     m=length(Q.Zret);
%     xa=x(1:m);
    dn = CJL.*1e-4;
%     dn2 = DT_JL.*1e-4;
    % this can go anything smaller than 0.1 even for higher temperatures works ok
    xpert = x;

    xpert(m+3) = CJL + dn;
%     xpert(end) =  DT_JL + dn2;
%     Xpert= [xpert x(end-2) x(end-1) x(end)];

    [y_JL_dT,y_JH_dT]=forwardmodelTraman(Q,xpert);

    dJHdc= (y_JH_dT - y_JH)./dn;
    dJLdc =(y_JL_dT - y_JL)./dn;
   
   
    return


% function [dSlodx,dShidx] = derivCounts(Q,x,j,theFM)
% % derivative of forward model with respect to temperature
% 
% [SH, SN] = theFM(Q,x);
% 
% if ~isempty(find(isnan(x)) == 1)
%     'after FM: Nans in retrieval vector derivCounts'
%     stop
% end
% 
% dn = 1.e-4 .* x(j); % 1e-5
% xpert = x;
% if x(j) == 0 % trap for tau's where tau(1) = 0
%     dn = 1.e-4 .* x(j+1);
% end
% xpert(j) = x(j) + dn;
% 
% [SHj, SNj] = theFM(Q,xpert);
% 
% dSlodx = (SHj - SH) ./ dn;
% dShidx = (SNj - SN) ./ dn;
% 
% return