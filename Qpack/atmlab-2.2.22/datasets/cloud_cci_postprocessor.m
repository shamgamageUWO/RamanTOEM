function S = cloud_cci_postprocessor(self,S,fields)
%% clouds_cci_postprocessor
%
% PURPOSE: To create "pseudo" fields that are not in the original cloud_cci
%          data by post-processing fields that are in the original data
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
% $Id: cloud_cci_postprocessor.m 8312 2013-03-26 19:17:31Z seliasson $
% Salomon Eliasson


for F =fields
    field = F{1};
    mv = self.pseudo_fields.(field).atts.missing_value;
    switch field
        case {'iwp','ref_ice','cot_ice','iwp_error'}
            % Keeping record of the pixels that are deemed to be cloud free
            clearPixel = S.cc_total==0;
            
            % grab values flagged as ice phase
            icePhase = S.phase==2;

      otherwise
        error(['atmlab:' mfilename],'field: %s not found',field)
    end
    switch field
        case 'iwp'
            % depends on {cwp'  'phase'  'cc_total'}

            S.cwp(~(clearPixel | icePhase)) = mv;
            S.iwp = S.cwp;
            S.iwp(clearPixel) = 0; 
        case 'ref_ice'
            % depends on {'phase','ref','cc_total'}
            
            S.ref(~(clearPixel | icePhase)) = mv;
            S.ref_ice = S.ref;
            S.ref_ice(clearPixel) = 0; 
        case 'cot_ice'
            % depends on {'phase','cot','cc_total'}
            
            S.cot(~(clearPixel | icePhase)) = mv;
            S.cot_ice = S.cot;
            S.cot_ice(clearPixel) = 0; 
            
        case 'iwp_error'
            S.iwp_error = S.cwp_uncertainty;
            S.iwp_error(~icePhase) = mv;
        otherwise
            error(['atmlab:' mfilename],'field: %s not found',field)
    end
    
end

end
