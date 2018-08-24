function S = cpr_postprocessor(self,S,flds)
%% CPR_POSTPROCESSOR
%
% PURPOSE: To create "pseudo" fields that are not in the original cloudsat
%          data by post-processing fields that are in the original data
%
%
% IN
%     self = dataset
%     S = Data structure to add pseudo field to (from self.reader)
%     flds = {'names','of','pseudo','fields'} (fields)
%
% OUT
%     S = Data structure + pseudo field/s
%
% NOTE: See also help Satdataset/pseudo_fields
%
% $Id: cpr_postprocessor.m 8433 2013-05-22 13:29:28Z seliasson $
% Salomon Eliasson

% --------------
% Do operations
% --------------


for F =flds
    field = F{1};
    % get the missing value
    mv = self.pseudo_fields.(field).atts.missing_value;
    switch field
        case {'Cloud_Types','Cloud_Types_multiLayer'}

            % preallocate
            x.cloudy = false(size(S.cloud_scenario));
            x.Ci = x.cloudy; x.As = x.cloudy; x.Ac = x.cloudy;
            x.St = x.cloudy; x.Sc = x.cloudy; x.Cu = x.cloudy;
            x.Ns = x.cloudy; x.DC = x.cloudy;
            
            % -----------------------
            % extract clouds
            % -----------------------
            CS = sum(2.^(1:4)); %scenario mask
            Nprof = size(S.cloud_scenario,1);
            ph=mv*ones(1,10);%placeholder
            for i = 1:Nprof
                determined = bitand(typecast(S.cloud_scenario(i,:),'uint16'),2^0)==2^0;
                cloudScenario = bitand(typecast(S.cloud_scenario(i,:),'uint16'),CS);
                x.cloudy(i,:) = determined & cloudScenario > 0;
                x.Ci(i,:) = determined & cloudScenario == 2;
                x.As(i,:) = determined & cloudScenario == 2^2;
                x.Ac(i,:) = determined & cloudScenario == 2^1+2^2;
                x.St(i,:) = determined & cloudScenario == 2^3;
                x.Sc(i,:) = determined & cloudScenario == 2^1+2^3;
                x.Cu(i,:) = determined & cloudScenario == 2^2+2^3;
                x.Ns(i,:) = determined & cloudScenario == 2^1+2^2+2^3;
                x.DC(i,:) = determined & cloudScenario == 2^4;
                if strcmp(field,'Cloud_Types_multiLayer')
                    singleThings = (1:8).*(any([x.Ci(i,:);x.As(i,:);x.Ac(i,:);x.St(i,:);x.Sc(i,:);x.Cu(i,:);x.Ns(i,:);x.DC(i,:)],2))';
                    singleThings=singleThings(singleThings~=0); if isempty(singleThings), singleThings=0;end
                    S.Cloud_Types_multiLayer(i,:) = ph;
                    S.Cloud_Types_multiLayer(i,1:length(singleThings)) = singleThings;
                end

                
            end            
            % -------------------------
            % Make logical true if all
            % clouds in profile are the same type
            % ------------------------
            
            cloudfree = ~any(x.cloudy,2);
            cloudTypes = {'Ci','As','Ac','St','Sc','Cu','Ns','DC'};
            for i = 1:length(cloudTypes)
                CT = cloudTypes{i};
                % in profile: sum(cloudtype) = sum(cloudy vertical bins)
                singleType.(CT) = sum(x.(CT),2)==sum(x.cloudy,2);
                singleType.(CT)(cloudfree) = false;
            end
            
            % mixed clouds is where the profile is not cloudfree nor does it contain only one cloud type (=9)
            S.Cloud_Types = (length(cloudTypes)+1)*ones(size(singleType.Ci),'int8');
            for i = 1:length(cloudTypes)
                S.Cloud_Types(singleType.(cloudTypes{i})) = i;
            end
            S.Cloud_Types(cloudfree) = 0;
        case {'Cloud_Types_Lidar','Cloud_Types_Lidar_multiLayer'}
            
            % The main data
            clouds = S.CloudLayerType;
            
            % cloud types come from CloudLayerType, but the pseudo_field: Cloud_Types_Lidar is a
            % column integrated quantity. Initialize.
            if strcmp(field,'Cloud_Types_Lidar_multiLayer')
                S.(field)=ones(size(clouds),'int8')*mv;
                logtext(atmlab('OUT'),'Filtering cloudtypes according to quality and assigning CT=0 if cloud free\n')
            elseif strcmp(field,'Cloud_Types_Lidar')
                S.(field)=ones(size(clouds,1),1,'int8')*mv;
                logtext(atmlab('OUT'),'Assigning cloudtype to each profile\n')
            end
            
            % I need to loop over every point in order to use the index of the cloud
            % fraction and the clouds together
            
            for i = 1:size(clouds,1)
                
                % ---------------
                % Assign clouds
                if strcmp(field,'Cloud_Types_Lidar')
                    cloudColumn = clouds(i,clouds(i,:)~=0);
                    if isempty(cloudColumn)
                        % undetermined cloud type (is = 0 in the original [clear, or
                        % undetermined]). I set "clear" explicitly using the
                        % CloudFraction field
                        S.(field)(i) = 10;
                    elseif length(unique(cloudColumn))==1 % this only works since, if it is clear, all values are 0
                        % column with a single cloud type
                        S.(field)(i) = unique(cloudColumn);
                    else
                        % mixed cloud column
                        S.(field)(i) = 9;
                    end
                elseif strcmp(field,'Cloud_Types_Lidar_multiLayer')
                    S.(field)(i,:) = clouds(i,:);
                    S.(field)(i,clouds(i,:)==0)=10; % reassigning undetermined to 10. Will put zeros if CloudFraction says zero (see below)
                end
                
                
                % -------------------
                % MASK special cases
                % -------------------
                
                % ------------
                % Bad quality
                % Assign a missing value to a profile if any of the cloud boxes have CloudTypeQuality < 0.5
                bad = S.CloudTypeQuality(i,:)<.5;
                if strcmp(field,'Cloud_Types_Lidar')
                    if any(bad)
                        S.(field)(i) = mv;
                    end
                elseif strcmp(field,'Cloud_Types_Lidar_multiLayer')
                    S.(field)(i,bad) = mv;
                end
                
                % -----------------
                % Cloud Fraction
                % Use the lidar cloud fraction to find the truly CLOUD FREE
                % measurements (-99), and mask partly cloudy cloudsat
                % footprints/ volumes
                cloudy = S.CloudFraction(i,:);
                if strcmp(field,'Cloud_Types_Lidar')
                    if any(cloudy>0&cloudy<1)
                        % not used for single profile
                        S.(field)(i) = mv;
                    elseif all(cloudy==-99)
                        % cloud free
                        S.(field)(i) = 0;
                    end
                elseif strcmp(field,'Cloud_Types_Lidar_multiLayer')
                    S.(field)(i,cloudy>0&cloudy<1) = mv;
                    S.(field)(i,cloudy==-99)=0;
                end
                
                % ------------------
                % Final sweep for multi clouds
                % ------------------
                % only count clouds covering consecutive bins once.
                
                if strcmp(field,'Cloud_Types_Lidar_multiLayer')
                    singleThings = S.(field)(i,diff(S.(field)(i,:))~=0);
                    if isempty(singleThings) % if not every box has a cloud in it
                        singleThings = 0; % i.e, cloud free
                    end
                    S.(field)(i,:) = mv*ones(1,10); % put missing values as fillers
                    S.(field)(i,1:length(singleThings)) = singleThings;
                end
            end
        otherwise
            error(['atmlab:' mfilename],'field: "%s" is not listed here',field)
            
    end
end

end