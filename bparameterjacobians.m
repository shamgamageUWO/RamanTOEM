function [JPress, JR,Jnair]=bparameterjacobians (X,Q,S_a,Se)
%%[X,R,Q,O,S_a,Se,xa]=TRamanOEM( date_in,time_in,flag)

% data structure
mdata = length(Q.y);
yJH = Q.JHnew;
yJL = Q.JLnew;

% oem retrievals
n = length(X.x)
% b parameter Jacobians starts from here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Pressure Jacobian 
JPress =zeros(mdata,n);
dSJHdP = (yJH - X.x(end-Q.OVlength-2))./Q.Pressi;
dSJLdP = (yJL - X.x(end-Q.OVlength-1))./Q.Pressi;


%%% R jacobian
JR = zeros(mdata,n);
dSJHdR = (yJH - X.x(end-Q.OVlength-2))./Q.R;
dSJLdR = zeros(mdata/2,1);


%%% Air density (in the transmission) jacobian
Jtrans = zeros(mdata,n);
dSJHdnair = (yJH - X.x(end-Q.OVlength-2))./Q.rho;
dSJLdnair = (yJL - X.x(end-Q.OVlength-1))./Q.rho;

%%% deadtime jacobian
JDT = zeros(mdata,n);
dSJHdDT = (yJH - X.x(end-Q.OVlength-2))./Q.rho;
dSJLdDT = (yJL - X.x(end-Q.OVlength-1))./Q.rho;