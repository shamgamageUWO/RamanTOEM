function [dOVJH,dOVJL,dOVJHa,dOVJLa] = deriCountsOVwv(j,Q,x,forwardmodelTraman)


 m = length(Q.Zret);
% N = 2*m+6 ;


    [y_JL,y_JH,y_JLa,y_JHa,y_WV,y_N2,y_WVa,y_N2a]=forwardmodelTraman(Q,x);

    if ~isempty(find(isnan(x)) == 1)
        'after FM: Nans in retrieval vector derivCounts'
        stop
    end

    dn = x(3*m+12+j).*1e-12; % this can go anything smaller than 0.1 even for higher temperatures works ok
    xpert = x;
    if x(j) == 0 % trap for tau's where tau(1) = 0
        dn = 1.e-12 .* x(3*m+12+j+1);
    end
    xpert(3*m+12+j) = x(3*m+12+j) + dn;
%     Xpert= [xpert x(end-2) x(end-1) x(end)];

    [y_JL_dT,y_JH_dT,y_JLa_dT,y_JHa_dT,y_WV_dT,y_N2_dT,y_WVa_dT,y_N2a_dT]=forwardmodelTraman(Q,xpert);

    dOVJL = (y_WV_dT - y_WV)./dn;
    dOVJH = (y_N2_dT - y_N2)./dn;
    dOVJLa = (y_WVa_dT - y_WVa)./dn;
    dOVJHa = (y_N2a_dT - y_N2a)./dn;
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