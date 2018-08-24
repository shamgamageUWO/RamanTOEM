function [corners,nregions,regionstrlong] = getPredefinedRegions(regionstr)
% GETPREDEFINEDRREGIONS Returns lat/lon corner values of predefined regions
%
% IN:    <none>        If nothing is input the list of currently available 
%                      regions are shown. Build on this list in
%                      retrieve_reginfo.m if you want other regions 
%        regionstr     {'%s'}    Use one or more regions listed in retrieve_reginfo.m
%
% OUT: corners = [blcorner,trcorner;blcorner,trcorner]
%      nregions = number of full regions (not necessarily size(corners,2))
%      regionstrlong = a string of the longname of the regions.
%
% NOTE:
% - Regions, including all of the AR4 IPCC regions (ch 11), can be chosen
%   from the set of regions (see list below). The code defining the regions
%   is in the subfunction (retrieve_reginfo) to this function. 
%
% current LIST of regions:
%    - Make sure to update this list if you add a region to the subfunction!!
%    Allregions = {'earth','global','total','tropics','boreal_trop','austral_trop',...
%        'sepdz','seadz','ocean_sub','seapdz_boreal','twp','trop_cont','conv_sa','conv_af',...
%        'swl','kurosho','gulfstr','nwl','westerlies','swe','aus','polar',...
%        'waf','eaf','saf','sah','neu','sem','nas','cas','tib','eas','sas',...
%        'sea','ala','cgi','wna','cna','ena','cam','amz','ssa','nau','sau',...
%        'car','ind','med','tne','npa','spa','arc','ant'};
%
%
% USAGE      [details,N,regionstrings]  = predefinedRegions   %if you want
%                                                               the list of
%                                                               regions
%
%            [corners,nregions,regionstrlong] = predefinedRegions(regionstr)
%            % regular use to get corners of a region
%
% Created by Salomon Eliasson
% $Id: getPredefinedRegions.m 7187 2011-10-29 19:46:25Z seliasson $

if ~nargin
    corners       = retrieve_reginfo('list');
    fn            = fieldnames(corners);
    nregions      = length(fn);
    regionstrlong = cell(1,length(fn)); i =1;
    for F = fn'
        regionstrlong{i} = corners.(F{1}).longname;
        i = i+1;
    end
    return
end
assert(iscell(regionstr)||ischar(regionstr),...
    'atmlab:predefinedRegions:badInput','input must be a cell of strings (region names)')

if ~iscell(regionstr)
    regionstr = {regionstr};
end

k=1;
corners       = zeros(10*length(regionstr),4);
regionstrlong = cell(1,length(regionstr));
nregions      = zeros(1,length(regionstr));

b = [];
for i = 1:length(regionstr) % loop over regionstrings
    test = regexp(regionstr,'/');
    if length(test{1})==3
        x            = sscanf(regionstr{1},'%f/%f/%f/%f');
        corners(i,1) = x(3); 
        corners(i,2) = x(1); 
        corners(i,3) = x(4);
        corners(i,4) = x(2);
        regionstrlong{i} = '';
        nregions(k)      = 1;
        k = k+1;
        continue
    end
    
    assert(ismember(regionstr{i},fieldnames(retrieve_reginfo('list'))),...
    'atmlab:predefinedRegions:notFound','region: %s is not in list',regionstr{i})

    [blcorner,trcorner,regionstrlong{i}]=retrieve_reginfo(regionstr{i});
    len = size(blcorner,1);
    
    corners(k:k+len-1,1:2) = blcorner;
    corners(k:k+len-1,3:4) = trcorner;
    nregions(i) = size(b,1)+size(blcorner,1);b=blcorner; % index of the last box in one region
    k = k+len;
end

corners = corners(1:k-1,:,:,:);

%%%%%%%%%%%%%%%%%
% SUBFUNCTIONS
% ||||||||
% VVVVVVVV

function [blcorner,trcorner,regionstrlong]=retrieve_reginfo(regionstr)
%% RETRIEVE_REGINFO returns infor required to work with predefined regions
%
% IN: regionstr   %s       Stringname of region. Check list of regions in
%                          Allregions (further down). If regionstr =
%                          'list', the function will list all configured
%                          regions
%
% OUT: 1) bottom left corners of boxes [lat,lon]
%      2) top right corners of boxes   [lat,lon]
%      3) long stringname of the region
%
% Created by Salomon Eliasson
% $Id: getPredefinedRegions.m 7187 2011-10-29 19:46:25Z seliasson $

assert(nargin==1,'atmlab:retrieve_reginfo:badInput','needs input')
if strcmp(regionstr,'list')
    % Make sure to update this list if you add a region!!
    Allregions = {'earth','global','total','tropics','boreal_trop','austral_trop',...
        'sepdz','seadz','ocean_sub','seadz_boreal','sepdz_boreal','twp','trop_cont','conv_sa','conv_af',...
        'swl','kurosho','gulfstr','ocean_sub_boreal','nwl','westerlies','swe','aus','polar',...
        'waf','eaf','saf','sah','neu','sem','nas','cas','tib','eas','sas',...
        'sea','ala','cgi','wna','cna','ena','cam','amz','ssa','nau','sau',...
        'car','ind','med','tne','npa','spa','arc','ant'};
    for A = Allregions
        [blcorner,trcorner,regionstrlong]=retrieve_reginfo(A{1});
        Allreg.(A{1}).shortname = A{1};
        Allreg.(A{1}).longname  = regionstrlong;
        Allreg.(A{1}).corners   = [blcorner, trcorner];
    end
    blcorner=Allreg;trcorner=[];regionstrlong='';
    return
end

switch lower(regionstr)
    case {'earth','global'}
        regionstrlong='earth';
        blcorner = [-90,-180]; trcorner = [90,180];
    case 'total'
        regionstrlong='total';
        blcorner = [-60,-180]; trcorner = [60,180];
    case 'tropics'
        regionstrlong='tropics';
        blcorner = [-30,-180]; trcorner = [30,180];
    case 'boreal_trop'
        regionstrlong='Tropical Northern half';
        blcorner = [0,-180]; trcorner = [30,180];
    case 'austral_trop'
        regionstrlong='Tropical Southern half';
        blcorner = [-30,-180]; trcorner = [0,180];
    case 'sepdz'
        regionstrlong ='South East Pacific Dry Zone';
        blcorner = [-27,-110;-18,-130]; trcorner = [-18,-72;2,-82];
    case 'seadz'
        regionstrlong ='South East Atlantic Dry zone';
        blcorner = [-30,-15;-20,-30]; trcorner = [-5,10;-5,-15];
    case 'sepdz_boreal'
        regionstrlong ='South East Pacific boreal Dry zone';
        blcorner = [-15,-180]; trcorner = [0,-80];
    case 'seadz_boreal'
        regionstrlong ='South East Atlantic boreal Dry zone';
        blcorner = [-23.5,-30]; trcorner = [-5,10];
    case 'ocean_sub'
        % this is both seadz and sepdz merged
        regionstrlong ='Subsidence zones of the South East Pacific and South East Atlantic';
        [a,b] = retrieve_reginfo('sepdz');
        [c,d] = retrieve_reginfo('seadz');
        blcorner = cat(1,a,c);
        trcorner = cat(1,b,d);
    case 'ocean_sub_boreal'
        % this is both seadz and sepdz merged
        regionstrlong ='Subsidence zones boreal of the South East Pacific and South East Atlantic';
        [a,b] = retrieve_reginfo('sepdz_boreal');
        [c,d] = retrieve_reginfo('seadz_boreal');
        blcorner = cat(1,a,c);
        trcorner = cat(1,b,d);
    case 'conv_sa'
        regionstrlong ='Continental convection area (South America)';
        blcorner = [-14,-71.9;-5,-79;0,-80];
        trcorner = [-5,-50;0,-56;10,-60];
    case 'conv_af'
        regionstrlong ='Continental convection area (Africa)';
        blcorner = [-16,15;-5,11;0,0];
        trcorner = [-5,30;0,33;8,34];
    case 'trop_cont'
        % this is conv_af and conv_sa merged
        regionstrlong ='Tropical Convention Continents';
        [a,b] = retrieve_reginfo('conv_af');
        [c,d] = retrieve_reginfo('conv_sa');
        blcorner = cat(1,a,c);
        trcorner = cat(1,b,d);
    case 'twp'
        regionstrlong ='Tropical Warm pool';
        blcorner = [-12 80;-8 100;-12 155];
        trcorner = [16 100;14 155;10 175];
    case 'swl'
        regionstrlong ='Southern midlatitude Westerlies';
        blcorner = [-60,-180;-60,-50];
        trcorner = [-45,-80;-45,180];
    case 'kurosho'
        regionstrlong ='The region surrounding the Kurosho Current';
        % need extra region as passing the dateline causes problems
        blcorner = [33,145;40,160;36,-180;40,-160];
        trcorner = [40,180;50,180;50,-160;55,-135];
    case 'gulfstr'
        regionstrlong ='The region surrounding the Gulfstream';
        blcorner=[35,-70;45,-55;];
        trcorner=[45,-40;60,-10;];
    case 'nwl'
        regionstrlong ='Northern midlatitude Westerlies';
        [a,b] = retrieve_reginfo('gulfstr');
        [c,d] = retrieve_reginfo('kurosho');
        blcorner = cat(1,a,c);
        trcorner = cat(1,b,d);
    case 'westerlies'
        % this is swl and nwl merged
        regionstrlong ='Northern and Southern hemisphere midlatitude Westerlies';
        [a,b] = retrieve_reginfo('gulfstr');
        [c,d] = retrieve_reginfo('kurosho');
        [e,f] = retrieve_reginfo('swl');
        blcorner = cat(1,a,c,e);
        trcorner = cat(1,b,d,f);
    case 'aus'
        regionstrlong ='Australia';
        blcorner = [-45,100]; trcorner = [0,170];
    case 'swe'
        regionstrlong='Sweden';
        blcorner = [54,4];trcorner = [72,32];
    case 'polar'
        regionstrlong = 'Polar regions';
        [a,b] = retrieve_reginfo('ant');
        [c,d] = retrieve_reginfo('arc');
        blcorner = cat(1,a,c);
        trcorner = cat(1,b,d);
    otherwise
        switch regionstr
            
            %%%%%%%%%%%%%%%%%%%%
            % Regions below this line are reserved for AR4 IPCC regions (Ch. 11)
            %{'waf','eaf','saf','sah','neu','sem','nas','cas','tib','eas','sas',...
            % 'sea','ala','cgi','wna','cna','ena','cam','amz','ssa','nau','sau',...
            %'car','ind','med','tne','npa','spa','arc','ant'}
            
            % Africa
            case 'waf'
                regionstrlong ='West Africa';
                blcorner = [-12,-20]; trcorner = [22,18];
            case 'eaf'
                regionstrlong ='East Africa';
                blcorner = [-12,22]; trcorner = [18,52];
            case 'saf'
                regionstrlong ='South Africa';
%                 disp('WARNING: hard-coded bounding corners dont ')
%                 disp('         correspond to those on p856 in AR4 IPCC rapport')
%                 disp('         and have been adjusted to figure 11.26 p923')
%                 disp('i.e. 35S,10E - 12S,52E has been adjusted to 35S,-10E - 12S,52E')
                blcorner = [-35,-10]; trcorner = [-12,52];
            case 'sah'
                regionstrlong ='Sahara';
%                 disp('WARNING: hard-coded bounding corners dont ')
%                 disp('         correspond to those on p856 in AR4 IPCC rapport')
%                 disp('         and have been adjusted to figure 11.26 p923')
%                 disp('i.e. 18N,20E - 30N,65E has been adjusted to 18N,20W - 30N,65E')
                blcorner = [18,-20]; trcorner = [30,65];
                
                %Europe
            case 'neu'
                regionstrlong ='Northern Europe';
                blcorner = [48,-10]; trcorner = [75,40];
            case 'sem'
                regionstrlong ='Southern Europe and Mediterranean';
                blcorner = [30,-10]; trcorner = [48,40];
                
                %Asia
            case 'nas'
                regionstrlong ='Nothern Asia';
                blcorner = [50,40]; trcorner = [70,180];
            case 'cas'
                regionstrlong ='Central Asia';
                blcorner = [30,40]; trcorner = [50,75];
            case 'tib'
                regionstrlong ='Tibetan Plateau';
%                 disp('WARNING: hard-coded bounding corners dont ')
%                 disp('         correspond to those on p856 in AR4 IPCC rapport')
%                 disp('         and have been adjusted to figure 11.26 p923')
%                 disp('i.e. 30N,50E - 75N,100E has been adjusted to 30N,75E - 50N,100E')
                blcorner = [30,75]; trcorner = [50,100];
            case 'eas'
                regionstrlong ='East Asia';
                blcorner = [20,100]; trcorner = [50,145];
            case 'sas'
                regionstrlong ='South Asia';
                %                         disp('         correspond to those on p856 in AR4 IPCC rapport')
                %                         disp('         and have been adjusted to figure 11.26 p923')
                %                         disp('i.e. 5N,64E - 50N,100E has been adjusted to 5N,64E - 30N,100E')
                blcorner = [5,64]; trcorner = [30,100];
            case 'sea'
                regionstrlong ='South East Asia';
%                 disp('         correspond to those on p856 in AR4 IPCC rapport')
%                 disp('         and have been adjusted to figure 11.26 p923')
%                 disp('i.e. 11S,95E - 20N,115E has been adjusted to 11S,95E - 20N,')
                blcorner = [-11,95]; trcorner = [20,155];
                
                % North America
            case 'ala'
                regionstrlong ='Alaska';
                blcorner = [60,-170]; trcorner = [72,-103];
            case 'cgi'
                regionstrlong ='East Canada, Greenland, Iceland';
                blcorner = [50,-103]; trcorner = [85,-10];
            case 'wna'
                regionstrlong ='Western North America';
%                 disp('WARNING: hard-coded bounding corners dont ')
%                 disp('         correspond to those on p856 in AR4 IPCC rapport')
%                 disp('         and have been adjusted to figure 11.26 p923')
%                 disp('i.e. 30N,50E - 75N,100E has been adjusted to 30N,130W - 60N,103W')
                blcorner = [30,-130]; trcorner = [60,-103];
            case 'cna'
                regionstrlong ='Central North America';
                blcorner = [30,-103]; trcorner = [50,-85];
            case 'ena'
                regionstrlong ='Eastern North America';
%                 disp('WARNING: hard-coded bounding corners dont ')
%                 disp('         correspond to those on p856 in AR4 IPCC rapport')
%                 disp('         and have been adjusted to figure 11.26 p923')
%                 disp('i.e. 25N,85W - 50N,50W has been adjusted to 25N,85W - 50N,60W')
                blcorner = [25,-85]; trcorner = [50,-60];
                % Central and South America
            case 'cam'
                regionstrlong ='Central America';
                blcorner = [10,-116]; trcorner = [30,-83];
            case 'amz'
                regionstrlong ='Amazonia';
                blcorner = [-20,-82]; trcorner = [12,-34];
            case 'ssa'
                regionstrlong ='Southern South America';
                blcorner = [-56,-76]; trcorner = [-20,-40];
                
                %Australia and New Zealand
            case 'nau'
                regionstrlong ='North Australia';
                blcorner = [-30,110]; trcorner = [-11,155];
            case 'sau'
                regionstrlong ='South Australia';
                blcorner = [-45,110]; trcorner = [-30,155];
                %Small islands and oceans
            case 'car'
                regionstrlong ='Caribbean';
                blcorner = [10,-85]; trcorner = [25,-60];
            case 'ind'
                regionstrlong ='Indian Ocean';
                blcorner = [-35,50]; trcorner = [17.5,100];
            case 'med'
                regionstrlong ='Mediterranean Basen';
                blcorner = [30,-5]; trcorner = [45,35];
            case 'tne'
                regionstrlong ='Tropical North East Atlantic';
                blcorner = [0,-30]; trcorner = [40,-10];
            case 'npa'
                regionstrlong ='North Pacific Ocean';
                blcorner = [0,150]; trcorner = [40,360-120];
            case 'spa'
                regionstrlong ='South Pacific Ocean';
                blcorner = [-55,150]; trcorner = [0,360-80];
            case 'arc'
                regionstrlong ='Arctic';
                blcorner = [60,-180]; trcorner = [90,180];
            case 'ant'
                regionstrlong ='Antarctica';
                blcorner = [-90,-180]; trcorner = [-60,180];
        end
end