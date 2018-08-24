/* Copyright (C) 2000-2012
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
    Declarations required for the calculation of absorption coefficients.

    This is the file from arts-1-0, back-ported to arts-1-1.

    \author Stefan Buehler, Axel von Engeln
*/

#ifndef absorption_h
#define absorption_h

#include <stdexcept>
#include <cmath>
#include "matpackI.h"
#include "array.h"
#include "mystring.h"
#include "make_array.h"
#include "messages.h"
#include "abs_species_tags.h"
#include "linerecord.h"
#include "linemixingrecord.h"


/** The type that is used to store pointers to lineshape
    functions.  */
typedef void (*lsf_type)(Vector&,
                         Vector&,
                         Vector&,
                         const Numeric,
                         const Numeric,
                         const Numeric,
                         ConstVectorView);

/** Lineshape related information. There is one LineshapeRecord for
    each available lineshape function.

    \author Stefan Buehler
    \date   2000-08-21  */
class LineshapeRecord{
public:

  /** Default constructor. */
  LineshapeRecord() : mname(),
                      mdescription(),
                      mphase(),
                      mfunction()
  { /* Nothing to do here. */ }

  /** Initializing constructor, used to build the lookup table. */
  LineshapeRecord(const String& name,
                  const String& description,
                  lsf_type      function,
                  const bool    phase)
    : mname(name),
      mdescription(description),
      mphase(phase),
      mfunction(function)
  { /* Nothing to do here. */ }
  /** Return the name of this lineshape. */
  const String&  Name()        const { return mname;        }   
  /** Return the description text. */
  const String&  Description() const { return mdescription; }
  /** Return pointer to lineshape function. */
  lsf_type Function() const { return mfunction; }
  /** Returns true if lineshape function calculates phase information. */
  bool Phase() const { return mphase; }
private:        
  String  mname;        ///< Name of the function (e.g., Lorentz).
  String  mdescription; ///< Short description.
  bool    mphase;       ///< Does this lineshape calculate phase information?
  lsf_type mfunction;   ///< Pointer to lineshape function.

};

/** The type that is used to store pointers to lineshape
    normalization functions.  */
typedef void (*lsnf_type)(Vector&,
                          const Numeric,
                          ConstVectorView,
                          const Numeric);

/** Lineshape related normalization function information. There is one
    LineshapeNormRecord for each available lineshape normalization
    function.

    \author Axel von Engeln
    \date   2000-11-30  */
class LineshapeNormRecord{
public:

  /** Default constructor. */
  LineshapeNormRecord() : mname(),
                          mdescription(),
                          mfunction()
  { /* Nothing to do here. */ }

  /** Initializing constructor, used to build the lookup table. */
  LineshapeNormRecord(const String& name,
                      const String& description,
                      lsnf_type      function)
    : mname(name),
      mdescription(description),
      mfunction(function)
  { /* Nothing to do here. */ }
  /** Return the name of this lineshape. */
  const String&  Name()        const { return mname;        }   
  /** Return the description text. */
  const String&  Description() const { return mdescription; }
  /** Return pointer to lineshape normalization function. */
  lsnf_type Function() const { return mfunction; }
private:        
  String  mname;        ///< Name of the function (e.g., linear).
  String  mdescription; ///< Short description.
  lsnf_type mfunction;  ///< Pointer to lineshape normalization function.
};

/** Lineshape related specification like which lineshape to use, the
normalizationfactor, and the cutoff.

    \author Axel von Engeln
    \date   2001-01-05  */
class LineshapeSpec{
public:

  /** Default constructor. */
  LineshapeSpec() : mind_ls(-1),
                    mind_lsn(-1),
                    mcutoff(0.)
  { /* Nothing to do here. */ }

  /** Initializing constructor. */
  LineshapeSpec(const Index&    ind_ls,
                const Index&    ind_lsn,
                const Numeric&   cutoff)
    : mind_ls(ind_ls),
      mind_lsn(ind_lsn),
      mcutoff(cutoff)
  { /* Nothing to do here. */ }

  /** Return the index of this lineshape. */
  const Index&  Ind_ls()        const { return mind_ls; }   
  /** Set it. */
  void SetInd_ls( Index ind_ls ) { mind_ls = ind_ls; }

  /** Return the index of the normalization factor. */
  const Index&  Ind_lsn()       const { return mind_lsn; }
  /** Set it. */
  void SetInd_lsn( Index ind_lsn ) { mind_lsn = ind_lsn; }

  /** Return the cutoff frequency (in Hz). This is the distance from
      the line center outside of which the lineshape is defined to be
      zero. Negative means no cutoff.*/
  const Numeric& Cutoff() const { return mcutoff; }
  /** Set it. */
  void SetCutoff( Numeric cutoff ) { mcutoff = cutoff; }
private:        
  Index  mind_ls;
  Index  mind_lsn;
  Numeric mcutoff;
};

ostream& operator<< (ostream& os, const LineshapeSpec& lsspec);

/** Holds a list of lineshape specifications: function, normalization, cutoff.
    \author Axel von Engeln */
typedef Array<LineshapeSpec> ArrayOfLineshapeSpec;



/** Contains the lookup data for one isotopologue.
    \author Stefan Buehler */
class IsotopologueRecord{
public:

  /** Default constructor. Needed by make_array. */
  IsotopologueRecord() : mname(),
                    mabundance(0.),
                    mmass(0.),
                    mmytrantag(-1),
                    mhitrantag(-1),
                    mjpltags(),
                    mqcoeff(),
                    mqcoefftype(-1),
                    mqcoeffgrid(),
                    mqcoeffinterporder(-1)
  { /* Nothing left to do here. */ }

  /** Copy constructor. We need this, since operator= does not work
      correctly for Arrays. (Target Array has to be resized first.) */
  IsotopologueRecord(const IsotopologueRecord& x) :
    mname(x.mname),
    mabundance(x.mabundance),
    mmass(x.mmass),
    mmytrantag(x.mmytrantag),
    mhitrantag(x.mhitrantag),
    mjpltags(x.mjpltags),
    mqcoeff(),
    mqcoefftype(),
    mqcoeffgrid(),
    mqcoeffinterporder()
  { /* Nothing left to do here. */ }

  /** Constructor that sets the values. */
  IsotopologueRecord(const String&           name,
                const Numeric&          abundance,
                const Numeric&          mass,
                const Index&            mytrantag,
                const Index&            hitrantag,
                const MakeArray<Index>& jpltags) :
    mname(name),
    mabundance(abundance),
    mmass(mass),
    mmytrantag(mytrantag),
    mhitrantag(hitrantag),
    mjpltags(jpltags),
    mqcoeff(),
    mqcoefftype(PF_NOTHING),
    mqcoeffgrid(),
    mqcoeffinterporder()
  {
    // With Matpack, initialization of mjpltags from jpltags should now work correctly.

    // Some consistency checks whether the given data makes sense.
#ifndef NDEBUG
      {
        /* 1. All the tags must be positive or -1 */
        assert( (0<mmytrantag) || (-1==mmytrantag) );
        assert( (0<mhitrantag) || (-1==mhitrantag) );
        for ( Index i=0; i<mjpltags.nelem(); ++i )
          assert( (0<mjpltags[i]) || (-1==mjpltags[i]) );
      }
#endif // ifndef NDEBUG
  }

  /** Isotopologue name. */
  const String&       Name()         const { return mname;  }
  /** Normal abundance ( = isotopologue ratio). (Absolute number.) */
  const Numeric&      Abundance()    const { return mabundance; }
  /** Mass of the isotopologue. (In unified atomic mass units u)
      If I understand this correctly this is the same as g/mol. */
  const Numeric&      Mass()         const { return mmass;    }
  /** MYTRAN2 tag numbers for all isotopologues. -1 means not included. */
  const Index&          MytranTag()    const { return mmytrantag;    }
  /** HITRAN-96 tag numbers for all isotopologues. -1 means not included. */
  const Index&          HitranTag()    const { return mhitrantag;    }
  /** JPL tag numbers for all isotopologues. Empty array means not included. There
      can be more than one JPL tag for an isotopologue species, because in
      JPL different vibrational states have different tags. */
  const ArrayOfIndex&   JplTags()      const { return mjpltags;      }

  //! Check if isotopologue is actually a continuum.
  /*!
   \return True if this is a continuum.
   */
  bool isContinuum() const { return mname.length() && !isdigit(mname[0]); }

  void SetPartitionFctCoeff( const ArrayOfNumeric& qcoeff, const Index& qcoefftype )
  {
    mqcoeff = qcoeff;
    mqcoefftype = qcoefftype;
  }

  //! Calculate partition function ratio.
  /*!
    This computes the partition function ratio Q(Tref)/Q(T). 

    Unfortunately, we have to recalculate also Q(Tref) for each
    spectral line, because the reference temperatures can be
    different!
    
    \param reference_temperature The reference temperature.
    \param actual_temperature The actual temperature.
  
    \return The ratio.
  */
  Numeric CalculatePartitionFctRatio( Numeric reference_temperature,
                                      Numeric actual_temperature ) const
  {
      
      Numeric qcoeff_at_t_ref, qtemp;
      
      switch(mqcoefftype)
        {
          case PF_FROMCOEFF:
            qcoeff_at_t_ref =
            CalculatePartitionFctAtTempFromCoeff( reference_temperature );
            qtemp =
            CalculatePartitionFctAtTempFromCoeff( actual_temperature    );
            break;
          case PF_FROMTEMP:
              qcoeff_at_t_ref =
              CalculatePartitionFctAtTempFromData( actual_temperature    );
              qtemp =
              CalculatePartitionFctAtTempFromData( actual_temperature    );
              break;
          default:
              throw runtime_error("The partition functions are incorrect.\n");
              break;
        }
/*        cout << "ref_t: " << reference_temperature << ", act_t:" <<
          actual_temperature << "\n";
        cout << "ref_q: " << qcoeff_at_t_ref << ", act_q:" <<
          qtemp << "\n";
*/
        if ( qtemp > 0. ) 
            return qcoeff_at_t_ref / qtemp;
        else
          {
            ostringstream os;
            os << "Partition function of "
               << "Isotopologue " << mname
//               << " is unknown.";
               << " at T=" << actual_temperature << "K is zero or negative.";
            throw runtime_error(os.str());
          }
  }
  
  
  enum {
      PF_FROMCOEFF,   // Partition function will be from coefficients
      PF_FROMTEMP,    // Partition function will be from temperature field
      PF_NOTHING      // This will be the designated starter value
  };

private:

  // calculate the partition fct at a certain temperature
  // this is only the prototyping
  Numeric CalculatePartitionFctAtTempFromCoeff( Numeric temperature ) const;
  Numeric CalculatePartitionFctAtTempFromData( Numeric temperature ) const;

  String mname;
  Numeric mabundance;
  Numeric mmass;
  Index mmytrantag;
  Index mhitrantag;
  ArrayOfIndex mjpltags;
  Vector mqcoeff;
  Index mqcoefftype;
  Vector mqcoeffgrid;
  Index mqcoeffinterporder;
};


/** Contains the lookup data for one species.

    \author Stefan Buehler  */
class SpeciesRecord{
public:

  /** Default constructor. */
  SpeciesRecord() : mname(),
                    mdegfr(-1),
                    misotopologue() { /* Nothing to do here */ }
  
  /** The constructor used in define_species_data. */
  SpeciesRecord(const char name[],
                const Index degfr,
                const MakeArray<IsotopologueRecord>& isotopologue)
    : mname(name),
      mdegfr(degfr),
      misotopologue(isotopologue)
  {

    // Thanks to Matpack, initialization of misotopologue with isotopologue
    // should now work correctly.  

#ifndef NDEBUG
      {
        /* Check that the isotopologues are correctly sorted. */
        for ( Index i=0; i<misotopologue.nelem()-1; ++i )
          {
              assert(isnan(misotopologue[i].Abundance()) || isnan(misotopologue[i+1].Abundance())
                     || misotopologue[i].Abundance() >= misotopologue[i+1].Abundance());
          }

        /* Check that the Mytran tags are correctly sorted. */
        for ( Index i=0; i<misotopologue.nelem()-1; ++i )
          {
            if ( (0<misotopologue[i].MytranTag()) && (0<misotopologue[i+1].MytranTag()) )
              {
                assert( misotopologue[i].MytranTag() < misotopologue[i+1].MytranTag() );
            
                // Also check that the tags have the same base number:
                assert( misotopologue[i].MytranTag()/10 == misotopologue[i].MytranTag()/10 );
              }
          }

        /* Check that the Hitran tags are correctly sorted. */
        for ( Index i=0; i<misotopologue.nelem()-1; ++i )
          {
            if ( (0<misotopologue[i].HitranTag()) && (0<misotopologue[i+1].HitranTag()) )
              {
//                assert( misotopologue[i].HitranTag() < misotopologue[i+1].HitranTag() );
            
                // Also check that the tags have the same base number:
                assert( misotopologue[i].HitranTag()/10 == misotopologue[i+1].HitranTag()/10 );
              }
          }
      }
#endif // #ifndef NDEBUG
  }

  const String&               Name()     const { return mname;     }   
  Index                         Degfr()    const { return mdegfr;    }
  const Array<IsotopologueRecord>& Isotopologue()  const { return misotopologue;  }
  Array<IsotopologueRecord>&       Isotopologue()        { return misotopologue;  }
  
private:
  /** Species name. */
  String mname;
  /** Degrees of freedom. */
  Index mdegfr;
  /** Isotopologue data. */
  Array<IsotopologueRecord> misotopologue;
};


/** Auxiliary data for isotopologues */
class SpeciesAuxData
{
public:
    /** Default constructor. */
    SpeciesAuxData() : mparams() { }

    /** Resize according to builtin isotopologues in species data. */
    void initParams(Index nparams);

    /** Get single parameter value. */
    Numeric getParam(Index species, Index isotopologue, Index col) const
    {
        return mparams[species](isotopologue, col);
    }

    /** Set parameter. */
    void setParam(Index species, Index isotopologue, Index col, Numeric v)
    {
        mparams[species](isotopologue, col) = v;
    }

    /** Return a constant reference to the parameters. */
    const ArrayOfMatrix& getParams() const { return mparams; }

    /** Read parameters from input stream. */
    bool ReadFromStream(String& artsid, istream& is, Index nparams,
                        const Verbosity& verbosity);

private:
    ArrayOfMatrix mparams;
};


/** Check that isotopologue ratios for the given species are correctly defined. */
void checkIsotopologueRatios(const ArrayOfArrayOfSpeciesTag& abs_species,
                             const SpeciesAuxData& sad);

/** Fill SpeciesAuxData with default isotopologue ratios from species data. */
void fillSpeciesAuxDataWithIsotopologueRatiosFromSpeciesData(SpeciesAuxData& sad);


// is needed to map jpl tags/arts identifier to the species/isotopologue data within arts
class SpecIsoMap{
public:
  SpecIsoMap():mspeciesindex(0), misotopologueindex(0){}
  SpecIsoMap(const Index& speciesindex,
                const Index& isotopologueindex)
    : mspeciesindex(speciesindex),
      misotopologueindex(isotopologueindex) 
  {}

  // Return the index to the species 
  const Index& Speciesindex() const { return mspeciesindex; }
  // Return the index to the isotopologue
  const Index& Isotopologueindex() const { return misotopologueindex; }

private:
  Index mspeciesindex;
  Index misotopologueindex;
};



/** Output operator for SpeciesRecord. Incomplete version: only writes
    SpeciesName.

    \author Jana Mendrok */
ostream& operator<< (ostream& os, const SpeciesRecord& sr);

/** Output operator for SpeciesAuxData.
    \author Oliver Lemke */
ostream& operator<< (ostream& os, const SpeciesAuxData& sad);



/** Define the species data map.

    \author Stefan Buehler  */
void define_species_map();


void xsec_species(MatrixView               xsec_attenuation,
                  MatrixView               xsec_phase,
                  ConstVectorView          f_grid,
                  ConstVectorView          abs_p,
                  ConstVectorView          abs_t,
                  ConstMatrixView          all_vmrs,
                  const ArrayOfArrayOfSpeciesTag& abs_species,
                  const Index              this_species,
                  const ArrayOfLineRecord& abs_lines,
                  const Index              ind_ls,
                  const Index              ind_lsn,
                  const Numeric            cutoff,
                  const SpeciesAuxData&    isotopologue_ratios,
                  const Verbosity&         verbosity );


void xsec_species_line_mixing_wrapper(  MatrixView               xsec_attenuation,
                                        MatrixView               xsec_phase,
                                        const ArrayOfArrayOfLineMixingRecord& line_mixing_data,
                                        const ArrayOfArrayOfIndex& line_mixing_data_lut,
                                        ConstVectorView          f_grid,
                                        ConstVectorView          abs_p,
                                        ConstVectorView          abs_t,
                                        ConstMatrixView          all_vmrs,
                                        const ArrayOfArrayOfSpeciesTag& abs_species,
                                        const Index              this_species,
                                        const ArrayOfLineRecord& abs_lines,
                                        const Index              ind_ls,
                                        const Index              ind_lsn,
                                        const Numeric            cutoff,
                                        const SpeciesAuxData&    isotopologue_ratios,
                                        const Verbosity&         verbosity );


void xsec_species_line_mixing_2nd_order(    MatrixView               xsec_attenuation,
                                            MatrixView               xsec_phase,
                                            const ArrayOfArrayOfLineMixingRecord& line_mixing_data,
                                            const ArrayOfArrayOfIndex& line_mixing_data_lut,
                                            ConstVectorView          f_grid,
                                            ConstVectorView          abs_p,
                                            ConstVectorView          abs_t,
                                            ConstMatrixView          all_vmrs,
                                            const ArrayOfArrayOfSpeciesTag& abs_species,
                                            const Index              this_species,
                                            const ArrayOfLineRecord& abs_lines,
                                            const Index              ind_ls,
                                            const Index              ind_lsn,
                                            const Numeric            cutoff,
                                            const SpeciesAuxData&    isotopologue_ratios,
                                            const Verbosity&         verbosity );


// A helper function for energy conversion:
Numeric wavenumber_to_joule(Numeric e);


//======================================================================
//             Functions related to species
//======================================================================

Index species_index_from_species_name( String name );

String species_name_from_species_index( const Index spec_ind );


//======================================================================
//             Functions to convert the accuracy index
//======================================================================

// ********* for HITRAN database *************
// convert index for the frequency accuracy.
void convHitranIERF(     
                    Numeric&     mdf,
              const Index&       df 
                    );

// convert to percents index for intensity and halfwidth accuracy.

void convHitranIERSH(     
                    Numeric&     mdh,
              const Index&       dh 
                    );

// ********* for MYTRAN database *************
// convert index for the halfwidth accuracy.
void convMytranIER(     
                    Numeric&     mdh,
              const Index  &      dh 
                    );


// Functions to set abs_n2 and abs_h2o:

void abs_n2Set(Vector&            abs_n2,
               const ArrayOfArrayOfSpeciesTag& abs_species,
               const Matrix&    abs_vmrs,
               const Verbosity&);

void abs_h2oSet(Vector&          abs_h2o,
                const ArrayOfArrayOfSpeciesTag& abs_species,
                const Matrix&    abs_vmrs,
                const Verbosity&);

#endif // absorption_h
