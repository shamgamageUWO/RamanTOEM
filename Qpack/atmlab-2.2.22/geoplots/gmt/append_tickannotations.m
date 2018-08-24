function file = append_tickannotations(file,annotations)
%% APPEND_TICKANNOTATIONS change legend annotations to whatever you want.
%
% Purpose: function that makes it easy to change the legend annotations	to
% whatever you	want.
%
% IN: 1) file: '%s', the color table file in which to add the annotations.
%     2) annotations: cell, '%s' must have the same number of elements as there
%     are levels.
% 
% OUT: file '%s'
%
% Created by Salomon Eliasson
% $Id: append_tickannotations.m 7254 2012-01-31 22:40:28Z seliasson $

% READ OLD FILE
fid = fopen(file);
out={};
while 1
    s=fgetl(fid);
    if (s == -1) break; end
    out{end+1}=s;
end
fclose(fid);

% CHECK INPUT
assert(sum(~cellfun('isempty', regexp(out,'^[-+]?[0-9]*\.?[0-9]+'))) == length(annotations),...
    ['gmtlab:' mfilename ':input'],'Number of annotations must match number of ticks')

fid = fopen(file,'w'); x = 1;
for i = 1:length(out)
    if ~isempty(regexp(out{i},'^[-+]?[0-9]*\.?[0-9]+', 'once'))
        fprintf(fid,'%s',sprintf('%s ; %s\n',out{i},annotations{x}));
        x=x+1;
    else
        fprintf(fid,'%s\n',out{i});
    end
end
fclose(fid);