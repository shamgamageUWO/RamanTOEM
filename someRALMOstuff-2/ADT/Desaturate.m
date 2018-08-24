function desP = Desaturate(P,f)
% Desaturates PC signal using non-paralyseable assumption
% Usage : desP = Desaturate(P,f)
%
% desP  - desaturated PC signal
% P     - saturated PC signal 
% f     - frequency ( 1/(dead time) )
desP = P./(1-P./f);
end
