function GlueCoef = LoadPretreatmentData03(config)

% [PretreatmentData, GlueCoef] = LoadPretreatmentData02
% Release 3 Version 2.1.

% Loads important pretreatment data.
%
% The function will try to load the required for data treatment data from
% the file 'iniDT.mat'. No such file will result in error. You can create
% it by running the function 'CreateFileiniDT.m'
%
% The function will try to load the required for gluing data from the file
% 'iniGlue.mat'. No such file will result in error. You can
% create it by running the function 'CreateFileiniGlue.mat'


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loads the file with glueing coefficients 
    
filename = config.GlueCoef_filename;
    
%This is required to load the file if not provided by gluecoef
if exist(filename, 'file') == 2
    load(filename);
    % the data is in a structure with a name 'gluecoef' !!!
    GlueCoef = gluecoef; 
else
   error('The file ''iniGlue.mat'' was not found.');
end

end