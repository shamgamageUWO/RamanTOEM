%ASG_PATHIWC calulates iwc and iwp and rhi along geometric propagation path
%
%     This function calculates the geometric propagation
%     path from a given height to the tangent point in steps 
%     of 100 m. The IWC field in G is simply linearly
%     3-D interpolated (in altitude, latitude,longitude)
%     on this path. Reguired data in G is IWC, Altitude
%     Temperature, and Water vapour field. 
%
%OUT  P.z   altitude along propagation path
%     P.lat latitude along propagation path
%     P.lon longitude along propagation path
%     P.iwc ice water content along propagation path
%     P.iwp vertical ice water path above the tangent point
%     P.rhi relative humidity w.r.t. ice
%    
%IN   
%     G     ASG data.
%     Q     Qarts setting structure
%           Only Q.SENSOR_LOS and Q.SENSOR_POS are considered
%     z_max maximum altitude of the propagation path
%           taking into consideration

% 2007-12-06   Created by Bengt Rydberg

function P=asg_pathiwc(G,Q,z_max)


%find the data of interest
iwc_ind=find(strncmp(lower({G.NAME}),'iwc',3));
alt_ind=find(strncmp(lower({G.NAME}),'altitude',8));
hum_ind=min(find(strcmp(lower({G.NAME}),'h2o')));
tem_ind=find(strncmp(lower({G.NAME}),'temperature',11));
lwc_ind=find(strncmp(lower({G.NAME}),'iwc',3));


if isempty( iwc_ind )
   error('G must contain IWC field')
end

if isempty( alt_ind )
   error('G must contain Altitude field')
end

if isempty( hum_ind )
   error('G must contain Water vapour')
end

if isempty( tem_ind )
   error('G must contain Temperature field')
end

if isempty( lwc_ind )
   error('G must contain LWC field')
end

deg2rad = constants( 'DEG2RAD' );

%regrid the fields on the same grids

Q2 = asg_atmgrids( D, G, Q );

%remove endpoints since these can cause problems
%in interpolation, we are not anyway interested 
%in these
    
Q2.P_GRID=Q2.P_GRID(2:end-1);

if ~isempty(iwc_ind)
    %H=asg_regrid(G([alt_ind,hum_ind,tem_ind,iwc_ind,lwc_ind]),Q2);
    H=G([alt_ind,hum_ind,tem_ind,iwc_ind,lwc_ind]);
else
    %H=asg_regrid(G([alt_ind,hum_ind,tem_ind]),Q2);
    G([alt_ind,hum_ind,tem_ind]);
end

%create a pressure matrix

Pr=zeros(size(H(1).DATA));
for i=1:length(H(1).GRID3)
    Pr(:,:,i)=vec2col(H(1).GRID1)*ones(1,length(H(1).GRID2));
end

%create meshgrids to be used in interpolation
[X,Y,Z]=meshgrid(H(1).GRID2,H(1).DATA(:,round(end/2),round(end/2)),H(1).GRID3);

%loop over sensor positions and line of sights
%

for pp=1:size(Q.SENSOR_POS,1)

    pos=Q.SENSOR_POS(pp,:);
    los=Q.SENSOR_LOS(pp,:);
    
    [x,y,z,dx,dy,dz] = arts_poslos2cart( pos(1),pos(2),pos(3),los(1),los(2) );

    %find the propagation path from the sensor to the tangent point
    %

    %the length from the sensor to the tangent point
    l_sen=pos(1)*cos( (180-los(1)) *deg2rad);

    %length of each step
    l_step=1e2;

    %make a vector of propagation steps
    l_sen=unique([ [0:l_step:l_sen] l_sen]);

    %the propagation path in cartesian cord.
    [x,y,z]=deal(x+dx*l_sen,y+dy*l_sen,z+dz*l_sen);

    %the propagation path in spherical cord.
    [r,lat,lon] = arts_cart2sph(x,y,z);

    %the geoid radius at the tangent point
    %re = interp1( [-90:1:90], wgs84( 2, [-90:1:90]), lat(end) );
    re = Q.R_GEOID;  

    %interpolate the data field on the propagation path
    %

    %remove high altitude points
    z_grid=r-re;
    ind=find(z_grid<z_max & z_grid>-1e3);
    
    z_grid=z_grid(ind);
    lat=lat(ind);
    lon=lon(ind);
   
    if ~isempty(iwc_ind)
       IWC=interp3(X,Y,Z,H(4).DATA,lat,z_grid,lon);
    end
    HUM=interp3(X,Y,Z,H(2).DATA,lat,z_grid,lon);
    TEM=interp3(X,Y,Z,H(3).DATA,lat,z_grid,lon);
    PRE=exp(interp3(X,Y,Z,log(Pr),lat,z_grid,lon));
    LWC=interp3(X,Y,Z,H(5).DATA,lat,z_grid,lon);

    %Equilibrium water vapor pressure
    ei = e_eq_ice(TEM);

    %Relative humidity w.r.t. ice
    RH=PRE.*HUM./ei*100;
  
    P(pp).z=z_grid;
    P(pp).lat=lat;
    P(pp).lon=lon;
    if ~isempty(iwc_ind)
       %set all nan values to 0
       IWC(find(isnan(IWC)))=0;
       LWC(find(isnan(LWC)))=0;
       P(pp).iwc=IWC;
       P(pp).lwc=LWC;
       P(pp).iwp=sum( (P(pp).z(1:end-1)-P(pp).z(2:end))...
                    .* (IWC(1:end-1)+IWC(2:end))/2 );
    else
      P(pp).iwc=zeros(size(z_grid));
      P(pp).iwp=0;
    end
    P(pp).rhi=RH;
    P(pp).t=TEM;

end
