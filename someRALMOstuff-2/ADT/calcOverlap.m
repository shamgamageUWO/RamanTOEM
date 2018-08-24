function O = calcOverlap(data,config)

what='Combined';
z=data.N2.Photon.Range;
bkg_ind = z > 45e3 & z<50e3;

% ELASTIC SIGNAL
Eb = data.Eb.(what).SignalMean;     
Eb = CorrBkg(Eb,sum(bkg_ind),0,1);

% ELASTIC SIGNAL FULL OVERLAP
Es = data.Es.(what).SignalMean;
Es = CorrBkg(Es,sum(bkg_ind),0,1);

O=Eb./Es;

% smooth the bottom section
Of = sgolayfilt(O,3,201);

% fit the overlap function -> middle section
ind=find(z<6000 & z>1000);
p=polyfit(z(ind),O(ind),3);

% find root of 2nd derivative
p1 = p(1:end-1) .* fliplr(1:length(p)-1);
p2 = p1(1:end-1) .* fliplr(1:length(p1)-1);
[val ind_root]=min(abs(z-roots(p2)));

Osm=polyval(p,z);

% merge bottom and middle section
ramp=zeros(size(z));
ind=find(z>2500 & z<3000);
ramp(ind)=(cumsum(ones(size(ind)))-1)/(length(ind)-1);
ramp(ind(end)+1:end)=1;

Of = Of.*(1-ramp) + Osm.*ramp;

% merge with top section
d1=diff(Osm(ind_root-1:ind_root));
dd=fliplr([0:d1/600:d1]);
ds=cumsum(dd);

Of(ind_root+1:ind_root+length(dd)) = Of(ind_root)+ds;
Of(ind_root+1+length(dd):end)=Of(ind_root+length(dd));


% norm Of to [0 1]
Of = Of/max(Of);

% output
clear O
O.start_date=data.GlobalParameters.Start(1,:);
O.end_date=data.GlobalParameters.End(end,:);
O.mode=what;
O.z=z;
O.O=Of;



return

% smooth Es

% design window size
w0=600;
z0=800;
z_ref=4000;
A=w0/exp(z_ref/z0);
w=A*exp(z/z0);
w=ceil(w);
w(w>600)=600;

% calculate the derivative order P=0
Es_smooth=nan(size(Es));
P=0;
i=1;
while z(i)<5000
        
    if i<w(i)+1 || i>length(Es)-w(i)-1
        i=i+1;
        continue
    end
    
    % design the SG filter
    [B,G]=sgolay(3,2*w(i)+1);
    
    Es_smooth(i)=G(:,P+1)'*Es(i-w(i):i+w(i));
    
    i=ceil(i+w(i)/3);
    
end

ind=find(isnan(Es_smooth)==0);
nan_ind=find(isnan(Es_smooth)==1);

% interpolate between filter points
Es_smooth(nan_ind) = interp1(z(ind),Es_smooth(ind),z(nan_ind));

% fill low part of vector
Es_smooth(1:ind(1)) = Es(1:ind(1));


% overlap function
O = Eb ./ Es_smooth;

% fit the noisy overlap function
ind=find(isnan(O)==0);
p = polyfit(z(ind),O(ind),7);
Oi = polyval(p,z);

ind=find(z>4000);
Oi(ind)=Oi(ind(1));
Oi=Oi/Oi(ind(1));

