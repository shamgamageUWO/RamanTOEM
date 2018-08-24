function timestamp=LicelFileTime(filename)

%Extracts the time in Matlab Time Stamp format from the Licel file name
%The function works with Licel files, or full path of Licel files, i.e.
%a080210...., or C:\data\a080210....
%The function will not work with files created before 2000. It will count
%them as created after 2000 year!

    %separates only the name of the file - if full path is as an input
%     [pathstr, name, ext, versn]=fileparts(filename);
    [pathstr, name, ext]=fileparts(filename);
    filename=[name,ext];
    %extracts the time from the Licel file name
    timestamp=sscanf(filename, '%*c %2d %1x %2d %2d %*c %2d %2d %2d')';
    timestamp=timestamp(1:6);
    timestamp(1)=timestamp(1)+2000; %adds 2000 to the year
    timestamp=datenum(timestamp);
end