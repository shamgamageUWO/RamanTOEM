%  SPAREICE   Functions related to SPAREICE retrievals
%
% Please note that, contrary to the rest of Atmlab, the functionality in
% this sub-toolbox relies on two toolboxes that require additional
% licenses to the Matlab core:
%
%   - Neural Network Toolbox.  Cannot currently be evaded, although it
%   should be possible to implement the resulting regression directly.
%
%   - Parallel Computing Toolbox.  Can be evaded with a small adaptation,
%   but that will make it much slower on multi-core machines.
%
% The functionality in this directory is not up to the same standards as
% the rest of Atmlab.  It is research code for Gerrits PhD project and it
% was not designed with multi-user interfaces in mind.  I (Gerrit) added
% it to Atmlab after my PhD, when I did not have the time for the cleanup
% needed.  Please use with care and I hope you can find what you need
% despite the messy situation.
%
% To perform SPARE-ICE retrievals, you will need:
%
%   - The trained neural net, available in:
%
%   /storage3/user_data/gerrit/neuralnets/avhrr_345_mhs_345_angles_tsurfcfsr_all_global_MEAN_AVHRR_Y,3,4,5,B_BT,3,4,5,B_LZA,B_LAA,B_SZA,B_SAA,CFSR_Skin_temperature,_to_MEAN_IWP_2C,_noise0.00,_v0.7_1.mat
%
%   - Data for AVHRR and MHS, should be at /storage3/data/avhrr and
%   /storage3/data/mhs, respectively
%
%   - CFSR data, downloaded from http://rda.ucar.edu/.  Version  (ds093.1)
%   is until March 2011, then it's (ds094.1).  Please see citation
%   information at http://rda.ucar.edu/datasets/ds093.1/ and
%   http://rda.ucar.edu/datasets/ds094.1/.  For the SPARE-ICE version, you
%   will need skin temperature.  Note that skin temperature is actually
%   included with the temperature profile!  So you should download the
%   temperature field, then choose "ground level" on the next page.  You
%   want "type of product" "all available" because the actual reanalysis
%   is only every 6 hours and SPARE-ICE retrieval needs hourly data
%   (reduces interpolation).  Choose the densest grid with all available
%   data.  Do not forget to set "Output format" to "Converted to NetCDF".
%
%   I downloaded the 'pure' reanalysis data to
%   /storage3/user_data/gerrit/reanalysis
%
%   - The Python script to convert this to daily netcdf files to be used
%   with the atmlab retrieval.  Resulting daily files at
%   /storage3/user_data/gerrit/reanalysis_per_day but change source code
%   as needed, in particular 'indir', 'infile', 'outdir', 'outfile',
%   defined near the top of the source code.  Note that this is Python3
%   code.
%
%   - The atmlab files in this directory.
%
% To process SPARE-ICE data, call process_ccniwp_data, for example:
%
%   process_ccniwp_data([2013, 4, 2], [2013, 5, 30], 'noaa18');
%
% To read SPARE-ICE data:
%
%   define_local_datasets();
%   D = datasets();
%   D.col_syn_iwp.read_...  (see SatDataset and SatDataset.read for details)
