%LINE_SPHERE_INTERSECT returns intersection points of a line and a sphere (or circle)
%
% FORMAT [y]=line_sphere_intersect(P1,P2,Pc,r]
%
% OUT     y      intersection point(s) y(1,:)=[x1,y1,z1]
%                                                        y(2,:)=[x2,y2,z2]
%                     where x1,y1,z1 are cartesian coordinates
%                     if size(y,1)=1 the line is a tangent to the sphere 
%                     if y=nan there is no interception points
% IN        P1    [xa,ya,zc] cartesian coordinates
%                     (a point on the line)
%             P2    [xb,yb,zb] cartesian coordinates
%                     (a point on the line)
%             Pc    the circle center [xc,yc,zc]
%             r       the circle radius

%History: created by Bengt Rydberg 2011-11-15  

function [y]=line_sphere_intersect(P1,P2,Pc,r)

x1=P1(1);
y1=P1(2);
z1=P1(3);
x2=P2(1);
y2=P2(2);
z2=P2(3);
x3=Pc(1);
y3=Pc(2);
z3=Pc(3);

a=(x2 - x1).^2 + (y2 - y1).^2 + (z2 - z1).^2;
b = 2*[ (x2 - x1)*(x1 - x3) + (y2 - y1) *(y1 - y3) + (z2 - z1)* (z1 - z3) ] ;
c = x3^2 + y3^2 + z3^2 + x1^2 + y1^2 + z1^2 - ...
     2*[x3*x1 + y3*y1 + z3*z1] - r^2;

if (b^2-4*a*c)<0
 %no intersections
 y=nan;
elseif (b^2-4*a*c)==0
 %the line is tangent to the sphere
 u1=-b/(2*a);
 y=P1+u1*(P2-P1);
 else
 %two intersections  
 u1=(-b+sqrt(b^2-4*a*c))/(2*a); 
 u2=(-b-sqrt(b^2-4*a*c))/(2*a);
 y1=P1+u1*(P2-P1);
 y2=P1+u2*(P2-P1);
 y=[y1;y2];
end

