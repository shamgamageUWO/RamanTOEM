% READ_OPENMTP_UTH   Read Open MTP UTH data file.
%
%    Reads an Open MTP UTH file into a structure.
%
% FORMAT   S = read_openmtp_uth (filename)

function S = read_openmtp_uth (filename)

if strcmp( filename(length(filename)-2:end), '.gz')
  uncompressed_filename = tempname(atmlab( 'WORK_AREA' ));
  cleanupObj = onCleanup(@() (delete(uncompressed_filename)));
  cmd = [ 'gunzip -cd ' filename ' > ' uncompressed_filename ];
  st = system (cmd);
  if st
    error ('atmlab:read_openmtp_uth', 'Failed to uncompress OpenMTP UTH file %s', filename);
  end
  filename = uncompressed_filename;
end

fid = fopen (filename, 'rb', 'b');
cleanupObj2 = onCleanup(@() (fclose(fid)));

if (fid == -1)
  error ('Can''t open input file')
end

%%%%%%%%%% Read Header %%%%%%%%%%
%
S.hdr = fread (fid, 542, 'uint8=>char')';

%%%%%%%%%% Read Segment Header %%%%%%%%%%
%
S.slot = fread (fid, 1, 'int32');
S.time = fread (fid, 1, 'int32');
S.jday = fread (fid, 1, 'int32');
S.year = fread (fid, 1, 'int32');
S.pltfrm = fread (fid, 4, 'uint8=>char')';
fread (fid, 8, 'int8');  %spares
S.fname = fread (fid, 4, 'uint8=>char')';
S.ptime = fread (fid, 1, 'int32');
S.palg = fread (fid, 32, 'uint8=>char')';
S.pvers = fread (fid, 1, 'int32');
S.nseg = fread (fid, 1, 'int32');
S.mqcflg = fread (fid, 1, 'uint8');
fread (fid, 15, 'int8');  %spares
S.qtotal = fread (fid, 1, 'int32');
S.dist = fread (fid, 1, 'uint8');
fread (fid, 3, 'int8');  %spares

% Preallocation commented out because it's slighty faster without
%
% S.seglin = zeros(1, S.nseg, 'int32');
% S.segcol = zeros(1, S.nseg, 'int32');
% S.selpix = zeros(1, S.nseg, 'int32');
% S.segpix = zeros(1, S.nseg, 'int32');
% S.selat = zeros(1, S.nseg, 'single');
% S.selon = zeros(1, S.nseg, 'single');
% S.sheight = zeros(1, S.nseg, 'int32');
% S.swidth = zeros(1, S.nseg, 'int32');
% 
% S.cenlat = zeros(1, S.nseg, 'single');
% S.cenlon = zeros(1, S.nseg, 'single');
% S.uth = zeros(1, S.nseg, 'single');
% S.csr = zeros(1, S.nseg, 'single');
% S.locq = zeros(1, S.nseg, 'int32');
% S.uthq = zeros(1, S.nseg, 'int32');
% S.acqrej = zeros(1, S.nseg, 'uint8');
% S.mqcrej = zeros(1, S.nseg, 'uint8');
% S.mqcmod = zeros(1, S.nseg, 'uint8');

%%%%%%%%%% Read Results Blocks %%%%%%%%%%
%
recn = 0;
while (~feof (fid) && recn < S.nseg)
    recn = recn + 1;
    
    S.seglin(recn) = fread (fid, 1, 'int32');
    S.segcol(recn) = fread (fid, 1, 'int32');
    S.selpix(recn) = fread (fid, 1, 'int32');
    S.segpix(recn) = fread (fid, 1, 'int32');
    S.selat(recn) = fread (fid, 1, 'float32');
    S.selon(recn) = fread (fid, 1, 'float32');
    S.sheight(recn) = fread (fid, 1, 'int32');
    S.swidth(recn) = fread (fid, 1, 'int32');
    nres = fread (fid, 1, 'int32');
    
    assert (nres==1, 'atmlab:read_openmtp_uth', ...
        'Number of result blocks expected to be 1 in OpenMTP UTH file %s', filename);
    
    S.cenlat(recn) = fread (fid, 1, 'float32');
    S.cenlon(recn) = fread (fid, 1, 'float32');
    S.uth(recn) = fread (fid, 1, 'float32');
    S.csr(recn) = fread (fid, 1, 'float32');
    fread (fid, 4, 'int8');  %spares
    S.locq(recn) = fread (fid, 1, 'int32');
    S.uthq(recn) = fread (fid, 1, 'int32');
%    fread (fid, 8, 'int8');  %spares
    fread (fid, 40, 'int8');  %spares
    S.acqrej(recn) = fread (fid, 1, 'uint8');
    S.mqcrej(recn) = fread (fid, 1, 'uint8');
    S.mqcmod(recn) = fread (fid, 1, 'uint8');
    fread (fid, 1, 'int8');  %spares
end
