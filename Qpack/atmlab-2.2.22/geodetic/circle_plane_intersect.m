%CIRCLE_PLANE returns the intesection points of a circle and plane in 3 dimensions
%
% FORMAT y=circle_plane_intersect(p1,n1,r1,p2,n2)
%
% OUT      
%         y     cartesian coordinates of the intersection points
%                y is nan if there are no intersections
%        
% IN     p1  the circle center in cartesian coordinates
%          n1  the normal to the circle
%          r1   the radius of the circle
%          p2  a point in the plane 
%          n2  the normal to the plane

% HISTORY: Created by Bengt Rydberg 2011-11-22          
function [y]=circle_plane_intersect(p1,n1,r1,p2,n2)

%check input
rqre_datatype( p1, @istensor1 );						%&%
rqre_datatype( n1, @istensor1 );						%&%
rqre_datatype( r1, @istensor1 );						%&%
rqre_datatype( p2, @istensor1 );						%&%
rqre_datatype( n2, @istensor1 );						%&%
if length(p1)~=3							%&%
    error('p1 must have length 3')						%&%
end												%&%
if length(n1)~=3							%&%
    error('n1 must have length 3')					%&%
end												%&%
if length(r1)~=1							%&%
    error('r1 must have length 1')						%&%
end												%&%
if length(p2)~=3							%&%
    error('p2 must have length 3')						%&%
end												%&%
if length(n2)~=3							%&%
    error('n2 must have length 3')					%&%
end												%&%

p1=p1';
n1=n1';
p2=p2';
n2=n2';


if sum(cross(n1,n2))==0
 %the circle plane and the other plane is parallel
%and there are no crossings
 y=nan;
 return
end

%rotate the coordinate system to make the code simpler
ind1=find(abs(n2)==max(abs(n2)));

if ind1==1
   indv=[1,2,3];
elseif ind1==2
    indv=[2,1,3];
else
   indv=[3,1,2];
end

%equation of the plane is then
%a2x+b2y+c2z=n2(1)*x+n2(2)*y+n2(3)*z=d2=n2*p2'
d2=n2*p2';
a2=n2(indv(1));
b2=n2(indv(2));
c2=n2(indv(3));

%the circle plane is
%a1x+b1x+c1x=d1=n1(1)*x+n1(2)*y+n1(3)*z=d1=n1*p1'
d1=n1*p1';
a1=n1(indv(1));
b1=n1(indv(2));
c1=n1(indv(3));

%
xa=p1(indv(1));
ya=p1(indv(2));
za=p1(indv(3));

%x=(d2-b2*y-c2*z)/a2;
b0=b1-b2*a1/a2;
c0=c1-c2*a1/a2;
d0=d1-d2*a1/a2;



if b0~=0
        y1=d0/b0;
        y2=c0/b0;
        %y=y1-y2*z;
        %x=d2/a2*(1-b2/a2*y1)-z*(b2/a2*y2-c2/a2)
        %x=x1-x2*z
        x1=d2/a2-b2/a2*d0/b0;
        x2=c2/a2-b2/a2*y2;
        %z^2*z0+z*z1+z2=0
        z0=x2^2+y2^2+1;
        z1=2*(x2*(xa-x1)+y2*(ya-y1)-za);
        z2=-r1^2+(x1-xa)^2+(y1-ya)^2+za^2;
        %%%%%%%
        zs1=(-z1+sqrt(z1^2-4*z0*z2))/(2*z0);
        zs2=(-z1-sqrt(z1^2-4*z0*z2))/(2*z0);
        xs1=x1-x2*zs1;
        xs2= x1-x2*zs2;
        ys1=y1-y2*zs1;
        ys2= y1-y2*zs2;
        y=[xs1,ys1,zs1;xs2,ys2,zs2];
   else
        z1=d0/c0;
        z2=b0/c0;
        x1=d2/a2-c2/a2*d0/c0;
        x2=b2/a2-c2/a2*z2;
        y0=x2^2+z2^2+1;
        y1=2*(x2*(xa-x1)+z2*(za-z1)-ya);
        y2=-r1^2+(x1-xa)^2+(z1-za)^2+ya^2;
        ys1=(-y1+sqrt(y1^2-4*y0*y2))/(2*y0);
        ys2=(-y1-sqrt(y1^2-4*y0*y2))/(2*y0);
        xs1=x1-x2*ys1;
        xs2= x1-x2*ys2;
        zs1=z1-z2*ys1;
        zs2= z1-z2*ys2;
        y=[xs1,ys1,zs1;xs2,ys2,zs2];
end

y=y(:,indv);
if ~isreal(y)
  y=nan;
end


