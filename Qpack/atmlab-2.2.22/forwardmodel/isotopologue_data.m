% ISOTOPOLUGUE_DATA   Returns data for different isotopologues
%
%    Isotopologues are named following the ARTS scheme, such as O3-666
%    for standard ozone.
%
%    The following data fields are defined:
%       isofrac   Standard values for relative fraction of isotopologue.
%       weight    Molecular weight, such as 47.98... for standard ozone.
%       hitran    HITRAN number, with molecular isotopologue numbers joined
%                 (such as 11 for H2O-161). Present numbers are valid for
%                 HITRAN 2000.
%       jpl       JPL tag number(s). This could be a vector (when JPL 
%                 includes vibrational levels).
%
%    NaN is returned for missing data.
%
%    An example:  isotopologue_data( {'02-66','O3-666'}, 'isofrac' )
%
%    If no input argumnets are given, all data are returned. A field with
%    name *name* is then added with name of all defined isotopolugues.
%    A list of all isotopolugues is obtained from output as
%       data(:).name 
%
% FORMAT   data = isotopologue_data(isos,fields)
%        
% OUT   data   Extracted data. A struct array, with fields following *fields*.
% IN    isos   Name of isotopolugues for which data shall be extracted.
%              A cell string array, or a string for a single isotopologue.
%       fields Data fields to extract.
%              A cell string array, or a string for a single field.

% 2006-11-26   Created by Patrick Eriksson.


function data = isotopologue_data(isos,fields)

if nargin == 1  |  nargin > 2
  error( 'The function requires 0 or 2 input arguments.' );
end


%- Modification of input data
%
if nargin
  if ischar( isos )
    isos = { isos };
  end
  %
  if ischar( fields )
    fields = { fields };
  end
end



%-----------------------------------------------------------------------------
%
% Isotopologue data
%
% The data were copied from the ARTS-1.0 file species_data.cc 2006-11-26
% 
% Iso. names must here use '_' instead of '-' as Matlab will take '-' as a
% minus sign. This for seperator between molecule name and isotopologue
% number.
% The + in ions are here replaced by 'x'.
% All fields must be specified, for all isotopologues, to get nargin=0
% version to work.
%
%-----------------------------------------------------------------------------

%D..isofrac = ;     
%D..weight  = ;
%D..hitran  = ;
%D..jpl     = [   ];



%---
%--- BrO
%---
%  
D.BrO_96.isofrac   = 0.50582466;
D.BrO_96.weight    = 95;
D.BrO_96.hitran    = NaN;
D.BrO_96.jpl       = [ 95001 ];
%  
D.BrO_16.isofrac   = 0.49431069;
D.BrO_16.weight    = 97;
D.BrO_16.hitran    = NaN;
D.BrO_16.jpl       = [ 97001 ];



%---
%--- C2H2
%---
%  
D.C2H2_1221.isofrac   = .977599E+00;     
D.C2H2_1221.weight    = 26.015650;
D.C2H2_1221.hitran    = 261;
D.C2H2_1221.jpl       = [ NaN ];
%  
D.C2H2_1231.isofrac   = 2.19663E-02;     
D.C2H2_1231.weight    = 27.019005;
D.C2H2_1231.hitran    = 261;
D.C2H2_1231.jpl       = [ NaN ];



%---
%--- C2H4
%---
%  
D.C2H4_221.isofrac   = .977294E+00;     
D.C2H4_221.weight    = 28.031300;
D.C2H4_221.hitran    = 381;
D.C2H4_221.jpl       = [ NaN ];
%  
D.C2H4_231.isofrac   = .219595E-01;     
D.C2H4_231.weight    = 29.034655;
D.C2H4_231.hitran    = 382;
D.C2H4_231.jpl       = [ NaN ];



%---
%--- C2H6
%---
%  
D.C2H6_1221.isofrac   = .976990E+00;     
D.C2H6_1221.weight    = 30.046950;
D.C2H6_1221.hitran    = 271;
D.C2H6_1221.jpl       = [ NaN ];



%---
%--- CH3Cl
%---
%  
D.CH3Cl_215.isofrac   = .748937E+00;     
D.CH3Cl_215.weight    = 49.992328;
D.CH3Cl_215.hitran    = 241;
D.CH3Cl_215.jpl       = [ 50007 ];
%  
D.CH3Cl_217.isofrac   = .239491E+00;     
D.CH3Cl_217.weight    = 51.989379;
D.CH3Cl_217.hitran    = 242;
D.CH3Cl_217.jpl       = [ 52009 ];



%---
%--- CH3CN
%---
%  
D.CH3CN_211124.isofrac   = 0.97366840;
D.CH3CN_211124.weight    = 41;
D.CH3CN_211124.hitran    = NaN;
D.CH3CN_211124.jpl       = [ 41001 ];
%  
D.CH3CN_311124.isofrac   = 0.011091748;
D.CH3CN_311124.weight    = 42;
D.CH3CN_311124.hitran    = NaN;
D.CH3CN_311124.jpl       = [ 42006 ];
%  
D.CH3CN_211134.isofrac   = 0.011091748;
D.CH3CN_211134.weight    = 42;
D.CH3CN_211134.hitran    = NaN;
D.CH3CN_211134.jpl       = [ 42007 ];
%  
D.CH3CN_211125.isofrac   = 0.0036982817;
D.CH3CN_211125.weight    = 42;
D.CH3CN_211125.hitran    = NaN;
D.CH3CN_211125.jpl       = [ 42001 ];
%  
D.CH3CN_211224.isofrac   = 0.00044977985;
D.CH3CN_211224.weight    = 42;
D.CH3CN_211224.hitran    = NaN;
D.CH3CN_211224.jpl       = [ 42008 ];



%---
%--- CH4
%---
%  
D.CH4_211.isofrac   = .988274E+00;     
D.CH4_211.weight    = 16.031300;
D.CH4_211.hitran    = 61;
D.CH4_211.jpl       = [ NaN ];
%  
D.CH4_311.isofrac   = 1.11031E-02;     
D.CH4_311.weight    = 17.034655;
D.CH4_311.hitran    = 62;
D.CH4_311.jpl       = [ NaN ];
%  
D.CH4_212.isofrac   = 6.15751E-04;     
D.CH4_212.weight    = 17.037475;
D.CH4_212.hitran    = 63;
D.CH4_212.jpl       = [ 17003 ];


%---
%--- Cl2O2
%---
%  
D.Cl2O2_565.isofrac   = 0.57016427;     
D.Cl2O2_565.weight    = 102;
D.Cl2O2_565.hitran    = NaN;
D.Cl2O2_565.jpl       = [ 102001 ];
%  
D.Cl2O2_765.isofrac   = 0.36982818;     
D.Cl2O2_765.weight    = 104;
D.Cl2O2_765.hitran    = NaN;
D.Cl2O2_765.jpl       = [ 104001 ];



%---
%--- ClO
%---
%  
D.ClO_56.isofrac   = .755908E+00;     
D.ClO_56.weight    = 50.963768;
D.ClO_56.hitran    = 181;
D.ClO_56.jpl       = [ 51002, 51003 ];
%  
D.ClO_76.isofrac   = .241720E+00;     
D.ClO_76.weight    = 52.960819;
D.ClO_76.hitran    = 182;
D.ClO_76.jpl       = [ 53002, 53006 ];



%---
%--- ClONO2
%---
%  
D.ClONO2_5646.isofrac   = .749570E+00; 
D.ClONO2_5646.weight    = 96.956672;
D.ClONO2_5646.hitran    = 351;
D.ClONO2_5646.jpl       = [ 97002 ];
%  
D.ClONO2_7646.isofrac   = .239694E+00;     
D.ClONO2_7646.weight    = 98.953723;
D.ClONO2_7646.hitran    = 352;
D.ClONO2_7646.jpl       = [ 99001 ];


         
%---
%--- CO
%---
%  
D.CO_26.isofrac   = .986544E+00;     
D.CO_26.weight    = 27.994915;
D.CO_26.hitran    = 51;
D.CO_26.jpl       = [ 28001 ];
%  
D.CO_36.isofrac   = 1.10836E-02;     
D.CO_36.weight    = 28.998270;
D.CO_36.hitran    = 52;
D.CO_36.jpl       = [ 29001 ];
%  
D.CO_28.isofrac   = 1.97822E-03;     
D.CO_28.weight    = 29.999161;
D.CO_28.hitran    = 53;
D.CO_28.jpl       = [ 30001 ];
%  
D.CO_27.isofrac   = 3.67867E-04;     
D.CO_27.weight    = 28.999130;
D.CO_27.hitran    = 54;
D.CO_27.jpl       = [ 29006 ];
%  
D.CO_38.isofrac   = 2.22250E-05;     
D.CO_38.weight    = 31.002516;
D.CO_38.hitran    = 55;
D.CO_38.jpl       = [ NaN ];
%  
D.CO_37.isofrac   = 4.13292E-06;     
D.CO_37.weight    = 30.002485;
D.CO_37.hitran    = 56;
D.CO_37.jpl       = [ NaN ];



%---
%--- CO2
%---
%  
D.CO2_626.isofrac = 0.984204;     
D.CO2_626.weight  = 43.989830;
D.CO2_626.hitran  = 21;
D.CO2_626.jpl     = [ NaN ];
%  
D.CO2_636.isofrac = 1.10574E-02;     
D.CO2_636.weight  = 44.993185;
D.CO2_636.hitran  = 22;
D.CO2_636.jpl     = [ NaN ];
%  
D.CO2_628.isofrac = 3.94707E-03;     
D.CO2_628.weight  = 45.994076;
D.CO2_628.hitran  = 23;
D.CO2_628.jpl     = [ 46013 ];
%  
D.CO2_627.isofrac = 7.33989E-04;     
D.CO2_627.weight  = 44.994045;
D.CO2_627.hitran  = 24;
D.CO2_627.jpl     = [ 45012 ];
%  
D.CO2_638.isofrac = 4.43446E-05;     
D.CO2_638.weight  = 46.997431;
D.CO2_638.hitran  = 25;
D.CO2_638.jpl     = [ NaN ];
%  
D.CO2_637.isofrac = 8.24623E-06;     
D.CO2_637.weight  = 45.997400;
D.CO2_637.hitran  = 26;
D.CO2_637.jpl     = [ NaN ];
%  
D.CO2_828.isofrac = 3.95734E-06;     
D.CO2_828.weight  = 47.998322;
D.CO2_828.hitran  = 27;
D.CO2_828.jpl     = [ NaN ];
%  
D.CO2_728.isofrac = 1.47180E-06;     
D.CO2_728.weight  = 46.998291;
D.CO2_728.hitran  = 28;
D.CO2_728.jpl     = [ NaN ];



%---
%--- COF2
%---
%  
D.COF2_269.isofrac = .986544E+00;     
D.COF2_269.weight  = 65.991722;
D.COF2_269.hitran  = 291;
D.COF2_269.jpl     = [ 66001 ];



%---
%--- H2CO
%---
%  
D.H2CO_1126.isofrac = .986237E+00;     
D.H2CO_1126.weight  = 30.010565;
D.H2CO_1126.hitran  = 201;
D.H2CO_1126.jpl     = [ 30004 ];
%  
D.H2CO_1136.isofrac = 1.10802E-02;     
D.H2CO_1136.weight  = 31.013920;
D.H2CO_1136.hitran  = 202;
D.H2CO_1136.jpl     = [ 31002 ];
%  
D.H2CO_1128.isofrac = 1.97761E-03;     
D.H2CO_1128.weight  = 32.014811;
D.H2CO_1128.hitran  = 203;
D.H2CO_1128.jpl     = [ 32004 ];
%  
D.H2CO_1226.isofrac = 0.00029578940;     
D.H2CO_1226.weight  = 31;
D.H2CO_1226.hitran  = NaN;
D.H2CO_1226.jpl     = [ 31003 ];
%  
D.H2CO_2226.isofrac = 2.2181076E-08;     
D.H2CO_2226.weight  = 32;
D.H2CO_2226.hitran  = NaN;
D.H2CO_2226.jpl     = [ 32006 ];



%---
%--- H2O
%---
%  
D.H2O_161.isofrac = 0.99731702;     
D.H2O_161.weight  = 18.010565;
D.H2O_161.hitran  = 11;
D.H2O_161.jpl     = [ 18003, 18005 ];
%
D.H2O_181.isofrac = 0.00199983;     
D.H2O_181.weight  = 20.014811;
D.H2O_181.hitran  = 12;
D.H2O_181.jpl     = [ 20003 ];
%
D.H2O_171.isofrac = 0.00037200;     
D.H2O_171.weight  = 19.014780;
D.H2O_171.hitran  = 13;
D.H2O_171.jpl     = [ 19003 ];
%
D.H2O_162.isofrac = 0.000310693; 
D.H2O_162.weight  = 19.016740;     
D.H2O_162.hitran  = 14;
D.H2O_162.jpl     = [ 19002 ];
%
D.H2O_182.isofrac = 6.23003E-07; 
D.H2O_182.weight  = 21.020985;     
D.H2O_182.hitran  = 15;
D.H2O_182.jpl     = [ 21001 ];
%
D.H2O_172.isofrac = 1.15853E-07;     
D.H2O_172.weight  = 20.020956;
D.H2O_172.hitran  = 16;
D.H2O_172.jpl     = [ NaN ];
%
D.H2O_262.isofrac = 2.2430204E-08;     
D.H2O_262.weight  = 20;
D.H2O_262.hitran  = NaN;
D.H2O_262.jpl     = [ 20001 ];



%---
%--- H2O2
%---
%  
D.H2O2_1661.isofrac = .994952E+00;
D.H2O2_1661.weight  = 34.005480;
D.H2O2_1661.hitran  = 251;
D.H2O2_1661.jpl     = [ 34004 ];



%---
%--- H2S
%---
%  
D.H2S_121.isofrac = .949884E+00;
D.H2S_121.weight  = 33.987721;
D.H2S_121.hitran  = 311;
D.H2S_121.jpl     = [ 34002 ];
%  
D.H2S_141.isofrac = 4.21369E-02;
D.H2S_141.weight  = 35.983515;
D.H2S_141.hitran  = 312;
D.H2S_141.jpl     = [ NaN ];
%  
D.H2S_131.isofrac = 7.49766E-03;
D.H2S_131.weight  = 34.987105;
D.H2S_131.hitran  = 313;
D.H2S_131.jpl     = [ NaN ];
%  
D.H2S_122.isofrac = 0.00029991625;
D.H2S_122.weight  = 35;
D.H2S_122.hitran  = NaN;
D.H2S_122.jpl     = [ 35001 ];



%---
%--- H2SO4
%---
%  
D.H2SO4_126.isofrac = 0.95060479;
D.H2SO4_126.weight  = 98;
D.H2SO4_126.hitran  = NaN;
D.H2SO4_126.jpl     = [ 98001 ];



%---
%--- HBr
%---
%  
D.HBr_19.isofrac = 0.506781;
D.HBr_19.weight  = 79.926160;
D.HBr_19.hitran  = 161;
D.HBr_19.jpl     = [ 80001 ];
%  
D.HBr_11.isofrac = 0.493063;
D.HBr_11.weight  = 81.924115;
D.HBr_11.hitran  = 162;
D.HBr_11.jpl     = [ 82001 ];



%---
%--- HCl
%---
%  
D.HCl_15.isofrac = 0.757587;
D.HCl_15.weight  = 35.976678;
D.HCl_15.hitran  = 151;
D.HCl_15.jpl     = [ 36001 ];
%  
D.HCl_17.isofrac = 0.242257;
D.HCl_17.weight  = 37.973729;
D.HCl_17.hitran  = 152;
D.HCl_17.jpl     = [ 38001 ];
%  
D.HCl_25.isofrac = 0.00011324004;
D.HCl_25.weight  = 37;
D.HCl_25.hitran  = NaN;
D.HCl_25.jpl     = [ 37001 ];
%  
D.HCl_27.isofrac = 3.6728230E-05;
D.HCl_27.weight  = 39;
D.HCl_27.hitran  = NaN;
D.HCl_27.jpl     = [ 39004 ];



%---
%--- HCN
%---
%  
D.HCN_124.isofrac = .985114E+00;
D.HCN_124.weight  = 27.010899;
D.HCN_124.hitran  = 231;
D.HCN_124.jpl     = [ 27001, 27003 ];
%  
D.HCN_134.isofrac = 1.10676E-02;
D.HCN_134.weight  = 28.014254;
D.HCN_134.hitran  = 232;
D.HCN_134.jpl     = [ 28002 ];
%  
D.HCN_125.isofrac = 3.62174E-03;
D.HCN_125.weight  = 28.007933;
D.HCN_125.hitran  = 233;
D.HCN_125.jpl     = [ 28003 ];
%  
D.HCN_224.isofrac = 0.00014773545;
D.HCN_224.weight  = 28;
D.HCN_224.hitran  = NaN;
D.HCN_224.jpl     = [ 28004 ];



%---
%--- HCOOH
%---
%  
D.HCOOH_1261.isofrac = 0.983898E+00;
D.HCOOH_1261.weight  = 46.005480;
D.HCOOH_1261.hitran  = 321;
D.HCOOH_1261.jpl     = [ 46005 ];
%  
D.HCOOH_1361.isofrac = 0.010913149;
D.HCOOH_1361.weight  = 47;
D.HCOOH_1361.hitran  = NaN;
D.HCOOH_1361.jpl     = [ 47002 ];
%  
D.HCOOH_2261.isofrac = 0.00014755369;
D.HCOOH_2261.weight  = 47;
D.HCOOH_2261.hitran  = NaN;
D.HCOOH_2261.jpl     = [ 47003 ];
%  
D.HCOOH_1262.isofrac = 0.00014755369;
D.HCOOH_1262.weight  = 47;
D.HCOOH_1262.hitran  = NaN;
D.HCOOH_1262.jpl     = [ 47004 ];



%---
%--- HF
%---
%  
D.HF_19.isofrac = 0.99984425;
D.HF_19.weight  = 20.006229;
D.HF_19.hitran  = 141;
D.HF_19.jpl     = [ 20001 ];
%  
D.HF_29.isofrac = 0.00014994513;
D.HF_29.weight  = 21;
D.HF_29.hitran  = NaN;
D.HF_29.jpl     = [ 21001 ];



%---
%--- HI
%---
%  
D.HI_17.isofrac = 0.99984425;
D.HI_17.weight  = 127.912297;
D.HI_17.hitran  = 171;
D.HI_17.jpl     = [ NaN ];



%---
%--- HNC
%---
%  
D.HNC_142.isofrac = 0.98505998;
D.HNC_142.weight  = 27;
D.HNC_142.hitran  = NaN;
D.HNC_142.jpl     = [ 27002 ];
%  
D.HNC_143.isofrac = 0.011091748;
D.HNC_143.weight  = 28;
D.HNC_143.hitran  = NaN;
D.HNC_143.jpl     = [ 28005 ];
%  
D.HNC_152.isofrac = 0.0036982817;
D.HNC_152.weight  = 28;
D.HNC_152.hitran  = NaN;
D.HNC_152.jpl     = [ 28006 ];
%  
D.HNC_242.isofrac = 0.00014996849;
D.HNC_242.weight  = 28;
D.HNC_242.hitran  = NaN;
D.HNC_242.jpl     = [ 28007 ];



%---
%--- HNO3
%---
%  
D.HNO3_146.isofrac = 0.989110;
D.HNO3_146.weight  = 62.995644;
D.HNO3_146.hitran  = 121;
D.HNO3_146.jpl     = [ 63001, 63002, 63003, 63004, 63005, 63006 ];



%---
%--- HO2
%---
%  
D.HO2_166.isofrac = 0.995107;
D.HO2_166.weight  = 32.997655;
D.HO2_166.hitran  = 331;
D.HO2_166.jpl     = [ 33001 ];



%---
%--- HOBr
%---
%  
D.HOBr_169.isofrac = .505579E+00;
D.HOBr_169.weight  = 95.921076;
D.HOBr_169.hitran  = 371;
D.HOBr_169.jpl     = [ 96001 ];
%  
D.HOBr_169.isofrac = .491894E+00;
D.HOBr_169.weight  = 97.919027;
D.HOBr_169.hitran  = 372;
D.HOBr_169.jpl     = [ 98001 ];



%---
%--- HOCl
%---
%  
D.HOCl_165.isofrac = .755790E+00;
D.HOCl_165.weight  = 51.971593;
D.HOCl_165.hitran  = 211;
D.HOCl_165.jpl     = [ 52006 ];
%  
D.HOCl_167.isofrac = .241683E+00;
D.HOCl_167.weight  = 53.968644;
D.HOCl_167.hitran  = 212;
D.HOCl_167.jpl     = [ 54005 ];



%---
%--- N2
%---
%  
D.N2_44.isofrac = 0.9926874;
D.N2_44.weight  = 28.006147;
D.N2_44.hitran  = 221;
D.N2_44.jpl     = [ NaN ];



%---
%--- N2O
%---
%  
D.N2O_446.isofrac = .990333E+00;
D.N2O_446.weight  = 44.001062;
D.N2O_446.hitran  = 41;
D.N2O_446.jpl     = [ 44004, 44009, 44012 ];
%  
D.N2O_456.isofrac = 3.64093E-03;
D.N2O_456.weight  = 44.998096;
D.N2O_456.hitran  = 42;
D.N2O_456.jpl     = [ 45007 ];
%  
D.N2O_546.isofrac = 3.64093E-03;
D.N2O_546.weight  = 44.998096;
D.N2O_546.hitran  = 43;
D.N2O_546.jpl     = [ 45008 ];
%  
D.N2O_448.isofrac = 1.98582E-03;
D.N2O_448.weight  = 46.005308;
D.N2O_448.hitran  = 44;
D.N2O_448.jpl     = [ 46007 ];
%  
D.N2O_447.isofrac = 3.69280E-04;
D.N2O_447.weight  = 45.005278;
D.N2O_447.hitran  = 45;
D.N2O_447.jpl     = [ NaN ];



%---
%--- NH3
%---
%  
D.NH3_4111.isofrac   = .9958715E+00;
D.NH3_4111.weight    = 17.026549;
D.NH3_4111.hitran    = 111;
D.NH3_4111.jpl       = [ 17002, 17004 ];
%  
D.NH3_5111.isofrac   = 3.66129E-03;
D.NH3_5111.weight    = 18.023583;
D.NH3_5111.hitran    = 112;
D.NH3_5111.jpl       = [ 18002 ];
%  
D.NH3_4112.isofrac   = 0.00044792294;
D.NH3_4112.weight    = 18;
D.NH3_4112.hitran    = NaN;
D.NH3_4112.jpl       = [ 18004 ];



%---
%--- NO
%---
%  
D.NO_46.isofrac   = .993974E+00;
D.NO_46.weight    = 29.997989;
D.NO_46.hitran    = 81;
D.NO_46.jpl       = [ 30008 ];
%  
D.NO_56.isofrac   = 3.65431E-03;
D.NO_56.weight    = 30.995023;
D.NO_56.hitran    = 82;
D.NO_56.jpl       = [ NaN ];
%  
D.NO_48.isofrac   = 1.99312E-03;
D.NO_48.weight    = 32.002234;
D.NO_48.hitran    = 83;
D.NO_48.jpl       = [ NaN ];



%---
%--- NO+
%---
%  
D.NOx_46.isofrac   = .993974E+00;
D.NOx_46.weight    = 29.997989;
D.NOx_46.hitran    = 361;
D.NOx_46.jpl       = [ 30011 ];

         
%---
%--- NO2
%---
%  
D.NO2_646.isofrac   = .991616E+00;
D.NO2_646.weight    = 45.992904;
D.NO2_646.hitran    = 101;
D.NO2_646.jpl       = [ 46006 ];



%---
%--- O
%---
%  
D.O_6.isofrac   = 0.997628;
D.O_6.weight    = 15.994915;
D.O_6.hitran    = 341;
D.O_6.jpl       = [ 16001 ];



%---
%--- O2
%---
%  
D.O2_66.isofrac   = .995262E+00;
D.O2_66.weight    = 31.989830;
D.O2_66.hitran    = 71;
D.O2_66.jpl       = [ 32001, 32002 ];
%  
D.O2_68.isofrac   = 3.99141E-03;
D.O2_68.weight    = 33.994076;
D.O2_68.hitran    = 72;
D.O2_68.jpl       = [ 34001 ];
%  
D.O2_67.isofrac   = 7.42235E-04;
D.O2_67.weight    = 32.994045;
D.O2_67.hitran    = 73;
D.O2_67.jpl       = [ 330002 ];



%---
%--- O3
%---
%  
D.O3_666.isofrac = .992901E+00;     
D.O3_666.weight  = 47.984745;
D.O3_666.hitran  = 31;
D.O3_666.jpl     = [ 48004, 48005, 48006, 48007, 48008 ];
%  
D.O3_668.isofrac = 3.98194E-03;     
D.O3_668.weight  = 49.988991;
D.O3_668.hitran  = 32;
D.O3_668.jpl     = [ 50004, 50006 ];
%  
D.O3_686.isofrac = 1.99097E-03;     
D.O3_686.weight  = 49.988991;
D.O3_686.hitran  = 33;
D.O3_686.jpl     = [ 50003, 50005 ];
%  
D.O3_667.isofrac = 7.40475E-04;     
D.O3_667.weight  = 48.988960;
D.O3_667.hitran  = 34;
D.O3_667.jpl     = [ 49002 ];
%  
D.O3_676.isofrac = 3.70237E-04;     
D.O3_676.weight  = 48.988960;
D.O3_676.hitran  = 35;
D.O3_676.jpl     = [ 49001 ];



%---
%--- OClO
%---
%
D.OClO_656.isofrac   = 0.75509223;
D.OClO_656.weight    = 67;
D.OClO_656.hitran    = NaN;
D.OClO_656.jpl       = [ 67001 ];
%
D.OClO_656.isofrac   = 0.24490632;
D.OClO_656.weight    = 69;
D.OClO_656.hitran    = NaN;
D.OClO_656.jpl       = [ 69001 ];



%---
%--- OCS
%---
%
% OCS-623 introduced in Hitran 2000, with an iso. number already used for 822
%
D.OCS_622.isofrac   = .937395E+00;
D.OCS_622.weight    = 59.966986;
D.OCS_622.hitran    = 191;
D.OCS_622.jpl       = [ 60001 ];
%  
D.OCS_624.isofrac   = 4.15828E-02;
D.OCS_624.weight    = 61.962780;
D.OCS_624.hitran    = 192;
D.OCS_624.jpl       = [ 62001 ];
%  
D.OCS_632.isofrac   = 1.05315E-02;
D.OCS_632.weight    = 60.970341;
D.OCS_632.hitran    = 193;
D.OCS_632.jpl       = [ 61001 ];
%  
D.OCS_623.isofrac   = 7.39908E-03;
D.OCS_623.weight    = 60.966371;
D.OCS_623.hitran    = 194;
D.OCS_623.jpl       = [ NaN ];
%  
D.OCS_822.isofrac   = 1.87967E-03;
D.OCS_822.weight    = 61.971231;
D.OCS_822.hitran    = 195;
D.OCS_822.jpl       = [ 62002 ];



%---
%--- OH
%---
%  
D.OH_61.isofrac   = .997473E+00;
D.OH_61.weight    = 17.002740;
D.OH_61.hitran    = 131;
D.OH_61.jpl       = [ 17001 ];
%  
D.OH_81.isofrac   = 2.00014E-03;
D.OH_81.weight    = 19.006986;
D.OH_81.hitran    = 132;
D.OH_81.jpl       = [ 19001 ];
%  
D.OH_62.isofrac   = 1.55371E-04;
D.OH_62.weight    = 18.008915;
D.OH_62.hitran    = 133;
D.OH_62.jpl       = [ 18001 ];



%---
%--- PH3
%---
%  
D.PH3_1111.isofrac   = 0.99953283;
D.PH3_1111.weight    = 33.997238;
D.PH3_1111.hitran    = 281;
D.PH3_1111.jpl       = [ 34003 ];



%---
%--- SF6
%---
%  
D.SF6_29.isofrac   = 0.95018;
D.SF6_29.weight    = 145.962492;
D.SF6_29.hitran    = 301;
D.SF6_29.jpl       = [ NaN ];



%---
%--- SO2
%---
%  
D.SO2_626.isofrac = .945678E+00;     
D.SO2_626.weight  = 63.961901;
D.SO2_626.hitran  = 91;
D.SO2_626.jpl     = [ 64002, 64005 ];
%  
D.SO2_646.isofrac = 4.19503E-02;     
D.SO2_646.weight  = 65.957695;
D.SO2_646.hitran  = 92;
D.SO2_646.jpl     = [ 66002 ];
%  
D.SO2_636.isofrac = 0.0074989421;     
D.SO2_636.weight  = 65;
D.SO2_636.hitran  = 93;
D.SO2_636.jpl     = [ 65001 ];
%  
D.SO2_628.isofrac = 0.0020417379;     
D.SO2_628.weight  = 66;
D.SO2_628.hitran  = 94;
D.SO2_628.jpl     = [ 66004 ];




%-----------------------------------------------------------------------------
%
% Extarct selected data 
%
%-----------------------------------------------------------------------------


data = [];


if nargin == 0
  %
  f = fieldnames( D );
  %
  data(1).isofrac = NaN;
  data(1).weight  = NaN;
  data(1).hitran  = NaN;
  data(1).jpl     = NaN;
  data(1).name    = NaN;
  %
  for i = 1:length(f)
    s             = f{i};
    ind           = find( s == '_' );
    s(ind)        = '-';
    ind           = find( s == 'x' );
    s(ind)        = '+';
    D.(f{i}).name = s;
    data(i)       = D.(f{i});
  end
  return
end


for i = 1 : length( isos )

  s      = isos{i};
  ind    = find( s == '-' );
  s(ind) = '_';
  ind    = find( s == '+' );
  s(ind) = 'x';
  
  if ~isfield( D, s )
    error( sprintf('No data defined for %s.',isos{i}) );
  end
    
  d = getfield( D, s );
  
  for f = 1 : length( fields )

    if ~isfield( d, fields{f} )
      error( sprintf( 'Field *%s* not defined for %s.', fields{f}, isos{i} ) );
    end
    
    data(i).(fields{f}) = getfield( d, fields{f} );
    
  end
end







