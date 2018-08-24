% AXES_FRAME   Visibility of axes frame.
%
%    The functions makes the frame for some axes visible or invisible.
%
%    The axes UserData is used to store lost information when making the
%    frame invisible. The UserData are used to restore the frame in its
%    original version.
%
% FORMAT   axes_frame(h,on_or_off)
%        
% IN    h           Handle to the axes.
%       on_or_off   Either 'on' or 'off'.

% 2002-12-12   Created by Patrick Eriksson.


function axes_frame(h,on_or_off)


%=== Check input
%
rqre_nargin( 2, nargin );
%
if ~( strcmp( on_or_off, 'off' )  |  strcmp( on_or_off, 'on' ) )
  error('Valid actions are ''off'' and ''on''.');
end


if strcmp( on_or_off, 'off' )
  %
  c = get( get( h, 'Parent' ), 'Color' );
  %
  A.xcol = get( h, 'XCol' );
  A.xt   = get( h, 'XTick' );
  A.xtl  = get( h, 'XTickL' );
  A.ycol = get( h, 'YCol' );
  A.yt   = get( h, 'YTick' );
  A.ytl  = get( h, 'YTickL' );
  A.zcol = get( h, 'ZCol' );
  A.zt   = get( h, 'ZTick' );
  A.ztl  = get( h, 'ZTickL' );
  set( h, 'UserData', A );
  %
  set( h, 'Box', 'off' );
  set( h, 'XCol', c );
  set( h, 'XTick', [] );
  set( h, 'XTickL', [] );
  set( h, 'YCol', c );
  set( h, 'YTick', [] );
  set( h, 'YTickL', [] );
  set( h, 'ZCol', c );
  set( h, 'ZTick', [] );
  set( h, 'ZTickL', [] );

else
  %
  A = get( h, 'UserData' );
  %
  set( h, 'Box', 'on' );
  set( h, 'XCol', A.xcol );
  set( h, 'XTick', A.xt );
  set( h, 'XTickL', A.xtl );
  set( h, 'YCol', A.ycol );
  set( h, 'YTick', A.yt );
  set( h, 'YTickL', A.ytl );
  set( h, 'ZCol', A.zcol );
  set( h, 'ZTick', A.zt );
  set( h, 'ZTickL', A.ztl );

end
