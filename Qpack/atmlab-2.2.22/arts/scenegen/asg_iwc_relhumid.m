% ASG_IWC_RELHUMID modify the water vapour field in Gcs
%
% The function reguires that water vapour and
% temperatures are fields in Gcs, and iwc in
% Gdbz. The water vapor field is modified if
% the iwc is above zero in a given position. 
% A stochastic relative humidity field centered
% around 100% +-10% rhi is computed, and weighted with 
% the original relative humidity field (computed from 
% temperature and water vapour field).
%
% The "returned" relative humdity field is then
% rhi=w*rhi(stochastic)+(1-w)*rhi(original)
% where w=1-exp(-100*iwc)
%
% The relative humdity field is not returned,
% but the water vapour field in Gcs is modified.
%
% The grids of Q will determine the grids of
% of the water vapor data in the returned Gcs  
%
% OUT Gcs modified Gformat array
%
% IN  D    gformat definition structure
%     Gcs  gformat atmospheric data
%     Q    Qarts setting structure   

% 2007-12-12 created by Bengt Rydberg

function Gcs=asg_iwc_relhumid(Gcs,Q)

Q1=Q;

%find indices
water_ind=min(find(strncmp(lower({Gcs.DATA_NAME}),'h2o',3)));
tem_ind=min(find(strncmp(lower({Gcs.DATA_NAME}),'temperature',11)));
iwc_ind=min(find(strncmp(lower({Gcs.DATA_NAME}),'iwc',3)));

if isempty(water_ind)
   error('water vapour must be included in Gcs')
end

if isempty(tem_ind)
   error('Temperature must be included in Gcs')
end

if isempty(iwc_ind)
   error('iwc must be included in Gdbz')
end

dim1=Gcs(water_ind).DIM;
dim2=Gcs(tem_ind).DIM;
dim3=Gcs(iwc_ind).DIM;

%check dimensionality
if ~any(dim1==dim2 & dim1==dim3)

   error('all data has not the same dimensions')

end

%reduce the resolution of Gcs in order to be able
%to make perturbation while calling asg_rndmz
%without memory problem
dim=dim1;

Q.P_GRID         = 1000/16e3;
Q.LAT_GRID       =1;
Q.LON_GRID       =1;
Q.LAT_GRID = Gcs(iwc_ind).GRID2;
Q.LON_GRID = Gcs(iwc_ind).GRID3;

[grid1a] = gf_get_grid( Gcs(water_ind), 1 );
[grid1b] = gf_get_grid( Gcs(iwc_ind), 1 );
grid1=flipud(vec2col(sort(union(grid1a,grid1b))));
grid1 = gridconvert( grid1, false, @log10, true );
grid1 = gridthinning( grid1, Q.P_GRID );
Q.P_GRID = gridconvert( grid1, true, @pow10 );
 
if dim==3
  [grid1a] = gf_get_grid( Gcs(water_ind), 2 );
  [grid1b] = gf_get_grid( Gcs(iwc_ind), 2 );
  grid1=vec2col(sort(union(grid1a,grid1b)));
  grid1 = gridthinning( grid1, Q.LAT_GRID );
  Q.LAT_GRID=grid1;

  [grid1a] = gf_get_grid( Gcs(water_ind), 3 );
  [grid1b] = gf_get_grid( Gcs(iwc_ind), 3 );
  grid1=vec2col(sort(union(grid1a,grid1b)));
  grid1 = gridthinning( grid1, Q.LON_GRID );
  Q.LON_GRID=grid1;
end


Gcs1 = asg_regrid( Gcs([water_ind,tem_ind,iwc_ind]), Q );


%create a random relative humidity field
%
Grhi=Gcs1(1);
%set randomize parameters
if dim<4
   RND.FORMAT    = 'param'; 
   RND.SEPERABLE = 1;
   RND.CCO       = 0.01;           % Cut-off for correlation values 
   RND.TYPE      = 'rel';          % Relative disturbances as default
   RND.DATALIMS  = [0];            % Do not allow negative values
   %
   RND.SI        = 0.1;            % 10 % std. dev. as default
   %
   RND.CFUN1     = 'exp';              % Exp. correlation function for p-dim.
   RND.CL1       = [0.15 0.3 0.3]';    % Corr. length varies with altitude
   RND.CL1_GRID1 = [1100e2 10e2 1e-3];
end

if dim>1    
   %
   RND.CFUN2     = 'lin';            % Linear correlation function for lat-dim.
   RND.CL2       = 0.5;              % Corr. length 0.5 deg everywhere
   %
end

if dim>2
   RND.CFUN3     = 'lin';            % Linear correlation function for lat-dim.
   RND.CL3       = 0.5;              % Corr. length 0.5 deg everywhere
end

Grhi.RNDMZ=RND;

%set the field to be 1==100%rhi
Grhi.DATA=ones(size(Grhi.DATA));

%perturb the field
Grhi = asg_rndmz( Grhi );



%Equilibrium water vapor pressure over ice
ei = e_eq_ice(Gcs1(2).DATA);

%create a pressure matrix
P=zeros(size(Gcs1(3).DATA));
if dim==1
   P=Gcs1(3).GRID1;
end

if dim>1
   p=vec2col(Gcs1(3).GRID1)*ones(1,length(Gcs1(3).GRID2));
   if dim==2
      P=p;
   else
      for i=1:length(Gcs1(3).GRID3)
          P(:,:,i)=p;
      end
   end
end

%relative humdity 
rhi=Gcs1(1).DATA.*P./ei;

%weights
%an iwc of 0.1 will give 100% weight to the stochastic value
%0.01 63%
%0.001 10%
%0.0001 1%
w=1-exp(-100*Gcs1(3).DATA);

%apply the weights
rhi=w.*Grhi.DATA+(1-w).*rhi;

%transform back to vmr
Gcs1(1).DATA=rhi.*ei./P;

%regrid back to input grids
Gcs(water_ind)=asg_regrid(Gcs1(1),Q1);