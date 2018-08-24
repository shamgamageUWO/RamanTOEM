function result = e3_xscan(nsteps, dx)

% Computation and plot of E3 function
% and compared with exp
% C. Mätzler, March 2004.

nx=(1:nsteps)';
x=(nx-0.5)*dx;
for j = 1:nsteps,
    a(j)=e_function(3,x(j));
    b(j)=0.5*exp(-2*x(j));
end;
a=a'; b=b';
% plotting the results
plot(x,a,'k.-',x,b,'k-'),
legend('E3(x)',' e^{-2x}/2'),
xlabel('x');
result=[x,a,b]; 