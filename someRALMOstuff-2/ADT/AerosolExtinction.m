function ext=AerosolExtinction(data,config)

% altitude vector
z=data.N2.Photon.Range;
dz=diff([z(1)-3.75; z]);

% Simplified atmospheric model for molecular correction
% Impact	for Std	Correction
% 3km       1.7%
% 7km		3.2%
ScaleHeight = 8.771e+3;														% Approximative up to 10km
Nair        = 2.56e25 .* exp(-z/ScaleHeight);    						    % Molecular profile
Nn2         = 0.7 * Nair;

% Raman wavelengths
LambdaLa = 354.70;
LambdaN2 = 386.69;

% Reference air constant [m^2*nm^4]
SigmaRef    = 3.1335e-20;

% Molecular extinction cross sections
SigmaN2=SigmaRef./LambdaN2.^4;

% Molecular Extinction
ExtN2 = SigmaN2.*Nn2;

% Molecular signal in absolute photon number
N2 = data.N2.Photon.Signal*data.N2.Photon.Shots*data.N2.Photon.BinSize./150;
N2 = mean(data.N2.Photon.Signal,2);

% background correction

% find lowest background level
bkgbin = find(z > 4e4,1,'first');
if isempty(bkgbin)                                          % If the sample doesn't reach 50 km then
    bkgbin = find(z > z(end-500),1,'first');		% use the last 500 bins
end

% subtract background
N2 = N2 - median(N2(bkgbin:end));

% overlap function
z0=3000;
O=zeros(size(z));
ind=find(z>50 & z<z0);
ramp=ones(size(ind));
ramp=cumsum(ramp);
ramp=ramp/ramp(end);
O(ind)=ramp;
O(z>=z0)=1;


% calculate derivative of log

% take the log
X = log(Nair./z.^2./N2.*O);

% design window size
w0=600;
z0=3000;
z_ref=10000;
A=w0/exp(z_ref/z0);
w=A*exp(z/z0);
w=ceil(w);

% calculate the derivative order P
Xd=nan(size(X));
P=1;
i=1;
while z(i)<10000
        
    if i<w(i)+1 || i>length(X)-w(i)-1
        i=i+1;
        continue
    end
    
    % design the SG filter
    [B,G]=sgolay(3,2*w(i)+1);
    
    Xd(i)=G(:,P+1)'*X(i-w(i):i+w(i))/dz(i);
    
    i=ceil(i+w(i)/2);
    
end


% calculate extinction
ext.z = z;
ext.ext = (Xd - ExtN2 * (1 + (LambdaLa/LambdaN2)^-4)) / (1 + (LambdaLa/LambdaN2)^1 );





