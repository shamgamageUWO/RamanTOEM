function bcks=AerosolBackscatter01(ASRatio,config)

% check for data
if isempty(ASRatio.profile)==1
    bcks.profile=[];
    return
end

% wavelength
lambda = 357;

% initialize output
bcks = ASRatio;

% remove nans
ind=find(isnan(ASRatio.profile)==0);
z=ASRatio.z(ind);
asr=ASRatio.profile(ind);

% Molecular density (1/cm^3)
ScaleHeight = 8.771e+3;														% Approximative up to 10km
Nair        = 2.56e25 .* exp(-z/ScaleHeight) / 1e6;

% molecular backscatter coefficent (1/m/sr)
beta_mol = Nair * 5.45 * (550/lambda)^4 * 1e-28 * 1e2;

% aerosol backscatter coefficient (1/m/sr)
bcks.profile = beta_mol .* (asr - 1);

% output
bcks.z = z;
bcks.relerr = ASRatio.relerr(ind);
bcks.abserr = bcks.profile .* bcks.relerr/100;