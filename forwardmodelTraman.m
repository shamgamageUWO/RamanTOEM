% This code is to create synthetic data using the US standard data

function [JL,JH,JLa,JHa,WV,N2,WVa,N2a]=forwardmodelTraman(Q,x)
m = length(Q.Zret);
x_a = x(1:m);%T
BJH = x(m+1);
BJL = x(m+2);
CJL = x(m+3);
OV = x(m+4:2*m+3);
BJHa = x(2*m+4);
BJLa = x(2*m+5);
CJLa = x(2*m+6);
DT_JH = x(2*m+7);
DT_JL = x(2*m+8); % deadtimes

rh_a = exp(x(2*m+9:3*m+8));%
Bwv = x(3*m+9);
Bn2 = x(3*m+10);
Cwv = x(3*m+11);
Cn2 = x(3*m+12);
OVwv = x(3*m+13:4*m+12);
Bwva = x(4*m+13);
Bn2a = x(4*m+14);
Cwva = x(4*m+15);
Cn2a = x(4*m+16);
DT_WV = x(4*m+17);
DT_N2 = x(4*m+18); % deadtimes
alpha_aero = exp(x(4*m+19:end));

%% PRR FM
            % interpolation
            Ti = interp1(Q.Zret,x_a,Q.Zmes,'linear');
%             Td = Ti(1:length(Q.JHnew));
             Td= Ti(end-length(Q.JHnew)+1:end);
            Ta= Ti(1:length(Q.JHnewa));
            Td_WV = Ti(end-length(Q.WVnew)+1:end);
            
            rho =Q.rho;% Q.Zmes
            rho_WVa= rho(1:length(Q.WVnewa));
            rho_WV = rho(end-length(Q.WVnew)+1:end);
            
            
            
            OV_Zi = interp1(Q.Zret,OV,Q.Zmes,'linear');
%             OV_Zid = OV_Zi(1:length(Q.JHnew));
             OV_Zid = OV_Zi(end-length(Q.JHnew)+1:end);%interp1(Q.Zret,OV,Q.Zmes2,'linear');
            OV_Zia = OV_Zi(1:length(Q.JHnewa));%interp1(Q.Zret,OV,Q.Zmes1,'linear');

            kb = 1.38064852*10^-23;

%             R_tr_i = (Q.Tr');
% %             R_tr_id= R_tr_i(1:length(Q.JHnew));
%              R_tr_id = R_tr_i(end-length(Q.JHnew)+1:end);%interp1(Q.Zmes,R_tr_i,Q.Zmes2,'linear');
%             R_tr_ia = R_tr_i(1:length(Q.JHnewa));%interp1(Q.Zmes,R_tr_i,Q.Zmes1,'linear');
%             Pd= Q.Pressi(1:length(Q.JHnew));
             Pd = Q.Pressi(end-length(Q.JHnew)+1:end);%exp(Pdigid);
                   Pd_WV = Q.Pressi(end-length(Q.WVnew)+1:end);%exp(Pdigid);
            Pa = Q.Pressi(1:length(Q.JHnewa));%exp(Pdigia);
            
            
            alpha_aero1 = interp1(Q.Zret,alpha_aero,Q.Zmes,'linear');
            sigma_tot = Q.alpha_mol + alpha_aero1;
            R_tr_i  = exp(-2.*cumtrapz(Q.Zmes,sigma_tot)); % Molecular transmission
            R_tr_id = R_tr_i(end-length(Q.JHnew)+1:end);%interp1(Q.Zmes,R_tr_i,Q.Zmes2,'linear');
            R_tr_ia = R_tr_i(1:length(Q.JHnewa));%interp1(Q.Zmes,R_tr_i,Q.Zmes1,'linear');
            
            
            
            
            A_Zi_an = ( OV_Zia' .*R_tr_ia' .*Pa')./(kb * Q.Zmes1 .^2);
            B_Zi_an = (R_tr_ia .*Pa')./(kb * Q.Zmes1 .^2); % No overlap
            A_Zi_d = (OV_Zid' .*R_tr_id' .*Pd')./(kb * Q.Zmes2 .^2);
            B_Zi_d = (R_tr_id .*Pd')./(kb * Q.Zmes2 .^2); % No overlap

            %% loading cross sections
            load('DiffCrossSections.mat');
            Diff_JH_i = interp1(T,Diff_JH,Ti,'linear');
            Diff_JL_i = interp1(T,Diff_JL,Ti,'linear');

            dJHd = Diff_JH_i(end-length(Q.JHnew)+1:end);%interp1(Q.Zmes,Diff_JH_i,Q.Zmes2,'linear');
            dJLd = Diff_JL_i(end-length(Q.JHnew)+1:end);%interp1(Q.Zmes,Diff_JL_i,Q.Zmes2,'linear');

            dJHa = Diff_JH_i(1:length(Q.JHnewa));%interp1(Q.Zmes,Diff_JH_i,Q.Zmes1,'linear');
            dJLa = Diff_JL_i(1:length(Q.JHnewa));%interp1(Q.Zmes,Diff_JL_i,Q.Zmes1,'linear');

            CJH = (Q.R).* CJL;
            CJHa = (Q.Ra).* CJLa;

            JL = (CJL.* A_Zi_d' .* dJLd)./(Td);
            JH = (CJH.* A_Zi_d' .* dJHd)./(Td);

            JLa = (CJLa.* A_Zi_an' .* dJLa )./(Ta );
            JHa = (CJHa.* A_Zi_an' .* dJHa )./(Ta );

            %  % Add true background to the digital counts
            JL = JL  + BJL;
            JH = JH  + BJH;

            %
            %% Saturation correction is applied for the averaged count profile This is just for digital channel
            % 1. Make the Co added counts to avg counts
            JH = JH./(Q.deltatime.*Q.coaddalt);
            JL = JL./(Q.deltatime.*Q.coaddalt);

            % 2. Convert counts to Hz
            JHnw = (JH.*Q.f);
            JLnw = (JL.*Q.f);

            % 3. Apply DT
            JL_dtc = JLnw ./ (1 + JLnw.*(DT_JL)); % non-paralyzable
            JH_dtc = JHnw ./ (1 + JHnw.*(DT_JH));
            % 4. Convert to counts
            JL = JL_dtc.*(1./Q.f);
            JH = JH_dtc.*(1./Q.f);
            % 5. Scale bacl to coadded signal
            JL = JL.*(Q.deltatime.*Q.coaddalt);
            JH = JH.*(Q.deltatime.*Q.coaddalt);

            %  % Add background to the analog signal

            JLa = JLa  + BJLa;
            JHa = JHa  + BJHa;


%% WV/N2 FM
% es = 6.107 * exp ((M_A .*(T-273))./(M_B + (T-273))); Saturated vapor pressure
% Q = (0.6222 .*RH)./(P - RH.*es); Mixing ratio
RHi = interp1(Q.Zret,rh_a,Q.Zmes,'linear');
% RHd = RHi(1:length(Q.JHnew));
 RHd=   RHi(end-length(Q.WVnew)+1:end);
RHa=   RHi(1:length(Q.WVnewa));

OV_wvi = interp1(Q.Zret,OVwv,Q.Zmes,'linear');
% OV_wvd = OV_wvi(1:length(Q.JHnew));
 OV_wvd = OV_wvi(end-length(Q.WVnew)+1:end);%interp1(Q.Zret,OV,Q.Zmes2,'linear');
OV_wva = OV_wvi(1:length(Q.WVnewa));%interp1(Q.Zret,OV,Q.Zmes1,'linear');



            sigma_totwv = Q.alpha_mol + 2.*alpha_aero1 +Q.alpha_wv;
%               sigma_totwv  = 1 + ((Q.Q.Lambdawv./Q.Lambda).^(-angstrom)) + ((Q.alpha_wv + Q.alpha_mol)./alpha_aero1);
            
            R_tr_wv  = exp(-cumtrapz(Q.Zmes,sigma_totwv)); % Molecular transmission
            R_tr_wvd = R_tr_wv(end-length(Q.WVnew)+1:end);%interp1(Q.Zmes,R_tr_i,Q.Zmes2,'linear');
            R_tr_wva = R_tr_wv(1:length(Q.WVnewa));%interp1(Q.Zmes,R_tr_i,Q.Zmes1,'linear');
            
            sigma_totn2 = Q.alpha_mol + 2.*alpha_aero1 +Q.alpha_n2;
%            sigma_totn2  = 1 + ((Q.Q.Lambdan2./Q.Lambda).^(-angstrom)) + ((Q.alpha_n2 + Q.alpha_mol)./alpha_aero1);
            R_tr_n2  = exp(-cumtrapz(Q.Zmes,sigma_totn2));
            R_tr_n2d = R_tr_n2(end-length(Q.N2new)+1:end);%interp1(Q.Zmes,R_tr_i,Q.Zmes2,'linear');
            R_tr_n2a = R_tr_n2(1:length(Q.WVnewa));%interp1(Q.Zmes,R_tr_i,Q.Zmes1,'linear');
            
% For analog channels
for i = 1:length(Ta)
    if Ta(i) <= 273 
        M_A = 17.84;
        M_B = 245.4;
    else 
        M_A = 17.08;
        M_B = 234.2;
    end
    
    es_a(i) = 6.107 * exp ((M_A .*(Ta(i)-273))./(M_B + (Ta(i)-273)));
    Q_a(i) = (0.6222 .* RHa(i))./(Pa(i) - RHa(i).*es_a(i));
end


for i = 1:length(Td_WV)
    if Td_WV(i) <= 273 
        M_Aa = 17.84;
        M_Ba = 245.4;
    else 
        M_Aa = 17.08;
        M_Ba = 234.2;
    end
    
    es_d(i) = 6.107 * exp ((M_Aa .*(Td_WV(i)-273))./(M_Ba + (Td_WV(i)-273)));
    Q_d(i) = (0.6222 .*RHd(i))./(Pd_WV(i) - RHd(i).*es_d(i));
end


 N2  = (0.7809.*OV_wvd'.*R_tr_n2d'.*Cn2.*Pd_WV')./(kb.*Td_WV'.*Q.Zmes3.^2);
 n2a = (0.7809.*OV_wva'.*R_tr_n2a'.*Cn2a.*Pa')./(kb.*Ta'.*Q.Zmes1.^2);
% % N2  = (0.7809.*OV_wvd'.*R_tr_n2d.*Cn2.*rho_WV')./(Q.Zmes3.^2);
% % n2a = (0.7809.*OV_wva'.*R_tr_n2a.*Cn2a.*rho_WVa')./(Q.Zmes1.^2);


M_N2 = 14.0067;
M_WV = 18.01;
mass_ratio = M_N2/M_WV;
 WV  = (mass_ratio.*OV_wvd'.*R_tr_wvd'.*Cwv.*Pd_WV'.*Q_d)./(kb.*Td_WV'.*Q.Zmes3.^2);
 wva = (mass_ratio.*OV_wva'.*R_tr_wva'.*Cwva.*Pa'.*Q_a)./(kb.*Ta'.*Q.Zmes1.^2);

% WV  = (mass_ratio.*OV_wvd'.*R_tr_wvd.*Cwv.*rho_WV'.*Q_d)./(Q.Zmes3.^2);
% wva = (mass_ratio.*OV_wva'.*R_tr_wva.*Cwva.*rho_WVa'.*Q_a)./(Q.Zmes1.^2);
WVa = (wva+Bwva)';
N2a = (n2a+Bn2a)';


%  % Add true background to the digital counts
N2 = (N2  + Bn2)';
WV = (WV  + Bwv)';

%
% Saturation correction is applied for the averaged count profile This is just for digital channel
% 1. Make the Co added counts to avg counts
N2 = N2./(Q.deltatime.*Q.coaddalt);
WV = WV./(Q.deltatime.*Q.coaddalt);

% 2. Convert counts to Hz
N2nw = (N2.*Q.f);
WVnw = (WV.*Q.f);

% 3. Apply DT
N2_dtc =  N2nw ./ (1 + N2nw.*(DT_N2)); % non-paralyzable
WV_dtc = WVnw ./ (1 + WVnw.*(DT_WV));

% 4. Convert to counts
N2 =  N2_dtc.*(1./Q.f);
WV = WV_dtc.*(1./Q.f);

% 5. Scale bacl to coadded signal
N2 = N2.*(Q.deltatime .*Q.coaddalt);
WV = WV.*(Q.deltatime .*Q.coaddalt);

return

 


