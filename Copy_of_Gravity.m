classdef Gravity
    %UNTITLED Summary of this class goes here
    %   Inputs: 
    %       alt: a vector of altitudes at which you want acceleration due
    %       to gravity, in meters.
    %       lat: Vector of latitudes you want acceleration due to gravity
    %       at
    %       Model: String of the name of the model you want to use,
    %       Defaults to WGS84 (ISSI suggested gravity model)
    %            Options: WGS84
    
    properties
        accel  %(m/s)
        alt
        lat

    end
    
    methods
        function obj = Gravity(alt, lat, model)
            
            
            if(min(lat)<-90 | max(lat)>90)
                error('latitudes must be between -90 an 90');
            end

            if(min(alt)<0)
                error('Gravity model only works above the surface');
            end

            obj.alt = alt;
            obj.lat = lat;

            %If a model isn't specified, Use WGS84.  This will be the
            %recomendation in a paper that will be written in the future.
            if nargin==2
                model = 'WGS84';
            end
            
            if strcmpi('WGS84', model)
                
                lat = lat*pi/180; %convert from degrees to radians
                
                a1 = 6378137.0;%m             Ellipsoid's semi-major axis
                e  = 8.1819190842622e-2;%     Ellipsoid's first eccentricity
                gE = 9.7803253359;% ms^2      Theoretical (normal) gravity at the equator
                f = 1/298.257223563;%         Ellipsoidal flattening
                
                k = 0.00193185265241;
                m = 0.00344978650684;
                
                g0 =  repmat(gE * (1 + k * sin(lat).^2)./(sqrt(1-e.^2 * sin(lat).^2)),size(alt,2),1);
                
                
                obj.accel = g0.*(1 - (2/a1) * alt' *(1 + f + m - 2 * f * sin(lat).^2) + repmat((3/a1.^2) .*alt'.^2, size(lat)));
            else
                error('Gravity Model not found.')
            end
        end
    end
    
end
