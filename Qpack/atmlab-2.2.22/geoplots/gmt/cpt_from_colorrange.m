function filecpt = cpt_from_colorrange(colorrange)
% CPT_FROM_COLORRANGE configure colortable to desired color values and ranges
%
% Purpose: Make a colortable file with desired color values and ranges, that
% will be passed in the makecpt function that uses this input to make a color
% that can be used by GMT. i.e. makecpt -Ccolorrange.cpt etc.
%
% USAGE: e.g. file = cpt_from_colorrange(
%        struct('colors',{{{0.25,'255/255/255'},{0.75,'0/0/0'}}},...
%        'color_model','RGB'))
%
% IN: structure.
%    colors = {{value,'color'},{value2,'color2'},etc.}; (manditory)
%    color_model = 'RGB', 'HSV'
%
% OUT: filename
%
% Created by Salomon Eliasson
% $Id: cpt_from_colorrange.m 7954 2012-10-28 20:57:41Z seliasson $

% COLOR MODEL
if ~isfield(colorrange,'color_model')
    model = 'RGB';
else
    model = colorrange.color_model;
end
C = colorrange.colors;
assert((length(C)-1)>0,['gmtlab:' mfilename,':badInput'],...
    ['Either there is only one level'...
    'or the cell is constructed incorrectly (see help gmt_plot)'])

% format to print z-slice in cptfile
strtab = '\t%s\t%s\t%s\t';
    
filecpt = 'colorrange.cpt';
fid = fopen(filecpt,'w');
CO = onCleanup(@() fclose(fid));

% header
fprintf(fid,'%s\n','#cpt file created by: cpt_from_colorrange.m');
fprintf(fid,'%s\n',sprintf('#COLOR_MODEL = %s',model));

% make z-slices (val1 Red1 Green1 Blue1 val2 Red2 Green2 Blue2)
for ii = 1:length(C)-1
    val    = C{ii}{1}; val2 = C{ii+1}{1};
    assert(~isequal(val,val2),['gmtlab:' mfilename ':badInput'],...
           'consecutive z values may not have the same value')
    color  = splitstring(C{ii}{2},'/');
    color2 = splitstring(C{ii+1}{2},'/'); 
    fprintf(fid,[sprintf('%s',getAnnotFormat(val)) strtab],...
        val, color{1}, color{2}, color{3});
    fprintf(fid,[sprintf('%s',getAnnotFormat(val2)) strtab '\n'],...
        val2,color2{1},color2{2},color2{3});
end
