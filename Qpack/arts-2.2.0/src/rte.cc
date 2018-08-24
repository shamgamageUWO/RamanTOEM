/* Copyright (C) 2002-2012
   Patrick Eriksson <Patrick.Eriksson@chalmers.se>
   Stefan Buehler   <sbuehler@ltu.se>
                            
   This program is free software; you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by the
   Free Software Foundation; either version 2, or (at your option) any
   later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307,
   USA. */



/*===========================================================================
  === File description 
  ===========================================================================*/

/*!
  \file   rte.cc
  \author Patrick Eriksson <Patrick.Eriksson@chalmers.se>
  \date   2002-05-29

  \brief  Functions to solve radiative transfer tasks.
*/



/*===========================================================================
  === External declarations
  ===========================================================================*/

#include <cmath>
#include <stdexcept>
#include "auto_md.h"
#include "check_input.h"
#include "geodetic.h"
#include "logic.h"
#include "math_funcs.h"
#include "montecarlo.h"
#include "physics_funcs.h"
#include "ppath.h"
#include "rte.h"
#include "special_interp.h"
#include "lin_alg.h"

extern const Numeric SPEED_OF_LIGHT;



/*===========================================================================
  === The functions in alphabetical order
  ===========================================================================*/


//! adjust_los
/*!
    Ensures that the zenith and azimuth angles of a line-of-sight vector are
    inside defined ranges.

    This function should not be used blindly, just when you know that the
    out-of-bounds values are obtained by an OK operation. As when making a
    disturbance calculation where e.g. the zenith angle is shifted with a small
    value. This function then handles the case when the original zenith angle
    is 0 or 180 and the disturbance then moves the angle outside the defined
    range. 

    \param   los              In/Out: LOS vector, defined as e.g. rte_los.
    \param   atmosphere_dim   As the WSV.

    \author Patrick Eriksson 
    \date   2012-04-11
*/
void adjust_los( 
         VectorView   los, 
   const Index &      atmosphere_dim )
{
  if( atmosphere_dim == 1 )
    {
           if( los[0] <   0 ) { los[0] = -los[0];    }
      else if( los[0] > 180 ) { los[0] = 360-los[0]; }
    }
  else if( atmosphere_dim == 2 )
    {
           if( los[0] < -180 ) { los[0] = los[0] + 360; }
      else if( los[0] >  180 ) { los[0] = los[0] - 360; }
    }
  else 
    {
      // If any of the angles out-of-bounds, use cart2zaaa to resolve 
      if( abs(los[0]-90) > 90  ||  abs(los[1]) > 180 )
        {
          Numeric dx, dy, dz;
          zaaa2cart( dx, dy, dz, los[0], los[1] );
          cart2zaaa( los[0], los[1], dx, dy, dz );
        }        
    }
}



//! apply_iy_unit
/*!
    Performs conversion from radiance to other units, as well as applies
    refractive index to fulfill the n2-law of radiance.

    Use *apply_iy_unit2* for conversion of jacobian data.

    \param   iy       In/Out: Tensor3 with data to be converted, where 
                      column dimension corresponds to Stokes dimensionality
                      and row dimension corresponds to frequency.
    \param   y_unit   As the WSV.
    \param   f_grid   As the WSV.
    \param   n        Refractive index at the observation position.
    \param   i_pol    Polarisation indexes. See documentation of y_pol.

    \author Patrick Eriksson 
    \date   2010-04-07
*/
void apply_iy_unit( 
            MatrixView   iy, 
         const String&   y_unit, 
       ConstVectorView   f_grid,
   const Numeric&        n,
   const ArrayOfIndex&   i_pol )
{
  // The code is largely identical between the two apply_iy_unit functions.
  // If any change here, remember to update the other function.

  const Index nf = iy.nrows();
  const Index ns = iy.ncols();

  assert( f_grid.nelem() == nf );
  assert( i_pol.nelem() == ns );

  if( y_unit == "1" )
    {
      if( n != 1 )
        { iy *= (n*n); }
    }

  else if( y_unit == "RJBT" )
    {
      for( Index iv=0; iv<nf; iv++ )
        {
          const Numeric scfac = invrayjean( 1, f_grid[iv] );
          for( Index is=0; is<ns; is++ )
            {
              if( i_pol[is] < 5 )           // Stokes components
                { iy(iv,is) *= scfac; }
              else                          // Measuement single pols
                { iy(iv,is) *= 2*scfac; }
            }
        }
    }

  else if( y_unit == "PlanckBT" )
    {
      for( Index iv=0; iv<nf; iv++ )
        {
          for( Index is=ns-1; is>=0; is-- ) // Order must here be reversed
            {
              if( i_pol[is] == 1 )
                { iy(iv,is) = invplanck( iy(iv,is), f_grid[iv] ); }
              else if( i_pol[is] < 5 )
                { 
                  assert( i_pol[0] == 1 );
                  iy(iv,is) = 
                    invplanck( 0.5*(iy(iv,0)+iy(iv,is)), f_grid[iv] ) -
                    invplanck( 0.5*(iy(iv,0)-iy(iv,is)), f_grid[iv] );
                }
              else
                { iy(iv,is) = invplanck( 2*iy(iv,is), f_grid[iv] ); }
            }
        }
    }
  
  else if ( y_unit == "W/(m^2 m sr)" )
    {
      for( Index iv=0; iv<nf; iv++ )
        {
          const Numeric scfac = n*n * f_grid[iv] * (f_grid[iv]/SPEED_OF_LIGHT);
          for( Index is=0; is<ns; is++ )
            { iy(iv,is) *= scfac; }
        }
    }
  
  else if ( y_unit == "W/(m^2 m-1 sr)" )
    {
      iy *= ( n * n * SPEED_OF_LIGHT );
    }

  else
    {
      ostringstream os;
      os << "Unknown option: y_unit = \"" << y_unit << "\"\n" 
         << "Recognised choices are: \"1\", \"RJBT\", \"PlanckBT\""
         << "\"W/(m^2 m sr)\" and \"W/(m^2 m-1 sr)\""; 
      
      throw runtime_error( os.str() );      
    }
}



//! apply_iy_unit2
/*!
    Largely as *apply_iy_unit* but operates on jacobian data.

    The associated spectrum data *iy* must be in radiance. That is, the
    spectrum can only be converted to Tb after the jacobian data. 

    \param   J        In/Out: Tensor3 with data to be converted, where 
                      column dimension corresponds to Stokes dimensionality
                      and row dimension corresponds to frequency.
    \param   iy       Associated radiance data.
    \param   y_unit   As the WSV.
    \param   f_grid   As the WSV.
    \param   n        Refractive index at the observation position.
    \param   i_pol    Polarisation indexes. See documentation of y_pol.

    \author Patrick Eriksson 
    \date   2010-04-10
*/
void apply_iy_unit2( 
   Tensor3View           J,
   ConstMatrixView       iy, 
   const String&         y_unit, 
   ConstVectorView       f_grid,
   const Numeric&        n,
   const ArrayOfIndex&   i_pol )
{
  // The code is largely identical between the two apply_iy_unit functions.
  // If any change here, remember to update the other function.

  const Index nf = iy.nrows();
  const Index ns = iy.ncols();
  const Index np = J.npages();

  assert( J.nrows() == nf );
  assert( J.ncols() == ns );
  assert( f_grid.nelem() == nf );
  assert( i_pol.nelem() == ns );

  if( y_unit == "1" )
    {
      if( n != 1 )
        { J *= (n*n); }
    }

  else if( y_unit == "RJBT" )
    {
      for( Index iv=0; iv<nf; iv++ )
        {
          const Numeric scfac = invrayjean( 1, f_grid[iv] );
          for( Index is=0; is<ns; is++ )
            {
              if( i_pol[is] < 5 )           // Stokes componenets
                {
                  for( Index ip=0; ip<np; ip++ )
                    { J(ip,iv,is) *= scfac; }
                }
              else                          // Measuement single pols
                {
                  for( Index ip=0; ip<np; ip++ )
                    { J(ip,iv,is) *= 2*scfac; }
                }
            }
        }
    }

  else if( y_unit == "PlanckBT" )
    {
      for( Index iv=0; iv<f_grid.nelem(); iv++ )
        {
          for( Index is=ns-1; is>=0; is-- )
            {
              Numeric scfac = 1;
              if( i_pol[is] == 1 )
                { scfac = dinvplanckdI( iy(iv,is), f_grid[iv] ); }
              else if( i_pol[is] < 5 )
                {
                  assert( i_pol[0] == 1 );
                  scfac = 
                    dinvplanckdI( 0.5*(iy(iv,0)+iy(iv,is)), f_grid[iv] ) +
                    dinvplanckdI( 0.5*(iy(iv,0)-iy(iv,is)), f_grid[iv] );
                }
              else
                { scfac = dinvplanckdI( 2*iy(iv,is), f_grid[iv] ); }
              //
              for( Index ip=0; ip<np; ip++ )
                { J(ip,iv,is) *= scfac; }
            }
        }
    }

  else if ( y_unit == "W/(m^2 m sr)" )
    {
      for( Index iv=0; iv<nf; iv++ )
        {
          const Numeric scfac = n*n * f_grid[iv] * (f_grid[iv]/SPEED_OF_LIGHT);
          for( Index ip=0; ip<np; ip++ )
            {
              for( Index is=0; is<ns; is++ )
                { J(ip,iv,is) *= scfac; }
            }
        }
    }
  
  else if ( y_unit == "W/(m^2 m-1 sr)" )
    {
      J *= ( n *n * SPEED_OF_LIGHT );
    }
  
  else
    {
      ostringstream os;
      os << "Unknown option: y_unit = \"" << y_unit << "\"\n" 
         << "Recognised choices are: \"1\", \"RJBT\", \"PlanckBT\""
         << "\"W/(m^2 m sr)\" and \"W/(m^2 m-1 sr)\""; 
      
      throw runtime_error( os.str() );      
    }  
}



//! bending_angle1d
/*!
    Calculates the bending angle for a 1D atmosphere.

    The expression used assumes a 1D atmosphere, that allows the bending angle
    to be calculated by start and end LOS. This is an approximation for 2D and
    3D, but a very small one and the function should in general be OK also for
    2D and 3D.

    The expression is taken from Kursinski et al., The GPS radio occultation
    technique, TAO, 2000.

    \return   alpha   Bending angle
    \param    ppath   Propagation path.

    \author Patrick Eriksson 
    \date   2012-04-05
*/
void bending_angle1d( 
        Numeric&   alpha,
  const Ppath&     ppath )
{
  Numeric theta;
  if( ppath.dim < 3 )
    { theta = abs( ppath.start_pos[1] - ppath.end_pos[1] ); }
  else
    { theta = sphdist( ppath.start_pos[1], ppath.start_pos[2],
                       ppath.end_pos[1], ppath.end_pos[2] ); }

  // Eq 17 in Kursinski et al., TAO, 2000:
  alpha = ppath.start_los[0] - ppath.end_los[0] + theta;

  // This as
  // phi_r = 180 - ppath.end_los[0]
  // phi_t = ppath.start_los[0]
}



//! defocusing_general_sub
/*!
    Just to avoid duplicatuion of code in *defocusing_general*.
   
    rte_los is mainly an input, but is also returned "adjusted" (with zenith
    and azimuth angles inside defined ranges) 
 
    \param    pos                 Out: Position of ppath at optical distance lo0
    \param    rte_los             In/out: Direction for transmitted signal 
                                  (disturbed from nominal value)
    \param    rte_pos             Out: Position of transmitter.
    \param    background          Out: Raditaive background of ppath.
    \param    lo0                 Optical path length between transmitter 
                                  and receiver.
    \param    ppath_step_agenda   As the WSV with the same name.
    \param    atmosphere_dim      As the WSV with the same name.
    \param    p_grid              As the WSV with the same name.
    \param    lat_grid            As the WSV with the same name.
    \param    lon_grid            As the WSV with the same name.
    \param    t_field             As the WSV with the same name.
    \param    z_field             As the WSV with the same name.
    \param    vmr_field           As the WSV with the same name.
    \param    f_grid              As the WSV with the same name.
    \param    refellipsoid        As the WSV with the same name.
    \param    z_surface           As the WSV with the same name.
    \param    verbosity           As the WSV with the same name.

    \author Patrick Eriksson 
    \date   2012-04-11
*/
void defocusing_general_sub( 
        Workspace&   ws,
        Vector&      pos,
        Vector&      rte_los,
        Index&       background,
  ConstVectorView    rte_pos,
  const Numeric&     lo0,
  const Agenda&      ppath_step_agenda,
  const Numeric&     ppath_lraytrace,
  const Index&       atmosphere_dim,
  ConstVectorView    p_grid,
  ConstVectorView    lat_grid,
  ConstVectorView    lon_grid,
  ConstTensor3View   t_field,
  ConstTensor3View   z_field,
  ConstTensor4View   vmr_field,
  ConstVectorView    f_grid,
  ConstVectorView    refellipsoid,
  ConstMatrixView    z_surface,
  const Verbosity&   verbosity )
{
  // Special treatment of 1D around zenith/nadir
  // (zenith angles outside [0,180] are changed by *adjust_los*)
  bool invert_lat = false;
  if( atmosphere_dim == 1  &&  ( rte_los[0] < 0 || rte_los[0] > 180 ) )
    { invert_lat = true; }

  // Handle cases where angles have moved out-of-bounds due to disturbance
  adjust_los( rte_los, atmosphere_dim );

  // Calculate the ppath for disturbed rte_los
  Ppath ppx;
  //
  ppath_calc( ws, ppx, ppath_step_agenda, atmosphere_dim, p_grid, lat_grid,
              lon_grid, t_field, z_field, vmr_field, 
              f_grid, refellipsoid, z_surface, 0, ArrayOfIndex(0), 
              rte_pos, rte_los, ppath_lraytrace, 0, verbosity );
  //
  background = ppath_what_background( ppx );

  // Calcualte cumulative optical path for ppx
  Vector lox( ppx.np );
  Index ilast = ppx.np-1;
  lox[0] = ppx.end_lstep;
  for( Index i=1; i<=ilast; i++ )
    { lox[i] = lox[i-1] + ppx.lstep[i-1] * ( ppx.nreal[i-1] + 
                                             ppx.nreal[i] ) / 2.0; }

  pos.resize( max( Index(2), atmosphere_dim ) );

  // Reciever at a longer distance (most likely out in space):
  if( lox[ilast] < lo0 )
    {
      const Numeric dl = lo0 - lox[ilast];
      if( atmosphere_dim < 3 )
        {
          Numeric x, z, dx, dz;
          poslos2cart( x, z, dx, dz, ppx.r[ilast], ppx.pos(ilast,1), 
                       ppx.los(ilast,0) );
          cart2pol( pos[0], pos[1], x+dl*dx, z+dl*dz, ppx.pos(ilast,1), 
                    ppx.los(ilast,0) );
        }
      else
        {
          Numeric x, y, z, dx, dy, dz;
          poslos2cart( x, y, z, dx, dy, dz, ppx.r[ilast], ppx.pos(ilast,1), 
                       ppx.pos(ilast,2), ppx.los(ilast,0), ppx.los(ilast,1) );
          cart2sph( pos[0], pos[1], pos[2], x+dl*dx, y+dl*dy, z+dl*dz, 
                    ppx.pos(ilast,1), ppx.pos(ilast,2), 
                    ppx.los(ilast,0), ppx.los(ilast,1) );
        }
    }

  // Interpolate to lo0
  else
    { 
      GridPos   gp;
      Vector    itw(2);
      gridpos( gp, lox, lo0 );
      interpweights( itw, gp );
      //
      pos[0] = interp( itw, ppx.r, gp );
      pos[1] = interp( itw, ppx.pos(joker,1), gp );
      if( atmosphere_dim == 3 )
        { pos[2] = interp( itw, ppx.pos(joker,2), gp ); }
    } 

  if( invert_lat )
    { pos[1] = -pos[1]; }
}


//! defocusing_general
/*!
    Defocusing for arbitrary geometry (zenith angle part only)

    Estimates the defocusing loss factor by calculating two paths with zenith
    angle off-sets. The distance between the two path at the optical path
    length between the transmitter and the receiver, divided with the
    corresponding distance for free space propagation, gives the defocusing
    loss. 

    The azimuth (gain) factor is not calculated. The path calculations are here
    done starting from the transmitter, which is the reversed direction
    compared to the ordinary path calculations starting at the receiver.
    
    \return   dlf                 Defocusing loss factor (1 for no loss)
    \param    ppath_step_agenda   As the WSV with the same name.
    \param    atmosphere_dim      As the WSV with the same name.
    \param    p_grid              As the WSV with the same name.
    \param    lat_grid            As the WSV with the same name.
    \param    lon_grid            As the WSV with the same name.
    \param    t_field             As the WSV with the same name.
    \param    z_field             As the WSV with the same name.
    \param    vmr_field           As the WSV with the same name.
    \param    f_grid              As the WSV with the same name.
    \param    refellipsoid        As the WSV with the same name.
    \param    z_surface           As the WSV with the same name.
    \param    ppath               As the WSV with the same name.
    \param    ppath_lraytrace     As the WSV with the same name.
    \param    dza                 Size of angular shift to apply.
    \param    verbosity           As the WSV with the same name.

    \author Patrick Eriksson 
    \date   2012-04-11
*/
void defocusing_general( 
        Workspace&   ws,
        Numeric&     dlf,
  const Agenda&      ppath_step_agenda,
  const Index&       atmosphere_dim,
  ConstVectorView    p_grid,
  ConstVectorView    lat_grid,
  ConstVectorView    lon_grid,
  ConstTensor3View   t_field,
  ConstTensor3View   z_field,
  ConstTensor4View   vmr_field,
  ConstVectorView    f_grid,
  ConstVectorView    refellipsoid,
  ConstMatrixView    z_surface,
  const Ppath&       ppath,
  const Numeric&     ppath_lraytrace,
  const Numeric&     dza,
  const Verbosity&   verbosity )
{
  // Optical and physical path between transmitter and reciver
  Numeric lo = ppath.start_lstep + ppath.end_lstep;
  Numeric lp = lo;
  for( Index i=0; i<=ppath.np-2; i++ )
    { lp += ppath.lstep[i];
      lo += ppath.lstep[i] * ( ppath.nreal[i] + ppath.nreal[i+1] ) / 2.0; 
    }
  // Extract rte_pos and rte_los
  const Vector rte_pos = ppath.start_pos[Range(0,atmosphere_dim)];
  //
  Vector rte_los0(max(Index(1),atmosphere_dim-1)), rte_los;
  mirror_los( rte_los, ppath.start_los, atmosphere_dim );
  rte_los0 = rte_los[Range(0,max(Index(1),atmosphere_dim-1))];

  // A new ppath with positive zenith angle off-set
  //
  Vector  pos1;
  Index   backg1;
  //
  rte_los     = rte_los0;
  rte_los[0] += dza;
  //
  defocusing_general_sub( ws, pos1, rte_los, backg1, rte_pos, lo, 
                          ppath_step_agenda, ppath_lraytrace, atmosphere_dim, 
                          p_grid, lat_grid, lon_grid, t_field, z_field, 
                          vmr_field, f_grid, refellipsoid, 
                          z_surface, verbosity );

  // Same thing with negative zenit angle off-set
  Vector  pos2;
  Index   backg2;
  //
  rte_los     = rte_los0;  // Use rte_los0 as rte_los can have been "adjusted"
  rte_los[0] -= dza;
  //
  defocusing_general_sub( ws, pos2, rte_los, backg2, rte_pos, lo, 
                          ppath_step_agenda, ppath_lraytrace, atmosphere_dim, 
                          p_grid, lat_grid, lon_grid, t_field, z_field, 
                          vmr_field, f_grid, refellipsoid, 
                          z_surface, verbosity );

  // Calculate distance between pos1 and 2, and derive the loss factor
  // All appears OK:
  if( backg1 == backg2 )
    {
      Numeric l12;
      if( atmosphere_dim < 3 )
        { distance2D( l12, pos1[0], pos1[1], pos2[0], pos2[1] ); }
      else
        { distance3D( l12, pos1[0], pos1[1], pos1[2], 
                           pos2[0], pos2[1], pos2[2] ); }
      //
      dlf = lp*2*DEG2RAD*dza /  l12;
    }
  // If different backgrounds, then only use the second calculation
  else
    {
      Numeric l12;
      if( atmosphere_dim == 1 )
        { 
          const Numeric r = refellipsoid[0];
          distance2D( l12, r+ppath.end_pos[0], 0, pos2[0], pos2[1] ); 
        }
      else if( atmosphere_dim == 2 )
        { 
          const Numeric r = refell2r( refellipsoid, ppath.end_pos[1] );
          distance2D( l12, r+ppath.end_pos[0], ppath.end_pos[1], 
                                                        pos2[0], pos2[1] ); 
        }
      else
        { 
          const Numeric r = refell2r( refellipsoid, ppath.end_pos[1] );
          distance3D( l12, r+ppath.end_pos[0], ppath.end_pos[1], 
                             ppath.end_pos[2], pos2[0], pos2[1], pos2[2] ); 
        }
      //
      dlf = lp*DEG2RAD*dza /  l12;
    }
}



//! defocusing_sat2sat
/*!
    Calculates defocusing for limb measurements between two satellites.

    The expressions used assume a 1D atmosphere, and can only be applied on
    limb sounding geometry. The function works for 2D and 3D and should give 
    OK estimates. Both the zenith angle (loss) and azimuth angle (gain) terms
    are considered.

    The expressions is taken from Kursinski et al., The GPS radio occultation
    technique, TAO, 2000.

    \return   dlf                 Defocusing loss factor (1 for no loss)
    \param    ppath_step_agenda   As the WSV with the same name.
    \param    atmosphere_dim      As the WSV with the same name.
    \param    p_grid              As the WSV with the same name.
    \param    lat_grid            As the WSV with the same name.
    \param    lon_grid            As the WSV with the same name.
    \param    t_field             As the WSV with the same name.
    \param    z_field             As the WSV with the same name.
    \param    vmr_field           As the WSV with the same name.
    \param    f_grid              As the WSV with the same name.
    \param    refellipsoid        As the WSV with the same name.
    \param    z_surface           As the WSV with the same name.
    \param    ppath               As the WSV with the same name.
    \param    ppath_lraytrace     As the WSV with the same name.
    \param    dza                 Size of angular shift to apply.
    \param    verbosity           As the WSV with the same name.

    \author Patrick Eriksson 
    \date   2012-04-11
*/
void defocusing_sat2sat( 
        Workspace&   ws,
        Numeric&     dlf,
  const Agenda&      ppath_step_agenda,
  const Index&       atmosphere_dim,
  ConstVectorView    p_grid,
  ConstVectorView    lat_grid,
  ConstVectorView    lon_grid,
  ConstTensor3View   t_field,
  ConstTensor3View   z_field,
  ConstTensor4View   vmr_field,
  ConstVectorView    f_grid,
  ConstVectorView    refellipsoid,
  ConstMatrixView    z_surface,
  const Ppath&       ppath,
  const Numeric&     ppath_lraytrace,
  const Numeric&     dza,
  const Verbosity&   verbosity )
{
  if( ppath.end_los[0] < 90  ||  ppath.start_los[0] > 90  )
     throw runtime_error( "The function *defocusing_sat2sat* can only be used "
                         "for limb sounding geometry." );

  // Index of tangent point
  Index it;
  find_tanpoint( it, ppath );
  assert( it >= 0 );

  // Length between tangent point and transmitter/reciver
  Numeric lt = ppath.start_lstep, lr = ppath.end_lstep;
  for( Index i=it; i<=ppath.np-2; i++ )
    { lt += ppath.lstep[i]; }
  for( Index i=0; i<it; i++ )
    { lr += ppath.lstep[i]; }

  // Bending angle and impact parameter for centre ray
  Numeric alpha0, a0;
  bending_angle1d( alpha0, ppath );
  alpha0 *= DEG2RAD;
  a0      = ppath.constant; 

  // Azimuth loss term (Eq 18.5 in Kursinski et al.)
  const Numeric lf = lr*lt / (lr+lt);
  const Numeric alt = 1 / ( 1 - alpha0*lf / refellipsoid[0] );

  // Calculate two new ppaths to get dalpha/da
  Numeric   alpha1, a1, alpha2, a2, dada;
  Ppath     ppt;
  Vector    rte_pos = ppath.end_pos[Range(0,atmosphere_dim)];
  Vector    rte_los = ppath.end_los;
  //
  rte_los[0] -= dza;
  adjust_los( rte_los, atmosphere_dim );
  ppath_calc( ws, ppt, ppath_step_agenda, atmosphere_dim, p_grid, lat_grid,
              lon_grid, t_field, z_field, vmr_field, 
              f_grid, refellipsoid, z_surface, 0, ArrayOfIndex(0), 
              rte_pos, rte_los, ppath_lraytrace, 0, verbosity );
  bending_angle1d( alpha2, ppt );
  alpha2 *= DEG2RAD;
  a2      = ppt.constant; 
  //
  rte_los[0] += 2*dza;
  adjust_los( rte_los, atmosphere_dim );
  ppath_calc( ws, ppt, ppath_step_agenda, atmosphere_dim, p_grid, lat_grid,
              lon_grid, t_field, z_field, vmr_field, 
              f_grid, refellipsoid, z_surface, 0, ArrayOfIndex(0), 
              rte_pos, rte_los, ppath_lraytrace, 0, verbosity );
  // This path can hit the surface. And we need to check if ppt is OK.
  // (remember this function only deals with sat-to-sat links and OK 
  // background here is be space) 
  // Otherwise use the centre ray as the second one.
  if( ppath_what_background(ppt) == 1 )
    {
      bending_angle1d( alpha1, ppt );
      alpha1 *= DEG2RAD;
      a1      = ppt.constant; 
      dada    = (alpha2-alpha1) / (a2-a1); 
    }
  else
    {
      dada    = (alpha2-alpha0) / (a2-a0);       
    }

  // Zenith loss term (Eq 18 in Kursinski et al.)
  const Numeric zlt = 1 / ( 1 - dada*lf );

  // Total defocusing loss
  dlf = zlt * alt;
}



//! dotprod_with_los
/*!
    Calculates the dot product between a field and a LOS

    The line-of-sight shall be given as in the ppath structure (i.e. the
    viewing direction), but the dot product is calculated for the photon
    direction. The field is specified by its three components.

    The returned value can be written as |f|*cos(theta), where |f| is the field
    strength, and theta the angle between the field and photon vectors.

    \return                    The result of the dot product
    \param   los               Pppath line-of-sight.
    \param   u                 U-component of field.
    \param   v                 V-component of field.
    \param   w                 W-component of field.
    \param   atmosphere_dim    As the WSV.

    \author Patrick Eriksson 
    \date   2012-12-12
*/
Numeric dotprod_with_los(
  ConstVectorView   los, 
  const Numeric&    u,
  const Numeric&    v,
  const Numeric&    w,
  const Index&      atmosphere_dim )
{
  // Strength of field
  const Numeric f = sqrt( u*u + v*v + w*w );

  // Zenith and azimuth angle for field (in radians) 
  const Numeric za_f = acos( w/f );
  const Numeric aa_f = atan2( u, v );

  // Zenith and azimuth angle for photon direction (in radians)
  Vector los_p;
  mirror_los( los_p, los, atmosphere_dim );
  const Numeric za_p = DEG2RAD * los_p[0];
  const Numeric aa_p = DEG2RAD * los_p[1];
  
  return f * ( cos(za_f) * cos(za_p) +
               sin(za_f) * sin(za_p) * cos(aa_f-aa_p) );
}    



//! emission_rtstep
/*!
    Radiative transfer over a step, with emission.

    In scalar notation, this is done: iy = iy*t + bbar*(1-t)

    The calculations are done differently for extmat_case 1 and 2/3.

    Frequency is throughout leftmost dimension.

    \param   iy           In/out: Radiance values
    \param   stokes_dim   In: As the WSV.
    \param   bbar         In: Average of emission source function
    \param   extmat_case  In: As returned by get_ppath_trans, but just for the
                              frequency of cocncern.
    \param   t            In: Transmission matrix of the step.

    \author Patrick Eriksson 
    \date   2013-04-19
*/
void emission_rtstep(
          Matrix&      iy,
    const Index&       stokes_dim,
    ConstVectorView    bbar,
       ArrayOfIndex&   extmat_case,
    ConstTensor3View   t )
{
  const Index nf = bbar.nelem();

  assert( t.ncols() == stokes_dim  &&  t.nrows() == stokes_dim ); 
  assert( t.npages() == nf );
  assert( extmat_case.nelem() == nf );

  // Spectrum at end of ppath step 
  if( stokes_dim == 1 )
    {
      for( Index iv=0; iv<nf; iv++ )  
        { iy(iv,0) = iy(iv,0) * t(iv,0,0) + bbar[iv] * ( 1 - t(iv,0,0) ); }
    }

  else
    {
#pragma omp parallel for      \
  if (!arts_omp_in_parallel()  \
      && nf >= arts_omp_get_max_threads())
      for( Index iv=0; iv<nf; iv++ )
        {
          assert( extmat_case[iv]>=1 && extmat_case[iv]<=3 );
          // Unpolarised absorption:
          if( extmat_case[iv] == 1 )
            {
              iy(iv,0) = iy(iv,0) * t(iv,0,0) + bbar[iv] * ( 1 - t(iv,0,0) );
              for( Index is=1; is<stokes_dim; is++ )
                { iy(iv,is) = iy(iv,is) * t(iv,is,is); }
            }
          // The general case:
          else
            {
              // Transmitted term
              Vector tt(stokes_dim);
              mult( tt, t(iv,joker,joker), iy(iv,joker));
              // Add emission, first Stokes element
              iy(iv,0) = tt[0] + bbar[iv] * ( 1 - t(iv,0,0) );
              // Remaining Stokes elements
              for( Index i=1; i<stokes_dim; i++ )
                { iy(iv,i) = tt[i] - bbar[iv] * t(iv,i,0); }
                      
            }
        }
    }
}

 

//! 
/*!
    Converts an extinction matrix to a transmission matrix

    The function performs the calculations differently depending on the
    conditions, to improve the speed. There are three cases: <br>
       1. Scalar RT and/or the matrix ext_mat_av is diagonal. <br>
       2. Special expression for "p30" case. <br>
       3. The total general case.

    If the structure of *ext_mat* is known, *icase* can be set to "case index"
    (1, 2 or 3) and some time is saved. This includes that no asserts are
    performed on *ext_mat*.

    Otherwise, *icase* must be set to 0. *ext_mat* is then analysed and *icase*
    is set by the function and is returned.

    trans_mat must be sized before calling the function.

    \param   trans_mat          Input/Output: Transmission matrix of slab.
    \param   icase              Input/Output: Index giving ext_mat case.
    \param   ext_mat            Input: Averaged extinction matrix.
    \param   lstep              Input: The length of the RTE step.

    \author Patrick Eriksson (based on earlier version started by Claudia)
    \date   2013-05-17 
*/
void ext2trans(
         MatrixView   trans_mat,
         Index&       icase,
   ConstMatrixView    ext_mat,
   const Numeric&     lstep )
{
  const Index stokes_dim = ext_mat.ncols();

  assert( ext_mat.nrows()==stokes_dim );
  assert( trans_mat.nrows()==stokes_dim && trans_mat.ncols()==stokes_dim );

  // Theoretically ext_mat(0,0) >= 0, but to demand this can cause problems for
  // iterative retrievals, and the assert is skipped. Negative should be a
  // result of negative vmr, and this issue is checked in basics_checkedCalc.
  //assert( ext_mat(0,0) >= 0 );     

  assert( icase>=0 && icase<=3 );
  assert( !is_singular( ext_mat ) );
  assert( lstep >= 0 );

  // Analyse ext_mat?
  if( icase == 0 )
    { 
      icase = 1;  // Start guess is diagonal

      //--- Scalar case ----------------------------------------------------------
      if( stokes_dim == 1 )
        {}

      //--- Vector RT ------------------------------------------------------------
      else
        {
          // Check symmetries and analyse structure of exp_mat:
          assert( ext_mat(1,1) == ext_mat(0,0) );
          assert( ext_mat(1,0) == ext_mat(0,1) );

          if( ext_mat(1,0) != 0 )
            { icase = 2; }
      
          if( stokes_dim >= 3 )
            {     
              assert( ext_mat(2,2) == ext_mat(0,0) );
              assert( ext_mat(2,1) == -ext_mat(1,2) );
              assert( ext_mat(2,0) == ext_mat(0,2) );
              
              if( ext_mat(2,0) != 0  ||  ext_mat(2,1) != 0 )
                { icase = 3; }

              if( stokes_dim > 3 )  
                {
                  assert( ext_mat(3,3) == ext_mat(0,0) );
                  assert( ext_mat(3,2) == -ext_mat(2,3) );
                  assert( ext_mat(3,1) == -ext_mat(1,3) );
                  assert( ext_mat(3,0) == ext_mat(0,3) ); 

                  if( icase < 3 )  // if icase==3, already at most complex case
                    {
                      if( ext_mat(3,0) != 0  ||  ext_mat(3,1) != 0 )
                        { icase = 3; }
                      else if( ext_mat(3,2) != 0 )
                        { icase = 2; }
                    }
                }
            }
        }
    }


  // Calculation options:
  if( icase == 1 )
    {
      trans_mat = 0;
      trans_mat(0,0) = exp( -ext_mat(0,0) * lstep );
      for( Index i=1; i<stokes_dim; i++ )
        { trans_mat(i,i) = trans_mat(0,0); }
    }
      
  else if( icase == 2 )
    {
      // Expressions below are found in "Polarization in Spectral Lines" by
      // Landi Degl'Innocenti and Landolfi (2004).
      const Numeric tI = exp( -ext_mat(0,0) * lstep );
      const Numeric HQ = ext_mat(0,1) * lstep;
      trans_mat(0,0) = tI * cosh( HQ );
      trans_mat(1,1) = trans_mat(0,0);
      trans_mat(1,0) = -tI * sinh( HQ );
      trans_mat(0,1) = trans_mat(1,0);
      if( stokes_dim >= 3 )
        {
          trans_mat(2,0) = 0;
          trans_mat(2,1) = 0;
          trans_mat(0,2) = 0;
          trans_mat(1,2) = 0;
          const Numeric RQ = ext_mat(2,3) * lstep;
          trans_mat(2,2) = tI * cos( RQ );
          if( stokes_dim > 3 )
            {
              trans_mat(3,0) = 0;
              trans_mat(3,1) = 0;
              trans_mat(0,3) = 0;
              trans_mat(1,3) = 0;
              trans_mat(3,3) = trans_mat(2,2);
              trans_mat(3,2) = tI * sin( RQ );
              trans_mat(2,3) = -trans_mat(3,2); 
            }
        }
    }
  else
    {
      Matrix ext_mat_ds = ext_mat;
      ext_mat_ds *= -lstep; 
      //         
      Index q = 10;  // index for the precision of the matrix exp function
      //
      matrix_exp( trans_mat, ext_mat_ds, q );
    }
}





//! get_iy
/*!
    Basic call of *iy_main_agenda*.

    This function is an interface to *iy_main_agenda* that can be used when
    only *iy* is of interest. That is, jacobian and auxilary parts are
    deactivated/ignored.

    \param   ws                    Out: The workspace
    \param   iy                    Out: As the WSV.
    \param   t_field               As the WSV.
    \param   z_field               As the WSV.
    \param   vmr_field             As the WSV.
    \param   cloudbox_on           As the WSV.
    \param   rte_pos               As the WSV.
    \param   rte_los               As the WSV.
    \param   iy_main_agenda    As the WSV.

    \author Patrick Eriksson 
    \date   2012-08-08
*/
void get_iy(
         Workspace&   ws,
         Matrix&      iy,
   ConstTensor3View   t_field,
   ConstTensor3View   z_field,
   ConstTensor4View   vmr_field,
   const Index&       cloudbox_on,
   ConstVectorView    f_grid,
   ConstVectorView    rte_pos,
   ConstVectorView    rte_los,
   ConstVectorView    rte_pos2,
   const Agenda&      iy_main_agenda )
{
  ArrayOfTensor3    diy_dx;
  ArrayOfTensor4    iy_aux;
  Ppath             ppath;
  Tensor3           iy_transmission(0,0,0);

  iy_main_agendaExecute( ws, iy, iy_aux, ppath, diy_dx, 1, iy_transmission, 
                         ArrayOfString(0), cloudbox_on, 0, t_field, z_field,
                         vmr_field, f_grid, rte_pos, rte_los, rte_pos2,
                         iy_main_agenda );
}




//! get_iy_of_background
/*!
    Determines iy of the "background" of a propgation path.

    The task is to determine *iy* and related variables for the
    background, or to continue the raditiave calculations
    "backwards". The details here depends on the method selected for
    the agendas.

    Each background is handled by an agenda. Several of these agandes
    can involve recursive calls of *iy_main_agenda*. 

    \param   ws                    Out: The workspace
    \param   iy                    Out: As the WSV.
    \param   diy_dx                Out: As the WSV.
    \param   iy_transmission       As the WSV.
    \param   jacobian_do           As the WSV.
    \param   ppath                 As the WSV.
    \param   atmosphere_dim        As the WSV.
    \param   t_field               As the WSV.
    \param   z_field               As the WSV.
    \param   vmr_field             As the WSV.
    \param   cloudbox_on           As the WSV.
    \param   stokes_dim            As the WSV.
    \param   f_grid                As the WSV.
    \param   iy_main_agenda        As the WSV.
    \param   iy_space_agenda       As the WSV.
    \param   iy_surface_agenda     As the WSV.
    \param   iy_cloudbox_agenda    As the WSV.

    \author Patrick Eriksson 
    \date   2009-10-08
*/
void get_iy_of_background(
        Workspace&        ws,
        Matrix&           iy,
        ArrayOfTensor3&   diy_dx,
  ConstTensor3View        iy_transmission,
  const Index&            jacobian_do,
  const Ppath&            ppath,
  ConstVectorView         rte_pos2,
  const Index&            atmosphere_dim,
  ConstTensor3View        t_field,
  ConstTensor3View        z_field,
  ConstTensor4View        vmr_field,
  const Index&            cloudbox_on,
  const Index&            stokes_dim,
  ConstVectorView         f_grid,
  const Agenda&           iy_main_agenda,
  const Agenda&           iy_space_agenda,
  const Agenda&           iy_surface_agenda,
  const Agenda&           iy_cloudbox_agenda,
  const Verbosity&        verbosity)
{
  CREATE_OUT3;
  
  // Some sizes
  const Index nf = f_grid.nelem();
  const Index np = ppath.np;

  // Set rtp_pos and rtp_los to match the last point in ppath.
  //
  // Note that the Ppath positions (ppath.pos) for 1D have one column more
  // than expected by most functions. Only the first atmosphere_dim values
  // shall be copied.
  //
  Vector rtp_pos, rtp_los;
  rtp_pos.resize( atmosphere_dim );
  rtp_pos = ppath.pos(np-1,Range(0,atmosphere_dim));
  rtp_los.resize( ppath.los.ncols() );
  rtp_los = ppath.los(np-1,joker);

  out3 << "Radiative background: " << ppath.background << "\n";


  // Handle the different background cases
  //
  String agenda_name;
  // 
  switch( ppath_what_background( ppath ) )
    {

    case 1:   //--- Space ---------------------------------------------------- 
      {
        agenda_name = "iy_space_agenda";
        chk_not_empty( agenda_name, iy_space_agenda );
        iy_space_agendaExecute( ws, iy, f_grid, rtp_pos, rtp_los, 
                                iy_space_agenda );
      }
      break;

    case 2:   //--- The surface -----------------------------------------------
      {
        agenda_name = "iy_surface_agenda";
        chk_not_empty( agenda_name, iy_surface_agenda );
        iy_surface_agendaExecute( ws, iy, diy_dx, iy_transmission, cloudbox_on,
                                  jacobian_do, t_field, z_field, vmr_field,
                                  f_grid, iy_main_agenda, rtp_pos, rtp_los, 
                                  rte_pos2, iy_surface_agenda );
      }
      break;

    case 3:   //--- Cloudbox boundary or interior ------------------------------
    case 4:
      {
        agenda_name = "iy_cloudbox_agenda";
        chk_not_empty( agenda_name, iy_cloudbox_agenda );
        iy_cloudbox_agendaExecute( ws, iy, f_grid, rtp_pos, rtp_los, 
                                   iy_cloudbox_agenda );
      }
      break;

    default:  //--- ????? ----------------------------------------------------
      // Are we here, the coding is wrong somewhere
      assert( false );
    }

  if( iy.ncols() != stokes_dim  ||  iy.nrows() != nf )
    {
      ostringstream os;
      os << "The size of *iy* returned from *" << agenda_name << "* is\n"
         << "not correct:\n"
         << "  expected size = [" << nf << "," << stokes_dim << "]\n"
         << "  size of iy    = [" << iy.nrows() << "," << iy.ncols()<< "]\n";
      throw runtime_error( os.str() );      
    }
}



//! get_ppath_atmvars
/*!
    Determines pressure, temperature, VMR, winds and magnetic field for each
    propgataion path point.

    The output variables are sized inside the function. For VMR the
    dimensions are [ species, propagation path point ].

    \param   ppath_p           Out: Pressure for each ppath point.
    \param   ppath_t           Out: Temperature for each ppath point.
    \param   ppath_vmr         Out: VMR values for each ppath point.
    \param   ppath_wind        Out: Wind vector for each ppath point.
    \param   ppath_mag         Out: Mag. field vector for each ppath point.
    \param   ppath             As the WSV.
    \param   atmosphere_dim    As the WSV.
    \param   p_grid            As the WSV.
    \param   lat_grid          As the WSV.
    \param   lon_grid          As the WSV.
    \param   t_field           As the WSV.
    \param   vmr_field         As the WSV.
    \param   wind_u_field      As the WSV.
    \param   wind_v_field      As the WSV.
    \param   wind_w_field      As the WSV.
    \param   mag_u_field       As the WSV.
    \param   mag_v_field       As the WSV.
    \param   mag_w_field       As the WSV.

    \author Patrick Eriksson 
    \date   2009-10-05
*/
void get_ppath_atmvars( 
        Vector&      ppath_p, 
        Vector&      ppath_t, 
        Matrix&      ppath_vmr, 
        Matrix&      ppath_wind, 
        Matrix&      ppath_mag,
  const Ppath&       ppath,
  const Index&       atmosphere_dim,
  ConstVectorView    p_grid,
  ConstTensor3View   t_field,
  ConstTensor4View   vmr_field,
  ConstTensor3View   wind_u_field,
  ConstTensor3View   wind_v_field,
  ConstTensor3View   wind_w_field,
  ConstTensor3View   mag_u_field,
  ConstTensor3View   mag_v_field,
  ConstTensor3View   mag_w_field )
{
  const Index   np  = ppath.np;
  // Pressure:
  ppath_p.resize(np);
  Matrix itw_p(np,2);
  interpweights( itw_p, ppath.gp_p );      
  itw2p( ppath_p, p_grid, ppath.gp_p, itw_p );
  
  // Temperature:
  ppath_t.resize(np);
  Matrix   itw_field;
  interp_atmfield_gp2itw( itw_field, atmosphere_dim, 
                          ppath.gp_p, ppath.gp_lat, ppath.gp_lon );
  interp_atmfield_by_itw( ppath_t,  atmosphere_dim, t_field, 
                          ppath.gp_p, ppath.gp_lat, ppath.gp_lon, itw_field );

  // VMR fields:
  const Index ns = vmr_field.nbooks();
  ppath_vmr.resize(ns,np);
  for( Index is=0; is<ns; is++ )
    {
      interp_atmfield_by_itw( ppath_vmr(is, joker), atmosphere_dim,
                              vmr_field( is, joker, joker, joker ), 
                              ppath.gp_p, ppath.gp_lat, ppath.gp_lon, 
                              itw_field );
    }

  // Winds:
  ppath_wind.resize(3,np);
  ppath_wind = 0;
  //
  if( wind_u_field.npages() > 0 ) 
    { 
      interp_atmfield_by_itw( ppath_wind(0,joker), atmosphere_dim, wind_u_field,
                            ppath.gp_p, ppath.gp_lat, ppath.gp_lon, itw_field );
    }
  if( wind_v_field.npages() > 0 ) 
    { 
      interp_atmfield_by_itw( ppath_wind(1,joker), atmosphere_dim, wind_v_field,
                            ppath.gp_p, ppath.gp_lat, ppath.gp_lon, itw_field );
    }
  if( wind_w_field.npages() > 0 ) 
    { 
      interp_atmfield_by_itw( ppath_wind(2,joker), atmosphere_dim, wind_w_field,
                            ppath.gp_p, ppath.gp_lat, ppath.gp_lon, itw_field );
    }

  // Magnetic field:
  ppath_mag.resize(3,np);
  ppath_mag = 0;
  //
  if( mag_u_field.npages() > 0 )
    {
      interp_atmfield_by_itw( ppath_mag(0,joker), atmosphere_dim, mag_u_field,
                            ppath.gp_p, ppath.gp_lat, ppath.gp_lon, itw_field );
    }
  if( mag_v_field.npages() > 0 )
    {
      interp_atmfield_by_itw( ppath_mag(1,joker), atmosphere_dim, mag_v_field,
                            ppath.gp_p, ppath.gp_lat, ppath.gp_lon, itw_field );
    }
  if( mag_w_field.npages() > 0 )
    {
      interp_atmfield_by_itw( ppath_mag(2,joker), atmosphere_dim, mag_w_field,
                            ppath.gp_p, ppath.gp_lat, ppath.gp_lon, itw_field );
    }
}



//! get_ppath_abs
/*!
    Determines the "clearsky" absorption along a propagation path.

    *ppath_abs* returns the summed absorption and has dimensions
       [ frequency, stokes, stokes, ppath point ]

    *abs_per_species* can hold absorption for individual species. The
    species to include ar selected by *ispecies*. For example, to store first
    and third species in abs_per_species, set ispecies to [0][2].

    The output variables are sized inside the function. The dimension order is 
       [ absorption species, frequency, stokes, stokes, ppath point ]

    \param   ws                  Out: The workspace
    \param   ppath_abs           Out: Summed absorption at each ppath point
    \param   abs_per_species     Out: Absorption for "ispecies"
    \param   propmat_clearsky_agenda As the WSV.    
    \param   ppath               As the WSV.    
    \param   ppath_p             Pressure for each ppath point.
    \param   ppath_t             Temperature for each ppath point.
    \param   ppath_vmr           VMR values for each ppath point.
    \param   ppath_f             See get_ppath_f.
    \param   ppath_mag           See get_ppath_atmvars.
    \param   f_grid              As the WSV.    
    \param   stokes_dim          As the WSV.
    \param   ispecies            Index of species to store in abs_per_species

    \author Patrick Eriksson 
    \date   2012-08-15
*/
void get_ppath_abs( 
        Workspace&      ws,
        Tensor4&        ppath_abs,
        Tensor5&        abs_per_species,
  const Agenda&         propmat_clearsky_agenda,
  const Ppath&          ppath,
  ConstVectorView       ppath_p, 
  ConstVectorView       ppath_t, 
  ConstMatrixView       ppath_vmr, 
  ConstMatrixView       ppath_f, 
  ConstMatrixView       ppath_mag,
  ConstVectorView       f_grid, 
  const Index&          stokes_dim,
  const ArrayOfIndex&   ispecies )
{
  // Sizes
  const Index   nf   = f_grid.nelem();
  const Index   np   = ppath.np;
  const Index   nabs = ppath_vmr.nrows();
  const Index   nisp = ispecies.nelem();

  DEBUG_ONLY(
    for( Index i=0; i<nisp; i++ )
      {
        assert( ispecies[i] >= 0 );
        assert( ispecies[i] < nabs );
      }
  )

  // Size variable
  try 
    {
      ppath_abs.resize( nf, stokes_dim, stokes_dim, np ); 
      abs_per_species.resize( nisp, nf, stokes_dim, stokes_dim, np ); 
    } 
  catch (std::bad_alloc x) 
    {
      ostringstream os;
      os << "Run-time error in function: get_ppath_abs" << endl
         << "Memory allocation failed for ppath_abs("
         << nabs << ", " << nf << ", " << stokes_dim << ", "
         << stokes_dim << ", " << np << ")" << endl;
      throw runtime_error(os.str());
    }

  String fail_msg;
  bool failed = false;

  // Loop ppath points
  //
  Workspace l_ws (ws);
  Agenda l_propmat_clearsky_agenda (propmat_clearsky_agenda);
  //
  if (np)
#pragma omp parallel for                    \
  if (!arts_omp_in_parallel()               \
      && np >= arts_omp_get_max_threads())  \
  firstprivate(l_ws, l_propmat_clearsky_agenda)
  for( Index ip=0; ip<np; ip++ )
    {
      if (failed) continue;

      // Call agenda
      //
      Tensor4  propmat_clearsky;
      //
      try {
        Vector rtp_vmr(0);
        if( nabs )
          {
            propmat_clearsky_agendaExecute( l_ws, propmat_clearsky, 
               ppath_f(joker,ip), ppath_mag(joker,ip), ppath.los(ip,joker), 
               ppath_p[ip], ppath_t[ip], ppath_vmr(joker,ip),
               l_propmat_clearsky_agenda );
          }
        else
          {
            propmat_clearsky_agendaExecute( l_ws, propmat_clearsky, 
               ppath_f(joker,ip), ppath_mag(joker,ip), ppath.los(ip,joker), 
               ppath_p[ip], ppath_t[ip], Vector(0), l_propmat_clearsky_agenda );
          }
      } catch (runtime_error e) {
#pragma omp critical (get_ppath_abs_fail)
          { failed = true; fail_msg = e.what();}
      }

      // Copy to output argument
      if( !failed )
        {
          assert( propmat_clearsky.ncols() == stokes_dim );
          assert( propmat_clearsky.nrows() == stokes_dim );
          assert( propmat_clearsky.npages() == nf );
          assert( propmat_clearsky.nbooks() == max(nabs,Index(1)) );

          for( Index i1=0; i1<nf; i1++ )
            {
              for( Index i2=0; i2<stokes_dim; i2++ )
                {
                  for( Index i3=0; i3<stokes_dim; i3++ )
                    {
                      ppath_abs(i1,i2,i3,ip) = propmat_clearsky(joker,i1,i2,i3).sum();

                      for( Index ia=0; ia<nisp; ia++ )
                        {
                          abs_per_species(ia,i1,i2,i3,ip) = 
                                                propmat_clearsky(ispecies[ia],i1,i2,i3);
                        }
                      
                    }
                }
            }
        }
    }

    if (failed)
        throw runtime_error(fail_msg);
}



//! get_ppath_blackrad
/*!
    Determines blackbody radiation along the propagation path.

    The output variable is sized inside the function. The dimension order is 
       [ frequency, ppath point ]

    \param   ws                Out: The workspace
    \param   ppath_blackrad    Out: Emission source term at each ppath point 
    \param   blackbody_radiation_agenda   As the WSV.    
    \param   ppath_t           Temperature for each ppath point.
    \param   ppath_f           See get_ppath_f.

    \author Patrick Eriksson 
    \date   2012-08-15
*/
void get_ppath_blackrad( 
        Workspace&   ws,
        Matrix&      ppath_blackrad,
  const Agenda&      blackbody_radiation_agenda,
  const Ppath&       ppath,
  ConstVectorView    ppath_t, 
  ConstMatrixView    ppath_f )
{
  // Sizes
  const Index   nf = ppath_f.nrows();
  const Index   np = ppath.np;

  // Loop path and call agenda
  //
  ppath_blackrad.resize( nf, np ); 
  //
  for( Index ip=0; ip<np; ip++ )
    {
      Vector   bvector;
      
      blackbody_radiation_agendaExecute( ws, bvector, ppath_t[ip],
                                         ppath_f(joker,ip), 
                                         blackbody_radiation_agenda );
      ppath_blackrad(joker,ip) = bvector;
    }
}



//! get_ppath_ext
/*!
    Determines the particle properties along a propagation path.

    Note that the extinction for all particle types is summed. And that
    all frequencies are filled for pnd_abs_vec and pnd_ext_mat even if
    use_mean_scat_data is true (but data equal for all frequencies).

    \param   ws                  Out: The workspace
    \param   clear2cloudbox      Out: Mapping of index. See code for details. 
    \param   pnd_abs_vec         Out: Absorption vectors for particles
                                      (defined only where particles are found)
    \param   pnd_ext_vec         Out: Extinction matrices for particles
                                      (defined only where particles are found)
    \param   scat_data           Out: Extracted scattering data. Length of
                                      array affected by *use_mean_scat_data*.
    \param   ppath_pnd           Out. The particle number density for each
                                      point (also outside cloudbox).
    \param   ppath               As the WSV.    
    \param   ppath_t             Temperature for each ppath point.
    \param   stokes_dim          As the WSV.    
    \param   f_grid              As the WSV.    
    \param   cloubox_limits      As the WSV.    
    \param   pnd_field           As the WSV.    
    \param   use_mean_scat_data  As the WSV.    
    \param   scat_data_array       As the WSV.    

    \author Patrick Eriksson 
    \date   2012-08-23
*/
void get_ppath_ext( 
        ArrayOfIndex&                  clear2cloudbox,
        Tensor3&                       pnd_abs_vec, 
        Tensor4&                       pnd_ext_mat, 
  Array<ArrayOfSingleScatteringData>&  scat_data,
        Matrix&                        ppath_pnd,
  const Ppath&                         ppath,
  ConstVectorView                      ppath_t, 
  const Index&                         stokes_dim,
  ConstMatrixView                      ppath_f, 
  const Index&                         atmosphere_dim,
  const ArrayOfIndex&                  cloudbox_limits,
  const Tensor4&                       pnd_field,
  const Index&                         use_mean_scat_data,
  const ArrayOfSingleScatteringData&   scat_data_array,
  const Verbosity&                     verbosity )
{
  const Index nf = ppath_f.nrows();
  const Index np = ppath.np;

  // Pnd along the ppath
  ppath_pnd.resize( pnd_field.nbooks(), np );
  ppath_pnd = 0;

  // A variable that maps from total ppath to extension data index.
  // If outside cloudbox or all pnd=0, this variable holds -1.
  // Otherwise it gives the index in pnd_ext_mat etc.
  clear2cloudbox.resize( np );

  // Determine ppath_pnd
  Index nin = 0;
  for( Index ip=0; ip<np; ip++ )
    {
      Matrix itw( 1, Index(pow(2.0,Numeric(atmosphere_dim))) );

      ArrayOfGridPos gpc_p(1), gpc_lat(1), gpc_lon(1);
      GridPos gp_lat, gp_lon;
      if( atmosphere_dim >= 2 ) { gridpos_copy( gp_lat, ppath.gp_lat[ip] ); } 
      if( atmosphere_dim == 3 ) { gridpos_copy( gp_lon, ppath.gp_lon[ip] ); }
      if( is_gp_inside_cloudbox( ppath.gp_p[ip], gp_lat, gp_lon, 
                                 cloudbox_limits, true, atmosphere_dim ) )
        { 
          interp_cloudfield_gp2itw( itw(0,joker), 
                                    gpc_p[0], gpc_lat[0], gpc_lon[0], 
                                    ppath.gp_p[ip], gp_lat, gp_lon,
                                    atmosphere_dim, cloudbox_limits );
          for( Index i=0; i<pnd_field.nbooks(); i++ )
            {
              interp_atmfield_by_itw( ppath_pnd(i,ip), atmosphere_dim,
                                      pnd_field(i,joker,joker,joker), 
                                      gpc_p, gpc_lat, gpc_lon, itw );
            }
          if( max(ppath_pnd(joker,ip)) > 0 )
            { clear2cloudbox[ip] = nin;   nin++; }
          else
            { clear2cloudbox[ip] = -1; }
        }
      else
        { clear2cloudbox[ip] = -1; }
    }

  // Particle single scattering properties (are independent of position)
  //
  if( use_mean_scat_data )
    {
      const Numeric f = (mean(ppath_f(0,joker))+mean(ppath_f(nf-1,joker)))/2.0;
      scat_data.resize( 1 );
      scat_data_array_monoCalc( scat_data[0], scat_data_array, Vector(1,f), 0, 
                          verbosity );
    }
  else
    {
      scat_data.resize( nf );
      for( Index iv=0; iv<nf; iv++ )
        { 
          const Numeric f = mean(ppath_f(iv,joker));
          scat_data_array_monoCalc( scat_data[iv], scat_data_array, Vector(1,f), 0, 
                              verbosity ); 
        }
    }

  // Resize absorption and extension tensors
  pnd_abs_vec.resize( nf, stokes_dim, nin ); 
  pnd_ext_mat.resize( nf, stokes_dim, stokes_dim, nin ); 

  // Loop ppath points
  //
  for( Index ip=0; ip<np; ip++ )
    {
      const Index i = clear2cloudbox[ip];
      if( i>=0 )
        {
          // Direction of outgoing scattered radiation (which is reversed to
          // LOS). Note that rtp_los2 is only used for extracting scattering
          // properties.
          Vector rtp_los2;
          mirror_los( rtp_los2, ppath.los(ip,joker), atmosphere_dim );

          // Extinction and absorption
          if( use_mean_scat_data )
            {
              Vector   abs_vec( stokes_dim );
              Matrix   ext_mat( stokes_dim, stokes_dim );
              opt_propCalc( ext_mat, abs_vec, rtp_los2[0], rtp_los2[1], 
                            scat_data[0], stokes_dim, ppath_pnd(joker,ip), 
                            ppath_t[ip], verbosity);
              for( Index iv=0; iv<nf; iv++ )
                { 
                  pnd_ext_mat(iv,joker,joker,i) = ext_mat;
                  pnd_abs_vec(iv,joker,i)       = abs_vec;
                }
            }
          else
            {
              for( Index iv=0; iv<nf; iv++ )
                { 
                  opt_propCalc( pnd_ext_mat(iv,joker,joker,i), 
                                pnd_abs_vec(iv,joker,i), rtp_los2[0], 
                                rtp_los2[1], scat_data[iv], stokes_dim,
                                ppath_pnd(joker,ip), ppath_t[ip], verbosity );
                }
            }
        }
    }
}



//! get_ppath_f
/*!
    Determines the Doppler shifted frequencies along the propagation path.

    ppath_doppler [ nf + np ]

    \param   ppath_f          Out: Doppler shifted f_grid
    \param   ppath            Propagation path.
    \param   f_grid           Original f_grid.
    \param   atmosphere_dim   As the WSV.
    \param   rte_alonglos_v   As the WSV.
    \param   ppath_wind       See get_ppath_atmvars.

    \author Patrick Eriksson 
    \date   2013-02-21
*/
void get_ppath_f( 
        Matrix&    ppath_f,
  const Ppath&     ppath,
  ConstVectorView  f_grid, 
  const Index&     atmosphere_dim,
  const Numeric&   rte_alonglos_v,
  ConstMatrixView  ppath_wind )
{
  // Sizes
  const Index   nf = f_grid.nelem();
  const Index   np = ppath.np;

  ppath_f.resize(nf,np);

  // Doppler relevant velocity
  //
  for( Index ip=0; ip<np; ip++ )
    {
      // Start by adding rte_alonglos_v (most likely sensor effects)
      Numeric v_doppler = rte_alonglos_v;

      // Include wind
      if( ppath_wind(1,ip) != 0  ||  ppath_wind(0,ip) != 0  ||  
                                     ppath_wind(2,ip) != 0  )
        {
          // The dot product below is valid for the photon direction. Winds
          // along this direction gives a positive contribution.
          v_doppler += dotprod_with_los( ppath.los(ip,joker), ppath_wind(0,ip),
                          ppath_wind(1,ip), ppath_wind(2,ip), atmosphere_dim );
        }

      // Determine frequency grid
      if( v_doppler == 0 )
        { ppath_f(joker,ip) = f_grid; }
      else
        { 
          // Positive v_doppler means that sensor measures lower rest
          // frequencies
          const Numeric a = 1 - v_doppler / SPEED_OF_LIGHT;
          for( Index iv=0; iv<nf; iv++ )
            { ppath_f(iv,ip) = a * f_grid[iv]; }
        }
    }
}



//! get_ppath_trans
/*!
    Determines the transmission in different ways for a clear-sky RT
    integration.

    The argument trans_partial holds the transmission for each propagation path
    step. It has np-1 columns.

    The structure of average extinction matrix for each step is returned in
    extmat_case. The dimension of this variable is [np-1,nf]. For the coding
    see *ext2trans*.

    The argument trans_cumalat holds the transmission between the path point
    with index 0 and each propagation path point. The transmission is valid for
    the photon travelling direction. It has np columns.

    The output variables are sized inside the function. The dimension order is 
       [ frequency, stokes, stokes, ppath point ]

    The scalar optical thickness is calculated in parallel.

    \param   trans_partial  Out: Transmission for each path step.
    \param   extmat_case    Out: Corresponds to *icase* of *ext2trans*.
    \param   trans_cumulat  Out: Transmission to each path point.
    \param   scalar_tau     Out: Total (scalar) optical thickness of path
    \param   ppath          As the WSV.    
    \param   ppath_abs      See get_ppath_abs.
    \param   f_grid         As the WSV.    
    \param   stokes_dim     As the WSV.

    \author Patrick Eriksson 
    \date   2012-08-15
*/
void get_ppath_trans( 
        Tensor4&               trans_partial,
        ArrayOfArrayOfIndex&   extmat_case,
        Tensor4&               trans_cumulat,
        Vector&                scalar_tau,
  const Ppath&                 ppath,
  ConstTensor4View&            ppath_abs,
  ConstVectorView              f_grid, 
  const Index&                 stokes_dim )
{
  // Sizes
  const Index   nf = f_grid.nelem();
  const Index   np = ppath.np;

  // Init variables
  //
  trans_partial.resize( nf, stokes_dim, stokes_dim, np-1 );
  trans_cumulat.resize( nf, stokes_dim, stokes_dim, np );
  //
  extmat_case.resize(np-1);
  for( Index i=0; i<np-1; i++ )
    { extmat_case[i].resize(nf); }
  //
  scalar_tau.resize( nf );
  scalar_tau = 0;

  // Loop ppath points (in the anti-direction of photons)  
  //
  for( Index ip=0; ip<np; ip++ )
    {
      // If first point, calculate sum of absorption and set transmission
      // to identity matrix.
      if( ip == 0 )
        { 
          for( Index iv=0; iv<nf; iv++ )
            { id_mat( trans_cumulat(iv,joker,joker,ip) ); }
        }

      else
        {
          for( Index iv=0; iv<nf; iv++ )
            {
              // Transmission due to absorption
              Matrix ext_mat(stokes_dim,stokes_dim);
              for( Index is1=0; is1<stokes_dim; is1++ ) {
                for( Index is2=0; is2<stokes_dim; is2++ ) {
                  ext_mat(is1,is2) = 0.5 * ( ppath_abs(iv,is1,is2,ip-1) + 
                                             ppath_abs(iv,is1,is2,ip  ) );
                } }
              scalar_tau[iv] += ppath.lstep[ip-1] * ext_mat(0,0); 
              extmat_case[ip-1][iv] = 0;
              ext2trans( trans_partial(iv,joker,joker,ip-1), 
                         extmat_case[ip-1][iv], ext_mat, ppath.lstep[ip-1] ); 
              
              // Cumulative transmission
              // (note that multiplication below depends on ppath loop order)
              mult( trans_cumulat(iv,joker,joker,ip), 
                    trans_cumulat(iv,joker,joker,ip-1), 
                    trans_partial(iv,joker,joker,ip-1) );
            }
        }
    }
}



//! get_ppath_trans2
/*!
    Determines the transmission in different ways for a cloudy RT integration.

    This function works as get_ppath_trans, but considers also particle
    extinction. See get_ppath_trans for format of output data.

    \param   trans_partial    Out: Transmission for each path step.
    \param   trans_cumulat    Out: Transmission to each path point.
    \param   scalar_tau       Out: Total (scalar) optical thickness of path
    \param   ppath            As the WSV.    
    \param   ppath_abs        See get_ppath_abs.
    \param   f_grid           As the WSV.    
    \param   stokes_dim       As the WSV.
    \param   clear2cloudbox   See get_ppath_ext.
    \param   pnd_ext_mat      See get_ppath_ext.

    \author Patrick Eriksson 
    \date   2012-08-23
*/
void get_ppath_trans2( 
        Tensor4&               trans_partial,
        ArrayOfArrayOfIndex&   extmat_case,
        Tensor4&               trans_cumulat,
        Vector&                scalar_tau,
  const Ppath&                 ppath,
  ConstTensor4View&            ppath_abs,
  ConstVectorView              f_grid, 
  const Index&                 stokes_dim,
  const ArrayOfIndex&          clear2cloudbox,
  ConstTensor4View             pnd_ext_mat )
{
  // Sizes
  const Index   nf = f_grid.nelem();
  const Index   np = ppath.np;

  // Init variables
  //
  trans_partial.resize( nf, stokes_dim, stokes_dim, np-1 );
  trans_cumulat.resize( nf, stokes_dim, stokes_dim, np );
  //
  extmat_case.resize(np-1);
  for( Index i=0; i<np-1; i++ )
    { extmat_case[i].resize(nf); }
  //
  scalar_tau.resize( nf );
  scalar_tau  = 0;
  
  // Loop ppath points (in the anti-direction of photons)  
  //
  Tensor3 extsum_old, extsum_this( nf, stokes_dim, stokes_dim );
  //
  for( Index ip=0; ip<np; ip++ )
    {
      // If first point, calculate sum of absorption and set transmission
      // to identity matrix.
      if( ip == 0 )
        { 
          for( Index iv=0; iv<nf; iv++ ) 
            {
              for( Index is1=0; is1<stokes_dim; is1++ ) {
                for( Index is2=0; is2<stokes_dim; is2++ ) {
                  extsum_this(iv,is1,is2) = ppath_abs(iv,is1,is2,ip);
                } } 
              id_mat( trans_cumulat(iv,joker,joker,ip) );
            }
          // First point should not be "cloudy", but just in case:
          if( clear2cloudbox[ip] >= 0 )
            {
              const Index ic = clear2cloudbox[ip];
              for( Index iv=0; iv<nf; iv++ ) {
                for( Index is1=0; is1<stokes_dim; is1++ ) {
                  for( Index is2=0; is2<stokes_dim; is2++ ) {
                    extsum_this(iv,is1,is2) += pnd_ext_mat(iv,is1,is2,ic);
                } } }
            }
        }

      else
        {
          const Index ic = clear2cloudbox[ip];
          //
          for( Index iv=0; iv<nf; iv++ ) 
            {
              // Transmission due to absorption and scattering
              Matrix ext_mat(stokes_dim,stokes_dim);  // -1*tau
              for( Index is1=0; is1<stokes_dim; is1++ ) {
                for( Index is2=0; is2<stokes_dim; is2++ ) {
                  extsum_this(iv,is1,is2) = ppath_abs(iv,is1,is2,ip);
                  if( ic >= 0 )
                    { extsum_this(iv,is1,is2) += pnd_ext_mat(iv,is1,is2,ic); }

                  ext_mat(is1,is2) = 0.5 * ( extsum_old(iv,is1,is2) + 
                                             extsum_this(iv,is1,is2) );
                } }
              scalar_tau[iv] += ppath.lstep[ip-1] * ext_mat(0,0); 
              extmat_case[ip-1][iv] = 0;
              ext2trans( trans_partial(iv,joker,joker,ip-1), 
                         extmat_case[ip-1][iv], ext_mat, ppath.lstep[ip-1] );

              // Note that multiplication below depends on ppath loop order
              mult( trans_cumulat(iv,joker,joker,ip), 
                    trans_cumulat(iv,joker,joker,ip-1), 
                    trans_partial(iv,joker,joker,ip-1) );
            }
        }

      extsum_old = extsum_this;
    }
}



//! get_rowindex_for_mblock
/*!
    Returns the "range" of *y* corresponding to a measurement block

    \return  The range.
    \param   sensor_response    As the WSV.
    \param   mblock_index            Index of the measurement block.

    \author Patrick Eriksson 
    \date   2009-10-16
*/
Range get_rowindex_for_mblock( 
  const Sparse&   sensor_response, 
  const Index&    mblock_index )
{
  const Index   n1y = sensor_response.nrows();
  return Range( n1y*mblock_index, n1y );
}


void iyb_calc_za_loop_body(
        bool&                       failed,
        String&                     fail_msg,
        ArrayOfArrayOfTensor4&      iy_aux_array,
        Workspace&                  ws,
        Vector&                     iyb,
        ArrayOfMatrix&              diyb_dx,
  const Index&                      mblock_index,
  const Index&                      atmosphere_dim,
  ConstTensor3View                  t_field,
  ConstTensor3View                  z_field,
  ConstTensor4View                  vmr_field,
  const Index&                      cloudbox_on,
  const Index&                      stokes_dim,
  ConstVectorView                   f_grid,
  ConstMatrixView                   sensor_pos,
  ConstMatrixView                   sensor_los,
  ConstMatrixView                   transmitter_pos,
  ConstVectorView                   mblock_za_grid,
  ConstVectorView                   mblock_aa_grid,
  const Index&                      antenna_dim,
  const Agenda&                     iy_main_agenda,
  const Index&                      j_analytical_do,
  const ArrayOfRetrievalQuantity&   jacobian_quantities,
  const ArrayOfArrayOfIndex&        jacobian_indices,
  const ArrayOfString&              iy_aux_vars,
  const Index&                      naa,
  const Index&                      iza,
  const Index&                      nf)
{
    // The try block here is necessary to correctly handle
    // exceptions inside the parallel region.
    try
    {
        for( Index iaa=0; iaa<naa; iaa++ )
        {
            //--- LOS of interest
            //
            Vector los( sensor_los.ncols() );
            //
            los     = sensor_los( mblock_index, joker );
            los[0] += mblock_za_grid[iza];
            //
            if( antenna_dim == 2 )  // map_daa handles also "adjustment"
            { map_daa( los[0], los[1], los[0], los[1],
                      mblock_aa_grid[iaa] ); }
            else
            { adjust_los( los, atmosphere_dim ); }

            //--- rtp_pos 1 and 2
            //
            Vector rtp_pos, rtp_pos2(0);
            //
            rtp_pos = sensor_pos( mblock_index, joker );
            if( transmitter_pos.nrows() )
            { rtp_pos2 = transmitter_pos( mblock_index, joker ); }

            // Calculate iy and associated variables
            //
            Matrix         iy;
            ArrayOfTensor3 diy_dx;
            Ppath          ppath;
            Tensor3        iy_transmission(0,0,0);
            Index          iang = iza*naa + iaa;
            //
            iy_main_agendaExecute(ws, iy, iy_aux_array[iang], ppath,
                                  diy_dx, 1, iy_transmission, iy_aux_vars,
                                  cloudbox_on, j_analytical_do, t_field,
                                  z_field, vmr_field, f_grid, rtp_pos, los,
                                  rtp_pos2, iy_main_agenda );

            // Check that aux data can be handled and has correct size
            for( Index q=0; q<iy_aux_array[iang].nelem(); q++ )
            {
                if( iy_aux_array[iang][q].ncols() != 1  ||
                   iy_aux_array[iang][q].nrows() != 1 )
                {
                    throw runtime_error( "For calculations using yCalc, "
                                        "*iy_aux_vars* can not include\nvariables of "
                                        "along-the-path or extinction matrix type.");
                }
                assert( iy_aux_array[iang][q].npages() == 1  ||
                       iy_aux_array[iang][q].npages() == stokes_dim );
                assert( iy_aux_array[iang][q].nbooks() == 1  ||
                       iy_aux_array[iang][q].nbooks() == nf  );
            }

            // Start row in iyb etc. for present LOS
            //
            const Index row0 = iang * nf * stokes_dim;

            // Jacobian part
            //
            if( j_analytical_do )
            {
                FOR_ANALYTICAL_JACOBIANS_DO(
                                            for( Index ip=0; ip<jacobian_indices[iq][1] -
                                                jacobian_indices[iq][0]+1; ip++ )
                                            {
                                                for( Index is=0; is<stokes_dim; is++ )
                                                {
                                                    diyb_dx[iq](Range(row0+is,nf,stokes_dim),ip)=
                                                    diy_dx[iq](ip,joker,is);
                                                }
                                            }
                                            )
            }

            // iy : copy to iyb
            for( Index is=0; is<stokes_dim; is++ )
            { iyb[Range(row0+is,nf,stokes_dim)] = iy(joker,is); }

        }  // End aa loop
    }  // End try

    catch (runtime_error e)
    {
#pragma omp critical (iyb_calc_fail)
        { fail_msg = e.what(); failed = true; }
    }
}


//! iyb_calc
/*!
    Calculation of pencil beam monochromatic spectra for 1 measurement block.

    All in- and output variables as the WSV with the same name.

    \author Patrick Eriksson 
    \date   2009-10-16
*/
void iyb_calc(
        Workspace&                  ws,
        Vector&                     iyb,
        ArrayOfVector&              iyb_aux,
        ArrayOfMatrix&              diyb_dx,
  const Index&                      mblock_index,
  const Index&                      atmosphere_dim,
  ConstTensor3View                  t_field,
  ConstTensor3View                  z_field,
  ConstTensor4View                  vmr_field,
  const Index&                      cloudbox_on,
  const Index&                      stokes_dim,
  ConstVectorView                   f_grid,
  ConstMatrixView                   sensor_pos,
  ConstMatrixView                   sensor_los,
  ConstMatrixView                   transmitter_pos,
  ConstVectorView                   mblock_za_grid,
  ConstVectorView                   mblock_aa_grid,
  const Index&                      antenna_dim,
  const Agenda&                     iy_main_agenda,
  const Index&                      j_analytical_do,
  const ArrayOfRetrievalQuantity&   jacobian_quantities,
  const ArrayOfArrayOfIndex&        jacobian_indices,
  const ArrayOfString&              iy_aux_vars,
  const Verbosity&                  verbosity)
{
  CREATE_OUT3;

  // Sizes
  const Index   nf   = f_grid.nelem();
  const Index   nza  = mblock_za_grid.nelem();
        Index   naa  = mblock_aa_grid.nelem();   
  if( antenna_dim == 1 )  
    { naa = 1; }
  const Index   niyb = nf * nza * naa * stokes_dim;
  // Set up size of containers for data of 1 measurement block.
  // (can not be made below due to parallalisation)
  iyb.resize( niyb );
  //
  if( j_analytical_do )
    {
      diyb_dx.resize( jacobian_indices.nelem() );
      FOR_ANALYTICAL_JACOBIANS_DO(
        diyb_dx[iq].resize( niyb, jacobian_indices[iq][1] -
                                  jacobian_indices[iq][0] + 1 );
      )
    }
  else
    { diyb_dx.resize( 0 ); }

  // For iy_aux we don't know the number of quantities, and we have to store
  // all outout
  ArrayOfArrayOfTensor4  iy_aux_array( nza*naa );

  // We have to make a local copy of the Workspace and the agendas because
  // only non-reference types can be declared firstprivate in OpenMP
  Workspace l_ws (ws);
  Agenda l_iy_main_agenda (iy_main_agenda);

  String fail_msg;
  bool failed = false;
  if (nza >= arts_omp_get_max_threads() || nza*10 >= nf)
  {
      out3 << "  Parallelizing za loop (" << nza << " iterations, "
      << nf << " frequencies)\n";

      // Start of actual calculations
#pragma omp parallel for                   \
if (!arts_omp_in_parallel()) \
firstprivate(l_ws, l_iy_main_agenda)
      for( Index iza=0; iza<nza; iza++ )
      {
          // Skip remaining iterations if an error occurred
          if (failed) continue;

          iyb_calc_za_loop_body(failed,
                                fail_msg,
                                iy_aux_array,
                                l_ws,
                                iyb,
                                diyb_dx,
                                mblock_index,
                                atmosphere_dim,
                                t_field,
                                z_field,
                                vmr_field,
                                cloudbox_on,
                                stokes_dim,
                                f_grid,
                                sensor_pos,
                                sensor_los,
                                transmitter_pos,
                                mblock_za_grid,
                                mblock_aa_grid,
                                antenna_dim,
                                l_iy_main_agenda,
                                j_analytical_do,
                                jacobian_quantities,
                                jacobian_indices,
                                iy_aux_vars,
                                naa,
                                iza,
                                nf);

      }  // End za loop
  }
  else
  {
      out3 << "  Not parallelizing za loop (" << nza << " iterations, "
      << nf << " frequencies)\n";

      for( Index iza=0; iza<nza; iza++ )
      {
          // Skip remaining iterations if an error occurred
          if (failed) continue;

          iyb_calc_za_loop_body(failed,
                                fail_msg,
                                iy_aux_array,
                                ws,
                                iyb,
                                diyb_dx,
                                mblock_index,
                                atmosphere_dim,
                                t_field,
                                z_field,
                                vmr_field,
                                cloudbox_on,
                                stokes_dim,
                                f_grid,
                                sensor_pos,
                                sensor_los,
                                transmitter_pos,
                                mblock_za_grid,
                                mblock_aa_grid,
                                antenna_dim,
                                iy_main_agenda,
                                j_analytical_do,
                                jacobian_quantities,
                                jacobian_indices,
                                iy_aux_vars,
                                naa,
                                iza,
                                nf);

      }  // End za loop
  }

  if( failed )
    throw runtime_error("Run-time error in function: iyb_calc\n" + fail_msg);

  // Compile iyb_aux
  //
  const Index nq = iy_aux_array[0].nelem();
  iyb_aux.resize( nq );
  //
  for( Index q=0; q<nq; q++ )
    {
      iyb_aux[q].resize( niyb );
      //
      for( Index iza=0; iza<nza; iza++ )
        {
          for( Index iaa=0; iaa<naa; iaa++ )
            {
              const Index iang = iza*naa + iaa;
              const Index row0 = iang * nf * stokes_dim;
              for( Index iv=0; iv<nf; iv++ )
                { 
                  const Index row1 = row0 + iv*stokes_dim;
                  const Index i1 = min( iv, iy_aux_array[iang][q].nbooks()-1 );
                  for( Index is=0; is<stokes_dim; is++ )
                    { 
                      Index i2 = min( is, iy_aux_array[iang][q].npages()-1 );
                      iyb_aux[q][row1+is] = iy_aux_array[iang][q](i1,i2,0,0);
                    }
                }
            }
        }
    }
}



//! iy_transmission_mult
/*!
    Multiplicates iy_transmission with (vector) transmissions.

    That is, a multiplication of *iy_transmission* with another
    variable having same structure and holding transmission values.

    The "new path" is assumed to be further away from the sensor than 
    the propagtion path already included in iy_transmission. That is,
    the operation can be written as:
    
       Ttotal = Told * Tnew

    where Told is the transmission corresponding to *iy_transmission*
    and Tnew corresponds to *tau*.

    *iy_trans_new* is sized by the function.

    \param   iy_trans_total    Out: Updated version of *iy_transmission*
    \param   iy_trans_old      A variable matching *iy_transmission.
    \param   iy_trans_new      A variable matching *iy_transmission.

    \author Patrick Eriksson 
    \date   2009-10-06
*/
void iy_transmission_mult( 
       Tensor3&      iy_trans_total,
  ConstTensor3View   iy_trans_old,
  ConstTensor3View   iy_trans_new )
{
  const Index nf = iy_trans_old.npages();
  const Index ns = iy_trans_old.ncols();

  assert( ns == iy_trans_old.nrows() );
  assert( nf == iy_trans_new.npages() );
  assert( ns == iy_trans_new.nrows() );
  assert( ns == iy_trans_new.ncols() );

  iy_trans_total.resize( nf, ns, ns );

  for( Index iv=0; iv<nf; iv++ )
    {
      mult( iy_trans_total(iv,joker,joker), iy_trans_old(iv,joker,joker),
                                            iy_trans_new(iv,joker,joker) );
    } 
}



//! iy_transmission_mult_scalar_tau
//! los3d
/*!
    Converts any LOS vector to the implied 3D LOS vector.

    The output argument, *los3d*, is a vector with length 2, with azimuth angle
    set and zenith angle always >= 0. 

    \param   los3d             Out: The line-of-sight in 3D
    \param   los               A line-of-sight
    \param   atmosphere_dim    As the WSV.

    \author Patrick Eriksson 
    \date   2012-07-10
*/
void los3d(
        Vector&     los3d,
  ConstVectorView   los, 
  const Index&      atmosphere_dim )
{
  los3d.resize(2);
  //
  los3d[0] = abs( los[0] ); 
  //
  if( atmosphere_dim == 1 )
    { los3d[1] = 0; }
  else if( atmosphere_dim == 2 )
    {
      if( los[0] >= 0 )
        { los3d[1] = 0; }
      else
        { los3d[1] = 180; }
    }
  else if( atmosphere_dim == 3 )
    { los3d[1] = los[1]; }
}    



//! mirror_los
/*!
    Determines the backward direction for a given line-of-sight.

    This function can be used to get the LOS to apply for extracting single
    scattering properties, if the propagation path LOS is given.

    A viewing direction of aa=0 is assumed for 1D. This corresponds to 
    positive za for 2D.

    \param   los_mirrored      Out: The line-of-sight for reversed direction.
    \param   los               A line-of-sight
    \param   atmosphere_dim    As the WSV.

    \author Patrick Eriksson 
    \date   2011-07-15
*/
void mirror_los(
        Vector&     los_mirrored,
  ConstVectorView   los, 
  const Index&      atmosphere_dim )
{
  los_mirrored.resize(2);
  //
  if( atmosphere_dim == 1 )
    { 
      los_mirrored[0] = 180 - los[0]; 
      los_mirrored[1] = 180; 
    }
  else if( atmosphere_dim == 2 )
    {
      los_mirrored[0] = 180 - fabs( los[0] ); 
      if( los[0] >= 0 )
        { los_mirrored[1] = 180; }
      else
        { los_mirrored[1] = 0; }
    }
  else if( atmosphere_dim == 3 )
    { 
      los_mirrored[0] = 180 - los[0]; 
      los_mirrored[1] = los[1] + 180; 
      if( los_mirrored[1] > 180 )
        { los_mirrored[1] -= 360; }
    }
}    



//! pos2true_latlon
/*!
    Determines the true alt and lon for an "ARTS position"

    The function disentangles if the geographical position shall be taken from
    lat_grid and lon_grid, or lat_true and lon_true.

    \param   lat              Out: True latitude.
    \param   lon              Out: True longitude.
    \param   atmosphere_dim   As the WSV.
    \param   lat_grid         As the WSV.
    \param   lat_true         As the WSV.
    \param   lon_true         As the WSV.
    \param   pos              A position, as defined for rt calculations.

    \author Patrick Eriksson 
    \date   2011-07-15
*/
void pos2true_latlon( 
          Numeric&     lat,
          Numeric&     lon,
    const Index&       atmosphere_dim,
    ConstVectorView    lat_grid,
    ConstVectorView    lat_true,
    ConstVectorView    lon_true,
    ConstVectorView    pos )
{
  assert( pos.nelem() == atmosphere_dim );

  if( atmosphere_dim == 1 )
    {
      assert( lat_true.nelem() == 1 );
      assert( lon_true.nelem() == 1 );
      //
      lat = lat_true[0];
      lon = lon_true[0];
    }

  else if( atmosphere_dim == 2 )
    {
      assert( lat_true.nelem() == lat_grid.nelem() );
      assert( lon_true.nelem() == lat_grid.nelem() );
      GridPos   gp;
      Vector    itw(2);
      gridpos( gp, lat_grid, pos[1] );
      interpweights( itw, gp );
      lat = interp( itw, lat_true, gp );
      lon = interp( itw, lon_true, gp );
    }

  else 
    {
      lat = pos[1];
      lon = pos[2];
    }
}


//! surface_calc
/*!
    Weights together downwelling radiation and surface emission.

    *iy* must have correct size when function is called.

    \param   iy                 In/Out: Radiation matrix, amtching 
                                        the WSV with the same name.
    \param   I                  Input: Downwelling radiation, with dimensions
                                       matching: 
                                       (surface_los, f_grid, stokes_dim)
    \param   surface_los        Input: As the WSV with the same name.
    \param   surface_rmatrix    Input: As the WSV with the same name.
    \param   surface_emission   Input: As the WSV with the same name.

    \author Patrick Eriksson 
    \date   2005-04-07
*/
void surface_calc(
              Matrix&         iy,
        ConstTensor3View      I,
        ConstMatrixView       surface_los,
        ConstTensor4View      surface_rmatrix,
        ConstMatrixView       surface_emission )
{
  // Some sizes
  const Index   nf         = I.nrows();
  const Index   stokes_dim = I.ncols();
  const Index   nlos       = surface_los.nrows();

  iy = surface_emission;
  
  // Loop *surface_los*-es. If no such LOS, we are ready.
  if( nlos > 0 )
    {
      for( Index ilos=0; ilos<nlos; ilos++ )
        {
          Vector rtmp(stokes_dim);  // Reflected Stokes vector for 1 frequency

          for( Index iv=0; iv<nf; iv++ )
            {
          mult( rtmp, surface_rmatrix(ilos,iv,joker,joker), I(ilos,iv,joker) );
          iy(iv,joker) += rtmp;
            }
        }
    }
}



//! vectorfield2los
/*!
    Calculates the size and direction of a vector field defined as u, v and w
    components.

    \param   l      Size/magnitude of the vector.
    \param   los    Out: The direction, as a LOS vector
    \param   u      Zonal component of the vector field
    \param   v      N-S component of the vector field
    \param   w      Vertical component of the vector field

    \author Patrick Eriksson 
    \date   2012-07-10
*/
void vectorfield2los(
        Numeric&    l,
        Vector&     los,
  const Numeric&    u,
  const Numeric&    v,
  const Numeric&    w )
{
  l= sqrt( u*u + v*v + w*w );
  //
  los.resize(2);
  //
  los[0] = acos( w / l );
  los[1] = atan2( u, v );   
}    



