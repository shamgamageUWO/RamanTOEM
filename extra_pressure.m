 %% Analog
            T_a = interp1(Q.Zret,Q.Ta,Q.Zmes1,'linear');
            Press_a =interp1(Q.Zret,lnpress,Q.Zmes1,'linear'); %% I am trying to make this looks like psonde
            Press_a = exp(Press_a);
 
            MoR_a = (M./Q.Rgas).*ones(size(T_a));
            obj_a = Gravity(Q.Zmes1, 46.82);
            grav_a = obj_a.accel;
            Q.z0_a = 6000;
            [P_a,p0A] = find_pHSEQ(Q.z0_a,Q.Zmes1,T_a,Press_a,0,grav_a',MoR_a);
            Q.P0_a = p0A; % po pressure


%% Digital

            T_d = interp1(Q.Zret,Q.Ta,Q.Zmes2,'linear');
            Press_d =interp1(Q.Zret,lnpress,Q.Zmes2,'linear'); %% I am trying to make this looks like psonde
            Press_d = exp(Press_d);
            %%
            MoR_d = (M./Q.Rgas).*ones(size(T_d));
            obj_d = Gravity(Q.Zmes1, 46.82);
            grav_d = obj_a.accel;
            Q.z0_d = 50000;
            [P_d,p0D] = find_pHSEQ(Q.z0_d,Q.Zmes2,T_d,Press_d,0,grav_d',MoR_d);
            Q.P0_d = p0D; % po pressure


%%
          Q.Pressi = [P_a P_d];
            Q.rho = Q.Pressi./(Rsp.*Q.Ti);
            Q.Nmol = (NA/M).* Q.rho ; % mol m-3