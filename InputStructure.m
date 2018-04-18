%% 20110909 Night & 20110910 00-05

Input.R =0.8102;%0.7913;%R;%0.808780013344381;%R;%R;%0.17;
Input.Ra =0.8719;%0.8639;%Ra;%1.042367710538608;%Ra; %%I'm hardcoding this for now. for some reason FM doesnt provide measurements close to real unless divide by 2                     Ttradi = real(Q.bb./(Q.aa-lnQ));
Input.dfacR= 0.0068; % ISSI recommend
Input.dfacRa= 0.0017 ;
Input.CJL = 3.8362e+19 ;
Input.CJLa= 4.6099e+15;

%% 20110910 Day
% Input.R =0.8002;%0.7913;%R;%0.808780013344381;%R;%R;%0.17;
% Input.Ra =0.8679;%0.8639;%Ra;%1.042367710538608;%Ra; %%I'm hardcoding this for now. for some reason FM doesnt provide measurements close to real unless divide by 2                     Ttradi = real(Q.bb./(Q.aa-lnQ));
% Input.dfacR= 0.0117; % ISSI recommend
% Input.dfacRa= 0.0015;
% Input.CJL = 4.6426e+19;
% Input.CJLa= 5.8145e+15;