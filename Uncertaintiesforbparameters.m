R =bparameterjacobians (Q,X);

degF1 = trace(X.A(1:m,1:m)); %DegF for Temperature 
degF2 = trace(X.A(m+4:end-5,m+4:end-5));%DegF for OV

%                     %% Percent difference of background, lidar calibration constant retrievals and the true
% 
%                     percent_BG_JH = ((Q.Bg_JH_real -BJH)./BJH).*100
%                     percent_BG_JL = ((Q.Bg_JL_real -BJL)./BJL).*100
%                     percent_CJL = ((Q.CL -CJL)./CJL).*100
%                     % e = cputime
%                     toc
% 
% 
%                     % %  %%
%                     % % % calculate error matrices
                    dfacP = 0.1; % ISSI recommend
                    dfacR = 0.1; % ISSI recommend
                    dfacRa = 0.1; % ISSI recommend
                    dfacAir = 0.01; % BOb code
                    dfacaero = 0.01;
%                     % % dfacDT = 0.1;
%                     % % Pressure error
                    SP1 = (dfacP.*Q.Pressi(n3+1:end)).^2;
                    SP2 = (dfacP.*Q.Pressi(1:n3)).^2;% for 2 digital channels
                    SP = [SP1 SP1 SP2 SP2];
                    S_P = diag(SP);
                    
%                     % % R  and Ra error
                    SR = (dfacR.*Q.R).^2;
                    SRa = (dfacRa.*Q.Ra).^2;
%                     % %
                    Sair1 = (dfacAir.*Q.Nmol(n3+1:end)).^2;
                    Sair2 = (dfacAir.*Q.Nmol(1:n3)).^2;
                    Sair = [Sair1 Sair1 Sair2 Sair2];
                    S_air = diag(Sair);
%                     % %
                    Saero1 = (dfacaero.*Q.alpha_aero(n3+1:end)').^2;
                    Saero2 = (dfacaero.*Q.alpha_aero(1:n3)').^2;
                    Saero = [Saero1 Saero1 Saero2 Saero2];
                    S_aero = diag(Saero);
%                     % %
%                     % % SDT = (dfacDT.*Q.deadtime).^2;
%                     % %
%                     % %
SxP = X.G*R.JPress*S_P*R.JPress'*X.G';
SxR = X.G*R.JR*SR*R.JR'*X.G';
SxRa = X.G*R.JRa*SRa*R.JRa'*X.G';
SxAir = X.G*R.Jnair*S_air*R.Jnair'*X.G';
Sxaero = X.G*R.Jaero*S_aero*R.Jaero'*X.G';
%                     % % SxDT = X.G*R.JDT*SDT*R.JDT'*X.G';
