% GFORMAT: A standardised format for handling gridded data.
%
%   The gformat can be seen as a class for gridded data (but implemented in
%   a functional way). The format is based on a structure. A minimal
%   structure for a dimension of dim is obtained by
%      G = gf_empty( dim );
%
%   The mandatory fields are
%
%    TYPE       : Type of data. Derived "classes" can use this field to flag
%                 the type/class. Set to 'basic' by gf_empty.
%    NAME       : Overall name of data, e.g. 'CIRA86 temparature'
%    SOURCE     : Source of data, such as the name of a file.
%    DIM        : Dimensionality of data. That is, highest possible
%                 dimension of data.
%    DATA       : The data (dim1,dim2,...,DIM).
%    DATA_NAME  : Name of data, such as 'Temperature'.
%    DATA_UNIT  : Unit of data, such as 'K'.
%
%   If DIM >= 1, fields describing the grids are mandatory:
%
%    GRID1      : Grid for data dimension 1.
%    GRID1_NAME : Description of data dimension 1, such as 'Pressure'.
%    GRID1_UNIT : Unit for data dimension 1, such as 'Pa'.
%    
%   And so on up to the dimension specified by *DIM*.
%
%   It is further allowed to add other fields. These fields can be used for
%   input to specific functions using gformat arrays as input. A consequency is
%   that data with different DIM can be mixed in an array of G. Some gformat
%   functions are vectorised, allowing G to be a vector (but not a matrix), and
%   should handle the case of a varying DIM.
%  
%   All interpolation is made as using *gridinterp* with its optional argument
%   *extrap* set to true. That is, the data are assumed to be defined
%   everywhere (end values valid all the way to +-INF). This is also valid for
%   singleton dimensions. The grid for empty/singleton dimensions can be empty
%   or a scalar.
%
%   Definitions of derived types are described in the associated
%   is-function, such as isatmdata for the atmdata type.