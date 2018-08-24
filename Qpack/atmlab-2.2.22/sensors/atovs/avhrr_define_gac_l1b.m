function [head, line] = avhrr_define_gac_l1b

% avhrr_define_gac_l1b Get AVHRR GAC L1B header and line definitions
%
% Reads the AVHRR L1B header and line definitions from HTML pages
% in ATMLAB_DATA.
%
% FORMAT
%
%   [head, line] = avhrr_define_gac_l1b
%
% OUT
%
%   head    struct
%   line    struct
%
% $Id: avhrr_define_gac_l1b.m 8340 2013-04-16 17:02:42Z gerrit $

% See ATMLAB_DATA_PATH/sensors/avhrr/README for how to regenerate this
% mat-file if necessary

matfile = fullfile(atmlab('ATMLAB_DATA_PATH'), 'sensors', 'avhrr', 'gac_version4.mat');
S = load(matfile);

% add reading information to structure so this need not be done on reading
% (every microsecond counts there because the function is called for every
% scanline, for every field)
for cat = {'head', 'line'}
    flds = fieldnames(S.(cat{1}));
    for fld = flds.';
        ws = S.(cat{1}).(fld{1}).Word_Size;
        nw = S.(cat{1}).(fld{1}).Number_of_Words;
        nbits = num2str(ws*8);
        switch S.(cat{1}).(fld{1}).Data_Type
            
            case 'i'
                S.(cat{1}).(fld{1}).read_type = ['int' nbits '=>int' nbits];
                S.(cat{1}).(fld{1}).read_size = nw;
                S.(cat{1}).(fld{1}).cast_type = ['int' nbits];
            case 'u'
                S.(cat{1}).(fld{1}).read_type = ['uint' nbits '=>uint' nbits];
                S.(cat{1}).(fld{1}).read_size = nw;
                S.(cat{1}).(fld{1}).cast_type = ['uint' nbits];                
            case 'c'
                S.(cat{1}).(fld{1}).read_type = 'uint8=>char';
                S.(cat{1}).(fld{1}).read_size = uint16(ws)*nw;
            case ''
                % should not be read
                S.(cat{1}).(fld{1}).read_type = 'uint8=>uint8';
                S.(cat{1}).(fld{1}).read_size = 1;
            otherwise
                error('atmlab:avhrr_define_gac_l1b', ...
                    'Field %s has unknown data type: %s', ...
                    fld{1}, S.(cat{1}).(fld{1}).Data_Type);
        end
    end
end

head = S.head;
line = S.line;

end
