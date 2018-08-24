%------------------------------------------------------------------------
% NAME:    axes_mxn(m,n,s)
%
%          Sets tight axes for figures with a nxm matrix of subplots.
%
%          This function is useful when the horisontal grid of the subplots
%          is identical.
%
% RETURN:  -
% IN:      m       the number of rows of sub-plots
%          n       the number of columns of subplots
%          s       space between plots  (optional)
%          b       space at the bottom (optional)
%          l       space at the left (optional)
%          t       space at the top (optional)
%          r       space at the right (optional) 
%          label   remove ticklabels (optional)
%           'on'
%
% EXAMPLE: axes_mxn(3,3,0.02,0.13,0.13,0.13,0.13)  
%------------------------------------------------------------------------

% HISTORY: 2004-03-30  Created by Samuel Brohede brohede@rss.chalmers.se

function axes_mxn(m,n,s,b,l,t,r,label)

if ~exist('s');s=0.03;end    
if ~exist('b');b=0.13;end    
if ~exist('l');l=0.13;end   
if ~exist('t');t=0;end   
if ~exist('r');r=0;end     
if (~exist('label','var') | isempty(label))
    label = 'on';
end

if n==1 & m==1, return,end

x0=l;
y0=b;

yh=((1-(m)*s)-y0-t)/m;
xw=((1-(n)*s)-x0-r)/n;

k=1;
for i=1:m
    for j=1:n
        subplot(m,n,k)
        set(gca,'Pos',[x0+(j-1)*s+(j-1)*xw y0+(m-i)*s+(m-i)*yh xw yh]);
        k=k+1;
        if ~(j==1) & strcmp(label,'on');
           set(gca,'YTickLabel','');
        end   
        if ~(i==m) & strcmp(label,'on');
            set(gca,'XTickLabel','');
        end
    end
end

