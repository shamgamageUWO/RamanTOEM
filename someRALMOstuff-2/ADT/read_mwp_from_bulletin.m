function data=read_mwp_from_bulletin(file,zz)

% default values
if nargin==1
    zz=[];
end

% open file
fid=fopen(file);

% get date
c=textscan(fid,'%n%s%n%*[^\n]','delimiter',';','headerlines',2);
t=datenum(c{2},'yyyymmddHHMMSS');
frewind(fid);

% read file
c=textscan(fid,'%n%n%n%n%n%n%n','delimiter',';','headerlines',4);

% assign data
z=c{2};
T=c{3};


% remove nan's and empty values
ind=find(isnan(T)==0 & isnan(z)==0);
z=z(ind);
T=T(ind);

% create time vector
t=t*ones(size(z));

if isempty(zz)==1
    data.t=t;
    data.z=z;
    data.T=T;
end


% create a matrix if zz is given as input
if isempty(zz)==0
    
    % find indices where a new profile starts and ends
    ind1=[0;find(diff(t)>0)]+1;
    ind2=[find(diff(t)>0);length(t)];
    
    % preallocate output
    data.t=nan(1,length(ind1));
    data.z=zz;
    [data.T]=deal(nan(length(zz),length(ind1)));
    
    % interpolate profiles to zz
    for i=1:length(ind1)
        
        data.t(i)=t(ind1(i));
        ind=ind1(i):ind2(i);
        if length(ind)<2
            continue
        end
        data.T(:,i)=interp1(z(ind),T(ind),zz);
        
    end
    
    
end
