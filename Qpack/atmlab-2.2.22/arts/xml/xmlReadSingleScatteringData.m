% Reads a SingleScatteringData table from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
%    Calls *xmlReadTag* for every member of the SingleScatteringData structure.
%
% FORMAT   result = xmlReadSingleScatteringData(fid, attrlist, itype, ftype, binary, fid2)
%
% OUT   result     SingleScatteringData
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
% IN    itype      Integer type of input file
% IN    ftype      Floating point type of input file
% IN    binary     Flag. 1 = binary file, 0 = ascii
% IN    fid2       File descriptor of binary file

% 2003-11-18   Created by Oliver Lemke.

function result = xmlReadSingleScatteringData(fid, attrlist, itype, ftype, binary, fid2)

  result.ptype            = xmlReadTag(fid, '', itype, ftype, binary, fid2);
  result.description      = xmlReadTag(fid, '', itype, ftype, binary, fid2);
  result.f_grid           = xmlReadTag(fid, '', itype, ftype, binary, fid2);
  result.T_grid           = xmlReadTag(fid, '', itype, ftype, binary, fid2);
  result.za_grid          = xmlReadTag(fid, '', itype, ftype, binary, fid2);
  result.aa_grid          = xmlReadTag(fid, '', itype, ftype, binary, fid2);
  result.pha_mat_data     = xmlReadTag(fid, '', itype, ftype, binary, fid2);
  result.ext_mat_data     = xmlReadTag(fid, '', itype, ftype, binary, fid2);
  result.abs_vec_data     = xmlReadTag(fid, '', itype, ftype, binary, fid2);

