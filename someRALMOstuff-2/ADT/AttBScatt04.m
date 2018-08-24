function data = AttBScatt04(S, power, config)

if isempty(power)
    data = [];
    return
end

Es = S.Es;
r = S.r;
Nfile = S.nfiles;

% bkg correction at each column
Es_bkg = CorrBkg(Es, 4, 0, 0);

% first 150m are nans - there is ono full overlap there - so cut
Es_bkg(r<150,:) = nan;

% normalize with power
p       = repmat(power',length(Es_bkg),1); 
Es_bkg  = Es_bkg./p;


% r^2 estimate
r2mat = r.^2; % r2 matrix, columns are equal for each file
r2mat = repmat(r,[1 size(Es_bkg,2)]);
Es_R2 = Es_bkg.*r2mat;
clear r2mat

% ln(s r^2) -> Es_log
warning off
s_ln    = real ( log(Es_R2) );
warning on
Es_ln   = zeros(size(Es_bkg));
for i=1:size(s_ln,2)
    ii= find (s_ln(:,i)<0, 1, 'first'); 
    if isempty(ii); ii=size(s_ln,1); end % in case of no negative elements
    Es_ln(1:ii,i) = s_ln(1:ii,i);
    %plot(Es_log(:,i));
    %pause(.5);
end
clear s_log ii i

% assign result
data.Nfile  = Nfile;
data.Bins   = config.ini.dABS.vertres; 
data.r      = r;
data.Es     = Es_bkg;
data.EsR2   = Es_R2;
data.EsLn   = Es_ln;
