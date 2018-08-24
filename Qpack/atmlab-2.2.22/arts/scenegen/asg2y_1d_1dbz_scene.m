% ASG2Y_1D_1DBZ_SCENE   Performs 1D scattering calculations based on ASG data 
%
%    Calculates spectrum/spectra considering scattering, where the spatial
%    structure of the clouds is taken from radar data.
%
%    The atmospheric scene is described by *Gcs* (clear sky fields) and *Gdbz*
%    (radar and auxiliary data). These gformat arrays are initially handled
%    seperately, mapped to grids specified by *grids_cs* and *grids_dbz*,
%    respectively. The data and grids are later merged and arts is called to
%    perform the calculations.
%
%    Remaining data are specified by Q. Not all fields must be set. These 
%    fields can be left undefined:
%       ATMOSPHERE_DIM
%       P_GRID
%       LAT_GRID
%       LON_GRID
%       all fields set *asg2q*
%
%    Note that batch calculations are not covered by this function.
%
% FORMAT   xxx
%        
% OUT   y           As returned by *arts_y*.
%       ydata       As returned by *arts_y*.
%       dy          As returned by *arts_y*.
%       G           modified G data
% IN    Gcs         Specification of clear sky fields, in gformat.
%       grids_cs    Initial grids for clear sky fields. These grids are used
%                   as put into Q before calling *asg_atmgrids*. Obtained
%                   grids are used e.g. when calling *asg_rndmz* for clear 
%                   sky fields. 
%                   The input is given as an array of vectors, where element  
%                   1 corresponds to Q.P_GRID, element 2 Q.LAT_GRID and 
%                   element 3 Q.LON_GRID. 
%       Gdbz        Field of radar dBz measurement, and possible additional 
%                   data (such as lidar or Doppler data), in gformat.
%                   Padding with zeros is made inside the function, and
%                   *Gdbz* should only contain data corresponding to the 
%                   "cloudy part" of the atmosphere.
%       grids_dbz   As *grids_cs* but used for *Gdbz*.
%       Q           Qarts structure. See above.
%       workfolder  Used as input to *asg2q*.

% 2008-02-06   Created by Bengt Rydberg.


function [y,ydata,dy,G] = ...
                 asg2y_1d_1dbz_scene(Gcs,grids_cs,Gdbz,grids_dbz,Q,workfolder)

%- Check input
%
% ???

%- Some fixed settings
%
D = asgD;
%


%- Determine grids for clear sky fields
%
Q.P_GRID   = grids_cs{1};
if Q.ATMOSPHERE_DIM==3
   Q.LAT_GRID = grids_cs{2};
   Q.LON_GRID = grids_cs{3};
end

%
Q = asg_atmgrids( D, Gcs, Q );

%This happens occasionally since the endpoints are
%treated separately in the functions, and we remove it 
if Q.P_GRID(end)==Q.P_GRID(end-1)
   Q.P_GRID=Q.P_GRID(1:end-1);
end

%- Create final clear sky fields
%

Gcs = asg_dimadd( D, Gcs, Q );
Gcs = asg_regrid( D, Gcs, Q );
Gcs = asg_fixed_relhumid( D, Gcs );
Gcs = asg_rndmz( D, Gcs );
Gcs = asg_hydrostat( D, Gcs, Q );


%- Determine grids for dbz field(s)
%
Q.P_GRID   = grids_dbz{1};
if Q.ATMOSPHERE_DIM==3
   Q.LAT_GRID = grids_dbz{2};
   Q.LON_GRID = grids_dbz{3};
end
%
Q = asg_atmgrids( D, Gdbz, Q );


%- Create final dbz field(s)
%

Gdbz = asg_dimadd( D, Gdbz, Q );
Gdbz = asg_regrid( D, Gdbz, Q );


%- Determine merged grids
%
% Smallest scalar value (if exist) in grids_cs and grids_dbz is used
% to remove very close grid points.
%
if isscalar( grids_cs{1} ),  step1=grids_cs{1};  else, step1=0; end
if isscalar( grids_dbz{1} ), step2=grids_dbz{1}; else, step2=0; end
Q.P_GRID = min( [ step1 step2] );
%
if Q.ATMOSPHERE_DIM==3
   if isscalar( grids_cs{2} ),  step1=grids_cs{2};  else, step1=0; end
   if isscalar( grids_dbz{2} ), step2=grids_dbz{2}; else, step2=0; end
   Q.LAT_GRID = min( [ step1 step2] );
   %
   if isscalar( grids_cs{3} ),  step1=grids_cs{3};  else, step1=0; end
   if isscalar( grids_dbz{3} ), step2=grids_dbz{3}; else, step2=0; end
   Q.LON_GRID = min( [ step1 step2] );
   %
end

Q = asg_atmgrids( D, [Gcs Gdbz], Q );


%- Make final re-gridding of clear sky fields
%
% Hydrostatic eq. does not necesserily apply at "new" points
%
Gcs = asg_regrid( D, Gcs, Q );
Gcs = asg_hydrostat( D, Gcs, Q );  


%- Pad dbz fields with zeros
%
% These fields do not need to match grids in Q. A reinterpolation is anyhow 
% done in ARTS
%
Gdbz = asg_zeropad( D, Gdbz, Q);
% As we fill data field with zeros, but the unit is in dBZe
% we give all zero valued data the minimum value (-50 )
Gdbz.DATA(find(Gdbz.DATA==0))=-50;  


%- Convert dbz field(s) to pnd fields but first regrid atmospheric fields
%  to the dbz grid
%
Q1          = Q;
Q1.P_GRID   = Gdbz.GRID1;
if Q.ATMOSPHERE_DIM==3
   Q1.LAT_GRID = Gdbz.GRID2;
   Q1.LON_GRID = Gdbz.GRID3;
end
Gcs1        = asg_regrid( D, Gcs, Q1 );
%
Gdbz = asg_dbz2pnd( D, [Gcs1 Gdbz], Q ,Gdbz.PROPS);
%remove atmospheric data from Gdbz
Gdbz = Gdbz(length(Gcs1)+1:end);

%- Modify water vapour to match cloud distribution
%
% How?
Gcs=asg_iwc_relhumid(D,Gcs,Gdbz,Q);
Gcs = asg_hydrostat( D, Gcs, Q );

%- Determine size of cloud box
%
iwc_ind = find( strcmp( lower({Gdbz.NAME}), 'iwc field' ) );
%
C1=[];
C2=[];
C3=[];
C4=[];
C5=[];
C6=[];
%
for i=1:size(Gdbz(iwc_ind).DATA,3)
  [c1,c2]=find(Gdbz(iwc_ind).DATA(:,:,i));
  if ~isempty(c1)
     C1=min([C1,vec2col(c1)']);
  end
  if ~isempty(c1)
     C2=max([C2,vec2col(c1)']);
  end
  if ~isempty(c2)
     C3=min([C3,vec2col(c2)']);
  end
  if ~isempty(c2)
     C4=max([C4,vec2col(c2)']);
  end
end
%
for i=1:size(Gdbz(iwc_ind).DATA,1)
  [c1,c2]=find(squeeze(Gdbz(iwc_ind).DATA(i,:,:)));
    if ~isempty(c2)
       C5=min([C5,vec2col(c2)']);
    end
    if ~isempty(c2)
       C6=max([C6,vec2col(c2)']);
   end
end
%

if ~isempty(C1) %if C1 is empty we don't have any cloud particles
    p1   = Gdbz(iwc_ind).GRID1(C1);
    p2   = Gdbz(iwc_ind).GRID1(C2);
    z    = p2z_cira86([p1 p2]',0,160);
    Q.CLOUDBOX.LIMITS = [z(1)-1e3 z(2)+1e3];
    if Q.ATMOSPHERE_DIM==3
       lat1 = Gdbz(iwc_ind).GRID2(C3);
       lat2 = Gdbz(iwc_ind).GRID2(C4);
       lon1 = Gdbz(iwc_ind).GRID3(C5);
       lon2 = Gdbz(iwc_ind).GRID3(C6);
       z    = p2z_cira86([p1 p2]',mean([lat1 lat2]),160);
       %
       Q.CLOUDBOX.LIMITS = [z(1)-1e3 z(2)+1e3 lat1 lat2 lon1 lon2];
    end
    %- Merge G arrays
    %
    G = [Gcs Gdbz];
else
    G = Gcs;
    Q.CLOUDBOX_DO=0;
end

%- Run ARTS
%
Q = asg2q( D, G, Q, workfolder );
Q                  = qarts_abstable( Q );
Q.ABS_LOOKUP       = arts_abstable( Q );
[y,ydata,dy] = arts_y( Q, workfolder )
    

