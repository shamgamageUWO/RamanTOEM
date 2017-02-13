function[fillhandle,msg]=jbfilly(ypoints,upper,lower,color,edge,add,transparency)
%USAGE: [fillhandle,msg]=jbfilly(ypoints,upper,lower,color,edge,add,transparency)
%This function will fill a region with a color between the two vectors provided
%using the Matlab fill command.
%
%fillhandle is the returned handle to the filled region in the plot.
% NOTE: must use row vectors!
%ypoints= The vertical data points (ie frequencies). Note length(Upper)
%         must equal Length(lower)and must equal length(xpoints)!
%upper = the upper curve values (data can be less than lower)
%lower = the lower curve values (data can be more than upper)
%color = the color of the filled area 
%edge  = the color around the edge of the filled area
%add   = a flag to add to the current plot or make a new one.
%transparency is a value ranging from 1 for opaque to 0 for invisible for
%the filled color only.
%
%John A. Bockstege November 2006;
%Example:
%     a=rand(1,20);%Vector of random data
%     b=a+2*rand(1,20);%2nd vector of data points;
%     x=1:20;%horizontal vector
%     [ph,msg]=jbfill(x,a,b,rand(1,3),rand(1,3),0,rand(1,1))
%     grid on
%     legend('Datr')
%
% Modfied by Sica Nov 2014 for vertical plotting

if nargin<7;transparency=.1;end %default is to have a transparency of .5
if nargin<6;add=1;end     %default is to add to current plot
if nargin<5;edge='r';end  %dfault edge color is black
if nargin<4;color='r';end %default color is blue

if length(upper)==length(lower) && length(lower)==length(ypoints)
    msg='';
    filled=[upper,fliplr(lower)];
    ypoints=[ypoints,fliplr(ypoints)];
    if add
        hold on
    end
    fillhandle=fill(filled,ypoints,color);%plot the data
    set(fillhandle,'EdgeColor',edge,'FaceAlpha',transparency,'EdgeAlpha',transparency);%set edge color
    if add
        hold off
    end
else
    msg='Error: Must use the same number of points in each vector';
end
