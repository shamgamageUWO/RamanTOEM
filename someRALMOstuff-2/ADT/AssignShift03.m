function data = AssignShift03(data,config)

% data = AssignShift03(data,config)
% Release 3 Version 3
%
% Shifts the PC signal with predefined "delay" bins and reassigns the
% data in new data structure with the names of the data i.e. Es, WV or N2.
%
% Inputs:
% -------
%   data                - current data structure from LoadLicel
%   PretreatmentData    - loaded from 'LoadPretreatmentData02.m'
% 
% Outputs:
% --------
%   data - the data structure from the input with shifted AD to PC signals
% 

delay       = config.iniDT.BinShift;
StartBin    = config.iniDT.BinStart;
StopBin     = config.iniDT.BinStop;
ChanName    = config.iniDT.ChannelNames;
ChanList    = 1:length(ChanName);

for k = 1:length(ChanList)
    
    if data.Channel(ChanList(k)).isPhotonCounting
        Mode = 'Photon';
        delay1 = 0;
        delay2 = delay;
    else
        Mode = 'Analog';
        delay1 = delay;
        delay2 = 0;
    end
    
    % Assign data
    data.(ChanName{k}).(Mode) = data.Channel(ChanList(k));
    
    % Recalculates the number of bins
    data.(ChanName{k}).(Mode).Bins = ...
        data.(ChanName{k}).(Mode).Bins - delay;

    data.(ChanName{k}).(Mode).Signal = ....
        data.(ChanName{k}).(Mode).Signal(1+delay1:end-delay2,:);
    data.(ChanName{k}).(Mode).Signal = ...
        data.(ChanName{k}).(Mode).Signal(StartBin:StopBin,:);
    % Reestimates the range
    data.(ChanName{k}).(Mode).Range = ...
        data.(ChanName{k}).(Mode).Range(1:end-delay,:);
    data.(ChanName{k}).(Mode).Range = ...
        data.(ChanName{k}).(Mode).Range(StartBin:StopBin,:);
    
    % Stores the initial signal for further refference
    data.(ChanName{k}).(Mode).IniSignal = ...
        data.(ChanName{k}).(Mode).Signal;
    
end

% Removes the field ChannelName from data
data = rmfield(data,'Channel');
%data = rmfield(data,'GlobalParameters');

end