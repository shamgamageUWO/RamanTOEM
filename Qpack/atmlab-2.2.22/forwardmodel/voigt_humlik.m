% VOIGT_HUMLIK   Voigt line shape 
%
%    A simple Matlab implementation of the Humlicek algorithm for
%    calculation the Voigt line shape (JQSRT, 21, 309-313, 1978).
%
%    Please note that width for both Doppler and pressure broadening is given
%    as FWHM/2. This corresponds to the standard width for pressure
%    broadening, but could differ for the Doppler part. See *doppler_width*
%    for some details.
%
%    The function handles only single altitudes (but multiple frequencies).
%
% FORMAT   bredd = voigt_humlik(f,f0,dfd,dfp)
%        
% OUT   bredd   Line shape.
% IN    f       Frequency vector.
%       f0      Centre frequency
%       dfd     Width of Doppler broadening.
%       dfp     Width of pressure broadening.

% 1992         Mats Pettersson
% 1993         Modified by Magnus Gustafsson
% 2006-11-26   Header written by Patrick Eriksson.


function bredd=voigt_humlik(f,f0,dfd,dfp)

bl=dfp;		%% MG
bd=dfd;		%% MG
x=f-f0;		%% MG



T=[.314240376 .947788391 1.59768264 2.27950708 3.02063703 3.8897249];
C=[1.01172805 -.75197147 1.2557727e-2 1.00220082e-2 -2.42068135e-4 5.00848061e-7];
S=[1.393237 .231152406 -.155351466 6.21836624e-3 9.19082986e-5 -6.27525958e-7];


p=0;
WR=0;WR2=0;WR1=0;
WI=0;
X=x/bd*(0.83255461115770);
Y=bl/bd*(0.83255461115770);

Y1=Y+1.5;
Y2=Y1*Y1;
X1=X;
X2=X;
n=0;
m=0;
k=0;
l=0;
if Y>0.85

 for i=1:6
   R=X-T(i);
   D=(R.^2+Y2).^(-1);
   D1=Y1*D;
   D2=R.*D;
   R=X+T(i);
   D=(R.^2+Y2).^(-1);
   D3=Y1*D;
   D4=R.*D;
   WR=WR+C(i)*(D1+D3)-S(i)*(D2-D4);
   
 end

else

 vektorlangd=length(X);
 test=sign(abs(X)-(18.1*Y+1.65));
 
 for p=1:vektorlangd
   if test(p)<0
     k=k+1;
     X1(k)=X(p);
   else
     n=n+1;
     X2(n)=X(p);
   end
 end
 X1=X1(1:k);
 X2=X2(1:n);

 if n>0
   WR2=exp(-X2.*X2);
   Y3=Y+3;
   for i=1:6
     R=X2-T(i);
     D=(R.^2+Y2).^(-1);
     D1=Y1*D;
     D2=R.*D;
     WR2=WR2+Y*(C(i)*(R.*D2-1.5*D1)+S(i)*Y3*D2).*((R.^2+2.25).^(-1));
     R=X2+T(i);
     D=(R.^2+Y2).^(-1);
     D3=Y1*D;
     D4=R.*D;
     WR2=WR2+Y*(C(i)*(R.*D4-1.5*D3)-S(i)*Y3*D4).*((R.^2+2.25).^(-1));  
    
   end
 
 end

 if k>0
   for i=1:6
    R=X1-T(i);
    D=(R.^2+Y2).^(-1);
    D1=Y1*D;
    D2=R.*D;
    R=X1+T(i);
    D=(R.^2+Y2).^(-1);
    D3=Y1*D;
    D4=R.*D;
    WR1=WR1+C(i)*(D1+D3)-S(i)*(D2-D4);
    
   end
 end  
 
 for p=1:vektorlangd
   if test(p)<0
     l=l+1;
     WR(p)=WR1(l);
   else
     m=m+1;
     WR(p)=WR2(m);
   end
 end

end  
    

%----Modification !-----
s=size(WR);
if s(1)<s(2)
	WR=WR';
end
%-----------------------
 bredd=1/bd*(0.46971863934983)*WR;


end
