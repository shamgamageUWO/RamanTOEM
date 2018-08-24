function S = modis_postprocessor(self,S,fields)
%% modis_postprocessor
%
% PURPOSE: To create "pseudo" fields that are not in the original modis data by 
%          post-processing fields that are in the original data
%
%
% IN
%     self = dataset
%     S = Data structure to add pseudo field to (from self.reader)
%     fields = {'names','of','pseudo','fields'}
%
% OUT
%     S = Data structure + pseudo field/s
%
% NOTE: See also help Satdataset/pseudo_fields
%
% $Id: modis_postprocessor.m 8286 2013-03-11 20:27:31Z seliasson $
% Salomon Eliasson


% READ dependent fields
% So far this function assumesa you always need cloud phase and quality
% flag
% common_fields = {'Quality_Assurance_1km','Cloud_Phase_Optical_Properties'};
% associatedFields = {'Cloud_Water_Path','Cloud_Effective_Radius','Cloud_Optical_Thickness'};
% pseudo_fields = {'modis_IWP','Tau_ice','Re_ice'};
% dependent_fields = [common_fields,associatedFields(ismember(pseudo_fields,fields))];

if any(ismember(fields,{'modis_IWP','modis_IWP_uncertainty','Tau_ice','Re_ice','Tau_ice_uncertainty','Re_ice_uncertainty'}))
    
    % Keeping record of the pixels that are deemed to be cloud free
    clearPixel = S.Cloud_Phase_Optical_Properties==1;

    % Removing all points that are not flagged as ice clouds
    icePhase = S.Cloud_Phase_Optical_Properties==3;

    % only KEEP retrievals that are USEFUL and CONFIDENT

    % this corresponds to the 1st and 2nd bit in the 2nd byte in
    % Quality_Assurance_1km (regarding cloud_water_path. I assume the
    % same apply to Re and Tau that CWP is based on anyway). By doing this
    % I'm also disregarding values with marginal confidence
    usefull=uint8(sum(2.^[0,1]));

    % bitand only works on vectors
    S.Quality_Assurance_1km = permute(S.Quality_Assurance_1km,[3,1,2]);

    flaggedAsGood = bitand(typecast(S.Quality_Assurance_1km(2,:),'uint8'),usefull)==usefull;
    flaggedAsGood = reshape(flaggedAsGood,size(icePhase,1),size(icePhase,2));

end

D = datasets;
for F = fields
    mv = D.modis_aqua_L2.pseudo_fields.(F{1}).atts.missing_value;
    switch F{1}
        case 'modis_IWP'
            S.modis_IWP = S.Cloud_Water_Path;
            S.modis_IWP(~(clearPixel | (icePhase & flaggedAsGood))) = mv;
            S.modis_IWP(clearPixel)=0;
        case 'modis_IWP_uncertainty'
            logtext(atmlab('OUT'),'scaling Cloud_Water_Path_Uncertainty by 0.01\n')
            S.modis_IWP_uncertainty = S.Cloud_Water_Path_Uncertainty*0.01;
            S.modis_IWP_uncertainty(~(clearPixel | (icePhase & flaggedAsGood))) = mv;
        case 'Re_ice'
            S.Re_ice = S.Cloud_Effective_Radius; %scale by *0.01;
            S.Re_ice(~(clearPixel | (icePhase & flaggedAsGood)))=mv;
            S.Re_ice(clearPixel)=0;
        case 'Re_ice_uncertainty'
            logtext(atmlab('OUT'),'scaling Cloud_Effective_Radius_Uncertainty by 0.01\n')
            S.Re_ice_uncertainty = S.Cloud_Effective_Radius_Uncertainty*0.01;
            S.Re_ice_uncertainty(~(clearPixel | (icePhase & flaggedAsGood))) = mv;
        case 'Tau_ice'
            logtext(atmlab('OUT'),'scaling Cloud_Optical_Thickness by 0.01\n')
            S.Tau_ice = S.Cloud_Optical_Thickness*0.01;
            S.Tau_ice(~(clearPixel | (icePhase & flaggedAsGood))) = mv;
            S.Tau_ice(clearPixel)=0;
        case 'Tau_ice_uncertainty'
            logtext(atmlab('OUT'),'scaling Cloud_Optical_Thickness_Uncertainty by 0.01\n')
            S.Tau_ice_uncertainty = S.Cloud_Optical_Thickness_Uncertainty*0.01;
            S.Tau_ice_uncertainty(~(clearPixel | (icePhase & flaggedAsGood))) = mv;
    end
    S.(F{1})(S.(F{1})<0) = mv; % since none of these quantities are negative
end

end