/* Copyright (C) 2012
   Patrick Eriksson <Patrick.Eriksson@chalmers.se>
                            
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
  \file   m_planets.cc
  \author Patrick Eriksson <Patrick.Eriksson@chalmers.se>
  \date   2012-03-16

  \brief  Planet specific workspace methods.

  These functions are listed in the doxygen documentation as entries of the
  file auto_md.h.
*/




/*===========================================================================
  === External declarations
  ===========================================================================*/

#include <cmath>
#include <stdexcept>
#include "arts.h"
#include "check_input.h"
#include "matpackI.h"
#include "messages.h"


extern const Numeric EARTH_RADIUS;
extern const Numeric DEG2RAD;


// Ref. 1:
// Seidelmann, P. Kenneth; Archinal, B. A.; A'hearn, M. F. et al (2007).
// "Report of the IAU/IAG Working Group on cartographic coordinates and
// rotational elements: 2006". Celestial Mechanics and Dynamical Astronomy 98
// (3): 155–180. Bibcode 2007CeMDA..98..155S. doi:10.1007/s10569-007-9072-y



/*===========================================================================
  === The functions (in alphabetical order)
  ===========================================================================*/

/* Workspace method: Doxygen documentation will be auto-generated */
void g0Earth(            
         Numeric&   g0,
   const Numeric&   lat,
   const Verbosity& )
{
  // "Small g" at altitude=0, g0:
  // Expression for g0 taken from Wikipedia page "Gravity of Earth", that
  // is stated to be: International Gravity Formula 1967, the 1967 Geodetic
  // Reference System Formula, Helmert's equation or Clairault's formula.

  const Numeric x = DEG2RAD * fabs( lat );

  g0 = 9.780327 * ( 1 + 5.3024e-3 * pow( sin(x),   2.0 ) + 
                           5.8e-6 * pow( sin(2*x), 2.0 ) );
}

/* Workspace method: Doxygen documentation will be auto-generated */
void g0Jupiter(            
         Numeric&   g0,
   const Verbosity& )
{
  // value from MPS, ESA-planetary
  g0 = 23.12;
  // value (1bar level) from http://nssdc.gsfc.nasa.gov/planetary/factsheet/jupiterfact.html
  // g0 = 24.79;
}

/* Workspace method: Doxygen documentation will be auto-generated */
void g0Mars(            
         Numeric&   g0,
   const Verbosity& )
{
  // value from MPS, ESA-planetary
  g0 = 3.690;
}

/* Workspace method: Doxygen documentation will be auto-generated */
void g0Venus(            
         Numeric&   g0,
   const Verbosity& )
{
  // value via MPS, ESA-planetary from Ahrens, 1995
  g0 = 8.870;
}



/* Workspace method: Doxygen documentation will be auto-generated */
void refellipsoidEarth(            
         Vector&    refellipsoid,
   const String&    model,
   const Verbosity& )
{
  refellipsoid.resize(2);

  if( model == "Sphere" )
    {
      refellipsoid[0] = EARTH_RADIUS;
      refellipsoid[1] = 0;
    }

  else if( model == "WGS84" )
    { // Values taken from atmlab's ellipsoidmodels.m
      refellipsoid[0] = 6378137; 
      refellipsoid[1] = 0.081819190842621;
    }

  else
    throw runtime_error( "Unknown selection for input argument *model*." );
}



/* Workspace method: Doxygen documentation will be auto-generated */
void refellipsoidJupiter(            
         Vector&    refellipsoid,
   const String&    model,
   const Verbosity& )
{
  refellipsoid.resize(2);

  if( model == "Sphere" )
    { 
      refellipsoid[0] = 69911e3;   // From Ref. 1 (see above)
      refellipsoid[1] = 0;
    }

  else if( model == "Ellipsoid" )
    {
      refellipsoid[0] = 71492e3;   // From Ref. 1
      refellipsoid[1] = 0.3543;    // Based on Ref. 1
    }

  else
    throw runtime_error( "Unknown selection for input argument *model*." );
}



/* Workspace method: Doxygen documentation will be auto-generated */
void refellipsoidMars(            
         Vector&    refellipsoid,
   const String&    model,
   const Verbosity& )
{
  refellipsoid.resize(2);

  if( model == "Sphere" )
    { 
      refellipsoid[0] = 3389.5e3;   // From Ref. 1 (see above)
      refellipsoid[1] = 0;
    }

  else if( model == "Ellipsoid" )
    {
      refellipsoid[0] = 3396.19e3;   // From Ref. 1
      refellipsoid[1] = 0.1083;      // Based on Ref. 1
    }

  else
    throw runtime_error( "Unknown selection for input argument *model*." );
}



/* Workspace method: Doxygen documentation will be auto-generated */
void refellipsoidMoon(            
         Vector&    refellipsoid,
   const String&    model,
   const Verbosity& )
{
  refellipsoid.resize(2);

  if( model == "Sphere" )
    { 
      refellipsoid[0] = 1737.4e3;  // From Ref. 1 (see above)
      refellipsoid[1] = 0;
    }

  else if( model == "Ellipsoid" )
    { // Values taken from Wikipedia, with reference to:
      // Williams, Dr. David R. (2 February 2006). "Moon Fact Sheet". 
      // NASA (National Space Science Data Center). Retrieved 31 December 2008.
      refellipsoid[0] = 1738.14e3; 
      refellipsoid[1] = 0.0500;
    }

  else
    throw runtime_error( "Unknown selection for input argument *model*." );
}



/* Workspace method: Doxygen documentation will be auto-generated */
void refellipsoidVenus(            
         Vector&    refellipsoid,
   const String&    model,
   const Verbosity& )
{
  refellipsoid.resize(2);

  if( model == "Sphere" )
    { 
      refellipsoid[0] = 6051.8e3;   // From Ref. 1 (see above)
      refellipsoid[1] = 0;
    }

  else
    throw runtime_error( "Unknown selection for input argument *model*." );
}
