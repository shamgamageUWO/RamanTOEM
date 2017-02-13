[Q] = makeQsham( );

xa = [Q.Ta Q.BaJH Q.BaJL Q.CL];
[JL,JH,A_Zi,B_Zi,Diff_JL_i,Diff_JH_i,Ti]=forwardmodelTraman(Q,xa);
plot(Q.y(1:Q.n1),Q.Zmes./1000,'r',JH,Q.Zmes./1000,'b')