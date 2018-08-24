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



/*****************************************************************************
 ***  File description 
 *****************************************************************************/

/*!
   \file   math_funcs.cc
   \author Patrick Eriksson <Patrick.Eriksson@chalmers.se>
   \date   2000-09-18 

   Contains basic mathematical functions.
*/



/*****************************************************************************
 *** External declarations
 *****************************************************************************/

#include <iostream>
#include <cmath>
#include <stdexcept>
#include "array.h"
#include "math_funcs.h"
#include "logic.h"
#include "mystring.h"
extern const Numeric DEG2RAD;
extern const Numeric PI;



/*****************************************************************************
 *** The functions (in alphabetical order)
 *****************************************************************************/

//! fac
/*!
    Calculates the factorial.

    The function asserts that n must be >= 0

    \return      The factorial
    \param   n   Nominator

    \author Oliver Lemke
    \date   2003-08-15
*/
Numeric fac(const Index n)
{
  Numeric sum;

  if (n == 0) return (1.0);

  sum = 1.0;
  for (Index i = 1; i <= n; i++)
    sum *= Numeric(i);

  return(sum);
}


//! integer_div
/*! 
    Performs an integer division.

    The function asserts that the reminder of the division x/y is 0.

    \return      The quotient
    \param   x   Nominator
    \param   y   Denominator

    \author Patrick Eriksson 
    \date   2002-08-11
*/
Index integer_div( const Index& x, const Index& y )
{
  assert( is_multiple( x, y ) );
  return x/y;
}



//! Lagrange Interpolation (internal function).
/*! 
  This function calculates the Lagrange interpolation of four interpolation 
  points as described in 
  <a href="http://mathworld.wolfram.com/LagrangeInterpolatingPolynomial.html">
  Lagrange Interpolating Polynomial</a>.<br>
  The input are the four x-axis values [x0,x1,x2,x3] and their associated 
  y-axis values [y0,y1,y2,y3]. Furthermore the x-axis point "a" at which the 
  interpolation should be calculated must be given as input. NOTE that 
  the relation x2 =< x < x3 MUST hold!

  \param x     x-vector with four elements [x0,x1,x2,x3]
  \param y     y-vector with four elements: yj = y(xj), j=0,1,2,3
  \param a     interpolation point on the x-axis with x1 =< a < x2 

  \return FIXME

  \author Thomas Kuhn
  \date   2003-11-25
*/

Numeric LagrangeInterpol4( ConstVectorView x,
                           ConstVectorView y,
                           const Numeric a)
{
  // lowermost grid spacing on x-axis
  const Numeric Dlimit = 1.00000e-15;

  // Check that dimensions of x and y vector agree
  const Index n_x = x.nelem();
  const Index n_y = y.nelem();
  if ( (n_x != 4) || (n_y != 4) )
    {
      ostringstream os;
      os << "The vectors x and y must all have the same length of 4 elements!\n"
        << "Actual lengths:\n"
        << "x:" << n_x << ", " << "y:" << n_y << ".";
      throw runtime_error(os.str());
    }

  // assure that x1 =< a < x2 holds
  if ( (a < x[1]) || (a > x[2]) )
    {
      ostringstream os;
      os << "LagrangeInterpol4: the relation x[1] =< a < x[2] is not satisfied. " 
         << "No interpolation can be calculated.\n";
      throw runtime_error(os.str());
    };

  // calculate the Lagrange polynomial coefficients for a polynomial of the order of 3
  Numeric b[4];
  for (Index i=0 ; i < 4 ; ++i)
    {
      b[i] = 1.000e0;
      for (Index k=0 ; k < 4 ; ++k)
        {
          if ( (k != i) && (fabs(x[i]-x[k]) > Dlimit) )  
            b[i] = b[i] * ( (a-x[k]) / (x[i]-x[k]) );
        };
    };

  Numeric ya = 0.000e0;
  for (Index i=0 ; i < n_x ; ++i) ya = ya + b[i]*y[i];

  return ya;
}




//! last
/*! 
    Returns the last value of a vector.

    \return      The last value of x.
    \param   x   A vector.

    \author Patrick Eriksson 
    \date   2000-06-27
*/
Numeric last( ConstVectorView x )
{
  assert( x.nelem() > 0 );
  return x[x.nelem()-1]; 
}



//! last
/*! 
    Returns the last value of an index array.

    \return      The last value of x.
    \param   x   An index array.

    \author Patrick Eriksson 
    \date   2000-06-27
*/
Index last( const ArrayOfIndex& x )
{
  assert( x.nelem() > 0 );
  return x[x.nelem()-1]; 
}



//! linspace
/*! 
    Linearly spaced vector with specified spacing. 

    The first element of x is always start. The next value is start+step etc.
    Note that the last value can deviate from stop.
    The step can be both positive and negative. 
    (in Matlab notation: start:step:stop)

    Size of result is adjusted within this function!

    \param    x       Output: linearly spaced vector
    \param    start   first value in x
    \param    stop    last value of x <= stop
    \param    step    distance between values in x

    \author Patrick Eriksson
    \date   2000-06-27
*/
void linspace(                      
              Vector&     x,           
              const Numeric     start,    
              const Numeric     stop,        
              const Numeric     step )
{
  Index n = (Index) floor( (stop-start)/step ) + 1;
  if ( n<1 )
    n=1;
  x.resize(n);
  for ( Index i=0; i<n; i++ )
    x[i] = start + (double)i*step;
}



//! nlinspace
/*! 
    Linearly spaced vector with specified length. 

    Returns a vector equally and linearly spaced between start and stop 
    of length n. (equals the Matlab function linspace)

    The length must be > 1.

    \param    x       Output: linearly spaced vector
    \param    start   first value in x
    \param    stop    last value of x <= stop
    \param    n       length of x

    \author Patrick Eriksson
    \date   2000-06-27
*/
void nlinspace(
               Vector&     x,
               const Numeric     start,     
               const Numeric     stop,        
               const Index       n )
{
  assert( 1<n );                // Number of points must be greatere 1.
  x.resize(n);
  Numeric step = (stop-start)/((double)n-1) ;
  for ( Index i=0; i<n-1; i++ )
    x[i] = start + (double)i*step;
  x[n-1] = stop;
}



//! nlogspace
/*! 
    Logarithmically spaced vector with specified length. 

    Returns a vector logarithmically spaced vector between start and 
    stop of length n (equals the Matlab function logspace)

    The length must be > 1.

    \param    x       Output: logarithmically spaced vector
    \param    start   first value in x
    \param    stop    last value of x <= stop
    \param    n       length of x

    \author Patrick Eriksson
    \date   2000-06-27
*/
void nlogspace(         
               Vector&     x, 
               const Numeric     start,     
               const Numeric     stop,        
               const Index         n )
{
  // Number of points must be greater than 1:
  assert( 1<n );        
  // Only positive numbers are allowed for start and stop:
  assert( 0<start );
  assert( 0<stop );

  x.resize(n);
  Numeric a = log(start);
  Numeric step = (log(stop)-a)/((double)n-1);
  x[0] = start;
  for ( Index i=1; i<n-1; i++ )
    x[i] = exp(a + (double)i*step);
  x[n-1] = stop;
}


//! AngIntegrate_trapezoid
/*! 
    Performs an integration of a matrix over all directions defined in angular
    grids using the trapezoidal integration method.

    \param Integrand The Matrix to be integrated
    \param za_grid   The zenith angle grid 
    \param aa_grid   The azimuth angle grid 
    
    \return The resulting integral
*/
Numeric AngIntegrate_trapezoid(ConstMatrixView Integrand,
                               ConstVectorView za_grid,
                               ConstVectorView aa_grid)
{

  Index n = za_grid.nelem();
  Index m = aa_grid.nelem();
  Vector res1(n);
  assert (is_size(Integrand, n, m));
  
  for (Index i = 0; i < n ; ++i)
    {
      res1[i] = 0.0;
      
      for (Index j = 0; j < m - 1; ++j)
        {
          res1[i] +=  0.5 * DEG2RAD * (Integrand(i, j) + Integrand(i, j + 1)) *
            (aa_grid[j + 1] - aa_grid[j]) * sin(za_grid[i] * DEG2RAD);
        }
    }
  Numeric res = 0.0;
  for (Index i = 0; i < n - 1; ++i)
    {
      res += 0.5 * DEG2RAD * (res1[i] + res1[i + 1]) * 
        (za_grid[i + 1] - za_grid[i]);
    }
  
  return res;
}


//! AngIntegrate_trapezoid_opti
/*! 
    Performs an integration of a matrix over all directions defined in angular
    grids using the trapezoidal integration method.

    In addition to the "old fashined" integration method, it checks whether
    the stepsize is constant. If it is, it uses a faster method, if not, it
    uses the old one.

    \param Integrand Input : The Matrix to be integrated
    \param za_grid Input : The zenith angle grid 
    \param aa_grid Input : The azimuth angle grid
    \param grid_stepsize Input : stepsize of the grid
    
    \return The resulting integral

    \author Claas Teichmann <claas@sat.physik.uni-bremen.de>
    \date 2003/05/28
*/
Numeric AngIntegrate_trapezoid_opti(ConstMatrixView Integrand,
                                    ConstVectorView za_grid,
                                    ConstVectorView aa_grid,
                                    ConstVectorView grid_stepsize)
{
  Numeric res = 0;
  if ((grid_stepsize[0] > 0) && (grid_stepsize[1] > 0))
    {
      Index n = za_grid.nelem();
      Index m = aa_grid.nelem();
      Numeric stepsize_za = grid_stepsize[0];
      Numeric stepsize_aa = grid_stepsize[1];
      Vector res1(n);
      assert (is_size(Integrand, n, m));

      Numeric temp = 0.0;
      
      for (Index i = 0; i < n ; ++i)
        {
          temp = Integrand(i, 0);
          for (Index j = 1; j < m - 1; j++)
            {
              temp += Integrand(i, j) * 2;
            }
          temp += Integrand(i, m-1);
          temp *= 0.5 * DEG2RAD * stepsize_aa * sin(za_grid[i] * DEG2RAD);
          res1[i] = temp;
        }

      res = res1[0];
      for (Index i = 1; i < n - 1; i++)
        {
          res += res1[i] * 2;
        }
      res += res1[n-1];
      res *= 0.5 * DEG2RAD * stepsize_za;
    }
  else
    {
      res = AngIntegrate_trapezoid(Integrand, za_grid, aa_grid);
    }

  return res;
}


//! AngIntegrate_trapezoid
/*! 
    Performs an integration of a matrix over all directions defined in angular
    grids using the trapezoidal integration method.
    The integrand is independant of the azimuth angle. The integration over
    the azimuth angle gives a 2*PI

    \param Integrand Input : The vector to be integrated
    \param za_grid Input : The zenith angle grid 

    \author Claas Teichmann
    \date   2003-05-13
    
    \return The resulting integral
*/
Numeric AngIntegrate_trapezoid(ConstVectorView Integrand,
                               ConstVectorView za_grid)
{

  Index n = za_grid.nelem();
  assert (is_size(Integrand, n));
  
  Numeric res = 0.0;
  for (Index i = 0; i < n - 1; ++i)
    {
      // in this place 0.5 * 2 * PI is calculated:
      res += PI * DEG2RAD * (Integrand[i]* sin(za_grid[i] * DEG2RAD) 
                             + Integrand[i + 1] * sin(za_grid[i + 1] * DEG2RAD))
        * (za_grid[i + 1] - za_grid[i]);
    }
  
  return res;
}




//! sign
/*! 
    Returns the sign of a numeric value.

    The function returns 1 if the value is greater than zero, 0 if it 
    equals zero and -1 if it is less than zero.

    \return      The sign of x (see above).
    \param   x   A Numeric.

    \author Patrick Eriksson 
    \date   2000-06-27
*/
Numeric sign( const Numeric& x )
{
  if( x < 0 )
    return -1.0;
  else if( x == 0 )
    return 0.0;
  else
    return 1.0;
}


//! Gamma Function
/*! Returns gamma function of real argument 'x'.
    Returns error msg if argument is a negative integer or 0,
    or use lgamma function if argument exceeds 32.0.

    \return  gam Gamma function of x.
    
    \param   xx  Numeric

    \author Daniel Kreyling 
    \date   2010-12-13
*/

Numeric gamma_func(Numeric xx)
{
  //double lgamma(double xx);
  
  Numeric gam;
  Index i;
  
  
  if (xx > 0.0) {
    if (xx == (int)xx) {
      gam = 1.0;               // use factorial
      for (i=2;i<xx;i++) {
        gam *= (Numeric)i;
      }
    }    
    else {       
	    return exp(lgamma_func(xx));
    }
  } else {
    ostringstream os;
    os << "Argument is zero or negative."
    << "Gamma function can not be calculated.\n";
    throw runtime_error(os.str());
  }
  
  
  return gam;
}


//! ln Gamma Function
/*! Returns ln of gamma function for real argument 'x'.
   
    \return      ln Gamma function of x.
    \param   xx  Numeric

    \author Daniel Kreyling 
     \date   2010-12-13
*/


Numeric lgamma_func(Numeric xx)
{
  
  Numeric x,y,tmp,ser;
  static const Numeric cof[6] = {
    76.18009172947146, -86.50532032941677, 24.01409824083091,
    -1.231739572450155, 0.1208650973866179e-2, -0.5395239384953e-5
  };
  
  if (xx > 0.0)
  {
    y=x=xx;
    tmp = x+5.5;
    tmp -= (x+0.5)*log(tmp);
    ser = 1.000000000190015;
    for (Index j=0;j<=5;j++) ser += cof[j]/++y;
    return -tmp+log(2.5066282746310005*ser/x);
  }
  else
  {
    ostringstream os;
    os << "Argument is zero or negative.\n"
    << "log Gamma function can not be calculated.\n";
    throw runtime_error(os.str());
  }
}



//! lunit
/*!
    Normalises a vector to have unit length.

    The standard Euclidean norm is used (2-norm).

    param    x   In/Out: A vector.

    \author Patrick Eriksson
    \date   2012-02-12
*/
void unitl( Vector& x )
{
  assert( x.nelem() > 0 );
 
  const Numeric l = sqrt(x*x);
  for(Index i=0; i<x.nelem(); i++ )
    x[i] /= l;
}
        
