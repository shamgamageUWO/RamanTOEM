% this code animates eah scan of each night. 
% Then you can see if these scabs are good or not. 
% For Raman channel: use: x = dataAY12.count and t = t = dataAY12.time;
% but for the Raylihg channels use the dataAY12.count.med or .low ones! 



clear all;
clc;
 dataAY12 = RawCounts.Fetch('date',20170302,'channel',18511);
  x = dataAY12.count.low;
  %x = dataAY12.count; % depending if you want it fo Raman or Rayligh. if it is for Raman you dont have low and high
 y = dataAY12.alt;
% t = dataAY12.time;
 t = dataAY12.time.med;
 
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
    pause(0.5)
   drawnow;
	thisFrame = getframe(gca);
    end
