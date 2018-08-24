function found = wait_for_existence(file, timeout, varargin)

% wait_for_existence Wait until a particular file exists
%
% This m-file waits until a particular file exists. It returns at the
% timeout or when the file exists. Since this is implemented in pure Matlab
% and Matlab does not support interrupts, it actually waits small amounts
% of time and then checks whether the file exists, so it may wait a
% little bit longer tahn necessary.
%
% FORMAT
%
%   wait_for_existence(file, timeout)
%
% IN
%
%   file        string      /path/to/file
%   timeout     number      maximume time to wait
%   step        number      (optional) timestep
%
% OUT
%
%   found       logical     true if file was found, false otherwise
%
% $Id: wait_for_existence.m 6608 2010-10-27 18:25:56Z gerrit $

timestep = optargs(varargin, {0.1});
t = 0;
found = true;
while ~exist(file, 'file')
    t = t + timestep;
    if t>=timeout
        found = false;
        break
    end
    pause(timestep)
end
