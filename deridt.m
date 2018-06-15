function [dJHdt,dJLdt,dWVdt,dN2dt] = deridt(Q,x,forwardmodelTraman)
m = length(Q.Zret);
DT_JH = x(2*m+7);
DT_JL = x(2*m+8); % deadtimes
DT_WV = x(end-1);
DT_N2 = x(end); % deadtimes
% N = 2*m+6 ;


    [y_JL,y_JH,y_JLa,y_JHa,y_WV,y_N2,y_WVa,y_N2a]=forwardmodelTraman(Q,x);

    if ~isempty(find(isnan(x)) == 1)
        'after FM: Nans in retrieval vector derivCounts'
        stop
    end
%     m=length(Q.Zret);
%     xa=x(1:m);
dn = DT_JH.*1e3;
dn2 = DT_JL.*1e3;
dn3 = DT_WV.*1e3;
dn4 = DT_N2.*1e3;
    % this can go anything smaller than 0.1 even for higher temperatures works ok
    xpert = x;

    xpert(2*m+7) = DT_JH + dn;
    xpert(2*m+8) =  DT_JL + dn2;
    xpert(end-1) = DT_WV + dn3;
    xpert(end) =  DT_N2 + dn4;
%     Xpert= [xpert x(end-2) x(end-1) x(end)];

    [y_JL_dT,y_JH_dT,y_JLa_dT,y_JHa_dT,y_WV_dT,y_N2_dT,y_WVa_dT,y_N2a_dT]=forwardmodelTraman(Q,xpert);

    dJHdt= (y_JH_dT - y_JH)./dn;
    dJLdt =(y_JL_dT - y_JL)./dn2;
    dWVdt= (y_WV_dT - y_WV)./dn3;
    dN2dt =(y_N2_dT - y_N2)./dn4;
   
   
    return

