function command = psscale(file,in)
% PSSCALE Appends options to GMT psscale
%
% PURPOSE: Appends options to a short script and calls the GMT
%
% IN    file      %s              .ps-file created/appened to by command
%       in        struct          options here (see help gmt_plot)
%
% OUT   command   %s              string command to be used in system call
%
% Created by Salomon Eliasson
% $Id: psscale.m 8453 2013-05-27 19:06:41Z seliasson $

assert(isfield(in,'cptfile'),['gmtlab:' mfilename ':badInput'],'needs in.cptfile')

psscale = sprintf('psscale');
if isfield(in,'position')
    psscale = sprintf('%s -D%s',psscale,in.position);
else
    psscale = sprintf('%s -D%s/%s/%s/%s%s',...
        psscale,num2str(in.xpos),num2str(in.ypos),num2str(in.length),num2str(in.width),...
        in.orientation);
    
    %may only append 'h'
    if strcmp(in.orientation,'v'), psscale = psscale(1:end-1); end 
end

if ( isfield(in,'tick_annotations') && ~isempty(in.tick_annotations) ) || ...
        ( isfield(in,'equalboxwidth') && in.equalboxwidth ) || ...
        any(isfield(in,{'box_spacing','tick_centering'}))
    
    psscale = sprintf('%s -L',psscale);
    
    if isfield(in,'box_spacing')
        % tickspacing (annotation every xth contour), unit (dispay with legend)
        psscale = sprintf('%s%g',psscale,in.box_spacing);
    end
    if isfield(in,'tick_centering')
        psscale = sprintf('%si',psscale);
    end
end

psscale = sprintf('%s %s',psscale,in.plotPlacement);

% selects Overlay plot mode and assume more pscode will be appended later
psscale = sprintf('%s -O -K',psscale);

if in.sidebar %i.e the triangles bellow the min and above the max values
    switch in.sidebar
        case 1
            str = '-Eb';
        case 2
            str = '-Ef';
        case 3
            str = '-E';
        otherwise
            error(['gmtlab:' mfilename ':input'],...
                'error in determining sidebar')
    end
    psscale = sprintf('%s %s',psscale,str);
end

if isfield(in,'tick_spacing')
    psscale = sprintf('%s -B%g:"%s":/:"%s":',psscale,in.tick_spacing,in.xunit,in.unit);
else
    psscale = sprintf('%s -B:"%s":/:"%s":',psscale,in.xunit,in.unit);
end

psscale = sprintf('%s -C%s',psscale,in.cptfile);

if isfield(in,'shift_tick_annotations')
    psscale = sprintf('%s --ANNOT_OFFSET_PRIMARY=%s',psscale,in.shift_tick_annotations);
end

if isfield(in,'font_size')
    psscale = sprintf('%s --ANNOT_FONT_SIZE_PRIMARY=%s',psscale,num2str(in.font_size));
end

if isfield(in,'tick_length')
    psscale = sprintf('%s --TICK_LENGTH %s',psscale,num2str(in.tick_length));
end
if isfield(in,'tick_annotation_format')
    psscale = sprintf('%s --D_FORMAT=%s',psscale,in.tick_annotation_format);
end

command = sprintf('%s >> %s.ps',psscale,file);