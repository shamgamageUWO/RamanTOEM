function vectcolors = list_colors(varargin)
% LIST_COLORS Creates a cell of rgb vectors
%
% PURPOSE:
%         From a cell of string arguments create a cell of rgb vectors for the
%         corresponding colors from the following table. Can also pass rogue rgb
%         vectors amongst color markers. e.g
%         strcolors = {'r',[.1 .1 .1],'k','b'}
% 
% IN      1) Either requested number of colors is given: list_colors('Ncolors',n)
%         
%         2) Or the colors are given in short string arguments. e.g 
%               list_colors('Colors',{'r','b'}), but the colors most be in the
%               colors list. see bellow for available colors
% 
% OUT     vector of rgb colors
% 
% Available colors (add more?)
% longname  | shortname | vector
%           |           |
% black     | 'k'       | [0,0,0]
% green     | 'g'       | [0,1,0]
% red       | 'r'       | [1,0,0]
% blue      | 'b'       | [0,0,1]
% cyan      | 'c'       | [0,1,1]
% magenta   | 'm'       | [1,0,1]
% yellow    | 'y'       | [1,1,0]
% white     | 'w'       | [1,1,1]
% red-purple| 'rp'      | [.8 .5 .8]
% grey      | 'gr'      | [.5 .5 .5]
% purple    | 'p'       | [.8 0 1]
% orange    | 'o'       | [1 .7 0]
% caucasian | 'ca'      | [1 .5 .5]
% pink      | 'pi'      | [1 .5 1]
% 
% default loop of colors: colors={'k','g','r','b','c','m','y','rp','gr','p','o','ca','pi'};
% 
% Created by Salomon Eliasson
% $Id: list_colors.m 6901 2011-05-02 07:40:00Z seliasson $

colors={'k','g','r','b','c','m','y','rp','gr','p','o','ca','pi'};
if ~nargin
    varargin = {'Ncolors',length(colors)};
end


%% LOAD CUSTOM OPTIONS:
for iopt = 1 : 2 : length(varargin)
    optname  = varargin{iopt};
    optvalue = varargin{iopt+1};
    switch lower(optname)
        case 'colors'
            strcolors=optvalue;
        case 'ncolors'
            k=1;
            strcolors=cell(optvalue,1);
            for ii=1:optvalue
                strcolors{ii}=colors{k};
                k=k+1;
                if k==length(colors),k=1;end
            end
    end
end


vectcolors=cell(length(strcolors),1);
for i=1:length(strcolors)                                                       % Create vectors of colors
    if ~ischar(strcolors{i})
        vectcolors{i}=strcolors{i};
    else
        switch strcolors{i}
            case 'k', vectcolors{i}=[0 0 0];   % black
            case 'g', vectcolors{i}=[0 1 0];   % green
            case 'r', vectcolors{i}=[1 0 0];   % red
            case 'b', vectcolors{i}=[0 0 1];   % blue
            case 'c', vectcolors{i}=[0 1 1];   % cyan
            case 'm', vectcolors{i}=[1 0 1];   % magenta
            case 'y', vectcolors{i}=[1 1 0];   % yellow
            case 'w', vectcolors{i}=[1 1 1];   % white
            case 'rp',vectcolors{i}=[.8 .5 .8];% redish purple
            case 'gr',vectcolors{i}=[.5 .5 .5];% grey
            case 'p', vectcolors{i}=[.8 0 1];  % purple
            case 'o', vectcolors{i}=[1 .7 0];  % orange
            case 'ca',vectcolors{i}=[1 .5 .5]; % caucasian
            case 'pi',vectcolors{i}=[1 .5 1];  % pink
            otherwise
                error('color: %s not in list. add color to mfile?',strcolors{i})
        end
    end
end
