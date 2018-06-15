function  [dJHdbg,dJLdbg,dJHadbg,dJLadbg,dWVdbg,dN2dbg,dWVadbg,dN2adbg] = deriBg(Q,x,forwardmodelTraman)

m = length(Q.Zret);
BJH = x(m+1);
BJL = x(m+2);
BJHa = x(2*m+4);
BJLa = x(2*m+5);
BWV = x(3*m+9);
BN2 = x(3*m+10);
BWVa = x(end-5);
BN2a = x(end-4);


    [y_JL,y_JH,y_JLa,y_JHa,y_WV,y_N2,y_WVa,y_N2a]=forwardmodelTraman(Q,x);

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
dn5 = BWV.*1e-4;
dn6 = BN2.*1e-4;
dn7 = BWVa.*1e-4;
dn8 = BN2a.*1e-4;
    % this can go anything smaller than 0.1 even for higher temperatures works ok
    xpert = x;

    xpert(m+1) = BJH + dn1;
    xpert(m+2) =  BJL + dn2;
    xpert(2*m+4) = BJHa + dn3;
    xpert(2*m+5) =  BJLa + dn4;
    xpert(3*m+9) = BWV + dn5;
    xpert(3*m+10) =  BN2 + dn6;
    xpert(end-5) = BWVa + dn7;
    xpert(end-4) =  BN2a + dn8;
%     Xpert= [xpert x(end-2) x(end-1) x(end)];

    [y_JL_dT,y_JH_dT,y_JLa_dT,y_JHa_dT,y_WV_dT,y_N2_dT,y_WVa_dT,y_N2a_dT]=forwardmodelTraman(Q,xpert);

    dJHdbg= (y_JH_dT - y_JH)./dn1;
    dJLdbg =(y_JL_dT - y_JL)./dn2;
    dJHadbg= (y_JHa_dT - y_JHa)./dn3;
    dJLadbg =(y_JLa_dT - y_JLa)./dn4;
    dWVdbg= (y_WV_dT - y_WV)./dn5;
    dN2dbg =(y_N2_dT - y_N2)./dn6;
    dWVadbg= (y_WVa_dT - y_WVa)./dn7;
    dN2adbg =(y_N2a_dT - y_N2a)./dn8;
   
    return

