% data=get_sounding_from_files(t1,t2[,zz,'data_dir','/mydatadir'])
% 
% input:
% - t1,t2       : start and end time as string (format: 'yyyymmddHHMMSS')
% - zz (amsl)   : altitude vector to which the data are interpolated (optional)
%
% options:
%
% - data_dir    : specifies the data directory
% 
% output:
% - data
% 
% haa, 2010-10-14
% haa, 2010-12-21
% mao, 2011-07-14 changed data dirctoy after sun migration
% haa, 2012-05-15 added option to specify data directory

function data=get_sounding_from_files(start_str,end_str,zz,varargin)


% set default values
if nargin==2
    zz=[];
elseif nargin==4 % in case, zz is not given, but the data_dir option is used
    if isnumeric(zz)==0
         varargin = { zz varargin };
         zz=[];
    end
end

% set data directory
ind=find(strcmp(varargin,'data_dir')==1);
if isempty(ind)==0
    data_dir=varargin{ind+1};
else
    if ispc==1
        root='\\paynas201.meteoswiss.ch\data\data\pay';
    elseif isunix==1
        root='/data/pay';
    end
    data_dir=fullfile(root,'sounding','srs');
end

% round to full hours
t1=sqltime2datenumber(start_str);
t2=sqltime2datenumber(end_str);


% initialize parameters
records=0;
[c,t,p,T,rh,gph,speed,dir]=deal([]);


% read all data into one matrix
for tt=round(4*[floor(4*t1)/4:.25:ceil(4*t2)/4])/4


    % filename
    file=fullfile(char(data_dir),datestr(tt,'fyyyymmdd.HH'));
    if exist(file)~=2
        continue
    end
    
    % read data
    fid=fopen(file);
    c=textscan(fid,'%n%n%n%n%n%n%n%n%n%n%n%n','headerlines',1);
    fclose(fid);
    
    t=[t;tt*ones(size(c{1}))];
    p=[p;c{5}];
    T=[T;c{6}/100+273.15];
    rh=[rh;c{7}/100];
    gph=[gph;c{2}];
    speed=[speed;c{4}/2];
    dir=[dir;c{3}];
    
    
    % count records
    records=records+1;
    
end
    
    
% remove nan's and empty values
ind=find(isnan(gph)==0);
t=t(ind);
p=p(ind);
T=T(ind);
rh=rh(ind);
gph=gph(ind);
speed=speed(ind);
dir=dir(ind);

% set nan's for p,T,rh and gph
p(p>=9999)=nan;
T(T>=999)=nan;
rh(rh>=999)=nan;
gph(gph>=9999)=nan;


% set nan's for speed and dir
ind=find(speed>=999 | dir>=360);
speed(ind)=nan;
dir(ind)=nan;

% calculate u and v
dir_rad=dir/360*2*pi;
u=speed.*sin(dir_rad);
v=speed.*cos(dir_rad);

% if no interpolation is required
if isempty(zz)==1
    data.t=t;
    data.p=p;
    data.T=T;
    data.rh=rh;
    data.gph=gph;
    data.u=u;
    data.v=v;
    data.speed=speed;
    data.dir=dir;
    data.records=records;
end

% create a matrix if zz is given as input
warning('off','MATLAB:interp1:NaNinY');
if isempty(zz)==0
    
    % find indices where a new profile starts and ends
    ind1=[0;find(diff(t)>0)]+1;
    ind2=[find(diff(t)>0);length(t)];
    
    % preallocate output
    data.t=nan(1,length(ind1));
    data.z=zz;
    [data.p data.T data.rh data.gph data.u data.v]=deal(nan(length(zz),length(ind1)));
    
    % interpolate profiles to zz
    for i=1:length(ind1)
        
        data.t(i)=t(ind1(i));
        ind=ind1(i):ind2(i);
%         ii=find(isnan(gph(ind))==0);
        [x ii]=makeXdistinct(gph(ind));
        data.p(:,i)=exp(interp1(gph(ind(ii)),log(p(ind(ii))),zz));
        data.T(:,i)=interp1(gph(ind(ii)),T(ind(ii)),zz);
        data.rh(:,i)=interp1(gph(ind(ii)),rh(ind(ii)),zz);
        data.gph(:,i)=interp1(gph(ind(ii)),gph(ind(ii)),zz);
        data.u(:,i)=interp1(gph(ind(ii)),u(ind(ii)),zz);
        data.v(:,i)=interp1(gph(ind(ii)),v(ind(ii)),zz);
        
    end
    
    data.records=records;
    
end



function t=sqltime2datenumber(sql_time_str)

switch length(sql_time_str)
    case 19
        t=datenum(sql_time_str,'yyyy-mm-dd HH:MM:SS');
    case 10
        t=datenum(sql_time_str,'yyyy-mm-dd');
    case 14
        t=datenum(sql_time_str,'yyyymmddHHMMSS');
    case 8
        t=datenum(sql_time_str,'yyyymmdd');
end




