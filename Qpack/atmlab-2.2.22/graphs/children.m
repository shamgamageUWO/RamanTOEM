% CHILDREN   Returns the children of all figure objects.
%
%    The function returns the children of all generations, or only the closest
%    generation, of a figure or figure objects. To get a handle to all
%    objects of a figure, type
%       hc = children( gcf );
%
%    The input argument *h* can be a vector of handles. No object in *h*
%    can be children (in any generation) of any other object in *h*. If this
%    is the case, some handles will be duplicated in *hc*.
%
%    This function returns more handles than the Matlab function *allchild*.
%    (I am not totally sure how that function is defined.)
%
% FORMAT   hc = children(h,all_generations)
%        
% OUT   hc                Handle to children.
% IN    h                 Handle to bject(s) for which children shall be 
%                         returned.
% OPT   all_generations   If set to 0, only the first generation is returned.
%                         Otherwise handles for all generations are returned.
%                         Default is 1.

% 2002-12-12   Created by Patrick Eriksson.


function hc = children(h,all_generations)


%=== Defaults
%
if nargin < 2
  all_generations = 1;
end


%=== Allocate space for 100 children (if they happen to be more, that is OK)
%
hc = zeros(100,1);


%=== Read children of input handles
%
ntot = 0;
%
for ih = 1 : length( h )
  %
  hl = get( h(ih), 'children' );
  n  = length( hl );
  %
  if n
    hc(ntot+(1:n)) = hl;
    ntot           = ntot +n;    
  end
  %
end


%=== Remove empty part 
%
hc = hc(1:ntot);


%=== Read younger generations by recursive call
%
if all_generations
  %
  hc = [ hc; children( hc, 0 ) ];
  %
end