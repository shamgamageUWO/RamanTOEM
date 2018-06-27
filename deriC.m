function [dJHdc,dJLdc,dJHadc,dJLadc,dWVdc,dN2dc,dWVadc,dN2adc] = deriC(Q,x,forwardmodelTraman)
m = length(Q.Zret);
CJL = x(m+3);
CJLa = x(end-2);
CWV = x(3*m+11);
CN2 = x(3*m+12);
CWVa = x(4*m+15);
CN2a = x(4*m+16);


    [y_JL,y_JH,y_JLa,y_JHa,y_WV,y_N2,y_WVa,y_N2a]=forwardmodelTraman(Q,x);

    if ~isempty(find(isnan(x)) == 1)
        'after FM: Nans in retrieval vector derivCounts'
        stop
    end
%     m=length(Q.Zret);
%     xa=x(1:m);
dn1 = CJL.*1e-4;
dn2 = CJLa.*1e-4;
dn3 = CWV.*1e-4;
dn4 = CN2.*1e-4;
dn5 = CWVa.*1e-4;
dn6 = CN2a.*1e-4;
%     dn2 = DT_JL.*1e-4;
    % this can go anything smaller than 0.1 even for higher temperatures works ok
    xpert = x;

    xpert(m+3) = CJL + dn1;
    xpert(end-2) = CJLa + dn2;
    xpert(3*m+11) = CWV + dn3;
    xpert(3*m+12) = CN2 + dn4;
    xpert(4*m+15) = CWVa + dn5;
    xpert(4*m+16) = CN2a + dn6;
    


    [y_JL_dT,y_JH_dT,y_JLa_dT,y_JHa_dT,y_WV_dT,y_N2_dT,y_WVa_dT,y_N2a_dT]=forwardmodelTraman(Q,xpert);

    dJHdc= (y_JH_dT - y_JH)./dn1;
    dJLdc =(y_JL_dT - y_JL)./dn1;
    dJHadc= (y_JHa_dT - y_JHa)./dn2;
    dJLadc =(y_JLa_dT - y_JLa)./dn2;
    dWVdc= (y_WV_dT - y_WV)./dn3;
    dN2dc =(y_N2_dT - y_N2)./dn4;
    dWVadc= (y_WVa_dT - y_WVa)./dn5;
    dN2adc =(y_N2a_dT - y_N2a)./dn6;
   
    return

