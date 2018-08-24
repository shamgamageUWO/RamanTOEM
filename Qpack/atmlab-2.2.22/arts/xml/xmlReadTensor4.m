% Reads a Tensor4 from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
% FORMAT   result = xmlReadTensor4(fid, attrlist, itype, ftype, binary, fid2)
%
% OUT   result     Tensor4
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
% IN    itype      Integer type of input file
% IN    ftype      Floating point type of input file
% IN    binary     Flag. 1 = binary file, 0 = ascii
% IN    fid2       File descriptor of binary file

% 2002-10-18   Created by Oliver Lemke.

function result = xmlReadTensor4(fid, attrlist, itype, ftype, binary, fid2)

nb = str2num (xmlGetAttrValue (attrlist, 'nbooks'));
np = str2num (xmlGetAttrValue (attrlist, 'npages'));
nr = str2num (xmlGetAttrValue (attrlist, 'nrows'));
nc = str2num (xmlGetAttrValue (attrlist, 'ncols'));
nelem =  nb * np * nr * nc;

if ~binary
  result = fscanf (fid, '%f', nelem);
else
  result = fread (fid2, nelem, ftype);
end
xmlCheckSize (nelem, size (result));

result = permute (reshape (result, [nc nr np nb]), [4 3 2 1]);

