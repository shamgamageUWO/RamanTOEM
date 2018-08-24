% GMTLAB   Handling of GMTLAB settings.
%
%   This function is based on *prstnt_struct* and for general help see 
%   the on-line help for that function. 
%
%   Existing fields, and possible settings, are listed below. 
%
%   For adding personal settings at startup, see the file CONFIGURE. To 
%   add or change settings after startup, follow the example below. 
%
%   To check all present settings
%      gmtlab;
%
%   A specific setting is obtained as
%      value = GMTLAB( 'PDFVIEWER' );
%
%   To set a field to a specic value
%      GMTLAB( 'PDFVIEWER', 'xpdf' );
%
%   To set all fields to default
%      GMTLAB( 'defaults' );
%
% FORMAT   value = gmtlab( [varargin] )
%        
% OUT   value      Setting, if a field is selected. See further 
%                  *prstnt_struct*.
% OPT   varargin   Field, field and setting or any option supported by
%                  *prstnt_struct*.
%
%----------------------------------------------------------------------------
% OPEN_COMMAND  
%
% General command to open files with. e.g. gmtlab('OPEN_COMMAND','gnome-open') 
% ---------------------------------------------------------------------------
% OUTDIR
%
% Directory to output files from created by gmtlab
% ---------------------------------------------------------------------------
% PDFVIEWER
%
% Command to view PDF files.
%----------------------------------------------------------------------------
% PSVIEWER
%
% Command to view PS or EPS files.
%----------------------------------------------------------------------------
%
% VERBOSITY
% 
% The verbosity of Atmlab (gmtlab) functions.  
% Functions writing to the screen set a report level for each output. If the
% the set report level is higher than VERBOSITY, the output is ignored.
% Output obeying this setting is most easily produced with the function *out*.
% Functions can also use VERBOSITY to decide if figures shall be produced
% (which is most easily checked by using *out*).
%----------------------------------------------------------------------------
%
% Created by Salomon Eliasson based entirely on atmlab.m by Patrick Eriksson.
% $Id: gmtlab.m 6920 2011-05-06 12:10:24Z olemke $

function value = gmtlab( varargin )
            
persistent B

if ~isempty(varargin) && iscell(varargin{1})
    [B,value] = gmt_prstnt_struct( B, @gmtlab_defs, varargin{:} );
else
    [B,value] = gmt_prstnt_struct( B, @gmtlab_defs, varargin );
end

%%%%%%%%%%%%%%%%
% SUBFUNCTIONS
%
function B = gmtlab_defs
%% gmtlab_defs
B.OPEN_COMMAND      = NaN;
B.OUTDIR            = atmlab('WORK_AREA');
B.PDFVIEWER         = NaN;
B.PSVIEWER          = NaN;
B.VERBOSITY         = 0;

function [A,value] = gmt_prstnt_struct( A, def_fun, varargin )
%% gmt_prstnt_struct
% More or less cloned from prstnt_struct created by Patrick Eriksson in atmlab.

if isempty( A )
  A = feval( def_fun );
end

%=== As this function is called with a varargin argument, we have to extract
%=== varargin as given to the calling function.
%
varg = varargin{1};
value = [];

switch length( varg )
  case 0
    value = A;
  case 1
    if strcmp( varg{1}, 'defaults' )
      A = feval( def_fun );
     else
      if ~isfield( A,upper(varg{1}))
          error('gmtlab:input:undefined', ...
            'The field %s is not defined',upper(varg{1})); 
      end
      value = A.(upper(varg{1}));
    end
  case 2
      if ~isfield( A, upper(varg{1}))
          error('gmtlab:input:undefined','The field %s is not defined.',upper(varg{1}));
      end
      A.(upper(varg{1})) = varg{2};
      value = varg{2};
  otherwise
    error('gmtlab:input','Too many input arguments.');
end