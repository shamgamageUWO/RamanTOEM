function [dzcutf hfout status message]=NDACC_ResolDFbis(coef, hfinp)
% Calculation of the normalized resolution of the filter. To obtain the
% real resolution, multiplie dzcutf by the initial resolution. 
%
% [dzcutf hfout status message]=NDACC_ResolDF(coef) or 
% [dzcutf hfout status message]=NDACC_ResolDF(coef, []): calculate the
% normalized resolution of the filter whose coefficients are "coef" ("coef"
% must be an odd array of value)
%
% [dzcutf hfout status message]=NDACC_ResolDF(coef, hfinp): hfinp is the
% transfer function of the last filter. The length of hfout is the same of
% hfinp.
%
% INPUTS:
%   - coef [array of number]: coefficients of the filter
%   - hfinp [array of number]: [optional] transfer function of last filter
%
% OUTPUT:
%   - dzcutf [array of number]: normalized resolution of the filter
%   - hfout [array of number]: transfer function of system (this filter and
%   last filters)
%   - status [Value]: 
%       - 0: problem
%       - 1: low-pass filter
%       - 2: derivative filter
%   - message [String]: error message (if status=0)

%% Parameters
missval = -99;
message='';
dzcutf=missval;
hfout=missval;
nf=4096;
nfmin=512;

%% Checking Inputs
% nomber of input
if nargin<1
    status=0;
    message='[ERROR] NDACC_ResolDF.m: Not enought inputs for this function';
    return
end
% Checking coef
if isempty(coef)
    status=0;
    message='[ERROR] NDACC_ResolDF.m: coef must be no empty';
    return
end
if mod(coef, 2)==0
    status=0;
    message='[ERROR] NDACC_ResolDF.m: length of coef must be odd';
    return
end
if length(coef)==1 && coef(1)~=1
    status=0;
    message='[ERROR] NDACC_ResolDF.m: if the length of coef is 1, this value must be 1';
    return
end
if size(coef, 1)==1
    coef=coef';
end
% Checking hfinp
if exist('hfinp', 'var')
    if ~isempty(hfinp)
        if size(hfinp,1)==1
            hfinp=hfinp';
        end
        nf=length(hfinp);
        if nf<nfmin
            disp(['[WARNING] NDACC_ResolDF.m: the length of hfinp is low: it ' ...
                'is better to take a length of ' num2str(nfmin) ' in minimum'])
        end
    else
        hfinp=ones(nf,1);
    end
else
    hfinp=ones(nf,1);
end
hfout=ones(nf, 1).*missval;

%% Symetry of coefficients
m=(length(coef)-1)/2;
if coef(1:m)+coef(end:-1:m+2)<1e-5
    status=2;
else
    if coef(1:m)-coef(end:-1:m+2)<1e-5
        status=1;
    else
        status=0;
        message='[ERROR] NDACC_ResolDF.m: coefficients must be symmetric or anti-symmetric';
        return
    end
end

%% Creation of the frequency vector
f(1,:)=0.5/nf:0.5/nf:0.5;

%% Calculation of the transfer function of the filter
hfcomp=zeros(length(f),1);  
for j=m+1:length(f)-m
    if status==1
        hfcomp(j,1)=coef(m+1)+2*cos(2*pi*f(j).*(1:m))*coef(m+2:end);
    else
        hfcomp(j,1)=-2*sin(2*pi*f(j).*(1:m))*coef(m+2:end)/(2*pi*f(j));
    end
end
hfcomp=abs(hfcomp);

%% Limit conditions
hfcomp(1:m,1)=hfcomp(m+1,1);
hfcomp(end-m+1,end)=hfcomp(end-m,1);

%% Final transfer function
hfout=hfcomp.*hfinp;

%% Identify fc (cutoff frequency) i.e. hfout(fc)=0.5
i_fc=find(hfout<0.5,1)-1;
if ~isempty(i_fc)
    if i_fc~=0
        a=(f(i_fc)-f(i_fc+1))/(hfout(i_fc)-hfout(i_fc+1));
        fc=f(i_fc+1)+a*(0.5-hfout(i_fc+1));
    else
        fc=0.5;
    end
else
    fc=0.5;
end
dzcutf=1/fc;

