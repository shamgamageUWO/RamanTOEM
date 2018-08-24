% MCI   Retrieval by Monte Carlo integration
%
%   A Bayesian inversion is performed by using a precalculated database.
%   The retrieval algoithm is descibed in e.g.
%      Evans et al., Submillimeter-wave cloud ice radiometer: Simulations
%      of retrieval algorithm performance, JGR, 107, D3, 2002.
%
%   The match between the measurement and the database cases is reported
%   as exp(-chi2/2)/exp(-m/2), where m=size(Y,1) and chi2 is defined in
%   the function with same name.
%
%   With the vector p you can give different prior weights to the
%   different training points. This is done AFTER the check on
%   which points are above the weight threshold for the
%   retrieval. (Otherwise this would be an unfair advantage for
%   those training points with large prior weights.) The prior p is
%   also taken into account in sum_w, so that the retrieval is
%   correctly normalized. It is NOT taken into account in the
%   number of hits, so if we find one training point with prior
%   weight 10, the number of hits is 1, not 10.
%
%   Some details of the inversion is controled by the structure M. Fields
%   can be left out. Defined fields are
%      use_all :      If set to 1 all cases in database are weighted together.
%                     If 0, only cases with a weight > w_limit are considered.
%                     Default is true.                
%      norm_w  :      If set to false, the normalisation of weights by 
%                     exp(-m/2) is NOT applied. This makes the weights to 
%                     depend more strongly on m, but allows to be consistent
%                     with how the weights are normally defined. Limit and
%                     sum threshold must be adopted if this field is changed.
%                     Default is true.
%      w_limit :      Threshold level for what is considered as an OK
%                     databse hit. Used by *use_all* and controls D.n_hit. 
%                     Default is 0.01.
%      verb    :      If set to 1 some text output is generated. 
%                     Default is false
%      sum_w_thresh : Threshold for sum_w for which retrieval is performed. 
%                     If the sum_w is smaller or equal to the treshold, a 
%                     value of NaN is assigned for that retrieval case. 
%                     Default value is 0 (to avoid division by zero).
%      n_hit_thresh : Threshold for number of database hits (weight
%                     exceeding w_limit) for which retrieval is performed. 
%                     If the number is smaller than the treshold, a value 
%                     of NaN is assigned for that retrieval case. 
%                     Default value is 0.
%
%    MCI specific retrieval diagnostics is given in the structure array D, 
%    having the fields
%      n_con : Number of considered cases
%      n_hit : Number of cases with weight >= *w_limit*
%      sum_w : Sum of weights (for considered cases)
%      max_w : Maximum weight value
%    To plot e.g. n_hit: plot([D(:).n_hit])
%
% FORMAT   [Xh,E,D,W] = mci(M,Xb,Yb,Se,Y[,p])
%        
% OUT   Xh   Retrieved states (that is, x-hat).
%       E    Retrieval error.
%       D    Diagnostics of the retrieval. See further above.
%       W    Weights for each database entry and each retrieval.
% IN    M    Settings for the MCI retrieval.  See further above.
%       Xb   States of retrieval data base.
%       Yb   Measurements corresponding to Xb.
%       Se   Observation unvertainty covariance matrix.
%       Y    Measurements to be inverted.
% OPT   p    Prior weight of given training point. Default is 1.

% 2005-11-23   Created by Patrick Eriksson.
% 2006-03-28   Extended to use prior weights and for more
%              diagnostics by Stefan Buehler (details see Atmlab Changelog).

function [Xh,E,D,W] = mci(M,Xb,Yb,Se,Y,p)

% Check input
if ~isfield( M, 'use_all' )
  M.use_all = 1;
end
if ~isfield( M, 'norm_w' )
  M.norm_w = true;
end
if ~isfield( M, 'w_limit' )
  M.w_limit = 0.01;
end
if ~isfield( M, 'verb' )
  M.verb = 0;
end
if ~isfield( M, 'sum_w_thresh' )
  M.sum_w_thresh = 0;
end
if ~isfield( M, 'n_hit_thresh' )
  M.n_hit_thresh = 0;
end


% Some sizes
nb = size(Xb,2);
m  = size(Y,1);
ny = size(Y,2);
lx = size(Xb,1);


% If no prior weights p are given, we set all prior weights to 1:
if nargin == 5
  p = ones(1,nb);
else
  % Check that length of p matches Xb:
  if length(p) ~= nb 
    error('Dimension of p does not match Xb')
  end
end


% Check that dimensions of Xb and Yb are consistent:
if size(Yb,2) ~= nb
    error('Dimensions of Xb and Yb do not match')
end


% Seems that nargout can get corrupted inside parfor! 
% Use a local variable to be safe. 
nout = nargout;



% Init output arguments
%
Xh = zeros( lx, ny );
%
if nout > 1
  E  = zeros( lx, ny );
end
if nout > 3
  W  = zeros( nb, ny );
end
%
D(ny) = struct( 'sum_w',NaN, 'max_w',NaN, 'n_con',NaN, 'n_hit',NaN );


for i = 1 : ny

  w = exp( -0.5*chi2( repmat(Y(:,i),1,nb)-Yb, Se ) );

  if M.norm_w 
    w = w /  exp(-m*(1-2/9/m)^3/2);
  end
  
  ind_hit = find( w >= M.w_limit );    
  
  if M.use_all
    ind = 1:nb;
  else
    ind = ind_hit;
  end

  % Catch the case that ind is empty
  if length(ind) == 0
    D(i).sum_w = 0;
    D(i).max_w = 0;
    D(i).n_con = 0;
    D(i).n_hit = 0;
  else
    D(i).sum_w = sum( p(ind)*w(ind) );	% Weight with prior.
    D(i).max_w = max( w(ind) );
    D(i).n_con = length(ind);
    D(i).n_hit = length(ind_hit);
  end
  
  % Prepare the weights for the selected training cases for the
  % retrieval. We also multiply in the prior weights here.
  Wi = repmat(p(ind).*w(ind)',lx,1);

  % The retrieval is only calculated if the weight sum is above the
  % treshold. The default value for the threshold is zero, to avoid
  % division by zero.
  %
  % Likewise, or alternatively, the retrieval is only calculated if
  % the number of hits is larger than n_hit_thresh.
  if ( D(i).sum_w > M.sum_w_thresh )  &&  ( D(i).n_hit >= M.n_hit_thresh )
    
    Xh(:,i) = sum( Xb(:,ind).*Wi, 2 ) ./ D(i).sum_w;

    if nout > 1
      E(:,i) = sqrt( sum( ...
	    (Xb(:,ind)-repmat(Xh(:,i),1,D(i).n_con)).^2.*Wi, 2 ) ./ D(i).sum_w );
      if nout > 3
        W(:,i) = w;
      end
    end  
  else
    Xh(:,i) = NaN;
  
    if nout > 1
      E(:,i) = NaN;
      if nout > 3
        W(:,i) = w;
      end
    end  
  end
  
  if M.verb
    disp(sprintf(['Measurement %d of %d: ' ...
		  'sum_w = %10.0f, ' ...
		  'max_w =%10.5f, ' ...
		  'w_ratio =%10.5f, ' ...
		  'n_con = %d.'],...
		 i, ny, ...
		 D(i).sum_w, D(i).max_w, ...
		 D(i).max_w / D(i).sum_w, ...
		 D(i).n_con ));
  end

end

