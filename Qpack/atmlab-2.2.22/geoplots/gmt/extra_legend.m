function file = extra_legend(in)
% EXTRA_LEGEND create an extra legend box for the missing values
%
% Purpose: To create an extra legend box for the missing values
%
% IN     struct:
%                   in.xtra_legend.type = 'nan','fg',or 'bg'
%                   in.xtra_legend.name = e.g. 'NaN
%                
% OUT    %s         fileThe output-file location
%
% Created by Salomon Eliasson
% $Id: extra_legend.m 8362 2013-04-20 18:30:35Z seliasson $
if ~isstruct(in.extra_legend)
    % then you have provided the psscale comamnd directly
    file = '';
    return
end
X = in.extra_legend;
assert(all(isfield(X,{'name','type'})),['atmlab:' mfilename],'Must have fields ''name'' and ''type''')
%create nan.cpt for NaN colorbox
switch X.type
    case 'nan'
     file = 'color_nan.cpt'; %save to local file
     tmp = splitstring(in.color_nan,'/');
    case 'fg'
      file = 'color_fg.cpt'; %save to local file
        tmp = splitstring(in.color_foreground,'/');  
    case 'bg'
      file = 'color_bg.cpt'; %save to local file
      tmp = splitstring(in.color_background,'/');  
    otherwise
        error(['atmlab' mfilename ':badInput'],'choose type nan,fg, or bg')
end
str = sprintf('%s\t%s\t%s',tmp{1},tmp{2},tmp{3});

fid = fopen(file,'w');
fprintf(fid,'%s\n',['#cpt file created by: ' mfilename]);
fprintf(fid,'%s\n','# Created for extra colorbox');
fprintf(fid,'%s\n%s\n','#COLOR_MODEL = RGB','#');
fprintf(fid,'%i\t%s\t%i\t%s\t%s\n',1,str,2,str,[';' X.name]);
fclose(fid);