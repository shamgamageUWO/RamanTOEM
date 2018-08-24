/* Copyright (C) 2002-2012
   Claudia Emde <claudia.emde@dlr.de>
   Sreerekha T.R. <rekha@uni-bremen.de>
                           
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
   USA. 
*/
  
/*!
  \file   m_doit.cc
  \author Claudia Emde <claudia.emde@dlr.de>
  \author Sreerekha T.R. <rekha@uni-bremen.de>
  \date   Wed Jun 19 11:03:57 2002
  
  \brief  This file contains functions to calculate the radiative transfer
  inside the cloudbox using the DOIT method.
  
  These functions are listed in the doxygen documentation as entries of the
  file auto_md.h
*/


/*===========================================================================
  === External declarations
  ===========================================================================*/

#include <stdexcept>
#include <iostream>
#include <cstdlib>
#include <cmath>
#include "arts.h"
#include "array.h"
#include "auto_md.h"
#include "check_input.h"
#include "matpackVII.h"
#include "logic.h"
#include "ppath.h"
#include "agenda_class.h"
#include "physics_funcs.h"
#include "lin_alg.h"
#include "math_funcs.h"
#include "messages.h"
#include "xml_io.h"
#include "rte.h"
#include "special_interp.h"
#include "doit.h"
#include "m_general.h"
#include "wsv_aux.h"
#include "geodetic.h"


extern const Numeric PI;
extern const Numeric RAD2DEG;
  
/*===========================================================================
  === The functions (in alphabetical order)
  ===========================================================================*/


/* Workspace method: Doxygen documentation will be auto-generated */
void DoitAngularGridsSet(// WS Output:
                         Index& doit_za_grid_size,
                         Vector& scat_aa_grid,
                         Vector& scat_za_grid,
                         // Keywords:
                         const Index& N_za_grid,
                         const Index& N_aa_grid,
                         const String& za_grid_opt_file,
                         const Verbosity& verbosity)
{
  // Check input
  //
  // The recommended values were found by testing the accuracy and the speed of 
  // 1D DOIT calculations for different grid sizes. For 3D calculations it can 
  // be necessary to use more grid points. 
  if (N_za_grid < 16)
    throw runtime_error("N_za_grid must be greater than 15 for accurate results");
  else if (N_za_grid > 100)
  {
    CREATE_OUT1;
    out1 << "Warning: N_za_grid is very large which means that the \n"
         << "calculation will be very slow.\n";
  }
  
  if (N_aa_grid < 6)
    throw runtime_error("N_aa_grid must be greater than 5 for accurate results");
  else if (N_aa_grid > 100)
  {
    CREATE_OUT1;
    out1 << "Warning: N_aa_grid is very large which means that the \n"
         << "calculation will be very slow.\n";
  }
  
  // Azimuth angle grid (the same is used for the scattering integral and
  // for the radiative transfer.
  nlinspace(scat_aa_grid, 0, 360, N_aa_grid);
  
  // Zenith angle grid: 
  // Number of zenith angle grid points (only for scattering integral): 
  doit_za_grid_size = N_za_grid; 

  if( za_grid_opt_file == "" ) 
    nlinspace(scat_za_grid, 0, 180, N_za_grid);
  else
    xml_read_from_file(za_grid_opt_file, scat_za_grid, verbosity);

}


/* Workspace method: Doxygen documentation will be auto-generated */
void doit_conv_flagAbs(//WS Input and Output:
                       Index& doit_conv_flag,
                       Index& doit_iteration_counter,
                       Tensor6& doit_i_field,
                       // WS Input:
                       const Tensor6& doit_i_field_old,
                       // Keyword:
                       const Vector& epsilon,
                       const Index& max_iterations,
                       const Index& throw_nonconv_error,
                       const Verbosity& verbosity)
{
  CREATE_OUT1;
  CREATE_OUT2;
  
  //------------Check the input---------------------------------------
  if( doit_conv_flag != 0 )
    throw runtime_error("Convergence flag is non-zero, which means that this\n"
                        "WSM is not used correctly. *doit_conv_flagAbs* should\n"
                        "be used only in *doit_conv_test_agenda*\n");
  
  const Index N_p = doit_i_field.nvitrines();
  const Index N_lat = doit_i_field.nshelves();
  const Index N_lon = doit_i_field.nbooks();
  const Index N_za = doit_i_field.npages();
  const Index N_aa = doit_i_field.nrows();
  const Index stokes_dim = doit_i_field.ncols();
  
  // Check keyword "epsilon":
  if ( epsilon.nelem() != stokes_dim )
    throw runtime_error(
                        "You have to specify limiting values for the "
                        "convergence test for each Stokes component "
                        "separately. That means that *epsilon* must "
                        "have *stokes_dim* elements!"
                        );

  // Check if doit_i_field and doit_i_field_old have the same dimensions:
  if(!is_size( doit_i_field_old, 
                  N_p, N_lat, N_lon, N_za, N_aa, stokes_dim))
    throw runtime_error("The fields (Tensor6) *doit_i_field* and \n"
                        "*doit_i_field_old* which are compared in the \n"
                        "convergence test do not have the same size.\n");
  
  //-----------End of checks-------------------------------------------------
                        

  doit_iteration_counter +=1;
  out2 << "  Number of DOIT iteration: " << doit_iteration_counter << "\n";

  if (doit_iteration_counter > max_iterations)
    {
      ostringstream out;
      out <<"Method does not converge (number of iterations \n"
          <<"is > " << max_iterations << "). Either the cloud "
          <<"particle number density \n"
          <<"is too large or the numerical setup for the DOIT \n"
          <<"calculation is not correct. In case of limb \n"
          <<"simulations please make sure that you use an \n"
          <<"optimized zenith angle grid. \n"
          <<"*doit_i_field* might be wrong.\n";
      if( throw_nonconv_error != 0)
        {
// FIXME: OLE: Remove this later
//          ostringstream os;
//          os << "Error in DOIT calculation:\n"
//             << out.str();
//          throw runtime_error( os.str() );
          out1 << "Warning in DOIT calculation (output set to NaN):\n"
               << out.str();
          doit_i_field = NAN;
          doit_conv_flag = 1;
        }
      else
        {
          out1 << "Warning in DOIT calculation (output equals current status):\n"
               << out.str();
          doit_conv_flag = 1;
        }
    }
  else
    {
   for (Index p_index = 0; p_index < N_p; p_index++)
    { 
      for (Index lat_index = 0; lat_index < N_lat; lat_index++)
        {
          for (Index lon_index = 0; lon_index <N_lon; lon_index++)
            {
              for (Index scat_za_index = 0; scat_za_index < N_za;
                   scat_za_index++)
                {
                  for (Index scat_aa_index = 0; scat_aa_index < N_aa;
                       scat_aa_index++)
                    {
                      for (Index stokes_index = 0; stokes_index <
                             stokes_dim; stokes_index ++) 
                        {
                          Numeric diff =
                             (doit_i_field(p_index, lat_index, lon_index, 
                                               scat_za_index, scat_aa_index, 
                                               stokes_index) -
                              doit_i_field_old(p_index, lat_index, 
                                               lon_index, scat_za_index,
                                               scat_aa_index, 
                                               stokes_index ));
                            
                          // If the absolute difference of the components
                          // is larger than the pre-defined values, return
                          // to *doit_i_fieldIterarte* and do next iteration
                          
                          if( abs(diff) > epsilon[stokes_index])
                            {
                              out1 << "difference: " << diff <<"\n";
                              return;
                            }
                          
                          
                        }// End loop stokes_dom.
                    }// End loop scat_aa_grid. 
                }// End loop scat_za_grid.
            }// End loop lon_grid. 
        }// End loop lat_grid.
    } // End p_grid.
  
  // Convergence test has been successful, doit_conv_flag can be set to 1.
  doit_conv_flag = 1;
    }
}
      

/* Workspace method: Doxygen documentation will be auto-generated */
void doit_conv_flagAbsBT(//WS Input and Output:
                         Index& doit_conv_flag,
                         Index& doit_iteration_counter,
                         Tensor6& doit_i_field,
                         // WS Input:
                         const Tensor6& doit_i_field_old,
                         const Vector& f_grid,
                         const Index& f_index, 
                         // Keyword:
                         const Vector& epsilon,
                         const Index& max_iterations,
                         const Index& throw_nonconv_error,
                         const Verbosity& verbosity)
{
  CREATE_OUT1;
  CREATE_OUT2;
  
   //------------Check the input---------------------------------------

  if( doit_conv_flag != 0 )
    throw runtime_error("Convergence flag is non-zero, which means that this \n"
                        "WSM is not used correctly. *doit_conv_flagAbs* should\n"
                        "be used only in *doit_conv_test_agenda*\n");
  
  const Index N_p = doit_i_field.nvitrines();
  const Index N_lat = doit_i_field.nshelves();
  const Index N_lon = doit_i_field.nbooks();
  const Index N_za = doit_i_field.npages();
  const Index N_aa = doit_i_field.nrows();
  const Index stokes_dim = doit_i_field.ncols();
  
  // Check keyword "epsilon":
  if ( epsilon.nelem() != stokes_dim )
    throw runtime_error(
                        "You have to specify limiting values for the "
                        "convergence test for each Stokes component "
                        "separately. That means that *epsilon* must "
                        "have *stokes_dim* elements!"
                        );
  
  // Check if doit_i_field and doit_i_field_old have the same dimensions:
  if(!is_size( doit_i_field_old, 
               N_p, N_lat, N_lon, N_za, N_aa, stokes_dim))
    throw runtime_error("The fields (Tensor6) *doit_i_field* and \n"
                        "*doit_i_field_old* which are compared in the \n"
                        "convergence test do not have the same size.\n");

  // Frequency grid
  //
  if( f_grid.nelem() == 0 )
    throw runtime_error( "The frequency grid is empty." );
  chk_if_increasing( "f_grid", f_grid );

  // Is the frequency index valid?
  if ( f_index >= f_grid.nelem() )
    throw runtime_error("*f_index* is greater than number of elements in the\n"
                        "frequency grid.\n");
  
  //-----------End of checks--------------------------------

  doit_iteration_counter +=1;
  out2 << "  Number of DOIT iteration: " << doit_iteration_counter << "\n";

  if (doit_iteration_counter > max_iterations)
    {
      ostringstream out;
      out <<"At frequency " << f_grid[f_index] << " GHz \n"
          <<"method does not converge (number of iterations \n"
          <<"is > " << max_iterations << "). Either the cloud particle"
          <<" number density \n"
          <<"is too large or the numerical setup for the DOIT \n"
          <<"calculation is not correct. In case of limb \n"
          <<"simulations please make sure that you use an \n"
          <<"optimized zenith angle grid. \n"
          <<"*doit_i_field* might be wrong.\n";
      if( throw_nonconv_error != 0)
        {
// FIXME: OLE: Remove this later
//          ostringstream os;
//          os << "Error in DOIT calculation:\n"
//             << out.str();
//          throw runtime_error( os.str() );
          out1 << "Warning in DOIT calculation (output set to NaN):\n"
               << out.str();
          doit_i_field = NAN;
          doit_conv_flag = 1;
        }
      else
        {
          out1 << "Warning in DOIT calculation (output equals current status):\n"
               << out.str();
          doit_conv_flag = 1;
        }
    }
  else
    {
    for (Index p_index = 0; p_index < N_p; p_index++)
    { 
      for (Index lat_index = 0; lat_index < N_lat; lat_index++)
        {
          for (Index lon_index = 0; lon_index <N_lon; lon_index++)
            {
              for (Index scat_za_index = 0; scat_za_index < N_za;
                   scat_za_index++)
                {
                  for (Index scat_aa_index = 0; scat_aa_index < N_aa;
                       scat_aa_index++)
                    {
                      for (Index stokes_index = 0; stokes_index <
                             stokes_dim; stokes_index ++) 
                        {
                          Numeric diff =
                            doit_i_field(p_index, lat_index, lon_index,
                                          scat_za_index, scat_aa_index, 
                                          stokes_index) -
                                  doit_i_field_old(p_index, lat_index, 
                                              lon_index, scat_za_index,
                                              scat_aa_index, 
                                              stokes_index );
                          
                          // If the absolute difference of the components
                          // is larger than the pre-defined values, return
                          // to *doit_i_fieldIterarte* and do next iteration
                          Numeric diff_bt = invrayjean(diff, f_grid[f_index]);
                          if( abs(diff_bt) > epsilon[stokes_index])
                            {
                              out1 << "BT difference: " << diff_bt
                                    << " in stokes dim " << stokes_index << "\n";
                              return;
                            }
                        }// End loop stokes_dom.
                    }// End loop scat_aa_grid. 
                }// End loop scat_za_grid.
            }// End loop lon_grid. 
        }// End loop lat_grid.
    } // End p_grid.
  
  // Convergence test has been successful, doit_conv_flag can be set to 1.
  doit_conv_flag = 1;
    }
}


/* Workspace method: Doxygen documentation will be auto-generated */
void doit_conv_flagLsq(//WS Output:
                       Index& doit_conv_flag,
                       Index& doit_iteration_counter,
                       Tensor6& doit_i_field,
                       // WS Input:
                       const Tensor6& doit_i_field_old,
                       const Vector& f_grid,
                       const Index& f_index,
                       // Keyword:
                       const Vector& epsilon,
                       const Index& max_iterations,
                       const Index& throw_nonconv_error,
                       const Verbosity& verbosity)
{
  CREATE_OUT1;
  CREATE_OUT2;
  
  //------------Check the input---------------------------------------
  
  if( doit_conv_flag != 0 )
    throw runtime_error("Convergence flag is non-zero, which means that this \n"
                        "WSM is not used correctly. *doit_conv_flagAbs* should\n"
                        "be used only in *doit_conv_test_agenda*\n");
 
  const Index N_p = doit_i_field.nvitrines();
  const Index N_lat = doit_i_field.nshelves();
  const Index N_lon = doit_i_field.nbooks();
  const Index N_za = doit_i_field.npages();
  const Index N_aa = doit_i_field.nrows();
  const Index stokes_dim = doit_i_field.ncols();
  
  // Check keyword "epsilon":
  if ( epsilon.nelem() != stokes_dim )
    throw runtime_error(
                        "You have to specify limiting values for the "
                        "convergence test for each Stokes component "
                        "separately. That means that *epsilon* must "
                        "have *stokes_dim* elements!"
                        );

  // Check if doit_i_field and doit_i_field_old have the same dimensions:
  if(!is_size( doit_i_field_old, 
               N_p, N_lat, N_lon, N_za, N_aa, stokes_dim))
    throw runtime_error("The fields (Tensor6) *doit_i_field* and \n"
                        "*doit_i_field_old* which are compared in the \n"
                        "convergence test do not have the same size.\n");
  
  // Frequency grid
  //
  if( f_grid.nelem() == 0 )
    throw runtime_error( "The frequency grid is empty." );
  chk_if_increasing( "f_grid", f_grid );

  // Is the frequency index valid?
  if ( f_index >= f_grid.nelem() )
    throw runtime_error("*f_index* is greater than number of elements in the\n"
                        "frequency grid.\n");
  
  //-----------End of checks--------------------------------

 
  doit_iteration_counter +=1;
  out2 << "  Number of DOIT iteration: " << doit_iteration_counter << "\n";
  
  if (doit_iteration_counter > max_iterations)
    {
      ostringstream out;
      out <<"Method does not converge (number of iterations \n"
          <<"is > " << max_iterations << "). Either the cloud"
          <<" particle number density \n"
          <<"is too large or the numerical setup for the DOIT \n"
          <<"calculation is not correct. In case of limb \n"
          <<"simulations please make sure that you use an \n"
          <<"optimized zenith angle grid. \n";
      if( throw_nonconv_error != 0)
        {
// FIXME: OLE: Remove this later
//          ostringstream os;
//          os << "Error in DOIT calculation:\n"
//             << out.str();
//          throw runtime_error( os.str() );
          out1 << "Warning in DOIT calculation (output set to NaN):\n"
               << out.str();
          doit_i_field = NAN;
          doit_conv_flag = 1;
        }
      else
        {
          out1 << "Warning in DOIT calculation (output equals current status):\n"
               << out.str();
          doit_conv_flag = 1;
        }
    }
  else
    {
  Vector lqs(4, 0.);
  
  // Will be set to zero if convergence not fullfilled
  doit_conv_flag = 1;
  for (Index i = 0; i < epsilon.nelem(); i ++)
    {
      for (Index p_index = 0; p_index < N_p; p_index++)
        { 
          for (Index lat_index = 0; lat_index < N_lat; lat_index++)
            {
              for (Index lon_index = 0; lon_index <N_lon; lon_index++)
                {
                  for (Index scat_za_index = 0; scat_za_index < N_za;
                       scat_za_index++)
                    {
                      for (Index scat_aa_index = 0; scat_aa_index < N_aa;
                           scat_aa_index++)
                        {
                          lqs[i] 
                            += pow(
                                   doit_i_field(p_index, lat_index, 
                                                lon_index, 
                                           scat_za_index, scat_aa_index, i) -
                                   doit_i_field_old(p_index, lat_index, 
                                               lon_index, scat_za_index,
                                               scat_aa_index, i) 
                                   , 2);
                        }// End loop scat_aa_grid. 
                    }// End loop scat_za_grid.
                }// End loop lon_grid. 
            }// End loop lat_grid.
        } // End p_grid.
      
      lqs[i] = sqrt(lqs[i]);
      lqs[i] /= (Numeric)(N_p*N_lat*N_lon*N_za*N_aa);

      // Convert difference to Rayleigh Jeans BT
      lqs[i] = invrayjean(lqs[i], f_grid[f_index]);
      
      if (lqs[i] >= epsilon[i] )
        doit_conv_flag = 0;
    }
  // end loop stokes_index
  out1 << "lqs [I]: " << lqs[0] << "\n";  
    }
}


/* Workspace method: Doxygen documentation will be auto-generated */
void doit_i_fieldIterate(Workspace& ws,
                         // WS Input and Output:
                         Tensor6& doit_i_field,
                         // WS Input:  
                         const Agenda& doit_scat_field_agenda,
                         const Agenda& doit_rte_agenda,
                         const Agenda& doit_conv_test_agenda,
                         const Verbosity& verbosity)
{
  CREATE_OUT2;
  
  //---------------Check input---------------------------------
  chk_not_empty( "doit_scat_field_agenda", doit_scat_field_agenda);
  chk_not_empty( "doit_rte_agenda", doit_rte_agenda);
  chk_not_empty( "doit_conv_test_agenda", doit_conv_test_agenda);
  
  //doit_i_field can not be checked here, because there is no way
  //to find out the size without including a lot more interface 
  //variables
  //-----------End of checks-------------------------------------- 

  Tensor6 doit_i_field_old_local;
  Index doit_conv_flag_local;
  Index doit_iteration_counter_local;

  // Resize and initialize doit_scat_field,
  // which  has the same dimensions as doit_i_field
  Tensor6 doit_scat_field_local
    (doit_i_field.nvitrines(), doit_i_field.nshelves(),
     doit_i_field.nbooks(), doit_i_field.npages(),
     doit_i_field.nrows(), doit_i_field.ncols(), 0.);

  doit_conv_flag_local = 0;
  doit_iteration_counter_local = 0;

  while(doit_conv_flag_local == 0) {
    
    // 1. Copy doit_i_field to doit_i_field_old.
    doit_i_field_old_local = doit_i_field;
    
    // 2.Calculate scattered field vector for all points in the cloudbox.
    
    // Calculate the scattered field.
    out2 << "  Execute doit_scat_field_agenda. \n";
    doit_scat_field_agendaExecute(ws, doit_scat_field_local,
                                  doit_i_field,
                                  doit_scat_field_agenda);

    // Update doit_i_field.
    out2 << "  Execute doit_rte_agenda. \n";
    doit_rte_agendaExecute(ws, doit_i_field, doit_scat_field_local,
                           doit_rte_agenda);

    //Convergence test.
    doit_conv_test_agendaExecute(ws, doit_conv_flag_local,
                                 doit_iteration_counter_local,
                                 doit_i_field,
                                 doit_i_field_old_local,
                                 doit_conv_test_agenda);

  }//end of while loop, convergence is reached.
}


/* Workspace method: Doxygen documentation will be auto-generated */
void
doit_i_fieldUpdate1D(Workspace& ws,
                     // WS Input and Output:
                     Tensor6& doit_i_field,
                     // WS Input:
                     const Tensor6& doit_scat_field,
                     const ArrayOfIndex& cloudbox_limits,
                     // Calculate scalar gas absorption:
                     const Agenda& propmat_clearsky_agenda,
                     const Tensor4& vmr_field,
                     // Optical properties for single particle type:
                     const Agenda& spt_calc_agenda,
                     const Vector& scat_za_grid,
                     const Tensor4& pnd_field,
                     // Optical properties for gases and particles:
                     const Agenda& opt_prop_part_agenda,
                     // Propagation path calculation:
                     const Agenda& ppath_step_agenda,
                     const Numeric& ppath_lraytrace,
                     const Vector& p_grid,
                     const Tensor3& z_field,
                     const Vector& refellipsoid,
                     // Calculate thermal emission:
                     const Tensor3& t_field,
                     const Vector& f_grid,
                     const Index& f_index,
                     const Agenda& surface_rtprop_agenda,
                     const Index& doit_za_interp,
                     const Verbosity& verbosity
                   )
{
  CREATE_OUT2;
  CREATE_OUT3;
  
  out2 << "  doit_i_fieldUpdate1D: Radiative transfer calculation in cloudbox\n";
  out2 << "  ------------------------------------------------------------- \n";
  
  // ---------- Check the input ----------------------------------------
  
  // Agendas
  chk_not_empty( "spt_calc_agenda", spt_calc_agenda);
  chk_not_empty( "opt_prop_part_agenda", opt_prop_part_agenda);
  chk_not_empty( "ppath_step_agenda", ppath_step_agenda);
  
  if (cloudbox_limits.nelem() != 2)
    throw runtime_error(
                        "The cloudbox dimension is not 1D! \n"
                        "Do you really want to do a 1D calculation? \n"
                        "If not, use *doit_i_fieldUpdateSeq3D*.\n"
                        );
  
  // Number of zenith angles.
  const Index N_scat_za = scat_za_grid.nelem();
  
  if (scat_za_grid[0] != 0. || scat_za_grid[N_scat_za-1] != 180.)
    throw runtime_error("The range of *scat_za_grid* must [0 180].");
  
  if( p_grid.nelem() < 2 )
    throw runtime_error( "The length of *p_grid* must be >= 2." );
  chk_if_decreasing( "p_grid", p_grid );

  chk_size("z_field", z_field, p_grid.nelem(), 1, 1);
  chk_size("t_field", t_field, p_grid.nelem(), 1, 1);
  
  
  // Frequency grid
  //
  if( f_grid.nelem() == 0 )
    throw runtime_error( "The frequency grid is empty." );
  chk_if_increasing( "f_grid", f_grid );
  
  // Is the frequency index valid?
  if ( f_index >= f_grid.nelem() )
    throw runtime_error("*f_index* is greater than number of elements in the\n"
                        "frequency grid.\n");
  
  if( !(doit_za_interp == 0  ||  doit_za_interp == 1 ) )
    throw runtime_error( "Interpolation method is not defined. Use \n"
                         "*doit_za_interpSet*.\n");
  
  const Index stokes_dim = doit_scat_field.ncols();
  assert(stokes_dim > 0 || stokes_dim < 5);


  // These variables are calculated internally, so assertions should be o.k.
  assert( is_size( doit_i_field, 
                   (cloudbox_limits[1] - cloudbox_limits[0]) + 1, 1, 1, 
                   N_scat_za, 1, stokes_dim));
  
  assert( is_size( doit_scat_field, 
                   (cloudbox_limits[1] - cloudbox_limits[0]) + 1, 1, 1, 
                   N_scat_za, 1, stokes_dim));
  
  // FIXME: Check *vmr_field* 
  
  // -------------- End of checks --------------------------------------
 
  
  //=======================================================================
  // Calculate scattering coefficients for all positions in the cloudbox 
  //=======================================================================
  out3 << "Calculate single particle properties \n";

  // At this place only the particle properties are calculated. Gaseous
  // absorption is calculated inside the radiative transfer part. Inter-
  // polating absorption coefficients for gaseous species gives very bad
  // results, so they are calulated for interpolated VMRs,
  // temperature and pressure.
      
  // To use special interpolation functions for atmospheric fields we 
  // use ext_mat_field and abs_vec_field:
  Tensor5 ext_mat_field(cloudbox_limits[1] - cloudbox_limits[0] + 1, 1, 1,
                        stokes_dim, stokes_dim, 0.);
  Tensor4 abs_vec_field(cloudbox_limits[1] - cloudbox_limits[0] + 1, 1, 1,
                        stokes_dim, 0.);

  Tensor6 doit_i_field_old(doit_i_field);

  //Only dummy variable:
  Index scat_aa_index_local = 0; 

  //Loop over all directions, defined by scat_za_grid 
  for( Index scat_za_index_local = 0; scat_za_index_local < N_scat_za; 
       scat_za_index_local ++)
    {
      // This function has to be called inside the angular loop, as
      // spt_calc_agenda takes *scat_za_index_local* and *scat_aa_index* 
      // from the workspace.
      // *scat_p_index* is needed for communication with agenda 
      // *opt_prop_part_agenda*.
      cloud_fieldsCalc(ws, ext_mat_field, abs_vec_field,
                       spt_calc_agenda, 
                       opt_prop_part_agenda, scat_za_index_local, 
                       scat_aa_index_local,
                       cloudbox_limits, t_field, pnd_field, verbosity);
      
      //======================================================================
      // Radiative transfer inside the cloudbox
      //=====================================================================
      
      for(Index p_index = cloudbox_limits[0]; p_index
            <= cloudbox_limits[1]; p_index ++)
        {
          if ( (p_index!=0) || (scat_za_grid[scat_za_index_local] <= 90.))
            {
              cloud_ppath_update1D_noseq(ws, doit_i_field,
                                     p_index, scat_za_index_local, 
                                     scat_za_grid,
                                     cloudbox_limits, doit_i_field_old, 
                                     doit_scat_field,
                                     propmat_clearsky_agenda, vmr_field,
                                     ppath_step_agenda, ppath_lraytrace,
                                     p_grid,  z_field, refellipsoid,
                                     t_field, f_grid, f_index, ext_mat_field, 
                                     abs_vec_field,
                                     surface_rtprop_agenda, doit_za_interp,
                                     verbosity);
            }
        }
    }// Closes loop over scat_za_grid.
}


/* Workspace method: Doxygen documentation will be auto-generated */
void
doit_i_fieldUpdateSeq1D(Workspace& ws,
                        // WS Input and Output:
                        Tensor6& doit_i_field,
                        Tensor6& doit_scat_field,
                        // WS Input:
                        const ArrayOfIndex& cloudbox_limits,
                        // Calculate scalar gas absorption:
                        const Agenda& propmat_clearsky_agenda,
                        const Tensor4& vmr_field,
                        // Optical properties for single particle type:
                        const Agenda& spt_calc_agenda,
                        const Vector& scat_za_grid,
                        const Vector& scat_aa_grid,
                        const Tensor4& pnd_field,
                        // Optical properties for gases and particles:
                        const Agenda& opt_prop_part_agenda,
                        // Propagation path calculation:
                        const Agenda& ppath_step_agenda,
                        const Numeric& ppath_lraytrace,
                        const Vector& p_grid,
                        const Tensor3& z_field,
                        const Vector& refellipsoid,
                        // Calculate thermal emission:
                        const Tensor3& t_field,
                        const Vector& f_grid,
                        const Index& f_index,
                        const Agenda& surface_rtprop_agenda, //STR
                        const Index& doit_za_interp,
                        const Index& normalize,
                        const Numeric& norm_error_threshold,
                        const Index& norm_debug,
                        const Verbosity& verbosity)
{
  CREATE_OUT2;
  CREATE_OUT3;

  out2<<"  doit_i_fieldUpdateSeq1D: Radiative transfer calculation in cloudbox\n";
  out2 << "  ------------------------------------------------------------- \n";

 // ---------- Check the input ----------------------------------------
  
  // Agendas
  chk_not_empty( "propmat_clearsky_agenda", propmat_clearsky_agenda);
  chk_not_empty( "spt_calc_agenda", spt_calc_agenda);
  chk_not_empty( "opt_prop_part_agenda", opt_prop_part_agenda);
  chk_not_empty( "ppath_step_agenda", ppath_step_agenda);
  
  if (cloudbox_limits.nelem() != 2)
    throw runtime_error(
                        "The cloudbox dimension is not 1D! \n"
                        "Do you really want to do a 1D calculation? \n"
                        "For 3D use *doit_i_fieldUpdateSeq3D*.\n"
                        );
   
  // Number of zenith angles.
  const Index N_scat_za = scat_za_grid.nelem();
  
  if (scat_za_grid[0] != 0. || scat_za_grid[N_scat_za-1] != 180.)
    throw runtime_error("The range of *scat_za_grid* must [0 180].");
  
  if( p_grid.nelem() < 2 )
    throw runtime_error( "The length of *p_grid* must be >= 2." );
  chk_if_decreasing( "p_grid", p_grid );

  chk_size("z_field", z_field, p_grid.nelem(), 1, 1);
  chk_size("t_field", t_field, p_grid.nelem(), 1, 1);
  
  
  // Frequency grid
  //
  if( f_grid.nelem() == 0 )
    throw runtime_error( "The frequency grid is empty." );
  chk_if_increasing( "f_grid", f_grid );
  
  // Is the frequency index valid?
  if ( f_index >= f_grid.nelem() )
    throw runtime_error("*f_index* is greater than number of elements in the\n"
                        "frequency grid.\n");
  
  if( !(doit_za_interp == 0  ||  doit_za_interp == 1 ) )
    throw runtime_error( "Interpolation method is not defined. Use \n"
                         "*doit_za_interpSet*.\n");
  
  const Index stokes_dim = doit_scat_field.ncols();
  assert(stokes_dim > 0 || stokes_dim < 5); 
  
  
  // These variables are calculated internally, so assertions should be o.k.
  assert( is_size( doit_i_field, 
                   (cloudbox_limits[1] - cloudbox_limits[0]) + 1, 1, 1, 
                   N_scat_za, 1, stokes_dim));
  
  assert( is_size( doit_scat_field, 
                   (cloudbox_limits[1] - cloudbox_limits[0]) + 1, 1, 1, 
                   N_scat_za, 1, stokes_dim));
  
  // FIXME: Check *vmr_field*
  
  // -------------- End of checks --------------------------------------
  
     
  //=======================================================================
  // Calculate scattering coefficients for all positions in the cloudbox 
  //=======================================================================
  out3 << "Calculate single particle properties \n";

  // At this place only the particle properties are calculated. Gaseous
  // absorption is calculated inside the radiative transfer part. Inter-
  // polating absorption coefficients for gaseous species gives very bad
  // results, so they are calulated for interpolated VMRs,
  // temperature and pressure.
      
  // To use special interpolation functions for atmospheric fields we 
  // use ext_mat_field and abs_vec_field:
  Tensor5 ext_mat_field(cloudbox_limits[1] - cloudbox_limits[0] + 1, 1, 1,
                        stokes_dim, stokes_dim, 0.);
  Tensor4 abs_vec_field(cloudbox_limits[1] - cloudbox_limits[0] + 1, 1, 1,
                        stokes_dim, 0.);
  
     
  // If theta is between 90° and the limiting value, the intersection point
  // is exactly at the same level as the starting point (cp. AUG)
  Numeric theta_lim = 180. - asin((refellipsoid[0]+
                                   z_field(cloudbox_limits[0],0,0))/
                                  (refellipsoid[0]+
                                   z_field(cloudbox_limits[1],0,0)))*RAD2DEG;

  // Epsilon for additional limb iterations
  Vector epsilon(4);
  epsilon[0] = 0.1;
  epsilon[1] = 0.01;
  epsilon[2] = 0.01;
  epsilon[3] = 0.01;

  Matrix doit_i_field_limb;

  //Only dummy variables:
  Index scat_aa_index_local = 0;

  if (normalize)
    {
      Tensor4 si, sei, si_corr;
      doit_scat_fieldNormalize(ws,
                               doit_scat_field,
                               doit_i_field,
                               cloudbox_limits,
                               spt_calc_agenda,
                               1,
                               scat_za_grid, scat_aa_grid,
                               pnd_field,
                               opt_prop_part_agenda,
                               t_field,
                               norm_error_threshold,
                               norm_debug,
                               verbosity);
    }

  //Loop over all directions, defined by scat_za_grid
  for(Index scat_za_index_local = 0; scat_za_index_local < N_scat_za;
      scat_za_index_local ++)
    {
      // This function has to be called inside the angular loop, as
      // spt_calc_agenda takes *scat_za_index* and *scat_aa_index* 
      // from the workspace.
      // *scat_p_index* is needed for communication with agenda 
      // *opt_prop_part_agenda*.
      cloud_fieldsCalc(ws, ext_mat_field, abs_vec_field, 
                       spt_calc_agenda, opt_prop_part_agenda, 
                       scat_za_index_local, scat_aa_index_local,
                       cloudbox_limits, t_field, pnd_field, verbosity);


      //======================================================================
      // Radiative transfer inside the cloudbox
      //=====================================================================
   
      
      // Sequential update for uplooking angles
      if ( scat_za_grid[scat_za_index_local] <= 90.) 
        {
          // Loop over all positions inside the cloud box defined by the 
          // cloudbox_limits excluding the upper boundary. For uplooking
          // directions, we start from cloudbox_limits[1]-1 and go down
          // to cloudbox_limits[0] to do a sequential update of the
          // radiation field
          for(Index p_index = cloudbox_limits[1]-1; p_index
                >= cloudbox_limits[0]; p_index --)
            {
              cloud_ppath_update1D(ws, doit_i_field,
                                   p_index, scat_za_index_local, scat_za_grid,
                                   cloudbox_limits, doit_scat_field,
                                   propmat_clearsky_agenda, vmr_field,
                                   ppath_step_agenda, ppath_lraytrace,
                                   p_grid,  z_field, refellipsoid,
                                   t_field, f_grid, f_index, 
                                   ext_mat_field, abs_vec_field, 
                                   surface_rtprop_agenda, doit_za_interp,
                                   verbosity); 
            }
        }
      else if ( scat_za_grid[scat_za_index_local] >= theta_lim) 
        {
          //
          // Sequential updating for downlooking angles
          //
          for(Index p_index = cloudbox_limits[0]+1; p_index
                <= cloudbox_limits[1]; p_index ++)
            {
              cloud_ppath_update1D(ws, doit_i_field,
                                   p_index, scat_za_index_local, scat_za_grid,
                                   cloudbox_limits, doit_scat_field,
                                   propmat_clearsky_agenda, vmr_field,
                                   ppath_step_agenda, ppath_lraytrace,
                                   p_grid,  z_field, refellipsoid,
                                   t_field, f_grid, f_index, 
                                   ext_mat_field, abs_vec_field, 
                                   surface_rtprop_agenda, doit_za_interp,
                                   verbosity); 
            }// Close loop over p_grid (inside cloudbox).
        } // end if downlooking.
      
      //
      // Limb looking:
      // We have to include a special case here, as we may miss the endpoints
      // when the intersection point is at the same level as the aactual point.
      // To be save we loop over the full cloudbox. Inside the function 
      // cloud_ppath_update1D it is checked whether the intersection point is 
      // inside the cloudbox or not.
      else
      {
        bool conv_flag = false;
        Index limb_it = 0;
        while (!conv_flag && limb_it < 10)
        {
          limb_it++;
          doit_i_field_limb = doit_i_field(joker, 0, 0, scat_za_index_local, 0, joker);
          for(Index p_index = cloudbox_limits[0];
              p_index <= cloudbox_limits[1]; p_index ++)
          {
            // For this case the cloudbox goes down to the surface and we
            // look downwards. These cases are outside the cloudbox and
            // not needed. Switch is included here, as ppath_step_agenda
            // gives an error for such cases.
            if (p_index != 0)
            {
              cloud_ppath_update1D(ws, doit_i_field,
                                   p_index, scat_za_index_local,
                                   scat_za_grid,
                                   cloudbox_limits, doit_scat_field,
                                   propmat_clearsky_agenda, vmr_field,
                                   ppath_step_agenda, ppath_lraytrace,
                                   p_grid,  z_field, refellipsoid,
                                   t_field, f_grid, f_index,
                                   ext_mat_field, abs_vec_field,
                                   surface_rtprop_agenda, doit_za_interp,
                                   verbosity);

            }
          }

          conv_flag = true;
          for (Index p_index = 0;
               conv_flag && p_index < doit_i_field.nvitrines(); p_index++)
          {
            for (Index stokes_index = 0;
                 conv_flag && stokes_index < stokes_dim; stokes_index ++)
            {
              Numeric diff =
              doit_i_field(p_index, 0, 0, scat_za_index_local, 0, stokes_index)
              - doit_i_field_limb(p_index, stokes_index);

              // If the absolute difference of the components
              // is larger than the pre-defined values, continue with
              // another iteration
              Numeric diff_bt = invrayjean(diff, f_grid[f_index]);
              if (abs(diff_bt) > epsilon[stokes_index])
              {
                out2 << "Limb BT difference: " << diff_bt
                << " in stokes dim " << stokes_index << "\n";
                conv_flag = false;
              }
            }
          }
        }
        out2 << "Limb iterations: " << limb_it << "\n";
      }
    }// Closes loop over scat_za_grid.
} // End of the function.


/* Workspace method: Doxygen documentation will be auto-generated */
void
doit_i_fieldUpdateSeq3D(Workspace& ws,
                        // WS Output and Input:
                        Tensor6& doit_i_field,
                        // WS Input:
                        const Tensor6& doit_scat_field,
                        const ArrayOfIndex& cloudbox_limits,
                        // Calculate scalar gas absorption:
                        const Agenda& propmat_clearsky_agenda,
                        const Tensor4& vmr_field,
                        // Optical properties for single particle type:
                        const Agenda& spt_calc_agenda,
                        const Vector& scat_za_grid,
                        const Vector& scat_aa_grid,
                        const Tensor4& pnd_field,
                        // Optical properties for gases and particles:
                        const Agenda& opt_prop_part_agenda,
                        // Propagation path calculation:
                        const Agenda& ppath_step_agenda,
                        const Numeric& ppath_lraytrace,
                        const Vector& p_grid,
                        const Vector& lat_grid,
                        const Vector& lon_grid,
                        const Tensor3& z_field,
                        const Vector& refellipsoid,
                        // Calculate thermal emission:
                        const Tensor3& t_field,
                        const Vector& f_grid,
                        const Index& f_index,
                        const Index& doit_za_interp,
                        const Verbosity& verbosity)
{
  CREATE_OUT2;
  CREATE_OUT3;
  
  out2<<"  doit_i_fieldUpdateSeq3D: Radiative transfer calculatiuon in cloudbox.\n";
  out2 << "  ------------------------------------------------------------- \n";
  
  // ---------- Check the input ----------------------------------------

   // Agendas
  chk_not_empty( "propmat_clearsky_agenda",propmat_clearsky_agenda);
  chk_not_empty( "spt_calc_agenda", spt_calc_agenda);
  chk_not_empty( "opt_prop_part_agenda", opt_prop_part_agenda);
  chk_not_empty( "ppath_step_agenda", ppath_step_agenda);
  
  if (cloudbox_limits.nelem() != 6)
    throw runtime_error(
                        "The cloudbox dimension is not 3D! \n"
                        "Do you really want to do a 3D calculation? \n"
                        "For 1D use *doit_i_fieldUpdateSeq1D*.\n"
                        );

  // Number of zenith angles.
  const Index N_scat_za = scat_za_grid.nelem();
  
  if (scat_za_grid[0] != 0. || scat_za_grid[N_scat_za-1] != 180.)
    throw runtime_error("The range of *scat_za_grid* must [0 180].");
  
  // Number of azimuth angles.
  const Index N_scat_aa = scat_aa_grid.nelem();
  
  if (scat_aa_grid[0] != 0. || scat_aa_grid[N_scat_aa-1] != 360.)
    throw runtime_error("The range of *scat_za_grid* must [0 360]."); 

  // Check atmospheric grids
  chk_atm_grids(3, p_grid, lat_grid, lon_grid);

  // Check atmospheric fields
  chk_size("z_field", z_field, p_grid.nelem(), lat_grid.nelem(), 
           lon_grid.nelem());
  chk_size("t_field", t_field, p_grid.nelem(), lat_grid.nelem(), 
           lon_grid.nelem());
  
  // Frequency grid
  //
  if( f_grid.nelem() == 0 )
    throw runtime_error( "The frequency grid is empty." );
  chk_if_increasing( "f_grid", f_grid );
  
  // Is the frequency index valid?
  if ( f_index >= f_grid.nelem() )
    throw runtime_error("*f_index* is greater than number of elements in the\n"
                        "frequency grid.\n");
  
  if( !(doit_za_interp == 0  ||  doit_za_interp == 1 ) )
    throw runtime_error( "Interpolation method is not defined. Use \n"
                         "*doit_za_interpSet*.\n");
  
  const Index stokes_dim = doit_scat_field.ncols();
  assert(stokes_dim > 0 || stokes_dim < 5); 
  
  // These variables are calculated internally, so assertions should be o.k.
  assert( is_size( doit_i_field, 
                   (cloudbox_limits[1] - cloudbox_limits[0]) + 1,
                   (cloudbox_limits[3] - cloudbox_limits[2]) + 1, 
                   (cloudbox_limits[5] - cloudbox_limits[4]) + 1,
                   N_scat_za,
                   N_scat_aa,
                   stokes_dim));

  assert( is_size( doit_scat_field, 
                   (cloudbox_limits[1] - cloudbox_limits[0]) + 1,
                   (cloudbox_limits[3] - cloudbox_limits[2]) + 1, 
                   (cloudbox_limits[5] - cloudbox_limits[4]) + 1,
                   N_scat_za,
                   N_scat_aa,
                   stokes_dim));
  
  // FIXME: Check *vmr_field* 
  
  // ---------- End of checks ------------------------------------------

  
  //=======================================================================
  // Calculate coefficients for all positions in the cloudbox 
  //=======================================================================
  out3 << "Calculate single particle properties \n";

  // At this place only the particle properties are calculated. Gaseous
  // absorption is calculated inside the radiative transfer part. Inter-
  // polating absorption coefficients for gaseous species gives very bad
  // results, so they are 
  // calulated for interpolated VMRs, temperature and pressure.
  
   // Define shorter names for cloudbox_limits.

  const Index p_low = cloudbox_limits[0];
  const Index p_up = cloudbox_limits[1];
  const Index lat_low = cloudbox_limits[2];
  const Index lat_up = cloudbox_limits[3];
  const Index lon_low = cloudbox_limits[4];
  const Index lon_up = cloudbox_limits[5];

  // To use special interpolation functions for atmospheric fields we 
  // use ext_mat_field and abs_vec_field:
  Tensor5 ext_mat_field(p_up-p_low+1, lat_up-lat_low+1, lon_up-lon_low+1,
                        stokes_dim, stokes_dim, 0.);
  Tensor4 abs_vec_field(p_up-p_low+1, lat_up-lat_low+1, lon_up-lon_low+1,
                        stokes_dim, 0.);
 
  
  //Loop over all directions, defined by scat_za_grid 
  for(Index scat_za_index = 0; scat_za_index < N_scat_za; scat_za_index ++)
    {
      //Loop over azimuth directions (scat_aa_grid). First and last point in 
      // azimuth angle grid are euqal. Start with second element.
      for(Index scat_aa_index = 1; scat_aa_index < N_scat_aa; scat_aa_index ++)
        {
         //==================================================================
          // Radiative transfer inside the cloudbox
          //==================================================================

          // This function has to be called inside the angular loop, as
          // it spt_calc_agenda takes *scat_za_index* and *scat_aa_index* 
          // from the workspace.
          cloud_fieldsCalc(ws, ext_mat_field, abs_vec_field, 
                           spt_calc_agenda, 
                           opt_prop_part_agenda, scat_za_index, 
                           scat_aa_index, cloudbox_limits, t_field, 
                           pnd_field, verbosity);
          

          Vector stokes_vec(stokes_dim,0.);
          
          Numeric theta_lim = 180. - asin((refellipsoid[0]+z_field(p_low,0,0))
                                         /(refellipsoid[0]+z_field(p_up,0,0)))
            *RAD2DEG;

          // Sequential update for uplooking angles
          if ( scat_za_grid[scat_za_index] <= 90.) 
            {
              // Loop over all positions inside the cloud box defined by the 
              // cloudbox_limits exculding the upper boundary. For uplooking
              // directions, we start from cloudbox_limits[1]-1 and go down
              // to cloudbox_limits[0] to do a sequential update of the
              // aradiation field
              for(Index p_index = p_up-1; p_index >= p_low; p_index --)
                {
                  for(Index lat_index = lat_low; lat_index <= lat_up; 
                      lat_index ++)
                    {
                      for(Index lon_index = lon_low; lon_index <= lon_up; 
                          lon_index ++)
                        {
                          cloud_ppath_update3D(ws, doit_i_field,
                                               p_index, lat_index, 
                                               lon_index, scat_za_index, 
                                               scat_aa_index, scat_za_grid, 
                                               scat_aa_grid, cloudbox_limits, 
                                               doit_scat_field, 
                                               propmat_clearsky_agenda,
                                               vmr_field, ppath_step_agenda, 
                                               ppath_lraytrace, p_grid, 
                                               lat_grid, lon_grid, z_field, 
                                               refellipsoid, t_field,
                                               f_grid, f_index,
                                               ext_mat_field, abs_vec_field,
                                               doit_za_interp,
                                               verbosity);
                        }
                    }
                }
            }// close up-looking case
          else if ( scat_za_grid[scat_za_index] > theta_lim) 
            {
              //
              // Sequential updating for downlooking angles
              //
              for(Index p_index = p_low+1; p_index <= p_up; p_index ++)
                {
                  for(Index lat_index = lat_low; lat_index <= lat_up; 
                      lat_index ++)
                    {
                      for(Index lon_index = lon_low; lon_index <= lon_up; 
                          lon_index ++)
                        {
                          cloud_ppath_update3D(ws, doit_i_field,
                                               p_index, lat_index, 
                                               lon_index, scat_za_index, 
                                               scat_aa_index, scat_za_grid, 
                                               scat_aa_grid, cloudbox_limits, 
                                               doit_scat_field, 
                                               propmat_clearsky_agenda,
                                               vmr_field, ppath_step_agenda, 
                                               ppath_lraytrace, p_grid, 
                                               lat_grid, lon_grid, z_field, 
                                               refellipsoid, t_field,
                                               f_grid, f_index,
                                               ext_mat_field, abs_vec_field,
                                               doit_za_interp,
                                               verbosity);
                        }
                    }
                }
            } // end if downlooking.
      
          //
          // Limb looking:
          // We have to include a special case here, as we may miss the endpoints
          // when the intersection point is at the same level as the actual point.
          // To be save we loop over the full cloudbox. Inside the function 
          // cloud_ppath_update3D it is checked whether the intersection point is 
          // inside the cloudbox or not.
          else if (  scat_za_grid[scat_za_index] > 90. &&
                     scat_za_grid[scat_za_index] < theta_lim ) 
            {
              for(Index p_index = p_low; p_index <= p_up; p_index ++)
                {
                  // For this case the cloudbox goes down to the surface an we
                  // look downwards. These cases are outside the cloudbox and 
                  // not needed. Switch is included here, as ppath_step_agenda 
                  // gives an error for such cases.
                  if (!(p_index == 0 && scat_za_grid[scat_za_index] > 90.))
                    {
                      for(Index lat_index = lat_low; lat_index <= lat_up; 
                          lat_index ++)
                        {
                          for(Index lon_index = lon_low; lon_index <= lon_up; 
                              lon_index ++)
                            {
                              cloud_ppath_update3D(ws, doit_i_field,
                                                   p_index, 
                                                   lat_index, 
                                                   lon_index, scat_za_index, 
                                                   scat_aa_index,
                                                   scat_za_grid, 
                                                   scat_aa_grid,
                                                   cloudbox_limits, 
                                                   doit_scat_field, 
                                                   propmat_clearsky_agenda,
                                                   vmr_field, ppath_step_agenda,
                                                   ppath_lraytrace, p_grid, 
                                                   lat_grid, lon_grid,
                                                   z_field, 
                                                   refellipsoid, 
                                                   t_field, f_grid, f_index,
                                                   ext_mat_field,
                                                   abs_vec_field,
                                                   doit_za_interp,
                                                   verbosity); 
                            }
                        }
                    }
                }
            }
        } //  Closes loop over aa_grid.
    }// Closes loop over scat_za_grid.

  doit_i_field(joker, joker, joker, joker, 0, joker) = 
    doit_i_field(joker, joker, joker, joker, N_scat_aa-1, joker);
  
}


/* Workspace method: Doxygen documentation will be auto-generated */
void
doit_i_fieldUpdateSeq1DPP(Workspace& ws,
                          // WS Output:
                          Tensor6& doit_i_field,
                          // spt_calc_agenda:
                          Index& scat_za_index ,
                          // WS Input:
                          const Tensor6& doit_scat_field,
                          const ArrayOfIndex& cloudbox_limits,
                          // Calculate scalar gas absorption:
                          const Agenda& propmat_clearsky_agenda,
                          const Tensor4& vmr_field,
                          // Optical properties for single particle type:
                          const Agenda& spt_calc_agenda,
                          const Vector& scat_za_grid,
                          const Tensor4& pnd_field,
                          // Optical properties for gases and particles:
                          const Agenda& opt_prop_part_agenda,
                          // Propagation path calculation:
                          const Vector& p_grid,
                          const Tensor3& z_field,
                          // Calculate thermal emission:
                          const Tensor3& t_field,
                          const Vector& f_grid,
                          const Index& f_index,
                          const Verbosity& verbosity)
{
  CREATE_OUT2;
  CREATE_OUT3;

  out2 << "  doit_i_fieldUpdateSeq1DPP: Radiative transfer calculation in cloudbox.\n";
  out2 << "  --------------------------------------------------------------------- \n";
  
  const Index stokes_dim = doit_scat_field.ncols();
  //  const Index atmosphere_dim = 1;

  //Check the input
  
  if (stokes_dim < 0 || stokes_dim > 4)
    throw runtime_error(
                        "The dimension of stokes vector must be"
                        "1,2,3, or 4");
  
  assert( is_size( doit_i_field, 
                      (cloudbox_limits[1] - cloudbox_limits[0]) + 1,
                      1, 
                      1,
                      scat_za_grid.nelem(), 
                      1,
                      stokes_dim));

  assert( is_size( doit_scat_field, 
                      (cloudbox_limits[1] - cloudbox_limits[0]) + 1,
                      1, 
                      1,
                      scat_za_grid.nelem(), 
                      1,
                      stokes_dim));  
  
  // Is the frequency index valid?
  assert( f_index <= f_grid.nelem() );

  // End of checks



  // Number of zenith angles.
  const Index N_scat_za = scat_za_grid.nelem();

  
  
  //=======================================================================
  // Calculate scattering coefficients for all positions in the cloudbox 
  //=======================================================================
  out3 << "Calculate single particle properties \n";

  // At this place only the particle properties are calculated. Gaseous
  // absorption is calculated inside the radiative transfer part. Inter-
  // polating absorption coefficients for gaseous species gives very bad
  // results, so they are 
  // calulated for interpolated VMRs, temperature and pressure.
  
  // To use special interpolation functions for atmospheric fields we 
  // use ext_mat_field and abs_vec_field:
     
      Tensor5 ext_mat_field(cloudbox_limits[1] - cloudbox_limits[0] + 1, 1, 1,
                            stokes_dim, stokes_dim, 0.);
      Tensor4 abs_vec_field(cloudbox_limits[1] - cloudbox_limits[0] + 1, 1, 1,
                            stokes_dim, 0.);

      //Loop over all directions, defined by scat_za_grid 
  for(scat_za_index = 0; scat_za_index < N_scat_za; scat_za_index ++)
    {
      
      //Only dummy variables:
      Index scat_aa_index = 0;
      
      cloud_fieldsCalc(ws, ext_mat_field, abs_vec_field, 
                       spt_calc_agenda, 
                       opt_prop_part_agenda, scat_za_index, scat_aa_index, 
                       cloudbox_limits, t_field, 
                       pnd_field, verbosity);

      //======================================================================
      // Radiative transfer inside the cloudbox
      //=====================================================================
      
      Vector stokes_vec(stokes_dim,0.);
       // Sequential update for uplooking angles
      if ( scat_za_grid[scat_za_index] <= 90) 
        {
          // Loop over all positions inside the cloud box defined by the 
          // cloudbox_limits exculding the upper boundary. For uplooking
          // directions, we start from cloudbox_limits[1]-1 and go down
          // to cloudbox_limits[0] to do a sequential update of the
          // aradiation field
     
          // Loop over all positions inside the cloudbox defined by the 
          // cloudbox_limits.
          for(Index p_index = cloudbox_limits[1] -1; p_index
                >= cloudbox_limits[0]; p_index --)
            {
              cloud_ppath_update1D_planeparallel(ws, doit_i_field,
                                                 p_index, scat_za_index,
                                                 scat_za_grid,
                                                 cloudbox_limits,
                                                 doit_scat_field,
                                                 propmat_clearsky_agenda,
                                                 vmr_field,
                                                 p_grid, z_field,
                                                 t_field, 
                                                 f_grid, f_index,
                                                 ext_mat_field,
                                                 abs_vec_field,
                                                 verbosity); 
            }   
        }
      else if ( scat_za_grid[scat_za_index] > 90) 
        {
          //
          // Sequential updating for downlooking angles
          //
          for(Index p_index = cloudbox_limits[0]+1; p_index
                <= cloudbox_limits[1]; p_index ++)
            {
              cloud_ppath_update1D_planeparallel(ws, doit_i_field,
                                                 p_index, scat_za_index,
                                                 scat_za_grid,
                                                 cloudbox_limits,
                                                 doit_scat_field,
                                                 propmat_clearsky_agenda,
                                                 vmr_field,
                                                 p_grid, z_field,
                                                 t_field, 
                                                 f_grid, f_index,
                                                 ext_mat_field, 
                                                 abs_vec_field,
                                                 verbosity);  
            }// Close loop over p_grid (inside cloudbox).
        } // end if downlooking.
      
    }// Closes loop over scat_za_grid.
}


/* Workspace method: Doxygen documentation will be auto-generated */
void DoitInit(//WS Output
              Index& scat_p_index,
              Index& scat_lat_index,
              Index& scat_lon_index,
              Index& scat_za_index,
              Index& scat_aa_index,
              Tensor6& doit_scat_field,
              Tensor6& doit_i_field,
              Index& doit_is_initialized,
              // WS Input
              const Index& stokes_dim,
              const Index& atmosphere_dim,
              const Vector& scat_za_grid,
              const Vector& scat_aa_grid,
              const Index& doit_za_grid_size,
              const Index& cloudbox_on,
              const ArrayOfIndex& cloudbox_limits,
              const ArrayOfSingleScatteringData& scat_data_array,
              const Verbosity& verbosity)
{
  if (!cloudbox_on)
  {
    CREATE_OUT0;
    doit_is_initialized = 0;
    out0 << "  Cloudbox is off, DOIT calculation will be skipped.\n";
    return;
  }
  
  // -------------- Check the input ------------------------------
  
  if (stokes_dim < 0 || stokes_dim > 4)
    throw runtime_error(
                        "The dimension of stokes vector must be"
                        "1,2,3, or 4");

  chk_if_in_range( "atmosphere_dim", atmosphere_dim, 1, 3 );
  
  // Number of zenith angles.
  const Index N_scat_za = scat_za_grid.nelem();
  
  if (scat_za_grid[0] != 0. || scat_za_grid[N_scat_za-1] != 180.)
    throw runtime_error("The range of *scat_za_grid* must [0 180].");
  
  if (!is_increasing(scat_za_grid))
    throw runtime_error("*scat_za_grid* must be increasing.");

  // Number of azimuth angles.
  const Index N_scat_aa = scat_aa_grid.nelem();
  
  if (scat_aa_grid[0] != 0. || scat_aa_grid[N_scat_aa-1] != 360.)
    throw runtime_error("The range of *scat_aa_grid* must [0 360].");

  if (doit_za_grid_size < 16)
    throw runtime_error(
     "*doit_za_grid_size* must be greater than 15 for accurate results");
  else if (doit_za_grid_size > 100)
  {
    CREATE_OUT1;
    out1 << "Warning: doit_za_grid_size is very large which means that the \n"
         << "calculation will be very slow. The recommended value is 19.\n";
  }
  
  if ( cloudbox_limits.nelem()!= 2*atmosphere_dim)
    throw runtime_error(
                        "*cloudbox_limits* is a vector which contains the"
                        "upper and lower limit of the cloud for all "
                        "atmospheric dimensions. So its dimension must"
                        "be 2 x *atmosphere_dim*");

  if (scat_data_array.nelem() == 0)
    throw runtime_error(
                         "No scattering data files have been added.\n"
                         "Please use the WSM *ParticleTypeAdd* or \n"
                         "*ParticleTypeAddAll* to define the cloud \n"
                         "properties for the scattering calculation.\n"
                         );

  //------------- end of checks ---------------------------------------
  
  
  // Initialize indices

  scat_p_index = 0;
  scat_lat_index = 0;
  scat_lon_index = 0;
  scat_za_index = 0;
  scat_aa_index = 0;
  
  
  // Resize and initialize radiation field in the cloudbox
  if (atmosphere_dim == 1)
    {
      doit_i_field.resize((cloudbox_limits[1] - cloudbox_limits[0]) +1,
                     1, 
                     1,
                     scat_za_grid.nelem(), 
                     1,
                     stokes_dim);
      
      doit_scat_field.resize((cloudbox_limits[1] - cloudbox_limits[0]) +1,
                        1, 
                        1,
                        scat_za_grid.nelem(), 
                        1,
                        stokes_dim);
    }
  else if (atmosphere_dim == 3)
    {
      doit_i_field.resize((cloudbox_limits[1] - cloudbox_limits[0]) +1,
                     (cloudbox_limits[3] - cloudbox_limits[2]) +1, 
                     (cloudbox_limits[5] - cloudbox_limits[4]) +1,
                     scat_za_grid.nelem(), 
                     scat_aa_grid.nelem(),
                     stokes_dim);
      
      doit_scat_field.resize((cloudbox_limits[1] - cloudbox_limits[0]) +1,
                        (cloudbox_limits[3] - cloudbox_limits[2]) +1, 
                        (cloudbox_limits[5] - cloudbox_limits[4]) +1,
                        scat_za_grid.nelem(), 
                        scat_aa_grid.nelem(),
                        stokes_dim);
    }
  else 
    {
      throw runtime_error(
                        "Scattering calculations are not possible for a 2D"
                        "atmosphere. If you want to do scattering calculations"
                        "*atmosphere_dim* has to be either 1 or 3"
                          );
    }
  
  doit_i_field = 0.;
  doit_scat_field = 0.;
  doit_is_initialized = 1;
}


/* Workspace method: Doxygen documentation will be auto-generated */
void DoitWriteIterationFields(//WS input 
                              const Index& doit_iteration_counter,
                              const Tensor6& doit_i_field,
                              //Keyword:
                              const ArrayOfIndex& iterations,
                              const Verbosity& verbosity)
{
  // Checks of doit_i_field have been done elsewhere, e.g. in
  // scat_fieldCalc(Limb).

  // If the number of iterations is less than a number specified in the 
  // keyword *iterations*, this number will be ignored.

  ostringstream os;
  os << doit_iteration_counter;
  
  // All iterations are written to files
  if( iterations[0] == 0 )
    {
      xml_write_to_file("doit_iteration_" + os.str() + ".xml",
                        doit_i_field, FILE_TYPE_ASCII, 0, verbosity);
    }
  
  // Only the iterations given by the keyword are written to a file
  else
    {
      for (Index i = 0; i<iterations.nelem(); i++)
        {
          if (doit_iteration_counter == iterations[i])
            xml_write_to_file("doit_iteration_" + os.str() + ".xml", 
                              doit_i_field, FILE_TYPE_ASCII, 0, verbosity);
        }
    }
}


/* Workspace method: Doxygen documentation will be auto-generated */
void
doit_scat_fieldCalc(Workspace& ws,
                    // WS Output and Input
                    Tensor6& doit_scat_field,
                    //WS Input:
                    const Agenda& pha_mat_spt_agenda,
                    const Tensor6& doit_i_field,
                    const Tensor4& pnd_field,
                    const Tensor3& t_field,
                    const Index& atmosphere_dim,
                    const ArrayOfIndex& cloudbox_limits,
                    const Vector& scat_za_grid,
                    const Vector& scat_aa_grid,
                    const Index& doit_za_grid_size,
                    const Verbosity& verbosity)
  
{
  CREATE_OUT2;
  CREATE_OUT3;
  
  // ------------ Check the input -------------------------------

  // Agenda for calculation of phase matrix
  chk_not_empty( "pha_mat_spt_agenda", pha_mat_spt_agenda);

  // Number of zenith angles.
  const Index Nza = scat_za_grid.nelem();
  
  if (scat_za_grid[0] != 0. || scat_za_grid[Nza-1] != 180.)
    throw runtime_error("The range of *scat_za_grid* must [0 180].");
  
  // Number of azimuth angles.
  const Index Naa = scat_aa_grid.nelem();
  
  if (scat_aa_grid[0] != 0. || scat_aa_grid[Naa-1] != 360.)
    throw runtime_error("The range of *scat_za_grid* must [0 360]."); 

  // Get stokes dimension from *doit_scat_field*:
  const Index stokes_dim = doit_scat_field.ncols();
  assert(stokes_dim > 0 || stokes_dim < 5); 

  // Size of particle number density field can not be checked here, 
  // because the function does not use the atmospheric grids.
  // Check will be included after fixing the size of pnd field, so 
  // that it is defined only inside the cloudbox. 
  
  // Check atmospheric dimension and dimensions of 
  // radiation field (*doit_i_field*) and scattering integral field
  // (*doit_scat_field*)
  if (atmosphere_dim == 1)
    {
      assert( is_size(doit_i_field, 
                      (cloudbox_limits[1] - cloudbox_limits[0]) +1,
                      1, 1, Nza, 1, stokes_dim));
      assert( is_size(doit_scat_field, 
                      (cloudbox_limits[1] - cloudbox_limits[0]) +1,
                      1, 1, scat_za_grid.nelem(), 1, stokes_dim));
    }
  else if (atmosphere_dim == 3)
    {
      assert ( is_size( doit_i_field, 
                        (cloudbox_limits[1] - cloudbox_limits[0]) +1,
                        (cloudbox_limits[3] - cloudbox_limits[2]) +1, 
                        (cloudbox_limits[5] - cloudbox_limits[4]) +1,
                        Nza, Naa, stokes_dim));
      assert ( is_size( doit_scat_field, 
                        (cloudbox_limits[1] - cloudbox_limits[0]) +1,
                        (cloudbox_limits[3] - cloudbox_limits[2]) +1, 
                        (cloudbox_limits[5] - cloudbox_limits[4]) +1,
                        Nza, Naa, stokes_dim));
    }
  else
    {
      ostringstream os;
      os << "The atmospheric dimension must be 1D or 3D \n"
         << "for scattering calculations using the DOIT\n"
         << "module, but it is not. The value of *atmosphere_dim*\n"
         << "is " << atmosphere_dim << ".";
      throw runtime_error( os.str() );
    }

  if ( cloudbox_limits.nelem()!= 2*atmosphere_dim)
    throw runtime_error(
                        "*cloudbox_limits* is a vector which contains the"
                        "upper and lower limit of the cloud for all "
                        "atmospheric dimensions. So its dimension must"
                        "be 2 x *atmosphere_dim*");
  
  // This function should only be used for down-looking cases where no 
  // optimized zenith angle grid is required. 
  if (doit_za_grid_size != Nza)
    throw runtime_error(
                        "The zenith angle grids for the computation of\n"
                        "the scattering integral and the RT part must \n"
                        "be equal. Check definitions in \n"
                        "*DoitAngularGridsSet*. The keyword \n"
                        "'za_grid_opt_file' should be empty. \n"
                        );

  // ------ end of checks -----------------------------------------------

  // Initialize variables *pha_mat* and *pha_mat_spt*
  Tensor4 pha_mat_local(doit_za_grid_size, scat_aa_grid.nelem(), 
                        stokes_dim, stokes_dim, 0.);
  
  Tensor5 pha_mat_spt_local(pnd_field.nbooks(), doit_za_grid_size,
                            scat_aa_grid.nelem(), stokes_dim, stokes_dim, 0.);
  
  // Equidistant step size for integration
  Vector grid_stepsize(2);
  grid_stepsize[0] = 180./(Numeric)(doit_za_grid_size - 1);
  grid_stepsize[1] = 360./(Numeric)(Naa - 1);     
  
  Tensor3 product_field(Nza, Naa, stokes_dim, 0);
 
  out2 << "  Calculate the scattered field\n";
  
  if  ( atmosphere_dim == 1 )
    {
      Index scat_aa_index_local = 0;
      
      // Get pha_mat at the grid positions
      // Since atmosphere_dim = 1, there is no loop over lat and lon grids
      for (Index p_index = 0; p_index<=cloudbox_limits[1]-cloudbox_limits[0] ;
           p_index++)
        {
          Numeric rtp_temperature_local =
            t_field(p_index + cloudbox_limits[0], 0, 0);
          //There is only loop over zenith angle grid ; no azimuth angle grid.
          for (Index scat_za_index_local = 0;
               scat_za_index_local < Nza; scat_za_index_local ++)
            {
              // Dummy index
              Index index_zero = 0;
              
              // Calculate the phase matric of a single particle type
              out3 << "Calculate the phase matrix \n"; 
              pha_mat_spt_agendaExecute(ws, pha_mat_spt_local,
                                        scat_za_index_local,
                                        index_zero,
                                        index_zero,
                                        p_index,
                                        scat_aa_index_local,
                                        rtp_temperature_local,
                                        pha_mat_spt_agenda);
              
              // Sum over all particle types
              pha_matCalc(pha_mat_local, pha_mat_spt_local, pnd_field, 
                          atmosphere_dim, p_index, 0, 
                          0, verbosity);

              out3 << "Multiplication of phase matrix with incoming" << 
                " intensities \n";
              
              product_field = 0;
              
              // za_in and aa_in are for incoming zenith and azimuth 
              //angle direction for which pha_mat is calculated
              for (Index za_in = 0; za_in < Nza; ++ za_in)
                { 
                  for (Index aa_in = 0; aa_in < Naa; ++ aa_in)
                    {
                      // Multiplication of phase matrix with incoming 
                      // intensity field.
                      
                      for ( Index i = 0; i < stokes_dim; i++)
                        {
                          for (Index j = 0; j< stokes_dim; j++)
                            {
                              product_field(za_in, aa_in, i) +=
                                pha_mat_local(za_in, aa_in, i, j) * 
                                doit_i_field(p_index, 0, 0, za_in, 0, j);
                          }
                      }
                      
                    }//end aa_in loop
                }//end za_in loop
              //integration of the product of ifield_in and pha
              //  over zenith angle and azimuth angle grid. It calls
              for (Index i = 0; i < stokes_dim; i++)
                {
                  doit_scat_field( p_index, 0, 0, scat_za_index_local, 0, i)
                    = AngIntegrate_trapezoid_opti
                    (product_field(joker, joker, i),
                     scat_za_grid,
                     scat_aa_grid,
                     grid_stepsize);
                  
                }//end i loop
            }//end za_prop loop
        }//end p_index loop
    }//end atmosphere_dim = 1
  
  
  //atmosphere_dim = 3
  else if( atmosphere_dim == 3 )
    {
      /*there is a loop over pressure, latitude and longitudeindex
        when we calculate the pha_mat from pha_mat_spt and pnd_field
        using the method pha_matCalc.  */
      
      for (Index p_index = 0; p_index <=
             cloudbox_limits[1] - cloudbox_limits[0];
           p_index++)
        {
          for (Index lat_index = 0; lat_index <= 
                 cloudbox_limits[3] - cloudbox_limits[2]; lat_index++)
            {
              for (Index lon_index = 0; lon_index <= 
                     cloudbox_limits[5]-cloudbox_limits[4]; lon_index++)
                {
                  Numeric rtp_temperature_local = 
                    t_field(p_index + cloudbox_limits[0],
                            lat_index + cloudbox_limits[2],
                            lon_index + cloudbox_limits[4]);
                
                  for (Index scat_aa_index_local = 1; 
                       scat_aa_index_local < Naa; 
                       scat_aa_index_local++)
                    {
                      for (Index scat_za_index_local = 0; 
                           scat_za_index_local < Nza; 
                           scat_za_index_local ++)
                        {
                          out3 << "Calculate phase matrix \n";
                          pha_mat_spt_agendaExecute(ws, pha_mat_spt_local,
                                                    scat_za_index_local,
                                                    lat_index,
                                                    lon_index,
                                                    p_index, 
                                                    scat_aa_index_local,
                                                    rtp_temperature_local,
                                                    pha_mat_spt_agenda);
                          
                          pha_matCalc(pha_mat_local, pha_mat_spt_local,
                                      pnd_field, 
                                      atmosphere_dim, 
                                      p_index, 
                                      lat_index, 
                                      lon_index,
                                      verbosity);
                          
                          product_field = 0;
                          
                          //za_in and aa_in are the incoming directions
                          //for which pha_mat_spt is calculated
                          for (Index za_in = 0; za_in < Nza; ++ za_in)
                            {
                              for (Index aa_in = 0; aa_in < Naa; ++ aa_in)
                                { 
                                  // Multiplication of phase matrix
                                  // with incloming intensity field.
                                  for ( Index i = 0; i < stokes_dim; i++)
                                    {
                                      for (Index j = 0; j< stokes_dim; j++)
                                        {
                                          product_field(za_in, aa_in, i) +=
                                            pha_mat_local
                                            (za_in, aa_in, i, j) * 
                                            doit_i_field(p_index, lat_index, 
                                                         lon_index, 
                                                         scat_za_index_local,
                                                         scat_aa_index_local,
                                                         j);
                                        }
                                    }
                                }//end aa_in loop
                            }//end za_in loop
                          //integration of the product of ifield_in and pha
                          //over zenith angle and azimuth angle grid. It 
                          //calls here the integration routine 
                          //AngIntegrate_trapezoid_opti
                          for (Index i = 0; i < stokes_dim; i++)
                            {
                              doit_scat_field( p_index,
                                               lat_index,
                                               lon_index,
                                               scat_za_index_local, 
                                               scat_aa_index_local,
                                               i)  =  
                                AngIntegrate_trapezoid_opti(product_field
                                                            ( joker,
                                                              joker, i),
                                                            scat_za_grid,
                                                            scat_aa_grid,
                                                            grid_stepsize);
                            }//end i loop
                        }//end aa_prop loop
                    }//end za_prop loop
                }//end lon loop
            }// end lat loop
        }// end p loop
      // aa = 0 is the same as aa = 180:
      doit_scat_field(joker, joker, joker, joker, 0, joker) =
        doit_scat_field(joker, joker, joker, joker, Naa-1, joker);
    }// end atmosphere_dim = 3
}


/* Workspace method: Doxygen documentation will be auto-generated */
void
doit_scat_fieldCalcLimb(Workspace& ws,
                        // WS Output and Input
                        Tensor6& doit_scat_field,
                        //WS Input:
                        const Agenda& pha_mat_spt_agenda,
                        const Tensor6& doit_i_field,
                        const Tensor4& pnd_field,
                        const Tensor3& t_field,
                        const Index& atmosphere_dim,
                        const ArrayOfIndex& cloudbox_limits,
                        const Vector& scat_za_grid,
                        const Vector& scat_aa_grid,
                        const Index& doit_za_grid_size,
                        const Index& doit_za_interp,
                        const Verbosity& verbosity)
{
  CREATE_OUT2;
  CREATE_OUT3;
  
  // ------------ Check the input -------------------------------
   
  // Agenda for calculation of phase matrix
  chk_not_empty( "pha_mat_spt_agenda", pha_mat_spt_agenda);
   
  // Number of zenith angles.
  const Index Nza = scat_za_grid.nelem();

  if (scat_za_grid[0] != 0. || scat_za_grid[Nza-1] != 180.)
    throw runtime_error("The range of *scat_za_grid* must [0 180].");
   
  // Number of azimuth angles.
  const Index Naa = scat_aa_grid.nelem();
   
  if (scat_aa_grid[0] != 0. || scat_aa_grid[Naa-1] != 360.)
    throw runtime_error("The range of *scat_aa_grid* must [0 360].");

  // Get stokes dimension from *doit_scat_field*:
  const Index stokes_dim = doit_scat_field.ncols();
  assert(stokes_dim > 0 || stokes_dim < 5); 

  // Size of particle number density field can not be checked here, 
  // because the function does not use the atmospheric grids.
  // Check will be included after fixing the size of pnd field, so 
  // that it is defined only inside the cloudbox. 
  
  // Check atmospheric dimension and dimensions of 
  // radiation field (*doit_i_field*) and scattering integral field
  // (*doit_scat_field*)
  if (atmosphere_dim == 1)
    {
      assert( is_size(doit_i_field, 
                      (cloudbox_limits[1] - cloudbox_limits[0]) +1,
                      1, 1, Nza, 1, stokes_dim));
      assert( is_size(doit_scat_field, 
                      (cloudbox_limits[1] - cloudbox_limits[0]) +1,
                      1, 1, scat_za_grid.nelem(), 1, stokes_dim));
    }
  else if (atmosphere_dim == 3)
    {
      assert ( is_size( doit_i_field, 
                        (cloudbox_limits[1] - cloudbox_limits[0]) +1,
                        (cloudbox_limits[3] - cloudbox_limits[2]) +1, 
                        (cloudbox_limits[5] - cloudbox_limits[4]) +1,
                        Nza, Naa, stokes_dim));
      assert ( is_size( doit_scat_field, 
                        (cloudbox_limits[1] - cloudbox_limits[0]) +1,
                        (cloudbox_limits[3] - cloudbox_limits[2]) +1, 
                        (cloudbox_limits[5] - cloudbox_limits[4]) +1,
                        Nza, Naa, stokes_dim));
    }
  else
    {
      ostringstream os;
      os << "The atmospheric dimension must be 1D or 3D \n"
         << "for scattering calculations using the DOIT\n"
         << "module, but it is not. The value of *atmosphere_dim*\n"
         << "is " << atmosphere_dim << ".";
      throw runtime_error( os.str() );
    }
  
  if( !(doit_za_interp == 0  ||  doit_za_interp == 1 ) )
    throw runtime_error( "Interpolation method is not defined. Use \n"
                         "*doit_za_interpSet*.\n");

  if ( cloudbox_limits.nelem()!= 2*atmosphere_dim)
    throw runtime_error(
                        "*cloudbox_limits* is a vector which contains the"
                        "upper and lower limit of the cloud for all "
                        "atmospheric dimensions. So its dimension must"
                        "be 2 x *atmosphere_dim*");
  
  if (doit_za_grid_size < 16)
    throw runtime_error(
                        "*doit_za_grid_size* must be greater than 15 for"
                        "accurate results");
  else if (doit_za_grid_size > 100)
  {
    CREATE_OUT1;
    out1 << "Warning: doit_za_grid_size is very large which means that the \n"
         << "calculation will be very slow. The recommended value is 19.\n";
  }

  // ------ end of checks -----------------------------------------------
  
  // Initialize variables *pha_mat* and *pha_mat_spt*
  Tensor4 pha_mat_local(doit_za_grid_size, scat_aa_grid.nelem(), 
                        stokes_dim, stokes_dim, 0.);

  Tensor5 pha_mat_spt_local(pnd_field.nbooks(), doit_za_grid_size,
                            scat_aa_grid.nelem(), stokes_dim, stokes_dim, 0.);

  // Create the grids for the calculation of the scattering integral.
  Vector za_grid;
  nlinspace(za_grid, 0, 180, doit_za_grid_size);
 
  // Two interpolations are required. First we have to interpolate the 
  // intensity field on the equidistant grid: 
  ArrayOfGridPos gp_za_i(doit_za_grid_size);
  gridpos(gp_za_i, scat_za_grid, za_grid);
  
  Matrix itw_za_i(doit_za_grid_size, 2);
  interpweights(itw_za_i, gp_za_i);

  // Intensity field interpolated on equidistant grid.
  Matrix doit_i_field_int(doit_za_grid_size, stokes_dim, 0);

  // Second, we have to interpolate the scattering integral on the RT
  // zenith angle grid.
  ArrayOfGridPos gp_za(Nza);
  gridpos(gp_za, za_grid, scat_za_grid);

  Matrix itw_za(Nza, 2);
  interpweights(itw_za, gp_za);
  
  // Original scattered field, on equidistant zenith angle grid.
  Matrix doit_scat_field_org(doit_za_grid_size, stokes_dim, 0);
  
  //  Grid stepsize of zenith and azimuth angle grid, these are needed for the 
  // integration function. 
  Vector grid_stepsize(2);
  grid_stepsize[0] = 180./(Numeric)(doit_za_grid_size - 1);
  grid_stepsize[1] = 360./(Numeric)(Naa - 1);
    
  Tensor3 product_field(doit_za_grid_size, Naa, stokes_dim, 0);

  if  ( atmosphere_dim == 1 )
    {
      Index scat_aa_index_local = 0;
      
      // Get pha_mat at the grid positions
      // Since atmosphere_dim = 1, there is no loop over lat and lon grids
      for (Index p_index = 0;
           p_index <= cloudbox_limits[1]-cloudbox_limits[0];
           p_index++)
        {
          Numeric rtp_temperature_local = 
            t_field(p_index + cloudbox_limits[0], 0, 0);
          // Interpolate intensity field:
          for (Index i = 0; i < stokes_dim; i++)
            {
              if (doit_za_interp == 0)
                {
                  interp(doit_i_field_int(joker, i), itw_za_i, 
                         doit_i_field(p_index, 0, 0, joker, 0, i), gp_za_i);
                } 
              else if (doit_za_interp == 1)
                {
                  // Polynomial
                  for(Index za = 0; za < za_grid.nelem(); za++)
                    {
                      doit_i_field_int(za, i) = 
                        interp_poly(scat_za_grid, 
                                     doit_i_field(p_index, 0, 0, joker, 0, i),
                                     za_grid[za],
                                     gp_za_i[za]);
                    }
                }
              // doit_za_interp must be 0 or 1 (linear or polynomial)!!!
              else assert(false);
            }       
          
          //There is only loop over zenith angle grid; no azimuth angle grid.
          for( Index scat_za_index_local = 0;
               scat_za_index_local < doit_za_grid_size;
               scat_za_index_local++)
            {
              // Dummy index
              Index index_zero = 0;
              
              // Calculate the phase matrix of a single particle type
              out3 << "Calculate the phase matrix \n"; 
              pha_mat_spt_agendaExecute(ws, pha_mat_spt_local,
                                        scat_za_index_local,
                                        index_zero,
                                        index_zero,
                                        p_index,
                                        scat_aa_index_local,
                                        rtp_temperature_local,
                                        pha_mat_spt_agenda);
              
              // Sum over all particle types
              pha_matCalc(pha_mat_local, pha_mat_spt_local, pnd_field, 
                          atmosphere_dim, p_index, 0, 
                          0, verbosity);

              out3 << "Multiplication of phase matrix with incoming" << 
                " intensities \n";
            
              product_field = 0;

              // za_in and aa_in are for incoming zenith and azimuth 
              // angle direction for which pha_mat is calculated
              for( Index za_in = 0; za_in < doit_za_grid_size; za_in ++)
                {
                  for (Index aa_in = 0; aa_in < Naa; ++ aa_in)
                    {
                      // Multiplication of phase matrix with incoming 
                      // intensity field.
                    
                      for ( Index i = 0; i < stokes_dim; i++)
                        {
                          for (Index j = 0; j< stokes_dim; j++)
                            {
                              product_field(za_in, aa_in, i) +=
                                pha_mat_local(za_in, aa_in, i, j) * 
                                doit_i_field_int(za_in, j);
                            }
                        }
                      
                    }//end aa_in loop
                }//end za_in loop
            
              out3 << "Compute integral. \n"; 
              for (Index i = 0; i < stokes_dim; i++)
                {
                  doit_scat_field_org(scat_za_index_local, i)=
                    AngIntegrate_trapezoid_opti(product_field(joker, joker, i),
                                                za_grid,
                                                scat_aa_grid,
                                                grid_stepsize);
                }//end i loop
            }//end za_prop loop
          
          // Interpolation on scat_za_grid, which is used in 
          //radiative transferpart.
          for (Index i = 0; i < stokes_dim; i++)
            {
            if(doit_za_interp == 0) // linear interpolation
              {
                interp(doit_scat_field(p_index,
                                  0,
                                  0,
                                  joker,
                                  0,
                                  i),
                       itw_za,
                       doit_scat_field_org(joker, i),
                       gp_za);
              }
            else // polynomial interpolation
              {
                for(Index za = 0; za < scat_za_grid.nelem(); za++)
                  {
                    doit_scat_field(p_index, 0, 0, za, 0, i) = 
                      interp_poly(za_grid, 
                                   doit_scat_field_org(joker, i),
                                   scat_za_grid[za],
                                   gp_za[za]);
                  }
              }
          }
        }//end p_index loop
      
    }//end atmosphere_dim = 1
  
  
  else if( atmosphere_dim == 3 ){
    // Loop over all positions
    for (Index p_index = 0; p_index <= cloudbox_limits[1] - cloudbox_limits[0];
         p_index ++)
      {
        for (Index lat_index = 0; lat_index <= 
               cloudbox_limits[3] - cloudbox_limits[2]; lat_index++)
          {
            for (Index lon_index = 0; lon_index <= 
                   cloudbox_limits[5] - cloudbox_limits[4]; lon_index++)
              {
                
                Numeric rtp_temperature_local =
                  t_field(p_index + cloudbox_limits[0],
                          lat_index + cloudbox_limits[2],
                          lon_index + cloudbox_limits[4]);
                
                // Loop over scattered directions
                for (Index scat_aa_index_local = 1;
                     scat_aa_index_local < Naa; 
                     scat_aa_index_local++)
                  {
                   // Interpolate intensity field:
                    for (Index i = 0; i < stokes_dim; i++)
                      {
                        interp(doit_i_field_int(joker, i), itw_za_i, 
                               doit_i_field(p_index, lat_index, lon_index,
                                       joker, scat_aa_index_local, i), gp_za_i);
                      }       
                    
                    for (Index scat_za_index_local = 0;
                         scat_za_index_local < doit_za_grid_size;
                         scat_za_index_local++)
                      {
                        
                        out3 << "Calculate phase matrix \n";
                        pha_mat_spt_agendaExecute(ws, pha_mat_spt_local,
                                                  scat_za_index_local,
                                                  lat_index,
                                                  lon_index,
                                                  p_index, 
                                                  scat_aa_index_local,
                                                  rtp_temperature_local,
                                                  pha_mat_spt_agenda);
  
                        pha_matCalc(pha_mat_local, pha_mat_spt_local,
                                    pnd_field, 
                                    atmosphere_dim, 
                                    p_index, 
                                    lat_index, 
                                    lon_index,
                                    verbosity);
                        
                        product_field = 0;
                        
                        
                        //za_in and aa_in are the incoming directions
                        //for which pha_mat_spt is calculated
                        out3 << "Multiplication of phase matrix with" << 
                          "incoming intensity \n";
                        
                        for( Index za_in = 0; za_in < doit_za_grid_size; za_in ++)
                          {
                            for (Index aa_in = 0; aa_in < Naa; ++ aa_in)
                              { 
                                // Multiplication of phase matrix
                                // with incloming intensity field.
                                for ( Index i = 0; i < stokes_dim; i++)
                                  {
                                    for (Index j = 0; j< stokes_dim; j++)
                                      {
                                        product_field(za_in, aa_in, i) +=
                                          pha_mat_local(za_in, aa_in, i, j) * 
                                          doit_i_field_int(za_in, j);
                                      }
                                  }
                              }//end aa_in loop
                          }//end za_in loop
                        
                        out3 << "Compute the integral \n";

                        for (Index i = 0; i < stokes_dim; i++)
                          {
                            doit_scat_field_org(scat_za_index_local, i)  =  
                              AngIntegrate_trapezoid_opti(product_field
                                                          ( joker,
                                                            joker, i),
                                                          za_grid,
                                                          scat_aa_grid,
                                                          grid_stepsize
                                                          );
                          }//end stokes_dim loop

                      }//end za_prop loop
                    //Interpolate on original za_grid. 
                    for (Index i = 0; i < stokes_dim; i++)
                      {
                        interp(doit_scat_field(p_index,
                                               lat_index,
                                               lon_index,
                                               joker,
                                               scat_aa_index_local,
                                               i),
                               itw_za,
                               doit_scat_field_org(joker, i),
                               gp_za);
                      }
                  } // end aa_prop loop
              }//end lon loop
          }//end lat loop
      }// end p loop
    doit_scat_field(joker, joker, joker, joker, 0, joker) =
      doit_scat_field(joker, joker, joker, joker, Naa-1, joker);
  }// end atm_dim=3
  out2 << "  Finished scattered field.\n"; 
}


/* Workspace method: Doxygen documentation will be auto-generated */
void doit_za_grid_optCalc(//WS Output
                          Vector& doit_za_grid_opt,
                          // WS Input:
                          const Tensor6& doit_i_field,
                          const Vector& scat_za_grid,
                          const Index& doit_za_interp,
                          //Keywords:
                          const Numeric& acc,
                          const Verbosity& verbosity)
{
  CREATE_OUT1;
  //-------- Check the input ---------------------------------
  
  // Here it is checked whether doit_i_field is 1D and whether it is 
  // consistent with scat_za_grid. The number of pressure levels and the 
  // number of stokes components does not matter. 
  chk_size("doit_i_field", doit_i_field, 
           doit_i_field.nvitrines() , 1, 1, scat_za_grid.nelem(), 1,
           doit_i_field.ncols());
  
  if(doit_i_field.ncols()<1 || doit_i_field.ncols()>4)
    throw runtime_error("The last dimension of *doit_i_field* corresponds\n"
                        "to the Stokes dimension, therefore the number of\n"
                        "columns in *doit_i_field* must be a number between\n"
                        "1 and 4, but it is not!");
  
  if( !(doit_za_interp == 0  ||  doit_za_interp == 1 ) )
    throw runtime_error( "Interpolation method is not defined. Use \n"
                         "*doit_za_interpSet*.\n");

  if(scat_za_grid.nelem() < 500)
    {
      out1 << "Warning: The fine grid (*scat_za_grid*) has less than\n" <<
              "500 grid points which is likely not sufficient for\n" <<
              "grid_optimization\n" ;
/*    throw runtime_error("The fine grid (*scat_za_grid*) has less than \n"
                        "500 grid points which is not sufficient for \n"
                        "grid_optimization");
*/
    }
  // ------------- end of checks ------------------------------------- 
  
  // Here only used as dummy variable. 
  Matrix doit_i_field_opt_mat;
  doit_i_field_opt_mat = 0.;
  
  // Optimize zenith angle grid. 
  za_gridOpt(doit_za_grid_opt, doit_i_field_opt_mat,
             scat_za_grid, doit_i_field, acc,
             doit_za_interp);
}


/* Workspace method: Doxygen documentation will be auto-generated */
void doit_za_interpSet(Index& doit_za_interp,
                       const Index& atmosphere_dim,
                       //Keyword
                       const String& method,
                       const Verbosity&)
{
  chk_if_in_range( "atmosphere_dim", atmosphere_dim, 1, 3 );

  if (atmosphere_dim != 1 && method == "polynomial")
    throw runtime_error(
                        "Polynomial interpolation is only implemented for\n"
                        "1D DOIT calculations as \n"   
                        "in 3D there can be numerical problems.\n"
                        "Please use 'linear' interpolation method."
                        );

  if(method == "linear")
    doit_za_interp = 0;
  else if (method == "polynomial")
    doit_za_interp = 1;
  else
    throw runtime_error("Possible interpolation methods are 'linear' "
                        "and 'polynomial'.\n");
}


/* Workspace method: Doxygen documentation will be auto-generated */
void ScatteringDoit(
         Workspace& ws,
         Tensor6&   doit_i_field,
         Tensor7&   scat_i_p, 
         Tensor7&   scat_i_lat, 
         Tensor7&   scat_i_lon,
         Tensor4&   doit_i_field1D_spectrum,
   const Index&     atmfields_checked,
   const Index&     atmgeom_checked,
   const Index&     cloudbox_checked,
   const Index&     cloudbox_on,
   const Vector&    f_grid,
   const Agenda&    doit_mono_agenda,
   const Index&     doit_is_initialized,
   const Verbosity& verbosity)
                  
{
  CREATE_OUT2;
  
  //-------- Check input -------------------------------------------
 
  if( atmfields_checked != 1 )
    throw runtime_error( "The atmospheric fields must be flagged to have "
                         "passed a consistency check (atmfields_checked=1)." );
  if( atmgeom_checked != 1 )
    throw runtime_error( "The atmospheric geometry must be flagged to have "
                         "passed a consistency check (atmgeom_checked=1)." );
  if( cloudbox_checked != 1 )
    throw runtime_error( "The cloudbox must be flagged to have "
                         "passed a consistency check (cloudbox_checked=1)." );

  // Don't do anything if there's no cloudbox defined.
  if (!cloudbox_on) return;
  
  chk_not_empty( "doit_mono_agenda", doit_mono_agenda );

  // Frequency grid
  //
  if( f_grid.nelem() == 0 )
    throw runtime_error( "The frequency grid is empty." );
  chk_if_increasing( "f_grid", f_grid );

  // Check whether DoitInit was executed
  if (!doit_is_initialized)
    throw runtime_error(
                        "Initialization method *DoitInit* has to be "
                        "put before\n"
                        "start of *ScatteringDoit*");

  //-------- end of checks ----------------------------------------


  // We have to make a local copy of the Workspace and the agendas because
  // only non-reference types can be declared firstprivate in OpenMP
  Workspace l_ws (ws);
  Agenda l_doit_mono_agenda(doit_mono_agenda);

  // OMP likes simple loop end conditions, so we make a local copy here: 
  const Index nf = f_grid.nelem();

/*if (nf)
  #pragma omp parallel for                                    \
  if(!arts_omp_in_parallel() && nf>1)                       \
  firstprivate(l_ws, l_doit_mono_agenda)*/
  for (Index f_index = 0; f_index < nf; f_index ++)
    {
      ostringstream os;
      os << "Frequency: " << f_grid[f_index]/1e9 <<" GHz \n" ;
      out2 << os.str();

      doit_mono_agendaExecute(l_ws, doit_i_field, scat_i_p, scat_i_lat,
                              scat_i_lon, doit_i_field1D_spectrum,
                              f_grid, f_index, l_doit_mono_agenda);
    }
}


/* Workspace method: Doxygen documentation will be auto-generated */
void DoitCloudboxFieldPut(//WS Output:
                          Tensor7&  scat_i_p,
                          Tensor7& scat_i_lat,
                          Tensor7& scat_i_lon,
                          Tensor4& doit_i_field1D_spectrum,
                          //WS Input:
                          const Tensor6& doit_i_field,
                          const Vector& f_grid,
                          const Index& f_index,
                          const Vector& p_grid,
                          const Vector& lat_grid,
                          const Vector& lon_grid,
                          const Vector& scat_za_grid,
                          const Vector& scat_aa_grid,
                          const Index& stokes_dim,
                          const Index& atmosphere_dim,
                          const ArrayOfIndex& cloudbox_limits,
                          const Matrix& sensor_pos,
                          const Tensor3& z_field,
                          const Verbosity& verbosity)
{
  // Some sizes:
  Index N_f = f_grid.nelem();
  Index N_za = scat_za_grid.nelem();
  Index N_aa = scat_aa_grid.nelem();
  Index N_p = cloudbox_limits[1] - cloudbox_limits[0] +1;

  // Some checks:
  
  assert( f_index < f_grid.nelem() );
 
  chk_if_in_range( "atmosphere_dim", atmosphere_dim, 1, 3 );
  
  // Grids have to be adapted to atmosphere_dim.
  chk_atm_grids( atmosphere_dim, p_grid, lat_grid, lon_grid );
  
   // Check the input:
  if (stokes_dim < 0 || stokes_dim > 4)
    throw runtime_error(
                        "The dimension of stokes vector must be"
                        "1,2,3, or 4");

  if ( cloudbox_limits.nelem()!= 2*atmosphere_dim)
    throw runtime_error(
                        "*cloudbox_limits* is a vector which contains the"
                        "upper and lower limit of the cloud for all "
                        "atmospheric dimensions. So its dimension must"
                        "be 2 x *atmosphere_dim*"); 
  // End of checks.
  
  // Resize and initialize *doit_i_field_spectra*
  doit_i_field1D_spectrum.resize(N_f, N_p, N_za, stokes_dim); 
  doit_i_field1D_spectrum = 0;

  // Put the doit_i_field at the cloudbox boundary into the interface variable 
  // scat_i_p.
  if(atmosphere_dim == 1)
    {
      bool in_cloudbox = false;
      // Check if sensor inside the cloudbox:
      //loop over all sensor positions
      for (Index i = 0; i < sensor_pos.nrows(); i++)
        {
          if(sensor_pos(i, 0) >= z_field(cloudbox_limits[0], 0, 0) &&
             sensor_pos(i, 0) <= z_field(cloudbox_limits[1], 0, 0) )
            {
              CREATE_OUT2;
              in_cloudbox = true;
              out2 << "  Sensor position in cloudbox, store radiation field\n"
                   << "  in cloudbox for all frequencies. \n"; 
            }
        }
      
      // Check size of doit_i_field.
      assert ( is_size( doit_i_field, 
                        (cloudbox_limits[1] - cloudbox_limits[0]) + 1,
                        1, 
                        1,
                        N_za, 
                        1,
                        stokes_dim));
      
      assert ( is_size( scat_i_p,
                        N_f, 2, 1, 1, N_za, 1, stokes_dim ));
      
      for (Index za = 0; za < N_za; za++)
        {
          for (Index i = 0; i < stokes_dim; i++)
            {  
              
              //doit_i_field at lower boundary
              scat_i_p(f_index, 0, 0, 0,
                       za, 0, i) = 
                doit_i_field(0, 0, 0, za, 0, i);
              //doit_i_field at upper boundary
              scat_i_p(f_index, 1, 0, 0,
                       za, 0, i) = 
                doit_i_field(cloudbox_limits[1] - cloudbox_limits[0],
                        0, 0, za, 0, i); 

              // If a sensor pos is inside the cloudbox we also need to 
              // define *doit_i_field1D_spectra*
              if( in_cloudbox)
                {
                  doit_i_field1D_spectrum(f_index, joker, za, i) = 
                    doit_i_field(joker, 0, 0, za, 0, i);
                }
              
            }//end stokes_dim
        }//end za loop
      
      
    }//end atmosphere_dim = 1
        
  if(atmosphere_dim == 3)
    {
      // Some sizes relevant for 3D atmosphere
      Index N_lat = cloudbox_limits[3] - cloudbox_limits[2] + 1;
      Index N_lon = cloudbox_limits[5] - cloudbox_limits[4] + 1;
      
      // Check size of doit_i_field.
      assert ( is_size( doit_i_field, 
                        cloudbox_limits[1] - cloudbox_limits[0] + 1,
                        N_lat,
                        N_lon,
                        N_za, 
                        N_aa,
                        stokes_dim));

      // Resize interface variables:
      scat_i_p.resize(N_f, 2, N_lat, N_lon, N_za, N_aa, stokes_dim);
      scat_i_lat.resize(N_f, N_p, 2, N_lon, N_za, N_aa, stokes_dim);
      scat_i_lon.resize(N_f, N_p, N_lat, 2, N_za, N_aa, stokes_dim);
 
      for (Index za = 0; za < N_za; za++)
        {
          for (Index aa = 0; aa < N_aa; aa++)
            {
              for (Index i = 0; i < stokes_dim; i++)
                {  
                  //
                  // Put doit_i_field in scat_i_p:
                  //
                  for (Index lat = 0; lat < N_lat; lat++)
                    {
                      for (Index lon = 0; lon < N_lon; lon++)
                        {
                          //doit_i_field at lower boundary
                          scat_i_p(f_index, 0, lat, lon,
                                   za, aa, i) = 
                            doit_i_field(0, lat, lon, za, aa, i);
                          //doit_i_field at upper boundary
                          scat_i_p(f_index, 1, lat, lon,
                                   za, aa, i) = 
                            doit_i_field(cloudbox_limits[1]-cloudbox_limits[0],
                                    lat, lon, za, aa, i);
                        }
                    }
                  // 
                  // Put doit_i_field in scat_i_lat:
                  //
                  for (Index p = 0; p < N_p; p++)
                    {
                      for (Index lon = 0; lon < N_lon; lon++)
                        {
                          //doit_i_field at lower boundary
                          scat_i_lat(f_index, p, 0, lon,
                                     za, aa, i) = 
                            doit_i_field(p, 0, lon, za, aa, i);
                          //doit_i_field at upper boundary
                          scat_i_lat(f_index, p, 1, lon,
                                     za, aa, i) = 
                            doit_i_field(p, cloudbox_limits[3]-
                                    cloudbox_limits[2],
                                    lon, za, aa, i);
                        }
                      //
                      // Put doit_i_field in scat_i_lon:
                      for (Index lat = 0; lat < N_lat; lat++)
                        {
                          //doit_i_field at lower boundary
                          scat_i_lon(f_index, p, lat, 0,
                                     za, aa, i) = 
                            doit_i_field(p, lat, 0, za, aa, i);
                          //doit_i_field at upper boundary
                          scat_i_lon(f_index, p, lat, 1,
                                     za, aa, i) = 
                            doit_i_field(p, lat, cloudbox_limits[5]-
                                    cloudbox_limits[4], za, aa, i);
                        } 
                    }
                }
            }
        }
    }
}



/* Workspace method: Doxygen documentation will be auto-generated */
void CloudboxGetIncoming(
         Workspace&      ws,
         Tensor7&        scat_i_p,
         Tensor7&        scat_i_lat,
         Tensor7&        scat_i_lon,
   const Index&    atmfields_checked,
   const Index&    atmgeom_checked,
   const Index&    cloudbox_checked,
   const Agenda&   iy_main_agenda,
   const Index&    atmosphere_dim,
   const Vector&   lat_grid,
   const Vector&   lon_grid,
   const Tensor3&  z_field,
   const Tensor3&  t_field,
   const Tensor4&  vmr_field,
   const Index&    cloudbox_on,
   const ArrayOfIndex&   cloudbox_limits,
   const Vector&   f_grid,
   const Index&    stokes_dim,
   const String&   iy_unit,
   const Agenda&   blackbody_radiation_agenda,
   const Vector&   scat_za_grid,
   const Vector&   scat_aa_grid,
   const Index&    rigorous,
   const Numeric&  maxratio,
   const Verbosity&)
{
  chk_if_in_range( "stokes_dim", stokes_dim, 1, 4 );
  if( atmfields_checked != 1 )
    throw runtime_error( "The atmospheric fields must be flagged to have "
                         "passed a consistency check (atmfields_checked=1)." );
  if( atmgeom_checked != 1 )
    throw runtime_error( "The atmospheric geometry must be flagged to have "
                         "passed a consistency check (atmgeom_checked=1)." );
  if( cloudbox_checked != 1 )
    throw runtime_error( "The cloudbox must be flagged to have "
                         "passed a consistency check (cloudbox_checked=1)." );
  

  // Don't do anything if there's no cloudbox defined.
  if (!cloudbox_on) return;
  
  // DOIT requires frequency based radiance:
  if( iy_unit != "1"  || 
      !chk_if_std_blackbody_agenda( ws, blackbody_radiation_agenda ) )
    {
      ostringstream os;
      os << "It is assumed that you use this method together with DOIT.\n"
         << "Usage of this method then demands that the *iy_main_agenda*\n"
         << "returns frequency based radiance (ie. [W/m2/Hz/sr]).\n"
         << "This requires that *iy_unit* is set to \"1\" and that\n"
         << "*blackbody_radiation_agenda uses *blackbody_radiationPlanck*\n"
         << "or a corresponding WSM.\n"
         << "At least one of these requirements is not met.\n";
      throw runtime_error( os.str() );
    }

  Index  Nf       = f_grid.nelem();
  Index  Np_cloud = cloudbox_limits[1] - cloudbox_limits[0] + 1;
  Index  Nza      = scat_za_grid.nelem();
  Index  Ni       = stokes_dim;
  Matrix iy;
  Ppath  ppath;

  //--- Check input ----------------------------------------------------------
  if( !(atmosphere_dim == 1  ||  atmosphere_dim == 3) )
    throw runtime_error( "The atmospheric dimensionality must be 1 or 3.");
  if( scat_za_grid[0] != 0. || scat_za_grid[Nza-1] != 180. )
        throw runtime_error(
                 "*scat_za_grid* must include 0 and 180 degrees as endpoints." );
  //--------------------------------------------------------------------------


  if( atmosphere_dim == 1 )
    {
      // Resize interface variables:
      scat_i_p.resize( Nf, 2, 1, 1, Nza, 1, Ni );
      scat_i_lat.resize( 0, 0, 0, 0, 0, 0, 0 );
      scat_i_lon.resize( 0, 0, 0, 0, 0, 0, 0 );

      //Define the variables for position and direction.
      Vector   los(1), pos(1);

      //--- Get scat_i_p at lower and upper boundary
      //    (boundary=0: lower, boundary=1: upper)
      for (Index boundary = 0; boundary <= 1; boundary++)
        {
          pos[0] = z_field( cloudbox_limits[boundary], 0, 0 );

          // doing the first angle separately for allowing dy between 2 angles
          // in the loop
          los[0] =  scat_za_grid[0];
          get_iy( ws, iy, t_field, z_field, vmr_field, 0, f_grid, pos, los, 
                  Vector(0), iy_main_agenda );
          scat_i_p( joker, boundary, 0, 0, 0, 0, joker ) = iy;

          for (Index scat_za_index = 1; scat_za_index < Nza; scat_za_index ++)
            {
              los[0] =  scat_za_grid[scat_za_index];

              get_iy( ws, iy, t_field, z_field, vmr_field, 0, f_grid, pos, los, 
                      Vector(0), iy_main_agenda );

              scat_i_p( joker, boundary, 0, 0, scat_za_index, 0, joker ) = iy;

              if( rigorous )
                {
                  for (Index fi = 0; fi < Nf; fi ++)
                    {
                      if( scat_i_p(fi,boundary,0,0,scat_za_index-1,0,0)/scat_i_p(fi,boundary,0,0,scat_za_index,0,0) > maxratio ||
                          scat_i_p(fi,boundary,0,0,scat_za_index-1,0,0)/scat_i_p(fi,boundary,0,0,scat_za_index,0,0) < 1/maxratio )
                        {
                          ostringstream os;
                          os << "ERROR: Radiance difference between interpolation\n"
                             << "points is too large (factor " << maxratio << ") to\n"
                             << "safely interpolate. This might be due to za_grid\n"
                             << "being too coarse or the radiance field being a\n"
                             << "step-like function.\n";
                          os << "Happens at boundary " << boundary << " between zenith\n"
                             << "angels " << scat_za_grid[scat_za_index-1] << " and "
                             << scat_za_grid[scat_za_index] << "deg for frequency"
                             << "#" << fi << ", where radiances are "
                             << scat_i_p(fi,boundary,0,0,scat_za_index-1,0,0)
                             << " and " << scat_i_p(fi,boundary,0,0,scat_za_index,0,0)
                             << " W/(sr m2 Hz).";
                          throw runtime_error(os.str());
                        }
                    }
                }
            }
        }
    }
  

  //--- atmosphere_dim = 3: --------------------------------------------------
  else
    {
      Index Naa = scat_aa_grid.nelem();

      if( scat_aa_grid[0] != 0. || scat_aa_grid[Naa-1] != 360. )
        throw runtime_error(
                 "*scat_aa_grid* must include 0 and 360 degrees as endpoints." );

      Index Nlat_cloud = cloudbox_limits[3] - cloudbox_limits[2] + 1;
      Index Nlon_cloud = cloudbox_limits[5] - cloudbox_limits[4] + 1;
      
      // Convert scat_aa_grid to "sensor coordinates"
      // (-180° < azimuth angle < 180°)
      //
      Vector aa_grid(Naa);
      for(Index i = 0; i<Naa; i++)
        aa_grid[i] = scat_aa_grid[i] - 180;

      // Resize interface variables:
      scat_i_p.resize( Nf, 2, Nlat_cloud, Nlon_cloud, Nza, Naa, Ni );
      scat_i_lat.resize( Nf, Np_cloud, 2, Nlon_cloud, Nza, Naa, Ni );
      scat_i_lon.resize( Nf, Np_cloud, Nlat_cloud, 2, Nza, Naa, Ni );

      // Define the variables for position and direction.
      Vector   los(2), pos(3);

      
      //--- Get scat_i_p at lower and upper boundary
      //    (boundary=0: lower, boundary=1: upper)
      for (Index boundary = 0; boundary <= 1; boundary++)
        {
          for (Index lat_index = 0; lat_index < Nlat_cloud; lat_index++ )
            {
              for (Index lon_index = 0; lon_index < Nlon_cloud; lon_index++ )
                {
                  pos[2] = lon_grid[lon_index + cloudbox_limits[4]];
                  pos[1] = lat_grid[lat_index + cloudbox_limits[2]];
                  pos[0] = z_field(cloudbox_limits[boundary],
                                   lat_index + cloudbox_limits[2],
                                   lon_index + cloudbox_limits[4]);

                  for (Index scat_za_index = 0; scat_za_index < Nza;
                       scat_za_index ++)
                    {
                      for (Index scat_aa_index = 0; scat_aa_index < Naa; 
                           scat_aa_index ++)
                        {
                          los[0] = scat_za_grid[scat_za_index];
                          los[1] = aa_grid[scat_aa_index];

                          // For end points of scat_za_index (0 & 180deg), we
                          // only need to perform calculations for one scat_aa
                          // and set the others to same value
                          if( ( scat_za_index != 0  &&  
                                scat_za_index != (Nza-1) )  ||  
                                scat_aa_index == 0 )
                            {
                              get_iy( ws, iy, t_field, z_field, vmr_field, 0, 
                                      f_grid, pos, los, Vector(0), 
                                      iy_main_agenda );
                            }

                          scat_i_p( joker, boundary, lat_index, lon_index, 
                                    scat_za_index, scat_aa_index, joker) = iy;
                        }
                    }
                }
            }
        }
      
      //--- Get scat_i_lat (2nd and 3rd boundary)
      for (Index boundary = 0; boundary <= 1; boundary++)
        {
          for (Index p_index = 0; p_index < Np_cloud; p_index++ )
            {
              for (Index lon_index = 0; lon_index < Nlon_cloud; lon_index++ )
                {
                  pos[2] = lon_grid[lon_index + cloudbox_limits[4]];
                  pos[1] = lat_grid[cloudbox_limits[boundary+2]];
                  pos[0] = z_field(p_index + cloudbox_limits[0],
                              cloudbox_limits[boundary+2],
                              lon_index + cloudbox_limits[4]);

                  for (Index scat_za_index = 0; scat_za_index < Nza;
                       scat_za_index ++)
                    {
                      for (Index scat_aa_index = 0; scat_aa_index < Naa; 
                           scat_aa_index ++)
                        {
                          los[0] = scat_za_grid[scat_za_index];
                          los[1] = aa_grid[scat_aa_index];

                          // For end points of scat_za_index, we need only to
                          // perform calculations for first scat_aa
                          if( ( scat_za_index != 0  &&  
                                scat_za_index != (Nza-1) )  ||  
                                scat_aa_index == 0 )
                            {
                              get_iy( ws, iy, t_field, z_field, vmr_field, 0, 
                                      f_grid, pos, los, Vector(0), 
                                      iy_main_agenda );
                            }

                          scat_i_lat( joker, p_index, boundary, lon_index, 
                                      scat_za_index, scat_aa_index, joker) = iy;
                        }
                    }
                }
            }    
        }

      //--- Get scat_i_lon (1st and 2nd boundary):
      for (Index boundary = 0; boundary <= 1; boundary++)
        {
          for (Index p_index = 0; p_index < Np_cloud; p_index++ )
            {
              for (Index lat_index = 0; lat_index < Nlat_cloud; lat_index++ )
                {
                  pos[2] = lon_grid[cloudbox_limits[boundary+4]];
                  pos[1] = lat_grid[lat_index + cloudbox_limits[2]];
                  pos[0] = z_field(p_index + cloudbox_limits[0],
                              lat_index + cloudbox_limits[2],
                              cloudbox_limits[boundary+4]);

                  for (Index scat_za_index = 0; scat_za_index < Nza;
                       scat_za_index ++)
                    {
                      for (Index scat_aa_index = 0; scat_aa_index < Naa; 
                           scat_aa_index ++)
                        {
                          los[0] = scat_za_grid[scat_za_index];
                          los[1] = aa_grid[scat_aa_index];

                          // For end points of scat_za_index, we need only to
                          // perform calculations for first scat_aa
                          if( ( scat_za_index != 0  &&  
                                scat_za_index != (Nza-1) )  ||  
                                scat_aa_index == 0 )
                            {
                              get_iy( ws, iy, t_field, z_field, vmr_field, 0, 
                                      f_grid, pos, los, Vector(0), 
                                      iy_main_agenda );
                            }

                          scat_i_lon( joker, p_index, lat_index, boundary, 
                                      scat_za_index, scat_aa_index, joker) = iy;
                        }
                    }
                }
            }
        } 
    }// End atmosphere_dim = 3.
}


/* Workspace method: Doxygen documentation will be auto-generated */
void CloudboxGetIncoming1DAtm(
         Workspace&      ws,
         Tensor7&        scat_i_p,
         Tensor7&        scat_i_lat,
         Tensor7&        scat_i_lon,
         Index&          cloudbox_on,
   const Index&    atmfields_checked,
   const Index&    atmgeom_checked,
   const Index&    cloudbox_checked,
   const Agenda&   iy_main_agenda,
   const Index&    atmosphere_dim,
   const Vector&   lat_grid,
   const Vector&   lon_grid,
   const Tensor3&  z_field,
   const Tensor3&  t_field,
   const Tensor4&  vmr_field,
   const ArrayOfIndex&   cloudbox_limits,
   const Vector&   f_grid,
   const Index&    stokes_dim,
   const String&   iy_unit,
   const Agenda&   blackbody_radiation_agenda,
   const Vector&   scat_za_grid,
   const Vector&   scat_aa_grid,
   const Verbosity&)
{
  chk_if_in_range( "stokes_dim", stokes_dim, 1, 4 );
  if( atmfields_checked != 1 )
    throw runtime_error( "The atmospheric fields must be flagged to have "
                         "passed a consistency check (atmfields_checked=1)." );
  if( atmgeom_checked != 1 )
    throw runtime_error( "The atmospheric geometry must be flagged to have "
                         "passed a consistency check (atmgeom_checked=1)." );
  if( cloudbox_checked != 1 )
    throw runtime_error( "The cloudbox must be flagged to have "
                         "passed a consistency check (cloudbox_checked=1)." );
  
  // Don't do anything if there's no cloudbox defined.
  if (!cloudbox_on) return;

  // DOIT requires frequency based radiance:
  if( iy_unit != "1"  || 
      !chk_if_std_blackbody_agenda( ws, blackbody_radiation_agenda ) )
    {
      ostringstream os;
      os << "It is assumed that you use this method together with DOIT.\n"
         << "Usage of this method then demands that the *iy_main_agenda*\n"
         << "returns frequency based radiance (ie. [W/m2/Hz/sr]).\n"
         << "This requires that *iy_unit* is set to \"1\" and that\n"
         << "*blackbody_radiation_agenda uses *blackbody_radiationPlanck*\n"
         << "or a corresponding WSM.\n"
         << "At least one of these requirements is not met.\n";
      throw runtime_error( os.str() );
    }
  
  Index  Nf       = f_grid.nelem();
  Index  Np_cloud = cloudbox_limits[1] - cloudbox_limits[0] + 1;
  Index  Nlat_cloud = cloudbox_limits[3] - cloudbox_limits[2] + 1;
  Index  Nlon_cloud = cloudbox_limits[5] - cloudbox_limits[4] + 1;
  Index  Nza      = scat_za_grid.nelem();
  Index  Naa      = scat_aa_grid.nelem();
  Index  Ni       = stokes_dim;
  Matrix iy;
  Ppath  ppath;


  //--- Check input ----------------------------------------------------------
  if( atmosphere_dim != 3 )
    throw runtime_error( "The atmospheric dimensionality must be 3.");
  if( scat_za_grid[0] != 0. || scat_za_grid[Nza-1] != 180. )
    throw runtime_error(
                     "*scat_za_grid* must include 0 and 180 degrees as endpoints." );
  if( scat_aa_grid[0] != 0. || scat_aa_grid[Naa-1] != 360. )
    throw runtime_error(
                     "*scat_aa_grid* must include 0 and 360 degrees as endpoints." );
  //--------------------------------------------------------------------------

  // Dummy variable for flag cloudbox_on. It has to be 0 here not to get
  // stuck in an infinite loop (if some propagation path hits the cloud
  // box at some other position.
  cloudbox_on = 0;

  // Convert scat_za_grid to "sensor coordinates"
  //(-180° < azimuth angle < 180°)
  //
  Vector aa_grid(Naa);
  for(Index i = 0; i<Naa; i++)
    aa_grid[i] = scat_aa_grid[i] - 180;

  // As the atmosphere is spherically symmetric we only have to calculate 
  // one azimuth angle.
  Index aa_index = 0;

  // Resize interface variables:
  scat_i_p.resize(Nf, 2, Nlat_cloud, Nlon_cloud, Nza, Naa, Ni);
  scat_i_lat.resize(Nf, Np_cloud, 2, Nlon_cloud, Nza, Naa, Ni);
  scat_i_lon.resize(Nf, Np_cloud, Nlat_cloud, 2, Nza, Naa, Ni);
  
  // Define the variables for position and direction.
  Vector   los(2), pos(3);

  // These variables are constant for all calculations:
  pos[1] = lat_grid[cloudbox_limits[2]];
  pos[2] = lon_grid[cloudbox_limits[4]];
  los[1] = aa_grid[aa_index];
  
  // Calculate scat_i_p, scat_i_lat, scat_i_lon
  for (Index p_index = 0; p_index < Np_cloud; p_index++ )
    {
      pos[0] = z_field( cloudbox_limits[0] + p_index, cloudbox_limits[2], 
                                                      cloudbox_limits[4] );
      
      for (Index scat_za_index = 0; scat_za_index < Nza; scat_za_index++ )
        {
          los[0] = scat_za_grid[scat_za_index];

          get_iy( ws, iy, t_field, z_field, vmr_field, 0, f_grid, pos, los, 
                  Vector(0), iy_main_agenda );
          
          for (Index aa = 0; aa < Naa; aa ++)
            {
              // scat_i_p lower boundary
              if(p_index == 0)
                {
                  for (Index lat = 0; lat < Nlat_cloud; lat ++)
                    {
                      for (Index lon = 0; lon < Nlon_cloud; lon ++)
                        {
                          scat_i_p( joker, 0, lat, lon, scat_za_index, aa,
                                    joker )
                            = iy;
                        }
                    }
                }
              //scat_i_p at upper boundary
              else if (p_index == Np_cloud-1)
                for (Index lat = 0; lat < Nlat_cloud; lat ++)
                  {
                    for (Index lon = 0; lon < Nlon_cloud; lon ++)
                      {
                        scat_i_p( joker, 1, lat, lon, scat_za_index, aa,
                                  joker )
                          = iy;
                      }
                  }
              
              // scat_i_lat (both boundaries)
              for (Index lat = 0; lat < 2; lat ++) 
                {
                  for (Index lon = 0; lon < Nlon_cloud; lon ++)
                    {
                      scat_i_lat( joker, p_index, lat, lon, 
                                  scat_za_index, aa, joker)
                        = iy;
                    }
                }
              
              // scat_i_lon (both boundaries)
              for (Index lat = 0; lat < Nlat_cloud; lat ++) 
                {
                  for (Index lon = 0; lon < 2; lon ++)
                    {
                      scat_i_lon( joker, p_index, lat, lon, 
                                  scat_za_index, aa, joker)
                        = iy;
                    }
                }
            }
        }
    }
  cloudbox_on = 1;
}


/* Workspace method: Doxygen documentation will be auto-generated */
void iyInterpCloudboxField(Matrix&         iy,
                           const Tensor7&  scat_i_p,
                           const Tensor7&  scat_i_lat,
                           const Tensor7&  scat_i_lon,
                           const Tensor4&  doit_i_field1D_spectrum,
                           const Vector&   rte_pos,
                           const Vector&   rte_los,
                           const Index&    jacobian_do,
                           const Index&    cloudbox_on,
                           const ArrayOfIndex&   cloudbox_limits,
                           const Index&    atmosphere_dim,
                           const Vector&   p_grid,
                           const Vector&   lat_grid,
                           const Vector&   lon_grid,
                           const Tensor3&  z_field,
                           const Index&    stokes_dim,
                           const Vector&   scat_za_grid,
                           const Vector&   scat_aa_grid,
                           const Vector&   f_grid,
                           const Index&    rigorous,
                           const Numeric&  maxratio,
                           const Verbosity& verbosity)
{
  // Retrieval variables
  if( jacobian_do )
    throw runtime_error( 
        "This method does not provide any jacobians (jacobian_do must be 0)" );

  // Convert rte_pos to grid positions
  GridPos gp_p, gp_lat, gp_lon;
  rte_pos2gridpos( gp_p, gp_lat, gp_lon, atmosphere_dim, 
                   p_grid, lat_grid, lon_grid, z_field, rte_pos );

  // iy
  iy_interp_cloudbox_field( iy, scat_i_p, scat_i_lat, scat_i_lon, 
                            doit_i_field1D_spectrum, gp_p, gp_lat, gp_lon, 
                            rte_los, cloudbox_on, 
                            cloudbox_limits, atmosphere_dim, stokes_dim, 
                            scat_za_grid, scat_aa_grid, f_grid, "linear",
                            rigorous, maxratio,
                            verbosity );
}


/* Workspace method: Doxygen documentation will be auto-generated */
void iyInterpPolyCloudboxField(Matrix&         iy,
                               const Tensor7&  scat_i_p,
                               const Tensor7&  scat_i_lat,
                               const Tensor7&  scat_i_lon,
                               const Tensor4&  doit_i_field1D_spectrum,      
                               const Vector&   rte_pos,
                               const Vector&   rte_los,
                               const Index&    jacobian_do,
                               const Index&    cloudbox_on,
                               const ArrayOfIndex&   cloudbox_limits,
                               const Index&    atmosphere_dim,
                               const Vector&   p_grid,
                               const Vector&   lat_grid,
                               const Vector&   lon_grid,
                               const Tensor3&  z_field,
                               const Index&    stokes_dim,
                               const Vector&   scat_za_grid,
                               const Vector&   scat_aa_grid,
                               const Vector&   f_grid,
                               const Verbosity& verbosity)
{
  // Retrieval varaibles
  if( jacobian_do )
    throw runtime_error( 
        "This method does not provide any jacobians (jacobian_do must be 0)" );

  // Convert rte_pos to grid positions
  GridPos gp_p, gp_lat, gp_lon;
  rte_pos2gridpos( gp_p, gp_lat, gp_lon, atmosphere_dim, 
                   p_grid, lat_grid, lon_grid, z_field, rte_pos );

  // iy
  iy_interp_cloudbox_field( iy, scat_i_p, scat_i_lat, scat_i_lon, 
                            doit_i_field1D_spectrum, gp_p, gp_lat, gp_lon, 
                            rte_los, cloudbox_on, cloudbox_limits, 
                            atmosphere_dim, stokes_dim, 
                            scat_za_grid, scat_aa_grid, f_grid, "polynomial",
                            0, 10,
                            verbosity );
}


/* Workspace method: Doxygen documentation will be auto-generated */
void doit_i_fieldSetClearsky(Tensor6& doit_i_field,
                             const Tensor7& scat_i_p,
                             const Tensor7& scat_i_lat,
                             const Tensor7& scat_i_lon,
                             const Vector& f_grid,
                             const Index& f_index,
                             const Vector& p_grid,
                             const Vector& lat_grid,
                             const Vector& lon_grid,
                             const ArrayOfIndex& cloudbox_limits,
                             const Index& atmosphere_dim,
                             //Keyword:
                             const Index& all_frequencies,
                             const Verbosity& verbosity)
{
  CREATE_OUT2;
  
  out2 << "  Interpolate boundary clearsky field to obtain the initial field.\n";
  
  // Initial field only needs to be calculated from clearsky field for the 
  // first frequency. For the next frequencies the solution field from the 
  // previous frequencies is used. 
  if(atmosphere_dim == 1)
    {
       if(f_index == 0 || all_frequencies == true){
         Index  N_f = scat_i_p.nlibraries();
         if (f_grid.nelem() != N_f){
           
           throw runtime_error(" scat_i_p should have same frequency  "
                               " dimension as f_grid");
         }
         
         if(scat_i_p.nvitrines() != 2){
           throw runtime_error("scat_i_p should have exactly two elements "
                               "in pressure dimension which correspond to the "
                               "two cloudbox bounding pressure levels");
         }
      
         
         Index N_za = scat_i_p.npages() ;
         Index N_aa = scat_i_p.nrows();
         Index N_i = scat_i_p.ncols();
         
         //1. interpolation - pressure grid
         
         doit_i_field.resize((cloudbox_limits[1]- cloudbox_limits[0])+1,
                             1,
                             1,
                             N_za,
                             N_aa,
                             N_i);
         
         doit_i_field = 0.;
         
         /*the old grid is having only two elements, corresponding to the 
           cloudbox_limits and the new grid have elements corresponding to
           all grid points inside the cloudbox plus the cloud_box_limits*/
         
         ArrayOfGridPos p_gp((cloudbox_limits[1]- cloudbox_limits[0])+1);
         
         p2gridpos(p_gp,
                   p_grid[Range(cloudbox_limits[0], 
                                2,
                                (cloudbox_limits[1]- cloudbox_limits[0]))],
                   p_grid[Range(cloudbox_limits[0], 
                                (cloudbox_limits[1]- cloudbox_limits[0])+1)]);
         
         Matrix itw((cloudbox_limits[1]- cloudbox_limits[0])+1, 2);
         interpweights ( itw, p_gp );
         
   
         
         for (Index za_index = 0; za_index < N_za ; ++ za_index)
           {
             for (Index aa_index = 0; aa_index < N_aa ; ++ aa_index)
               {
                 for (Index i = 0 ; i < N_i ; ++ i)
                   {
                     
                     VectorView target_field = doit_i_field(Range(joker),
                                                            0,
                                                            0,
                                                            za_index,
                                                            aa_index,
                                                            i);
                     
                     ConstVectorView source_field = scat_i_p(f_index,
                                                             Range(joker),    
                                                             0,
                                                             0,
                                                             za_index,
                                                             aa_index,
                                                             i);
                     
                     interp(target_field,
                            itw,
                            source_field,
                            p_gp);
                   }
                 
               }
           }
       }
       else{// no interpolation is required for other frequencies,
         // but the boundary needs to be set correctly.
         doit_i_field(0, 0, 0, Range(joker), Range(joker), Range(joker))=
           scat_i_p(f_index, 0, 0, 0, Range(joker), Range(joker),
                    Range(joker));
           doit_i_field(doit_i_field.nvitrines()-1, 0, 0, Range(joker), 
                        Range(joker), Range(joker))=
             scat_i_p(f_index, 1, 0, 0, Range(joker), Range(joker),
                      Range(joker));
       }
    }
  else if(atmosphere_dim == 3)
    {
      if (all_frequencies == false)
        throw runtime_error("Error in doit_i_fieldSetClearsky: For 3D "
                            "all_frequencies option is not implemented \n");

      Index  N_f = scat_i_p.nlibraries();
      if (scat_i_lat.nlibraries() != N_f || 
          scat_i_lon.nlibraries() != N_f){
      
        throw runtime_error(" scat_i_p, scat_i_lat, scat_i_lon should have  "
                            "same frequency dimension");
      }
      Index N_p = cloudbox_limits[1] - cloudbox_limits[0] + 1;
      if(scat_i_lon.nvitrines() != N_p ||
         scat_i_lat.nvitrines() != N_p ){
        throw runtime_error("scat_i_lat and scat_i_lon should have  "
                            "same pressure grid dimension as p_grid");
      }
    
      Index N_lat =  cloudbox_limits[3] - cloudbox_limits[2] + 1;
    
      if(scat_i_lon.nshelves() != N_lat ||
         scat_i_p.nshelves()   != N_lat){
        throw runtime_error("scat_i_p and scat_i_lon should have  "
                            "same latitude grid dimension as lat_grid");
      }

      Index N_lon = cloudbox_limits[5] - cloudbox_limits[4] + 1;
      if(scat_i_lat.nbooks() != N_lon ||
         scat_i_p.nbooks()   != N_lon ){
        throw runtime_error("scat_i_p and scat_i_lat should have  "
                            "same longitude grid dimension as lon_grid");
      }
      if(scat_i_p.nvitrines() != 2){
        throw runtime_error("scat_i_p should have exactly two elements "
                            "in pressure dimension which correspond to the "
                            "two cloudbox bounding pressure levels");
      }
    
      if(scat_i_lat.nshelves() != 2){
        throw runtime_error("scat_i_lat should have exactly two elements "
                            "in latitude dimension which correspond to the "
                            "two cloudbox bounding latitude levels");
      }
      if(scat_i_lon.nbooks() != 2){
        throw runtime_error("scat_i_lon should have exactly two elements "
                            "in longitude dimension which correspond to the "
                            "two cloudbox bounding longitude levels");
      }
      Index N_za = scat_i_p.npages() ;
      if (scat_i_lat.npages() != N_za || 
          scat_i_lon.npages() != N_za){
      
        throw runtime_error(" scat_i_p, scat_i_lat, scat_i_lon should have "
                            "same zenith angle dimension");
      }
      Index N_aa = scat_i_p.nrows();
      if (scat_i_lat.nrows() != N_aa || 
          scat_i_lon.nrows() != N_aa){
      
        throw runtime_error(" scat_i_p, scat_i_lat, scat_i_lon should have "
                            "same azimuth angle dimension");
      }
      Index N_i = scat_i_p.ncols();
      if (scat_i_lat.ncols() != N_i || 
          scat_i_lon.ncols() != N_i){
      
        throw runtime_error(" scat_i_p, scat_i_lat, scat_i_lon should have "
                            "same value for stokes_dim and can take only"
                            "values 1,2,3 or 4");
      }
    
      //1. interpolation - pressure grid, latitude grid and longitude grid
    
 
      //doit_i_field
      doit_i_field.resize((cloudbox_limits[1]- cloudbox_limits[0])+1, 
                          (cloudbox_limits[3]- cloudbox_limits[2])+1,
                          (cloudbox_limits[5]- cloudbox_limits[4])+1,
                          N_za, 
                          N_aa,
                          N_i);
    

    
      ArrayOfGridPos p_gp((cloudbox_limits[1]- cloudbox_limits[0])+1);
      ArrayOfGridPos lat_gp((cloudbox_limits[3]- cloudbox_limits[2])+1);
      ArrayOfGridPos lon_gp((cloudbox_limits[5]- cloudbox_limits[4])+1);

      /*the old grid is having only two elements, corresponding to the 
        cloudbox_limits and the new grid have elements corresponding to
        all grid points inside the cloudbox plus the cloud_box_limits*/
    
      p2gridpos(p_gp,
                p_grid[Range(cloudbox_limits[0], 
                             2,
                             (cloudbox_limits[1]- cloudbox_limits[0]))],
                p_grid[Range(cloudbox_limits[0], 
                             (cloudbox_limits[1]- cloudbox_limits[0])+1)]);
      gridpos(lat_gp,
              lat_grid[Range(cloudbox_limits[2], 
                             2,
                             (cloudbox_limits[3]- cloudbox_limits[2]))],
              lat_grid[Range(cloudbox_limits[2], 
                             (cloudbox_limits[3]- cloudbox_limits[2])+1)]);
      gridpos(lon_gp,
              lon_grid[Range(cloudbox_limits[4], 
                             2,
                             (cloudbox_limits[5]- cloudbox_limits[4]))],
              lon_grid[Range(cloudbox_limits[4], 
                             (cloudbox_limits[5]- cloudbox_limits[4])+1)]);


      //interpolation weights corresponding to pressure, latitude and 
      //longitude grids.

      Matrix itw_p((cloudbox_limits[1]- cloudbox_limits[0])+1, 2);
      Matrix itw_lat((cloudbox_limits[3]- cloudbox_limits[2])+1, 2);
      Matrix itw_lon((cloudbox_limits[5]- cloudbox_limits[4])+1, 2);

      interpweights ( itw_p, p_gp );
      interpweights ( itw_lat, lat_gp );
      interpweights ( itw_lon, lon_gp );

      // interpolation - pressure grid
      for (Index lat_index = 0; 
           lat_index <= (cloudbox_limits[3]-cloudbox_limits[2]); ++ lat_index)
        {
          for (Index lon_index = 0; 
               lon_index <= (cloudbox_limits[5]-cloudbox_limits[4]);
               ++ lon_index)
            {
              for (Index za_index = 0; za_index < N_za ; ++ za_index)
                {
                  for (Index aa_index = 0; aa_index < N_aa ; ++ aa_index)
                    {
                      for (Index i = 0 ; i < N_i ; ++ i)
                        {
                        
                          VectorView target_field = doit_i_field(Range(joker),
                                                                 lat_index,
                                                                 lon_index,
                                                                 za_index,
                                                                 aa_index,
                                                                 i);
                        
                          ConstVectorView source_field = scat_i_p(f_index,
                                                                  Range(joker),    
                                                                  lat_index,
                                                                  lon_index,
                                                                  za_index,
                                                                  aa_index,
                                                                  i);
                        
                          interp(target_field,
                                 itw_p,
                                 source_field,
                                 p_gp);
                        }
                    }
                }
            } 
        }
      //interpolation latitude
      for (Index p_index = 0; 
           p_index <= (cloudbox_limits[1]-cloudbox_limits[0]) ; ++ p_index)
        {
          for (Index lon_index = 0; 
               lon_index <= (cloudbox_limits[5]-cloudbox_limits[4]) ;
               ++ lon_index)
            {
              for (Index za_index = 0; za_index < N_za ; ++ za_index)
                {
                  for (Index aa_index = 0; aa_index < N_aa ; ++ aa_index)
                    {
                      for (Index i = 0 ; i < N_i ; ++ i)
                        {
                          
                          VectorView target_field = doit_i_field
                            (p_index, Range(joker), lon_index,
                             za_index, aa_index, i);
                        
                          ConstVectorView source_field = scat_i_lat
                            (f_index, p_index, Range(joker),    
                             lon_index, za_index, aa_index, i);
                        
                          interp(target_field,
                                 itw_lat,
                                 source_field,
                                 lat_gp);
                        }
                    }
                }
            } 
        }
      //interpolation -longitude
      for (Index p_index = 0; 
           p_index <= (cloudbox_limits[1]-cloudbox_limits[0]); ++ p_index)
        {
          for (Index lat_index = 0; 
               lat_index <= (cloudbox_limits[3]-cloudbox_limits[2]);
               ++ lat_index)
            {
              for (Index za_index = 0; za_index < N_za ; ++ za_index)
                {
                  for (Index aa_index = 0; aa_index < N_aa ; ++ aa_index)
                    {
                      for (Index i = 0 ; i < N_i ; ++ i)
                        {
                        
                          VectorView target_field = doit_i_field(p_index,
                                                                 lat_index,
                                                                 Range(joker),
                                                                 za_index,
                                                                 aa_index,
                                                                 i);
                        
                          ConstVectorView source_field = scat_i_lon(f_index,
                                                                    p_index,    
                                                                    lat_index,
                                                                    Range(joker),
                                                                    za_index,
                                                                    aa_index,
                                                                    i);
                        
                          interp(target_field,
                                 itw_lon,
                                 source_field,
                                 lon_gp);
                        }
                    }
                }
            } 
        }
      //end of interpolation
    }//ends atmosphere_dim = 3
}


/* Workspace method: Doxygen documentation will be auto-generated */
void doit_i_fieldSetConst(//WS Output:
                          Tensor6& doit_i_field,
                          //WS Input:
                          const Tensor7& scat_i_p,
                          const Tensor7& scat_i_lat,
                          const Tensor7& scat_i_lon,
                          const Vector& p_grid,
                          const Vector& lat_grid,
                          const Vector& lon_grid,
                          const ArrayOfIndex& cloudbox_limits,
                          const Index& atmosphere_dim,
                          const Index& stokes_dim,
                          // Keyword       
                          const Vector& doit_i_field_values,
                          const Verbosity& verbosity)
{
  CREATE_OUT2;
  CREATE_OUT3;
  
  out2 << "  Set initial field to constant values: " << doit_i_field_values << "\n"; 

  // In the 1D case the atmospheric layers are defined by p_grid and the
  // required interface is scat_i_p.
  Index N_za = scat_i_p.npages();
  Index N_aa = scat_i_p.nrows();
  Index N_i = stokes_dim; 
  Index Np_cloud = cloudbox_limits[1] - cloudbox_limits[0] + 1;
  Index Nlat_cloud = cloudbox_limits[3] - cloudbox_limits[2] + 1;
  Index Nlon_cloud = cloudbox_limits[5] - cloudbox_limits[4] + 1;

  chk_if_in_range( "atmosphere_dim", atmosphere_dim, 1, 3 );
  
  // Grids have to be adapted to atmosphere_dim.
  chk_atm_grids( atmosphere_dim, p_grid, lat_grid, lon_grid );
  
   // Check the input:
  if (stokes_dim < 0 || stokes_dim > 4)
    throw runtime_error(
                        "The dimension of stokes vector must be"
                        "1,2,3, or 4");

  if ( cloudbox_limits.nelem()!= 2*atmosphere_dim)
    throw runtime_error(
                        "*cloudbox_limits* is a vector which contains the"
                        "upper and lower limit of the cloud for all "
                        "atmospheric dimensions. So its dimension must"
                        "be 2 x *atmosphere_dim*"); 


 
  if(atmosphere_dim == 1)
    {
      out3 << "  atm_dim = 1\n"; 
      
    // Define the size of doit_i_field.
    doit_i_field.resize((cloudbox_limits[1] - cloudbox_limits[0])+1, 1, 1,  N_za,
                   1, N_i);
    doit_i_field = 0.;

    // Loop over all zenith angle directions.
    for (Index za_index = 0; za_index < N_za; za_index++)
      {
        for (Index i = 0; i < stokes_dim; i++)
          { 
            //set the value for the upper boundary
            doit_i_field(cloudbox_limits[1]-cloudbox_limits[0], 0, 0, za_index,
                    0, i) = 
          scat_i_p(0, 1, 0, 0, za_index, 0, i);
            //set the value for the lower boundary 
            doit_i_field(0, 0, 0, za_index, 0, i) =  
          scat_i_p(0, 0, 0, 0, za_index, 0, i);
            for (Index scat_p_index = 1; scat_p_index < cloudbox_limits[1] - 
                   cloudbox_limits[0]; scat_p_index++ )
              // The field inside the cloudbox is set to some arbitrary value.
              doit_i_field(scat_p_index, 0, 0, za_index, 0, i) =  doit_i_field_values[i];
          }    
      }
    }
  else 
    {
      if ( !is_size(scat_i_p, 1, 2, Nlat_cloud, 
                Nlon_cloud, N_za, N_aa, stokes_dim)  
           || !is_size(scat_i_lat, 1, Np_cloud, 2, 
                       Nlon_cloud, N_za, N_aa, stokes_dim)  
           || !is_size(scat_i_lon, 1, Np_cloud,  
                       Nlat_cloud, 2, N_za, N_aa, stokes_dim) )
        throw runtime_error(
                            "One of the interface variables (*scat_i_p*, "
                            "*scat_i_lat* or *scat_i_lon*) does not have "
                            "the right dimensions.  \n Probably you have "
                            "calculated them before for another value of "
                            "*stokes_dim*."
                            );
      

      
      out3 << "atm_dim = 3\n";      
      doit_i_field.resize((cloudbox_limits[1]- cloudbox_limits[0])+1, 
                     (cloudbox_limits[3]- cloudbox_limits[2])+1,
                     (cloudbox_limits[5]- cloudbox_limits[4])+1,
                     N_za, 
                     N_aa,
                     N_i);
      
      doit_i_field = 0.;
      

      // Loop over all directions:
      for (Index za_index = 0; za_index < N_za; za_index++)
        {
          for (Index aa_index = 0; aa_index < N_aa; aa_index++)
            {
              for (Index i = 0; i < stokes_dim; i++)
                { 
                  // pressure boundaries
                  // 
                   for (Index lat_index = cloudbox_limits[2]; 
                         lat_index <= cloudbox_limits[3]; lat_index++)
                      {
                        for (Index lon_index = cloudbox_limits[4]; 
                             lon_index <= cloudbox_limits[5]; lon_index++)
                          {
                            //set the value for the upper pressure boundary
                            doit_i_field(cloudbox_limits[1]-cloudbox_limits[0], 
                                    lat_index-cloudbox_limits[2],
                                    lon_index-cloudbox_limits[4],
                                    za_index, aa_index, i) = 
                              scat_i_p(0, 1, lat_index-cloudbox_limits[2],
                                       lon_index-cloudbox_limits[4],
                                       za_index, aa_index, i);
                            //set the value for the lower pressure boundary 
                            doit_i_field(0, lat_index-cloudbox_limits[2],
                                    lon_index-cloudbox_limits[4],
                                    za_index, aa_index, i) =  
                              scat_i_p(0, 0, lat_index-cloudbox_limits[2],
                                       lon_index-cloudbox_limits[4],
                                       za_index, aa_index, i);
                          }
                      }
                   
                   for (Index p_index = cloudbox_limits[0]; 
                        p_index <= cloudbox_limits[1]; p_index++)
                     {
                       // latitude boundaries
                       //
                        for (Index lon_index = cloudbox_limits[4]; 
                             lon_index <= cloudbox_limits[5]; lon_index++)
                          {
                            // first boundary
                            doit_i_field(p_index-cloudbox_limits[0], 
                                    cloudbox_limits[3]-cloudbox_limits[2],
                                    lon_index-cloudbox_limits[4],
                                    za_index, aa_index, i) = 
                              scat_i_lat(0, p_index-cloudbox_limits[0],
                                         1, lon_index-cloudbox_limits[4],
                                         za_index, aa_index, i);
                            // second boundary
                            doit_i_field(p_index-cloudbox_limits[0], 0, 
                                    lon_index-cloudbox_limits[4], 
                                    za_index, aa_index, i) =  
                              scat_i_lat(0, p_index-cloudbox_limits[0], 0,
                                         lon_index-cloudbox_limits[4],
                                         za_index, aa_index, i);
                            
                          }                                                    
                        // longitude boundaries
                   for (Index lat_index = cloudbox_limits[2]; 
                             lat_index <= cloudbox_limits[3]; lat_index++)
                          {
                            // first boundary
                            doit_i_field(p_index-cloudbox_limits[0],
                                    lat_index-cloudbox_limits[2],
                                    cloudbox_limits[5]-cloudbox_limits[4],
                                    za_index, aa_index, i) = 
                              scat_i_lon(0, p_index-cloudbox_limits[0],
                                         lat_index-cloudbox_limits[2], 1,
                                         za_index, aa_index, i);
                            // second boundary
                            doit_i_field(p_index-cloudbox_limits[0],  
                                    lat_index-cloudbox_limits[2],
                                    0, 
                                    za_index, aa_index, i) =  
                              scat_i_lon(0, p_index-cloudbox_limits[0],
                                         lat_index-cloudbox_limits[2], 0,
                                         za_index, aa_index, i);
                          } //lat_grid loop
                     } //p_grid loop
                   //
                   // Set the initial field to a constant value inside the 
                   // cloudbox:
                   // 
                   for( Index p_index = (cloudbox_limits[0]+1); 
                                 p_index <  cloudbox_limits[1] ;
                                 p_index ++)
                     {
                       for (Index lat_index = (cloudbox_limits[2]+1); 
                            lat_index < cloudbox_limits[3]; 
                            lat_index++)
                         {
                           for (Index lon_index = (cloudbox_limits[4]+1); 
                                lon_index < cloudbox_limits[5];
                                lon_index++)
                             {
                               doit_i_field(p_index-cloudbox_limits[0],
                                       lat_index-cloudbox_limits[2],
                                       lon_index-cloudbox_limits[4],
                                       za_index, aa_index, i) =  
                                 doit_i_field_values[i];
                             }
                         }
                     }
                } // stokes loop
            } // aa_grid loop
        } // za_grid loop
       
    } // atmosphere dim = 3
}
