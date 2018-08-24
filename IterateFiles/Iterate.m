
InputStructure;
% dates = [20110816];
% time = [18 19 20 21 22 23];
date_in = 20110909;
time = 18;

% for j = 1:length(dates)
%     date_in = dates(j);

    for i = 1:length(time)
        time_in = time(i);
%         if time_in < 0
%           continue   
%         else
        [X,R,Q,O,S_a,Se,xa,S_b,Error]=TRamanOEMIterateVersion( date_in,time_in,flag,Input);
%         end
    end

% end
