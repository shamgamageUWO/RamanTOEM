% ice_particleshape_Hogan2012   Dimension parameters(long and short diameters)
%                               and density of a non-spherical and non-solid 
%                               ice particle that composes ice matrix with air inclusion.
%                         
%
%             The equivalent mass of a spherical solid ice is calculated upon the 
%             distribution of mass equivalent spheres m=(power(d,3)*pi*rhoice)/6;  
%             then according to Brown and Francis(1995)relationship between
%             particle mass and size, the mean and max(long) diameters, 
%             and inclusion media fraction of a non-spherical(spheroidal) 
%             particle which has the *same mass*, are computed.
%             
%             Note that all of the outputs are as a function of mass-equivalent 
%             diameter (d).
%             
%             The parameterization is taken from R. Hogan et al(2012).
%             "Radar Scattering from Ice Aggregates Using the Horizontally 
%             Aligned Oblate Spheroid Approximation".
%             
%                        
% 
% FORMAT         [diameter_max diameter_short aspect_ratio mixfrac rho]= ice_particleshape_Hogan2012(d)
%        
% OUT  diameter_max   longest diameter of an aligned oblate spheroid particle  [m]      
%      diameter_short shortest diameter of an aligned oblate spheroid particle [m]  
%      aspect_ratio   d_short / d_long
%      mixfrac        Fraction of inclusion media (air) in ice matrix.
%      rho            Density of a sheroid of non-solid ice particle      [kg/m^3]
%                     (mixture of ice and air)               
%
% IN   d              mass equivalent diameter       [m]     
       
% 2013-08-09    Created by Maryam Jamali


function  [diameter_max diameter_short aspect_ratio mixfrac rho]= ice_particleshape_Hogan2012(d)


rhoice=0.917*1e3;     % kg/m^3

%To calculate diameter_max and diameter_short :
for i=1:length(d)
    m=(power(d(i),3)*pi*rhoice)/6;   %kg 
    D_0=power((m./(pi*rhoice/6)),(1/3));
    
    if D_0 < 97e-6
    diameter_mean(i)=D_0;
    else
    diameter_mean(i)=power((m./0.0185), (1/1.9));
    end

    if  D_0 < 66e-6
    diameter_max(i)=D_0;
    else
    diameter_max(i)=power((m./0.0121), (1/1.9));
    end
    
    diameter_long(i) =diameter_max(i);
    diameter_short(i)=(2*diameter_mean(i))-diameter_max(i);
    aspect_ratio(i)=diameter_short(i)./diameter_long(i);
    
    volume_ice(i)= (pi/6).* power(d(i),3);
    
    if diameter_short(i)==diameter_long(i)
    rho(i)=rhoice;
    volume_spheroid(i)=volume_ice(i);
    else
    volume_spheroid(i)=(pi/6).*power(diameter_long(i),2).*diameter_short(i);
    rho(i)=m./volume_spheroid(i); % kg/m^3
    end
end

mixfrac=(volume_spheroid - volume_ice)./ volume_spheroid;
