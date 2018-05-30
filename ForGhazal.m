function Y = ForGhazal


load('/Volumes/Sham_RALMO/RALMO_DATA/RALMO_Data/RALMO/20110909/S0.mat')


%  % open S0 matfile according to the given date
% datadirS3='/Volumes/Sham_RALMO/RALMO_DATA/RALMO_Data/RALMO';
% file = 'S0';
% Dateofthefolder =[yr  sprintf('%02.f',month) sprintf('%02.f',day)];
% folderpath = [datadirS3 filesep  Dateofthefolder filesep  file];
% load(folderpath);


g = hour(S0.GlobalParameters.Start);%S0.GlobalParameters.Start.FastCom );
Minute = minute(S0.GlobalParameters.Start);%(S0.GlobalParameters.Start.FastCom  );

starttime=find(g==19);
endtime=find(g==00);

% from 2300 to 2330Q.min1 = 00;

Y.Eb= S0.Channel(10).Signal(:,starttime:end);%20120717(:,1347:1377);%(:,961:990);
Y.alt = S0.Channel(10).Range;
Y.time = 1:length(Y.Eb(1,:));

x = Y.Eb;
y = Y.alt;
t = Y.time;
x = x';

 hFigure = figure;
 numberOfFrames = length(t);
 allTheFrames = cell(numberOfFrames,1);
vidHeight = 344;
vidWidth = 446;
 allTheFrames(:) = {zeros(vidHeight, vidWidth, 3, 'uint8')};
 allTheColorMaps = cell(numberOfFrames,1);
 allTheColorMaps(:) = {zeros(256, 3)};
myMovie = struct('cdata', allTheFrames, 'colormap', allTheColorMaps);
set(gcf);
%[x, y] = meshgrid(-3:.1:3,-3:.1:3);
%for frameIndex = 1 : numberOfFrames
    for i = 1:length(t)
    semilogx(x(i,:),y)
    pause(0.1)
    caption = sprintf('Frame #%d of %d, t = %.1f', i, numberOfFrames, t(i));
    
	title(caption, 'FontSize', 15);
    pause(1)
   drawnow;
	thisFrame = getframe(gca);
    end


Y.B1_counts = x(1:67,:);
Y.G1_counts= x(138:163,:);
Y.G2_counts= x(320:344,:);
Y.G3_counts= x(376:400,:);
