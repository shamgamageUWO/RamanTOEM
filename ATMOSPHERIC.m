 function [nmsis, Tmsis, zmsis]=ATMOSPHERIC( )
% Determin ethe density using CIRA. I can't find CIRA tables to donwload so I use the 
%msis data set. However it is in units of kg/m^3 but we need unirts of
%1/(m^3)...
%

%Calcul	tf = temperature	[K]

%			df = densite	[[cm^-3]]

%altitude de 122.5 km -> 0 km

% load msis here.
%% YOu need to write a subroute here to read these data for you. For the time being,
%% this is more than good!
ind = 0;

fid=fopen('MSIS.txt');
d = struct();
while 1
    tline =  fgetl(fid) ;
    if ~ischar(tline)
        break
    end
    dataline = textscan(tline, '%f %f %f %f %f %f %f %f %f %f %f %f');
    ind = ind + 1;
    d(ind).year = dataline{1};
    d(ind).month = dataline{2};
    d(ind).day = dataline{3};
    d(ind).alt = dataline{4};
    d(ind).O = dataline{5};
    d(ind).N2 = dataline{6};
    d(ind).O2 = dataline{7};
    d(ind).temp = dataline{8};
    d(ind).He = dataline{9};
    d(ind).Ar = dataline{10};
    d(ind).H = dataline{11};
    d(ind).N = dataline{12};
end

objectdata = struct();

objectdata.alt = [d.alt];
objectdata.temp = [d.temp];
Tmsis = objectdata.temp;
zmsis = objectdata.alt; %Km
zmsis = zmsis*1000;
%Tmsis = Tmsis - 273; % converting to °C
objectdata.dens = [d.O]+ [d.N2] +[d.O2] +[d.He] +[d.Ar] +[d.H] +[d.N]; %1/[cm^3]
nmsis = objectdata.dens; %1/[cm^3]
 
nmsis = nmsis * 1e6; %1/[m^3]
%%nmsis = nmsis * 1000; %1/[m^3]
%% t
% % date = 20160228;
% % channel= 511;
% % [dataOutmed, dataOutlow, z] = coadding(date, channel);
% % if max(z)>122.5,
% % 	lim=find(z>122.5,1)-1;
% % else
% %     lim=length(z);
% % end;
% % hf=z(1:lim);
% % tf=interp1(zmsis,Tmsis,hf);
% % dens=interp1(zmsis,nmsis,hf); %cm^-3
% % 
% % if channel==511 || channel==512
% %     LI=1;
% % else
% %     LI=2;
% % end
 end
