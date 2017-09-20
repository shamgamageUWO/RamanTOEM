    function [dJH,dJL] = deriCountsOEM(j,Q,x,forwardmodelTraman)

    [y_JL,y_JH]=forwardmodelTraman(Q,x);

    if ~isempty(find(isnan(x)) == 1)
        'after FM: Nans in retrieval vector derivCounts'
        stop
    end
%     m=length(Q.Zret);
%     xa=x(1:m);
    dn = x(j).*1e-8; % this can go anything smaller than 0.1 even for higher temperatures works ok
    xpert = x;
    if x(j) == 0 % trap for tau's where tau(1) = 0
        dn = 1.e-8 .* x(j+1);
    end
    xpert(j) = x(j) + dn;
%     Xpert= [xpert x(end-2) x(end-1) x(end)];

    [y_JL_dT,y_JH_dT]=forwardmodelTraman(Q,xpert);

        dJL = (y_JL_dT - y_JL)./dn;
        dJH = (y_JH_dT - y_JH)./dn;
%         dJLa = (y_JLa_dT - y_JLa)./dn;
%         dJHa = (y_JHa_dT - y_JHa)./dn;
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