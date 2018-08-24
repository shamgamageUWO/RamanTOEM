%LINE_PLANE_INTERSECT returns the intersection point between a plane and and a line
%
%    FORMAT [y,x]=line_plane_intersect(P1,P2,P3,n)
%
%    OUT        y     the intersection point in cartesian coordinate
%                           if y=nan the line is parallell to the plane
%                   x      a scalar which information on the intersection point
%                           x=1 the intersection is at point P1
%                           x=2 the intersection is at point P2
%                           x=3 the intersection is between point P1 and P2
%                           x=4 the intersection is not between point P1 and P2
% 
%    IN            P1  cartesian coordinates of a point on the line
%                    P2  cartesian coordinates of a point on the line
%                    P3  cartesian coordinates of a point on the plane
%                    n    the normal to the plane
%  

%HISTORY: created by Bengt Rydberg 2011-11-16
function [y,x]=line_plane_intersect(P1,P2,P3,n)




%check input
rqre_datatype( P1, @istensor1 );						%&%
rqre_datatype( P2, @istensor1 );						%&%
rqre_datatype( P3, @istensor1 );						%&%
rqre_datatype( n, @istensor1 );						%&%
if length(P1)~=3							%&%
    error('P1 must have length 3')						%&%
end												%&%
if length(P2)~=3							%&%
    error('P2 must have length 3')						%&%
end												%&%
if length(P3)~=3							%&%
    error('P3 must have length 3')						%&%
end												%&%
if length(n)~=3								%&%
    error('n must have length 3')						%&%
end												%&%

n=n';

u=(n*(P3-P1))/(n*(P2-P1));

if (n*(P2-P1))==0
    %the line is parallell to the plane
    y=nan;
    x=nan;
else
   y=P1+u*(P2-P1);
   if u>0 & u<1
       x=3;
   elseif u==0
      x=1;
   elseif u==1  
      x=2;
   else
     x=4;
   end
end
