%asg_dbz2pnd calculates iwc and pnd fields
%
% FORMAT   G=asg_dbz2pnd( G, Q, P)
% 
% OUT      G        Modified gformat data,now including
%                   IWC and PND data
% IN     
%          G        original gformat data 
%          Q        Qarts setting structure.            
%          P        conversion structure of length 2
%                   P(1) corresponds to the radar frequency                    
%                   P(2) corresponds to the instrument frequencys 
%                   with fields                  
%            SSP    single scattering properties    
%            PSD    particle size dist. choice
%                   'MH97' is the only valid option
%            method method for calculating particle
%                   number density fields
%                   'gauss-laguerre' is the only valid option
%            x      particle diameter (see function gauss_laguerre
%                   for help)                     
%            w      weights
%            x_norm normalisation factor 
%            shape  particle shape
%                   'sphere' is the only valid option 
%
%  2007-11-13 created by Bengt Rydberg

function [G]= asg_dbz2pnd(  G, Q ,P);

r_ind=find(strncmp(lower({G(:).NAME}),'radar',5));
t_ind=find(strncmp(lower({G(:).NAME}),'temperature',11));
z_ind=find(strncmp(lower({G(:).NAME}),'altitude',8));

dBZ=G(r_ind).DATA;
T=G(t_ind).DATA;
ALT=G(z_ind).DATA;

warning off

if length(P)~=2
   error('P structure must be of length 2')
end

if ~exist('T','var') & ~exist('dBZ','var')
   error('G must hold Temperature and Radar_Reflectivity data')
end


if strcmp(P(1).method,'gauss-laguerre')
   len=size(P(1).radar_back,1);
   if length(P(1).x)~=len & length(P(1).w)~=len
      error('mismatch in size between P(1).radar_back,P(1).x, and P(1).w')
   end
   Q_b1=P(1).radar_back';
   %create the look-up-table for iwc
   c=constants('SPEED_OF_LIGHT');
   f=P(1).F_GRID;
   lambda=c/f;
   nwater=sqrt(eps_water_liebe93(f,273.15));
   Kwater=( abs( (nwater.^2-1)./ (nwater.^2+2) ) ).^2;
   IWCv=logspace(-3.65,0.5,100);
   Tvi=180:2:273;
   T_grid=P(1).T_grid;
   %loop over Tv and IWCv to find dBZ(T,IWC)
   for j=1:length(Tvi)
       sigma_b=interp1(T_grid,Q_b1,Tvi(j));
       %sigma_c=interp1(T_grid,Q_b2,Tvi(j));
       for i=1:length(IWCv)
           if strcmp(P(1).PSD,'MH97')
              y(i,:) = ice_psd_Mcfar_97(Tvi(j),IWCv(i),P(1).x,1);
              %rho=0.91e6;
              %a=1;
              %N=6*IWCv(i).*((3.67+a)./dm).^(4+a)/(rho*pi*gamma(4+a));
              %y(i,:)=N*P(1).x.^a.*exp(-(3.67+a)*P(1).x/dm);
              Y(i,:) = gauss_laguerre_apply(y(i,:)',P(1).x,P(1).w,P(1).x_norm);
           else
             error('MH97 is the only valid option for P.PSD')
           end
       end
       Z(j,:)=lambda^4 /(pi^5)/Kwater*...
                           sum([Y.*[ones(length(IWCv),1)*sigma_b]]');
       %ext(j,:)=sum([Y.*[ones(length(IWCv),1)*sigma_c]]');
   end
   dBZm=10*log10(Z*1e18);
   
   len=size(P(2).radar_back,1);
   if length(P(2).x)~=len & length(P(2).w)~=len
      error('mismatch in size between P(2).SSP,P(2).x, and P(2).w')
   end
   clear Q_b1 Q_b2 y Y
   Q_b1=P(2).radar_back';
  
   %create the look-up-table for lwc
   LWCv=logspace(-3.65,2,100);
   %IWCv=logspace(-4,6,100);
   Tvw=273:2:313;
   T_grid=P(2).T_grid;
   %loop over Tv and IWCv to find dBZ(T,IWC)
   for j=1:length(Tvw)
       sigma_b=interp1(T_grid,Q_b1,Tvw(j));
       %sigma_c=interp1(T_grid,Q_b2,Tvw(j));
       for i=1:length(IWCv)
           if strcmp(P(2).PSD,'Water')
              c1=6;c2=1;rc=10;
              y(i,:)=water_psd(LWCv(i),P(2).x,rc,c1,c2)';
              %rho=0.91e6;
              %a=1;
              %N=6*IWCv(i).*((3.67+a)./dm).^(4+a)/(rho*pi*gamma(4+a));
              %y(i,:)=N*P(1).x.^a.*exp(-(3.67+a)*P(1).x/dm);
              Y(i,:) = gauss_laguerre_apply(y(i,:)',P(2).x,P(2).w,P(2).x_norm);
           else
             error('not a valid option for P.PSD')
           end
       end
       Zw(j,:)=lambda^4 /(pi^5)/Kwater*...
                           sum([Y.*[ones(length(IWCv),1)*sigma_b]]');
       %extw(j,:)=sum([Y.*[ones(length(IWCv),1)*sigma_c]]');
   end
   dBZmw=10*log10(Zw*1e18);


   %estimate the unattenuated dBZ field
   if 0

   dBZp=zeros(size(dBZ));
   for i=1:size(dBZ,2) 
    for j=1:size(dBZ,3)
     for k=size(dBZ,1):-1:1
       %ind of the closest temperature
       if T(k,i,j)<273
        ind=find(abs(T(k,i,j)-Tvi)==min(abs(T(k,i,j)-Tvi)));
        ice=1;
       else
        ind=find(abs(T(k,i,j)-Tvw)==min(abs(T(k,i,j)-Tvw)));
        ice=0;
       end

       if k==size(dBZ,1)
        dz=ALT(k,i,j)-ALT(k-1,i,j);
        if ice
         qext(k)=interp1(10.^(dBZm(ind,:)/10),ext(ind,:),...
                        10^(dBZ(k,i,j)/10),'linear','extrap')*dz;
        else
         qext(k)=interp1(10.^(dBZmw(ind,:)/10),extw(ind,:),...
                        10^(dBZ(k,i,j)/10),'linear','extrap')*dz;  
        end
       elseif k<size(dBZ,1) & k>1

        dz=( [ALT(k,i,j)-ALT(k-1,i,j)] + [ALT(k+1,i,j)-ALT(k,i,j)] )/2;
        if ice
         qext(k)= interp1(10.^(dBZm(ind,:)/10),ext(ind,:),...
                         10^(dBZp(k,i,j)/10),'linear','extrap')*dz;
        else
         qext(k)= interp1(10.^(dBZmw(ind,:)/10),extw(ind,:),...
                         10^(dBZp(k,i,j)/10),'linear','extrap')*dz;
        end
       else

        dz=ALT(k+1,i,j)-ALT(k,i,j);
        if ice
         qext(k)=interp1(10.^(dBZm(ind,:)/10),ext(ind,:),...
                        10^(dBZp(k,i,j)/10),'linear','extrap')*dz;
        else
         qext(k)=interp1(10.^(dBZmw(ind,:)/10),extw(ind,:),...
                        10^(dBZp(k,i,j)/10),'linear','extrap')*dz;
        end 
       end
       %if qext(k)>10
       %   qext(k)=10;
       %end
       %two way transmission
       sqext2(k)=2*sum(qext(k:size(ALT,1)));
       trans2(k)=exp(-sqext2(k));
       %self layer transmission 
       trans1(k)=exp(-qext(k));

       if k~=1 & k~=size(ALT,1)
        dBZp(k,i,j)=10*log10(10^(dBZp(k,i,j)/10)/trans1(k)); 
        dBZp(k-1,i,j)=10*log10(10^(dBZ(k-1,i,j)/10)/trans2(k)); 
       elseif k==1
        dBZp(k,i,j)=10*log10(10^(dBZp(k,i,j)/10)/trans1(k));
       else
        dBZp(k,i,j)=10*log10(10^(dBZ(k,i,j)/10)/trans1(k));
        dBZp(k-1,i,j)=10*log10(10^(dBZ(k-1,i,j)/10)/trans2(k));
       end
     end
    end
   end
      
   

   %set all modified dBZp to min(dBZ) for these original dBZ==min(dBZ)
   %since otherwise we may strecth out the clouds 
   mindBZ=min(min(min(dBZ)));
   dBZp(find(dBZ==mindBZ))=mindBZ;

   end

   %re-arrange the look-up-table [IWC(T,dBZ)]
   dBZv=[-49:1:30];
   %dBZv=[-49:1:50];
   for i=1:size(dBZm,1)
       IWCC(i,:)=interp1(dBZm(i,:),IWCv,dBZv);
   end
   %IWC=interp2(dBZv,Tvi,IWCC,dBZp,T);
   IWC=interp2(dBZv,Tvi,IWCC,dBZ,T);
   IWC(isnan(IWC))=0;
   IWC(find(T>273))=0;
   
   %re-arrange the look-up-table [LWC(T,dBZ)]
   dBZv=[-49:1:30];
   %dBZv=[-49:1:50];
   for i=1:size(dBZmw,1)
       LWCC(i,:)=interp1(dBZmw(i,:),LWCv,dBZv);
   end
   %LWC=interp2(dBZv,Tvw,LWCC,dBZp,T);
   LWC=interp2(dBZv,Tvw,LWCC,dBZ,T);
   LWC(find(T<=273))=0;
   LWC(isnan(LWC))=0;
  
 


   %put in IWC and LWC in G
   glen=length(G);   
   G(glen+1)=G(glen);
   G(glen+1).NAME='IWC field';
   G(glen+1).DATA=IWC;
   G(glen+1).DATA_NAME='IWC';
   G(glen+1).DATA_UNIT='gm-3';
   G(glen+1).SOURCE='';
   
   %setting in PND fields in G
   Ni=length(P(1).x);
   if ~strcmp(P(1).shape,'sphere')
      error('sphere is the only valid option for P.shape')
   end
   if strcmp(P(1).PSD,'MH97')
      y=zeros(length(IWC(:)),Ni);
      ivec=find(IWC);
      for i=ivec'
          y(i,:) = ice_psd_Mcfar_97(T(i),IWC(i),P(1).x,1);
      end
      Y = gauss_laguerre_apply(y',P(1).x,P(1).w,P(1).x_norm);
      for i=1:Ni
          G(glen+1+i)=G(glen+1);
          G(glen+1+i).DATA=reshape(Y(i,:),size(IWC));
          G(glen+1+i).PROPS=[];
          G(glen+1+i).NAME=['Particles ',num2str(P(1).x(i)*1e6),' um'];
          G(glen+1+i).DATA_NAME=['Particle number density'];
          G(glen+1+i).DATA_UNIT=['m-3'];
      end
   end
 
   glen=length(G);   
   G(glen+1)=G(glen);
   G(glen+1).NAME='LWC field';
   G(glen+1).DATA=LWC;
   G(glen+1).DATA_NAME='IWC';
   G(glen+1).DATA_UNIT='gm-3';
   G(glen+1).SOURCE='';
   
   %setting in PND fields in G
   Ni=length(P(2).x);
   if ~strcmp(P(2).shape,'sphere')
      error('sphere is the only valid option for P.shape')
   end
   if 0 %strcmp(P(4).PSD,'Water')
      y=zeros(length(LWC(:)),Ni);
      ivec=find(LWC);
      for i=ivec'
          %N=6*IWC(i).*((3.67+a)./dm).^(4+a)/(rho*pi*gamma(4+a));
          %y(i,:)=N*P(4).x.^a.*exp(-(3.67+a)*P(2).x/dm);
          %y(i,:) = ice_psd_Mcfar_97(T(i),IWC(i),P(2).x,1);
          y(i,:)=water_psd(LWC(i),P(4).x,rc,c1,c2)';
      end
      Y = gauss_laguerre_apply(y',P(4).x,P(4).w,P(4).x_norm);
      for i=1:Ni
          G(glen+1+i)=G(glen+1);
          G(glen+1+i).DATA=reshape(Y(i,:),size(IWC));
          G(glen+1+i).PROPS=P(4).SSP(i);
          G(glen+1+i).NAME=['Particles ',num2str(P(4).x(i)*1e6),' um'];
          G(glen+1+i).DATA_NAME=['Particle number density'];
          G(glen+1+i).DATA_UNIT=['m-3'];
      end
   end
   

else 
  error('gauss-laguerre is the only valid method')
end


warning on