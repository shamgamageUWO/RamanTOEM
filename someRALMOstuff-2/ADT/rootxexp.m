function x=rootxexp(y,xmax,xdisc,order)

% Search root x of function y=fx using a modified Newton-Raphson method
% FORTRAN source code from A. Hauchecorne (CNRS/SA, France), adapted by T. Leblanc

rootend=0;
x=0;

coef=nan(1,order+1);

for i=1:order+1
    
    coef(i)=xdisc^(i-1)/factorial(i-1)^2*(1.-xdisc/(i));
    
end

if y == 0
    x=0;
    return;
end

r=0;
while rootend~=1
    
%  Next line = 0 order of Carswell et al., 1993 equation (16)
%  fx=x*exp(-x/nrmax) & dfx=exp(-x/nrmax)*(1.-x/nrmax)

  fx0=x*exp(-x/xmax);
  dfx0=exp(-x/xmax)*(1.-x/xmax);
  fxi=0;
  dfxi=0;
  for i=1:order+1
    fxi=fxi+coef(i)*(x/xmax)^(i-1);
    if i-1 > 0
        dfxi=dfxi+coef(i)/xmax*(i-1)*(x/xmax)^(i-2) ;
    else
        dfxi=0;
    end
  end
  fx=fx0*fxi;
  dfx=dfx0*fxi+fx0*dfxi;

% ----- Now starts the Newton-Raphson method applied to fx and dfx ---
  if x*dfx < fx/100
    ok = 0;
    x = -1./xmax;
    rootend=1;
  elseif (y-fx)/y < 1.e-5
    rootend=1;
  else
    alpha=abs(y-fx)/y;
    if alpha > 1
        alpha=1;
    end
    x = x + (y-fx)/dfx*(1-alpha/2.);
  end

  
  r=r+1;
  if r>10
      rootend=1;
      x=nan;
      disp('rootxexp not converged...');
  end

end
