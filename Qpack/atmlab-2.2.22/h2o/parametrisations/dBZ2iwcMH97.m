% dBZ2iwcMH97 returns iwc from radar reflectivity and temperature
%             while assuming McFarquhar and Heymsfield (1997)
%             particle size dsitribution
%                          
%
% OUT      IWC is a matrix with iwc [g/m^3] profiles
%
% IN       dBZ [mm^6/m^-3] matrix 
%          outside this range nan is reported
%
%          T [K] matrix [limits: 200 - 272]
%          outside this range nan is reported
%
%          f frequency (scalar)
%
%          clo.do create look-up-table (0 or 1) 
%          clo.file filename where the look-up-table
%                   is/will be stored          
%
% 
%          comments: IWC values are linearly interpolated in 
%                    a look-up-table of IWC(dBZ,T).
%                    By advantage this look-up-table
%                    is precalculated and stored
%                    as a matlab file. The file is not large
%                    but take some time to calculate.
%          Example usage:
%              tmpfolder='/home/bengt/tmp';
%              clo.do=0;
%              clo.file=[tmpfolder,'/dBZ-data.mat']
%              dBZ=[-30 -40;-20 16];
%              T=[230 240;220 220];
%              [IWC] = dBZ2iwcMH97(dBZ,T,clo)
%
%
% FORMAT   [IWC] = dBZ2iwcMH97(dBZ,T,clo)
%
%
% History: 2007-03-27  Created by Bengt Rydberg
%

function [IWC] = dBZ2iwcMH97(dBZ,T,f,clo)

if  sum(size(T)==size(dBZ))~=2
   error('size of T must be equal size of dBZ!!!')
end
if clo.do~=0 & clo.do~=1
   error('clo.do must be 0 or 1!!!')
end
if ~isstr(clo.file)
    error('clo.file must be a string specifying a filename!!!')
end    
if  clo.do==0
    if exist(clo.file,'file')~=2 
        error(['the file ',clo.file,' does not exist!!!'])
    end
end

if clo.do
    
  %calculate the radar backscattering cross-section for spheres  
  %particle diameter
  D=5e-6:10e-6:1e-2;
  x_i=D/2;
  F=create_ssp('sphere',f,x_i/2);

  %loop over particle diameters
  for i=1:length(x_i)
      %radar backscattering per particle
      Q_b1(:,i)=4*pi*squeeze(F(i).pha_mat_data(1,:,end,1,1,1,1))';
      %extinction per particle
      Q_b2(:,i)=F(i).ext_mat_data;
  end
  
  %create the look-up-table
  c=3e8;
  lambda=c/f;
  nwater=sqrt(eps_water_liebe93(f,273.15));
  Kwater=( abs( (nwater.^2-1)./ (nwater.^2+2) ) ).^2;
  % 
  IWCv = logspace(-3.65,0.58,100);
  Tv   = 190:2:272;
  mode = 1;
  %
  dx=D(2)-D(1);
  T_grid=F(1).T_grid;
  %loop over Tv and IWCv to find dBZ(T,IWC)
  clear y Z ext
  for j=1:length(Tv)
      sigma_b=interp1(T_grid,Q_b1,Tv(j));
      sigma_c=interp1(T_grid,Q_b2,Tv(j));
      for i=1:length(IWCv)
          y(i,:) = ice_psd_Mcfar_97(Tv(j),IWCv(i),D,mode);
      end
      Z(j,:)=lambda^4 /(pi^5)/Kwater*...
             sum([y.*[ones(length(IWCv),1)*sigma_b]*dx]');
      ext(j,:)=sum([y.*[ones(length(IWCv),1)*sigma_c]*dx]');
  end
  dBZm=10*log10(Z*1e18);

  %plot a figure showing the relationships
  if 0
     semilogy(dBZm,IWCv)
     legend(num2str(Tv'))
  end

  %re-arrange the look-up-table [IWC(T,dBZ)]
  dBZv=[-40:1:15];
  for i=1:size(dBZm,1)
      IWCC(i,:)=interp1(dBZm(i,:),IWCv,dBZv);
  end
  P.IWC=IWCC;
  P.T=Tv;
  P.dBZ=dBZv; 
  
  save(clo.file,'P')
end

load(clo.file)

ind1=find(isnan(dBZ(:)));
ind2=find(isnan(T(:)));
ind=union(ind1,ind2);
ind=setdiff(1:length(dBZ(:)),ind); 


IWC=zeros(size(dBZ));
IWC(ind)=interp2(P.dBZ,P.T,P.IWC,dBZ(ind),T(ind));


%- Handle data outisde covered dBZ-T area
%
% Low dBZ and high/low T -> IWC = 0 
ind      = find( dBZ<min(P.dBZ) |  T>max(P.T) |  T<min(P.T) );
IWC(ind) = 0;
%
% High dBZ -> max(IWC)
ind      = find( dBZ>max(P.dBZ) );
IWC(ind) = mean( max( P.IWC' ) );


if any(isnan(IWC))
  fprintf( 'NaN found. Check cause!\n' );
  keyboard
end