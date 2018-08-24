% CIRCLE_INTERSECT returns intersection points of two circles in two dimensions
%
% Format [y]=circle_intersect(P1,P2,r1,r2);
%      
%      OUT  y coordinates of the intersection points
%              y(1,:) are closest to origin (x=0,y=0) 
%              if y=nan there is no intersection
%     
%     IN    P1 coordinates(x,y) of the circle 1 center
%             P2 coordinates(x,y) of the circle 2 center
%             r1 radius of circle 1
%             r2 radius of circle 2
%       

% Histiry: created by Bengt Rydberg 2011-11-15
function [y]=circle_intersect(P1,P2,R1,R2);

Pv=P1-P2;
d=sqrt(Pv*Pv');

if d>(R1+R2)
 %no solutions (the circles are separate.)
 y=nan;
elseif d<abs(R1-R2)
 %no solutions (one circle is contained within the other.)
 y=nan;
elseif d==0 & R1==R2
 %infinite number of solutions (circles are coincident)
 y=inf;
else

 a=(R1^2-R2^2+d^2)/(2*d);
 h=sqrt(R1^2-a^2);
 P3=P1+a*(P2-P1)/d;
 x4a=P3(1)+h*(P2(2)-P1(2))/d;
 x4b=P3(1)-h*(P2(2)-P1(2))/d;
 y4a=P3(2)-h*(P2(1)-P1(1))/d;
 y4b=P3(2)+h*(P2(1)-P1(1))/d;

 P4a=[x4a,y4a];
 P4b=[x4b,y4b];
 
 d4a=sqrt(P4a*P4a');
 d4b=sqrt(P4b*P4b');
  
 if d4a==d4b
  %only one intersection
  y=[P4a;P4b];
 elseif d4a>d4b
  y=[P4b;P4a]; 
 else
  y=[P4a;P4b]; 
 end
end
