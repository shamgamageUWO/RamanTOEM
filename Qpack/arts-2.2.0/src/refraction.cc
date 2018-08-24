/* Copyright (C) 2002-2012 Patrick Eriksson <patrick.eriksson@chalmers.se>

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
  \file   refraction.cc
  \author Patrick Eriksson <Patrick.Eriksson@chalmers.se>
  \date   2003-01-17
  
  \brief  Functions releated to calculation of refractive index.
*/



/*===========================================================================
  === External declarations
  ===========================================================================*/

#include <cmath>
#include "auto_md.h"
#include "complex.h"          
#include "interpolation.h"
#include "geodetic.h"
#include "refraction.h"
#include "special_interp.h"

extern const Numeric DEG2RAD;
extern const Numeric RAD2DEG;
extern const Numeric TEMP_0_C;



/*===========================================================================
  === The functions (in alphabetical order)
  ===========================================================================*/


//! complex_n_water_liebe93
/*! 
  Complex refractive index of liquid water according to Liebe 1993.

  The method treats liquid water without salt. Thus, not valid below 10 GHz.
  Upper frequency limit not known, here set to 1000 GHz. Model parameters taken
  from Atmlab function epswater93 (by C. Maetzler), which refer to Liebe 1993
  without closer specifications.
 
  Temperature must be between 0 and 100 degrees Celsius.

  The output matrix has two columns, where column 0 is real part and column 1
  is imaginary part. And rows matches f_grid.
   
   \param   complex_n   Out: Complex refractive index.        
   \param   f_grid      As the WSV with the same name.
   \param   t           Temperature

   \author Patrick Eriksson
   \date   2003-08-15
*/
void complex_n_water_liebe93(
         Matrix&   complex_n,
   const Vector&   f_grid,
   const Numeric&  t )
{
  chk_if_in_range( "t", t, TEMP_0_C-40, TEMP_0_C+100 );
  chk_if_in_range( "min of f_grid", min(f_grid), 10e9, 1000e9 );
  chk_if_in_range( "max of f_grid", max(f_grid), 10e9, 1000e9 );

  const Index   nf = f_grid.nelem();

  complex_n.resize( nf, 2 );

  // Implementation following epswater93.m (by C. Mätzler), part of Atmlab,
  // but numeric values strictly following the paper version (146, not 146.4)
  const Numeric   theta = 1 - 300 / t;
  const Numeric   e0    = 77.66 - 103.3 * theta;
  const Numeric   e1    = 0.0671 * e0;
  const Numeric   f1    = 20.2 + 146 * theta + 316 * theta * theta;
  const Numeric   e2    = 3.52;  
  const Numeric   f2    = 39.8 * f1;

  for( Index iv=0; iv<nf; iv++ )
    { 
      const Complex  ifGHz( 0.0, f_grid[iv]/1e9 );
          
      Complex n = sqrt( e2 + (e1-e2) / (Numeric(1.0)-ifGHz/f2) + 
                             (e0-e1) / (Numeric(1.0)-ifGHz/f1) );
    
      complex_n(iv,0) = n.real();
      complex_n(iv,1) = n.imag();
    }
}



//! get_refr_index_1d
/*! 
   Extracts the refractive index for 1D cases.

   The function interpolates the atmospheric pressure and fields, and
   calls *refr_index_air_agenda* to determine the refractive index for the
   given point.

   The atmosphere is given by its 1D view. That is, the latitude and
   longitude dimensions are removed from the atmospheric fields. For
   example, the temperature is given as a vector (the vertical profile).

   \param   ws                  Current Workspace
   \param   refr_index_air          Output: As the WSV with the same name.
   \param   refr_index_air_group    Output: As the WSV with the same name.
   \param   refr_index_air_agenda   As the WSV with the same name.
   \param   p_grid              As the WSV with the same name.   
   \param   refellipsoid        As the WSV with the same name.
   \param   z_field             As the WSV with the same name.
   \param   t_field             As the WSV with the same name.
   \param   vmr_field           As the WSV with the same name.
   \param   f_grid              As the WSV with the same name.
   \param   r                   The radius of the position of interest.

   \author Patrick Eriksson
   \date   2003-01-16
*/
void get_refr_index_1d(
          Workspace&  ws,
          Numeric&    refr_index_air,
          Numeric&    refr_index_air_group,
    const Agenda&     refr_index_air_agenda,
    ConstVectorView   p_grid,
    ConstVectorView   refellipsoid,
    ConstTensor3View  z_field,
    ConstTensor3View  t_field,
    ConstTensor4View  vmr_field,
    ConstVectorView   f_grid,
    const Numeric&    r )
{ 
  Numeric   rtp_pressure, rtp_temperature;
  Vector    rtp_vmr;

  // Pressure grid position
  ArrayOfGridPos   gp(1);
  gridpos( gp, z_field(joker,0,0), Vector( 1, r - refellipsoid[0] ) );

  // Altitude interpolation weights
  Matrix   itw(1,2);
  interpweights( itw, gp );

  // Pressure
  Vector   dummy(1);
  itw2p( dummy, p_grid, gp, itw );
  rtp_pressure = dummy[0];

  // Temperature
  interp( dummy, itw, t_field(joker,0,0), gp );
  rtp_temperature = dummy[0];

  // VMR
  const Index   ns = vmr_field.nbooks();
  //
  rtp_vmr.resize(ns);
  //
  for( Index is=0; is<ns; is++ )
    {
      interp( dummy, itw, vmr_field(is,joker,0,0), gp );
      rtp_vmr[is] = dummy[0];
    }

  refr_index_air_agendaExecute( ws, refr_index_air, refr_index_air_group, 
                            rtp_pressure, rtp_temperature, rtp_vmr, 
                            f_grid, refr_index_air_agenda );
}



//! get_refr_index_2d
/*! 
   Extracts the refractive index for 2D cases.

   The function interpolates the atmospheric pressure and fields, and
   calls *refr_index_air_agenda* to determine the refractive index for the
   given point.

   The atmosphere is given by its 2D view. That is, the longitude
   dimension is removed from the atmospheric fields. For example,
   the temperature is given as a matrix.

   \param   ws                      Current Workspace
   \param   refr_index_air          Output: As the WSV with the same name.
   \param   refr_index_air_group    Output: As the WSV with the same name.
   \param   refr_index_air_agenda   As the WSV with the same name.
   \param   p_grid                  As the WSV with the same name.
   \param   lat_grid                As the WSV with the same name.
   \param   refellipsoid            As the WSV with the same name.
   \param   z_field                 As the WSV with the same name.
   \param   t_field                 As the WSV with the same name.
   \param   vmr_field               As the WSV with the same name.
   \param   f_grid                  As the WSV with the same name.
   \param   r                       The radius of the position of interest.
   \param   lat                     The latitude of the position of interest.

   \author Patrick Eriksson
   \date   2003-01-14
*/
void get_refr_index_2d(
          Workspace&  ws,
          Numeric&    refr_index_air,
          Numeric&    refr_index_air_group,
    const Agenda&     refr_index_air_agenda,
    ConstVectorView   p_grid,
    ConstVectorView   lat_grid,
    ConstVectorView   refellipsoid,
    ConstTensor3View  z_field,
    ConstTensor3View  t_field,
    ConstTensor4View  vmr_field,
    ConstVectorView   f_grid,
    const Numeric&    r,
    const Numeric&    lat )
{ 
  Numeric   rtp_pressure, rtp_temperature;
  Vector    rtp_vmr;

  // Determine the geometric altitudes at *lat*
  const Index      np = p_grid.nelem();
  Vector           z_grid(np);
  ArrayOfGridPos   gp_lat(1);
  //
  gridpos( gp_lat, lat_grid, lat );
  z_at_lat_2d( z_grid, p_grid, lat_grid, z_field(joker,joker,0), gp_lat[0] );

  // Determine the ellipsoid radius at *lat*
  const Numeric   rellips = refell2d( refellipsoid, lat_grid, gp_lat[0] );

  // Altitude (equal to pressure) grid position
  ArrayOfGridPos   gp_p(1);
  gridpos( gp_p, z_grid, Vector( 1, r - rellips ) );

  // Altitude interpolation weights
  Matrix   itw(1,2);
  Vector   dummy(1);
  interpweights( itw, gp_p );

  // Pressure
  itw2p( dummy, p_grid, gp_p, itw );
  rtp_pressure = dummy[0];

  // Temperature
  itw.resize(1,4);
  interpweights( itw, gp_p, gp_lat );
  interp( dummy, itw, t_field(joker,joker,0), gp_p, gp_lat );
  rtp_temperature = dummy[0];

  // VMR
  const Index   ns = vmr_field.nbooks();
  //
  rtp_vmr.resize(ns);
  //
  for( Index is=0; is<ns; is++ )
    {
      interp( dummy, itw, vmr_field(is,joker,joker,0), gp_p, gp_lat );
      rtp_vmr[is] = dummy[0];
    }


  refr_index_air_agendaExecute( ws, refr_index_air, refr_index_air_group, 
                            rtp_pressure, rtp_temperature, rtp_vmr, 
                            f_grid, refr_index_air_agenda );
}



/*! get_refr_index_3d

   Extracts the refractive index for 3D cases.

   The function interpolates the atmospheric pressure and fields, and
   calls *refr_index_air_agenda* to determine the refractive index for the
   given point.

   \param   ws                      Current Workspace
   \param   refr_index_air          Output: As the WSV with the same name.
   \param   refr_index_air_group    Output: As the WSV with the same name.
   \param   refr_index_air_agenda   As the WSV with the same name.
   \param   p_grid                  As the WSV with the same name.
   \param   lat_grid                As the WSV with the same name.
   \param   lon_grid                As the WSV with the same name.
   \param   refellipsoid            As the WSV with the same name.
   \param   z_field                 As the WSV with the same name.
   \param   t_field                 As the WSV with the same name.
   \param   vmr_field               As the WSV with the same name.
   \param   f_grid                  As the WSV with the same name.
   \param   r                       The radius of the position of interest.
   \param   lat                     The latitude of the position of interest.
   \param   lon                     The longitude of the position of interest.

   \author Patrick Eriksson
   \date   2003-01-17
*/
void get_refr_index_3d(
          Workspace&  ws,
          Numeric&    refr_index_air,
          Numeric&    refr_index_air_group,
    const Agenda&     refr_index_air_agenda,
    ConstVectorView   p_grid,
    ConstVectorView   lat_grid,
    ConstVectorView   lon_grid,
    ConstVectorView   refellipsoid,
    ConstTensor3View  z_field,
    ConstTensor3View  t_field,
    ConstTensor4View  vmr_field,
    ConstVectorView   f_grid,
    const Numeric&    r,
    const Numeric&    lat,
    const Numeric&    lon )
{ 
  Numeric   rtp_pressure, rtp_temperature;
  Vector    rtp_vmr;

  // Determine the geometric altitudes at *lat* and *lon*
  const Index      np = p_grid.nelem();
  Vector           z_grid(np);
  ArrayOfGridPos   gp_lat(1), gp_lon(1);
  //
  gridpos( gp_lat, lat_grid, lat );
  gridpos( gp_lon, lon_grid, lon );
  z_at_latlon( z_grid, p_grid, lat_grid, lon_grid, z_field, 
                                                        gp_lat[0], gp_lon[0] );
  
  // Determine the elipsoid radius at *lat*
  const Numeric   rellips = refell2d( refellipsoid, lat_grid, gp_lat[0] );

  // Altitude (equal to pressure) grid position
  ArrayOfGridPos   gp_p(1);
  gridpos( gp_p, z_grid, Vector( 1, r - rellips ) );

  // Altitude interpolation weights
  Matrix   itw(1,2);
  Vector   dummy(1);
  interpweights( itw, gp_p );

  // Pressure
  itw2p( dummy, p_grid, gp_p, itw );
  rtp_pressure = dummy[0];

  // Temperature
  itw.resize(1,8);
  interpweights( itw, gp_p, gp_lat, gp_lon );
  interp( dummy, itw, t_field, gp_p, gp_lat, gp_lon );
  rtp_temperature = dummy[0];

  // VMR
  const Index   ns = vmr_field.nbooks();
  //
  rtp_vmr.resize(ns);
  //
  for( Index is=0; is<ns; is++ )
    {
      interp( dummy, itw, vmr_field(is,joker,joker,joker), gp_p, gp_lat, 
                                                                      gp_lon );
      rtp_vmr[is] = dummy[0];
    }

  refr_index_air_agendaExecute( ws, refr_index_air, refr_index_air_group, 
                            rtp_pressure, rtp_temperature, rtp_vmr, 
                            f_grid, refr_index_air_agenda );
}



//! refr_gradients_1d
/*! 
   Determines the refractive index, and its gradients, for the given position.

   The gradients are calculated in pure numerical way. That is, the
   refractive index is calculated for slightly shifted radius or
   latitude and the difference to the refractive index at the given
   point determines the gradient.

   \param   ws                    Current Workspace
   \param   refr_index_air        Output: As the WSV with the same name.
   \param   refr_index_air_group  Output: As the WSV with the same name.
   \param   dndr                  Output: Radial gradient of refractive index.
   \param   refr_index_air_agenda As the WSV with the same name.
   \param   p_grid                As the WSV with the same name.
   \param   refellipsoid          As the WSV with the same name.
   \param   z_field               As the WSV with the same name.
   \param   t_field               As the WSV with the same name.
   \param   vmr_field             As the WSV with the same name.
   \param   f_grid                As the WSV with the same name.
   \param   r                     The radius of the position of interest.
   \param   lat                   The latitude of the position of interest.

   \author Patrick Eriksson
   \date   2003-01-14
*/
void refr_gradients_1d(
          Workspace&  ws,
          Numeric&    refr_index_air,
          Numeric&    refr_index_air_group,
          Numeric&    dndr,
    const Agenda&     refr_index_air_agenda,
    ConstVectorView   p_grid,
    ConstVectorView   refellipsoid,
    ConstTensor3View  z_field,
    ConstTensor3View  t_field,
    ConstTensor4View  vmr_field,
    ConstVectorView   f_grid,
    const Numeric&    r )
{ 
  get_refr_index_1d( ws, refr_index_air, refr_index_air_group, 
                     refr_index_air_agenda, p_grid, refellipsoid, 
                     z_field, t_field, vmr_field, f_grid, r );

  const Numeric   n0 = refr_index_air;
        Numeric   dummy;

  get_refr_index_1d( ws, refr_index_air, dummy, 
                     refr_index_air_agenda, p_grid, refellipsoid, 
                     z_field, t_field, vmr_field, f_grid, r+1 );

  dndr = refr_index_air - n0;

  refr_index_air = n0;
}



//! refr_gradients_2d
/*! 
   Determines the refractive index, and its gradients, for the given position.

   The gradients are calculated in pure numerical way. That is, the
   refractive index is calculated for slightly shifted radius or
   latitude and the difference to the refractive index at the given
   point determines the gradient.

   The latitude gradient is scaled with the radius to obtain the same
   unit ([1/m]) for both gradients. That is, the returned value is the
   change of the refractive index for a movement of 1m in the latitude
   direction.

   \param   ws                    Current Workspace
   \param   refr_index_air        Output: As the WSV with the same name.
   \param   refr_index_air_group  Output: As the WSV with the same name.
   \param   dndr                  Output: Radial gradient of refractive index.
   \param   dndlat                Output: Latitude gradient of refractive index.
   \param   refr_index_air_agenda As the WSV with the same name.
   \param   p_grid                As the WSV with the same name.
   \param   lat_grid              As the WSV with the same name.
   \param   refellipsoid          As the WSV with the same name.
   \param   z_field               As the WSV with the same name.
   \param   t_field               As the WSV with the same name.
   \param   vmr_field             As the WSV with the same name.
   \param   f_grid                As the WSV with the same name.
   \param   r                     The radius of the position of interest.
   \param   lat                   The latitude of the position of interest.

   \author Patrick Eriksson
   \date   2003-01-14
*/
void refr_gradients_2d(
          Workspace&  ws,
          Numeric&    refr_index_air,
          Numeric&    refr_index_air_group,
          Numeric&    dndr,
          Numeric&    dndlat,
    const Agenda&     refr_index_air_agenda,
    ConstVectorView   p_grid,
    ConstVectorView   lat_grid,
    ConstVectorView   refellipsoid,
    ConstTensor3View  z_field,
    ConstTensor3View  t_field,
    ConstTensor4View  vmr_field,
    ConstVectorView   f_grid,
    const Numeric&    r,
    const Numeric&    lat )
{ 
  get_refr_index_2d( ws, refr_index_air, refr_index_air_group, 
                     refr_index_air_agenda, p_grid, lat_grid, refellipsoid, 
                     z_field, t_field, vmr_field, f_grid, r, lat );

  const Numeric   n0 = refr_index_air;
        Numeric   dummy;

  get_refr_index_2d( ws, refr_index_air, dummy, refr_index_air_agenda, p_grid, 
                     lat_grid, refellipsoid, z_field, t_field, vmr_field, 
                     f_grid, r+1, lat );

  dndr = refr_index_air - n0;

  const Numeric   dlat = 1e-4;

  get_refr_index_2d( ws, refr_index_air, dummy, refr_index_air_agenda, p_grid, 
                     lat_grid, refellipsoid, z_field, t_field, vmr_field, 
                     f_grid, r, lat+dlat );

  dndlat = ( refr_index_air - n0 ) / ( DEG2RAD * dlat * r ); 

  refr_index_air = n0;
}



//! refr_gradients_3d
/*! 
   Determines the refractive index, and its gradients, for the given position.

   The gradients are calculated in pure numerical way. That is, the
   refractive index is calculated for slightly shifted radius,
   latitude or longitude and the difference to the refractive index at
   the given point determines the gradient.

   The latitude and longitude gradients are scaled with the
   (effective) radius to obtain the same unit ([1/m]) for all
   gradients. That is, the returned values are the change of the
   refractive index for a movement of 1m in the latitude or longitude
   direction.

   \param   ws                   Current Workspace
   \param   refr_index_air       Output: As the WSV with the same name.
   \param   refr_index_air_group Output: As the WSV with the same name.
   \param   dndr                 Output: Radial gradient of refractive index.
   \param   dndlat               Output: Latitude gradient of refractive index.
   \param   dndlon               Output: Longitude gradient of refractive index.
   \param   refr_index_air_agenda As the WSV with the same name.
   \param   p_grid               As the WSV with the same name.
   \param   lat_grid             As the WSV with the same name.
   \param   lon_grid             As the WSV with the same name.
   \param   refellipsoid         As the WSV with the same name.
   \param   z_field              As the WSV with the same name.
   \param   t_field              As the WSV with the same name.
   \param   vmr_field            As the WSV with the same name.
   \param   f_grid               As the WSV with the same name.
   \param   r                    The radius of the position of interest.
   \param   lat                  The latitude of the position of interest.
   \param   lon                  The longitude of the position of interest.

   \author Patrick Eriksson
   \date   2003-01-17
*/
void refr_gradients_3d(
          Workspace&  ws,
          Numeric&    refr_index_air,
          Numeric&    refr_index_air_group,
          Numeric&    dndr,
          Numeric&    dndlat,
          Numeric&    dndlon,
    const Agenda&     refr_index_air_agenda,
    ConstVectorView   p_grid,
    ConstVectorView   lat_grid,
    ConstVectorView   lon_grid,
    ConstVectorView   refellipsoid,
    ConstTensor3View  z_field,
    ConstTensor3View  t_field,
    ConstTensor4View  vmr_field,
    ConstVectorView   f_grid,
    const Numeric&    r,
    const Numeric&    lat,
    const Numeric&    lon )
{ 
  get_refr_index_3d( ws, refr_index_air, refr_index_air_group, 
                     refr_index_air_agenda, p_grid, lat_grid, lon_grid, 
                     refellipsoid, z_field, t_field, vmr_field, f_grid, 
                     r, lat, lon );

  const Numeric   n0 = refr_index_air;
        Numeric   dummy;

  get_refr_index_3d( ws, refr_index_air, dummy, refr_index_air_agenda, p_grid, 
                     lat_grid, lon_grid, refellipsoid, z_field, t_field, 
                     vmr_field, f_grid, r+1, lat, lon );

  dndr = refr_index_air - n0;

  const Numeric   dlat = 1e-4;

  get_refr_index_3d( ws, refr_index_air, dummy, refr_index_air_agenda, p_grid, 
                     lat_grid, lon_grid, refellipsoid, z_field, t_field, 
                     vmr_field, f_grid, r, lat+dlat, lon );

  dndlat = ( refr_index_air - n0 ) / ( DEG2RAD * dlat * r ); 

  const Numeric   dlon = 1e-4;

  get_refr_index_3d( ws, refr_index_air, dummy, refr_index_air_agenda, p_grid, 
                     lat_grid, lon_grid, refellipsoid, z_field, t_field, 
                     vmr_field, f_grid, r, lat, lon+dlon);

  dndlon = ( refr_index_air - n0 ) / 
           ( DEG2RAD * dlon * r * cos( DEG2RAD*lat ) ); 
  
  refr_index_air = n0;
}


