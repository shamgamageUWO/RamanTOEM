function command = nearneighbor(file,in)
% NEARNEIGHBOR Appends options to GMT nearneighbor
%
% PURPOSE: Appends options to a short script and calls the GMT
%
% IN    file      %s              .ps-file created/appened to by command
%       in        struct          options here (see help gmt_plot)
%
% OUT   command   %s              string command to be used in system call
%
% Created by Salomon Eliasson
% $Id: nearneighbor.m 7908 2012-10-07 12:16:39Z seliasson $

nearneighbor = sprintf('nearneighbor -R');

nearneighbor = sprintf('%s -bic',nearneighbor); %for binary input

%location of file
if isfield(in,'ungriddedfile')
    nearneighbor = sprintf('%s %s',nearneighbor,in.ungriddedfile);
    nearneighbor = sprintf('%s -G%s',nearneighbor,file);
else
    error 'needs in.ungriddedfile '
end

%increment grid
if isfield(in,'increment')
    nearneighbor = sprintf('%s -I%s',nearneighbor,in.increment);
end

%average with adjasent gridpoint GMT default=4
nearneighbor = sprintf('%s -N1/1',nearneighbor);

%search radius
if isfield(in,'search')
    nearneighbor = sprintf('%s -S%s',nearneighbor,in.search);
else
    error 'needs in.search'
end

command = sprintf('%s >> %s.ps',nearneighbor,file(1:end-4));