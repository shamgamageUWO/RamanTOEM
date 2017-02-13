 function [Tmsis, pmsis,zmsis]= msisRALMO
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
kb = 1.38064852*10^-23;
Rsp = 287;
ind = 0;

fid=fopen('msisRALMOmeasurements.txt');
d = struct();
while 1
    tline =  fgetl(fid) ;
    if ~ischar(tline)
        break
    end
    dataline = textscan(tline, '%f %f %f');
    ind = ind + 1;
    d(ind).alt = dataline{1};
    d(ind).temp = dataline{2};
    d(ind).den = dataline{3};

end

objectdata = struct();

objectdata.alt = [d.alt];
objectdata.temp = [d.temp];
Tmsis = objectdata.temp;
zmsis = objectdata.alt; %Km
zmsis = zmsis*1000;
objectdata.dens = [d.den]; %1/[cm^3]
nmsis = objectdata.dens; %g/[cm^3]
pmsis = nmsis.*Rsp.*Tmsis.* 1e3;

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
