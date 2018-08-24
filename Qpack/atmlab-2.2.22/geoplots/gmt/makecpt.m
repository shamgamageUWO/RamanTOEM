function file = makecpt(in)
% MAKECPT appends options to GMT makecpt
%
% PURPOSE: Appends options to a short script and calls the GMT
%
% IN      struct           options here (see help gmt_plot)
%
% NOTE    list of colortables found at /usr/lib/gmt/share/cpt/
%
% Created by Salomon Eliasson
% $Id: makecpt.m 7954 2012-10-28 20:57:41Z seliasson $

mkcpt = sprintf('makecpt -C%s',in.ctable);

if isfield(in,'tickval')
    mkcpt = sprintf('%s -Ttickvalues.txt',mkcpt);
else
    mi = in.datarange(1);
    mx = in.datarange(2);
    step = in.stepsize;
    fstr = sprintf('%s -T%s/%s/%s',mkcpt,...
        getAnnotFormat(mi),getAnnotFormat(mx),getAnnotFormat(step));
    mkcpt = sprintf(fstr,mi,mx,step);
end

mkcpt = sprintf('%s --COLOR_NAN=%s',mkcpt,in.color_nan);
mkcpt = sprintf('%s --COLOR_BACKGROUND=%s',mkcpt,in.color_background);
mkcpt = sprintf('%s --COLOR_FOREGROUND=%s',mkcpt,in.color_foreground);

file = 'ctable.cpt';
command = [mkcpt ' > ' file];

exec_system_cmd(command,gmtlab('verbosity'));