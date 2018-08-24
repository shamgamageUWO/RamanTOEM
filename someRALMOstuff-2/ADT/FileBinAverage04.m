function data = FileBinAverage03(S, chanlist, BinsOrVector)
% data = FileBinAverage02(FileNames, chanlist, bins, bkgbins)
% ver.2.0. faster than ver.1.0 
% Uses the function 'LoadLidar_Auto_WVAE'
% Bkg correction, file average, bin average
% Inputs: 
% FileNames - cell array of files - one file would be {'full file name'}
% chanlist  = {'Es','Eb','Mo'} or {'Es'}
% BinsOrVector  - bins over to average, or an altitude vector in [m]


d   = S;

r   = d.(chanlist{1}).Combined.Range;    % range vector
ncol= length(d.GlobalParameters.Name);     % n columns/files to average over
row = length(r);
s   = zeros(row,ncol);

data.GlobalParameters.Station   = d.GlobalParameters.Station;
data.GlobalParameters.HeightASL = d.GlobalParameters.HeightASL;
data.GlobalParameters.Latitude  = d.GlobalParameters.Latitude;
data.GlobalParameters.Longitude = d.GlobalParameters.Longitude;
data.nfiles = ncol;      % number of averaged files
data.tstart = datenum(d.GlobalParameters.Start,'dd-mmm-yyyy HH:MM:SS');    % start time - time of start of first averaged file
data.tstop  = datenum(d.GlobalParameters.End,'dd-mmm-yyyy HH:MM:SS');;     % stop time - the tima of record of the last file

clear d;

% bin averaging
if length(BinsOrVector) == 1
    r_avebin = BinAverage(r,BinsOrVector);
elseif length(BinsOrVector)>1
    r_avebin = BinAverageFAV(r, BinsOrVector, 3.75);
end
data.r      = r_avebin;  % range vector - hopefully equal to all channels 

for i = 1:length(chanlist)
    for k=1:size(S.(chanlist{i}).Combined.Signal,2)
%     s = temp.(chanlist{i});
    s = S.(chanlist{i}).Combined.Signal(:,k);
    % file average
    s_ave = FileAverage02(s, ncol);
    clear s
    % bin average
    if length(BinsOrVector) == 1
        s_avebin = BinAverage(s_ave,BinsOrVector);
    elseif length(BinsOrVector)>1
        s_avebin = BinAverageFAV(s_ave, BinsOrVector, 3.75);
    end
    clear r s_ave
    %assign result
    data.(chanlist{i})(:,k)  = s_avebin;
    clear s_avebin r_avebin
    end
end

end % function 