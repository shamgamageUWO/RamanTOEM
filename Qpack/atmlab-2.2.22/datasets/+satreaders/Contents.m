% Function shells around reading routines for SatDataset framework.
%
% For info on the common format, see <a href="matlab:help SatDataset/reader">SatDataset/reader</a>.
%
% For the collocation toolkit, "common" reading routines are needed that
% fulfill a prescribed interface. The interface is as follows:
%
%  FORMAT
% 
%    data = satreaders.routine(file)
% 
%  IN
% 
%    file    string  Path to file. Must be full path, routines may need
%                    information obtained from the directory the file
%                    resides in.
% 
%  OUT
% 
%    data    struct  With fields:
%                    time    time in seconds since 00:00 UT
%                    lat     latitude in degrees, one column per viewing
%                            position, one row per scanline
%                    lon     longitude in [-180, 180] degrees, colums as for lat
%
% For examples, see existing implementations.
%
% For a complete list of existing data, see <a href="matlab:what satreaders">what satreaders</a>.
