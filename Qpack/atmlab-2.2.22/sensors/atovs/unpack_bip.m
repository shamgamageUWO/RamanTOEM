function out = unpack_bip(in)

% unpack_bip Unpacks Band-Interleaved by Pixel (BIP) data in uint16
%
% AVHRR GAC data Earth views are stored in Band-Interleaved by Pixel (BIP)
% 10-bit format. This function takes 32-bit words encoded with BIP and
% extracts the counts for all channels.
%
% FORMAT
%
%   counts = unpack_bip(bip_data)
%
% IN
%
%   bip_data      682-element uint32 (as returned by <a href="atmlab:help avhrr_gac_read_raw">avhrr_gac_read_raw</a>
%
% OUT
%
%   counts        409*5 uint16, counts for channels 1--5
%
% $Id: unpack_bip.m 8340 2013-04-16 17:02:42Z gerrit $

% FIXME: make this function vectorised

% words = uint32([...
%                 bin2dec('00000000000000000000001111111111'), ...
%                 bin2dec('00000000000011111111110000000000'), ...
%                 bin2dec('00111111111100000000000000000000'), ...
%                 ]);
words = uint32([1023, 1047552, 1072693248]);

bit_0_9 = bitand(words(1), in);
bit_10_19 = bitshift(bitand(words(2), in), -10);
bit_20_29 = bitshift(bitand(words(3), in), -20);

% sort it as bit_20_29 bit_10_19 bit_0_9 because the data are big-endian
% and like this, channel order will be contiguous (1 2 3 4 5 1 2 ... 4 5 -)
% see also NOAA KLM User's Guide Table 8.3.1.4.3.2-1.

backsorted = [bit_20_29 bit_10_19 bit_0_9]';
backsorted = backsorted(:);
ch1 = backsorted(1:5:end-5);
ch2 = backsorted(2:5:end);
ch3 = backsorted(3:5:end);
ch4 = backsorted(4:5:end);
ch5 = backsorted(5:5:end);
out = [ch1 ch2 ch3 ch4 ch5];
end
