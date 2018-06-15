x_a = [Q.Ta Q.BaJH Q.BaJL Q.CL Q.OVa Q.BaJHa Q.BaJLa Q.CLa Q.deadtimeJH Q.deadtimeJL Q.RHa Q.BaWV Q.BaN2 Q.CWV Q.CN2 Q.OVwva Q.BaWVa Q.BaN2a Q.CWVa Q.CN2a Q.deadtimeWV Q.deadtimeN2];
[JL,JH,JLa,JHa,WV,N2,WVa,N2a]=forwardmodelTraman(Q,x_a);
figure;
subplot(1,2,1)
semilogx(Q.WVnew,Q.Zmes2,'y',WV,Q.Zmes2,'g')
hold on;
semilogx(Q.WVnewa,Q.Zmes1,'r',WVa,Q.Zmes1,'b')
hold off

subplot(1,2,2)
semilogx(Q.N2new,Q.Zmes2,'y',N2,Q.Zmes2,'g')
hold on;
semilogx(Q.N2newa,Q.Zmes1,'r',N2a,Q.Zmes1,'b')
hold off