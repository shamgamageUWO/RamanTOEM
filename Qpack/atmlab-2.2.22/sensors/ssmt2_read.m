% SSMT2_READ   Read SSM/T-2 data file - old style.
%
% ************************************************
% *                DEPRECATED                    *
% *       Use ssmt2_read_ngdc instead!           *
% *                DEPRECATED                    *
% ************************************************
%
%    Reads an SSM/T-2 file into a structure and applies calibration.
%
%    This function is based on the ssmt2list C program written by Don Moss,
%    University of Alabama in Huntsville.
%
%    To get the exact timestamp for each scan of one scanline use:
%    datestr(S.recs(1).timestamp)
%
% FORMAT   S = ssmt2_read (filename, apply_calibration)
%        
% OUT   S   SSM/T-2 structure
%             Header information:
%               dsname   Dataset name
%               nscan    Number of scans
%               ngap     Data gaps
%               precal   Preflight calibration (not used)
%               apc      Antenna pattern correction coefficients
%               qc_earth QC of earth locations
%               qc_scene QC of scene data
%               qc_cal   Calibration QC flags
%             Data records S.recs():
%               orbit    Orbit number
%               scan     Scan number
%               t1x      ?
%               year     Year of first scan in file
%               doy      Day of year of first scan in file
%               ols      seconds since start of day
%               ts       milliseconds since ols
%               lat      Latitude earth location vector
%               lon      Longitude earth location vector
%               time     Scene time data
%               timestamp Scene time data as matlab datenum value
%               count    Scene raw count data (not returned if
%                        apply_calibration is set to true or not given)
%               temp     Scene calibrated antenna temperatures (not returned if
%                        apply_calibration is set to false)
%               rawcal   Raw calibration data (not used)
%               slopes   Calibration slopes
%               offset   Calibration intercepts
%               qc_earth QC flags of earth locations
%               qc_scene QC flags of scene data
%               qc_cal   Calibration QC flags
%               
%               
% IN    filename            Name of SSM/T-2 file
% OPT   apply_calibration   Pass false to get the raw count values,
%                           false: don't apply calibration
%                           true: apply calibration to retrieve BTs
%
% ************************************************
% *                DEPRECATED                    *
% *       Use ssmt2_read_ngdc instead!           *
% *                DEPRECATED                    *
% ************************************************

% 2009-11-20   Created by Oliver Lemke and Mathias Milz.

function S = ssmt2_read (filename, apply_calibration)

if nargin == 1
  apply_calibration = true;
end

if strcmp( filename(length(filename)-2:end), '.gz')
  uncompressed_filename = tempname(atmlab( 'WORK_AREA' ));
  cleanupObj = onCleanup(@() (delete(uncompressed_filename)));
  cmd = [ 'gunzip -cd ' filename ' > ' uncompressed_filename ];
  st = system (cmd);
  if st
    error ('atmlab:ssmt2_read', 'Failed to uncompress SSM/T-2 file %s', filename);
  end
  filename = uncompressed_filename;
end

% times of known switches in datasets
%dateswitch1 = datenum(1999, 2, 8, 17, 2, 00); %1,59.9808);
%dateswitch2 = datenum(2001, 9, 18, 14, 44, 0);% 44, 0096);


experimental_offset_calibration_xx = [0.2815 0.2915 0.2782 0.3762 1.1355];
experimental_offset_calibration_20 = [1 1 1 1 1];
experimental_offset_calibration_100 = [0.2 0.2 0.2 0.2 0.2];
%HDRSIZE = 692;
%DATSIZE = 692;
NPOS    = 28;
NCHAN   = 5;

ebcdic_ascii = [ ...
	'?','?','?','?','?','?','?','?','?','?','?','?','?','?','?', ...
	'?','?','?','?','?','?','?','?','?','?','?','?','?','?','?','?', ...
	'?','?','?','?','?','?','?','?','?','?','?','?','?','?','?','?', ...
	'?','?','?','?','?','?','?','?','?','?','?','?','?','?','?','?', ...
	' ','?','?','?','?','?','?','?','?','?','?','.','?','?','+','?', ...
	'?','?','?','?','?','?','?','?','?','?','?','?','?','?','?','?', ...
	'-','?','?','?','?','?','?','?','?','?','?','?','?','_','?','?', ...
	'?','?','?','?','?','?','?','?','?','?',':','#','@','?','=','?', ...
	'?','a','b','c','d','e','f','g','h','i','?','?','?','?','?','?', ...
	'?','j','k','l','m','n','o','p','q','r','?','?','?','?','?','?', ...
	'?','?','s','t','u','v','w','x','y','z','?','?','?','?','?','?', ...
	'?','?','?','?','?','?','?','?','?','?','?','?','?','?','?','?', ...
	'?','A','B','C','D','E','F','G','H','I','?','?','?','?','?','?', ...
	'?','J','K','L','M','N','O','P','Q','R','?','?','?','?','?','?', ...
	'?','?','S','T','U','V','W','X','Y','Z','?','?','?','?','?','?', ...
	'0','1','2','3','4','5','6','7','8','9','?','?','?','?','?','?' ...
    ];

fid = fopen (filename, 'rb', 'b');

if (fid == -1)
  error ('atmlab:ssmt2_read', 'Can''t open input file %s', filename);
end
cleanupObj2 = onCleanup(@() (fclose(fid)));

%%%%%%%%%% Read Header %%%%%%%%%%
%
S.dsname  = ebcdic_ascii(fread (fid, 44, 'uint8=>char'));

if (~strcmp(S.dsname(1:8), 'NSS.SMT2'))
  error ('atmlab:ssmt2_read', 'Not a valid SSM/T-2 file: %s', filename);
end

S.nscan   = fread (fid, 1, 'uint16');
S.ngap    = fread (fid, 1, 'uint16');
S.precal  = fread (fid, 108, 'uint8');

S.apc  = reshape (fread (fid, NPOS*NCHAN, 'uint16') / 100, NCHAN, NPOS)';

S.qc_earth = fread (fid, 1, 'uint16');
S.qc_scene = fread (fid, 1, 'uint16');
S.qc_cal   = fread (fid, NCHAN, 'uint16');

%%%%%%%%%% Read Data Records %%%%%%%%%%
%
recn = 0;
while (~feof (fid) && recn < S.nscan)
    recn = recn + 1;
    fseek (fid, recn*692, 'bof');

    rec.orbit = fread (fid, 1, 'uint32');
    
    if (~rec.orbit), break, end;
    
    rec.scan  = fread (fid, 1, 'uint16');
    rec.t1x   = fread (fid, 1, 'uint16');
    yyddd = fread (fid, 1, 'uint32');
    
    rec.year = floor(yyddd/1000);
    rec.doy = yyddd - rec.year*1000;
    
    if (rec.year < 50)
        rec.year = rec.year+2000;
    else
        rec.year=rec.year+1900;
    end;
    
    rec.ols   = fread (fid, 1, 'uint32');
    if (recn == 1)
        firstols = rec.ols;
    elseif (rec.ols < firstols)
        rec.ols = rec.ols + 86400;
    end
    
    rec.ts    = fread (fid, 1, 'uint32');

    latlon = reshape (fread (fid, NPOS*2, 'int16') / 128, 2, NPOS);
    rec.lat = latlon (1, :);
    rec.lon = latlon (2, :);
    
    timecount = reshape (fread (fid, (1+NCHAN)*NPOS, 'uint16'), 1+NCHAN, NPOS);
    rec.time  = timecount (1, :);
    rec.timestamp = datenum(rec.year,1,1) + rec.doy-1 + rec.ols/86400 + rec.time/1000/86400;
    if (recn == 1)
        firsttimestamp = rec.timestamp(1);
    end
    rec.count = timecount (2:NCHAN+1, :);
    
    rec.rawcal = fread (fid, 172, 'uint8');
    
    rec.slope  = fread (fid, NCHAN, 'int16')' / 10000;
    %FIXME OLE: The offset factor was changed at some point
    %rec.offset  = fread (fid, NCHAN, 'int16')' / 100;
    rec.offset = fread (fid, NCHAN, 'int16')' / 20;
    
    rec.qc_earth = fread (fid, 1, 'uint16');
    rec.qc_scene = fread (fid, 1, 'uint16');
    rec.qc_cal   = fread (fid, NCHAN, 'uint16')';
    
    %%%%%%%%%% Apply calibration %%%%%%%%%%
    %
    if (apply_calibration)
        if  firsttimestamp < 730159.709722
      % if  firsttimestamp < dateswitch1
            experimental_offset_calibration=experimental_offset_calibration_100;
        elseif firsttimestamp >= 730159.709722  && ...
                firsttimestamp < 731112.613889
%        elseif firsttimestamp >= dateswitch1  && ...
%                firsttimestamp < dateswitch2
            experimental_offset_calibration=experimental_offset_calibration_20;
        else
            experimental_offset_calibration=experimental_offset_calibration_xx;
        end
        for chan = 1:NCHAN
            rec.temp(chan,:) = rec.count(chan,:) * rec.slope(chan) ...
                + rec.offset(chan) * experimental_offset_calibration(chan);
        end
    end
    
    S.recs(recn) = rec;
    clear rec;
end

if (S.nscan ~= recn)
    error ('atmlab:ssmt2_read', ...
        'Premature end of file %s, expected %d records, found %d', ...
        filename, S.nscan, recn);
end
