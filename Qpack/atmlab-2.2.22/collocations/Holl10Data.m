classdef Holl10Data < AssociatedDataset
    % CPR-MHS collocations (1 per CPR) for Holl et. al, 2010
    %
    % WORK IN PROGRESS!
    %
    % $Id: Holl10Data.m 7520 2012-04-17 15:48:20Z gerrit $
    
    properties (SetAccess = protected)

         members = struct(...
            'ROIWP', struct(...
                'type', 'float', ...
                'atts', struct(...
                    'long_name', 'CloudSat Radar-Only CPR IWP', ...
                    'units', 'g/m^2')), ...
            'dROIWP', struct(...
                'type', 'float', ...
                'atts', struct(...
                    'long_name', 'Cloudsat Radar-Only CPR IWP uncertainty', ...
                    'units', 'g/m^2')), ...
            'IOROIWP', struct(...
                'type', 'float', ...
                'atts', struct(...
                    'long_name', 'Cloudsat Ice-Only Radar-Only CPR IWP', ...
                    'units', 'g/m^2')), ...
            'dIOROIWP', struct(...
                'type', 'float', ...
                'atts', struct(...
                    'long_name', 'Cloudsat Ice-Only Radar-Only CPR IWP uncertainty', ...
                    'units', 'g/m^2')), ...
            'MHS', struct(...
              'type', 'float', ...
              'dims', {{'MHS_CHANS', 5}}, ...
              'atts', struct(...
                  'long_name', 'MHS brightness temperature', ...
                  'units', 'Kelvin')));
        
         parent = datasets_config('collocation_cpr_mhs');      
         dependencies = {};
     end
     
     methods
         function self = Holl10Data(varargin)
             self = self@AssociatedDataset(...
                 varargin{:});
         end
     end
     
     methods (Static)
         
         
         function args = primary_arguments()
             args = {'RO_ice_water_path'; ...
                 'RO_ice_water_path_uncertainty'; ...
                 'IO_RO_ice_water_path'; ...
                 'IO_RO_ice_water_path_uncertainty'};
         end
         
         function args = secondary_arguments()
             args = {};
         end
         
         function bool = needs_primary_data()
             bool = true;
         end
         
         function bool = needs_secondary_data()
             bool = true;
         end
         
     end
     
     methods
         
         function M = process_granule(self, processed_core, data_cpr, ~, ~, data_mhs, ~, ~, ~)
             % process_granule FIXME DOC
             %
             % WORK IN PROGRESS
             %
             % FIXME DOC
             
             self.members2cols(); % only here, because in some cases it happens after reading data
             % prepare
             n_collocs = size(processed_core, 1);
             n_fields = max(cell2mat(struct2cell(self.cols).'));
             M = nan*zeros(n_collocs, n_fields);
             if n_collocs==0
                 return % don't bother
             end
                          
             % row and columns           
             cpr_i = processed_core(:, self.parent.cols.LINE1);
             mhs_r = processed_core(:, self.parent.cols.LINE2);
             mhs_c = processed_core(:, self.parent.cols.POS2);
             
             %% cloudsat data
             
             M(:, self.cols.ROIWP) = data_cpr.RO_ice_water_path(cpr_i);
             M(:, self.cols.dROIWP) = data_cpr.RO_ice_water_path_uncertainty(cpr_i);
             M(:, self.cols.IOROIWP) = data_cpr.IO_RO_ice_water_path(cpr_i);
             M(:, self.cols.dIOROIWP) = data_cpr.IO_RO_ice_water_path_uncertainty(cpr_i);
             
             %% AMSUB/MHS data
             
             % index for direct addressing
             mhs_i = sub2ind(size(data_mhs.lat), mhs_r, mhs_c);
             
             % reshape so that I can use direct addressing for brightness temperatures
             tb = reshape(data_mhs.tb, [numel(data_mhs.lat) 5]);
             
             M(:, self.cols.MHS) = tb(mhs_i, :);
             
         end  

     end
end
