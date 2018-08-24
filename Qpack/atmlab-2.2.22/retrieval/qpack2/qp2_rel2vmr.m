% QP2_REL2VMR  Convert 'rel' or 'logrel' data to VMR
%
%    If one or several absorption species have been retrieved with 'rel' or
%    'logrel' as unit, but prefer to have the L2 data as VMR values, this
%    function makes the conversion.
%    
%    The L2 data must contain the a priori state (species1_xa etc.). This field
%    is used to determine the retrieval unit used. A field holding the a priori
%    VMR (species1_vmr0 etc.) must also exist (added automatically by
%    *qp2_l2*). After the conversion, the a priori field (xa) is modified and
%    the VMR field is removed.
%
%    IMPORTANT: Only fields starting with "species" are treated. This means
%    that e.g. the Jacobian (J) and covariance matrices are not converted.
%    Averaging kernels are converted as they are stored separately among the
%    species. 
%
%    Note that if L2_RANGE has been used to include parts outside the range of
%    the retrieval grids, the obtained VMR profile is not representing those
%    parts correctly (the L2 data will only have a straight line for those
%    parts). 
%
%    For 'logrel', errors are converted simply as e_vmr = e*x_vmr.
%
% FORMAT   L2 = qp2_rel2vmr( L2 )
%        
% OUT      L2   Modified L2 data structure.
% IN       L2   Original L2 data structure.

% 2012-02-07   Created by Patrick Eriksson.

function L2 = qp2_rel2vmr(L2)
  
i     = 0;
ready = false;

while ~ready
  
  i = i + 1;
  
  nx = sprintf( 'species%d_x', i );
  
  if ~isfield( L2, nx )
    ready = true;
  
  else
    
    % Define name strings
    % 
    na = sprintf( 'species%d_xa', i );
    nv    = sprintf( 'species%d_vmr0', i );
    nA    = sprintf( 'species%d_A', i );
    nmr   = sprintf( 'species%d_mr', i );
    ns{1} = sprintf( 'species%d_e', i );
    ns{2} = sprintf( 'species%d_eo', i );
    ns{3} = sprintf( 'species%d_es', i );
    nsx   = sprintf( 'species%d_ex', i );
    
    rqre_field( L2, nv, 'sub-field vmr0' );

    if isfield( L2, nmr )  &  ~isfield( L2, nA )
      error( 'Handling of measurement response requires that A is part of L2' );
    end

    
    % Retrieval unit determined for each L2 element, to be safe 
    
    for j = 1: length(L2)

      % Use xa to determine retrieval unit
      %    
      xa = L2(j).(na);
      %
      rel    = false;
      logrel = false;
      mval   = max(xa);
      %
      if mval == 0
        logrel = true;
      elseif mval < 1
        % VMR
      elseif mval == 1  &  min(xa) == 1
        rel = true;
      end  % Remaining option mval>1 equals nd
    
      % Ready if VMR or ND

      if rel | logrel  
    
        vmr0       = L2(j).(nv);

        % rel
        if rel
          L2(j).(nx) = L2(j).(nx) .* vmr0;
          L2(j).(na) = vmr0;
          %
          if isfield( L2, nA )
            L2(j).(nA) = L2(j).(nA) .* (vmr0*(1./vmr0'));
            if isfield( L2, nmr )
              L2(j).(nmr) = mrespA( L2(j).(nA), [1 length(vmr0)] );
            end
          end
          %
          for k = 1 : length(ns)
            if isfield( L2, ns{k} )
              L2(j).(ns{k}) = L2(j).(ns{k}) .* vmr0;
            end
          end
          %
          if isfield( L2, nsx )
            L2(j).(nsx) = L2(j).(nsx) .* vmr0;
          end

          
        % logrel
        else
          L2(j).(nx) = exp(L2(j).(nx)) .* vmr0;
          L2(j).(na) = vmr0;
          %
          if isfield( L2, nA )
            L2(j).(nA) = L2(j).(nA) .* (L2(j).(nx)*(1./L2(j).(nx)'));
            if isfield( L2, nmr )
              L2(j).(nmr) = mrespA( L2(j).(nA), [1 length(vmr0)] );
            end
          end
          %
          for k = 1 : length(ns)
            if isfield( L2, ns{k} )
              L2(j).(ns{k}) = L2(j).(ns{k}) .* L2(j).(nx);
            end
          end
          %
          if isfield( L2, nsx )
            L2(j).(nsx) = L2(j).(nsx) .* vmr0;
          end
        end

      end  
    end  
    
    L2 = rmfield( L2, nv );

  end   % if "species exist"
end   % while
