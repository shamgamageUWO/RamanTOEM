function config = getCalibration(config)


% water vapor
if isempty(config.ini.dWV.constant)==1
    % open file
    fid = fopen(config.ini.dWV.calibFile);
    
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
    
    % find last calibration
    ind = find(t<=config.t0,1,'last');
    config.ini.dWV.constant = cal(ind);
    
end

% temperature
if isempty(config.ini.dTE.constant)==1
    % open file
    fid = fopen(config.ini.dTE.calibFile);
    
    % read data
    C=textscan(fid,'%s%n%n','Delimiter','\t');
    
    % close file
    fclose(fid);
    
    % time vector
    t = datenum(C{1});
    
    % data
    cal = [C{2} C{3}];
    
    % sort, just in case
    [t, ind] = sort(t);
    cal = cal(ind,:);
    
    % find last calibration
    ind = find(t<=config.t0,1,'last');
    config.ini.dTE.constant = cal(ind,:)';
    
end

% BSR
if isempty(config.ini.dASR.constant)==1
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
    
    % find last calibration
    ind = find(t<=config.t0,1,'last');
    config.ini.dASR.constant = cal(ind);
end