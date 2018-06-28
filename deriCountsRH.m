function [dRHWV,dRHN2,dRHWVa,dRHN2a] = deriCountsRH(j,Q,x,forwardmodelTraman)


 m = length(Q.Zret);
% N = 2*m+6 ;


    [y_JL,y_JH,y_JLa,y_JHa,y_WV,y_N2,y_WVa,y_N2a]=forwardmodelTraman(Q,x);

    if ~isempty(find(isnan(x)) == 1)
        'after FM: Nans in retrieval vector derivCounts'
        stop
    end
%     m=length(Q.Zret);
%     xa=x(1:m);
    dn = x(2*m+8+j).*1e-4; % this can go anything smaller than 0.1 even for higher temperatures works ok
    xpert = x;
    if x(2*m+8+j) == 0 % trap for tau's where tau(1) = 0
        dn = 1.e-4 .* x(2*m+8+j+1);
    end
    
    xpert(2*m+8+j) = x(2*m+8+j) + dn;

    
    [y_JL_dT,y_JH_dT,y_JLa_dT,y_JHa_dT,y_WV_dT,y_N2_dT,y_WVa_dT,y_N2a_dT]=forwardmodelTraman(Q,xpert);
    dRHWV = (y_WV_dT - y_WV)./dn;
    dRHN2 = (y_N2_dT - y_N2)./dn;
    dRHWVa = (y_WVa_dT - y_WVa)./dn;
    dRHN2a = (y_N2a_dT - y_N2a)./dn;
    return


