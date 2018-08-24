function outfile = combine_pdfs(pdffiles, options)
% COMBINE_PDFS Combine several PDF files on one page
%
% USAGE: outfile = combine_pdfs(pdffiles, options)
%
% E.g. file = combine_pdfs(files,struct('cols',[2 2 2 2 1],...))
%
% By default, pdf files are created in gmtlab('outdir')
%
% PURPOSE:  Merge several pdf's (one page each) into a pdf file
%
% EXTERNAL DEPENDENCIES: pdfinfo, pdflatex.
%
% IN:   pdffiles            cell: Each element contains the path to a
%                                 file.
%                           OR
%                           string: 'dir(<string>)' will get a list of files,
%                                   globbing is allowed:
%                             e.g pdffiles = figs/*{CAlow,CAmiddle,CAhigh}*
%
%
% OPT
%       % HOW TO READ VARIABLE DESCRIPTION OF OPTIONAL VARIABLES:
%         KEY:  in.variable   in: = expect input type, ex: = Explanation/Example, de: = Default value/behavior
%         NOTE: If "def" is missing for a variable it means the variable is not used by default
%
%         types: %s=character or string
%                %f=numeric/logical
%                {}=cell
%
%       Structure where the following fields are considered options:
%
%       options.cols
%            in:  %d
%            ex:  Number of columns per row. option.cols can also be a vector
%                 containing the number of columns that should be on each each row.
%                 In that case, the sum of this vector must match the number of pdf files.
%            def: 2
%       options.filename
%            in:  %s
%            ex:  name of output file
%            def: 'out.pdf'
%       options.outdir
%            in:  %s
%            ex:  directory for output
%            def: gmtlab('outdir')
%       options.vspace
%            in:  %f
%            ex:  space between rows in cm
%            def: 1
%       options.hspace
%            in:  %f
%            ex:  space between columns in cm
%            def: 1
%       options.rightPadding
%            in:  %f
%            ex:  padding to the right of a row in cm. Note: Needs one value per row.
%                 e.g., for 4 rows something like options.rightPadding=[1.7,1.7,0,0]
%            def: 1 
%       options.valign
%            in:  %s
%            ex:  vertical alignment. 'm' = middle, 'b' = bottom, 't'=top
%            def: 'm'
%       options.scale
%            in:  [%d,%d; etc]
%            ex:  scale individual figures. [filenumber,scale]
%            def: 1
%       options.title
%            in:  %s
%            ex:  title to be displayed above the combined pdfs
%            def: <none>
%       options.fontsize
%            in:  %s
%            ex:  E.g., '4cm' or '40pt'
%            def: 1/22 * rowwidth (but only relevent if title is given)
%       options.display
%            in:  %f
%            ex:  tries to open pdf file with 'gnome-open' or 'kde-open'
%                 if you are on a linux and 'open' if called from Mac
%            def: false
%       options.pdfviewer
%            in:  %s
%            ex:  Your pdf-viewing program of choice
%            def: Mac: 'open'
%                 Linux: 'gnome-open' or if that does work,
%                        'kde-open'. If neither exists, nothing is displayed
%       options.pdfcrop
%            in:  %f
%            ex:  Do a pdfcrop when finished putting everything together
%            def: false
%
% OUT:      outfile = The fullpath to the created pdf-file
%
% NOTE: The files are appended left to right and from top to bottom.


% 2013-04-10 Oliver Lemke and Salomon Eliasson.

if ~nargin, error(['atmlab:' mfilename],'Needs input. See help.'); end
if nargin == 1, options = struct; end

%% Set defaults and use them if not specified by user
default.cols        = 2;
default.vspace      = 1;
default.hspace      = 1;
default.valign      = 'm';
if isfield(options,'title') && ~isempty(options.title)
    default.filename = [sanitise(options.title),'.pdf'];
else
    default.filename = 'out.pdf';
end
default.outdir     = gmtlab('outdir');
default.secret_latex_spacing_tweak = 0.5;
default.display    = false;
default.title      = ''; 
default.pdfcrop    = false;
default.pdfviewer  = '';
options = optargs_struct(options, default);

%% Convert outdir to fullpath
options.outdir = path_replace_tilde(options.outdir);
if (isempty(options.outdir) || options.outdir(1) ~= filesep())
    options.outdir = fullfile(pwd(), options.outdir);
end

%% Sanity checks

assert(length(options.valign) == 1 && any('mbt' == options.valign), ...
    'atmlab:combine_pdfs', 'Vertical alignment must be either ''m'' or ''b''');
assert(isdir(options.outdir), 'atmlab:combine_pdfs', ...
    '%s does not exist', options.outdir);


%% If we got a regexp, use ls to get the file list
if ischar(pdffiles), files = dir(pdffiles); pdffiles = {files.name}; end

%% Make sure filenames are in a row vector and non-empty
pdffiles = pdffiles(:)';
pdffiles = pdffiles(~cellfun('isempty',pdffiles));
pdffiles = path_replace_tilde(pdffiles);
assert(~isempty(pdffiles), 'atmlab:combine_pdfs', 'List of input pdf files is empty');

%% We trust that the user can count! Not really, better double check here
if (length(options.cols) ~= 1 && sum(options.cols) ~= length(pdffiles))
    error (['atmlab:' mfilename]', ...
        'Number of plots (%d) doesn''t match sum of columns (%d)', ...
        length(pdffiles), sum(options.cols));
end

%% If cols is only one number, replicate it to match the number files
if (length(options.cols) == 1)
    options.cols = repmat(options.cols, ceil(length(pdffiles)/options.cols), 1);
end

%% Setup is complete, let's get cracking
layout = create_layout_from_pdffiles(pdffiles, options);

create_pdf_from_layout_with_latex(layout, options);

outfile = fullfile(options.outdir, options.filename);

%% Display output
% This only works for the following pre-programmed options
if options.display && isempty(options.pdfviewer)
    if ismac
        exec_system_cmd(sprintf('open %s',outfile));
    elseif isunix
        [~,b1]=system('which gnome-open');
        [~,b2]=system('which kde-open');
        if ~isempty(b1)
            exec_system_cmd(sprintf('gnome-open %s &',outfile));
        elseif ~isempty(b2)
            exec_system_cmd(sprintf('kde-open %s &',outfile));
        end
    end
elseif options.display
    exec_system_cmd(sprintf('%s %s',options.pdfviewer,outfile));
end

end

%% Only subfunctions allowed after this point!!!

function layout = create_layout_from_pdffiles(pdffiles, options)

% Create a fancy regexp that gives us width and height from pdfinfo output
regx = 'Page size: +(?<width>\d.+).x.(?<height>\d.+) pts';

col = 1; row = 1;filenum=1;
for P = pdffiles
    info  = exec_system_cmd(sprintf('pdfinfo ''%s''', P{1}), gmtlab('VERBOSITY'));
    
    % Great, pdfinfo uses BigPoints as a unit. Let's throw in some fancy
    % numbers and hope we end up with centimeters after that (DPI*INCH).
    % This might break for some PDFs, better keep your fingers crossed.
    psize =  structfun(@(x) str2double(x)/72*2.54, ...
        regexp(info{1},regx, 'names'), ...
        'uniformoutput', 0);
    
    % --------------
    % Apply scaling
    % --------------
    if isfield(options,'scale') && ~isempty(options.scale(options.scale(:,1)==filenum,2))
        sc = options.scale(options.scale(:,1)==filenum,2);
    else
        sc = 1;
    end
    layout.plotsbyrow{row}(col) = struct('height', psize.height*sc, ...
        'width', psize.width*sc, ...
        'file', P{1});
    
    col = col + 1;
    if (col > options.cols(row) ...
            || length([layout.plotsbyrow{:}]) == length(pdffiles))
        col = 1;
        R = layout.plotsbyrow(row);
        layout.rowwidth(row) = sum([R{:}.width]) ...
            + options.hspace*(length(R{:})-1) ...
            + options.secret_latex_spacing_tweak*length(R{:});
        layout.rowheight(row) = max([R{:}.height]);
        row = row + 1;
    end
    filenum = filenum+1;
end

end

function file = create_pdf_from_layout_with_latex(layout, options)

tmpfolder = create_tmpfolder();

%% Hook up a cleanup callback.
% In case we screw up the LaTeX run, we don't want to leave any
% evidence behind.
c = onCleanup(@() delete_tmpfolder(tmpfolder));

%% Assemble our pretty tex file
file = fullfile(tmpfolder, 'out.tex');
fid = fopen(file,'w');
Cob = onCleanup(@(x) fclose(fid));

fprintf(fid,'\\documentclass[a4paper,10pt]{report}\n');

margin=0.1; %cm
if ~isempty(options.title)
    options = optargs_struct(options,struct('fontsize',sprintf('%gcm',1/20 * max(layout.rowwidth)))); % cm
    tmp=regexp(options.fontsize,'(?<fz>\d+\.?\d*)(?<unit>.+)','names');
    fz=str2double(tmp.fz);
    unit=tmp.unit;
else
    fz=0;
end

fprintf(fid,['\\usepackage[margin=%gcm,paperwidth=%gcm,' ...
    'paperheight=%gcm]{geometry}\n'], ...
    margin, ...
    max(layout.rowwidth) + 2*margin, ...
    sum(layout.rowheight) + 2*margin + 2*fz ...
    + options.vspace*(length(layout.rowheight)));

fprintf(fid,'\\pagestyle{empty}\n');
fprintf(fid,'\\usepackage{graphicx}\n');
fprintf(fid,'\\usepackage{anyfontsize}\n');
fprintf(fid,'\\setlength{\\parindent}{0in}\n');
fprintf(fid,'\\begin{document}\n');
fprintf(fid,'\\centering\n');
if ~isempty(options.title)
    if ~any(ismember(unit,{'cm','mm','pt'})), error(['atmlab:' mfilename],'Don''t know fontsize unit "%s"',unit),end
    fprintf(fid,'\\begin{minipage}[%s]{%gcm}\n', options.valign, max(layout.rowwidth));
    fprintf(fid,'\\begin{center}\n');
    fprintf(fid,'{\\fontsize{%g%s}{%g%s}\\selectfont \\sffamily %s}\n',...
        fz,unit,1.2*fz,unit,strrep(options.title,'_','\_'));
    fprintf(fid,'\\end{center}\n');
    fprintf(fid,'\\end{minipage}\n');
    fprintf(fid, '\\vspace{%gcm}\\\\\n', options.vspace);
end

row = 1; filenum = 1;
for R = layout.plotsbyrow
    col=1;
    for P = R{:}
        fprintf(fid,'\\begin{minipage}[%s]{%gcm}\n', options.valign, P.width);
        tmpplotname=sprintf('plot%d.pdf', filenum);
        mvplotcmd{filenum}=sprintf('cp ''%s'' ''%s/%s''', P.file, tmpfolder, tmpplotname); %#ok
        if isfield(options,'scale') && ~isempty(options.scale(options.scale(:,1)==filenum,2))
            strscale = num2str(options.scale(options.scale(:,1)==filenum,2));
        else
            strscale = '1';
        end
        fprintf(fid,'\\includegraphics[scale=%s]{%s}\n', strscale,tmpplotname);
        fprintf(fid,'\\end{minipage}\n');
        if (col ~= length(R{:}))
            fprintf(fid,'\\hspace{%gcm}\n', options.hspace);
        elseif isfield(options,'rightPadding')
            fprintf(fid,'\\hspace{%gcm}\n', options.rightPadding(row));
        end
        col = col+1;
        filenum=filenum+1;
    end
    if (row ~= length(layout.rowheight))
        fprintf(fid, '\\vspace{%gcm}\\\\\n', options.vspace);
    end
    row = row+1;
end
fprintf(fid,'\\end{document}\n');

%% Hand the TeX file over to pdflatex
exec_system_cmd(mvplotcmd, gmtlab('VERBOSITY'));
exec_system_cmd(sprintf('cd %s && pdflatex -interaction nonstopmode out.tex', ...
    tmpfolder), ...
    gmtlab('VERBOSITY'));

file = fullfile(options.outdir, options.filename); 
exec_system_cmd(sprintf('cd %s && mv -f out.pdf ''%s''', ...
    tmpfolder, file), ...
    gmtlab('VERBOSITY'));

if options.pdfcrop
    [message,test]=exec_system_cmd(sprintf('pdfcrop %s',file),gmtlab('VERBOSITY'));
    if logical(test)
        error(['atmlab' mfilename],'There was a problem with pdfcrop: %s',message{1})
    end
    exec_system_cmd(sprintf('mv %s-crop.pdf %s',file(1:end-4),file),gmtlab('VERBOSITY'));
end

end
