function A = flat(M)

% Small helper function to flatten an array without storing intermediate
%
% This is a tiny helper function that lets one flatten the result of an
% operation without needing to store the result in an intermediate
% variable.  It's normally used in the context of a
%
% EXAMPLE
%
%   answers{ii} = flat(self.overall_limitators{ii}(M_coll_part));

% $Id: flat.m 8343 2013-04-17 09:42:14Z gerrit $

A = M(:);

end
