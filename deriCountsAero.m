    function [dJH,dJL,dJHa,dJLa,dWV,dN2,dWVa,dN2a] = deriCountsAero(j,Q,x,forwardmodelTraman)
m = length(Q.Zret);
    [y_JL,y_JH,y_JLa,y_JHa,y_WV,y_N2,y_WVa,y_N2a]=forwardmodelTraman(Q,x);

    if ~isempty(find(isnan(x)) == 1)
        'after FM: Nans in retrieval vector derivCounts'
        stop
    end
%     m=length(Q.Zret);
%     xa=x(1:m);
    dn = x(4*m+18+j).*1e-8; % this can go anything smaller than 0.1 even for higher temperatures works ok
    xpert = x;
    if x(4*m+18+j) == 0 % trap for tau's where tau(1) = 0
        dn = 1.e-8 .* x(4*m+18+j+1);
    end
    xpert(4*m+18+j) = x(4*m+18+j) + dn;
%     Xpert= [xpert x(end-2) x(end-1) x(end)];

    [y_JL_dT,y_JH_dT,y_JLa_dT,y_JHa_dT,y_WV_dT,y_N2_dT,y_WVa_dT,y_N2a_dT]=forwardmodelTraman(Q,xpert);

    dJL = (y_JL_dT - y_JL)./dn;
    dJH = (y_JH_dT - y_JH)./dn;
    dJLa = (y_JLa_dT - y_JLa)./dn;
    dJHa = (y_JHa_dT - y_JHa)./dn;
    
    dWV = (y_WV_dT - y_WV)./dn;
    dN2 = (y_N2_dT - y_N2)./dn;
    dWVa = (y_WVa_dT - y_WVa)./dn;
    dN2a = (y_N2a_dT - y_N2a)./dn;
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