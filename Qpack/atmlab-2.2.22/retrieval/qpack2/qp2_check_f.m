% QP2_CHECK_F   Checks if frequencies of measurement data are correct
%
%   The frequencies of measurement data (Y.f) are compared to
%   Q.SENSOR_RESPONSE.F_BACKEND. A first demand is that Y(i).F has the same
%   length as Q.F_BACKEND. If not, df is set to NaN. The second step is to
%   determine the max (absolute) difference between Y(i).F and
%   Q.SENSOR_RESPONSE.F_BACKEND, and check if this difference is below *max_df*.
%
% FORMAT   [all_ok,df,i_ok,i_bad] = qp2_check_f(Q,Y,max_df)
%
% IN    Q        Qpack2 setting structure
%       Y        Measurement data.
%       max_df   Max allowed deviation to Q.F_BACKEND
% OUT   all_ok   1 if all checks OK. 0 otherwise.
%       df       The maximum deviation for each spectrum.
%       i_ok     Index of spectra where check OK.
%       i_bad    Index of spectra where check not OK.

% 2009-08-05   Created by Patrick Eriksson.

function [all_ok,df,i_ok,i_bad] = qp2_check_f(Q,Y,max_df)


%- Check of input
%
qcheck( @qp2_y, Y );  


%- Init
%
if ~isstruct( Q.SENSOR_RESPONSE )                                           %&%
  error( 'The structure version of Q.SENSOR_RESPONSE must be used.' );      %&%
end                                                                         %&%
%
f0 = qarts_get( Q.SENSOR_RESPONSE.F_BACKEND );
%
ny = length( Y );
nf = length( f0 );
%
all_ok = 1;
df     = zeros( ny, 1 );
i_ok   = ones( ny, 1 );


%- Loop spectra and check
%
for i = 1 : ny
  
  if length( Y(i).F ) ~= nf 
    this_df = NaN;
  else
    this_df = max( abs( f0 - Y(i).F ) );
  end
  
  if isnan(this_df)  |  this_df > df
    all_ok  = 0;
    i_ok(i) = 0;
  end
  
  df(i) = this_df;
    
end


%- Convert 0/1 to index data
%
i_bad = find( ~i_ok );
i_ok  = find( i_ok );