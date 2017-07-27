    function [dDTJH,dDTJL] = deriCountsDT(Q,x,forwardmodelTraman)

    [y_JL,y_JH,A_Zi,B_Zi,Diff_JL_i,Diff_JH_i]=forwardmodelTraman(Q,x);

    if ~isempty(find(isnan(x)) == 1)
        'after FM: Nans in retrieval vector derivCounts'
        stop
    end
    
dn = 1e-10 .* x(end);
xpert = x;
xpert(end) = x(end) + dn;

    [y_JL_dT,y_JH_dT,A_Zi,B_Zi,Diff_JL_i,Diff_JH_i]=forwardmodelTraman(Q,xpert);

    dDTJL = (y_JL_dT - y_JL)./dn;
    dDTJH = (y_JH_dT - y_JH)./dn;

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