function  [dJHdbg,dJLdbg,dJHadbg,dJLadbg] = deriBg(Q,x,forwardmodelTraman)

m = length(Q.Zret);
BJH = x(m+1);
BJL = x(m+2);
BJHa = x(2*m+4);
BJLa = x(2*m+5);
% N = 2*m+6 ;


    [y_JL,y_JH,y_JLa,y_JHa]=forwardmodelTraman(Q,x);

    if ~isempty(find(isnan(x)) == 1)
        'after FM: Nans in retrieval vector derivCounts'
        stop
    end
%     m=length(Q.Zret);
%     xa=x(1:m);
    dn1 = BJH.*1e-4;
    dn2 = BJL.*1e-4;
    dn3 = BJHa.*1e-4;
    dn4 = BJLa.*1e-4;
    % this can go anything smaller than 0.1 even for higher temperatures works ok
    xpert = x;

    xpert(m+1) = BJH + dn1;
    xpert(m+2) =  BJL + dn2;
    xpert(2*m+4) = BJHa + dn3;
    xpert(2*m+5) =  BJLa + dn4;
%     Xpert= [xpert x(end-2) x(end-1) x(end)];

    [y_JL_dT,y_JH_dT,y_JLa_dT,y_JHa_dT]=forwardmodelTraman(Q,xpert);

    dJHdbg= (y_JH_dT - y_JH)./dn1;
    dJLdbg =(y_JL_dT - y_JL)./dn2;
    dJHadbg= (y_JHa_dT - y_JHa)./dn3;
    dJLadbg =(y_JLa_dT - y_JLa)./dn4;
   
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