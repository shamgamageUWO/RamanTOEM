function [ year, month, day ] = getYMDFromDate( date )
%UNTITLED5 send in a date in the format of YYYYMMDD, get them back in
%seperate variables
%   Now using math.

    year = floor(date/1e4);
    month= floor((date-(year*1e4))/100);
    day = date-(year*1e4)-(month*100);
end

