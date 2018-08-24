function file = xtra_nan_legend(in)
% XTRA_NAN_LEGEND create an extra legend box for the missing values
%
% Purpose: To create an extra legend box for the missing values
%
% IN     struct:    in.outdir                where to put file
%                   in.color_nan             The color of NAN
%                
% OUT    %s         fileThe output-file location
%
% Created by Salomon Eliasson
% $Id: xtra_nan_legend.m 7221 2011-11-24 18:15:58Z seliasson $

%create nan.cpt for NaN colorbox
file = 'color_nan.cpt'; %save to local file
fid = fopen(file,'w');
fprintf(fid,'%s\n','#cpt file created by: xtra_nan_legend.m');
fprintf(fid,'%s\n','# Created for NaN colorbox');
fprintf(fid,'%s\n%s\n','#COLOR_MODEL = RGB','#');

if isfield(in,'color_nan')
    tmp = splitstring(in.color_nan,'/');
    str = sprintf('%s\t%s\t%s',tmp{1},tmp{2},tmp{3});
else
    str = '128\t128\t128';
end
fprintf(fid,'%i\t%s\t%i\t%s\t%s\n',1,str,2,str,';NaN');
fclose(fid);