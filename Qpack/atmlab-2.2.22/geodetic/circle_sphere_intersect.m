%CIRCLE_SPHERE_INTERSECT returns the intersection points of a circle and sphere,
%		The sphere is assumed to be centered at 
%             cartesian origin [0,0,0].
%
% FORMAT  y=circle_sphere_intersect(p1,n1,r1,r2)
%
%  OUT        y   the intersection points in cartesian coordinates
%                      y is nan if there are no intersections
%
%  IN            p1 the circle center in cartesian coordinates
%                  n1 the normal of the cricle plane
%                  r1  the radius of the circle
%                  r2 the radius of the sphere (the sphere is placed 
%                  at 0,0,0)

%HISTORY: created be Bengt Rydberg 2011-11-22 
function [y]=circle_sphere_intersect(p1,n1,r1,r2)

%check input
rqre_datatype( p1, @istensor1 );						%&%
rqre_datatype( n1, @istensor1 );						%&%
rqre_datatype( r1, @istensor1 );						%&%
rqre_datatype( r2, @istensor1 );						%&%
if length(p1)~=3							%&%
    error('p1 must have length 3')						%&%
end												%&%
if length(n1)~=3							%&%
    error('n1 must have length 3')					%&%
end												%&%
if length(r1)~=1							%&%
    error('r1 must have length 1')						%&%
end												%&%
if length(r2)~=1							%&%
    error('r2 must have length 1')						%&%
end												%&%

p1=p1';
n1=n1';

%rotate coordinates if necessary to simplify code
ind1=min(find(p1));
if ind1==1
   indv=[1,2,3];
elseif ind1==2
    indv=[2,1,3];
else
   indv=[3,1,2];
end


indv=[1,2,3];

%equation of the plane is then
%ax+by+cz=n1(1)*x+n1(2)*y+n1(3)*z=d2=n1*p1'
d=n1*p1';
a=n1(indv(1));
b=n1(indv(2));
c=n1(indv(3));
xa=p1(indv(1));
ya=p1(indv(2));
za=p1(indv(3));

%we have three equations
%x^2+y^2+z^2=r2^2 					(1)
%(x-xa)^2+(y-ya)^2+(z-za)^2=r1^2  		(2)
%a*x+b*y+c*z=d							(3)

%(1) in (2) =>
%-2*x*xa-2*y*ya-2*z*za=r1^2-r2^2-ra^2=r0^2
ra2=p1*p1';
r02=r1^2-r2^2-ra2;
%=> x=-(r0^2+2*y*ya+2*z*za)/(2*xa)
%=>x=-r0^2/(2*xa)-y*ya/xa-z*za/xa=x0+x1*y+x2*z 	(4)
x0=-r02/(2*xa);
x1=-ya/xa;
x2=-za/xa;

if (a*x1+b)~=0
    %(4) in (3) =>
    %y=(d-a*x0-z*(c+a*x2))/(a*x1+b)=y1+y2*z  	(5)
    y1=(d-a*x0)/(a*x1+b);
    y2=-(c+a*x2)/(a*x1+b);
    %(5) in (4) =>
    %x=x01+x02*z   							(6)
    x01=x0+x1*y1;
    x02=x1*y2+x2;
    %(5) & (6) in 1=>
    %z1*z^2+z2*z+z3=0
    z0=1+x02^2+y2^2;
    z1=2*x01*x02+2*y1*y2;
    z2=x01^2+y1^2-r2^2;
    zs1=(-z1+sqrt(z1^2-4*z0*z2))/(2*z0);
    zs2=(-z1-sqrt(z1^2-4*z0*z2))/(2*z0);
    xs1=x01+x02*zs1; 
    xs2=x01+x02*zs2; 
    ys1=y1+y2*zs1;
    ys2=y1+y2*zs2;
else
    %(4) in (3) =>
    %z=(d-a*x0-y*(b+a*x1))/(a*x2+c)=z1+z2*y 	(5)
    z1=(d-a*x0)/(a*x2+c);
    z2=-(b+a*x1)/(a*x2+c);
    %(5) in (4) =>
    %x=x01+x02*y  							(6)
    x01=x0+x2*z1;
    x02=x2*z2+x1;
    %(5) & (6) in 1=>
    %y1*y^2+y2*y+y3=0
    y0=1+x02^2+z2^2;
    y1=2*x01*x02+2*z1*z2;
    y2=x01^2+z1^2-r2^2;
    ys1=(-y1+sqrt(y1^2-4*y0*y2))/(2*y0);
    ys2=(-y1-sqrt(y1^2-4*y0*y2))/(2*y0);
    xs1=x01+x02*ys1; 
    xs2=x01+x02*ys2; 
    zs1=z1+z2*ys1;
    zs2=z1+z2*ys2;
end

y=[xs1,ys1,zs1;xs2,ys2,zs2];
y=y(:,indv);
if ~isreal(y)
  y=nan;
end

    






