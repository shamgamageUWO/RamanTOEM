function config = getCalibration(config)


% water vapor
if isempty(config.ini.dWV.constant)
    % open file
    fid = fopen(config.ini.dWV.calibFile);
    
    % read data
    C=textscan(fid,'%s','Delimiter','\n');
    
    % close file
    fclose(fid);
    
    % time vector
    t=zeros(size(C{1},1),1);
    % data
    cal=ones(size(C{1},1),1);
    % error
    error=zeros(size(C{1},1),1);
    for i=1:size(C{1},1)
        dummystr1=strsplit(C{1}{i},'\t');
        if ~isempty(dummystr1{1})
            t(i)=datenum(dummystr1{1});
            if length(dummystr1)<3
                cal(i,:)=str2double(dummystr1{2});
            elseif length(dummystr1)==3
                cal(i,:)=str2double(dummystr1{2});
                error(i)=str2double(dummystr1{3});
            end
        end
    end    
    % sort, just in case
    [t, ind] = sort(t);
    cal = cal(ind);
    
    % find closest calibration in time
    [~,ind]=nanmin(abs(t-config.t0));
%     ind = find(t<=config.t0,1,'last');
    config.ini.dWV.constant = cal(ind);
    config.ini.dWV.timeconstant = t(ind);
end

% temperature
if isempty(config.ini.dTE.constant)
    % open file
    fid = fopen(config.ini.dTE.calibFile);
    
    % read data
%     C=textscan(fid,'%s%n%n','Delimiter','\t');
    C=textscan(fid,'%s','Delimiter','\n');
    
    % close file
    fclose(fid);
    
    t=zeros(size(C{1},1),1);
    cal=ones(size(C{1},1),3);
    sModel=cell(size(C{1},1),1);
    for i=1:size(C{1},1)
        dummystr1=strsplit(C{1}{i},'\t');
        if ~isempty(dummystr1{1})
            t(i)=datenum(dummystr1{1});
            if length(dummystr1)<=3
                cal(i,:)=[str2double(dummystr1{2}) str2double(dummystr1{3}) NaN];
                sModel{i}='linear';
            elseif length(dummystr1)>3
                cal(i,:)=[str2double(dummystr1{2}) str2double(dummystr1{3}) str2double(dummystr1{4})];
                sModel{i}=dummystr1{5};
            end
        end
    end
    % sort, just in case
    [t, ind] = sort(t);
    cal = cal(ind,:);
    
    % find closest calibration in time
    [~,ind]=nanmin(abs(t-config.t0));
%     ind = find(t<=config.t0,1,'last');
    config.ini.dTE.constant = cal(ind,:)';
    config.ini.dTE.timeconstant = t(ind);
end

% BSR
if isempty(config.ini.dASR.constant)
    % open file
    fid = fopen(config.ini.dASR.calibFile);
    
    % read data
    C=textscan(fid,'%s%n','Delimiter','\t');
    
    % close file
    fclose(fid);
    
    % time vector
    t = datenum(C{1});
    
    % data
    cal = C{2};
    
    % sort, just in case
    [t, ind] = sort(t);
    cal = cal(ind);
    
    % find closest calibration in time
    [~,ind]=nanmin(abs(t-config.t0));
%     ind = find(t<=config.t0,1,'last');
    config.ini.dASR.constant = cal(ind);
    config.ini.dASR.timeconstant = t(ind);
end