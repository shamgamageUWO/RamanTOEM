function pspoly = polygoninize_regions(boxes)
% POLYGONINIZE_REGIONS Turn adjacent regions (boxes) into polygon for plotting
%
% PURPOSE: To set up for plotting many regions defined as box coordinates. This
%          function make sure that extra lines aren't drawn right next to each
%          other for essentially the same region. This is usefull if you have a
%          complicated region made of of several boxes.
%          e.g. in eliasson11_assessing_acp
%         
%
% IN      boxes  [%f %s]: (array containing coordinates for one or several regions)
%         e.g. boxes = [box1; box2; box3], where box1 has the form 
%         [bottom left corner, top right corner];
%
% OUT     struct      Structure of arguments to be used for plotting the
%                     regions  on a map
%
% Created by Salomon Eliasson
% $Id: polygoninize_regions.m 6862 2011-04-17 20:27:55Z seliasson $

%% Make a grid of logicals
res = .1;
tmplon = -180-res:res:180+res;
tmplat = -90-res:res:90+res;
tmpgrid = false(length(tmplat),length(tmplon));
[lon,lat]=meshgrid(tmplon(2:end-1),tmplat((2:end-1)));

% cond1 within the regions
for i=1:size(boxes,1)
    latindex= tmplat >= boxes(i,1) & tmplat <= boxes(i,3);
    lonindex= tmplon >= boxes(i,2) & tmplon <= boxes(i,4);
    tmpgrid(latindex,lonindex)=true;
end

j = 2:length(tmplat)-1;
i = 2:length(tmplon)-1;

%% grid
%|------|------|------| |------|------|------|
%| j-1, | j-1, | j-1, | |  1   | 2    | 3    |
%|   i-1|   i  |   i+1| |      |      |      |
%|------|------|------| |------|------|------|
%| j,   | j,i  | j,   | |  4   | i,j  |  5   |
%|  i-1 |      |  i+1 | |      |      |      |
%|------|------|------| |------|------|------|
%| j+1, | j+1, | j+1, | |  6   |  7   |  8   |
%|   i-1|   i  |   i+1| |      |      |      |
%|------|------|------| |------|------|------|

cond1= tmpgrid(j,i) & tmpgrid(j-1,i-1);
cond2= tmpgrid(j,i) & tmpgrid(j-1,i);
cond3= tmpgrid(j,i) & tmpgrid(j-1,i+1);
cond4= tmpgrid(j,i) & tmpgrid(j,i-1);
cond5= tmpgrid(j,i) & tmpgrid(j,i+1);
cond6= tmpgrid(j,i) & tmpgrid(j+1,i-1);
cond7= tmpgrid(j,i) & tmpgrid(j+1,i);
cond8= tmpgrid(j,i) & tmpgrid(j+1,i+1);

%% CORNERS
% remember grid is upside down
tl = tmpgrid(2:end-1,2:end-1) & ~(cond4 | cond2); %bl
tr = tmpgrid(2:end-1,2:end-1) & ~(cond5 | cond2); %br
bl = tmpgrid(2:end-1,2:end-1) & ~(cond4 | cond7); %tl
br = tmpgrid(2:end-1,2:end-1) & ~(cond5 | cond7); %tr
itl = xor(cond1,cond4 & cond2) & ~tmpgrid(j-1,i-1); % ibl
itr = xor(cond3,cond5 & cond2) & ~tmpgrid(j-1,i+1); % ibr
ibl = xor(cond6,cond4 & cond7) & ~tmpgrid(j+1,i-1); % itl
ibr = xor(cond8,cond5 & cond7) & ~tmpgrid(j+1,i+1); % itr

%% TRACING
corners = tl | tr | bl | br | itl | itr | ibl | ibr;
[rows,cols]=find(corners);
points = [lat(corners),lon(corners),rows,cols];

tmpgrid = tmpgrid(2:end-1,2:end-1);

di=-1;
j = 1;
curpoints = [points,false(size(cols))];
psxy = cell(10,1);
while 1
    if isempty(curpoints)
        break
    end
    i = 1;
    psxy{j} = [curpoints(i,2),curpoints(i,1)];
    curpoints(i,5)=true;
    while  1
        di = finddirection(tmpgrid,curpoints,i,di);
        i = nextcoord(di,curpoints,i);
        if curpoints(i,5)
            break
        end
        psxy{j} = [psxy{j}; [curpoints(i,2),curpoints(i,1)]];
        curpoints(i,5)=true;
    end
    curpoints = curpoints(~curpoints(:,5),:);
    j = j+1;
end

pspoly = psxy(1:j-1); %pspoly is the name used in gmt_plot

%% SUBFUNCTIONS
%     |||||||
%     vvvvvvv

function d = finddirection(tmpgrid,points,i,dir)
%% finddirection

[d,f] = specialcase(tmpgrid,points,i,dir);

if f, return, end

for j=1:4
    d = mod(d+1,4);
    if d == dir
        break
    end
    if dir~=-1 && mod(dir+2,4)==d, continue, end
    switch d
        case 0 % west, left in matrix
            beside=~isempty(points(points(:,3) == points(i,3) & points(:,4) == points(i,3)-1,:));
            west = sum(tmpgrid(points(i,3)-1:points(i,3)+1,points(i,4)-1))==2;
            if beside || west
                break
            end
        case 1 %north, down in matrix
            beside=~isempty(points(points(:,4) == points(i,4) & points(:,3) == points(i,3)+1,:));
            north = sum(tmpgrid(points(i,3)+1,points(i,4)-1:points(i,4)+1))==2;
            if beside || north
                break
            end
        case 2 %east, right in matrix
            beside=~isempty(points(points(:,3) == points(i,3) & points(:,4) == points(i,3)+1,:));
            east = sum(tmpgrid(points(i,3)-1:points(i,3)+1,points(i,4)+1))==2;
            if beside || east
                break
            end
        case 3 %south, up in matrix
            beside=~isempty(points(points(:,4) == points(i,4) & points(:,3) == points(i,3)-1,:));
            south = sum(tmpgrid(points(i,3)-1,points(i,4)-1:points(i,4)+1))==2;
            if beside || south
                break
            end
    end
end


function a = nextcoord(di,points,i)
%% nextcoord

ref = points(i,3:4);

k = 1:length(points);
switch di
    case 0 % west, left in matrix
        index = ref(1,1)==points(:,3)&ref(1,2)>points(:,4);
    case 1 %north, down in matrix
        index = ref(1,2)==points(:,4)&ref(1,1)<points(:,3);
    case 2 %east, right in matrix
        index = ref(1,1)==points(:,3)&ref(1,2)<points(:,4);
    case 3 %south, up in matrix
        index = ref(1,2)==points(:,4)&ref(1,1)>points(:,3);
end

k = k(index);
test = sum(repmat(ref,sum(index),1)-points(index,3:4),2);
a = k(abs(test)==min(abs(test)));
if isempty(a)
    error('gmtlab:error','isempty(a)')
end

function [dir,f] = specialcase(tmpgrid,points,i,dir)                            
%% SPECIAL CASE

a = points(i,4) == 1;              % you are on the western edge of the map
b = points(i,4) == size(tmpgrid,2);% you are on the eastern edge of the map
c = points(i,3) == 1;              % you are on the southern edge of the map
d = points(i,3) == size(tmpgrid,1);% you are on the northern edge of the map
f = false;
if a || b || c || d
    if a
        % north or east
        if checknorth(tmpgrid,points,i)
            dir = 1;
        else dir = 2;
        end
    end
    if b
        % south or west
        if checksouth(tmpgrid,points,i)
            dir = 3;
        else dir = 0;
        end
    end
    if c
        % west or north
        if checkwest(tmpgrid,points,i)
            dir = 0;
        else dir = 1;
        end
    end
    if d
        % east or south
        if checkeast(tmpgrid,points,i)
            dir = 2;
        else dir = 3;
        end
    end
    f = true;
end


function out = checknorth(tmpgrid,points,i)                                     
%% CHECK NORTH

out = false;
ref = points(i,3:4);
k = 1:length(points);

% check if any points exist in this direction
cond = points(:,4)==ref(1,2)&points(:,3)>ref(1,1)&~points(:,5);
if sum(cond)==0, return, end

subset = points(cond,3:4);
k = k(cond);
test = sum(repmat(ref,size(subset,1),1)-subset,2);
a = k(abs(test)==min(abs(test)));

%test if it's there (western edge)
vect = tmpgrid(ref(1,1):points(a,3),1);
out = sum(vect,1)==length(vect);

function out = checksouth(tmpgrid,points,i)                                     
%% CHECK SOUTH

out=false;
ref = points(i,3:4);
k = 1:length(points);

% check if any points exist in this direction
cond = points(:,4)==ref(1,2)&points(:,3)<ref(1,1)&~points(:,5);
if sum(cond)==0, return, end

subset = points(cond,3:4);
k = k(cond);
test = sum(repmat(ref,size(subset,1),1)-subset,2);
a = k(abs(test)==min(abs(test)));

%test if it's there (eastern edge)
vect = tmpgrid(ref(1,1):points(a,3),end);
out = sum(vect,1)==length(vect);

function out = checkwest(tmpgrid,points,i)                                      
%% CHECK WEST

out=false;
ref = points(i,3:4);
k = 1:length(points);

cond = points(:,3)==ref(1,1)&points(:,4)<ref(1,2)&~points(:,5);
if sum(cond)==0, return, end

subset = points(cond,3:4);
k = k(cond);
test = sum(repmat(ref,size(subset,1),1)-subset,2);
a = k(abs(test)==min(abs(test)));

%test if it's there (southern edge)
vect = tmpgrid(1,ref(1,2):points(a,4));
out = sum(vect,1)==length(vect);

function out = checkeast(tmpgrid,points,i)                                      
%% CHECK EAST

out=false;
ref = points(i,3:4);
k = 1:length(points);

cond = points(:,3)==ref(1,1)&points(:,4)>ref(1,2)&~points(:,5);
if sum(cond)==0, return, end

subset = points(cond,3:4);
k = k(cond);
test = sum(repmat(ref,size(subset,1),1)-subset,2);
a = k(abs(test)==min(abs(test)));

%test if it's there (northern edge)
vect = tmpgrid(end,ref(1,2):points(a,4));
out = sum(vect,1)==length(vect);