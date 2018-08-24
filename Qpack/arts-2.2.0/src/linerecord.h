/* Copyright (C) 2000-2013
   Stefan Buehler <sbuehler@ltu.se>
   Axel von Engeln <engeln@uni-bremen.de>

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

/** \file
    LineRecord class for managing line catalog data.

    \author Stefan Buehler, Axel von Engeln
*/

#ifndef linerecord_h
#define linerecord_h

#include <stdexcept>
#include <cmath>
#include "messages.h"
#include "mystring.h"
#include "array.h"
#include "matpackI.h"
#include "quantum.h"

/* Forward declaration of classes */
class SpeciesRecord;
class IsotopologueRecord;

/** Spectral line catalog data.

    Below is a description of the ARTS catalogue format.
    The file starts with the usual XML header:

    \verbatim
    <?xml version="1.0"?>
    <arts format="ascii" version="1">
    <ArrayOfLineRecord version="ARTSCAT-3" nelem="8073">
    \endverbatim

    The ARTSCAT version number is there to keep track of catalogue format changes.
    The "nelem" tag contains the total number of lines in the file.

    The file ends with the usual XML closing tags:

    \verbatim
    </ArrayOfLineRecord>
    </arts>
    \endverbatim

    In-between the header and the footer are the actual spectroscopic
    data. Each new entry, corresponding to one spectral line, starts
    with the `@' character.

    The line catalogue should not have any fixed column widths because
    the precision of the parameters should not be limited by the
    format.  The catalogue can then be stored as binary or ASCII. In
    the ASCII version the columns are separated by one or more
    blanks. The line format is then specified by only the order and
    the units of the columns. As the catalogue entry for each
    transition can be quite long, it can be broken across lines in the
    ASCII file. That is why each new transition is marked with a `@'
    character.

    The first column will contain the species and isotopologue, following
    the naming scheme described below.  Scientific notation is
    allowed, e.g. 501.12345e9.  

    Note that starting with ARTSCAT-2, the intensity is per molecule,
    i.e., it does not contain the isotopologue ratio. This is similar to
    JPL, but different to HITRAN.

    Currently, ARTS is capable of handling ARTSCAT versions 3 and 4. Different
    versions can be handled simultaneously.
    The line format of ARTSCAT-3 (for ARTSCAT-4 see further below) is:

    \verbatim
    Col  Variable                    Label     Unit    Comment
    ------------------------------------------------------------------      
     0   `@'                         ENTRY        -    marks start of entry
     1    species\&isotopologue tag   NAME        -    e.g. O3-666
     2   center frequency                F       Hz    e.g. 501.12345e9 
     3   pressure shift of F           PSF    Hz/Pa    
     4   line intensity                 I0    Hz*m^2   per isotopologue, not per species
     5   reference temp. for I0       T_I0        K
     6   lower state energy           ELOW        J    
     7   air broadened width          AGAM    Hz/Pa    values around 20000 Hz/Pa
     8   self broadened width         SGAM    Hz/Pa
     9   AGAM temp. exponent          NAIR        -    values around .5
    10   SGAM temp. exponent         NSELF        - 
    11   ref. temp. for AGAM, SGAM   T_GAM        K
    12   number of aux. parameters   N_AUX        -
    13   auxiliary parameter          AUX1        -
    14   ... 
    15   error for F                    DF       Hz
    16   error for I0                  DI0        %
    17   error for AGAM              DAGAM        %
    18   error for SGAM              DSGAM        %
    19   error for NAIR              DNAIR        %
    20   error for NSELF            DNSELF        %
    21   error for PSF                DPSF        %
    \endverbatim

    The parameters 0-12 must be present, the others can be missing,
    since they are not needed for the calculation.

    For the error fields (15-21), a -1 means that no value exist.

    A valid ARTS (CAT-3) line file would be:
    \verbatim
    <?xml version="1.0"?>
    <arts format="ascii" version="1">
    <ArrayOfLineRecord version="ARTSCAT-3" nelem="2">
    @ O3-676 80015326542.0992 0 3.70209114155527e-19 296 7.73661776567701e-21 21480.3182341969
    28906.7092490501 0.76 0.76 296 0 300000 0.1 0.1 0.1 0.2 -1 -1.24976056865038e-11
    @ O3-676 80015476438.3282 0 3.83245786810611e-19 296 7.73661577919822e-21 21480.3182341969
    28906.7092490501 0.76 0.76 296 0 300000 0.1 0.1 0.1 0.2 -1 -1.24975822742335e-11
    </ArrayOfLineRecord>
    </arts>
    \endverbatim

    Some species need special parameters that are not needed by other
    species (for example overlap coefficients for O2). In the case of
    oxygen two parameters are sufficient to describe the overlap, but
    other species, e.g., methane, may need more coefficients. The
    default for \c N_AUX is zero. In that case, no further
    \c AUX fields are present. [FIXME: Check Oxygen.]

    The line format of ARTSCAT-4 is:

    \verbatim
    Col  Variable                    Label        Unit    Comment
    ------------------------------------------------------------------      
    00   `@'                         ENTRY        -       marks start of entry
    01   species\&isotopologue tag   NAME         -       e.g. O3-666
    02   center frequency            F            Hz      e.g. 501.12345e9 
    03   line intensity              I0           Hz*m^2  per isotopologue, not per species
    04   reference temp. for I0      T_I0         K
    05   lower state energy          ELOW         J   
    06   Einstein A-coefficient      A            1/s     where available from HITRAN 
    07   Upper state stat. weight    G_upper      -       where available from HITRAN 
    08   Lower state stat. weight    G_lower      -       where available from HITRAN 

    09   broadening parameter self   GAMMA_self   Hz/Pa   GAM have values around 20000 Hz/Pa
    10   broadening parameter N2     GAMMA_N2     Hz/Pa
    11   broadening parameter O2     GAMMA_O2     Hz/Pa
    12   broadening parameter H2O    GAMMA_H2O    Hz/Pa
    13   broadening parameter CO2    GAMMA_CO2    Hz/Pa
    14   broadening parameter H2     GAMMA_H2     Hz/Pa
    15   broadening parameter He     GAMMA_He     Hz/Pa

    16   GAM temp. exponent self     N_self       -       N have values around .5
    17   GAM temp. exponent N2       N_N2         -       
    18   GAM temp. exponent O2       N_O2         -       
    19   GAM temp. exponent H2O      N_H2O        -       
    20   GAM temp. exponent CO2      N_CO2        -       
    21   GAM temp. exponent H2       N_H2         -       
    22   GAM temp. exponent He       N_He         -       

    23   F pressure shift N2         DELTA_N2     Hz/Pa   DELTA have values around 0 Hz/Pa
    24   F pressure shift O2         DELTA_O2     Hz/Pa    
    25   F pressure shift H2O        DELTA_H2O    Hz/Pa    
    26   F pressure shift CO2        DELTA_CO2    Hz/Pa    
    27   F pressure shift H2         DELTA_H2     Hz/Pa    
    28   F pressure shift He         DELTA_He     Hz/Pa    

    29   Vibrational and rotational  VRA          -       contains (coded) quantum numbers.
         assignments                                     
------------------------------------------------------------------      
\endverbatim

    Parameters 0-28 must be present.
    Coding conventions of parameter 29 are species specific. The definition is
    given in arts-xml-data/spectroscopy/perrin/ARTSCAT-4_Col29_Conventions.txt.


    The names of the private members and public access functions of
    this data structure follow the above table. The only difference is
    that underscores are omited and only the first letter of each name
    is capitalized. This is for consistency with the notation
    elsewhere in the program.

    \author Stefan Buehler 
*/
class LineRecord {
public:
    
  /** Default constructor. Initialize to default values. The indices
      are initialized to large numbers, so that we at least get range
      errors when we try to used un-initialized data. */
  LineRecord()
    : mversion (3),
      mspecies (1000000),
      misotopologue (1000000),
      mf       (0.     ),
      mpsf     (0.     ),
      mi0      (0.     ),
      mti0     (0.     ),
      melow    (0.     ),
      magam    (0.     ),
      msgam    (0.     ),
      mnair    (0.     ),
      mnself   (0.     ),
      mtgam    (0.     ),
      maux     (       ),
      mdf      (-1.    ),
      mdi0     (-1.    ),
      mdagam   (-1.    ),
      mdsgam   (-1.    ),
      mdnair   (-1.    ),
      mdnself  (-1.    ),
      mdpsf    (-1.    ),
      mupper_n (-1     ),
      mupper_j (-1     ),
      mlower_n (-1     ),
      mlower_j (-1     ),
      mquantum_numbers_str(""),
      mquantum_numbers()
 { /* Nothing to do here. */ }

  /** Constructor that sets all data elements explicitly. If
      assertions are not disabled (i.e., if NDEBUG is not \#defined),
      assert statements check that the species and isotopologue data
      exists. */
  LineRecord( Index                 species,
              Index                 isotopologue,
              Numeric               f,
              Numeric               psf,
              Numeric               i0,
              Numeric               ti0,
              Numeric               elow,
              Numeric               agam,
              Numeric               sgam,
              Numeric               nair,
              Numeric               nself,
              Numeric               tgam,
              const ArrayOfNumeric& aux,
              Numeric               /* df */,
              Numeric               /* di0 */,
              Numeric               /* dagam */,
              Numeric               /* dsgam */,
              Numeric               /* dnair */,
              Numeric               /* dnself */,
              Numeric               /* dpsf */)
    : mversion (3),
      mspecies (species    ),
      misotopologue (isotopologue    ),
      mf       (f          ),
      mpsf     (psf        ),
      mi0      (i0         ),
      mti0     (ti0        ),
      melow    (elow       ),
      magam    (agam       ),
      msgam    (sgam       ),
      mnair    (nair       ),
      mnself   (nself      ),
      mtgam    (tgam       ), 
      maux     (aux        ),
      mdf      (-1.    ),
      mdi0     (-1.    ),
      mdagam   (-1.    ),
      mdsgam   (-1.    ),
      mdnair   (-1.    ),
      mdnself  (-1.    ),
      mdpsf    (-1.    ),
      mupper_n (-1     ),
      mupper_j (-1     ),
      mlower_n (-1     ),
      mlower_j (-1     ),
      mquantum_numbers_str(""),
      mquantum_numbers()
  {
    // Thanks to Matpack, initialization of misotopologue with isotopologue
    // should now work correctly.  

    // Check if this species is legal, i.e., if species and isotopologue
    // data exists.
    ////    extern Array<SpeciesRecord> species_data;
    //assert( mspecies < species_data.nelem() );
    //assert( misotopologue < species_data[mspecies].Isotopologue().nelem() );
  }

  /** Return the version String. */
  String VersionString() const;
  
  /** Return the version number. */
  Index Version() const { return mversion; }
  
  /** The index of the molecular species that this line belongs to.
   The species data can be accessed by species_data[Species()]. */
  Index Species() const { return mspecies; }

  /** The index of the isotopologue species that this line belongs to.
   The isotopologue species data can be accessed by
   species_data[Species()].Isotopologue()[Isotopologue()].  */
  Index Isotopologue() const { return misotopologue; }

  /** The full name of the species and isotopologue. E.g., `O3-666'.
   The name is found by looking up the information in species_data,
   using the species and isotopologue index. */
  String Name() const;

  /** The matching SpeciesRecord from species_data. To get at the
   species data of a LineRecord lr, you can use:
   <ul>
   <li>species_data[lr.Species()]</li>
   <li>lr.SpeciesData()</li>
   </ul>
   The only advantages of the latter are that the notation is
   slightly nicer and that you don't have to declare the external
   variable species_data. */
  const SpeciesRecord& SpeciesData() const;

  /** The matching IsotopologueRecord from species_data. The IsotopologueRecord
   is a subset of the SpeciesRecord. To get at the isotopologue data of
   a LineRecord lr, you can use:
   <ul>
   <li>species_data[lr.Species()].Isotopologue()[lr.Isotopologue()]</li>
   <li>lr.SpeciesData().Isotopologue()[lr.Isotopologue()]</li>
   <li>lr.IsotopologueData()</li>
   </ul>
   The last option is clearly the shortest, and has the advantage
   that you don't have to declare the external variable
   species_data. */
  const IsotopologueRecord& IsotopologueData() const;

  /** The line center frequency in <b> Hz</b>. */
  Numeric F() const     { return mf; }

  /** Set the line center frequency in <b> Hz</b>. */
  void setF( Numeric new_mf ) { mf = new_mf; }

  /** The pressure shift parameter in <b> Hz/Pa</b>. */
  Numeric Psf() const   { return mpsf; }

  /** Set the pressure shift parameter in <b> Hz/Pa</b>. */
  void setPsf( Numeric new_mpsf ) { mpsf = new_mpsf; }

  /** The line intensity in <b> m^2*Hz</b> at the reference temperature \c Ti0. 

   The line intensity \f$I_0\f$ is defined by:

   \f[
   \alpha(\nu) = n \, x \, I_0(T) \, F(\nu)
   \f]

   where \f$\alpha\f$ is the absorption coefficient (in <b>
   m^-1</b>), \f$\nu\f$ is frequency, \f$n\f$ is the
   total number density, \f$x\f$ is the volume mixing ratio, and
   \f$F(\nu)\f$ is the lineshape function. */
  Numeric I0() const    { return mi0; }

 /** Set Intensity */
  void setI0( Numeric new_mi0 ) { mi0 = new_mi0; }

  /** Reference temperature for I0 in <b> K</b>: */
  Numeric Ti0() const   { return mti0; }

  /** Lower state energy in <b> cm^-1</b>: */
  Numeric Elow() const  { return melow; }

  /** Air broadened width in <b> Hz/Pa</b>: */
  Numeric Agam() const  { return magam; }

   /** Set Air broadened width in <b> Hz/Pa</b>: */
  void setAgam( Numeric new_agam ) { magam = new_agam; }

  /** Self broadened width in <b> Hz/Pa</b>: */
  Numeric Sgam() const  { return msgam; }

  /** Set Self  broadened width in <b> Hz/Pa</b>: */
  void setSgam( Numeric new_sgam ) { msgam = new_sgam; }

  /** AGAM temperature exponent (dimensionless): */
  Numeric Nair() const  { return mnair; }

  /** Set AGAM temperature exponent (dimensionless): */
  void setNair( Numeric new_mnair ) { mnair = new_mnair; }

  /** SGAM temperature exponent (dimensionless): */
  Numeric Nself() const { return mnself; }

 /** Set SGAM temperature exponent (dimensionless): */
  void setNself( Numeric new_mnself ) { mnself = new_mnself; }

  /** Reference temperature for AGAM and SGAM in <b> K</b>: */
  Numeric Tgam() const  { return mtgam; }

  /** Number of auxiliary parameters. This function is actually
      redundant, since the number of auxiliary parameters can also be
      obtained directly with Aux.nelem(). I just added the function in
      order to have consistency of the interface with the catalgue
      format. */
  Index Naux() const   { return maux.nelem(); }

  /** Auxiliary parameters. */
  const ArrayOfNumeric& Aux() const { return maux; }
  //

  /** Accuracy for line position in <b> Hz </b>: */
  Numeric dF() const  { return mdf; }

  /** Accuracy for line intensity in <b> relative value </b>: */
  Numeric dI0() const  { return mdi0; }

 /** Accuracy for air broadened width in <b> relative value </b>: */
  Numeric dAgam() const  { return mdagam; }

  /** Accuracy for self broadened width in <b> relative value </b>: */
  Numeric dSgam() const  { return mdsgam; }

  /** Accuracy for AGAM temperature exponent in <b> relative value </b>: */
  Numeric dNair() const  { return mdnair; }

  /** Accuracy for SGAM temperature exponent in <b> relative value</b>: */
  Numeric dNself() const { return mdnself; }

  /** Accuracy for pressure shift in <b> relative value </b>: */
  Numeric dPsf() const { return mdpsf; }

  /** ARTSCAT-4 Einstein A-coefficient in <b> 1/s </b>: */
  Numeric A() const { return ma; }
  
  /** ARTSCAT-4 Upper state stat. weight: */
  Numeric G_upper() const { return mgupper; }
  
  /** ARTSCAT-4 Lower state stat. weight: */
  Numeric G_lower() const { return mglower; }
  
  /** ARTSCAT-4 foreign broadening parameters in <b> Hz/Pa </b>: */
  Numeric Gamma_foreign(const Index i) const { return mgamma_foreign[i]; }

   /** ARTSCAT-4 foreign temperature exponents (dimensionless): */
   Numeric N_foreign(const Index i) const { return mn_foreign[i]; }

   /** ARTSCAT-4 pressure shift parameters in <b> Hz/Pa </b>: */
   Numeric Delta_foreign(const Index i) const { return mdelta_foreign[i]; }

//  /** Broadening parameter self in <b> Hz/Pa </b>: */
//  Numeric Gamma_self() const { return mgamma_self; }
//  
//  /** Broadening parameter N2 in <b> Hz/Pa </b>: */
//  Numeric Gamma_N2() const { return mgamma_n2; }
//  
//  /** Broadening parameter O2 in <b> Hz/Pa </b>: */
//  Numeric Gamma_O2() const { return mgamma_o2; }
//  
//  /** Broadening parameter H2O in <b> Hz/Pa </b>: */
//  Numeric Gamma_H2O() const { return mgamma_h2o; }
//  
//  /** Broadening parameter CO2 in <b> Hz/Pa </b>: */
//  Numeric Gamma_CO2() const { return mgamma_co2; }
//  
//  /** Broadening parameter H2 in <b> Hz/Pa </b>: */
//  Numeric Gamma_H2() const { return mgamma_h2; }
//  
//  /** Broadening parameter He in <b> Hz/Pa </b>: */
//  Numeric Gamma_He() const { return mgamma_he; }
//  
//  /** GAM temp. exponent N self: */
//  Numeric Gam_N_self() const { return mn_self; }
//  
//  /** GAM temp. exponent N N2: */
//  Numeric Gam_N_N2() const { return mn_n2; }
//  
//  /** GAM temp. exponent N O2: */
//  Numeric Gam_N_O2() const { return mn_o2; }
//  
//  /** GAM temp. exponent N H2O: */
//  Numeric Gam_N_H2O() const { return mn_h2o; }
//  
//  /** GAM temp. exponent N CO2: */
//  Numeric Gam_N_CO2() const { return mn_co2; }
//  
//  /** GAM temp. exponent N H2: */
//  Numeric Gam_N_H2() const { return mn_h2; }
//  
//  /** GAM temp. exponent N He: */
//  Numeric Gam_N_He() const { return mn_he; }
//  
//  /** F Pressure shift N2 in <b> Hz/Pa </b>: */
//  Numeric Delta_N2() const { return mdelta_n2; }
//  
//  /** F Pressure shift O2 in <b> Hz/Pa </b>: */
//  Numeric Delta_O2() const { return mdelta_o2; }
//  
//  /** F Pressure shift H2O in <b> Hz/Pa </b>: */
//  Numeric Delta_H2O() const { return mdelta_h2o; }
//  
//  /** F Pressure shift CO2 in <b> Hz/Pa </b>: */
//  Numeric Delta_CO2() const { return mdelta_co2; }
//  
//  /** F Pressure shift H2 in <b> Hz/Pa </b>: */
//  Numeric Delta_H2() const { return mdelta_h2; }
//  
//  /** F Pressure shift He in <b> Hz/Pa </b>: */
//  Numeric Delta_He() const { return mdelta_he; }

  /** Upper state global quanta */
  const String& Upper_GQuanta() const { return mupper_gquanta; }

  /** Lower state global quanta */
  const String& Lower_GQuanta() const { return mlower_gquanta; }

  /** Upper state local quanta */
  const String& Upper_LQuanta() const { return mupper_lquanta; }

  /** Lower state local quanta */
  const String& Lower_LQuanta() const { return mlower_lquanta; }

  /** Upper state local quanta N */
  Rational Upper_N() const { return mupper_n; }

  /** Upper state local quanta J */
  Rational Upper_J() const { return mupper_j; }

  /** Lower state local quanta N */
  Rational Lower_N() const { return mlower_n; }

  /** Lower state local quanta J */
  Rational Lower_J() const { return mlower_j; }

  /** String with quantum numbers */
  const String& QuantumNumbersString() const { return mquantum_numbers_str; }

  /** Quantum numbers */
  const QuantumNumberRecord& QuantumNumbers() const { return mquantum_numbers; }
    

  /** Indices of different broadening species in Gamma_foreign, 
   N_foreign, and Delta_foreign. */
  enum {
    BROAD_SPEC_POS_N2,
    BROAD_SPEC_POS_O2,
    BROAD_SPEC_POS_H2O,
    BROAD_SPEC_POS_CO2,
    BROAD_SPEC_POS_H2,
    BROAD_SPEC_POS_He
  };

  /** Return the number of artscat-4 foreign broadening species (6). This just
      so that we do not have to hardwire the number elsewhere. */
  static Index NBroadSpec()  {return 6;}
    
  /** Return the name of an artscat-4 broadening species, as function of its
   broadening species index. Meant to be called with the enum constants 
   defined in this class. */
  static String BroadSpecName(const Index i)  {
    switch (i) {
      case BROAD_SPEC_POS_N2:
        return "N2";
        break;
      case BROAD_SPEC_POS_O2:
        return "O2";
        break;
      case BROAD_SPEC_POS_H2O:
        return "H2O";
        break;
      case BROAD_SPEC_POS_CO2:
        return "CO2";
        break;
      case BROAD_SPEC_POS_H2:
        return "H2";
        break;
      case BROAD_SPEC_POS_He:
        return "He";
        break;
      default:
        assert(false);   // We should never end up here.
        return "";
        break;
    }
  }
  
  /** Return the internal species index (index in species_data) of an 
   artscat-4 broadening species,
   as function of its broadening spcecies index. Meant to be called with the 
   enum constants defined in this class. */
  static Index BroadSpecSpecIndex(const Index i);

  /** Converts line parameters from ARTSCAT-3 to ARTSCAT-4 format.
     
     ARTSCAT-4 lines contain more information than ARTSCAT-3 lines,
     particularly they contain separate broadening parameters for six
     different broadening species. So a real conversion is not
     possible. What this method does is copy the air broadening (and shift)
     parameters from ARTSCAT-3 to all ARTSCAT-4 broadening species. The
     case that one of the broadening species is identical to the Self
     species is also handled correctly.
     
     The idea is that the ARTSCAT-4 line list generated in this way should
     give identical RT simulation results as the original ARTSCAT-3
     list. This is verified in one of the test controlfiles.
     
     Currently only broadening and shift parameters are handled here. There
     are some other additional fields in ARTSCAT-4, which we so far ignore.
   */
  void ARTSCAT4FromARTSCAT3();
  
 /** Set to NaN all parameters that are not in ARTSCAT-4. */
  void ARTSCAT4UnusedToNaN() {
      
      // Resize aux array to 0, not used in ARTSCAT-4:
      maux.resize(0);
      
      // Set other parameters to NAN:
      magam    = NAN;
      mnair    = NAN;
      mpsf     = NAN;
      mtgam    = NAN;
      
      mdf      = NAN;
      mdi0     = NAN;
      mdagam   = NAN;
      mdsgam   = NAN;
      mdnair   = NAN;
      mdnself  = NAN;
      mdpsf    = NAN;
    }
  
  /** Read one line from a stream associated with a HITRAN 1986-2001 file. The
    HITRAN format is as follows (directly from the HITRAN documentation):

    \verbatim
    Each line consists of 100
    bytes of ASCII text data, followed by a line feed (ASCII 10) and
    carriage return (ASCII 13) character, for a total of 102 bytes per line.
    Each line can be read using the following READ and FORMAT statement pair
    (for a FORTRAN sequential access read):

          READ(3,800) MO,ISO,V,S,R,AGAM,SGAM,E,N,d,V1,V2,Q1,Q2,IERF,IERS,
         *  IERH,IREFF,IREFS,IREFH
    800   FORMAT(I2,I1,F12.6,1P2E10.3,0P2F5.4,F10.4,F4.2,F8.6,2I3,2A9,3I1,3I2)

    Each item is defined below, with its format shown in parenthesis.

      MO  (I2)  = molecule number
      ISO (I1)  = isotopologue number (1 = most abundant, 2 = second, etc)
      V (F12.6) = frequency of transition in wavenumbers (cm-1)
      S (E10.3) = intensity in cm-1/(molec * cm-2) at 296 Kelvin
      R (E10.3) = transition probability squared in Debyes**2
      AGAM (F5.4) = air-broadened halfwidth (HWHM) in cm-1/atm at 296 Kelvin
      SGAM (F5.4) = self-broadened halfwidth (HWHM) in cm-1/atm at 296 Kelvin
      E (F10.4) = lower state energy in wavenumbers (cm-1)
      N (F4.2) = coefficient of temperature dependence of air-broadened halfwidth
      d (F8.6) = shift of transition due to pressure (cm-1)
      V1 (I3) = upper state global quanta index
      V2 (I3) = lower state global quanta index
      Q1 (A9) = upper state local quanta
      Q2 (A9) = lower state local quanta
      IERF (I1) = accuracy index for frequency reference
      IERS (I1) = accuracy index for intensity reference
      IERH (I1) = accuracy index for halfwidth reference
      IREFF (I2) = lookup index for frequency
      IREFS (I2) = lookup index for intensity
      IREFH (I2) = lookup index for halfwidth

    The molecule numbers are encoded as shown in the table below:

      0= Null    1=  H2O    2=  CO2    3=   O3    4=  N2O    5=   CO
      6=  CH4    7=   O2    8=   NO    9=  SO2   10=  NO2   11=  NH3
     12= HNO3   13=   OH   14=   HF   15=  HCl   16=  HBr   17=   HI
     18=  ClO   19=  OCS   20= H2CO   21= HOCl   22=   N2   23=  HCN
     24=CH3Cl   25= H2O2   26= C2H2   27= C2H6   28=  PH3   29= COF2
     30=  SF6   31=  H2S   32=HCOOH
    \endverbatim

    The function attempts to read a line of data from the
    catalogue. It returns false if it succeeds. Otherwise, if eof is
    reached, it returns true. If an error occurs, a runtime_error is
    thrown. When the function looks for a data line, comment lines are
    automatically skipped. It is checked if the data record has the right
    number of characters. If not, a runtime_error is thrown.

    \param is Stream from which to read
    \exception runtime_error Some error occured during the read
    \return false=ok (data returned), true=eof (no data returned)

    \author Stefan Buehler */
  bool ReadFromHitran2001Stream(istream& is, const Verbosity& verbosity);



  /** Read one line from a stream associated with a HITRAN 2004 file. The
    HITRAN format is as follows:

    \verbatim
    Each line consists of 160 ASCII characters, followed by a line feed (ASCII 10)
    and carriage return (ASCII 13) character, for a total of 162 bytes per line.

    Each item is defined below, with its Fortran format shown in parenthesis.

    (I2)     molecule number
    (I1)     isotopologue number (1 = most abundant, 2 = second, etc)
    (F12.6)  vacuum wavenumbers (cm-1)
    (E10.3)  intensity in cm-1/(molec * cm-2) at 296 Kelvin
    (E10.3)  Einstein-A coefficient (s-1)
    (F5.4)   air-broadened halfwidth (HWHM) in cm-1/atm at 296 Kelvin
    (F5.4)   self-broadened halfwidth (HWHM) in cm-1/atm at 296 Kelvin
    (F10.4)  lower state energy (cm-1)
    (F4.2)   coefficient of temperature dependence of air-broadened halfwidth
    (F8.6)   air-broadened pressure shift of line transition at 296 K (cm-1)
    (A15)    upper state global quanta
    (A15)    lower state global quanta
    (A15)    upper state local quanta
    (A15)    lower state local quanta
    (I1)     uncertainty index for wavenumber
    (I1)     uncertainty index for intensity
    (I1)     uncertainty index for air-broadened half-width
    (I1)     uncertainty index for self-broadened half-width
    (I1)     uncertainty index for temperature dependence
    (I1)     uncertainty index for pressure shift
    (I2)     index for table of references correspond. to wavenumber
    (I2)     index for table of references correspond. to intensity
    (I2)     index for table of references correspond. to air-broadened half-width
    (I2)     index for table of references correspond. to self-broadened half-width
    (I2)     index for table of references correspond. to temperature dependence
    (I2)     index for table of references correspond. to pressure shift
    (A1)     flag (*) for lines supplied with line-coupling algorithm
    (F7.1)   upper state statistical weight
    (F7.1)   lower state statistical weight

     The molecule numbers are encoded as shown in the table below:

      0= Null    1=  H2O    2=  CO2    3=   O3    4=  N2O    5=    CO
      6=  CH4    7=   O2    8=   NO    9=  SO2   10=  NO2   11=   NH3
     12= HNO3   13=   OH   14=   HF   15=  HCl   16=  HBr   17=    HI
     18=  ClO   19=  OCS   20= H2CO   21= HOCl   22=   N2   23=   HCN
     24=CH3Cl   25= H2O2   26= C2H2   27= C2H6   28=  PH3   29=  COF2
     30=  SF6   31=  H2S   32=HCOOH   33=  HO2   34=    O   35=ClONO2
     36=  NO+   37= HOBr   38= C2H4
    \endverbatim

    CH3OH is not included in ARTS because its total internal partition
    sum is not known yet.

    The function attempts to read a line of data from the
    catalogue. It returns false if it succeeds. Otherwise, if eof is
    reached, it returns true. If an error occurs, a runtime_error is
    thrown. When the function looks for a data line, comment lines are
    automatically skipped. It is checked if the data record has the right number
    of characters (comment lines are ignored). If not, a runtime_error is thrown.
    If the molecule is unknown to ARTS, a warning is prompted but the
    program continues (ignoring this record). For CH3OH this
    warning will be issued even when using the regular Hitran 2004 data base
    (see above).
    If the line center is below fmin, mf is set to -1 and the caller should ignore
    this line.

    \param is Stream from which to read
    \param verbosity Verbosity
    \param fmin Skip line if mf < fmin
    \exception runtime_error Some error occured during the read
    \return false=ok (data returned), true=eof (no data returned)

    \author Stefan Buehler, Hermann Berg */
  bool ReadFromHitran2004Stream(istream& is, const Verbosity& verbosity, const Numeric fmin=0);




  /** Read one line from a stream associated with a MYTRAN2 file. The MYTRAN2
    format is as follows (directly taken from the abs_my.c documentation):

    \verbatim
    The MYTRAN format is as follows (FORTRAN notation):
    FORMAT(I2,I1,F13.4,1PE10.3,0P2F5.2,F10.4,2F4.2,F8.6,F6.4,2I3,2A9,4I1,3I2)
   
    Each item is defined below, with its FORMAT String shown in
    parenthesis.
   
       MO  (I2)      = molecule number
       ISO (I1)      = isotopologue number (1 = most abundant, 2 = second, etc)
    *  F (F13.4)     = frequency of transition in MHz
    *  errf (F8.4)   = error in f in MHz
       S (E10.3)     = intensity in cm-1/(molec * cm-2) at 296 K
    *  AGAM (F5.4)   = air-broadened halfwidth (HWHM) in MHz/Torr at Tref
    *  SGAM (F5.4)   = self-broadened halfwidth (HWHM) in MHz/Torr at Tref
       E (F10.4)     = lower state energy in wavenumbers (cm-1)
       N (F4.2)      = coefficient of temperature dependence of 
                       air-broadened halfwidth
    *  N_self (F4.2) = coefficient of temperature dependence of 
                       self-broadened halfwidth
    *  Tref (F7.2)   = reference temperature for AGAM and SGAM 
    *  d (F9.7)      = shift of transition due to pressure (MHz/Torr)
       V1 (I3)       = upper state global quanta index
       V2 (I3)       = lower state global quanta index
       Q1 (A9)       = upper state local quanta
       Q2 (A9)       = lower state local quanta
       IERS (I1)     = accuracy index for S
       IERH (I1)     = accuracy index for AGAM
    *  IERN (I1)     = accuracy index for N

   
    The asterisks mark entries that are different from HITRAN.

    Note that AGAM and SGAM are for the temperature Tref, while S is
    still for 296 K!
   
    The molecule numbers are encoded as shown in the table below:
   
     0= Null    1=  H2O    2=  CO2    3=   O3    4=  N2O    5=   CO
     6=  CH4    7=   O2    8=   NO    9=  SO2   10=  NO2   11=  NH3
    12= HNO3   13=   OH   14=   HF   15=  HCl   16=  HBr   17=   HI
    18=  ClO   19=  OCS   20= H2CO   21= HOCl   22=   N2   23=  HCN
    24=CH3Cl   25= H2O2   26= C2H2   27= C2H6   28=  PH3   29= COF2
    30=  SF6   31=  H2S   32=HCOOH   33= HO2    34=    O   35= CLONO2
    36=  NO+   37= Null   38= Null   39= Null   40=H2O_L   41= Null
    42= Null   43= OCLO   44= Null   45= Null   46=BRO     47= Null
    48= H2SO4  49=CL2O2

    All molecule numbers are from HITRAN, except for species with id's
    greater or equals 40, which are not included in HITRAN.
    (E.g.: For BrO, iso=1 is Br-79-O,iso=2 is  Br-81-O.)
    \endverbatim

    The function attempts to read a line of data from the
    catalogue. It returns false if it succeeds. Otherwise, if eof is
    reached, it returns true. If an error occurs, a runtime_error is
    thrown. When the function looks for a data line, comment lines are
    automatically skipped.

    \param is Stream from which to read
    \exception runtime_error Some error occured during the read
    \return false=ok (data returned), true=eof (no data returned)

    \date 31.10.00
    \author Axel von Engeln 
  */
  bool ReadFromMytran2Stream(istream& is, const Verbosity& verbosity);


  /** Read one line from a stream associated with a JPL file. The JPL
    format is as follows (directly taken from the jpl documentation):

    \verbatim 
    The catalog line files are composed of 80-character lines, with one
    line entry per spectral line.  The format of each line is:

    \label{lfmt}
    \begin{tabular}{@{}lccccccccr@{}}
    FREQ, & ERR, & LGINT, & DR, & ELO, & GUP, & TAG, & QNFMT, & QN${'}$, & QN${''}$\\ 
    (F13.4, & F8.4, & F8.4, & I2, & F10.4, & I3, & I7, & I4, & 6I2, & 6I2)\\
    \end{tabular}

    \begin{tabular}{lp{4.5in}} 
    FREQ: & Frequency of the line in MHz.\\ 
    ERR: & Estimated or experimental error of FREQ in MHz.\\ 
    LGINT: &Base 10 logarithm of the integrated intensity 
    in units of \linebreak nm$^2$$\cdot$MHz at 300 K. (See Section 3 for 
    conversions to other units.)\\ 
    DR: & Degrees of freedom in the rotational partition 
    function (0 for atoms, 2 for linear molecules, and 3 for nonlinear 
    molecules).\\ 
    ELO: &Lower state energy in cm$^{-1}$ relative to the lowest energy 
    spin--rotation level in ground vibronic state.\\ 
    GUP: & Upper state degeneracy.\\ 
    TAG: & Species tag or molecular identifier. 
    A negative value flags that the line frequency has 
    been measured in the laboratory.  The absolute value of TAG is then the 
    species tag and ERR is the reported experimental error.  The three most 
    significant digits of the species tag are coded as the mass number of the 
    species, as explained above.\\ 
    QNFMT: &Identifies the format of the quantum numbers 
    given in the field QN. These quantum number formats are given in Section 5 
    and are different from those in the first two editions of the catalog.\\ 
    QN${'}$: & Quantum numbers for the upper state coded 
    according to QNFMT.\\ 
    QN${''}$: & Quantum numbers for the lower state.\\
    \end{tabular} 
    \endverbatim

    The function attempts to read a line of data from the
    catalogue. It returns false if it succeeds. Otherwise, if eof is
    reached, it returns true. If an error occurs, a runtime_error is
    thrown. When the function looks for a data line, comment lines are
    automatically skipped (unused in jpl).

    \param is Stream from which to read
    \exception runtime_error Some error occured during the read
    \return false=ok (data returned), true=eof (no data returned)

    \date 01.11.00
    \author Axel von Engeln */
  bool ReadFromJplStream(istream& is, const Verbosity& verbosity);

  /** Read one line from a stream associated with an ARTSCAT-3 file.

      Format: see Documentation of class LineRecord

      The function attempts to read a line of data from the
      catalogue. It returns false if it succeeds. Otherwise, if eof is
      reached, it returns true. If an error occurs, a runtime_error is
      thrown. When the function looks for a data line, comment lines are
      automatically skipped.

      \param is Stream from which to read
      \exception runtime_error Some error occured during the read
      \return false=ok (data returned), true=eof (no data returned)

      \date   2000-12-15
      \author Oliver Lemke

      
      \date   2001-06-20
      \author Stefan Buehler
*/
  bool ReadFromArtscat3Stream(istream& is, const Verbosity& verbosity);

  /** Read one line from a stream associated with an ARTSCAT-4 file.
   
   Format: see Documentation of class LineRecord
   
   The function attempts to read a line of data from the
   catalogue. It returns false if it succeeds. Otherwise, if eof is
   reached, it returns true. If an error occurs, a runtime_error is
   thrown. When the function looks for a data line, comment lines are
   automatically skipped.
   
   \param is Stream from which to read
   \exception runtime_error Some error occured during the read
   \return false=ok (data returned), true=eof (no data returned)
   
   \date   2012-02-10
   \author Oliver Lemke
   */
  bool ReadFromArtscat4Stream(istream& is, const Verbosity& verbosity);
    
private:
  // Version number:
  Index mversion;
  // Molecular species index: 
  Index mspecies;
  // Isotopologue species index:
  Index misotopologue;
  // The line center frequency in Hz:
  Numeric mf;
  // The pressure shift parameter in Hz/Pa:
  Numeric mpsf;
  // The line intensity in m^2/Hz:
  Numeric mi0;
  // Reference temperature for I0 in K:
  Numeric mti0;
  // Lower state energy in cm^-1:
  Numeric melow;
  // Air broadened width in Hz/Pa:
  Numeric magam;
  // Self broadened width in Hz/Pa:
  Numeric msgam;
  // AGAM temperature exponent (dimensionless):
  Numeric mnair;
  // SGAM temperature exponent (dimensionless):
  Numeric mnself;
  // Reference temperature for AGAM and SGAM in K:
  Numeric mtgam;
  // Array to hold auxiliary parameters:
  ArrayOfNumeric maux;
  //
  // Fields for the spectroscopic parameters accuracies
  //
  // Accuracy for line center frequency in Hz:
  Numeric mdf;
  // Accuracy for line intensity in %:
  Numeric mdi0;
  // Accuracy for air broadened width in %:
  Numeric mdagam;
  // Accuracy for self broadened width in %:
  Numeric mdsgam;
  // Accuracy for AGAM temperature exponent in %:
  Numeric mdnair;
  //  Accuracy for SGAM temperature exponent in %:
  Numeric mdnself;
 //  Accuracy for pressure shift in %:
  Numeric mdpsf;
  
  //// New fields in ARTSCAT-4
  
  // Einstein A-coefficient in 1/s:
  Numeric ma;
  // Upper state stat. weight:
  Numeric mgupper;
  // Lower state stat. weight:
  Numeric mglower;
  
  // Broadening parameter self in Hz/Pa:
  //  Numeric mgamma_self;
  // Already in artscat-3 as msgam
    
  // Array of foreign broadening parameters in Hz/Pa. Parameters for
  // individual species can be found using the enum defined in this class.
  Vector mgamma_foreign;
  
//  // Broadening parameter N2 in Hz/Pa:
//  Numeric mgamma_n2;
//  // Broadening parameter O2 in Hz/Pa:
//  Numeric mgamma_o2;
//  // Broadening parameter H2O in Hz/Pa:
//  Numeric mgamma_h2o;
//  // Broadening parameter CO2 in Hz/Pa:
//  Numeric mgamma_co2;
//  // Broadening parameter H2 in Hz/Pa:
//  Numeric mgamma_h2;
//  // Broadening parameter He in Hz/Pa:
//  Numeric mgamma_he;

  // GAM temp. exponent self:
  //  Numeric mn_self;
  // Already in artscat-3 as msgam mnself

  // Array of foreign temp. exponents (dimensionless). Parameters for
  // individual species can be found using the enum defined in this class.
  Vector mn_foreign;

//  // GAM temp. exponent N2:
//  Numeric mn_n2;
//  // GAM temp. exponent O2:
//  Numeric mn_o2;
//  // GAM temp. exponent H2O:
//  Numeric mn_h2o;
//  // GAM temp. exponent CO2:
//  Numeric mn_co2;
//  // GAM temp. exponent H2:
//  Numeric mn_h2;
//  // GAM temp. exponent He:
//  Numeric mn_he;
  
  // Array of pressure shift parameters in Hz/Pa. Parameters for
  // individual species can be found using the enum defined in this class.
  Vector mdelta_foreign;

//  // F Pressure shift N2 in Hz/Pa:
//  Numeric mdelta_n2;
//  // F Pressure shift O2 in Hz/Pa:
//  Numeric mdelta_o2;
//  // F Pressure shift H2O in Hz/Pa:
//  Numeric mdelta_h2o;
//  // F Pressure shift CO2 in Hz/Pa:
//  Numeric mdelta_co2;
//  // F Pressure shift H2 in Hz/Pa:
//  Numeric mdelta_h2;
//  // F Pressure shift He in Hz/Pa:
//  Numeric mdelta_he;

  /** Upper state global quanta */
  String mupper_gquanta;
  /** Lower state global quanta */
  String mlower_gquanta;
  /** Upper state local quanta */
  String mupper_lquanta;
  /** Lower state local quanta */
  String mlower_lquanta;
  /** Upper state local N quanta */
  Rational mupper_n;
  /** Upper state local J quanta */
  Rational mupper_j;
  /** Lower state local N quanta */
  Rational mlower_n;
  /** Lower state local J quanta */
  Rational mlower_j;

  /** String with quantum numbers for ARTSCAT-4 */
  String mquantum_numbers_str;

  /** Quantum numbers from HITRAN */
  QuantumNumberRecord mquantum_numbers;
};

/** Output operator for LineRecord. The result should look like a
    catalogue line.

    \author Stefan Buehler */
ostream& operator<<(ostream& os, const LineRecord& lr);


//======================================================================
//         Typedefs for LineRecord Arrays
//======================================================================

/** Holds a list of spectral line data.
    \author Stefan Buehler */
typedef Array<LineRecord> ArrayOfLineRecord;

/** Holds a lists of spectral line data for each tag group.
    Dimensions: (tag_groups.nelem()) (number of lines for this tag)
    \author Stefan Buehler */
typedef Array< Array<LineRecord> > ArrayOfArrayOfLineRecord;


//======================================================================
//         Functions for searches inside the line catalog
//======================================================================

typedef enum {
    LINE_MATCH_FIRST,
    LINE_MATCH_UNIQUE,
    LINE_MATCH_ALL
} LineMatchingCriteria;


//! Find lines matching the given criteria.
/**
 \param[out] matches        Matching indexes in abs_lines
 \param[in]  species        Species index (-1 matches all)
 \param[in]  isotopologue   Isotopologue index (-1 matches all)
 \param[in]  qr             QuantumNumberRecord
 \param[in]  match_criteria One of LINE_MATCH_FIRST, LINE_MATCH_UNIQUE,
                            LINE_MATCH_ALL

 \returns true if the match_criteria was satisfied
 */
bool find_matching_lines(ArrayOfIndex& matches,
                         const ArrayOfLineRecord& abs_lines,
                         const Index species,
                         const Index isotopologue,
                         const QuantumNumberRecord qr,
                         const LineMatchingCriteria match_criteria = LINE_MATCH_ALL);

#endif // linerecord_h
