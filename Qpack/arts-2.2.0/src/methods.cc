/* Copyright (C) 2000-2012
   Stefan Buehler <sbuehler@uni-bremen.de>
   Patrick Eriksson <patrick.eriksson@chalmers.se>
   Oliver Lemke <olemke@ltu.se>

   This program is free software; you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by the
   Free Software Foundation; either version 2, or (at your option) any
   later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307,
   USA. */

/*!
  \file   methods.cc
  \brief  Definition of method description data.

  This file contains only the definition of the function
  define_md_data, which sets the WSV lookup data. You have to change
  this function each time you add a new method. See methods.h for more
  documentation.

  \author Stefan Buehler
  \date 2000-06-10 */

#include "arts.h"
#include "make_array.h"
#include "methods.h"
#include "wsv_aux.h"

namespace global_data {
    Array<MdRecord> md_data_raw;
    extern const ArrayOfString wsv_group_names;
}

// Some #defines and typedefs to make the records better readable:
#define NAME(x) x
#define DESCRIPTION(x) x
#define AUTHORS     MakeArray<String>
#define OUT         MakeArray<String>
#define GOUT        MakeArray<String>
#define GOUT_TYPE   MakeArray<String>
#define GOUT_DESC   MakeArray<String>
#define IN          MakeArray<String>
#define GIN         MakeArray<String>
#define GIN_TYPE    MakeArray<String>
#define GIN_DEFAULT MakeArray<String>
#define GIN_DESC    MakeArray<String>
#define SETMETHOD(x) x
#define AGENDAMETHOD(x) x
#define USES_TEMPLATES(x) x
#define PASSWORKSPACE(x) x
#define PASSWSVNAMES(x) x


/* Here's a template record entry:  (PE 2008-09-20)

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "MethodName" ),
        DESCRIPTION
        (
        "A concise summary of the method.\n"
        "\n"
        "A more detailed description of the method. Try to describe the\n"
        "purpose of the method and important considerations. Try to avoid\n"
        "references to other WSMs as they might change. Refer to the user\n"
        "guide for more complex information (as long as it exists, or that\n"
        "you add it to AUG!).\n"
        "\n"
        "You do not need to describe workspace variables used. That\n"
        "information is found in workspace.cc. Generic\n"
        "output and input variables must be described in GIN_DESC and\n"
        "GOUT_DESC below.\n"
        ),
        AUTHORS( "Your Name" ),
        OUT(),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(         "descriptive_name_for_generic_input1" ),
        GIN_TYPE(    "GenericInput1Type" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC(    "Description for Generic Input Variable 1" )
        ));
 
 For variable descriptions longer than one line, use the following format.
 Don't forget to remove the space in '/ *' and '* /' if you copy this template.
 I had to put it in there because C++ doesn't allow nested comments.
 
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "MethodName" ),
        ...
        ...
        ...
        GIN( gin_var1, gin_var2, gin_var3 )
        GIN_TYPE( "GInput1Type", "GInput2Type", "GInput3Type" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( / * gin_var1 * /
                  "Long description for Generic Input Variable 1 "
                  "which can span multiple lines like for example "
                  "this one. Don't put any \n in the variable descriptions.",
                  / * gin_var2 * /
                  "Long description for Generic Input Variable 2 "
                  "which can span multiple lines like for example "
                  "this one. Don't put any \n in the variable descriptions.",
                  / * gin_var3 * /
                  "Long description for Generic Input Variable 3 "
                  "which can span multiple lines like for example "
                  "this one. Don't put any \n in the variable descriptions."
                  )

*/



void define_md_data_raw()
{
  // The variable md_data is defined in file methods_aux.cc.
  using global_data::md_data_raw;

  // Initialise to zero, just in case:
  md_data_raw.resize(0);

  // String with all array groups
  const String ARRAY_GROUPS = get_array_groups_as_string();
  // String with all groups that also exist as an array type
  const String GROUPS_WITH_ARRAY_TYPE = get_array_groups_as_string(true, true);
  // String with all array types whose element type is also available as a group
  const String ARRAY_GROUPS_WITH_BASETYPE = get_array_groups_as_string(true, false);

  using global_data::wsv_group_names;
  
  for (ArrayOfString::const_iterator it = wsv_group_names.begin();
       it != wsv_group_names.end(); it++)
  {
    if (*it != "Any")
    {
      md_data_raw.push_back
      (MdRecord
       (NAME( String(*it + "Create").c_str() ),
        DESCRIPTION
        (
         String("Creates a variable of group " + *it + ".\n"
                "\n"
                "After being created, the variable is uninitialized.\n"
                ).c_str()
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT(),
        GOUT(      "out" ),
        GOUT_TYPE( (*it).c_str() ),
        GOUT_DESC( "Variable to create." ),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        )
       );
    }
  }
  
  /////////////////////////////////////////////////////////////////////////////
  // Let's put in the functions in alphabetical order. This gives a clear rule
  // for where to place a new function and this gives a nicer results when
  // the functions are listed by "arts -m all".
  // No distinction is made between uppercase and lowercase letters. The sign
  // "_" comes after all letters.
  // Patrick Eriksson 2002-05-08
  /////////////////////////////////////////////////////////////////////////////

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "AbsInputFromAtmFields" ),
        DESCRIPTION
        (
         "Initialises the WSVs *abs_p*, *abs_t* and *abs_vmrs* from\n"
         "*p_grid, *t_field* and *vmr_field*.\n"
         "\n"
         "This only works for a 1D atmosphere!\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT( "abs_p", "abs_t", "abs_vmrs" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atmosphere_dim", "p_grid", "t_field", "vmr_field" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));
  
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "AbsInputFromRteScalars" ),
        DESCRIPTION
        (
         "Initialize absorption input WSVs from local atmospheric conditions.\n"
         "\n"
         "The purpose of this method is to allow an explicit line-by-line\n"
         "calculation, e.g., by *abs_coefCalc*, to be put inside the\n"
         "*propmat_clearsky_agenda*. What the method does is to prepare absorption\n"
         "input parameters (pressure, temperature, VMRs), from the input\n"
         "parameters to *propmat_clearsky_agenda*.\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT( "abs_p", "abs_t", "abs_vmrs" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "rtp_pressure", "rtp_temperature", "rtp_vmr" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_coefCalcFromXsec" ),
        DESCRIPTION
        (
         "Calculate absorption coefficients from cross sections.\n"
         "\n"
         "This calculates both the total absorption and the\n"
         "absorption per species.\n"
         "\n"
         "Cross sections are multiplied by n*VMR.\n"
         ),
        AUTHORS( "Stefan Buehler", "Axel von Engeln" ),
        OUT( "abs_coef", "abs_coef_per_species" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_xsec_per_species", "abs_vmrs", "abs_p", "abs_t" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_cont_descriptionAppend" ),
        DESCRIPTION
        (
         "Appends the description of a continuum model or a complete absorption\n"
         "model to *abs_cont_names* and *abs_cont_parameters*.\n"
         "\n"
         "See online documentation for *abs_cont_names* for a list of\n"
         "allowed models and for information what parameters they require. See\n"
         "file includes/continua.arts for default parameters for the various models.\n"
         ),
        AUTHORS( "Thomas Kuhn", "Stefan Buehler" ),
        OUT( "abs_cont_names", 
             "abs_cont_models",
             "abs_cont_parameters" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_cont_names", 
            "abs_cont_models",
            "abs_cont_parameters" ),
        GIN( "tagname", "model",  "userparam" ),
        GIN_TYPE(    "String",  "String", "Vector" ),
        GIN_DEFAULT( NODEF,     NODEF,    "[]"),
        GIN_DESC(
         "The name (species tag) of a continuum model. Must match one\n"
         "of the models implemented in ARTS.\n",
         "A string selecting a particular continuum/full model under this\n"
         "species tag.\n",
         "A Vector containing the required parameters for the selected model.\n"
         "The meaning of the parameters and how many parameters are required\n"
         "depends on the model.\n" )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_cont_descriptionInit" ),
        DESCRIPTION
        (
         "Initializes the two workspace variables for the continuum description,\n"
         "*abs_cont_names* and *abs_cont_parameters*.\n"
         "\n"
         "This method does not really do anything, except setting the two\n"
         "variables to empty Arrays. It is just necessary because the method\n"
         "*abs_cont_descriptionAppend* wants to append to the variables.\n"
         "\n"
         "Formally, the continuum description workspace variables are required\n"
         "by the absorption calculation methods (e.g., *abs_coefCalc*). Therefore you\n"
         "always have to call at least *abs_cont_descriptionInit*, even if you do\n"
         "not want to use any continua.\n"
         ),
        AUTHORS( "Thomas Kuhn", "Stefan Buehler" ),
        OUT( "abs_cont_names", 
             "abs_cont_models",
             "abs_cont_parameters" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_lineshapeDefine" ),
        DESCRIPTION
        (
         "Set the lineshape for all calculated lines.\n"
         "\n"
         "Sets the lineshape function. Beside the lineshape function itself, you\n"
         "also have so select a forefactor and a frequency cutoff. The\n"
         "forefactor is later multiplied with the lineshape function.\n"
         "\n"
         "The cutoff frequency is used to make lineshapes finite in frequency,\n"
         "the response outside the cutoff is set to zero, and the lineshape\n"
         "value at the cutoff frequency is subtracted from the overall lineshape\n"
         "as a constant offset. This ensures that the lineshape goes to zero at\n"
         "the cutoff frequency without a discontinuity.\n"
         "\n"
         "We generate only one copy of the lineshape settings. Absorption\n"
         "routines check for this case and use it for all species.\n"
         "\n"
         "The allowed values for the input parameters are:\n"
         "\n"
         "shape:\n"
         "   no_shape:                 no specified shape\n"
         "   Doppler:                  Doppler lineshape\n"
         "   Lorentz:                  Lorentz lineshape\n"
         "   Voigt_Kuntz3:             Kuntz approximation to the Voigt lineshape,\n"
         "                             accuracy > 2x10^(-3)\n"
         "   Voigt_Kuntz4:             Kuntz approximation to the Voigt lineshape,\n"
         "                             accuracy > 2x10^(-4)\n"
         "   Voigt_Kuntz6:             Kuntz approximation to the Voigt lineshape,\n"
         "                             accuracy > 2x10^(-6)\n"
         "   Voigt_Drayson:            Drayson approximation to the Voigt lineshape\n"
         "   Rosenkranz_Voigt_Drayson: Rosenkrantz oxygen absortion with overlap correction\n"
         "                             on the basis of Drayson routine\n"
         "   Rosenkranz_Voigt_Kuntz6 : Rosenkrantz oxygen absortion with overlap correction\n"
         "                             on the basis of Kuntz routine, accuracy > 2x10^(-6)\n"
         "   CO2_Lorentz:              Lorentz multiplied with Cousin's chi factors\n"
         "   CO2_Drayson:              Drayson multiplied with Cousin's chi factors\n"
         "   Faddeeva_Algorithm_916:   Faddeeva function based on Zaghloul, M.R. and\n"
         "                             A.N. Ali (2011).  Implementation by Steven G. Johnson\n"
         "                             under the MIT License (attainable through\n"
         "                             http://ab-initio.mit.edu/Faddeeva)\n"
         "\n"
         "forefactor:\n"
         "   no_norm:                  1\n"
         "   quadratic:                (f/f0)^2\n"
         "   VVH:                      (f*tanh(h*f/(2k*T))) / (f0*tanh(h*f0/(2k*T)))\n"
         "\n"
         "cutoff:\n"
         "    -1:                      no cutoff\n"
         "   <Number>:                 positive cutoff frequency in Hz\n"
         ),
        AUTHORS( "Axel von Engeln", "Stefan Buehler" ),
        OUT( "abs_lineshape" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN( "shape",  "forefactor", "cutoff" ),
        GIN_TYPE(    "String", "String",              "Numeric" ),
        GIN_DEFAULT( NODEF,    NODEF,                 NODEF ),
        GIN_DESC( "Line shape function.",
                  "Normalization factor.",
                  "Cutoff frequency [Hz]." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_lineshape_per_tgDefine" ),
        DESCRIPTION
        (
         "Set the lineshape, separately for each absorption species.\n"
         "\n"
         "This method is similar to *abs_lineshapeDefine*, except that a\n"
         "different lineshape can be set for each absorption species (see\n"
         "*abs_species*). For example, you might want to use different values of\n"
         "the cutoff frequency for different species.\n"
         "\n"
         "For detailed documentation on the available options for the input\n"
         "parameters see documentation of method *abs_lineshapeDefine*.\n"
         ),
        AUTHORS( "Axel von Engeln", "Stefan Buehler" ),
        OUT( "abs_lineshape" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_species" ),
        GIN( "shape",        "normalizationfactor", "cutoff" ),
        GIN_TYPE(    "ArrayOfString", "ArrayOfString",        "Vector" ),
        GIN_DEFAULT( NODEF,          NODEF,                 NODEF ),
        GIN_DESC( "Line shape function for each species.",
                  "Normalization factor for each species.",
                  "Cutoff frequency [Hz] for each species." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_linesArtscat4FromArtscat3" ),
        DESCRIPTION
        (
	 "Convert a line list from ARTSCAT-3 to ARTSCAT-4 format.\n"
	 "\n"
	 "ARTSCAT-4 lines contain more information than ARTSCAT-3 lines,\n"
	 "particularly they contain separate broadening parameters for six\n"
	 "different broadening species. So a real conversion is not\n"
	 "possible. What this method does is copy the air broadening (and shift)\n"
	 "parameters from ARTSCAT-3 to all ARTSCAT-4 broadening species. The\n"
	 "case that one of the broadening species is identical to the Self\n"
	 "species is also handled correctly.\n"
	 "\n"
	 "The idea is that the ARTSCAT-4 line list generated in this way should\n"
	 "give identical RT simulation results as the original ARTSCAT-3\n"
	 "list. This is verified in one of the test controlfiles.\n"
	 "\n"
	 "Currently only broadening and shift parameters are handled here. There\n"
	 "are some other additional fields in ARTSCAT-4, which we so far ignore.\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT( "abs_lines" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_lines" ),
        GIN(  ),
        GIN_TYPE(     ),
        GIN_DEFAULT(  ),
        GIN_DESC(  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_linesReadFromArts" ),
        DESCRIPTION
        (
         "Read all the lines from an Arts catalogue file in the\n"
         "given frequency range. Otherwise a runtime error will be\n"
         "thrown\n"
         "\n"
         "Please note that all lines must correspond\n"
         "to legal species / isotopologue combinations\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT( "abs_lines" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN( "filename", "fmin",    "fmax" ),
        GIN_TYPE(    "String",   "Numeric", "Numeric" ),
        GIN_DEFAULT( NODEF,      NODEF,     NODEF ),
        GIN_DESC( "Name (and path) of the catalogue file.",
                  "Minimum frequency for lines to read [Hz].",
                  "Maximum frequency for lines to read [Hz]." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_linesReadFromHitran" ),
        DESCRIPTION
        (
         "Read all the lines from HITRAN 2004 and later catalogue file in\n"
         "the given frequency range. Otherwise a runtime error is thrown.\n"
         "\n"
         "Records of molecules unknown to ARTS are ignored but a\n"
         "warning is issued. In particular this happens for CH3OH\n"
         "(HITRAN molecule number 39) because there is no total internal\n"
         "partition sum available.\n"
         "\n"
         "The database must be sorted by increasing frequency!\n"
         "\n"
         "WWW access of the HITRAN catalogue: http://www.hitran.com/\n"
         "\n"
         "For data in the Hitran 1986-2001 format use the workspace\n"
         "method *abs_linesReadFromHitranPre2004*\n"
         ),
        AUTHORS( "Hermann Berg", "Thomas Kuhn" ),
        OUT( "abs_lines" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN( "filename",  "fmin",    "fmax" ),
        GIN_TYPE( "String", "Numeric", "Numeric" ),
        GIN_DEFAULT( NODEF,       NODEF,     NODEF ),
        GIN_DESC( "Name (and path) of the catalogue file.",
                  "Minimum frequency for lines to read [Hz].",
                  "Maximum frequency for lines to read [Hz]." )
        ));
  
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_linesReadFromHitranPre2004" ),
        DESCRIPTION
        (
         "Read all the lines from a HITRAN 1986-2001 catalogue file in\n"
         "the given frequency range. Otherwise a runtime error will be\n"
         "thrown. For HITRAN 2004 and later line data use the workspace\n"
         "method *abs_linesReadFromHitran*.\n"
         "\n"
         "Please note that all lines must correspond to legal\n"
         "species / isotopologue combinations and that the line data\n"
         "file must be sorted by increasing frequency\n"
         "\n"
         "WWW access of the HITRAN catalogue: http://www.hitran.com/\n"
         ),
        AUTHORS( "Thomas Kuhn" ),
        OUT( "abs_lines" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN( "filename",  "fmin",    "fmax" ),
        GIN_TYPE(    "String",    "Numeric", "Numeric" ),
        GIN_DEFAULT( NODEF,       NODEF,     NODEF ),
        GIN_DESC( "Name (and path) of the catalogue file.",
                  "Minimum frequency for lines to read [Hz].",
                  "Maximum frequency for lines to read [Hz]." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_linesReadFromJpl" ),
        DESCRIPTION
        (
         "Read all the lines from a JPL catalogue file in the\n"
         "given frequency range. Otherwise a runtime error will be\n"
         "thrown\n"
         "\n"
         "Please note that all lines must correspond\n"
         "to legal species / isotopologue combinations.\n"
         "\n"
         "WWW access of the JPL catalogue: http://spec.jpl.nasa.gov/\n"
         ),
        AUTHORS( "Thomas Kuhn" ),
        OUT( "abs_lines" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN( "filename",  "fmin", "fmax" ),
        GIN_TYPE( "String", "Numeric", "Numeric" ),
        GIN_DEFAULT( NODEF,       NODEF,     NODEF ),
        GIN_DESC( "Name (and path) of the catalogue file.",
                  "Minimum frequency for lines to read [Hz].",
                  "Maximum frequency for lines to read [Hz]." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_linesReadFromMytran2" ),
        DESCRIPTION
        (
         "Read all the lines from a MYTRAN2 catalogue file in the\n"
         "given frequency range. Otherwise a runtime error will be\n"
         "thrown\n"
         "\n"
         "Please note that all lines must correspond\n"
         "to legal species / isotopologue combinations\n"
         ),
        AUTHORS( "Axel von Engeln", "Stefan Buehler" ),
        OUT( "abs_lines" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN( "filename", "fmin", "fmax" ),
        GIN_TYPE( "String", "Numeric", "Numeric" ),
        GIN_DEFAULT( NODEF,       NODEF,     NODEF ),
        GIN_DESC( "Name (and path) of the catalogue file.",
                  "Minimum frequency for lines to read [Hz].",
                  "Maximum frequency for lines to read [Hz]." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_linesReadFromSplitArtscat" ),
        DESCRIPTION
        (
         "Read all the lines in the given frequency range from a split\n"
         "Arts catalogue file.\n"
         "\n"
         "Please note that all lines must correspond\n"
         "to legal species / isotopologue combinations\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( "abs_lines" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_species" ),
        GIN(         "basename", "fmin",    "fmax" ),
        GIN_TYPE(    "String",   "Numeric", "Numeric" ),
        GIN_DEFAULT( NODEF,      NODEF,     NODEF ),
        GIN_DESC("Basename of the catalogue.",
                 "Minimum frequency for lines to read [Hz].",
                 "Maximum frequency for lines to read [Hz]." )
    ));
  
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_lines_per_speciesAddMirrorLines" ),
        DESCRIPTION
        (
         "Adds mirror lines at negative frequencies to *abs_lines_per_species*.\n"
         "\n"
         "For each line at frequency +f in *abs_lines_per_species* a corresponding\n"
         "entry at frequency -f is added to *abs_lines_per_species*. The mirror\n"
         "lines are appended to the line list after the original lines.\n" 
         ),
        AUTHORS( "Axel von Engeln", "Stefan Buehler", "Patrick Eriksson"),
        OUT( "abs_lines_per_species" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_lines_per_species" ),
        GIN( "max_f" ),
        GIN_TYPE( "Numeric" ),
        GIN_DEFAULT( "-1" ),
        GIN_DESC( "Limit for mirroring, ie. lines above this frequency do "
                  "not generate a mirror line. All lines mirrored if *max_f* "
                  "is < 0, that is the default setting.")
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_lines_per_speciesCompact" ),
        DESCRIPTION
        (
         "Removes all lines outside the defined lineshape cutoff frequencies\n"
         "from *abs_lines_per_species*. This can save computation time.\n"
         "It should be particularly useful to call this method after\n"
         "*abs_lines_per_speciesAddMirrorLines*.\n" 
         ),
        AUTHORS( "Axel von Engeln", "Stefan Buehler" ),
        OUT( "abs_lines_per_species" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_lines_per_species", "abs_lineshape", "f_grid" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_lines_per_speciesCreateFromLines" ),
        DESCRIPTION
        (
         "Split lines up into the different species.\n"
         "\n"
         "The species are tested in the order in which they are specified in the\n"
         "controlfile. Lines are assigned to the first species that\n"
         "matches. That means if the list of species is [\"O3-666\",\"O3\"], then\n"
         "the last group O3 gets assigned all the O3 lines that do not fit in\n"
         "the first group (all other isotopologues than the main isotopologue).\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT( "abs_lines_per_species" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_lines", "abs_species" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_lines_per_speciesReadFromCatalogues" ),
        DESCRIPTION
        (
         "Read spectral line data from different line catalogues.\n"
         "\n"
         "For each absorption species, you can specify which catalogue to\n"
         "use. Because the method creates *abs_lines_per_species* directly, it\n"
         "replaces for example the following two method calls:\n"
         "\n"
         "  - abs_linesReadFromHitran\n"
         "  - abs_lines_per_speciesCreateFromLines\n"
         "\n"
         "This method needs as input WSVs the list of species\n"
         "*abs_species*. Generic input parameters must specify the names of the\n"
         "catalogue files to use and the matching formats.  Names can be\n"
         "anything, formats can currently be HITRAN96 (for HITRAN 1986-2001\n"
         "databases), HITRAN04 (for HITRAN 2004 database), MYTRAN2, JPL, or\n"
         "ARTS.  Furthermore, you have to specify minimum and maximum frequency\n"
         "for each species. To safe typing, if there are less elements in the\n"
         "keyword parameters than there are species, the last parameters are\n"
         "applied to all following species.\n"
         "\n"
         "Example usage:\n"
         "\n"
         "abs_lines_per_speciesReadFromCatalogues(\n"
         "   [ \"../data/cat1.dat\", \"../data/cat2.dat\" ]\n"
         "   [ \"MYTRAN2\",          \"HITRAN96\"         ]\n"
         "   [ 0,                  0                  ]\n"
         "   [ 2000e9,             100e9              ]\n"
         ")\n"
         "\n"
         "In this example, lines for the first species will be taken from cat1,\n"
         "lines for all other species will be taken from cat2. This allows you\n"
         "for example to use a special line file just for water vapor lines.\n"
         "\n"
         "Catalogues are only read once, even if several tag groups have the\n"
         "same catalogue. However, in that case the frequency ranges MUST be the\n"
         "same. (If you want to do fine-tuning of the frequency ranges, you can\n"
         "do this inside the tag definitions, e.g., \"H2O-*-0-2000e9\".)\n"
         "\n"
         "This function uses the various reading routines\n"
         "(*abs_linesReadFromHitran*, etc.), as well as\n"
         "*abs_lines_per_speciesCreateFromLines*.\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT( "abs_lines_per_species" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_species" ),
        GIN(         "filenames",     "formats",       "fmin",   "fmax" ),
        GIN_TYPE(    "ArrayOfString", "ArrayOfString", "Vector", "Vector" ),
        GIN_DEFAULT( NODEF,           NODEF,           NODEF,    NODEF ),
        GIN_DESC( "Name (and path) of the catalogue files.",
                  "Format of each file. (Allowed formats are\n"
                  "HITRAN96, HITRAN04, MYTRAN2, JPL, ARTS.",
                  "Minimum frequency for lines to read [Hz].",
                  "Maximum frequency for lines to read [Hz]." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_lines_per_speciesSetEmpty" ),
        DESCRIPTION
        (
         "Sets abs_lines_per_species to empty line lists.\n"
         "\n"
         "You can use this method to set *abs_lines_per_species* if you do not\n"
         "really want to compute line spectra. Formally, abs_coefCalc will still\n"
         "require *abs_lines_per_species* to be set.\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT( "abs_lines_per_species" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_species" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_lines_per_speciesWriteToSplitArtscat" ),
        DESCRIPTION
        (
         "Write each species to a separate catalogue file.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT(),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "output_file_format", "abs_lines_per_species" ),
        GIN(         "basename" ),
        GIN_TYPE(    "String" ),
        GIN_DEFAULT( "" ),
        GIN_DESC(    "Basename of the catalogue." )
        ));
  
  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "abs_lookupAdapt" ),
        DESCRIPTION
        (
         "Adapts a gas absorption lookup table to the current calculation.\n"
         "\n"
         "The lookup table can contain more species and more frequencies than\n"
         "are needed for the current calculation. This method cuts down the\n"
         "table in memory, so that it contains just what is needed. Also, the\n"
         "species in the table are brought in the same order as the species in\n"
         "the current calculation.\n"
         "\n"
         "Of course, the method also performs quite a lot of checks on the\n"
         "table. If something is not ok, a runtime error is thrown.\n"
         "\n"
         "The method sets a flag *abs_lookup_is_adapted* to indicate that the\n"
         "table has been checked and that it is ok. Never set this by hand,\n"
         "always use this method to set it!\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT( "abs_lookup", "abs_lookup_is_adapted" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_lookup", "abs_species", "f_grid" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "abs_lookupCalc" ),
        DESCRIPTION
        (
         "Creates a gas absorption lookup table.\n"
         "\n"
         "The lookup table stores absorption cross-sections as a function of\n"
         "pressure. Additionally, absorption can be stored as a function of\n"
         "temperature for temperature perturbations from a reference\n"
         "profile.\n"
         "\n"
         "Additionally, absorption can be stored as a function of water vapor\n"
         "VMR perturbations from a reference profile. The variable *abs_nls*\n"
         "specifies, for which species water vapor perturbations should be\n"
         "generated.\n"
         "\n"
         "Note, that the absorbing gas can be any gas, but the perturbing gas is\n"
         "always H2O.\n"
         "\n"
         "In contrast to other absorption functions, this method does not use\n"
         "the input variable *abs_h2o*. This is because *abs_h2o* has to be set\n"
         "interally to allow perturbations. If there are more than one H2O\n"
         "species, the first is assumed to be the main one.\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT( "abs_lookup", "abs_lookup_is_adapted" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_species", 
            "abs_nls",
            "f_grid",
            "abs_p",
            "abs_vmrs",
            "abs_t", 
            "abs_t_pert", 
            "abs_nls_pert",
            "abs_xsec_agenda"
            ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "abs_lookupInit" ),
        DESCRIPTION
        (
         "Creates an empty gas absorption lookup table.\n"
         "\n"
         "This is mainly there to help developers. For example, you can write\n"
         "the empty table to an XML file, to see the file format.\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT( "abs_lookup" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "abs_lookupSetup" ),
        DESCRIPTION
        (
         "Set up input parameters for abs_lookupCalc.\n"
         "\n"
         "More information can be found in the documentation for method\n"
         "*abs_lookupSetupBatch*\n"
         "\n"
         "Max and min values of H2O and temperature are adjusted to allow for\n"
         "numerical perturbations in Jacobian calculation.\n"
         "\n"
         "The input variables *abs_nls_interp_order* and *abs_t_interp_order*\n"
         "are used to make sure that there are enough points in *abs_nls_pert*\n"
         "and *abs_t_pert* for the chosen interpolation order.\n"
         "\n"
         "Note: For homogeneous 1D cases, it can be advantageous to calculate\n"
         "*abs_lookup* from the 1D atmosphere, and to expand the atmosphere\n"
         "to 3D only after that. This particularly if nonlinear species\n"
         "(i.e., H2O) are involved."
         "\n"
         "See also:\n"
         "   *abs_lookupSetupBatch*\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT( "abs_p",
             "abs_t", 
             "abs_t_pert", 
             "abs_vmrs",
             "abs_nls",
             "abs_nls_pert" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atmosphere_dim",
            "p_grid",
//            "lat_grid",
//            "lon_grid",
            "t_field",
            "vmr_field",
            "atmfields_checked",
            "abs_species",
            "abs_p_interp_order",
            "abs_t_interp_order",
            "abs_nls_interp_order" ),
        GIN( "p_step",  "t_step",  "h2o_step" ),
        GIN_TYPE(    "Numeric", "Numeric", "Numeric" ),
        GIN_DEFAULT( "0.05",    "100",     "100" ),
        GIN_DESC( /* p_step */
                  "Maximum step in log10(p[Pa]) (base 10 logarithm)."
                  "If the pressure grid is coarser than this, additional "
                  "points are added until each log step is smaller than this.",
                  /* t_step */
                  "The temperature variation grid step in Kelvin, "
                  "for a 2D or 3D atmosphere. For a 1D atmosphere this "
                  "parameter is not used.",
                  /* h2o_step */
                  "The H2O variation grid step [fractional], if "
                  "H2O variations are done (which is determined automatically, "
                  "based on abs_species and the atmospheric dimension). For a "
                  "1D atmosphere this parameter is not used."
                  )
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "abs_lookupSetupBatch" ),
        DESCRIPTION
        (
         "Set up input parameters for abs_lookupCalc for batch calculations.\n"
         "\n"
         "This method performs a similar task as *abs_lookupSetup*, with the\n"
         "difference, that the lookup table setup is not for a single\n"
         "atmospheric state, but for a whole batch of them, stored in\n"
         "*batch_atm_fields_compact*.\n"
         "\n"
         "The method checks *abs_species* to decide, which species depend on\n"
         "*abs_h2o*, and hence require nonlinear treatment in the lookup table.\n"
         "\n"
         "The method also checks which range of pressures, temperatures, and\n"
         "VMRs occurs, and sets *abs_p*, *abs_t*, *abs_t_pert*, and *abs_vmrs*\n"
         "accordingly.\n"
         "\n"
         "If nonlinear species are present, *abs_nls* and *abs_nls_pert* are also\n"
         "generated.\n"
         "\n"
         "Max and min values of H2O and temperature are adjusted to allow for\n"
         "numerical perturbations in Jacobian calculation.\n"
         "\n"
         "The input variables *abs_nls_interp_order* and *abs_t_interp_order*\n"
         "are used to make sure that there are enough points in *abs_nls_pert*\n"
         "and *abs_t_pert* for the chosen interpolation order.\n"
         "\n"
         "See also:\n"
         "   *abs_lookupSetup*\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT( "abs_p",
             "abs_t", 
             "abs_t_pert", 
             "abs_vmrs",
             "abs_nls",
             "abs_nls_pert" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_species",
            "batch_atm_fields_compact",
            "abs_p_interp_order",
            "abs_t_interp_order",
            "abs_nls_interp_order" ),
        GIN( "p_step",  "t_step",  "h2o_step", "extremes" ),
        GIN_TYPE(    "Numeric", "Numeric", "Numeric",  "Vector" ),
        GIN_DEFAULT( "0.05",    "20",       "100",      "[]" ),
        GIN_DESC( /* p_step */ 
                  "Grid step in log10(p[Pa]) (base 10 logarithm).",
                  /* t_step */
                  "The temperature variation grid step in Kelvin. The true "
                  "step can become finer than this, if required by the "
                  "interpolation order.",
                  /* h2o_step */
                  "The H2O variation grid step [fractional], if H2O variations "
                  "are done (which is determined automatically, based on "
                  "abs_species and the atmospheric dimension). As for T, the true "
                  "step can turn out finer if required by the interpolation order.",
                  /* extremes */
                  "You can give here explicit extreme values to add to "
                  "abs_t_pert and abs_nls_pert. The order is [t_pert_min, "
                  "t_pert_max, nls_pert_min, nls_pert_max]."
                  )
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "abs_lookupSetupWide" ),
        DESCRIPTION
        (
         "Set up input parameters for abs_lookupCalc for a wide range of\n"
         "atmospheric conditions.\n"
         "\n"
         "This method can be used to set up parameters for a lookup table that\n"
         "really covers all reasonable atmospheric conditions.\n"
         "\n"
         "Reference profiles of T and H2O will be constant, so that the\n"
         "different dimensions in the lookup table are actually \"orthogonal\",\n"
         "unlike the traditional case where we have pressure dependent reference\n"
         "profiles. This makes the table numerically somewhat more robust then\n"
         "the traditional ones, and it makes it straightforward to calculate the\n"
         "accuracy for the different interpolations with abs_lookupTestAccuracy.\n"
         "\n"
         "You can give min an max values for the atmospheric conditions. The\n"
         "default values are chosen such that they cover all Chevallier data set\n"
         "cases, and a bit more. The statistics of the Chevallier data are:\n"
         "\n"
         "min(p)   / max(p)   [Pa]:  1 / 104960\n"
         "min(T)   / max(T)   [K]:   158.21 / 320.39\n"
         "min(H2O) / max(H2O) [VMR]: -5.52e-07 / 0.049\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT( "abs_p",
             "abs_t", 
             "abs_t_pert", 
             "abs_vmrs",
             "abs_nls",
             "abs_nls_pert" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_species",
            "abs_p_interp_order",
            "abs_t_interp_order",
            "abs_nls_interp_order" ),
        GIN( "p_min",   "p_max",   "p_step",  "t_min",   "t_max",   "h2o_min", "h2o_max" ),
        GIN_TYPE(    "Numeric", "Numeric", "Numeric", "Numeric", "Numeric", "Numeric", "Numeric" ),
        GIN_DEFAULT( "0.5",  "110000",  "0.05",    "100",     "400",     "0",       "0.05" ),
        GIN_DESC( "Pressure grid minimum [Pa].",
                  "Pressure grid maximum [Pa].",
                  "Pressure grid step in log10(p[Pa]) (base 10 logarithm).",
                  "Temperature grid minimum [K].",
                  "Temperature grid maximum [K].",
                  "Humidity grid minimum [fractional].",
                  "Humidity grid maximum [fractional]." )
        ));
  
  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "abs_lookupTestAccuracy" ),
        DESCRIPTION
        (
         "Test accuracy of absorption lookup table.\n"
         "\n"
         "Explicitly compare absorption from the lookup table with line-by-line\n"
         "calculations for strategically selected conditions (in-between the\n"
         "lookup table grid points).\n"
         "\n"
         "For error units see *abs_lookupTestAccMC*\n"
         "\n"
         "Produces no workspace output, only output to the output streams.\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT(),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_lookup",
            "abs_lookup_is_adapted",
            "abs_p_interp_order",
            "abs_t_interp_order",
            "abs_nls_interp_order",
            "abs_xsec_agenda" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "abs_lookupTestAccMC" ),
        DESCRIPTION
        (
         "Test accuracy of absorption lookup table with Monte Carlo Algorithm.\n"
         "\n"
         "Explicitly compare absorption from the lookup table with line-by-line\n"
         "calculations for random conditions.\n"
         "\n"
         "The quantities returned are the mean value and standard deviation of\n"
         "the absolute value of the relative error in percent.\n"
         "The relative error itself is computed for a large number of cases\n"
         "(pressure, temperature, and H2O VMR combinations). In the frequency\n"
         "dimension the maximum value is taken for each case.\n"
         "\n"
         "Produces no workspace output, only output to the output streams.\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT(),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_lookup",
            "abs_lookup_is_adapted",
            "abs_p_interp_order",
            "abs_t_interp_order",
            "abs_nls_interp_order",
            "mc_seed",
            "abs_xsec_agenda" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));
    
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_xsec_agenda_checkedCalc" ),
        DESCRIPTION
        (
         "Checks if the *abs_xsec_agenda* contains all necessary\n"
         "methods to calculate all the species in *abs_species*.\n"
         "\n"
         "This method should be called just before the *abs_xsec_agenda*\n"
         "is used, e.g. *abs_lookupCalc*, *ybatchCalc*, *yCalc*\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( "abs_xsec_agenda_checked" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_species", "abs_xsec_agenda" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_speciesAdd" ),
        DESCRIPTION
        (
         "Adds species tag groups to the list of absorption species.\n"
         "\n"
         "This WSM is similar to *abs_speciesSet*, the only difference is that\n"
         "this method appends species to an existing list of absorption species instead\n"
         "of creating the whole list.\n"
         "\n"
         "See *abs_speciesSet* for details on how tags are defined and examples of\n"
         "how to input them in the control file.\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT( "abs_species", "propmat_clearsky_agenda_checked", "abs_xsec_agenda_checked" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_species" ),
        GIN( "species" ),
        GIN_TYPE(    "ArrayOfString"   ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "Specify one String for each tag group that you want to\n"
                  "add. Inside the String, separate the tags by commas\n"
                  "(plus optional blanks).\n")
        ));
 
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_speciesAdd2" ),
        DESCRIPTION
        (
         "Adds a species tag group to the list of absorption species and\n"
         "jacobian quantities.\n"
         "\n"
         "The method is basically a combined call of *abs_speciesAdd* and\n"
         "*jacobianAddAbsSpecies*. In this way it is not needed to specify a\n"
         "tag group in two different places.\n"
         "\n"
         "Arguments exactly as for *jacobianAddAbsSpecies*. Note that this\n"
         "method only handles a single tag group, in contrast to\n"
         "*abs_speciesAdd*\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "abs_species", "jacobian_quantities", "jacobian_agenda",
             "propmat_clearsky_agenda_checked", "abs_xsec_agenda_checked" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_species", "atmosphere_dim", "p_grid", "lat_grid", 
            "lon_grid" ),
        GIN( "gin1"      , "gin2"      , "gin3"      ,
             "species", "method", "unit", "dx" ),
        GIN_TYPE(    "Vector", "Vector", "Vector",
                     "String", "String", "String", "Numeric" ),
        GIN_DEFAULT( NODEF   , NODEF   , NODEF   ,
                     NODEF,     NODEF,    NODEF,  NODEF ),
        GIN_DESC( "Pressure retrieval grid.",
                  "Latitude retrieval grid.",
                  "Longitude retreival grid.",
                  "The species tag of the retrieval quantity.",
                  "Calculation method. See above.",
                  "Retrieval unit. See above.",
                  "Size of perturbation."
                  ),
        SETMETHOD(      false ),
        AGENDAMETHOD(   false  ),
        USES_TEMPLATES( false ),
        PASSWORKSPACE(  true )
        ));
 
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_speciesDefineAllInScenario" ),
        DESCRIPTION
        (
         "Define one tag group for each species known to ARTS and included in an\n"
         "atmospheric scenario.\n"
         "\n"
         "You can use this as an alternative to *abs_speciesSet* if you want to make an\n"
         "absorption calculation that is as complete as possible. The method\n"
         "goes through all defined species and tries to open the VMR file. If\n"
         "this works the tag is included, otherwise it is skipped.\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT( "abs_species", "propmat_clearsky_agenda_checked", "abs_xsec_agenda_checked" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN( "basename" ),
        GIN_TYPE( "String" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "The name and path of a particular atmospheric scenario.\n"
                  "For example: /pool/lookup2/arts-data/atmosphere/fascod/tropical" )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_speciesInit" ),
        DESCRIPTION
        (
         "Sets  *abs_species* to be empty.\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT( "abs_species" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_speciesSet" ),
        DESCRIPTION
        (
         "Set up a list of absorption species tag groups.\n"
         "\n"
         "Workspace variables like *abs_species* contain several tag\n"
         "groups. Each tag group contains one or more tags. This method converts\n"
         "descriptions of tag groups given in the keyword to the ARTS internal\n"
         "representation (an *ArrayOfArrayOfSpeciesTag*). A tag group selects\n"
         "spectral features which belong to the same species.\n"
         "\n"
         "A tag is defined in terms of the name of the species, isotopologue, and a\n"
         "range of frequencies. Species are named after the standard chemical\n"
         "names, e.g., \"O3\". Isotopologues are given by the last digit of the atomic\n"
         "weight, i.g., \"O3-668\" for the asymmetric ozone molecule including an\n"
         "oxygen 18 atom. Groups of transitions are specified by giving a lower\n"
         "and upper limit of a frequency range, e.g., \"O3-666-500e9-501e9\".\n"
         "\n"
         "To turn on Zeeman calculation for a Species, \"-Z\" may be appended\n"
         "to its name: \"O2-Z\" or \"O2-Z-66\"\n"
         "\n"
         "To turn on line mixing for a Species, \"-LM_METHOD\" may be appended\n"
         "to its name. Currently only one METHOD is supported: 2NDORDER.\n"
         "Line mixing data has to be provided if this is turned on.\n"
         "See *line_mixing_dataInit* and *line_mixing_dataRead*\n."
         "Example: \"O2-66-LM_2NDORDER\".\n"
         "\n"
         "The symbol \"*\" acts as a wild card. Furthermore, frequency range or\n"
         "frequency range and isotopologue may be omitted.\n"
         "\n"
         "Finally, instead of the isotopologue the special letter \"nl\" may be given,\n"
         "e.g., \"H2O-nl\". This means that no absorption at all is associated\n"
         "with this tag. (It is not quite clear if this feature is useful for\n"
         "anything right now.)\n"
         "\n"
         "Example:\n"
         "\n"
         "   species = [ \"O3-666-500e9-501e9, O3-686\",\n"
         "               \"O3\",\n"
         "               \"H2O-PWR98\" ]\n"
         "\n"
         "   The first tag group selects all O3-666 lines between 500 and\n"
         "   501 GHz plus all O3-686 lines. \n"
         "\n"
         "   The second tag group selects all remaining O3 transitions.\n"
         "\n"
         "   The third tag group selects H2O, with one of the complete\n"
         "   absorption models (Rosenkranz 98). No spectrocopic line catalogue\n"
         "   data will be used for that third tag group.\n"
         "\n"
         "   Note that order of tag groups in the species list matters. In our\n"
         "   example, changing the order of the first two tag group will give\n"
         "   different results: as \"O3\" already selects all O3 transitions,\n"
         "   no lines will remain to be selected by the\n"
         "   \"O3-666-500e9-501e9, O3-686\" tag.\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT( "abs_species", "abs_xsec_agenda_checked", "propmat_clearsky_agenda_checked" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN( "species" ),
        GIN_TYPE(    "ArrayOfString"   ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC("Specify one String for each tag group that you want to\n"
                 "create. Inside the String, separate the tags by commas\n"
                 "(plus optional blanks).\n")
        ));


  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_vecAddGas" ),
        DESCRIPTION
        (
         "Add gas absorption to first element of absorption vector.\n"
         "\n"
         "The task of this method is to sum up the gas absorption of the\n"
         "different gas species and add the result to the first element of the\n"
         "absorption vector.\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT( "abs_vec" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_vec", "propmat_clearsky" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_vecAddPart" ),
        DESCRIPTION
        (
         "The particle absorption is added to *abs_vec*\n"
         "\n"
         "This function sums up the absorption vectors for all particle\n"
         "types weighted with particle number density.\n"
         "The resluling absorption vector is added to the workspace\n"
         "variable *abs_vec*\n"
         "Output and input of this method is *abs_vec* (stokes_dim).\n"
         "The inputs are the absorption vector for the single particle type\n"
         "*abs_vec_spt* (N_particletypes, stokes_dim) and the local particle\n"
         " number densities for all particle types namely the\n"
         "*pnd_field* (N_particletypes, p_grid, lat_grid, lon_grid, ) for given\n"
         "*p_grid*, *lat_grid*, and *lon_grid*. The particle types required\n"
         "are specified in the control file.\n"
         ),
        AUTHORS( "Sreerekha T.R." ),
        OUT( "abs_vec" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_vec", "abs_vec_spt", "pnd_field", "atmosphere_dim",
            "scat_p_index",  "scat_lat_index", "scat_lon_index" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_vecInit" ),
        DESCRIPTION
        (
         "Initialize absorption vector.\n"
         "\n"
         "This method is necessary, because all other absorption methods just\n"
         "add to the existing absorption vector.\n"
         "\n"
         "So, here we have to make it the right size and fill it with 0.\n"
         "\n"
         "Note, that the vector is not really a vector, because it has a\n"
         "leading frequency dimension.\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT( "abs_vec" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "f_grid", "stokes_dim", "f_index" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
     ( NAME( "abs_xsec_per_speciesAddCIA" ),
      DESCRIPTION
      (
       "Calculate absorption cross sections per tag group for HITRAN CIA continua.\n"
       "\n"
       "This interpolates the cross sections from *abs_cia_data*.\n"
       "\n"
       "The robust option is intended only for testing. Do not use for normal\n"
       "runs, since subsequent functions will not be able to deal with NAN values.\n"
       ),
      AUTHORS( "Stefan Buehler" ),
      OUT( "abs_xsec_per_species" ),
      GOUT(),
      GOUT_TYPE(),
      GOUT_DESC(),
      IN( "abs_xsec_per_species", "abs_species", "abs_species_active",
          "f_grid", "abs_p", "abs_t",
          "abs_vmrs", "abs_cia_data" ),
      GIN(         "T_extrapolfac", "robust" ),
      GIN_TYPE(    "Numeric",       "Index"),
      GIN_DEFAULT( "0.5",           "0" ),
      GIN_DESC( "Temperature extrapolation factor (relative to grid spacing).",
                "Set to 1 to suppress runtime errors (and return NAN values instead).")
      ));
    
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_xsec_per_speciesAddConts" ),
        DESCRIPTION
        (
         "Calculate absorption cross sections per tag group for continua.\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT( "abs_xsec_per_species" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_xsec_per_species", "abs_species", "abs_species_active",
            "f_grid", "abs_p", "abs_t",
            "abs_vmrs", "abs_cont_names", "abs_cont_parameters",
            "abs_cont_models" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_xsec_per_speciesAddLines" ),
        DESCRIPTION
        (
         "Calculates the line spectrum for both attenuation and phase\n"
         "for each tag group and adds it to abs_xsec_per_species.\n"
         ),
        AUTHORS( "Stefan Buehler", "Axel von Engeln" ),
        OUT( "abs_xsec_per_species"),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_xsec_per_species", "abs_species", "abs_species_active",
            "f_grid", "abs_p", "abs_t",
            "abs_vmrs", "abs_lines_per_species", "abs_lineshape",
            "isotopologue_ratios", "line_mixing_data", "line_mixing_data_lut" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_xsec_per_speciesInit" ),
        DESCRIPTION
        (
         "Initialize *abs_xsec_per_species*.\n"
         "\n"
         "The initialization is\n"
         "necessary, because methods *abs_xsec_per_speciesAddLines*\n"
         "and *abs_xsec_per_speciesAddConts* just add to *abs_xsec_per_species*.\n"
         "The size is determined from *abs_species*.\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT( "abs_xsec_per_species" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_species", "abs_species_active", "f_grid", "abs_p",
            "abs_xsec_agenda_checked" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "AgendaAppend" ),
        DESCRIPTION
        ( 
         "Append methods to an agenda.\n"
         "\n"
         "An agenda is used to store a list of methods that are meant to be\n"
         "executed sequentially.\n"
         "\n"
         "This method takes the methods given in the body (in the curly braces)\n"
         "and appends them to the agenda given by the output argument (in the round\n"
         "braces).\n"
         "\n"
         "It also uses the agenda lookup data (defined in file agendas.cc) to\n"
         "check, whether the given methods use the right input WSVs and produce\n"
         "the right output WSVs.\n"
          ),
        AUTHORS( "Oliver Lemke" ),
        OUT(),
        GOUT(        "out" ),
        GOUT_TYPE(   "Agenda" ),
        GOUT_DESC(   "Target agenda." ),
        IN(),
        GIN(         "in" ),
        GIN_TYPE(    "Agenda" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC(    "Source agenda." ),
        SETMETHOD(      false ),
        AGENDAMETHOD(   true  ),
        USES_TEMPLATES( false ),
        PASSWORKSPACE(  false ),
        PASSWSVNAMES(   true  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "AgendaExecute" ),
        DESCRIPTION
        ( 
         "Execute an agenda.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT(),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(         "a" ),
        GIN_TYPE(    "Agenda" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC(    "Agenda to be executed." ),
        SETMETHOD(    false ),
        AGENDAMETHOD( false )
        ));
      
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "AgendaExecuteExclusive" ),
        DESCRIPTION
        ( 
         "Execute an agenda exclusively.\n"
         "\n"
         "Only one call to *AgendaExecuteExclusive* is executed at a time.\n"
         "Other calls to this function are blocked until the current one\n"
         "finishes. WARNING: Can cause deadlocks! Use with care.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT(),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(         "a" ),
        GIN_TYPE(    "Agenda" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC(    "Agenda to be executed." ),
        SETMETHOD(    false ),
        AGENDAMETHOD( false )
        ));
      
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "AgendaSet" ),
        DESCRIPTION
        ( 
         "Set up an agenda.\n"
         "\n"
         "An agenda is used to store a list of methods that are meant to be\n"
         "executed sequentially.\n"
         "\n"
         "This method takes the methods given in the body (in the curly braces)\n"
         "and puts them in the agenda given by the output argument (in the round\n"
         "braces).\n"
         "\n"
         "It also uses the agenda lookup data (defined in file agendas.cc) to\n"
         "check, whether the given methods use the right input WSVs and\n"
         "produce the right output WSVs.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT(),
        GOUT(      "out"       ),
        GOUT_TYPE( "Agenda" ),
        GOUT_DESC( "The new agenda." ),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC(),
        SETMETHOD(      false ),
        AGENDAMETHOD(   true  ),
        USES_TEMPLATES( false ),
        PASSWORKSPACE(  false ),
        PASSWSVNAMES(   true  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "AntennaConstantGaussian1D" ),
        DESCRIPTION
        (
         "Sets up a 1D gaussian antenna response and a matching\n"
         "*mblock_za_grid*.\n"
         "\n"
         "As *antenna_responseGaussian*, but alsp creates *mblock_za_grid*.\n"
         "For returned antenna response, see *antenna_responseGaussian*.\n"
         "\n"
         "The length of *mblock_za_grid* is determined by *n_za_grid*.\n"
         "The end points of the grid are set to be the same as for the\n"
         "antenna response. The spacing of the grid follows the magnitude of\n"
         "the response; the spacing is smaller where the response is high.\n"
         "More precisely, the grid points are determined by dividing\n"
         "the cumulative sum of the response in equal steps. This makes sense\n"
         "if the representation error of the radiance (as a function of\n"
         "zenith angle) increases linearly with the grid spacing.\n"
         "\n"
         "The WSV *antenna_los* is set to 0.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "antenna_dim", "mblock_za_grid", "mblock_aa_grid", 
             "antenna_response", "antenna_los" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(  ),
        GIN( "n_za_grid", "fwhm", "xwidth_si", "dx_si" ),
        GIN_TYPE( "Index", "Numeric", "Numeric", "Numeric" ),
        GIN_DEFAULT( NODEF, NODEF, "3", "0.1" ),
        GIN_DESC( "Number of points to include in *mblock_za_grid*.",
                  "Full width at half-maximum of antenna beam [deg].", 
                  "Half-width of response, in terms of std. dev.", 
                  "Grid spacing, in terms of std. dev." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "AntennaMultiBeamsToPencilBeams" ),
        DESCRIPTION
        (
         "Maps a multi-beam case to a matching pencil beam case.\n"
         "\n"
         "Cases with overlapping beams are most efficiently handled by\n"
         "letting *antenna_los* have several rows. That is, there are\n"
         "multiple beams for each measurement block. The drawback is that\n"
         "many variables must be adjusted if the corresponding pencil beam\n"
         "spectra shall be calculated. This method makes this adjustment.\n"
         "That is, if you have a control file for a multiple beam case and\n"
         "for some reason want to avoid the antenna weighting, you add this\n"
         "method before *sensor_responseInit*, and remove the call of\n"
         "*sensor_responseAntenna* and you will get the matching pencil beam\n"
         "spectra.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "sensor_pos", "sensor_los", "antenna_los", "antenna_dim", 
             "mblock_za_grid", "mblock_aa_grid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "sensor_pos", "sensor_los", "antenna_los", "antenna_dim", 
            "mblock_za_grid", "mblock_aa_grid", "atmosphere_dim" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "AntennaOff" ),
        DESCRIPTION
        (
         "Sets some antenna related variables\n"
         "\n"
         "Use this method to set *antenna_dim*, *mblock_za_grid* and\n"
         "*mblock_aa_grid* to suitable values (1, [0] and [], respectively)\n"
         "for cases when a sensor is included, but the antenna pattern is\n"
         "neglected.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "antenna_dim", "mblock_za_grid", "mblock_aa_grid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "AntennaSet1D" ),
        DESCRIPTION
        (
         "Sets the antenna dimension to 1D.\n"
         "\n"
         "Sets *antenna_dim* to 1 and sets *mblock_aa_grid* to be empty.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "antenna_dim", "mblock_aa_grid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "AntennaSet2D" ),
        DESCRIPTION
        (
         "Sets the antenna dimension to 2D.\n"
         "\n"
         "Sets *antenna_dim* to 2.\n"
         "\n"
         "It is only allowed to set *antenna_dim* to 2 when *atmosphere_dim*\n"
         "equals 3.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "antenna_dim" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atmosphere_dim" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "antenna_responseGaussian" ),
        DESCRIPTION
        (
         "Sets up a gaussian antenna response.\n"
         "\n"
         "The method assumes that the response is the same for all\n"
         "frequencies and polarisations, and that it can be modelled as\n"
         "gaussian.\n"
         "\n"
         "The grid generated is approximately\n"
         "   si * [-xwidth_si:dx_si:xwidth_si]\n"
         "where si is the standard deviation corresponding to the FWHM.\n"
         "That is, width and spacing of the grid is specified in terms of\n"
         "number of standard deviations. If xwidth_si is set to 2, the\n"
         "response will cover about 95% the complete response. For\n"
         "xwidth_si=3, about 99% is covered. If xwidth_si/dx_si is not\n"
         "an integer, the end points of the grid are kept and the spacing\n"
         "of the grid is reduced (ie. spacing is equal or smaller *dx_si*).\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "antenna_response" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( ),
        GIN( "fwhm", "xwidth_si", "dx_si" ),
        GIN_TYPE( "Numeric", "Numeric", "Numeric" ),
        GIN_DEFAULT( NODEF, "3", "0.1" ),
        GIN_DESC( "Full width at half-maximum", 
                  "Half-width of response, in terms of std. dev.", 
                  "Grid spacing, in terms of std. dev." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "antenna_responseVaryingGaussian" ),
        DESCRIPTION
        (
         "Sets up gaussian antenna responses.\n"
         "\n"
         "Similar to *antenna_responseGaussian* but allows to set up\n"
         "responses that varies with frequency. That is, the method assumes\n"
         "that the response is the same for all polarisations, and that it\n"
         "can be modelled as a gaussian function varying with frequency.\n"
         "\n"
         "The full width at half maximum (FWHM in radians) is calculated as:\n"
         "    fwhm = lambda / leff\n"
         "where lambda is the wavelength and *leff* is the effective size of\n"
         "the antenna. Normally, *leff* is smaller than the physical antenna\n"
         "size.\n"
         "\n"
         "Antenna responses are created for *nf* frequencies spanning the\n"
         "range [*fstart*,*fstop*], with a logarithmic spacing. That is, the\n"
         "frequency grid of the responses is taken from *VectorNLogSpace*.\n"
         "\n"
         "The responses have a common angular grid. The width, determined by\n"
         "*xwidth_si*, is set for the lowest frequency, while the spacing\n"
         "(*dx_si*) is set for the highest frequency. This ensures that both\n"
         "the width and spacing are equal or better than *xwidth_si* and\n"
         "*dx_si*, respectively, for all frequencies.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "antenna_response" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( ),
        GIN( "leff", "xwidth_si", "dx_si", "nf", "fstart", "fstop" ),
        GIN_TYPE( "Numeric", "Numeric", "Numeric", "Index", "Numeric", 
                  "Numeric" ),
        GIN_DEFAULT( NODEF, "3", "0.1", NODEF, NODEF, NODEF ),
        GIN_DESC( "Effective size of the antenna", 
                  "Half-width of response, in terms of std. dev.", 
                  "Grid spacing, in terms of std. dev.",
                  "Number of points in frequency grid (must be >= 2)",
                  "Start point of frequency grid",
                  "End point of frequency grid" )
        ));
 
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Append" ),
        DESCRIPTION
        (
         "Append one workspace variable to another.\n"
         "\n"
         "This method can append an array to another array of the same type,\n"
         "e.g. ArrayOfIndex to ArrayOfIndex. Or a single element to an array\n"
         "such as a Tensor3 to an ArrayOfTensor3.\n"
         "\n"
         "Appending two vectors or a numeric to a vector works as for array\n"
         "variables.\n"
         "\n"
         "Both another matrix or a vector can be appended to a matrix. In\n"
         "addition, for matrices, the 'append dimension' can be selected.\n" 
         "The third argument, *dimension*, indicates how to append, where\n"
         "\"leading\" means to append row-wise, and \"trailing\" means\n"
         "column-wise. Other types are currently only implemented for\n"
         "appending to the leading dimension.\n"
         "\n"
         "This method is not implemented for all types, just for those that\n"
         "were thought to be useful. (See variable list below.).\n"
         ),
        AUTHORS( "Stefan Buehler, Oliver Lemke" ),
        OUT(),
        GOUT( "out" ),
        GOUT_TYPE( "Vector, Vector, Matrix, Matrix, Tensor4, String, " +
                   ARRAY_GROUPS + ", " + ARRAY_GROUPS_WITH_BASETYPE ),
        GOUT_DESC( "The variable to append to." ),
        IN(),
        GIN( "in",
             "dimension" ),
        GIN_TYPE( "Numeric, Vector, Matrix, Vector, Tensor4, String, " +
                  ARRAY_GROUPS + "," + GROUPS_WITH_ARRAY_TYPE,
                  "String" ),
        GIN_DEFAULT( NODEF,
                     "leading" ),
        GIN_DESC( "The variable to append.",
                  "Where to append. Could be either the \"leading\" or \"trailing\" dimension." ),
        SETMETHOD(      false ),
        AGENDAMETHOD(   false ),
        USES_TEMPLATES( true  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "ArrayOfIndexLinSpace" ),
        DESCRIPTION
        (
         "Initializes an ArrayOfIndex with linear spacing.\n"
         "\n"
         "The first element equals always the start value, and the spacing\n"
         "equals always the step value, but the last value can deviate from\n"
         "the stop value. *step* can be both positive and negative.\n"
         "\n"
         "The created array is [start, start+step, start+2*step, ...]\n "
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT(),
        GOUT(      "out"      ),
        GOUT_TYPE( "ArrayOfIndex" ),
        GOUT_DESC( "Output array." ),
        IN(),
        GIN(         "start",   "stop",    "step"    ),
        GIN_TYPE(    "Index",   "Index",   "Index" ),
        GIN_DEFAULT( NODEF,     NODEF,     NODEF     ),
        GIN_DESC( "Start value.",
                  "Maximum/minimum value of the end value",
                  "Spacing of the array."
                  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "ArrayOfIndexSet" ),
        DESCRIPTION
        (
         "Creates an ArrayOfIndex from the given list of numbers.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT(),
        GOUT(      "out"       ),
        GOUT_TYPE( "ArrayOfIndex" ),
        GOUT_DESC( "Variable to initialize." ),
        IN(),
        GIN(         "value" ),
        GIN_TYPE(    "ArrayOfIndex" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "Indexes for initializiation." ),
        SETMETHOD( true )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "ArrayOfIndexSetConstant" ),
        DESCRIPTION
        (
         "Creates an ArrayOfIndex of length *nelem*, with all values\n"
         "identical.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT(      "out"       ),
        GOUT_TYPE( "ArrayOfIndex" ),
        GOUT_DESC( "Variable to initialize." ),
        IN( "nelem" ),
        GIN(         "value" ),
        GIN_TYPE(    "Index" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "Array value.." ),
        SETMETHOD( true )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "ArrayOfLineMixingRecordReadAscii" ),
        DESCRIPTION
        (
         "Read line mixing data from an ASCII file.\n"
         "\n"
         "This is merely a convenience function to convert data from Richard's\n"
         "ASCII format into XML. For example:\n"
         "  ArrayOfLineMixingRecordCreate(lm_convert)\n"
         "  ArrayOfLineMixingRecordReadAscii(lm_convert, \"o2_v1_0_band_40-120_GHz\")\n"
         "  WriteXML(\"zascii\", lm_convert, \"o2_v1_0_band_40-120_GHz.xml\")\n"
         "\n"
         "After reading the data it must be matched to *abs_lines_per_species*.\n"
         "See *line_mixing_dataMatch*.\n"
         "\n"
         "Format Documentation:\n"
         "Quantum numbers: v1, Upper N, Lower N, Upper J, Lower J,\n"
         "First Order Zeroth Phase Correction,\n"
         "First Order First Phase Correction,\n"
         "Second Order Zeroth Absorption Correction,\n"
         "Second Order First Absorption Correction,\n"
         "Second Order Zeroth Line-Center Correction,\n"
         "Second Order First Line-Center Correction,\n"
         "Standard Temperature For Corrections,\n"
         "First Order Phase Temperature Correction Exponential Term,\n"
         "Second Order Absorption Temperature Correction Exponential Term, and \n"
         "Second Order Line-Center Temperature Correction Exponential Term.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT(),
        GOUT( "line_mixing_records" ),
        GOUT_TYPE( "ArrayOfLineMixingRecord"),
        GOUT_DESC( "Unmatched line mixing data." ),
        IN(),
        GIN(         "filename" ),
        GIN_TYPE(    "String" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC(    "Line mixing data file.")
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "ArrayOfStringSet" ),
        DESCRIPTION
        (
         "Sets a String array according the given text.\n"
         "The format is text = [\"String1\",\"String2\",...]\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT(),
        GOUT(      "out" ),
        GOUT_TYPE( "ArrayOfString" ),
        GOUT_DESC( "Variable to initialize." ),
        IN(),
        GIN( "value" ),
        GIN_TYPE(    "ArrayOfString" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "Strings for initialization." ),
        SETMETHOD( true )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Arts" ),
        DESCRIPTION
        ( 
         "Runs the agenda that is specified inside the curly braces. ARTS\n"
         "controlfiles must define this method. It is executed automatically\n"
         "when ARTS is run on the controlfile and cannot be called by the user.\n"
         "This methods was used for Arts 1 controlfiles and is now obsolete.\n"
         "See *Arts2*\n"
          ),
        AUTHORS( "Stefan Buehler" ),
        OUT(),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC(),
        SETMETHOD(    false ),
        AGENDAMETHOD( true  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Arts2" ),
        DESCRIPTION
        ( 
         "Runs the agenda that is specified inside the curly braces. ARTS\n"
         "controlfiles must define this method. It is executed automatically\n"
         "when ARTS is run on the controlfile and cannot be called by the user.\n"
          ),
        AUTHORS( "Oliver Lemke" ),
        OUT(),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC(),
        SETMETHOD(    false ),
        AGENDAMETHOD( true  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "AtmFieldsCalc" ),
        DESCRIPTION
        (
         "Interpolation of raw atmospheric T, z, and VMR fields to calculation grids.\n"
         "\n"
         "An atmospheric scenario includes the following data for each\n"
         "position (pressure, latitude, longitude) in the atmosphere:\n"
         "   1. temperature field\n"
         "   2. the corresponding altitude field\n"
         "   3. vmr fields for the gaseous species\n"
         "This method interpolates the fields of raw data (*t_field_raw*,\n"
         "*z_field_raw*, *vmr_field_raw*) which can be stored on arbitrary\n"
         "grids to the calculation grids (*p_grid*, *lat_grid*, *lon_grid*).\n"
         "\n"
         "Internally, *AtmFieldsCalc* applies *GriddedFieldPRegrid* and\n"
         "*GriddedFieldLatLonRegrid*. Generally, 'half-grid-step' extrapolation\n"
         "is allowed and applied. However, if *vmr_zeropadding*=1 then VMRs at\n"
         "*p_grid* levels exceeding the raw VMRs' pressure grid are set to 0\n"
         "(applying the *zeropadding* option of *GriddedFieldPRegrid*).\n"
         "\n"
         "Default is to just accept obtained VMRs. If you want to enforce\n"
         "that all VMR created are >= 0, set *vmr_nonegative* to 1. Negative\n"
         "values are then set 0. Beside being present in input data, negative\n"
         "VMR can be generated from the interpolation if *interp_order* is\n"
         "above 1.\n"
         ),
        AUTHORS( "Claudia Emde", "Stefan Buehler" ),
        OUT( "t_field", "z_field", "vmr_field" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "p_grid", "lat_grid", "lon_grid", "t_field_raw", "z_field_raw", 
            "vmr_field_raw", "atmosphere_dim" ),
        GIN( "interp_order", "vmr_zeropadding", "vmr_nonegative" ),
        GIN_TYPE( "Index", "Index", "Index" ),
        GIN_DEFAULT( "1", "0", "0" ),
        GIN_DESC( "Interpolation order (1=linear interpolation).",
                "Pad VMRs with zeroes to fit the pressure grid if necessary.", 
                "If set to 1, negative VMRs are set to 0." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "AtmFieldsCalcExpand1D" ),
        DESCRIPTION
        (
         "Interpolation of 1D raw atmospheric fields to create 2D or 3D\n"
         "homogeneous atmospheric fields.\n"
         "\n"
         "The method works as *AtmFieldsCalc*, but accepts only raw 1D\n"
         "atmospheres. The raw atmosphere is interpolated to *p_grid* and\n"
         "the obtained values are applied for all latitudes, and also\n"
         "longitudes for 3D, to create a homogeneous atmosphere.\n"
         "\n"
         "The method deals only with the atmospheric fields, and to create\n"
         "a true 2D or 3D version of a 1D case, a demand is also that the\n"
         "ellipsoid is set to be a sphere.\n"
         ),
        AUTHORS( "Patrick Eriksson", "Claudia Emde", "Stefan Buehler" ),
        OUT( "t_field", "z_field", "vmr_field" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "p_grid", "lat_grid", "lon_grid", "t_field_raw", "z_field_raw", 
            "vmr_field_raw", "atmosphere_dim" ),
        GIN( "interp_order", "vmr_zeropadding", "vmr_nonegative" ),
        GIN_TYPE( "Index", "Index", "Index" ),
        GIN_DEFAULT( "1", "0", "0" ),
        GIN_DESC( "Interpolation order (1=linear interpolation).",
                "Pad VMRs with zeroes to fit the pressure grid if necessary.", 
                "If set to 1, negative VMRs are set to 0." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "AtmFieldsExpand1D" ),
        DESCRIPTION
        (
         "Maps a 1D case to 2D or 3D homogeneous atmospheric fields.\n"
         "\n"
         "This method takes a 1D atmospheric case and converts it to the\n"
         "corresponding case for 2D or 3D. The atmospheric fields (t_field,\n"
         "z_field and vmr_field) must be 1D and match *p_grid*. The size of\n"
         "the new data is determined by *atmosphere_dim*, *lat_grid* and\n"
         "*lon_grid*. That is, these later variables have been changed since\n"
         "the original fields were created.\n"
         "\n"
         "The method deals only with the atmospheric fields, and to create\n"
         "a true 2D or 3D version of a 1D case, a demand is also that the\n"
         "ellipsoid is set to be a sphere.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "t_field", "z_field", "vmr_field" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "t_field", "z_field", "vmr_field", "p_grid", "lat_grid", 
            "lon_grid", "atmosphere_dim" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "AtmFieldsRefinePgrid" ),
        DESCRIPTION
        (
         "Refine the pressure grid in the atmospheric fields.\n"
         "\n"
         "This method is used for absorption lookup table testing. It probably\n"
         "has no other application.\n"
         "\n"
         "It adds additional vertical grid points to the atmospheric fields, by\n"
         "interpolating them in the usual ARTS way (linear in log pressure).\n"
         "\n"
         "How fine the new grid will be is determined by the keyword parameter\n"
         "p_step. The definition of p_step, and the interpolation behavior, is\n"
         "consistent with *abs_lookupSetup* and *abs_lookupSetupBatch*. (New\n"
         "points are added between the original ones, so that the spacing is\n"
         "always below p_step.)\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT( "p_grid",
             "t_field", "z_field", "vmr_field" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "p_grid", "lat_grid", "lon_grid",
            "t_field", "z_field", "vmr_field", "atmosphere_dim" ),
        GIN( "p_step" ),
        GIN_TYPE(    "Numeric" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC("Maximum step in log(p[Pa]) (natural logarithm, as always). If\n"
                 "the pressure grid is coarser than this, additional points\n"
                 "are added until each log step is smaller than this.\n")
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "atmfields_checkedCalc" ),
        DESCRIPTION
        (
         "Checks consistency of (clear sky) atmospheric fields.\n"
         "\n"
         "The following WSVs are treated: *p_grid*, *lat_grid*, *lon_grid*,\n"
         "*t_field*, *vmr_field*, wind_u/v/w_field and mag_u/v/w_field.\n"
         "\n"
         "If any of the variables above is changed, then this method shall be\n"
         "called again (no automatic check that this is fulfilled!).\n"
         "\n"
         "The tests include that:\n"
         " 1. Atmospheric grids (p/lat/lon_grid) are OK with respect to\n"
         "    *atmosphere_dim* (and vmr_field also regarding *abs_species*).\n"
         " 2. Atmospheric fields have sizes consistent with the atmospheric\n"
         "    grids.\n"
         " 3. *abs_f_interp_order* is not zero if any wind is nonzero.\n"
         " 4. All values in *t_field* are > 0.\n"
         "\n"
         "Default is that values in *vmr_field* are demanded to be >= 0\n"
         "(ie. zero allowed, in contrast to *t_field*), but this\n"
         "requirement can be removed by the *negative_vmr_ok* argument.\n"
         "\n"
         "If any test fails, there is an error. Otherwise,\n"
         "*atmfields_checked* is set to 1.\n"
         "\n"
         "The cloudbox is covered by *cloudbox_checked*, *z_field* is\n"
         "part of the checks done around *atmgeom_checked*.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "atmfields_checked" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atmosphere_dim", "p_grid", "lat_grid", "lon_grid", "abs_species",
            "t_field", "vmr_field", "wind_u_field", "wind_v_field",
            "wind_w_field", "mag_u_field", "mag_v_field", "mag_w_field",
            "abs_f_interp_order" ),
        GIN(  "negative_vmr_ok" ),
        GIN_TYPE( "Index" ),
        GIN_DEFAULT( "0" ),
        GIN_DESC("Boolean for demanding vmr_field > 0 or not.")
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "atmgeom_checkedCalc" ),
        DESCRIPTION
        (
         "Checks consistency of geometric considerations of the atmosphere.\n"
         "\n"
         "The following WSVs are checked: *z_field*, *refellipsoid* and\n"
         "*z_surface*. If any of the variables above is changed, then this\n"
         "method shall be called again (no automatic check that this is\n"
         "fulfilled!).\n"
         "\n"
         "The tests include that:\n"
         " 1. *refellipsoid* has correct size, and that eccentricity is\n"
         "    set to zero if 1D atmosphere.\n"
         " 2. *z_field* and *z_surface* have sizes consistent with the\n"
         "    atmospheric grids.\n"
         " 3. There is no gap between *z_surface* and *z_field*.\n"
         "\n"
         "If any test fails, there is an error. Otherwise, *atmgeom_checked*\n"
         "is set to 1.\n"
         "\n"
         "See further *atmgeom_checkedCalc*.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "atmgeom_checked" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atmosphere_dim", "p_grid", "lat_grid", "lon_grid", 
            "z_field", "refellipsoid", "z_surface" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));


  md_data_raw.push_back
    ( MdRecord
      ( NAME( "atm_fields_compactAddConstant" ),
        DESCRIPTION
        (
         "Adds a constant field to atm_fields_compact.\n"
         "\n"
         "This is handy for nitrogen or oxygen. The constant value is\n"
         "appended at the end of the fields that are already there. All\n"
         "dimensions (pressure, latitude, longitude) are filled up, so this\n"
         "works for 1D, 2D, or 3D atmospheres.\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT( "atm_fields_compact" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atm_fields_compact" ),
        GIN( "name",   "value" ),
        GIN_TYPE(    "String", "Numeric" ),
        GIN_DEFAULT( NODEF,    NODEF ),
        GIN_DESC( "Name of additional atmospheric field, with constant value.",
                  "Constant value of additional field." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "atm_fields_compactAddSpecies" ),
        DESCRIPTION
        (
         "Adds a field to atm_fields_compact, with interpolation.\n"
         "\n"
         "This method appends a *GriddedField3* to *atm_fields_compact*.\n"
         "The *GriddedField3* is interpolated upon the grid of *atm_fields_compact*.\n"
         "A typical use case for this method may be to add a climatology of some gas\n"
         "when this gas is needed for radiative transfer calculations, but\n"
         "not yet present in *atm_fields_compact*. One case where this happens\n"
         "is when using the Chevalier dataset for infrared simulations.\n"
         "\n"
         "The grids in *atm_fields_compact* must fully encompass the grids in\n"
         "the *GriddedField3* to be added, for interpolation to succeed. If\n"
         "this is not the case, a RuntimeError is thrown.\n"
         ),
        AUTHORS( "Gerrit Holl" ),
        OUT( "atm_fields_compact" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atm_fields_compact" ),
        GIN( "name",   "value" ),
        GIN_TYPE(    "String", "GriddedField3" ),
        GIN_DEFAULT( NODEF,    NODEF ),
        GIN_DESC( "Name of additional atmospheric field.",
                  "Value of additional atmospheric field." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "atm_fields_compactFromMatrix" ),
        DESCRIPTION
        (
         "Set *atm_fields_compact* from 1D profiles in a matrix.\n"
         "\n"
         "For clear-sky batch calculations it is handy to store atmospheric\n"
         "profiles in an array of matrix. We take such a matrix, and create\n"
         "*atm_fields_compact* from it.\n"
         "\n"
         "The matrix must contain one row for each pressure level.\n"
         "The matrix can contain some additional fields which are not directly used\n"
         "by ARTS for calculations but can be required for further processing,\n"
         "for e.g. wind speed and direction. In this case, additional fields must\n"
         "be put at the end of the matrix and they must be flagged by 'ignore',\n"
         "large or small letters, in the field names.\n"
         "Recommended row format:\n"
         "\n"
         "p[Pa] T[K] z[m] VMR_1[fractional] ... VMR[fractional] IGNORE ... IGNORE\n"
         "\n"
         "Works only for *atmosphere_dim==1.*\n"         
         "\n"
         "Keywords:\n"
         "   field_names : Field names to store in atm_fields_compact.\n"
         "                 This should be, e.g.:\n"
         "                 [\"T[K]\", \"z[m]\", \"vmr_h2o[fractional]\", \"ignore\"]\n"
         "                 There must be one name less than matrix columns,\n"
         "                 because the first column must contain pressure.\n"
         ),
        AUTHORS( "Stefan Buehler", "Daniel Kreyling", "Jana Mendrok" ),
        OUT( "atm_fields_compact" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atmosphere_dim" ),
        GIN(      "gin1"      ,
                  "field_names" ),
        GIN_TYPE(    "Matrix",
                     "ArrayOfString" ),
        GIN_DEFAULT( NODEF   ,
                     NODEF ),
        GIN_DESC( "One atmosphere matrix from batch input ArrayOfMatrix.",
                  "Order/names of atmospheric fields." )
        ));
    

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "AtmFieldsFromCompact" ),
        DESCRIPTION
        (
         "Extract pressure grid and atmospheric fields from\n"
         "*atm_fields_compact*.\n"
         "\n"
         "An atmospheric scenario includes the following data for each\n"
         "position (pressure, latitude, longitude) in the atmosphere:\n"
         "           1. temperature field\n"
         "           2. the corresponding altitude field\n"
         "           3. vmr fields for the gaseous species\n"
         "\n"
         "This method just splits up the data found in *atm_fields_compact* to\n"
         "p_grid, lat_grid, lon_grid, and the various fields. No interpolation.\n"
         "See documentation of *atm_fields_compact* for a definition of the data.\n"
         "\n"
         "There are some safety checks on the names of the fields: The first\n"
         "field must be called \"T\", the second \"z\"*. Remaining fields must be\n"
         "trace gas species volume mixing ratios, named for example \"H2O\", \"O3\",\n"
         "and so on. The species names must fit the species in *abs_species*.\n"
         "(Same species in same order.) Only the species name must fit, not the\n"
         "full tag.\n"
         "\n"
         "Possible future extensions: Add a keyword parameter to refine the\n"
         "pressure grid if it is too coarse. Or a version that interpolates onto\n"
         "given grids, instead of using and returning the original grids.\n"
         ),
        AUTHORS( "Stefan Buehler", "Daniel Kreyling", "Jana Mendrok" ),
        OUT( "p_grid", "lat_grid", "lon_grid", "t_field", "z_field",
             "vmr_field", "massdensity_field" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_species", "part_species", "atm_fields_compact", "atmosphere_dim" ),
        GIN( "delim" ),
        GIN_TYPE( "String" ),
        GIN_DEFAULT( "-" ),
        GIN_DESC( "Delimiter string of *part_species* elements." )
        ));
    
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "AtmosphereSet1D" ),
        DESCRIPTION
        (
         "Sets the atmospheric dimension to 1D.\n"
         "\n"
         "Sets *atmosphere_dim* to 1 and gives some variables dummy values.\n"
         "\n"
         "The latitude and longitude grids are set to be empty.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "atmosphere_dim", "lat_grid", "lon_grid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "AtmosphereSet2D" ),
        DESCRIPTION
        (
         "Sets the atmospheric dimension to be 2D.\n"
         "\n"
         "Sets *atmosphere_dim* to 2 and the longitude grid to be empty.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "atmosphere_dim", "lon_grid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "AtmosphereSet3D" ),
        DESCRIPTION
        (
         "Sets the atmospheric dimension to 3D.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "atmosphere_dim" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "AtmRawRead" ),
        DESCRIPTION
        (
         "Reads atmospheric data from a scenario.\n"
         "\n"
         "An atmospheric scenario includes the following data for each\n"
         "position (pressure, latitude, longitude) in the atmosphere:\n"
         "   1. temperature field\n"
         "   2. the corresponding altitude field\n"
         "   3. vmr fields for the gaseous species\n"
         "The data is stored in different files. This methods reads all\n"
         "files and creates the variables *t_field_raw*, *z_field_raw* and\n"
         "*vmr_field_raw*.\n"
         "\n"
         "Files in a scenarios should be named matching the pattern of:\n"
         "tropical.H2O.xml\n"
         "\n"
         "The files can be anywhere, but they must be all in the same\n"
         "directory, selected by 'basename'. The files are chosen by the\n"
         "species name. If you have more than one tag group for the same\n"
         "species, the same profile will be used.\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT( "t_field_raw", "z_field_raw", "vmr_field_raw" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_species" ),
        GIN( "basename" ),
        GIN_TYPE( "String" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "Name of scenario, probably including the full path. For "
                  "example: \"/smiles_local/arts-data/atmosphere/fascod/"
                  "tropical\"" )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "backend_channel_responseFlat" ),
        DESCRIPTION
        (
         "Sets up a rectangular channel response.\n"
         "\n"
         "The response of the backend channels is hee assumed to be constant\n"
         "inside the resolution width, and zero outside.\n"
         "\n"
         "The method assumes that all channels have the same response.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "backend_channel_response" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( ),
        GIN( "resolution" ),
        GIN_TYPE( "Numeric" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "The spectrometer resolution." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "backend_channel_responseGaussian" ),
        DESCRIPTION
        (
         "Sets up a gaussian backend channel response.\n"
         "\n"
         "The method assumes that all channels have the same response, and\n"
         "that it can be modelled as gaussian.\n"
         "\n"
         "The grid generated can be written as\n"
         "   si * [-xwidth_si:dx_si:xwidth_si]\n"
         "where si is the standard deviation corresponding to the FWHM.\n"
         "That is, width and spacing of the grid is specified in terms of\n"
         "number of standard deviations. If xwidth_si is set to 2, the\n"
         "response will cover about 95% the complete response. For\n"
         "xwidth_si=3, about 99% is covered. If xwidth_si/dx_si is not\n"
         "an integer, the end points of the grid are kept and the spacing\n"
         "if the grid is adjusted in the downward direction (ie. spacing is.\n"
         "is max *dx_si*).\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "backend_channel_response" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( ),
        GIN( "fwhm", "xwidth_si", "dx_si" ),
        GIN_TYPE( "Numeric", "Numeric", "Numeric" ),
        GIN_DEFAULT( NODEF, "3", "0.1" ),
        GIN_DESC( "Full width at half-maximum", 
                  "Half-width of response, in terms of std. dev.", 
                  "Grid spacing, in terms of std. dev." )
        ));
 
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "batch_atm_fields_compactAddConstant" ),
        DESCRIPTION
        (
         "Adds a constant field to batch_atm_fields_compact.\n"
         "\n"
         "Applies *atm_fields_compactAddConstant* to each batch.\n"
         "The format is equal to that WSM.\n"
         ),
        AUTHORS( "Gerrit Holl" ),
        OUT( "batch_atm_fields_compact" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "batch_atm_fields_compact" ),
        GIN( "name",   "value" ),
        GIN_TYPE(    "String", "Numeric" ),
        GIN_DEFAULT( NODEF,    NODEF ),
        GIN_DESC( "Name of additional atmospheric field, with constant value.",
                  "Constant value of additional field." )
        ));

   md_data_raw.push_back
    ( MdRecord
      ( NAME( "batch_atm_fields_compactAddSpecies" ),
        DESCRIPTION
        (
         "Adds a field to *batch_atm_fields_compact*, with interpolation.\n"
         "\n"
         "This method appends a *GriddedField3* to each *atm_fields_compact*.\n"
         "in *batch_atm_fields_compact*. For details, see *atm_fields_compactAddSpecies*.\n"
         ),
        AUTHORS( "Gerrit Holl" ),
        OUT( "batch_atm_fields_compact" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "batch_atm_fields_compact" ),
        GIN( "name",   "value" ),
        GIN_TYPE(    "String", "GriddedField3" ),
        GIN_DEFAULT( NODEF,    NODEF ),
        GIN_DESC( "Name of additional atmospheric field. Use, e.g., vmr_ch4 for methane VMR",
                  "Value of additional atmospheric field." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "batch_atm_fields_compactFromArrayOfMatrix" ),
        DESCRIPTION
        (
         "Expand batch of 1D atmospheric states to a batch_atm_fields_compact.\n"
         "\n"
         "This is used to handle 1D batch cases, for example from the Chevallier\n"
         "data set, stored in a matrix.\n"
         "\n"
         "The matrix must contain one row for each pressure level.\n"
         "The matrix can contain some additional fiels which are not directly used\n"
         "by ARTS for calculations but can be required for further processing,\n"
         "for e.g. wind speed and direction. In this case, additional fields must\n"
         "be put at the end of the matrix and they must be flagged by 'ignore',\n"
         "large or small letters, in the field names.\n"
         "Row format:\n"
         "\n" 
         "p[Pa] T[K] z[m] VMR_1[fractional] ... VMR[fractional] IGNORE ... IGNORE\n"
         "\n"
         "Keywords:\n"
         "   field_names : Field names to store in atm_fields_compact.\n"
         "                 This should be, e.g.:\n"
         "                 [\"T\", \"z\", \"H2O\", \"O3\", \"ignore\"]\n"
         "                 There must be one name less than matrix columns,\n"
         "                 because the first column must contain pressure.\n"
         "\n"
         "   extra_field_names : You can add additional constant VMR fields,\n"
         "                       which is handy for O2 and N2. Give here the\n"
         "                       field name, e.g., \"O2\". Default: Empty.\n"
         "\n"
         "   extra_field_values : Give here the constant field value. Default:\n"
         "                        Empty. Dimension must match extra_field_names.\n"
         ),
        AUTHORS( "Stefan Buehler", "Daniel Kreyling", "Jana Mendrok" ),
        OUT( "batch_atm_fields_compact" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atmosphere_dim" ),
        GIN(      "gin1"             ,
                  "field_names", "extra_field_names", "extra_field_values" ),
        GIN_TYPE(    "ArrayOfMatrix",
                     "ArrayOfString", "ArrayOfString",     "Vector" ),
        GIN_DEFAULT( NODEF          ,
                     NODEF,         "[]",                "[]" ),
        //KW_DEFAULT( NODEF,         NODEF,                NODEF ),
        GIN_DESC( "Batch of atmospheres stored in one array of matrix",
                  "Order/names of atmospheric fields.",
                  "Names of additional atmospheric fields, with constant values.",
                  "Constant values of additional fields.")
        ));
    
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "blackbody_radiationPlanck" ),
        DESCRIPTION
        (
         "The Planck function (frequency version).\n"
         "\n"
         "The standard function for *blackbody_radiation_agenda*.\n"
         "\n"
         "The is considered as the standard version inside ARTS of the Planck\n"
         "function. The unit of the returned data is W/(m^2 Hz sr).\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "blackbody_radiation" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "f_grid", "rtp_temperature" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));
    
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_cia_dataReadFromCIA" ),
        DESCRIPTION
        (
         "Read data from a CIA data file for all CIA molecules defined\n"
         "in *abs_species*.\n"
         "\n"
         "The units in the HITRAN file are:\n"
         "Frequency: cm^(-1)\n"
         "Binary absorption cross-section: cm^5 molec^(-2)\n"
         "\n"
         "Upon reading we convert this to the ARTS internal SI units \n"
         "of Hz and m^5 molec^(-2).\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( "abs_cia_data" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_species" ),
        GIN( "catalogpath" ),
        GIN_TYPE( "String" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "Path to the CIA catalog directory." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "abs_cia_dataReadFromXML" ),
        DESCRIPTION
        (
         "Read data from a CIA XML file and check that all CIA tags defined\n"
         "in *abs_species* are present in the file.\n"
         "\n"
         "The units of the data are described in *abs_cia_dataReadFromCIA*.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( "abs_cia_data" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_species" ),
        GIN( "filename" ),
        GIN_TYPE( "String" ),
        GIN_DEFAULT( "" ),
        GIN_DESC( "Name of the XML file." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "CIAInfo" ),
        DESCRIPTION
        (
         "Display information about the given CIA tags.\n"
         "The CIA tags shown are in the same format as needed by *abs_speciesSet*.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT(),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN( "catalogpath", "cia_tags" ),
        GIN_TYPE( "String", "ArrayOfString" ),
        GIN_DEFAULT( NODEF, NODEF ),
        GIN_DESC( "Path to the CIA catalog directory.",
                  "Array of CIA tags to view, e.g. [ \"N2-N2\", \"H2-H2\" ]" )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "CloudboxGetIncoming" ),
        DESCRIPTION
        (
         "Calculates incoming radiation field of the cloudbox by repeated\n"
         "radiative transfer calculations.\n"
         "\n"
         "The method performs monochromatic pencil beam calculations for\n"
         "all grid positions on the cloudbox boundary, and all directions\n"
         "given by scattering angle grids (*scat_za/aa_grid*). Found radiances\n"
         "are stored in *scat_i_p/lat/lon* which can be used as boundary\n"
         "conditions when scattering inside the cloud box is solved by the\n"
         "DOIT method.\n"
         "\n"
         "Can only handle *iy_unit*=1 (intensity in terms of radiances). Other\n"
         "output units need to be derived by unit conversion later on (e.g.\n"
         "after yCalc).\n"
         ),
        AUTHORS( "Sreerekha T.R.", "Claudia Emde" ),
        OUT( "scat_i_p", "scat_i_lat", "scat_i_lon" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN("atmfields_checked", "atmgeom_checked",
           "cloudbox_checked", "iy_main_agenda", "atmosphere_dim", 
           "lat_grid", "lon_grid", "z_field", "t_field", "vmr_field",
            "cloudbox_on", "cloudbox_limits", "f_grid", "stokes_dim", 
            "iy_unit", "blackbody_radiation_agenda", 
            "scat_za_grid", "scat_aa_grid" ),
        GIN( "rigorous", "maxratio" ),
        GIN_TYPE( "Index", "Numeric" ),
        GIN_DEFAULT( "1", "100" ),
        GIN_DESC( "Fail if incoming field is not safely interpolable.",
                  "Maximum allowed ratio of two radiances regarded as interpolable." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "CloudboxGetIncoming1DAtm" ),
        DESCRIPTION
        (
         "As *CloudboxGetIncoming* but assumes clear sky part to be 1D."
         "\n"
         "The incoming field is calculated only for one position and azimuth\n"
         "angle for each cloud box boundary, and obtained values are used\n"
         "for all other postions and azimuth angles. This works if a 3D\n"
         "cloud box is put into an 1D background atmosphere.\n"
         "\n"
         "This method can only be used for 3D cases.\n"
         ),
        AUTHORS( "Sreerekha T.R.", "Claudia Emde" ),
        OUT( "scat_i_p", "scat_i_lat", "scat_i_lon", "cloudbox_on" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atmfields_checked", "atmgeom_checked",
            "cloudbox_checked", "iy_main_agenda", "atmosphere_dim", 
            "lat_grid", "lon_grid", "z_field", "t_field", "vmr_field",
            "cloudbox_on", "cloudbox_limits",
            "f_grid", "stokes_dim", "iy_unit", 
            "blackbody_radiation_agenda", "scat_za_grid", "scat_aa_grid" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "cloudboxOff" ),
        DESCRIPTION
        (
         "Deactivates the cloud box.\n"
         "\n"
         "Use this method if no scattering calculations shall be performed.\n"
         "\n"
         "The function sets *cloudbox_on* to 0, *cloudbox_limits*,\n"
         "*pnd_field*, *scat_data_array*, *iy_cloudbox_agenda* and\n"
         "*particle_masses* to be empty and *use_mean_scat_data* to -999.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "cloudbox_on", "cloudbox_limits", "iy_cloudbox_agenda", 
             "pnd_field", "scat_data_array", "particle_masses"
           ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));
    
    
    md_data_raw.push_back
    ( MdRecord
      ( NAME( "cloudboxSetAutomatically" ),
        DESCRIPTION
        (
         "Sets the cloud box to encompass the cloud given by the entries\n"
         "in *massdensity_field*. \n"
         "\n"
         "The function must be called before any *cloudbox_limits* using\n"
         "WSMs.\n"
         "NOTE: only 1-dim case is handeled in the moment!\n"
         "\n"
         "The function iterates over all *part_species* and performs a \n"
         "check, to see if the corresponding scattering particle profiles do not\n"
         "contain a cloud (all values equal zero). If, after all iterations,\n"
         "all the considrered profiles proove to contain no cloud,\n"
         "the cloudbox is switched off! (see WSM *cloudboxOff*)\n"
         "\n"
         "Each scattering particle profile is searched for the first and last\n"
         "pressure index, where the value is unequal to zero. This index\n"
         "is then copied to *cloudbox_limits*.\n"
         "\n"
         "Additionaly the lower cloudbox_limit is altered by\n" 
         "*cloudbox_margin*.\n"
         "The margin is given as a height difference in meters and\n"
         "trasformed into a pressure.(via isothermal barometric heightformula)\n"
         "This alteration is needed to ensure, that scattered photons\n"
         "do not leave and re-enter the cloudbox, due to its convex\n"
         "shape.\n"
         "If *cloudbox_margin* is set to -1 (default), the cloudbox will extend to\n" 
         "the surface. Hence the lower cloudbox_limit is set to 0 (index\n"
         "of first pressure level).\n"
         ),
        AUTHORS( "Daniel Kreyling" ),
        OUT( "cloudbox_on", "cloudbox_limits"),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atmosphere_dim", "p_grid", "lat_grid", "lon_grid", "massdensity_field"),
        GIN( "cloudbox_margin"),
        GIN_TYPE( "Numeric" ),
        GIN_DEFAULT( "-1" ),
        GIN_DESC( "The margin alters the lower vertical\n"
                  "cloudbox limit. Value must be given in [m].\n"
                  "If cloudbox_margin is set to *-1* (default), the lower\n" 
                  "cloudbox limit equals 0, what corresponds to the surface !\n"
        )
        ));
  
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "cloudboxSetDisort" ),
        DESCRIPTION
        (
         "For Disort calculation the cloudbox must be extended to\n"
         "cover the full atmosphere.\n"
         "This method sets *cloudbox_limits* accordingly.\n"
         ), 
        AUTHORS( "Claudia Emde" ),
        OUT( "cloudbox_on", "cloudbox_limits" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "p_grid" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));


  md_data_raw.push_back
    ( MdRecord
      ( NAME( "cloudboxSetManually" ),
        DESCRIPTION
        (
         "Sets the cloud box to encompass the given positions.\n"
         "\n"
         "The function sets *cloudbox_on* to 1 and sets *cloudbox_limits*\n"
         "following the given pressure, latitude and longitude positions.\n"
         "The index limits in *cloudbox_limits* are selected to give the\n" 
         "smallest possible cloud box that encompass the given points.\n"
         "\n"
         "The points must be given in the same order as used in\n"
         "*cloudbox_limits*. That means that the first keyword argument\n"
         "shall be a higher pressure than argument two, while the latitude\n"
         "and longitude points are given in increasing order. Positions\n"
         "given for dimensions not used by the selected atmospheric\n"
         "dimensionality are ignored.\n"
         "\n"
         "The given pressure points can be outside the range of *p_grid*.\n"
         "The pressure limit is then set to the end point of *p_grid*.\n"
         "The given latitude and longitude points must be inside the range\n"
         "of the corresponding grid. In addition, the latitude and longitude\n"
         "points cannot be inside the outermost grid ranges as the latitude\n"
         "and longitude limits in *cloudbox_limits* are not allowed to be\n"
         "grid end points.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "cloudbox_on", "cloudbox_limits" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atmosphere_dim", "p_grid", "lat_grid", "lon_grid" ),
        GIN( "p1",      "p2",      "lat1",    "lat2",    "lon1",
             "lon2" ),
        GIN_TYPE(    "Numeric", "Numeric", "Numeric", "Numeric", "Numeric", 
                     "Numeric" ),
        GIN_DEFAULT( NODEF,     NODEF,     NODEF,     NODEF,     NODEF,
                     NODEF ),
        GIN_DESC( "Upper pressure point.",
                  "Lower pressure point.",
                  "Lower latitude point.",
                  "Upper latitude point.",
                  "Lower longitude point.",
                  "Upper longitude point." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "cloudboxSetManuallyAltitude" ),
        DESCRIPTION
        (
         "Sets the cloud box to encompass the given positions.\n"
         "\n"
         "As *cloudboxSetManually* but uses altitudes instead of pressure.\n"
         "The given altitude points can be outside the range of *z_field*.\n"
         "The altitude limit is then set to the end point of *p_grid*.\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT( "cloudbox_on", "cloudbox_limits" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atmosphere_dim", "z_field", "lat_grid", "lon_grid" ),
        GIN( "z1",      "z2",      "lat1",    "lat2",    "lon1",
             "lon2" ),
        GIN_TYPE(    "Numeric", "Numeric", "Numeric", "Numeric", "Numeric", 
                     "Numeric" ),
        GIN_DEFAULT( NODEF,     NODEF,     NODEF,     NODEF,     NODEF,
                     NODEF ),
        GIN_DESC( "Lower altitude point.",
                  "Upper altitude point.",
                  "Lower latitude point.",
                  "Upper latitude point.",
                  "Lower longitude point.",
                  "Upper longitude point." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "cloudbox_checkedCalc" ),
        DESCRIPTION
        (
         "Checks consistency between cloudbox and particle variables.\n"
         "\n"
         "The following WSVs are treated: *cloudbox_on*, *cloudbox_limits*,\n"
         "*pnd_field*, *scat_data_array*, *particle_masses* and\n"
         "wind_u/v/w_field.\n"
         "\n"
         "If any of these variables are changed, then this method shall be\n"
         "called again (no automatic check that this is fulfilled!).\n"
         "\n"
         "The main checks are if the cloudbox limits are OK with respect to\n"
         "the atmospheric dimensionality and the limits of the atmosphere,\n"
         "and that the particle variables match in size.\n"
         "\n"
         "If any test fails, there is an error. Otherwise, *cloudbox_checked*\n"
         "is set to 1.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "cloudbox_checked" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atmfields_checked", "atmosphere_dim", "p_grid", "lat_grid", 
            "lon_grid", "z_field", "z_surface",
            "wind_u_field", "wind_v_field", "wind_w_field", 
            "cloudbox_on", "cloudbox_limits", "pnd_field", "scat_data_array",
            "particle_masses", "abs_species" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Compare" ),
        DESCRIPTION
        (
         "Checks the consistency between two variables.\n" 
         "\n"
         "The two variables are checked to not deviate outside the specified\n"
         "value (*maxabsdiff*). An error is issued if this is not fulfilled.\n"
         "\n"
         "The main application of this method is to be part of the test\n"
         "control files, and then used to check that a calculated value\n"
         "is consistent with an old, reference, value.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN( "var1", "var2", "maxabsdiff", "error_message" ),
        GIN_TYPE( "Numeric, Vector, Matrix, Tensor3, Tensor7, ArrayOfVector, ArrayOfMatrix",
                  "Numeric, Vector, Matrix, Tensor3, Tensor7, ArrayOfVector, ArrayOfMatrix",
                  "Numeric", "String" ),
        GIN_DEFAULT( NODEF, NODEF, "", "" ),
        GIN_DESC( "A first variable", "A second variable", 
                  "Threshold for maximum absolute difference.",
                  "Additional error message."),
        SETMETHOD(      false ),
        AGENDAMETHOD(   false ),
        USES_TEMPLATES( false ),
        PASSWORKSPACE(  false ),
        PASSWSVNAMES(   true  )
        ));

  md_data_raw.push_back
    ( MdRecord
    ( NAME( "complex_refr_indexConstant" ),
      DESCRIPTION
      (
       "Set complex refractive index to a constant value.\n"
       "\n"
       "Frequency and temperature grids are set to have length 1 (and\n" 
       "set to the value 0).\n"
       ),
      AUTHORS( "Oliver Lemke" ),
      OUT( "complex_refr_index" ),
      GOUT(),
      GOUT_TYPE(),
      GOUT_DESC(),
      IN(),
      GIN( "refr_index_real", "refr_index_imag" ),
      GIN_TYPE( "Numeric", "Numeric" ),
      GIN_DEFAULT( NODEF, NODEF ),
      GIN_DESC( "Real part of refractive index",
                "Imag part of refractive index" )
      ));
    
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "complex_refr_indexIceWarren84" ),
        DESCRIPTION
        (
         "Refractive index of ice follwoing Warren84 parameterization.\n"
         "\n"
         "Calculates complex refractive index of Ice 1H for wavelengths\n"
         "between 45 nm and 8.6 m.\n"
         "For wavelengths above 167 microns, temperature dependence is\n"
         "included for temperatures between 213 and 272K.\n"
         "Mainly intended for applications in Earth ice\n"
         "clouds and snow, not other planets or interstellar space;\n"
         "the temperature dependence or crystalline form of ice may be\n"
         "incorrect for these latter applications.\n"
         "\n"
         "Authors of Fortran function:\n"
         "Stephen Warren, Univ. of Washington (1983)\n"
         "Bo-Cai Gao, JCESS, Univ. of Maryland (1995)\n"
         "Warren Wiscombe, NASA Goddard (1995)\n"
         "\n"
         "References:\n"
         "Warren, S., 1984: Optical Constants of Ice from the Ultraviolet\n"
         "to the Microwave, Appl. Opt. 23, 1206-1225\n"
         "\n"
         "Kou, L., D. Labrie, and P. Chylek, 1994: Refractive indices\n"
         "of water and ice in the 0.65- to 2.5-micron spectral range,\n"
         "Appl. Opt. 32, 3531-3540\n"
         "\n"
         "Perovich, D., and J. Govoni, 1991: Absorption Coefficients\n"
         "of Ice from 250 to 400 nm, Geophys. Res. Lett. 18, 1233-1235\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( "complex_refr_index" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN( "data_f_grid", "data_T_grid" ),
        GIN_TYPE( "Vector", "Vector" ),
        GIN_DEFAULT( NODEF, NODEF ),
        GIN_DESC( "Frequency grid for refractive index calculation",
                  "Temperature grid for refractive index calculation" )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "complex_refr_indexWaterLiebe93" ),
        DESCRIPTION
        (
         "Complex refractive index of liquid water according to Liebe 1993.\n"
         "\n"
         "The method treats liquid water without salt. Thus, not valid below\n"
         "10 GHz. Upper frequency limit not known, here set to 1000 GHz.\n"
         "Model parameters taken from Atmlab function epswater93 (by\n"
         "C. Maetzler), which refer to Liebe 1993 without closer\n"
         "specifications.\n"
         "\n"
         "Temperatures must be between -40 and 100 degrees Celsius. The\n"
         "accuracy of the parametrization below 0 C is not known by us.\n"
         ),
        AUTHORS( "Patrick Eriksson", "Oliver Lemke" ),
        OUT( "complex_refr_index" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN( "data_f_grid", "data_T_grid" ),
        GIN_TYPE( "Vector", "Vector" ),
        GIN_DEFAULT( NODEF, NODEF ),
        GIN_DESC( "Frequency grid for refractive index calculation",
                  "Temperature grid for refractive index calculation" )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Copy" ),
        DESCRIPTION
        (
         "Copy a workspace variable.\n"
         "\n"
         "This method can copy any workspace variable\n"
         "to another workspace variable of the same group. (E.g., a Matrix to\n"
         "another Matrix.)\n"
         "\n"
         "As always, output comes first in the argument list!\n"
         "\n"
         "Usage example:\n"
         "\n"
         "Copy(f_grid, p_grid)\n"
         "\n"
         "Will copy the content of *p_grid* to *f_grid*. The size of *f_grid*\n"
         "is adjusted automatically (the normal behaviour for workspace\n"
         "methods).\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT(),
        GOUT(      "out"    ),
        GOUT_TYPE( "Any" ),
        GOUT_DESC( "Destination variable." ),
        IN(),
        GIN(      "in"    ),
        GIN_TYPE(    "Any" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "Source variable." ),
        SETMETHOD(      false ),
        AGENDAMETHOD(   false ),
        USES_TEMPLATES( true  ),
        PASSWORKSPACE(  false ),
        PASSWSVNAMES(   true  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Delete" ),
        DESCRIPTION
        (
         "Deletes a workspace variable.\n"
         "\n"
         "The variable is marked as uninitialized and its memory freed.\n"
         "It is not removed from the workspace though, therefore you\n"
         "don't need to/can't call Create for this variable again.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT(),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(         "v" ),
        GIN_TYPE(    "Any" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC(    "Variable to be deleted." ),
        SETMETHOD(      false ),
        AGENDAMETHOD(   false ),
        USES_TEMPLATES( true  ),
        PASSWORKSPACE(  true  ),
        PASSWSVNAMES(   true  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "DoitAngularGridsSet" ),
        DESCRIPTION
        (
         "Sets the angular grids for DOIT calculation."
         "\n"
         "In this method the angular grids for a DOIT calculation are\n"
         "specified. For down-looking geometries it is sufficient to define\n"
         "*N_za_grid* and *N_aa_grid*. From these numbers equally spaced\n"
         "grids are created and stored in the WSVs *scat_za_grid* and\n"
         "*scat_aa_grid*.\n" 
         "\n"
         "For limb simulations it is important to use an optimized zenith \n"
         "angle grid with a very fine resolution about 90 degrees. Such a grid can be\n"
         "generated using *doit_za_grid_optCalc*. The filename of an optimized\n"
         "zenith angle grid can be given as a keyword (*za_grid_opt_file*).\n"
         "\n"
         "If a filename is given, the equidistant grid is used for the\n"
         "calculation of the scattering integrals and the optimized grid is\n"
         "applied for integration of the radiative transfer equation. \n"
         "\n"
         "For down-looking cases no filename should be specified (za_grid_opt_file = \"\" ) \n"
         "Using only the equidistant grid makes sense to speed up the calculation.\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT( "doit_za_grid_size", "scat_aa_grid", "scat_za_grid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN( "N_za_grid", "N_aa_grid", "za_grid_opt_file" ),
        GIN_TYPE(    "Index",     "Index",     "String" ),
        GIN_DEFAULT( NODEF,       NODEF,       NODEF ),
        GIN_DESC( "Number of grid points in zenith angle grid. "
                  "Recommended value is 19.",
                  "Number of grid points in azimuth angle grid. "
                  "Recommended value is 37.",
                  "Name of special grid for RT part." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "DoitCloudboxFieldPut" ),
        DESCRIPTION
        (
         "Method for the DOIT communication between cloudbox and clearsky.\n"
         "\n"
         "This method puts the scattered radiation field into the interface\n"
         "variables between the cloudbox and the clearsky, which are\n"
         "*scat_i_p*, *scat_i_lat* and *scat_i_lon*.\n"
         "\n"
         "The best way to calculate spectra including the influence of\n" 
         "scattering is to set up the *doit_mono_agenda* where this method\n"
         "can be included.\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT( "scat_i_p", "scat_i_lat", "scat_i_lon",
             "doit_i_field1D_spectrum" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "scat_i_p", "doit_i_field", "f_grid", "f_index",   "p_grid", "lat_grid", 
            "lon_grid", "scat_za_grid", "scat_aa_grid", "stokes_dim",
            "atmosphere_dim", "cloudbox_limits", "sensor_pos", "z_field" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "doit_conv_flagAbs" ),
        DESCRIPTION
        (
         "DOIT convergence test (maximum absolute difference).\n"
         "\n"
         "The function calculates the absolute differences for two successive\n"
         "iteration fields. It picks out the maximum values for each Stokes\n"
         "component separately. The convergence test is fullfilled under the\n"
         "following conditions:\n"
         "   |I(m+1) - I(m)| < epsilon_1     Intensity.\n"
         "   |Q(m+1) - Q(m)| < epsilon_2     The other Stokes components.\n" 
         "   |U(m+1) - U(m)| < epsilon_3   \n"
         "   |V(m+1) - V(m)| < epsilon_4   \n" 
         "These conditions have to be valid for all positions in the\n"
         "cloudbox and for all directions.\n"  
         ),
        AUTHORS( "Claudia Emde" ),
        OUT( "doit_conv_flag", "doit_iteration_counter", "doit_i_field" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "doit_conv_flag", "doit_iteration_counter",
            "doit_i_field", "doit_i_field_old" ),
        GIN( "epsilon", "max_iterations", "nonconv_return_nan" ),
        GIN_TYPE( "Vector", "Index", "Index" ),
        GIN_DEFAULT( NODEF, "100", "0" ),
        GIN_DESC( "Limits for convergence. A vector with length matching "
                  "*stokes_dim* with unit [W / (m^2 Hz sr)].",
                  "Maximum number of iterations allowed to reach convergence"
                  "limit.",
                  "Flag whether to accept result at max_iterations (0=default)"
                  "or whether to return NaNs in case of non-convergence at"
                  "max_iterations"
                  )
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "doit_conv_flagAbsBT" ),
        DESCRIPTION
        (
         "DOIT convergence test (maximum absolute difference in Rayleigh Jeans "
         "BT)\n"
         "\n"
         "As *doit_conv_flagAbs* but convergence limits are specified in\n"
         "Rayleigh-Jeans brighntess temperatures.\n"
         ),
        AUTHORS( "Sreerekha T.R.", "Claudia Emde" ),
        OUT( "doit_conv_flag", "doit_iteration_counter", "doit_i_field" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "doit_conv_flag", "doit_iteration_counter",
            "doit_i_field", "doit_i_field_old", "f_grid", "f_index" ),
        GIN( "epsilon", "max_iterations", "nonconv_return_nan" ),
        GIN_TYPE( "Vector", "Index", "Index" ),
        GIN_DEFAULT( NODEF, "100", "0" ),
        GIN_DESC( "Limits for convergence. A vector with length matching "
                  "*stokes_dim* with unit [K].",
                  "Maximum number of iterations allowed to reach convergence"
                  "limit.",
                  "Flag whether to accept result at max_iterations (0=default)"
                  "or whether to return NaNs in case of non-convergence at"
                  "max_iterations"
                  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "doit_conv_flagLsq" ),
        DESCRIPTION
        (
         "DOIT convergence test (least squares).\n"
         "\n"
         "As *doit_conv_flagAbsBT* but applies a least squares convergence\n"
         "test between two successive iteration fields.\n"
         "\n"
         "Warning: This method is not recommended because this kind of\n"
         "convergence test is not sufficiently strict, so that the\n"
         "DOIT result might be wrong.\n" 
         ),
        AUTHORS( "Claudia Emde" ),
        OUT( "doit_conv_flag", "doit_iteration_counter", "doit_i_field" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "doit_conv_flag", "doit_iteration_counter", 
            "doit_i_field", "doit_i_field_old", "f_grid", "f_index" ),
        GIN( "epsilon", "max_iterations", "nonconv_return_nan" ),
        GIN_TYPE( "Vector", "Index", "Index" ),
        GIN_DEFAULT( NODEF, "100", "0" ),
        GIN_DESC( "Limits for convergence. A vector with length matching "
                  "*stokes_dim* with unit [K].",
                  "Maximum number of iterations allowed to reach convergence"
                  "limit.",
                  "Flag whether to accept result at max_iterations (0=default)"
                  "or whether to return NaNs in case of non-convergence at"
                  "max_iterations"
                  )
        ));
  
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "DoitInit" ),
        DESCRIPTION
        (
         "Initialises variables for DOIT scattering calculations.\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT( "scat_p_index", "scat_lat_index", "scat_lon_index", 
             "scat_za_index", "scat_aa_index", "doit_scat_field",
             "doit_i_field", "doit_is_initialized" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "stokes_dim", "atmosphere_dim", "scat_za_grid", "scat_aa_grid",
            "doit_za_grid_size", "cloudbox_on", "cloudbox_limits", "scat_data_array" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "doit_i_fieldIterate" ),
        DESCRIPTION
        (
         "Iterative solution of the VRTE (DOIT method).\n"
         "\n"
         "A solution for the RTE with scattering is found using the\n"
         "DOIT method:\n"
         " 1. Calculate scattering integral using *doit_scat_field_agenda*.\n"
         " 2. Calculate RT with fixed scattered field using\n"
         "    *doit_rte_agenda*.\n"
         " 3. Convergence test using *doit_conv_test_agenda*.\n"
         "\n"
         "Note: The atmospheric dimensionality *atmosphere_dim* can be\n"
         "      either 1 or 3. To these dimensions the method adapts\n"
         "      automatically. 2D scattering calculations are not\n"
         "      supported.\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT( "doit_i_field" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "doit_i_field", "doit_scat_field_agenda", "doit_rte_agenda", 
            "doit_conv_test_agenda" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "doit_i_fieldSetClearsky" ),
        DESCRIPTION
        (
         "Interpolate clearsky field on all gridpoints in cloudbox.\n"
         "\n"
         "This method uses a linear 1D/3D interpolation scheme to obtain the\n"
         "radiation field on all grid points inside the cloud box from the\n"
         "clear sky field on the cloud box boundary. This radiation field\n"
         "is taken as the first guess radiation field in the DOIT module.\n"
         "\n"
         "Set the *all_frequencies* to 1 if the clearsky field shall be used\n"
         "as initial field for all frequencies. Set it to 0 if the clear sky\n"
         "field shall be used only for the first frequency in *f_grid*. For\n"
         "later frequencies, *doit_i_field* of the previous frequency is then\n"
         "used.\n"
         ),
        AUTHORS( "Sreerekha T.R. and Claudia Emde" ),
        OUT( "doit_i_field" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "doit_i_field", "scat_i_p", "scat_i_lat", "scat_i_lon", "f_grid",
            "f_index", "p_grid", "lat_grid", "lon_grid", 
            "cloudbox_limits", "atmosphere_dim" ),
        GIN( "all_frequencies" ),
        GIN_TYPE( "Index" ),
        GIN_DEFAULT( "1" ),
        GIN_DESC( "See above." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "doit_i_fieldSetConst" ),
        DESCRIPTION
        (
         "This method sets the initial field inside the cloudbox to a\n"
         "constant value. The method works only for monochromatic\n"
         "calculations (number of elements in f_grid=1).\n"
         "\n"
         "The user can specify a value for each Stokes dimension in the\n"
         "control file by *value*.\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT( "doit_i_field" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "scat_i_p", "scat_i_lat", "scat_i_lon", "p_grid", "lat_grid", 
            "lon_grid", 
            "cloudbox_limits", "atmosphere_dim", "stokes_dim" ),
        GIN( "value" ),
        GIN_TYPE(    "Vector" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "A vector containing 4 elements with the value of the "
                  "initial field for each Stokes dimension."
                  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "doit_i_fieldUpdate1D" ),
        DESCRIPTION
        (
         "RT calculation in cloudbox with fixed scattering integral (1D).\n"
         "\n"
         "Updates the radiation field (DOIT method). The method loops\n"
         "through the cloudbox to update the radiation field for all\n"
         "positions and directions in the 1D cloudbox.\n"
         "\n"
         "Note: This method is very inefficient, because the number of\n"
         "iterations scales with the number of cloudbox pressure levels.\n"
         "It is recommended to use *doit_i_fieldUpdateSeq1D*.\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT( "doit_i_field" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "doit_i_field",
            "doit_scat_field", "cloudbox_limits",
            "propmat_clearsky_agenda",
            "vmr_field", "spt_calc_agenda", "scat_za_grid", "pnd_field", 
            "opt_prop_part_agenda", "ppath_step_agenda", "ppath_lraytrace", 
            "p_grid", "z_field", "refellipsoid", 
            "t_field", "f_grid", "f_index", 
            "surface_rtprop_agenda", "doit_za_interp" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "doit_i_fieldUpdateSeq1D" ),
        DESCRIPTION
        (
         "RT calculation in cloudbox with fixed scattering integral.\n"
         "\n"
         "Updates radiation field (*doit_i_field*) in DOIT module.\n"
         "This method loops through the cloudbox to update the\n"
         "radiation field for all positions and directions in the 1D\n"
         "cloudbox. The method applies the sequential update. For more\n"
         "information refer to AUG.\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT( "doit_i_field", "doit_scat_field" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "doit_i_field", "doit_scat_field", "cloudbox_limits",
            "propmat_clearsky_agenda",
            "vmr_field", "spt_calc_agenda", "scat_za_grid", "scat_aa_grid", 
            "pnd_field", "opt_prop_part_agenda", "ppath_step_agenda", 
            "ppath_lraytrace", "p_grid", "z_field", "refellipsoid", 
            "t_field", "f_grid", "f_index", 
            "surface_rtprop_agenda", "doit_za_interp" ),
        GIN( "normalize", "norm_error_threshold", "norm_debug" ),
        GIN_TYPE( "Index", "Numeric", "Index" ),
        GIN_DEFAULT( "0", "0.05", "0" ),
        GIN_DESC( "Apply normalization to scattered field.",
                  "Error threshold for scattered field correction factor.",
                  "Debugging flag. Set to 1 to output normalization factor to out0.")
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "doit_i_fieldUpdateSeq1DPP" ),
        DESCRIPTION
        (
         "RT calculation in cloudbox with fixed scattering integral.\n"
         "\n " 
         "Update radiation field (*doit_i_field*) in DOIT module.\n"
         "This method loops through the cloudbox to update the\n"
         "radiation field for all\n"
         "positions and directions in the 1D cloudbox. The method applies\n"
         "the sequential update and the plane parallel approximation.\n"
         "This method is only slightly faster than\n"
         "*doit_i_fieldUpdateSeq1D* and it is less accurate. It can not\n"
         "be used for limb simulations.\n"
         ),
        AUTHORS( "Sreerekha T.R." ),
        OUT( "doit_i_field", "scat_za_index" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "doit_i_field",
            "doit_scat_field", "cloudbox_limits",
            "propmat_clearsky_agenda",
            "vmr_field", "spt_calc_agenda", "scat_za_grid", "pnd_field", 
            "opt_prop_part_agenda",
            "p_grid", "z_field", "t_field", "f_grid", "f_index" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "doit_i_fieldUpdateSeq3D" ),
        DESCRIPTION
        (
         "RT calculation in cloudbox with fixed scattering integral.\n"
         "\n"
         "Update radiation field (*doit_i_field*) in DOIT module.\n"
         "This method loops through the cloudbox to update the\n"
         "radiation field for all positions and directions in the 3D\n"
         "cloudbox. The method applies the sequential update. For more\n"
         "information please refer to AUG.\n"
         "Surface reflections are not yet implemented in 3D scattering\n"
         "calculations.\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT( "doit_i_field" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "doit_i_field", "doit_scat_field", "cloudbox_limits", 
            "propmat_clearsky_agenda",
            "vmr_field", "spt_calc_agenda", "scat_za_grid", "scat_aa_grid",
            "pnd_field", "opt_prop_part_agenda", "ppath_step_agenda", 
            "ppath_lraytrace", "p_grid", "lat_grid", "lon_grid", "z_field",
            "refellipsoid", "t_field",
            "f_grid", "f_index", "doit_za_interp" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));
  
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "doit_scat_fieldCalc" ),
        DESCRIPTION
        (
         "Calculates the scattering integral field in the DOIT module.\n"
         "\n"
         "The scattering integral field is generated by integrating\n"
         "the product of phase matrix and Stokes vector over all incident\n"
         "angles. For more information please refer to AUG.\n" 
         ),
        AUTHORS( "Sreerekha T.R.", "Claudia Emde" ),
        OUT( "doit_scat_field" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "doit_scat_field", "pha_mat_spt_agenda",
            "doit_i_field", "pnd_field", "t_field", "atmosphere_dim", 
            "cloudbox_limits", "scat_za_grid", "scat_aa_grid",  
            "doit_za_grid_size" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "doit_scat_fieldCalcLimb" ),
        DESCRIPTION
        (
         "Calculates the scattering integral field in the DOIT module (limb).\n"
         "\n"
         "The scattering integral field is the field generated by integrating\n"
         "the product of phase matrix and the Stokes vector over all incident\n"
         "angles.\n"
         "\n"
         "For limb simulations it makes sense to use different\n"
         "zenith angle grids for the scattering integral part and the RT part,\n"
         "because the latter part requires a much finer resolution near\n"
         "90 degrees. Taking an optimized grid for the RT part and an equidistant\n"
         "grid for the scattering integral part saves very much CPU time.\n"
         "This method uses the equidistant za_grid defined in\n"
         "*DoitAngularGridsSet* and it should always be used for limb\n"
         "simulations.\n"
         "\n"
         "For more information please refer to AUG.\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT( "doit_scat_field" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "doit_scat_field", "pha_mat_spt_agenda",
            "doit_i_field", "pnd_field", "t_field", "atmosphere_dim", 
            "cloudbox_limits", "scat_za_grid", "scat_aa_grid",  
            "doit_za_grid_size", "doit_za_interp" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "DoitScatteringDataPrepare" ),
        DESCRIPTION
        (
         "Prepares single scattering data for a DOIT scattering calculation.\n"
         "\n"
         "First the scattering data is interpolated in frequency using\n"
         "*scat_data_array_monoCalc*. Then the phase matrix data is\n"
         "transformed or interpolated from the raw data to the laboratory frame\n"
         "for all possible combinations of the angles contained in the angular\n"
         "grids which are set in *DoitAngularGridsSet*. The resulting phase\n"
         "matrices are stored in *pha_mat_sptDOITOpt*.\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT( "pha_mat_sptDOITOpt", "scat_data_array_mono" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "doit_za_grid_size", "scat_aa_grid", "scat_data_array", "f_grid", 
            "f_index", "atmosphere_dim", "stokes_dim" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "DoitWriteIterationFields" ),
        DESCRIPTION
        (
         "Writes DOIT iteration fields.\n"
         "\n"
         "This method writes intermediate iteration fields to xml-files. The\n"
         "method can be used as a part of *doit_conv_test_agenda*.\n"
         "\n"
         "The iterations to be stored are specified by *iterations*, e.g.:\n"
         "    iterations = [3, 6, 9]\n"
         "In this case the 3rd, 6th and 9th iterations are stored in the\n"
         "files 'doit_iteration_3.xml', 'doit_iteration_6.xml' ...\n"
         "If a number is larger than the total number of iterations, this\n" 
         "number is ignored. If all iterations should be stored set\n"
         "   iterations = [0]\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT(),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "doit_iteration_counter", "doit_i_field" ),
        GIN( "iterations" ),
        GIN_TYPE( "ArrayOfIndex" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "See above." )
        ));

   md_data_raw.push_back
    ( MdRecord
      ( NAME( "doit_za_grid_optCalc" ),
        DESCRIPTION
        (
         "Zenith angle grid optimization for scattering calculation.\n"
         "\n"
         "This method optimizes the zenith angle grid. As input it requires\n"
         "a radiation field (*doit_i_field*) which is calculated on a very\n"
         "fine zenith angle grid (*scat_za_grid*). Based on this field\n"
         "zenith angle grid points are selected, such that the maximum\n"
         "difference between the radiation field represented on the very\n"
         "fine zenith angle grid and the radiation field represented on the\n"
         "optimized grid (*doit_za_grid_opt*) is less than the accuracy\n"
         "(*acc*). Between the grid points the radiation field is interpolated\n"
         "linearly or polynomially depending on *doit_za_interp*.\n"
         "\n"
         "Note: The method works only for a 1D atmosphere and for one\n"
         "frequency.\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT( "doit_za_grid_opt" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "doit_i_field", "scat_za_grid", "doit_za_interp" ),
        GIN( "acc" ),
        GIN_TYPE( "Numeric" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "Accuracy to achieve [%]." )
        ));
                                                                               
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "doit_za_interpSet" ),
        DESCRIPTION
        (
         "Define interpolation method for zenith angle dimension.\n"
         "\n"
         "You can use this method to choose the interpolation method for\n"
         "interpolations in the zenith angle dimension.\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT( "doit_za_interp" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atmosphere_dim" ),
        GIN( "interp_method" ),
        GIN_TYPE( "String" ),
        GIN_DEFAULT( "linear" ),
        GIN_DESC( "Interpolation method (\"linear\" or \"polynomial\")." )
        ));
 
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Error" ),
        DESCRIPTION
        (
         "Issues an error and exits ARTS.\n"
         "\n"
         "This method can be placed in agendas that must be specified, but\n"
         "are expected not to be used for the particular case. An inclusion\n"
         "in *surface_rtprop_agenda* could look like:\n   "
         "Error{\"Surface interceptions of propagation path not expected.\"}\n"
         "\n"
         "Ignore and other dummy method calls must still be included.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN( "msg" ),
        GIN_TYPE( "String" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "String describing the error." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Exit" ),
        DESCRIPTION
        (
         "Stops the execution and exits ARTS.\n"
         "\n"
         "This method is handy if you want to debug one of your control\n"
         "files. You can insert it anywhere in the control file. When\n"
         "it is reached, it will terminate the program.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Extract" ),
        DESCRIPTION
        (
         "Extracts an element from an array.\n"
         "\n"
         "Copies the element with the given Index from the input\n"
         "variable to the output variable.\n"
         "\n"
         "For a Tensor3 as an input, it copies the page with the given\n"
         "Index from the input Tensor3 variable to the output Matrix.\n"
         "\n"
         "In other words, the selection is always done on the first dimension.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT(),
        GOUT( "needle" ),
        GOUT_TYPE( "Index, ArrayOfIndex, Numeric, Vector,"
                   "Matrix, Matrix,"
                   "Tensor3, Tensor4, Tensor4,"
                   "GriddedField3, ArrayOfGriddedField3,"
                   "GriddedField4, String, SingleScatteringData" ),
        GOUT_DESC( "Extracted element." ),
        IN(),
        GIN( "haystack", "index" ),
        GIN_TYPE( "ArrayOfIndex, ArrayOfArrayOfIndex, Vector, ArrayOfVector,"
                  "ArrayOfMatrix, Tensor3,"
                  "Tensor4, ArrayOfTensor4, Tensor5,"
                  "ArrayOfGriddedField3, ArrayOfArrayOfGriddedField3,"
                  "ArrayOfGriddedField4, ArrayOfString, ArrayOfSingleScatteringData",
                  "Index" ),
        GIN_DEFAULT( NODEF, NODEF ),
        GIN_DESC( "Variable to extract from.",
                  "Position of the element which should be extracted." ),
        SETMETHOD(      false ),
        AGENDAMETHOD(   false ),
        USES_TEMPLATES( true  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "ext_matAddGas" ),
        DESCRIPTION
        (
         "Add gas absorption to all diagonal elements of extinction matrix.\n"
         "\n"
         "The task of this method is to sum up the gas absorption of the\n"
         "different gas species and add the result to the extinction matrix.\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT( "ext_mat" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "ext_mat", "propmat_clearsky" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "ext_matAddPart" ),
        DESCRIPTION
        (
         "The particle extinction is added to *ext_mat*\n"
         "\n"
         "This function sums up the extinction matrices for all particle\n"
         "types weighted with particle number density.\n"
         "The resulting extinction matrix is added to the workspace\n"
         "variable *ext_mat*\n"
         "The output of this method is *ext_mat* (stokes_dim, stokes_dim).\n"
         "The inputs are the extinction matrix for the single particle type\n"
         "*ext_mat_spt* (N_particletypes, stokes_dim, stokes_dim) and the local\n"
         "particle number densities for all particle types namely the\n"
         "*pnd_field* (N_particletypes, p_grid, lat_grid, lon_grid ) for given\n"
         "*p_grid*, *lat_grid*, and *lon_grid*. The particle types required\n"
         "are specified in the control file.\n"
         ),
        AUTHORS( "Sreerekha T.R." ),
        OUT( "ext_mat" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "ext_mat", "ext_mat_spt", "pnd_field", "atmosphere_dim", 
            "scat_p_index", "scat_lat_index", "scat_lon_index" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));
 
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "ext_matInit" ),
        DESCRIPTION
        (
         "Initialize extinction matrix.\n"
         "\n"
         "This method is necessary, because all other extinction methods just\n"
         "add to the existing extinction matrix.\n"
         "\n"
         "So, here we have to make it the right size and fill it with 0.\n"
         "\n"
         "Note, that the matrix is not really a matrix, because it has a\n"
         "leading frequency dimension.\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT( "ext_mat" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "f_grid", "stokes_dim", "f_index" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "FieldFromGriddedField" ),
        DESCRIPTION
        (
         "Extract the data from a GriddedField.\n"
         "\n"
         "A check is performed that the grids from the\n"
         "GriddedField match *p_grid*, *lat_grid* and *lon_grid*.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT(),
        GOUT( "out" ),
        GOUT_TYPE( "Matrix, Tensor3, Tensor4, Tensor4" ),
        GOUT_DESC( "Extracted field." ),
        IN( "p_grid", "lat_grid", "lon_grid" ),
        GIN( "in" ),
        GIN_TYPE( "GriddedField2, GriddedField3, GriddedField4, ArrayOfGriddedField3" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "Raw input gridded field." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "FlagOff" ),
        DESCRIPTION
        (
         "Sets an index variable that acts as an on/off flag to 0.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT( "flag" ),
        GOUT_TYPE( "Index" ),
        GOUT_DESC( "Variable to set to 0." ),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "FlagOn" ),
        DESCRIPTION
        (
         "Sets an index variable that acts as an on/off flag to 1.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT( "flag" ),
        GOUT_TYPE( "Index" ),
        GOUT_DESC( "Variable to set to 1." ),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "ForLoop" ),
        DESCRIPTION
        (
         "A simple for-loop.\n"
         "\n"
         "This method is handy when you quickly want to test out a calculation\n"
         "with a set of different settings.\n"
         "\n"
         "It does a for-loop from start to stop in steps of step (who would\n"
         "have guessed that). For each iteration, the agenda *forloop_agenda* is\n"
         "executed. Inside the agenda, the variable *forloop_index* is available\n"
         "as index counter.\n"
         "\n"
         "There are no other inputs to *forloop_agenda*, and also no outputs. That\n"
         "means, if you want to get any results out of this loop, you have to\n"
         "save it to files (for example with *WriteXMLIndexed*), since\n"
         "variables used inside the agenda will only be local.\n"
         "\n"
         "Note that this kind of for loop is not parallel.\n"
         "\n"
         "The method is intended for simple testing, not as a replacement of\n"
         "*ybatchCalc*. However, it is compatible with *ybatchCalc*, in the sense\n"
         "that *ybatchCalc* may occur inside *forloop_agenda*.\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT(),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "forloop_agenda" ),
        GIN( "start", "stop",  "step" ),
        GIN_TYPE(    "Index", "Index", "Index" ),
        GIN_DEFAULT( NODEF,   NODEF,   NODEF ),
        GIN_DESC( "Start value.",
                  "End value.",
                  "Step size." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "FrequencyFromWavelength" ),
        DESCRIPTION
        (
         "Convert from wavelength [m] to frequency [Hz].\n"
         "\n"
         "This is a generic method. It can take a single wavelength value or a wavelength vector as input.\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT(),
        GOUT("frequency"),
        GOUT_TYPE("Numeric, Vector"),
        GOUT_DESC("frequency [Hz]"),
        IN(),
        GIN( "wavelength"),
        GIN_TYPE("Numeric, Vector" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC("wavelength [m]" )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "f_gridFromGasAbsLookup" ),
        DESCRIPTION
        (
         "Sets *f_grid* to the frequency grid of *abs_lookup*.\n"
         "\n"
         "Must be called between importing/creating raw absorption table and\n"
         "call of *abs_lookupAdapt*.\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT( "f_grid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_lookup" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "f_gridFromSensorAMSU" ),
        DESCRIPTION
        (
         "Automatically calculate f_grid to match the sensor.\n"
         "\n"
         "This method is handy if you are simulating an AMSU-type instrument,\n"
         "consisting of a few discrete channels. The case that channels touch,\n"
         "as for MHS, is handled correctly. But the case that channels overlap\n"
         "is not (yet) handled and results in an error message.\n"
         "\n"
         "The method calculates *f_grid* to match the instrument, as given by\n"
         "the local oscillator frequencies *lo_multi*, the backend\n"
         "frequencies *f_backend_multi*, and the backend channel\n"
         "responses *backend_channel_response_multi*.\n"
         "\n"
         "You have to specify the desired spacing in the keyword *spacing*,\n"
         "which has a default value of 100 MHz. (The actual value is 0.1e9,\n"
         "since our unit is Hz.)\n"
         "\n"
         "The produced grid will not have exactly the requested spacing, but\n"
         "will not be coarser than requested. The algorithm starts with the band\n"
         "edges, then adds additional points until the spacing is at least as\n"
         "fine as requested.\n"
         "\n"
         "There is a similar method for HIRS-type instruments,\n"
         "see *f_gridFromSensorHIRS*.\n"
         ),
        AUTHORS( "Stefan Buehler, Mathias Milz" ),
        OUT( "f_grid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "lo_multi", "f_backend_multi", "backend_channel_response_multi" ),
        GIN( "spacing" ),
        GIN_TYPE(    "Numeric" ),
        GIN_DEFAULT( ".1e9" ),
        GIN_DESC( "Desired grid spacing in Hz." )
        ));
  

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "f_gridFromSensorAMSUgeneric" ),
        DESCRIPTION
        (
         "Automatcially calculate f_grid to match the sensor. \n"
         "This function is based on 'f_gridFromSensorAMSU' \n"
         "\n"
         "The method calculates *f_grid* to match the instrument, as given by\n"
         "the backend frequencies *f_backend*, and the backend channel\n"
         "responses *backend_channel_response*.\n"
         "\n"
         "You have to specify the desired spacing in the keyword *spacing*,\n"
         "which has a default value of 100 MHz. (The actual value is 0.1e9,\n"
         "since our unit is Hz.)"
         "\n"
         "The produced grid will not have exactly the requested spacing, but\n"
         "it will not be coarser than requested. The algorithm starts with the band\n"
         "edges, then adds additional points until the spacing is at least as\n"
         "fine as requested.\n"
         ),
        AUTHORS( "Oscar Isoz" ),
        OUT( "f_grid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "f_backend_multi","backend_channel_response_multi" ),
        GIN( "spacing","verbosityVect"),
        GIN_TYPE(    "Numeric","Vector"),
        GIN_DEFAULT( ".1e9","[]"),
        GIN_DESC( "Desired grid spacing in Hz.","Bandwidth adjusted spacing")
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "f_gridFromSensorHIRS" ),
        DESCRIPTION
        (
         "Automatically calculate f_grid to match the sensor.\n"
         "\n"
         "This method is handy if you are simulating a HIRS-type instrument,\n"
         "consisting of a few discrete channels.\n"
         "\n"
         "It calculates f_grid to match the instrument, as given by the nominal\n"
         "band frequencies *f_backend* and the spectral channel response\n"
         "functions given by *backend_channel_response*.\n"
         "\n"
         "You have to specify the desired spacing in the keyword *spacing*, which\n"
         "has a default value of 5e8 Hz.\n"
         "\n"
         "The produced grid will not have exactly the requested spacing, but\n"
         "will not be coarser than requested. The algorithm starts with the band\n"
         "edges, then adds additional points until the spacing is at least as\n"
         "fine as requested.\n"
         "\n"
         "There is a similar method for AMSU-type instruments, see\n"
         "*f_gridFromSensorAMSU*.\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT( "f_grid" ),
        GOUT(),
        GOUT_TYPE( ),
        GOUT_DESC(),
        IN( "f_backend", "backend_channel_response" ),
        GIN( "spacing" ),
        GIN_TYPE( "Numeric" ),
        GIN_DEFAULT( "5e8" ),
        GIN_DESC( "Desired grid spacing in Hz." )
        ));
  
  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "g0Earth" ),
        DESCRIPTION
        (
         "Gravity at zero altitude on Earth.\n"
         "\n"
         "Sets *g0* for the given latitude using a standard parameterisation.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "g0" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "lat" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "g0Jupiter" ),
        DESCRIPTION
        (
         "Gravity at zero altitude on Jupiter.\n"
         "\n"
         "Sets *g0*  to mean equatorial gravity on Jupiter. Value provided by\n"
         "MPS under ESA-planetary study (TN1).\n"
         ),
        AUTHORS( "Jana Mendrok" ),
        OUT( "g0" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "g0Mars" ),
        DESCRIPTION
        (
         "Gravity at zero altitude on Mars.\n"
         "\n"
         "Sets *g0*  to mean equatorial gravity on Mars. Value provided by\n"
         "MPS under ESA-planetary study (TN1).\n"
         ),
        AUTHORS( "Jana Mendrok" ),
        OUT( "g0" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "g0Venus" ),
        DESCRIPTION
        (
         "Gravity at zero altitude on Venus.\n"
         "\n"
         "Sets *g0*  to mean equatorial gravity on Venus. Value from Ahrens\n"
         "(1995), provided by MPS under ESA-planetary study (TN1).\n"
         ),
        AUTHORS( "Jana Mendrok" ),
        OUT( "g0" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "GriddedFieldLatLonExpand" ),
        DESCRIPTION
        (
         "Expands the latitude and longitude grid of the GriddedField to\n"
         "[-90, 90] and [0,360], respectively. Expansion is only done in\n"
         "the dimension(s), where the grid size is 1.\n"
         "The values from the input data will be duplicated to accomodate\n"
         "for the larger size of the output field.\n"
         "gfield_raw_out and gfield_raw_in can be the same variable.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT(),
        GOUT( "out" ),
        GOUT_TYPE( "GriddedField2, GriddedField3, GriddedField4, ArrayOfGriddedField3" ),
        GOUT_DESC( "Expanded gridded field." ),
        IN(),
        GIN( "in" ),
        GIN_TYPE( "GriddedField2, GriddedField3, GriddedField4, ArrayOfGriddedField3" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "Raw input gridded field." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "GriddedFieldLatLonRegrid" ),
        DESCRIPTION
        (
         "Interpolates the input field along the latitude and longitude dimensions\n"
         "to *lat_true* and *lon_true*.\n"
         "\n"
         "If the input longitude grid is outside of *lon_true* it will be shifted\n"
         "left or right by 360. If it covers 360 degrees, a cyclic interpolation\n"
         "will be performed.\n"
         "in and out fields can be the same variable.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT(),
        GOUT( "out" ),
        GOUT_TYPE( "GriddedField2, GriddedField3, GriddedField4, ArrayOfGriddedField3" ),
        GOUT_DESC( "Regridded gridded field." ),
        IN( "lat_true", "lon_true" ),
        GIN( "in", "interp_order" ),
        GIN_TYPE( "GriddedField2, GriddedField3, GriddedField4, ArrayOfGriddedField3",
                  "Index" ),
        GIN_DEFAULT( NODEF, "1" ),
        GIN_DESC( "Raw input gridded field.",
                  "Interpolation order." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "GriddedFieldPRegrid" ),
        DESCRIPTION
        (
         "Interpolates the input field along the pressure dimension to *p_grid*.\n"
         "\n"
         "If zero-padding is applied (zeropadding=1), pressures that are\n"
         "outside the *p_grid* are set to 0. This is thought, e.g., for VMR\n"
         "fields that outside the given pressure can safely be assumed to be\n"
         "zero.\n"
         "Note: Using zeropadding for altitude and temperature fields is\n"
         "strongly discouraged (it will work here, though, but likely trigger\n"
         "errors later on).\n"
         "Extrapolation is allowed within the common 0.5grid-step margin,\n"
         "but is overruled by zeropadding.\n"
         "in and out fields can be the same variable.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT(),
        GOUT( "out" ),
        GOUT_TYPE( "GriddedField3, GriddedField4, ArrayOfGriddedField3" ),
        GOUT_DESC( "Regridded gridded field." ),
        IN( "p_grid" ),
        GIN( "in", "interp_order", "zeropadding" ),
        GIN_TYPE( "GriddedField3, GriddedField4, ArrayOfGriddedField3",
                  "Index",
                  "Index" ),
        GIN_DEFAULT( NODEF, "1", "0" ),
        GIN_DESC( "Raw input gridded field.",
                  "Interpolation order.",
                  "Apply zero-padding." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Ignore" ),
        DESCRIPTION
        (
         "Ignore a workspace variable.\n"
         "\n"
         "This method is handy for use in agendas in order to suppress warnings\n"
         "about unused input workspace variables. What it does is: Nothing!\n"
         "In other words, it just ignores the variable it is called on.\n"
         "\n"
         "This method can ignore any workspace variable\n"
         "you want.\n"
         "\n"
         "Usage example:\n"
         "\n"
         "AgendaSet(els_agenda){\n"
         "  Ignore(ls_sigma)\n"
         "  elsLorentz\n"
         "}\n"
         "\n"
         "Without Ignore you would get an error message, because 'els_agenda' is\n"
         "supposed to use the Doppler width 'ls_sigma', but the Lorentz lineshape\n"
         "'elsLorentz' does not need it.\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT(),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(       "in"    ),
        GIN_TYPE(     "Any" ),
        GIN_DEFAULT(  NODEF ),
        GIN_DESC( "Variable to be ignored." ),
        SETMETHOD(      false ),
        AGENDAMETHOD(   false ),
        USES_TEMPLATES( true  )
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "INCLUDE" ),
        DESCRIPTION
        (
         "Includes the contents of another controlfile.\n"
         "\n"
         "The INCLUDE statement inserts the contents of the controlfile\n"
         "with the given name into the current controlfile.\n"
         "If the filename is given without path information, ARTS will\n"
         "first search for the file in all directories specified with the\n"
         "-I (see arts -h) commandline option and then in directories given\n"
         "in the environment variable ARTS_INCLUDE_PATH. In the environment\n"
         "variable multiple paths have to be separated by colons.\n"
         "\n"
         "Note that INCLUDE is not a workspace method and thus the\n"
         "syntax is different:\n"
         "\n"
         "Arts {\n"
         "  INCLUDE \"general.arts\"\n"
         "}\n"
         "\n"
         "Includes can also be nested. In the example above general.arts\n"
         "can contain further includes which will then be treated\n"
         "the same way.\n"
         "\n"
         "The idea behind this mechanism is that you can write common settings\n"
         "for a bunch of calculations into one file. Then, you can create\n"
         "several controlfiles which include the basic settings and tweak them\n"
         "for different cases. When you decide to make changes to your setup\n"
         "that should apply to all calculations, you only have to make a\n"
         "single change in the include file instead of modifying all your\n"
         "controlfiles.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT(),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "IndexSet" ),
        DESCRIPTION
        (
         "Sets an index workspace variable to the given value.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT(      "out"     ),
        GOUT_TYPE( "Index" ),
        GOUT_DESC( "Variable to initialize." ),
        IN(),
        GIN(       "value" ),
        GIN_TYPE(  "Index" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "Value." ),
        SETMETHOD( true )
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "IndexStepDown" ),
        DESCRIPTION
        (
         "Performas: out = in - 1\n"
         "\n"
         "Input and output can be same variable.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT(      "out"    ),
        GOUT_TYPE( "Index" ),
        GOUT_DESC( "Output index variable." ),
        IN(),
        GIN(       "in"  ),
        GIN_TYPE(  "Index" ),
        GIN_DEFAULT( NODEF   ),
        GIN_DESC( "Input index variable." )
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "IndexStepUp" ),
        DESCRIPTION
        (
         "Performas: out = in + 1\n"
         "\n"
         "Input and output can be same variable.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT(      "out"    ),
        GOUT_TYPE( "Index" ),
        GOUT_DESC( "Output index variable." ),
        IN(),
        GIN(       "in"  ),
        GIN_TYPE(  "Index" ),
        GIN_DEFAULT( NODEF   ),
        GIN_DESC( "Input index variable." )
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "InterpAtmFieldToPosition" ),
        DESCRIPTION
        (
         "Point interpolation of atmospheric fields.\n" 
         "\n"
         "The default way to specify the position is by *rtp_pos*.\n"
         "\n"
         "Linear interpolation is applied.\n"         
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT(      "out"       ),
        GOUT_TYPE( "Numeric" ),
        GOUT_DESC( "Value obtained by the interpolation." ),
        IN( "atmosphere_dim", "p_grid", "lat_grid", "lon_grid", "z_field",
            "rtp_pos" ),
        GIN( "field"),
        GIN_TYPE( "Tensor3" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "Field to interpolate." )
        ));
  
  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "InterpSurfaceFieldToPosition" ),
        DESCRIPTION
        (
         "Point interpolation of surface fields.\n" 
         "\n"
         "The default way to specify the position is by *rtp_pos*.\n"
         "\n"
         "Linear interpolation is applied.\n" 
         "\n"
         "The interpolation is done for the latitude and longitude in\n"
         "*rtp_pos*, while the altitude in *rtp_pos* is not part of the\n"
         "calculations. However, it is checked that the altitude of *rtp_pos*\n"
         "is inside the range covered by *z_surface* with a 1 m margin, to\n"
         "give a warning when the specified position is not consistent with\n"
         "the surface altitudes.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT( "out" ),
        GOUT_TYPE( "Numeric" ),
        GOUT_DESC( "Value obtained by interpolation." ),
        IN( "atmosphere_dim", "lat_grid", "lon_grid", "rtp_pos", "z_surface" ),
        GIN( "field" ),
        GIN_TYPE( "Matrix" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "Field to interpolate." )
        ));
  
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "isotopologue_ratiosInitFromBuiltin" ),
        DESCRIPTION
        (
         "Initialize isotopologue ratios with default values from built-in\n"
         "species data.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( "isotopologue_ratios" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "iyApplyUnit" ),
        DESCRIPTION
        (
         "Conversion of *iy* to other spectral units.\n"
         "\n"
         "The method allows a change of unit, as a post-processing step,\n"
         "ignoring the n2-law of radiance.\n"
         "\n"         
         "The conversion made inside *iyEmissionStandard* is mimiced,\n"
         "see that method for constraints and selection of output units.\n"
         "Restricted to that the n2-law can be ignored. This assumption\n"
         "is valid if the sensor is placed in space, or if the refractive\n"
         "index only deviates slightly from unity.\n"
         "\n"
         "It is stressed that there is no automatic check that the method is\n"
         "applied correctly, it is up to the user to ensure that the input\n"
         "data are suitable for the conversion.\n"
         "\n"
         "Beside *iy*, these auxilary quantities are modified:\n"
         "    \"iy\", \"Error\" and \"Error (uncorrelated)\"\n"
         "\n"
         "Please note that *diy_dx* is not handled.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "iy", "iy_aux" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "iy", "iy_aux", "stokes_dim", "f_grid", "iy_aux_vars", "iy_unit" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord

      ( NAME( "iyCalc" ),
        DESCRIPTION
        (
         "A single monochromatic pencil beam calculation.\n"
         "\n"
         "Performs monochromatic radiative transfer calculations for the\n"
         "specified position (*rte_pos*) and line-of-sight (*rte_pos*).\n"
         "See *iy* and associated variables for format of output.\n"
         "\n"
         "Please note that Jacobian type calculations not are supported.\n"
         "For this use *yCalc*.\n"
         "\n"
         "No sensor characteristics are applied. These are most easily\n"
         "incorporated by using *yCalc*\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "iy", "iy_aux", "ppath" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atmgeom_checked", "atmfields_checked", 
            "iy_aux_vars", "f_grid", "t_field", 
            "z_field", "vmr_field", "cloudbox_on", "cloudbox_checked", 
            "rte_pos", "rte_los", "rte_pos2", "iy_main_agenda" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "iyCloudRadar" ),
        DESCRIPTION
        (
         "Simulation of cloud radars, restricted to single scattering.\n"
         "\n"
         "The WSM treats radar measurements of cloud and precipitation, on\n"
         "the condition that multiple scattering can be ignored. Beside the\n"
         "direct backsacttering, the two-way attenuation by gases and\n"
         "particles is considered. Surface scattering is ignored. Further\n"
         "details are given in AUG.\n"
         "\n"
         "The method could potentially be used for lidars, but multiple\n"
         "scattering poses here a must stronger constrain for the range of\n"
         "applications.\n"
         "\n"
         "The method can be used with *iyCalc*, but not with *yCalc*. In the\n" 
         "later case, use instead *yCloudRadar*.\n"
         "\n"
         "The method returns the backscattering for each point of *ppath*.\n"
         "Several frequencies can be treated in parallel. The size of *iy*\n"
         "is [ nf*np, stokes_dim ], where nf is the length of *f_grid* and\n"
         "np is the number of path points. The data are stored in blocks\n"
         "of [ np, stokes_dim ]. That is, all the results for the first\n"
         "frequency occupy the np first rows of *iy* etc.\n"
         "\n"
         "The polarisation state of the transmitted pulse is taken from\n"
         "*iy_transmitter_agenda*, see further *iy_transmitterCloudRadar*\n"
         "If the radar transmits several polarisations at the same frequency,\n"
         "you need to handle this by using two frequencies in *f_grid*, but\n"
         "but these can be almost identical.\n"
         "\n"
         "The options *iy_unit* are:\n"
         " \"1\"  : Backscatter coefficient. Unit is 1/(m*sr). Without\n"
         "          attenuation, this equals the scattering matrix value for\n"
         "          the backward direction. See further AUG.\n"
         " \"Ze\" : Equivalent reflectivity. I the conversion, \"K\" is\n"
         "          calculated using the refractive index for liquid water,\n"
         "          at the temperature defined by *ze_tref*.\n"
         "\n"
         "No Jacobian quantities are yet handled.\n"
         "\n"
         "The following auxiliary data can be obtained:\n"
         "  \"Pressure\": The pressure along the propagation path.\n"
         "     Size: [1,1,1,np].\n"
         "  \"Temperature\": The temperature along the propagation path.\n"
         "     Size: [1,1,1,np].\n"
         "  \"Backscattering\": The un-attenuated backscattering. Unit\n"
         "     follows *iy_unit*. Size: [nf,ns,1,np].\n"
         "  \"Transmission\": The single-way transmission matrix from the\n"
         "     transmitter to each propagation path point. The matrix is\n"
         "     valid for the photon direction. Size: [nf,ns,ns,np].\n"
         "  \"Round-trip time\": The time for the pulse to propagate. For a \n"
         "     totally correct result, refraction must be considered (in\n"
         "     *pppath_agenda*). Size: [1,1,1,np].\n"
         "  \"PND, type X\": The particle number density for particle type X\n"
         "       (ie. corresponds to book X in pnd_field). Size: [1,1,1,np].\n"
         "  \"Mass content, X\": The particle content for mass category X.\n"
         "       This corresponds to column X in *particle_masses* (zero-\n"
         "       based indexing). Size: [1,1,1,np].\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "iy", "iy_aux", "ppath" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "stokes_dim", "f_grid", "atmosphere_dim", "p_grid", "z_field",
            "t_field", "vmr_field", 
            "wind_u_field", "wind_v_field", "wind_w_field", "mag_u_field",
            "mag_v_field", "mag_w_field", "cloudbox_on", 
            "cloudbox_limits", "pnd_field", "use_mean_scat_data",
            "scat_data_array", "particle_masses",
            "iy_unit", "iy_aux_vars", "jacobian_do", "ppath_agenda", 
            "propmat_clearsky_agenda", "iy_transmitter_agenda",
            "iy_agenda_call1", "iy_transmission", "rte_pos", "rte_los",
            "rte_alonglos_v", "ppath_lraytrace" ),
        GIN(      "ze_tref" ),
        GIN_TYPE( "Numeric" ),
        GIN_DEFAULT( "273.15"  ),
        GIN_DESC( "Reference temperature for conversion to Ze" )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "iyEmissionStandard" ),
        DESCRIPTION
        (
         "Standard method for radiative transfer calculations with emission.\n"
         "\n"
         "Designed to be part of *iy_main_agenda*. That is, only valid\n"
         "outside the cloudbox (no scattering). Assumes local thermodynamic\n"
         "equilibrium for emission. The basic calculation strategy is to take\n"
         "the average of the absorption and the emission source function at\n"
         "the end points of each step of the propagation path. For details\n"
         "see the user guide.\n" 
         "\n"
         "The internal radiance unit is determined by your definition of\n"
         "blackbody radiation inside the atmospheric and surface source\n" 
         "terms. Set *iy_unit* to \"1\" if you want this to also be the unit\n"
         "for output radiances. If you want another output unit, you need to\n"
         "make sure that the internal unit is [W/m2/Hz/sr] (ie. the frequency\n"
         "version of the Planck function). The possible choices for *iy_unit*\n"
         "are:\n"
         " \"1\"             : No conversion.\n"
         " \"RJBT\"          : Conversion to Rayleigh-Jean brightness\n"
         "                     temperature.\n"
         " \"PlanckBT\"      : Conversion to Planck brightness temperature.\n"
         " \"W/(m^2 m sr)\"  : Conversion to [W/(m^2 m sr)] (radiance per\n"
         "                     wavelength unit).\n"
         " \"W/(m^2 m-1 sr)\": Conversion to [W/(m^2 m-1 sr)] (radiance per\n"
         "                     wavenumber unit).\n"
         "\n"
         "Please note that there is no way for ARTS to strictly check the\n"
         "internal unit. In principle, the unit can differ between the\n"
         "elements. The user must makes sure that any unit conversion is\n"
         "applied correctly, and in accordance with the calibration of the\n"
         "instrument of concern. Expressions applied and considerations for\n"
         "the unit conversion of radiances are discussed in Sec. 5.7 of the\n"
         "ARTS-2 article.\n"
         "\n"
         "The following auxiliary data can be obtained:\n"
         "  \"Pressure\": The pressure along the propagation path.\n"
         "     Size: [1,1,1,np].\n"
         "  \"Temperature\": The temperature along the propagation path.\n"
         "     Size: [1,1,1,np].\n"
         "  \"VMR, species X\": VMR of the species with index X (zero based).\n"
         "     For example, adding the string \"VMR, species 0\" extracts the\n"
         "     VMR of the first species. Size: [1,1,1,np].\n"
         "  \"Absorption, summed\": The total absorption matrix along the\n"
         "     path. Size: [nf,ns,ns,np].\n"
         "  \"Absorption, species X\": The absorption matrix along the path\n"
         "     for an individual species (X works as for VMR).\n"
         "     Size: [nf,ns,ns,np].\n"
         "* \"Radiative background\": Index value flagging the radiative\n"
         "     background. The following coding is used: 0=space, 1=surface\n"
         "     and 2=cloudbox. Size: [nf,1,1,1].\n"
         "  \"iy\": The radiance at each point along the path (*iy_unit* is.\n"
         "     considered). Size: [nf,ns,1,np].\n"
         "  \"Transmission\": The transmission matrix from the surface, space\n"
         "     or cloudbox, to each propagation path point. The matrix is\n"
         "     valid for the photon direction. Size: [nf,ns,ns,np].\n"
         "* \"Optical depth\": The scalar optical depth between the\n"
         "     observation point and the end of the primary propagation path\n"
         "     (ie. the optical depth to the surface or space.). Calculated\n"
         "     in a pure scalar manner, and not dependent on direction.\n"
         "     Size: [nf,1,1,1].\n"
         "where\n"
         "  nf: Number of frequencies.\n"
         "  ns: Number of Stokes elements.\n"
         "  np: Number of propagation path points.\n"
         "\n"
         "The auxiliary data are returned in *iy_aux* with quantities\n"
         "selected by *iy_aux_vars*. Most variables require that the method\n"
         "is called directly or by *iyCalc*. For calculations using *yCalc*,\n"
         "the selection is restricted to the variables marked with *.\n"
         "\n"
         "In addition, these choices are accepted but no calculations are\n"
         "done:\n"
         "  \"PND, type X\": Size: [0,0,0,0].\n"
         "  \"Mass content, X\": Size: [0,0,0,0].\n"
         "See e.g. *iyTransmissionStandard* for a definition of these\n"
         "variables. To fill these elements of *iy_aux* (after calling\n"
         "this WSM), use *iy_auxFillParticleVariables*.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "iy", "iy_aux", "ppath", "diy_dx" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "stokes_dim", "f_grid", "atmosphere_dim", "p_grid", "z_field",
            "t_field", "vmr_field", "abs_species", 
            "wind_u_field", "wind_v_field", "wind_w_field", "mag_u_field",
            "mag_v_field", "mag_w_field", 
            "cloudbox_on", "iy_unit", "iy_aux_vars", "jacobian_do", 
            "jacobian_quantities", "jacobian_indices", 
            "ppath_agenda", "blackbody_radiation_agenda",
            "propmat_clearsky_agenda", "iy_main_agenda", 
            "iy_space_agenda", "iy_surface_agenda", "iy_cloudbox_agenda", 
            "iy_agenda_call1", "iy_transmission", "rte_pos", "rte_los", 
            "rte_pos2", "rte_alonglos_v", "ppath_lraytrace" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "iyFOS" ),
        DESCRIPTION
        (
         "Method in development. Don't use without contacting Patrick.\n"
         "\n"
         "Regarding radiance unit, works exactly as *iyEmissionStandard*.\n"
         "\n"
         "The *fos_n* argument determines the maximum scattering order that\n"
         "will be considered. For example, 1 corresponds to that only single\n"
         "scattering is considered. The value 0 is accepted and results\n"
         "in calculations of clear-sky type. In the later case, particle\n"
         "absorption/emission is considered if cloudbox is active. If\n"
         "cloudbox is not active,clear-sky results are returned for all\n"
         "values of *fos_n*.\n"
         "\n"
         "The following auxiliary data can be obtained:\n"
         "  \"Pressure\": The pressure along the propagation path.\n"
         "     Size: [1,1,1,np].\n"
         "  \"Temperature\": The temperature along the propagation path.\n"
         "     Size: [1,1,1,np].\n"
         "  \"VMR, species X\": VMR of the species with index X (zero based).\n"
         "     For example, adding the string \"VMR, species 0\" extracts the\n"
         "     VMR of the first species. Size: [1,1,1,np].\n"
         "  \"Absorption, summed\": The total absorption matrix along the\n"
         "     path. Size: [nf,ns,ns,np].\n"
         "  \"Absorption, species X\": The absorption matrix along the path\n"
         "     for an individual species (X works as for VMR).\n"
         "     Size: [nf,ns,ns,np].\n"
         "  \"PND, type X\": The particle number density for particle type X\n"
         "       (ie. corresponds to book X in pnd_field). Size: [1,1,1,np].\n"
         "  \"Mass content, X\": The particle content for mass category X.\n"
         "       This corresponds to column X in *particle_masses* (zero-\n"
         "       based indexing). Size: [1,1,1,np].\n"
         "* \"Radiative background\": Index value flagging the radiative\n"
         "     background. The following coding is used: 0=space and\n"
         "     and 1=surface. Size: [nf,1,1,1].\n"
         "  \"iy\": The radiance at each point along the path (*iy_unit* is.\n"
         "     considered). Size: [nf,ns,1,np].\n"
         "* \"Optical depth\": The scalar optical depth between the\n"
         "     observation point and the end of the primary propagation path\n"
         "     (ie. the optical depth to the surface or space.). Calculated\n"
         "     in a pure scalar manner, and not dependent on direction.\n"
         "     Size: [nf,1,1,1].\n"
         "where\n"
         "  nf: Number of frequencies.\n"
         "  ns: Number of Stokes elements.\n"
         "  np: Number of propagation path points.\n"
         "\n"
         "The auxiliary data are returned in *iy_aux* with quantities\n"
         "selected by *iy_aux_vars*. Most variables require that the method\n"
         "is called directly or by *iyCalc*. For calculations using *yCalc*,\n"
         "the selection is restricted to the variables marked with *.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "iy", "iy_aux", "ppath", "diy_dx" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "stokes_dim", "f_grid", "atmosphere_dim", "p_grid", "z_field",
            "t_field", "vmr_field", "abs_species", 
            "wind_u_field", "wind_v_field", "wind_w_field", "mag_u_field",
            "mag_v_field", "mag_w_field", "cloudbox_on", "cloudbox_limits",
            "pnd_field", "use_mean_scat_data", "scat_data_array",
            "particle_masses", "iy_unit", "iy_aux_vars", "jacobian_do", 
            "ppath_agenda", "blackbody_radiation_agenda",
            "propmat_clearsky_agenda", "iy_main_agenda", "iy_space_agenda", 
            "iy_surface_agenda", "iy_agenda_call1", "iy_transmission", 
            "rte_pos", "rte_los", "rte_pos2", "rte_alonglos_v", "ppath_lraytrace",
            "fos_scatint_angles", "fos_iyin_za_angles"
            ),
        GIN( "fos_za_interporder", "fos_n" ),
        GIN_TYPE( "Index", "Index" ),
        GIN_DEFAULT( "1", "1" ),
        GIN_DESC( "Polynomial order for zenith angle interpolation.",
                  "Max scattering order to consider." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "iyMC" ),
        DESCRIPTION
        (
         "Interface to Monte Carlo part for *iy_main_agenda*.\n"
         "\n"
         "Basically an interface to *MCGeneral* for doing monochromatic\n"
         "pencil beam calculations. This functions allows Monte Carlo (MC)\n"
         "calculations for sets of frequencies and sensor pos/los in a single\n"
         "run. Sensor responses can be included in the standard manner\n" 
         "(through *yCalc*).\n"
         "\n"
         "This function does not apply the MC approach when it comes\n"
         "to sensor properties. These properties are not considered when\n"
         "tracking photons, which is done in *MCGeneral* (but then only for\n"
         "the antenna pattern).\n"
         "\n"
         "Output unit options  (*iy_unit*) exactly as for *MCGeneral*.\n"
         "\n"
         "The MC calculation errors are all assumed be uncorrelated and each\n"
         "have a normal distribution. These properties are of relevance when\n"
         "weighting the errors with the sensor repsonse matrix. The seed is\n"
         "reset for each call of *MCGeneral* to obtain uncorrelated errors.\n"
         "\n"
         "MC control arguments (mc_std_err, mc_max_time, mc_min_iter and\n"
         "mc_mas_iter) as for *MCGeneral*. The arguments are applied\n"
         "for each monochromatic pencil beam calculation individually.\n"
         "As or *MCGeneral*, the value of *mc_error* shall be adopted to\n"
         "*iy_unit*.\n"
         "\n"
         "The following auxiliary data can be obtained:\n"
         "  \"Error (uncorrelated)\": Calculation error. Size: [nf,ns,1,1].\n"
         "    (The later part of the text string is required. It is used as\n"
         "    a flag to yCalc for how to apply the sensor data.)\n"
         "where\n"
         "  nf: Number of frequencies.\n"
         "  ns: Number of Stokes elements.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "iy", "iy_aux", "diy_dx" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "iy_agenda_call1", "iy_transmission", "rte_pos", "rte_los", 
            "iy_aux_vars", "jacobian_do", "atmosphere_dim", "p_grid", 
            "lat_grid", "lon_grid", "z_field", "t_field", "vmr_field", 
            "refellipsoid", 
            "z_surface", "cloudbox_on", "cloudbox_limits",
            "stokes_dim", "f_grid", "scat_data_array", "iy_space_agenda", 
            "surface_rtprop_agenda", "propmat_clearsky_agenda",
            "ppath_step_agenda", "ppath_lraytrace", "pnd_field", "iy_unit",
            "mc_std_err", "mc_max_time", "mc_max_iter", "mc_min_iter" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "iyInterpCloudboxField" ),
        DESCRIPTION
        (
         "Interpolates the intensity field of the cloud box.\n"
         "\n"
         "This is the standard method to put in *iy_cloudbox_agenda* if the\n"
         "the scattering inside the cloud box is handled by the DOIT method.\n"
         "\n"
         "The intensity field is interpolated to the position (specified by\n"
         "*rtp_pos*) and direction (specified by *rtp_los*) given. A linear\n"
         "interpolation is used for all dimensions.\n"
         "\n"
         "The intensity field on the cloux box boundaries is provided by\n"
         "*scat_i_p/lat/lon* and these variables are interpolated if the\n"
         "given position is at any boundary.\n"
         "\n"
         "Interpolation of the internal field is not yet possible.\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT( "iy" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "scat_i_p", "scat_i_lat", "scat_i_lon", "doit_i_field1D_spectrum",
            "rtp_pos", "rtp_los", "jacobian_do","cloudbox_on", 
            "cloudbox_limits", "atmosphere_dim", "p_grid", "lat_grid",
            "lon_grid", "z_field", "stokes_dim", 
            "scat_za_grid", "scat_aa_grid", "f_grid" ),
        GIN( "rigorous", "maxratio" ),
        GIN_TYPE( "Index", "Numeric" ),
        GIN_DEFAULT( "1", "3" ),
        GIN_DESC( "Fail if cloudbox field is not safely interpolable.",
                  "Maximum allowed ratio of two radiances regarded as interpolable." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "iyInterpPolyCloudboxField" ),
        DESCRIPTION
        (
         "As *iyInterpCloudboxField* but performs cubic interpolation.\n"
         "\n"
         "Works so far only for 1D cases, and accordingly a cubic\n"
         "interpolation along *scat_za_grid* is performed.\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT( "iy" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "scat_i_p", "scat_i_lat", "scat_i_lon", "doit_i_field1D_spectrum",
            "rtp_pos", "rtp_los", "jacobian_do", "cloudbox_on", 
            "cloudbox_limits", "atmosphere_dim", "p_grid", "lat_grid",
            "lon_grid", "z_field", "stokes_dim", "scat_za_grid", 
            "scat_aa_grid", "f_grid" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "iyLoopFrequencies" ),
        DESCRIPTION
        (
         "Radiative transfer calculations one frequency at the time.\n"
         "\n"
         "The method loops the frequencies in *f_grid* and calls\n"
         "*iy_sub_agenda* for each individual value. This method is placed\n"
         "in *iy_main_agenda*, and the actual radiative ransfer method is\n"
         "put in *iy_sub_agenda*.\n"
         "\n"
         "A common justification for using the method should be to consider\n"
         "dispersion. By using this method it is ensured that the propagation\n"
         "path for each individual frequency is calculated.\n"
         "\n"
         "Auxiliary data (defined by *iy_aux_vars*) can not contain along-\n"
         "the-path quantities (a common ppath is not ensured). The returned\n"
         "*ppath* is valid for the last frequency.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "iy", "iy_aux", "ppath", "diy_dx" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "iy_aux_vars", "stokes_dim", "f_grid", "t_field", "z_field", 
            "vmr_field", "cloudbox_on", "iy_agenda_call1", "iy_transmission",
            "rte_pos", "rte_los", "rte_pos2", "jacobian_do", "iy_sub_agenda" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "iyRadioLink" ),
        DESCRIPTION
        (
         "Radiative transfer for (active) radio links.\n"
         "\n"
         "The method assumes that *ppath*agenda* is set up to return the\n"
         "propagation path between the transmitter and the receiver. The\n" 
         "position of the transmitter is given as *rte_pos*, and the\n"
         "\"sensor\" is taken as the receiver.\n"
         "\n"
         "The primary output (*y*) is the received signal, where the signal\n"
         "transmitted is taken from *iy_transmitter_agenda*. That is, *y*\n"
         "is a Stokes vector for each frequency considered. Several other\n"
         "possible measurements quantities, such as the bending angle, can\n"
         "be obtained as the auxiliary data (see lost below).\n"
         "\n"
         "If it is found that no link can be obtained due to intersection of\n"
         "the ground, all data are set to zero. If no link could be\n"
         "determined for other reasons (due to critical refraction or\n"
         "numerical problems), all data are set to NaN.\n"
         "\n"
         "This method is just intended for approximative calculations for\n"
         "cases corresponding to relatively simple ray tracing. A detailed,\n"
         "and more exact, treatment of several effects require more advanced\n"
         "calculation approaches. Here a simple geometrical optics approach\n"
         "is followed. See the user guide for details.\n"
         "\n"
         "Defocusing is a special consideration for radio links. Two\n"
         "algorithms are at hand for estimating defocusing, simply denoted\n"
         "as method 1 and 2:\n"
         " 1: This algorithm is of general character. Defocusing is estimated\n"
         "    by making two path calculations with slightly shifted zenith\n"
         "    angles.\n"
         " 2: This method is restricted to satellite-to-satellite links, and\n"
         "    using a standard expression for such links, based on the\n"
         "    vertical gradient of the bending angle.\n"
         "Both methods are described more in detail in the user guide.\n"
         "The argument *defocus_shift* is used by both methods.\n"
         "\n"
         "The following auxiliary data can be obtained:\n"
         "  \"Pressure\": The pressure along the propagation path.\n"
         "     Size: [1,1,1,np].\n"
         "  \"Temperature\": The temperature along the propagation path.\n"
         "     Size: [1,1,1,np].\n"
         "  \"VMR, species X\": VMR of the species with index X (zero based).\n"
         "     For example, adding the string \"VMR, species 0\" extracts the\n"
         "     VMR of the first species. Size: [1,1,1,np].\n"
         "  \"Absorption, summed\": The total absorption matrix along the\n"
         "     path. Size: [nf,ns,ns,np].\n"
         "  \"Absorption, species X\": The absorption matrix along the path\n"
         "     for an individual species (X works as for VMR).\n"
         "     Size: [nf,ns,ns,np].\n"
         "  \"Particle extinction, summed\": The total particle extinction\n"
         "       matrix along the path. Size: [nf,ns,ns,np].\n"
         "  \"PND, type X\": The particle number density for particle type X\n"
         "       (ie. corresponds to book X in pnd_field). Size: [1,1,1,np].\n"
         "  \"Mass content, X\": The particle content for mass category X.\n"
         "       This corresponds to column X in *particle_masses* (zero-\n"
         "       based indexing). Size: [1,1,1,np].\n"
         "* \"Impact parameter\": As normally defined for GNRSS radio\n"
         "       occultations (this equals the propagation path constant,\n"
         "       r*n*sin(theta)). Size: [1,1,1,1].\n"
         "* \"Free space loss\": The total loss due to the inverse square\n"
         "       law. Size: [1,1,1,1].\n"
         "  \"Free space attenuation\": The local attenuation due to the\n"
         "       inverse square law. Size: [1,1,1,np].\n"
         "* \"Atmospheric loss\": Total atmospheric attenuation, reported as\n"
         "       the transmission. Size: [nf,1,1,1].\n"
         "* \"Defocusing loss\": The total loss between the transmitter and\n"
         "       receiver due to defocusing. Given as a transmission.\n"
         "       Size: [1,1,1,1].\n"
         "* \"Faraday rotation\": Total rotation [deg] along the path, for\n"
         "     each frequency. Size: [nf,1,1,1].\n"
         "* \"Faraday speed\": The rotation per length unit [deg/m], at each\n"
         "     path point and each frequency. Size: [nf,1,1,np].\n"
         "* \"Extra path delay\": The time delay of the signal [s], compared\n"
         "       to the case of propagation through vacuum. Size: [1,1,1,1].\n"
         "* \"Bending angle\": As normally defined for GNRSS radio\n"
         "       occultations, in [deg]. Size: [1,1,1,1].\n"
         "where\n"
         "  nf: Number of frequencies.\n"
         "  ns: Number of Stokes elements.\n"
         "  np: Number of propagation path points.\n"
         "\n"
         "The auxiliary data are returned in *iy_aux* with quantities\n"
         "selected by *iy_aux_vars*. Most variables require that the method\n"
         "is called directly or by *iyCalc*. For calculations using *yCalc*,\n"
         "the selection is restricted to the variables marked with *.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "iy", "iy_aux", "ppath", "diy_dx" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "stokes_dim", "f_grid", "atmosphere_dim",
            "p_grid", "lat_grid", "lon_grid",
            "z_field", "t_field", "vmr_field", "abs_species",
            "wind_u_field", "wind_v_field", "wind_w_field", "mag_u_field",
            "mag_v_field", "mag_w_field", 
            "refellipsoid", "z_surface", "cloudbox_on", "cloudbox_limits", 
            "pnd_field", "use_mean_scat_data","scat_data_array", 
            "particle_masses", "iy_aux_vars", "jacobian_do", 
            "ppath_agenda", "ppath_step_agenda",
            "propmat_clearsky_agenda", "iy_transmitter_agenda",
            "iy_agenda_call1", "iy_transmission", "rte_pos", "rte_los", 
            "rte_pos2", "rte_alonglos_v", "ppath_lraytrace" ),
        GIN(      "defocus_method", "defocus_shift" ),
        GIN_TYPE( "Index", "Numeric" ),
        GIN_DEFAULT( "1", "3e-3" ),
        GIN_DESC( "Selection of defocusing calculation method. See above.",
                  "Angular shift to apply in defocusing estimates." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "iyReplaceFromAux" ),
        DESCRIPTION
        (
         "Change of main output variable.\n"
         "\n"
         "With this method you can replace the content of *iy* with one of\n"
         "the auxiliary variables. The selected variable (by *aux_var*) must\n"
         "be part of *iy_aux_vars*. The corresponding data from *iy_aux* are\n"
         "copied to form a new *iy* (*iy_aux* is left unchanged). Elements of\n"
         "*iy* correponding to Stokes elements not covered by the auxiliary\n"
         "variable are just set to zero.\n"
         "\n"
         "Jacobian variables are not handled.\n"         
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "iy" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "iy", "iy_aux", "iy_aux_vars", "jacobian_do" ),
        GIN(      "aux_var" ),
        GIN_TYPE( "String" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "Auxiliary variable to insert as *iy*." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "iySurfaceRtpropAgenda" ),
        DESCRIPTION
        (
         "Interface to *surface_rtprop_agenda* for *iy_surface_agenda*.\n"
         "\n"
         "This method is designed to be part of *iy_surface_agenda*. It\n"
         "determines the radiative properties of the surface by\n"
         "*surface_rtprop_agenda* and calculates the downwelling radiation\n"
         "by *iy_main_agenda*, and sums up the terms as described in AUG.\n"
         "That is, this WSM uses the output from *surface_rtprop_agenda*\n"
         "in a straightforward fashion.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "iy", "diy_dx" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "iy_transmission", "jacobian_do", "atmosphere_dim", "t_field", 
            "z_field", "vmr_field", "cloudbox_on", "stokes_dim", "f_grid", 
            "rtp_pos", "rtp_los", "rte_pos2", "iy_main_agenda", 
            "surface_rtprop_agenda"
          ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "iyTransmissionStandard" ),
        DESCRIPTION
        (
         "Standard method for handling (direct) transmission measurements.\n"
         "\n"
         "Designed to be part of *iy_main_agenda*. Treatment of the cloudbox\n"
         "is incorporated (that is, no need to define *iy_cloudbox_agenda*).\n"
         "\n"
         "In short, the propagation path is followed until the surface or\n"
         "space is reached. At this point *iy_transmitter_agenda* is called\n"
         "and the radiative transfer calculations start. That is, the result\n"
         "of the method (*iy*) is the output of *iy_transmitter_agenda*\n"
         "multiplied with th transmission from the sensor to either the\n"
         "surface or space.\n"
         "\n"
         "The following auxiliary data can be obtained:\n"
         "  \"Pressure\": The pressure along the propagation path.\n"
         "     Size: [1,1,1,np].\n"
         "  \"Temperature\": The temperature along the propagation path.\n"
         "     Size: [1,1,1,np].\n"
         "  \"VMR, species X\": VMR of the species with index X (zero based).\n"
         "     For example, adding the string \"VMR, species 0\" extracts the\n"
         "     VMR of the first species. Size: [1,1,1,np].\n"
         "  \"Absorption, summed\": The total absorption matrix along the\n"
         "     path. Size: [nf,ns,ns,np].\n"
         "  \"Absorption, species X\": The absorption matrix along the path\n"
         "     for an individual species (X works as for VMR).\n"
         "     Size: [nf,ns,ns,np].\n"
         "  \"Particle extinction, summed\": The total particle extinction\n"
         "       matrix along the path. Size: [nf,ns,ns,np].\n"
         "  \"PND, type X\": The particle number density for particle type X\n"
         "       (ie. corresponds to book X in pnd_field). Size: [1,1,1,np].\n"
         "  \"Mass content, X\": The particle content for mass category X.\n"
         "       This corresponds to column X in *particle_masses* (zero-\n"
         "       based indexing). Size: [1,1,1,np].\n"
         "* \"Radiative background\": Index value flagging the radiative\n"
         "     background. The following coding is used: 0=space, 1=surface\n"
         "     and 2=cloudbox. Size: [nf,1,1,1].\n"
         "  \"iy\": The radiance at each point along the path.\n"
         "     Size: [nf,ns,1,np].\n"
         "  \"Transmission\": The transmission matrix from the surface or\n"
         "     space, to each propagation path point. The matrix is valid for\n"
         "     the photon direction. Size: [nf,ns,ns,np].\n"
         "* \"Optical depth\": The scalar optical depth between the\n"
         "     observation point and the end of the primary propagation path\n"
         "     (ie. the optical depth to the surface or space.). Calculated\n"
         "     in a pure scalar manner, and not dependent on direction.\n"
         "     Size: [nf,1,1,1].\n"
         "* \"Faraday rotation\": Total rotation [deg] along the path, for\n"
         "     each frequency. Size: [nf,1,1,1].\n"
         "* \"Faraday speed\": The rotation per length unit [deg/m], at each\n"
         "     path point and each frequency. Size: [nf,1,1,np].\n"
         "where\n"
         "  nf: Number of frequencies.\n"
         "  ns: Number of Stokes elements.\n"
         "  np: Number of propagation path points.\n"
         "\n"
         "The auxiliary data are returned in *iy_aux* with quantities\n"
         "selected by *iy_aux_vars*. Most variables require that the method\n"
         "is called directly or by *iyCalc*. For calculations using *yCalc*,\n"
         "the selection is restricted to the variables marked with *.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "iy", "iy_aux", "ppath", "diy_dx" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "stokes_dim", "f_grid", "atmosphere_dim", "p_grid",
            "z_field", "t_field", "vmr_field", "abs_species", 
            "wind_u_field", "wind_v_field", "wind_w_field", "mag_u_field",
            "mag_v_field", "mag_w_field", 
            "cloudbox_on", "cloudbox_limits", "pnd_field", 
            "use_mean_scat_data", "scat_data_array", "particle_masses",
            "iy_aux_vars", "jacobian_do", "jacobian_quantities", 
            "jacobian_indices", "ppath_agenda", "propmat_clearsky_agenda",
            "iy_transmitter_agenda", "iy_agenda_call1", "iy_transmission", 
            "rte_pos", "rte_los", "rte_pos2", "rte_alonglos_v", 
            "ppath_lraytrace" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "iy_auxFillParticleVariables" ),
        DESCRIPTION
        (
         "Additional treatment some particle auxiliary variables.\n"
         "\n"
         "This WSM is intended to complement main radiative transfer methods\n"
         "that does not handle scattering, and thus can not provide auxiliary\n"
         "data for particle properties. The following auxiliary variables\n"
         "are covered:\n"
         "  \"PND, type X\": The particle number density for particle type X\n"
         "       (ie. corresponds to book X in pnd_field). Size: [1,1,1,np].\n"
         "  \"Mass content, X\": The particle content for mass category X.\n"
         "       This corresponds to column X in *particle_masses* (zero-\n"
         "       based indexing). Size: [1,1,1,np].\n"
         "\n"
         "To complement *iyEmissionStandard* should be the main application.\n"
         "As a preparatory step you need to set up all cloud variables in\n"
         "standard manner. After this you need to set *cloudbox_on* to zero,\n"
         "and in *iy_main_agenda* add these lines (after iyEmissionStandard):\n"
         "   FlagOn(cloudbox_on)\n"
         "   iy_auxFillParticleVariables\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "iy_aux" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "iy_aux", "atmfields_checked", "cloudbox_checked", 
            "atmosphere_dim", "cloudbox_on", "cloudbox_limits", "pnd_field", 
            "particle_masses", "ppath", "iy_aux_vars" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "iy_transmitterMultiplePol" ),
        DESCRIPTION
        (
         "Transmitter definition handling multiple polarisations.\n"
         "\n"
         "The method is intended to be part of *iy_transmitter_agenda*. It\n"
         "sets *iy* to describe the transmitted pulses. The polarisation\n"
         "state is taken from *sensor_pol*, where *sensor_pol* must contain\n"
         "an element for each frequency in *f_grid*. The transmitted pulses \n"
         "are set to be of unit magnitude, such as [1,1,0,0].\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "iy" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "stokes_dim", "f_grid", "sensor_pol" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "iy_transmitterSinglePol" ),
        DESCRIPTION
        (
         "Transmitter definition involving a single polarisation.\n"
         "\n"
         "The method is intended to be part of *iy_transmitter_agenda*. It\n"
         "sets *iy* to describe the transmitted pulses. The polarisation\n"
         "state is taken from *sensor_pol*, where *sensor_pol* must contain\n"
         "a single value. This polarisation state is applied for all\n"
         "frequencies. The transmitted pulses are set to be of unit\n"
         "magnitude, such as [1,1,0,0].\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "iy" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "stokes_dim", "f_grid", "sensor_pol" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "jacobianAddAbsSpecies" ),
        DESCRIPTION
        (
         "Includes an absorption species in the Jacobian.\n"
         "\n"
         "Details are given in the user guide.\n"
         "\n"         
         "For 1D or 2D calculations the latitude and/or longitude grid of\n"
         "the retrieval field should set to have zero length.\n"
         "\n"
         "There are two possible calculation methods:\n"
         "   \"analytical\"   : (semi-)analytical expressions are used\n"
         "   \"perturbation\" : pure numerical perturbations are used\n"
         "\n"
         "The retrieval unit can be:\n"
         "   \"vmr\"    : Volume mixing ratio.\n"
         "   \"nd\"     : Number density.\n"
         "   \"rel\"    : Relative unit (e.g. 1.1 means 10% more of the gas).\n"
         "   \"logrel\" : The retrieval is performed with the logarithm of\n"
         "                the \"rel\" option.\n"
         "\n"
         "For perturbation calculations the size of the perturbation is set\n"
         "by the user. The unit for the perturbation is the same as for the\n"
         "retrieval unit.\n"
         ),
        AUTHORS( "Mattias Ekstrom", "Patrick Eriksson" ),
        OUT( "jacobian_quantities", "jacobian_agenda" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "jacobian_quantities", "jacobian_agenda",
            "atmosphere_dim", "p_grid", "lat_grid", "lon_grid" ),
        GIN( "g1", "g2", "g3", "species", "method", "unit","dx" ),
        GIN_TYPE( "Vector", "Vector", "Vector", "String", "String", "String", 
                  "Numeric" ),
        GIN_DEFAULT( NODEF, NODEF, NODEF, NODEF, "analytical", "rel", "0.001" ),
        GIN_DESC( "Pressure retrieval grid.",
                  "Latitude retrieval grid.",
                  "Longitude retreival grid.",
                  "The species tag of the retrieval quantity.",
                  "Calculation method. See above.",
                  "Retrieval unit. See above.",
                  "Size of perturbation." 
                  ),
        SETMETHOD(      false ),
        AGENDAMETHOD(   false ),
        USES_TEMPLATES( false ),
        PASSWORKSPACE(  true  )
        ));
         
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "jacobianAddFreqShift" ),
        DESCRIPTION
        (
         "Includes a frequency for of shift type in the Jacobian.\n"
         "\n"
         "Retrieval of deviations between nominal and actual backend\n"
         "frequencies can be included by this method. The assumption here is\n"
         "that the deviation is a constant off-set, a shift, common for all\n"
         "frequencies.\n"
         "\n"
         "The frequency shift can be modelled to be time varying. The time\n"
         "variation is then described by a polynomial (with standard base\n"
         "functions). For example, a polynomial order of 0 means that the\n"
         "shift is constant in time. If the shift is totally uncorrelated\n"
         "between the spectra, set the order to -1.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "jacobian_quantities", "jacobian_agenda" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "jacobian_quantities", "jacobian_agenda", "f_grid", "sensor_pos",
            "sensor_time" ),
        GIN( "poly_order", "df" ),
        GIN_TYPE( "Index", "Numeric" ),
        GIN_DEFAULT( "0", "100e3" ),
        GIN_DESC( "Order of polynomial to describe the time variation of "
                  "frequency shift.",
                  "Size of perturbation to apply."
                  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "jacobianAddFreqStretch" ),
        DESCRIPTION
        (
         "Includes a frequency for of stretch type in the Jacobian.\n"
         "\n"
         "Retrieval of deviations between nominal and actual backend\n"
         "frequencies can be included by this method. The assumption here is\n"
         "that the deviation varies linearly over the frequency range\n"
         "(following ARTS basis function for polynomial order 1).\n"
         "\n"
         "The frequency shift can be modelled to be time varying. The time\n"
         "variation is then described by a polynomial (with standard base\n"
         "functions). For example, a polynomial order of 0 means that the\n"
         "shift is constant in time. If the shift is totally uncorrelated\n"
         "between the spectra, set the order to -1.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "jacobian_quantities", "jacobian_agenda" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "jacobian_quantities", "jacobian_agenda", "f_grid", "sensor_pos",
            "sensor_time" ),
        GIN( "poly_order", "df" ),
        GIN_TYPE( "Index", "Numeric" ),
        GIN_DEFAULT( "0", "100e3" ),
        GIN_DESC( "Order of polynomial to describe the time variation of "
                  "frequency stretch.",
                  "Size of perturbation to apply."
                  )
        ));



  /*
    md_data_raw.push_back
    ( MdRecord
    ( NAME( "jacobianAddParticle" ),
    DESCRIPTION
    (
    "Add particle number density as retrieval quantity to the Jacobian.\n"
    "\n"
    "The Jacobian is done by perturbation calculation by adding elements\n"
    "of *pnd_field_perturb* to *pnd_field*. Only 1D and 3D atmospheres\n"
    "can be handled by this method.\n"
    "\n"
    "The perturbation field and the unit of it are defined outside ARTS.\n"
    "This method only returns the difference between the reference and\n"
    "perturbed spectra. The division by the size of the perturbation\n"
    "also has to be done outside ARTS.\n"
    "The unit of the particle jacobian is the same as for *y*.\n"
    "\n"
    "Generic input:\n"
    "  Vector : The pressure grid of the retrieval field.\n"
    "  Vector : The latitude grid of the retrieval field.\n"
    "  Vector : The longitude grid of the retrieval field.\n"
    ),
    AUTHORS( "Mattias Ekstrom", "Patrick Eriksson" ),
    OUT( "jacobian_quantities", "jacobian_agenda" ),
    GOUT(),
    GOUT_TYPE(),
    GOUT_DESC(),
    IN( "jacobian", "atmosphere_dim", "p_grid", "lat_grid", "lon_grid", 
    "pnd_field", "pnd_field_perturb", "cloudbox_limits" ),
    GIN(      "gin1"      , "gin2"      , "gin3"       ),
    GIN_TYPE(    "Vector", "Vector", "Vector" ),
    GIN_DEFAULT( NODEF   , NODEF   , NODEF    ),
    GIN_DESC( "FIXME DOC",
    "FIXME DOC",
    "FIXME DOC" )
    ));
  */
  
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "jacobianAddPointingZa" ),
        DESCRIPTION
        (
         "Adds sensor pointing zenith angle off-set jacobian.\n"
         "\n"
         "Retrieval of deviations between nominal and actual zenith angle of\n"
         "the sensor can be included by this method. The weighing functions\n"
         "can be calculated in several ways:\n"
         "   calcmode = \"recalc\": Recalculation of pencil beam spectra,\n"
         "      shifted with *dza* from nominal values. A single-sided\n"
         "      perturbation is applied (towards higher zenith angles).\n"
         "   calcmode = \"interp\": Inter/extrapolation of existing pencil\n"
         "       beam spectra. For this option, allow some extra margins for\n"
         "       zenith angle grids, to avoid artifacts when extrapolating\n"
         "       the data (to shifted zenith angles). The average of a\n"
         "       negative and a positive shift is taken."
         "\n"
         "The interp option is recommended. It should in general be both\n"
         "faster and more accurate (due to the double sided disturbance).\n"
         "In addition, it is less sensitive to the choice of dza (as long\n"
         "as a small value is applied).\n"
         "\n"
         "The pointing off-set can be modelled to be time varying. The time\n"
         "variation is then described by a polynomial (with standard base\n"
         "functions). For example, a polynomial order of 0 means that the\n"
         "off-set is constant in time. If the off-set is totally uncorrelated\n"
         "between the spectra, set the order to -1.\n"
         ),
        AUTHORS( "Patrick Eriksson", "Mattias Ekstrom" ),
        OUT( "jacobian_quantities", "jacobian_agenda" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "jacobian_quantities", "jacobian_agenda", "sensor_pos", 
            "sensor_time" ),
        GIN( "poly_order", "calcmode", "dza" ),
        GIN_TYPE( "Index", "String", "Numeric" ),
        GIN_DEFAULT( "0", "recalc", "0.01" ),
        GIN_DESC( "Order of polynomial to describe the time variation of "
                  "pointing off-sets.",
                  "Calculation method. See above",
                  "Size of perturbation to apply (when applicable)."
                  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "jacobianAddPolyfit" ),
        DESCRIPTION
        (
         "Includes polynomial baseline fit in the Jacobian.\n"
         "\n"
         "This method deals with retrieval of disturbances of the spectra\n"
         "that can be described by an addidative term, a baseline off-set.\n"
         "\n"
         "The baseline off-set is here modelled as a polynomial. The\n"
         "polynomial spans the complete frequency range spanned by\n"
         "*sensor_response_f_grid* and the method should only of interest for\n"
         "cases with no frequency gap in the spectra. The default assumption\n"
         "is that the off-set differs between all spectra, but it can also be\n"
         "assumed that the off-set is common for all e.g. line-of-sights.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "jacobian_quantities", "jacobian_agenda" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "jacobian_quantities", "jacobian_agenda", 
            "sensor_response_pol_grid", "sensor_response_za_grid", 
            "sensor_pos" ),
        GIN( "poly_order", "no_pol_variation", "no_los_variation", 
             "no_mblock_variation" ),
        GIN_TYPE( "Index", "Index", "Index", "Index" ),
        GIN_DEFAULT( NODEF, "0", "0", "0" ),
        GIN_DESC( "Polynomial order to use for the fit.", 
                  "Set to 1 if the baseline off-set is the same for all "
                  "Stokes components.", 
                  "Set to 1 if the baseline off-set is the same for all "
                  "line-of-sights (inside each measurement block).", 
                  "Set to 1 if the baseline off-set is the same for all "
                  "measurement blocks." 
                  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "jacobianAddSinefit" ),
        DESCRIPTION
        (
         "Includes sinusoidal baseline fit in the Jacobian.\n"
         "\n"
         "Works as *jacobianAddPolyFit*, beside that a series of sine and\n"
         "cosine terms are used for the baseline fit.\n"
         "\n"
         "For each value in *period_lengths one sine and one cosine term are\n"
         "included (in mentioned order). By these two terms the amplitude and\n"
         "\"phase\" for each period length can be determined. The sine and\n"
         "cosine terms have value 0 and 1, respectively, for first frequency.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "jacobian_quantities", "jacobian_agenda" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "jacobian_quantities", "jacobian_agenda", 
            "sensor_response_pol_grid", "sensor_response_za_grid", 
            "sensor_pos" ),
        GIN( "period_lengths", "no_pol_variation", "no_los_variation", 
             "no_mblock_variation" ),
        GIN_TYPE( "Vector", "Index", "Index", "Index" ),
        GIN_DEFAULT( NODEF, "0", "0", "0" ),
        GIN_DESC( "Period lengths of the fit.", 
                  "Set to 1 if the baseline off-set is the same for all "
                  "Stokes components.", 
                  "Set to 1 if the baseline off-set is the same for all "
                  "line-of-sights (inside each measurement block).", 
                  "Set to 1 if the baseline off-set is the same for all "
                  "measurement blocks." 
                  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "jacobianAddTemperature" ),
        DESCRIPTION
        (
         "Includes atmospheric temperatures in the Jacobian.\n"
         "\n"
         "The calculations can be performed by (semi-)analytical expressions\n"
         "or by perturbations. Hydrostatic equilibrium (HSE) can be included.\n"
         "For perturbation calculations, all possible effects are included\n"
         "(but is a costly option). The analytical calculation approach\n"
         "neglects refraction totally, but considers the local effect of HSE.\n"
         "The later should be accaptable for observations around zenith and\n"
         "nadir. There is no warning if the method is applied incorrectly, \n"
         "with respect to these issues.\n"
         "\n"
         "The calculations (both options) assume that gas species are defined\n"
         "in VMR (a change in temperature then changes the number density). \n"
         "This has the consequence that retrieval of temperatures and number\n" 
         "density can not be mixed. Neither any warning here!\n"
         "\n"
         "The choices for *method* are:\n"
         "   \"analytical\"   : (semi-)analytical expressions are used\n"
         "   \"perturbation\" : pure numerical perturbations are used\n"
         ),
        AUTHORS( "Mattias Ekstrom", "Patrick Eriksson" ),
        OUT( "jacobian_quantities", "jacobian_agenda" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "jacobian_quantities", "jacobian_agenda", 
            "atmosphere_dim", "p_grid", "lat_grid", "lon_grid" ),
        GIN( "g1", "g2", "g3", "hse", "method", "dt" ),
        GIN_TYPE( "Vector", "Vector", "Vector", "String", "String", "Numeric" ),
        GIN_DEFAULT( NODEF, NODEF, NODEF, "on", "analytical", "0.1" ),
        GIN_DESC( "Pressure retrieval grid.",
                  "Latitude retrieval grid.",
                  "Longitude retreival grid.",
                  "Flag to assume HSE or not (\"on\" or \"off\").",
                  "Calculation method. See above.",
                  "Size of perturbation [K]." 
                  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "jacobianAddWind" ),
        DESCRIPTION
        (
         "Includes one atmospheric wind component in the Jacobian.\n"
         "\n"
         "The method follows the pattern of other Jacobian methods. The\n"
         "calculations can only be performed by analytic expressions.\n"
         "\n"
         "As mentioned, the wind components are assumed to be retrieved\n"
         "separately, and, hence, the argument *component* can be \"u\",\n"
         "\"v\" or \"w\". \n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "jacobian_quantities", "jacobian_agenda" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "jacobian_quantities", "jacobian_agenda", 
            "atmosphere_dim", "p_grid", "lat_grid", "lon_grid" ),
        GIN( "g1", "g2", "g3", "component" ),
        GIN_TYPE( "Vector", "Vector", "Vector", "String" ),
        GIN_DEFAULT( NODEF, NODEF, NODEF, "v" ),
        GIN_DESC( "Pressure retrieval grid.",
                  "Latitude retrieval grid.",
                  "Longitude retreival grid.",
                  "Wind component to retrieve"
                  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "jacobianCalcAbsSpeciesAnalytical" ),
        DESCRIPTION
        (
         "This function doesn't do anything. It just exists to satisfy\n"
         "the input and output requirement of the *jacobian_agenda*.\n"
         "\n"
         "This function is added to *jacobian_agenda* by\n"
         "jacobianAddAbsSpecies and should normally not be called\n"
         "by the user.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( "jacobian" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "jacobian",
            "mblock_index", "iyb", "yb" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "jacobianCalcAbsSpeciesPerturbations" ),
        DESCRIPTION
        (
         "Calculates absorption species jacobians by perturbations.\n"
         "\n"
         "This function is added to *jacobian_agenda* by\n"
         "jacobianAddAbsSpecies and should normally not be called\n"
         "by the user.\n"
         ),
        AUTHORS( "Mattias Ekstrom", "Patrick Eriksson" ),
        OUT( "jacobian" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "jacobian",
            "mblock_index", "iyb", "yb", "atmosphere_dim", "p_grid", "lat_grid",
            "lon_grid", "t_field", "z_field", "vmr_field", "abs_species", 
            "cloudbox_on", "stokes_dim", "f_grid", 
            "sensor_pos", "sensor_los", "transmitter_pos", "mblock_za_grid", 
            "mblock_aa_grid", "antenna_dim", "sensor_response",
            "iy_main_agenda", "jacobian_quantities", "jacobian_indices" ),
        GIN( "species" ),
        GIN_TYPE(    "String" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "Species of interest." ),
        SETMETHOD( true )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "jacobianCalcFreqShift" ),
        DESCRIPTION
        (
         "Calculates frequency shift jacobians by interpolation\n"
         "of *iyb*.\n"
         "\n"
         "This function is added to *jacobian_agenda* by jacobianAddFreqShift\n"
         "and should normally not be called by the user.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "jacobian" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "jacobian",
            "mblock_index", "iyb", "yb", "stokes_dim", "f_grid", "sensor_los", 
            "mblock_za_grid", "mblock_aa_grid", "antenna_dim", 
            "sensor_response", "sensor_time", "jacobian_quantities", 
            "jacobian_indices" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "jacobianCalcFreqStretch" ),
        DESCRIPTION
        (
         "Calculates frequency stretch jacobians by interpolation\n"
         "of *iyb*.\n"
         "\n"
         "This function is added to *jacobian_agenda* by jacobianAddFreqStretch\n"
         "and should normally not be called by the user.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "jacobian" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "jacobian",
            "mblock_index", "iyb", "yb", "stokes_dim", "f_grid", "sensor_los", 
            "mblock_za_grid", "mblock_aa_grid", "antenna_dim", 
            "sensor_response", "sensor_response_pol_grid",
            "sensor_response_f_grid", "sensor_response_za_grid",
            "sensor_time", "jacobian_quantities", 
            "jacobian_indices" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

 /*
           md_data_raw.push_back
            ( MdRecord
            ( NAME( "jacobianCalcParticle" ),
            DESCRIPTION
            (
            "Calculates particle number densities jacobians by perturbations\n"
            "\n"
            "This function is added to *jacobian_agenda* by jacobianAddParticle\n"
            "and should normally not be called by the user.\n"
            ),
            AUTHORS( "Mattias Ekstrom", "Patrick Eriksson" ),
            OUT( "jacobian" ),
            GOUT(),
            GOUT_TYPE(),
            GOUT_DESC(),
            IN( "y", "jacobian_quantities", "jacobian_indices", "pnd_field_perturb",
            "jacobian_particle_update_agenda",
            "ppath_step_agenda", "rte_agenda", "iy_space_agenda", 
            "surface_rtprop_agenda", "iy_cloudbox_agenda", "atmosphere_dim", 
            "p_grid", "lat_grid", "lon_grid", "z_field", "t_field", "vmr_field",
            "refellipsoid", "z_surface", 
            "cloudbox_on", "cloudbox_limits", "pnd_field",
            "sensor_response", "sensor_pos", "sensor_los", "f_grid", 
            "stokes_dim", "antenna_dim", "mblock_za_grid", "mblock_aa_grid" ),
            GIN(),
            GIN_TYPE(),
            GIN_DEFAULT(),
            GIN_DESC()
            ));
        
 */

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "jacobianCalcPointingZaInterp" ),
        DESCRIPTION
        (
         "Calculates zenith angle pointing deviation jacobians by\n"
         "inter-extrapolation of *iyb*.\n"
         "\n"
         "This function is added to *jacobian_agenda* by\n"
         "jacobianAddPointingZa and should normally not be\n"
         "called by the user.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "jacobian" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "jacobian", "mblock_index", "iyb", "yb", "stokes_dim", "f_grid", 
            "sensor_los", "mblock_za_grid", "mblock_aa_grid", "antenna_dim", 
            "sensor_response", "sensor_time", 
            "jacobian_quantities", "jacobian_indices" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "jacobianCalcPointingZaRecalc" ),
        DESCRIPTION
        (
         "Calculates zenith angle pointing deviation jacobians by\n"
         "recalulation of *iyb*.\n"
         "\n"
         "This function is added to *jacobian_agenda* by\n"
         "jacobianAddPointingZa and should normally not be\n"
         "called by the user.\n"
         ),
        AUTHORS( "Mattias Ekstrom", "Patrick Eriksson" ),
        OUT( "jacobian" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "jacobian", "mblock_index", "iyb", "yb", "atmosphere_dim",
            "t_field", "z_field", "vmr_field", "cloudbox_on", "stokes_dim", 
            "f_grid", "sensor_pos", "sensor_los", "transmitter_pos", 
            "mblock_za_grid", "mblock_aa_grid", "antenna_dim", 
            "sensor_response", "sensor_time", 
            "iy_main_agenda", "jacobian_quantities",
            "jacobian_indices" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "jacobianCalcPolyfit" ),
        DESCRIPTION
        (
         "Calculates jacobians for polynomial baseline fit.\n"
         "\n"
         "This function is added to *jacobian_agenda* by jacobianAddPolyfit\n"
         "and should normally not be called by the user.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "jacobian" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "jacobian", "mblock_index", "iyb", "yb", "sensor_response",
            "sensor_response_pol_grid", "sensor_response_f_grid", 
            "sensor_response_za_grid", 
            "jacobian_quantities", "jacobian_indices" ),
        GIN( "poly_coeff" ),
        GIN_TYPE( "Index" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "Polynomial coefficient to handle." ),
        SETMETHOD( true )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "jacobianCalcSinefit" ),
        DESCRIPTION
        (
         "Calculates jacobians for sinusoidal baseline fit.\n"
         "\n"
         "This function is added to *jacobian_agenda* by jacobianAddPolyfit\n"
         "and should normally not be called by the user.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "jacobian" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "jacobian", "mblock_index", "iyb", "yb", "sensor_response",
            "sensor_response_pol_grid", "sensor_response_f_grid", 
            "sensor_response_za_grid", 
            "jacobian_quantities", "jacobian_indices" ),
        GIN( "period_index" ),
        GIN_TYPE( "Index" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "Index among the period length specified for add-method." ),
        SETMETHOD( true )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "jacobianCalcTemperatureAnalytical" ),
        DESCRIPTION
        (
         "This function doesn't do anything. It just exists to satisfy\n"
         "the input and output requirement of the *jacobian_agenda*.\n"
         "\n"
         "This function is added to *jacobian_agenda* by\n"
         "jacobianAddTemperature and should normally not be called\n"
         "by the user.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( "jacobian" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "jacobian",
            "mblock_index", "iyb", "yb" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "jacobianCalcTemperaturePerturbations" ),
        DESCRIPTION
        (
         "Calculates atmospheric temperature jacobians by perturbations.\n"
         "\n"
         "This function is added to *jacobian_agenda* by\n"
         "jacobianAddTemperature and should normally not be called\n"
         "by the user.\n"
         ),
        AUTHORS( "Mattias Ekstrom", "Patrick Eriksson" ),
        OUT( "jacobian" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "jacobian",
            "mblock_index", "iyb", "yb", "atmosphere_dim", "p_grid", "lat_grid",
            "lon_grid", "lat_true", "lon_true", "t_field", "z_field", 
            "vmr_field", "abs_species", "refellipsoid", "z_surface", 
            "cloudbox_on", "stokes_dim", "f_grid", "sensor_pos", "sensor_los", 
            "transmitter_pos", "mblock_za_grid", "mblock_aa_grid", 
            "antenna_dim", "sensor_response", "iy_main_agenda", 
            "g0_agenda", "molarmass_dry_air", "p_hse", "z_hse_accuracy", 
            "jacobian_quantities", "jacobian_indices" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "jacobianCalcWindAnalytical" ),
        DESCRIPTION
        (
         "This function doesn't do anything. It just exists to satisfy\n"
         "the input and output requirement of the *jacobian_agenda*.\n"
         "\n"
         "This function is added to *jacobian_agenda* by\n"
         "jacobianAddWind and should normally not be called\n"
         "by the user.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( "jacobian" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "jacobian",
            "mblock_index", "iyb", "yb" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "jacobianClose" ),
        DESCRIPTION
        (
         "Closes the array of retrieval quantities and prepares for\n" 
         "calculation of the Jacobian matrix.\n"
         "\n"
         "This function closes the *jacobian_quantities* array, sets the\n"
         "correct size of *jacobian* and sets *jacobian_do* to 1.\n"
         "\n"
         "Retrieval quantities should not be added after a call to this WSM.\n"
         "No calculations are performed here.\n"
         ),
        AUTHORS( "Mattias Ekstrom" ),
        OUT( "jacobian_do", "jacobian_indices", "jacobian_agenda" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "jacobian_agenda", "jacobian_quantities", "sensor_pos", "sensor_response" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "jacobianInit" ),
        DESCRIPTION
        (
         "Initialises the variables connected to the Jacobian matrix.\n"
         "\n"
         "This function initialises the *jacobian_quantities* array so\n"
         "that retrieval quantities can be added to it. Accordingly, it has\n"
         "to be called before any calls to jacobianAddTemperature or\n"
         "similar methods.\n"
         "\n"
         "The Jacobian quantities are initialised to be empty.\n"
         ),
        AUTHORS( "Mattias Ekstrom" ),
        OUT( "jacobian_quantities", "jacobian_indices","jacobian_agenda" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "jacobianOff" ),
        DESCRIPTION
        (
         "Makes mandatory initialisation of some jacobian variables.\n"
         "\n"
         "Some jacobian WSVs must be initilised even if no such calculations\n"
         "will be performed and this is handled with this method. That is,\n"
         "this method must be called when no jacobians will be calculated.\n"
         "Sets *jacobian_on* to 0.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "jacobian_do", "jacobian_agenda", "jacobian_quantities", 
             "jacobian_indices" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "lat_gridFromRawField" ),
        DESCRIPTION
        (
         "Sets *lat_grid* according to given raw atmospheric field's lat_grid.\n"
         "Similar to *p_gridFromZRaw*, but acting on a generic *GriddedField3*\n"
         "(e.g., a wind or magnetic field component).\n"
         ),
        AUTHORS( "Jana Mendrok" ),
        OUT( "lat_grid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(  ),
        GIN(         "field_raw" ),
        GIN_TYPE(    "GriddedField3" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "A raw atmospheric field." )
        ));
 
  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "lon_gridFromRawField" ),
        DESCRIPTION
        (
         "Sets *lon_grid* according to given raw atmospheric field's lat_grid.\n"
         "Similar to *p_gridFromZRaw*, but acting on a generic *GriddedField3*\n"
         "(e.g., a wind or magnetic field component).\n"
         ),
        AUTHORS( "Jana Mendrok" ),
        OUT( "lon_grid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(  ),
        GIN(         "field_raw" ),
        GIN_TYPE(    "GriddedField3" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "A raw atmospheric field." )
        ));
 
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "line_mixing_dataInit" ),
        DESCRIPTION
        (
         "Initialize *line_mixing_data* and *line_mixing_data_lut*.\n"
         "Resizes first dimension of both to the same size as *abs_species*.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( "line_mixing_data", "line_mixing_data_lut" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_species" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "line_mixing_dataMatch" ),
        DESCRIPTION
        (
         "Matches line mixing records to a species in *abs_lines_per_species*.\n"
         "*line_mixing_dataInit* must be called before this method.\n"
         "\n"
         "  ArrayOfLineMixingRecordCreate(lm_o2)\n"
         "  ReadXML(lm_o2, \"o2_v1_0_band_40-120_GHz.xml\")\n"
         "  line_mixing_dataInit\n"
         "  line_mixing_dataMatch(species_tag=\"O2-66-LM_2NDORDER\",\n"
         "                        line_mixing_records=lm_o2)\n"

         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( "line_mixing_data", "line_mixing_data_lut" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "line_mixing_data", "line_mixing_data_lut",
            "abs_lines_per_species", "abs_species" ),
        GIN(         "species_tag", "line_mixing_records" ),
        GIN_TYPE(    "String",      "ArrayOfLineMixingRecord" ),
        GIN_DEFAULT( NODEF,         NODEF ),
        GIN_DESC(    "Species tag", "Unmatched line mixing data.")
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Massdensity_cleanup" ),
        DESCRIPTION
        (
         "This WSM checks if *massdensity_field* contains values smaller than\n"
         "*massdensity_threshold*. In this case, these values will be set to zero.\n"
         "\n"
         "The Method should be applied if *massdensity_field* contains unrealistic small\n"
         "or erroneous data. (e.g. the chevallierl_91l data sets contain these small values)\n"
         "\n"
         "*Massdensity_cleanup* is called after generation of atmopheric fields.\n"
         "\n"
         "*Default value*:\t1e-15\n"
         ),
        AUTHORS( "Daniel Kreyling" ),
        OUT( "massdensity_field" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "massdensity_field" ),
        GIN( "massdensity_threshold" ),
        GIN_TYPE( "Numeric" ),
        GIN_DEFAULT( "1e-15" ),
        GIN_DESC( "Values in *massdensity_field* smaller than *massdensity_threshold* will be set to zero." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "MatrixCBR" ),
        DESCRIPTION
        (
         "Sets a matrix to hold cosmic background radiation (CBR).\n"
         "\n"
         "The CBR is assumed to be un-polarized and Stokes components 2-4\n"
         "are zero. Number of Stokes components, that equals the number\n"
         "of columns in the created matrix, is determined by *stokes_dim*.\n"
         "The number of rows in the created matrix equals the length of the\n"
         "given frequency vector.\n"
         "\n"
         "The cosmic radiation is modelled as blackbody radiation for the\n"
         "temperature given by the global constant COSMIC_BG_TEMP, set in\n"
         "the file constants.cc. The frequencies are taken from the generic\n"
         "input vector.\n"
         "\n"
         "The standard definition, in ARTS, of the Planck function is\n"
         "followed and the unit of the returned data is W/(m3 * Hz * sr).\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT(      "out"       ),
        GOUT_TYPE( "Matrix" ),
        GOUT_DESC( "Variable to initialize." ),
        IN( "stokes_dim" ),
        GIN(         "f"      ),
        GIN_TYPE(    "Vector" ),
        GIN_DEFAULT( NODEF    ),
        GIN_DESC( "Frequency vector." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "MatrixExtractFromTensor3" ),
        DESCRIPTION
        (
         "Extracts a Matrix from a Tensor3.\n"
         "\n"
         "Copies page or row or column with given Index from input Tensor3\n"
         "variable to output Matrix.\n"
         "Higher order equivalent of *VectorExtractFromMatrix*.\n"
         ),
        AUTHORS( "Jana Mendrok" ),
        OUT(),
        GOUT(      "out"      ),
        GOUT_TYPE( "Matrix" ),
        GOUT_DESC( "Extracted matrix." ),
        IN(),
        GIN(          "in"     , "i"    , "direction" ),
        GIN_TYPE(     "Tensor3", "Index", "String"    ),
        GIN_DEFAULT(  NODEF   , NODEF  , NODEF       ),
        GIN_DESC( "Input matrix.",
                  "Index of page or row or column to extract.",
                  "Direction. \"page\" or \"row\" or \"column\"." 
                  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "MatrixMatrixMultiply" ),
        DESCRIPTION
        (
         "Multiply a Matrix with another Matrix and store the result in the result\n"
         "Matrix.\n"
         "\n"
         "This just computes the normal Matrix-Matrix product, Y=M*X. It is ok\n"
         "if Y and X are the same Matrix. This function is handy for\n"
         "multiplying the H Matrix to batch spectra.\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT(),
        GOUT(      "out"       ),
        GOUT_TYPE( "Matrix" ),
        GOUT_DESC( "The result of the multiplication (dimension mxc)." ),
        IN(),
        GIN(      "m"      , "x"       ),
        GIN_TYPE(    "Matrix", "Matrix" ),
        GIN_DEFAULT( NODEF   , NODEF    ),
        GIN_DESC( "The Matrix to multiply (dimension mxn).",
                  "The original Matrix (dimension nxc)." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "MatrixPlanck" ),
        DESCRIPTION
        (
         "Sets a matrix to hold blackbody radiation.\n"
         "\n"
         "The radiation is assumed to be un-polarized and Stokes components\n"
         "2-4 are zero. Number of Stokes components, that equals the number\n"
         "of columns in the created matrix, is determined by *stokes_dim*.\n"
         "The number of rows in the created matrix equals the length of the\n"
         "given frequency vector.\n"
         "\n"
         "The standard definition, in ARTS, of the Planck function is\n"
         "followed and the unit of the returned data is W/(m3 * Hz * sr).\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT(      "out"      ),
        GOUT_TYPE( "Matrix" ),
        GOUT_DESC( "Variable to initialize." ),
        IN( "stokes_dim" ),
        GIN(        "f"  , "t"    ),
        GIN_TYPE(   "Vector", "Numeric" ),
        GIN_DEFAULT( NODEF   , NODEF    ),
        GIN_DESC( "Frequency vector.",
                  "Temperature [K]." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "MatrixScale" ),
        DESCRIPTION
        (
         "Scales all elements of a matrix with the specified value.\n"
         "\n"
         "The result can either be stored in the same or another\n"
         "variable.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT(      "out"   ),
        GOUT_TYPE( "Matrix" ),
        GOUT_DESC( "Output matrix" ),
        IN(),
        GIN(         "in"   , "value"   ),
        GIN_TYPE(    "Matrix", "Numeric" ),
        GIN_DEFAULT( NODEF   , NODEF     ),
        GIN_DESC( "Input matrix.",
                  "The value to be multiplied with the matrix." 
                  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "MatrixSet" ),
        DESCRIPTION
        (
         "Initialize a Matrix from the given list of numbers.\n"
         "\n"
         "Usage:\n"
         "   MatrixSet(m1, [1, 2, 3; 4, 5, 6])\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT(),
        GOUT(      "out"       ),
        GOUT_TYPE( "Matrix" ),
        GOUT_DESC( "The newly created matrix" ),
        IN(),
        GIN( "value"   ),
        GIN_TYPE(    "Matrix" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "The values of the newly created matrix. Elements are separated "
                  "by commas, rows by semicolons."),
        SETMETHOD( true )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "MatrixSetConstant" ),
        DESCRIPTION
        (
         "Creates a matrix and sets all elements to the specified value.\n"
         "\n"
         "The size is determined by *ncols* and *nrows*.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT(      "out"      ),
        GOUT_TYPE( "Matrix" ),
        GOUT_DESC( "Variable to initialize." ),
        IN( "nrows", "ncols" ),
        GIN(         "value"   ),
        GIN_TYPE(    "Numeric" ),
        GIN_DEFAULT( NODEF     ),
        GIN_DESC( "Matrix value." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "MatrixUnitIntensity" ),
        DESCRIPTION
        (
         "Sets a matrix to hold unpolarised radiation with unit intensity.\n"
         "\n"
         "Works as MatrixPlanck where the radiation is set to 1.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT(      "out"       ),
        GOUT_TYPE( "Matrix" ),
        GOUT_DESC( "Variable to initialize." ),
        IN( "stokes_dim" ),
        GIN(         "f"      ),
        GIN_TYPE(    "Vector" ),
        GIN_DEFAULT( NODEF    ),
        GIN_DESC( "Frequency vector." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Matrix1ColFromVector" ),
        DESCRIPTION
        (
         "Forms a matrix containing one column from a vector.\n"
         ),
        AUTHORS( "Mattias Ekstrom" ),
        OUT(),
        GOUT(      "out"      ),
        GOUT_TYPE( "Matrix" ),
        GOUT_DESC( "Variable to initialize." ),
        IN(),
        GIN(         "v"       ),
        GIN_TYPE(    "Vector" ),
        GIN_DEFAULT( NODEF    ),
        GIN_DESC( "The vector to be copied." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Matrix2ColFromVectors" ),
        DESCRIPTION
        (
         "Forms a matrix containing two columns from two vectors.\n"
         "\n"
         "The vectors are included as columns in the matrix in the same order\n"
         "as they are given.\n"
         ),
        AUTHORS( "Mattias Ekstrom" ),
        OUT(),
        GOUT(      "out"      ),
        GOUT_TYPE( "Matrix" ),
        GOUT_DESC( "Variable to initialize." ),
        IN(),
        GIN(         "v1"    , "v2"     ),
        GIN_TYPE(    "Vector", "Vector" ),
        GIN_DEFAULT( NODEF   , NODEF    ),
        GIN_DESC( "The vector to be copied into the first column.",
                  "The vector to be copied into the second column." 
                  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Matrix3ColFromVectors" ),
        DESCRIPTION
        (
         "Forms a matrix containing three columns from three vectors.\n"
         "\n"
         "The vectors are included as columns in the matrix in the same order\n"
         "as they are given.\n"
         ),
        AUTHORS( "Mattias Ekstrom" ),
        OUT(),
        GOUT(      "out"      ),
        GOUT_TYPE( "Matrix" ),
        GOUT_DESC( "Variable to initialize." ),
        IN(),
        GIN(         "v1"    , "v2"    , "v3"     ),
        GIN_TYPE(    "Vector", "Vector", "Vector" ),
        GIN_DEFAULT( NODEF   , NODEF   , NODEF    ),
        GIN_DESC( "The vector to be copied into the first column.",
                  "The vector to be copied into the second column.",
                  "The vector to be copied into the third column." 
                  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Matrix1RowFromVector" ),
        DESCRIPTION
        (
         "Forms a matrix containing one row from a vector.\n"
         ),
        AUTHORS( "Mattias Ekstrom" ),
        OUT(),
        GOUT(      "out"      ),
        GOUT_TYPE( "Matrix" ),
        GOUT_DESC( "Variable to initialize." ),
        IN(),
        GIN(         "v"       ),
        GIN_TYPE(    "Vector" ),
        GIN_DEFAULT( NODEF    ),
        GIN_DESC( "The vector to be copied." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Matrix2RowFromVectors" ),
        DESCRIPTION
        (
         "Forms a matrix containing two rows from two vectors.\n"
         "\n"
         "The vectors are included as rows in the matrix in the same order\n"
         "as they are given.\n"
         ),
        AUTHORS( "Mattias Ekstrom" ),
        OUT(),
        GOUT(      "out"      ),
        GOUT_TYPE( "Matrix" ),
        GOUT_DESC( "Variable to initialize." ),
        IN(),
        GIN(         "v1"    , "v2"     ),
        GIN_TYPE(    "Vector", "Vector" ),
        GIN_DEFAULT( NODEF   , NODEF    ),
        GIN_DESC( "The vector to be copied into the first row.",
                  "The vector to be copied into the second row." 
                  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Matrix3RowFromVectors" ),
        DESCRIPTION
        (
         "Forms a matrix containing three rows from three vectors.\n"
         "\n"
         "The vectors are included as rows in the matrix in the same order\n"
         "as they are given.\n"
         ),
        AUTHORS( "Mattias Ekstrom" ),
        OUT(),
        GOUT(      "out"      ),
        GOUT_TYPE( "Matrix" ),
        GOUT_DESC( "Variable to initialize." ),
        IN(),
        GIN(         "v1"    , "v2"    , "v3"     ),
        GIN_TYPE(    "Vector", "Vector", "Vector" ),
        GIN_DEFAULT( NODEF   , NODEF   , NODEF    ),
        GIN_DESC( "The vector to be copied into the first row.",
                  "The vector to be copied into the second row.",
                  "The vector to be copied into the third row." 
                  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "mc_antennaSetGaussian" ),
        DESCRIPTION
        (
         "Makes mc_antenna (used by MCGeneral) a 2D Gaussian pattern.\n"
         "\n"
         "The gaussian antenna pattern is determined by *za_sigma* and\n"
         "*aa_sigma*, which represent the standard deviations in the\n"
         "uncorrelated bivariate normal distribution.\n"
         ),
        AUTHORS( "Cory Davis" ),
        OUT( "mc_antenna" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(         "za_sigma", "aa_sigma" ),
        GIN_TYPE(    "Numeric",  "Numeric" ),
        GIN_DEFAULT( NODEF,      NODEF ),
        GIN_DESC( "Width in the zenith angle dimension as described above.",
                  "Width in the azimuth angle dimension as described above." 
                  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "mc_antennaSetGaussianByFWHM" ),
        DESCRIPTION
        (
         "Makes mc_antenna (used by MCGeneral) a 2D Gaussian pattern.\n"
         "\n"
         "The gaussian antenna pattern is determined by *za_fwhm* and\n"
         "*aa_fwhm*, which represent the full width half maximum (FWHM)\n"
         "of the antenna response, in the zenith and azimuthal planes.\n"
         ),
        AUTHORS( "Cory Davis" ),
        OUT( "mc_antenna" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(         "za_fwhm", "aa_fwhm" ),
        GIN_TYPE(    "Numeric", "Numeric" ),
        GIN_DEFAULT( NODEF,     NODEF ),
        GIN_DESC( "Width in the zenith angle dimension as described above.",
                  "Width in the azimuth angle dimension as described above." 
                  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "mc_antennaSetPencilBeam" ),
        DESCRIPTION
        (
         "Makes mc_antenna (used by MCGeneral) a pencil beam.\n"
         "\n"
         "This WSM makes the subsequent MCGeneral WSM perform pencil beam\n"
         "RT calculations.\n" 
         ),
        AUTHORS( "Cory Davis" ),
        OUT( "mc_antenna" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "MCGeneral" ),
        DESCRIPTION
        ( "A generalised 3D reversed Monte Carlo radiative algorithm, that\n"
          "allows for 2D antenna patterns, surface reflection and arbitrary\n"
          "sensor positions.\n"
          "\n"
          "The main output variables *y* and *mc_error* represent the\n"
          "Stokes vector integrated over the antenna function, and the\n"
          "estimated error in this vector, respectively.\n"
          "\n"
          "The WSV *mc_max_iter* describes the maximum number of `photons\'\n"
          "used in the simulation (more photons means smaller *mc_error*).\n"
          "*mc_std_err* is the desired value of mc_error. *mc_max_time* is\n"
          "the maximum allowed number of seconds for MCGeneral. The method\n"
          "will terminate once any of the max_iter, std_err, max_time\n"
          "criteria are met. If negative values are given for these\n"
          "parameters then it is ignored.\n"
          "\n"
          "The WSV *mc_min_iter* sets the minimum number of photons to apply\n"
          "before the condition set by *mc_std_err* is considered. Values\n"
          "of *mc_min_iter* below 100 are not accepted.\n"
          "\n"
          "Negative values of *mc_seed* seed the random number generator\n"
          "according to system time, positive *mc_seed* values are taken\n"
          "literally.\n"
          "\n"
          "Only \"1\" and \"RJBT\" are allowed for *iy_unit*. The value of\n"
          "*mc_error* follows the selection for *iy_unit* (both for in- and\n"
          "output.\n"
          ),
        AUTHORS( "Cory Davis" ),
        OUT( "y", "mc_iteration_count", "mc_error", "mc_points" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "mc_antenna", "f_grid", "f_index", "sensor_pos", "sensor_los", 
            "stokes_dim", "atmosphere_dim", "ppath_step_agenda", 
            "ppath_lraytrace", "iy_space_agenda", "surface_rtprop_agenda", 
            "propmat_clearsky_agenda", "p_grid",
            "lat_grid", "lon_grid", "z_field", "refellipsoid", "z_surface", 
            "t_field", "vmr_field", "cloudbox_on", "cloudbox_limits", 
            "pnd_field", "scat_data_array_mono", 
            "atmfields_checked", "atmgeom_checked",
            "cloudbox_checked", "mc_seed", "iy_unit", 
            "mc_std_err", "mc_max_time", "mc_max_iter", "mc_min_iter" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "MCSetSeedFromTime" ),
        DESCRIPTION
        ( "Sets the value of mc_seed from system time\n" ),
        AUTHORS( "Cory Davis" ),
        OUT( "mc_seed" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "NumericAdd" ),
        DESCRIPTION
        (
         "Adds a numeric and a value (out = in+value).\n"
         "\n"
         "The result can either be stored in the same or another numeric.\n"
         "(in and out can be the same varible, but not out and value)\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT(      "out"       ),
        GOUT_TYPE( "Numeric" ),
        GOUT_DESC( "Output numeric." ),
        IN(),
        GIN(      "in"      ,
                  "value" ),
        GIN_TYPE(    "Numeric",
                     "Numeric" ),
        GIN_DEFAULT( NODEF   ,
                     NODEF ),
        GIN_DESC( "Input numeric.",
                  "Value to add." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "NumericInvScale" ),
        DESCRIPTION
        (
         "Inversely scales/divides a numeric with a value (out = in/value).\n"
         "\n"
         "The result can either be stored in the same or another numeric.\n"
         "(in and out can be the same varible, but not out and value)\n" 
         ),
        AUTHORS( "Jana Mendrok" ),
        OUT(),
        GOUT(      "out"       ),
        GOUT_TYPE( "Numeric" ),
        GOUT_DESC( "Output numeric." ),
        IN(),
        GIN(      "in"      ,
                  "value" ),
        GIN_TYPE(    "Numeric",
                     "Numeric" ),
        GIN_DEFAULT( NODEF   ,
                     NODEF ),
        GIN_DESC( "Input numeric.",
                  "Scaling value." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "NumericScale" ),
        DESCRIPTION
        (
         "Scales/multiplies a numeric with a value (out = in*value).\n"
         "\n"
         "The result can either be stored in the same or another numeric.\n"
         "(in and out can be the same varible, but not out and value)\n" 
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT(      "out"       ),
        GOUT_TYPE( "Numeric" ),
        GOUT_DESC( "Output numeric." ),
        IN(),
        GIN(      "in"      ,
                  "value" ),
        GIN_TYPE(    "Numeric",
                     "Numeric" ),
        GIN_DEFAULT( NODEF   ,
                     NODEF ),
        GIN_DESC( "Input numeric.",
                  "Scaling value." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "NumericSet" ),
        DESCRIPTION
        (
         "Sets a numeric workspace variable to the given value.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT(      "out"        ),
        GOUT_TYPE( "Numeric" ),
        GOUT_DESC( "Variable to initialize." ),
        IN(),
        GIN(         "value"   ),
        GIN_TYPE(    "Numeric" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "The value." ),
        SETMETHOD( true )
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "nelemGet" ),
        DESCRIPTION
        (
         "Retrieve nelem from given variable and store the value in the\n"
         "variable *nelem*.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( "nelem" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(         "v"    ),
        GIN_TYPE(    ARRAY_GROUPS + ", Vector" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC(    "Variable to get the number of elements from." ),
        SETMETHOD(      false ),
        AGENDAMETHOD(   false ),
        USES_TEMPLATES( true  )
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "ncolsGet" ),
        DESCRIPTION
        (
         "Retrieve ncols from given variable and store the value in the\n"
         "workspace variable *ncols*\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( "ncols" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(         "v" ),
        GIN_TYPE(    "Matrix, Sparse, Tensor3, Tensor4, Tensor5, Tensor6, Tensor7" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC(    "Variable to get the number of columns from." ),
        SETMETHOD(      false ),
        AGENDAMETHOD(   false ),
        USES_TEMPLATES( true  )
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "nrowsGet" ),
        DESCRIPTION
        (
         "Retrieve nrows from given variable and store the value in the\n"
         "workspace variable *nrows*\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( "nrows" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(         "v" ),
        GIN_TYPE(    "Matrix, Sparse, Tensor3, Tensor4, Tensor5, Tensor6, Tensor7" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC(    "Variable to get the number of rows from." ),
        SETMETHOD(      false ),
        AGENDAMETHOD(   false ),
        USES_TEMPLATES( true  )
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "npagesGet" ),
        DESCRIPTION
        (
         "Retrieve npages from given variable and store the value in the\n"
         "workspace variable *npages*\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( "npages" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(         "v" ),
        GIN_TYPE(    "Tensor3, Tensor4, Tensor5, Tensor6, Tensor7" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC(    "Variable to get the number of pages from." ),
        SETMETHOD(      false ),
        AGENDAMETHOD(   false ),
        USES_TEMPLATES( true  )
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "nbooksGet" ),
        DESCRIPTION
        (
         "Retrieve nbooks from given variable and store the value in the\n"
         "workspace variable *nbooks*\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( "nbooks" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(         "v" ),
        GIN_TYPE(    "Tensor4, Tensor5, Tensor6, Tensor7" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC(    "Variable to get the number of books from." ),
        SETMETHOD(      false ),
        AGENDAMETHOD(   false ),
        USES_TEMPLATES( true  )
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "nshelvesGet" ),
        DESCRIPTION
        (
         "Retrieve nshelves from given variable and store the value in the\n"
         "workspace variable *nshelves*\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( "nshelves" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(         "v" ),
        GIN_TYPE(    "Tensor5, Tensor6, Tensor7" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC(    "Variable to get the number of shelves from." ),
        SETMETHOD(      false ),
        AGENDAMETHOD(   false ),
        USES_TEMPLATES( true  )
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "nvitrinesGet" ),
        DESCRIPTION
        (
         "Retrieve nvitrines from given variable and store the value in the\n"
         "workspace variable *nvitrines*\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( "nvitrines" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(         "v" ),
        GIN_TYPE(    "Tensor6, Tensor7" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC(    "Variable to get the number of vitrines from." ),
        SETMETHOD(      false ),
        AGENDAMETHOD(   false ),
        USES_TEMPLATES( true  )
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "nlibrariesGet" ),
        DESCRIPTION
        (
         "Retrieve nlibraries from given variable and store the value in the\n"
         "workspace variable *nlibraries*\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( "nlibraries" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(         "v" ),
        GIN_TYPE(    "Tensor7" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC(    "Variable to get the number of libraries from." ),
        SETMETHOD(      false ),
        AGENDAMETHOD(   false ),
        USES_TEMPLATES( true  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "opt_prop_sptFromData" ),
        DESCRIPTION
        (
         "Calculates opticle properties for the single particle types.\n"
         "\n"
         "In this function the extinction matrix and the absorption vector\n"
         "are calculated in the laboratory frame. An interpolation of the\n"
         "data on the actual frequency is the first step in this function.\n"
         "The next step is a transformation from the database coordinate\n"
         "system to the laboratory coordinate system.\n"
         "\n"
         "Output of the function are *ext_mat_spt* and *abs_vec_spt* which\n"
         "hold the optical properties for a specified propagation direction\n"
         "for each particle type.\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT( "ext_mat_spt", "abs_vec_spt" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "ext_mat_spt", "abs_vec_spt", "scat_data_array", "scat_za_grid", 
            "scat_aa_grid", "scat_za_index", "scat_aa_index", 
            "f_index", "f_grid", "rtp_temperature",
            "pnd_field", "scat_p_index", "scat_lat_index", "scat_lon_index" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "opt_prop_sptFromMonoData" ),
        DESCRIPTION
        (
         "Calculates optical properties for the single particle types.\n"
         "\n"
         "As *opt_prop_sptFromData* but no frequency interpolation is\n"
         "performed. The single scattering data is here obtained from\n"
         "*scat_data_array_mono*, instead of *scat_data_array*.\n"
         ),
        AUTHORS( "Cory Davis" ),
        OUT( "ext_mat_spt", "abs_vec_spt" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "ext_mat_spt", "abs_vec_spt", "scat_data_array_mono", "scat_za_grid", 
            "scat_aa_grid", "scat_za_index", "scat_aa_index", "rtp_temperature",
            "pnd_field", "scat_p_index", "scat_lat_index", "scat_lon_index" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));
 
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "output_file_formatSetAscii" ),
        DESCRIPTION
        (
         "Sets the output file format to ASCII.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( "output_file_format" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "output_file_formatSetBinary" ),
        DESCRIPTION
        (
         "Sets the output file format to binary.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( "output_file_format" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "output_file_formatSetZippedAscii" ),
        DESCRIPTION
        (
         "Sets the output file format to zipped ASCII.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( "output_file_format" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));
    
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "particle_massesFromMetaDataSingleCategory" ),
        DESCRIPTION
        (
         "Sets *particle_masses* based on *scat_meta_array* assuming\n"
         "all particles are of the same mass category.\n"
         "\n"
         "This method calculates the particle masses as density*volume\n"
         "for each particle type. Single phase particles, and that all\n"
         "all particles consist of the same (bulk) matter (e.g. water\n"
         "or ice) are assumed. With other words, a single mass category\n"
         "is assumed (see *particle_masses* for a definition of \"mass\n"
         "category\").\n"
         "\n"
         "To be clear, the above are assumptions of the method, the user\n"
         "is free to work with any particle type. For Earth and just having\n"
         "cloud and particles, the resulting mass category can be seen as\n"
         "the total cloud water content, with possible contribution from\n"
         "both ice and liquid phase.\n"
         ),
        AUTHORS( "Jana Mendrok", "Patrick Eriksson" ),
        OUT( "particle_masses" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "scat_meta_array" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "particle_massesFromMetaDataAndPart_species" ),
        DESCRIPTION
        (
         "Derives *particle_masses* from *scat_meta_array*.\n"
         "\n"
         "This method is supposed to be used to derive *particle_masses*\n"
         "when *pnd_field* is internally calculated using *pnd_fieldSetup*\n"
         "(in contrast to reading it from external sources using\n"
         "*ParticleTypeAdd* and *pnd_fieldCalc*).\n"
         "It extracts particle the mass information (density*volume) from\n"
         "*scat_meta_array*. Different entries in *part_species* are\n"
         "taken as different categories of particle_masses, i.e., the\n"
         "resulting *particle_masses* matrix will contain as many columns as\n"
         "entries exist in *part_species*.\n"
         ),
        AUTHORS( "Jana Mendrok" ),
        OUT( "particle_masses" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "scat_meta_array", "scat_data_per_part_species", "part_species" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "ParticleSpeciesInit" ),
        DESCRIPTION
        (
         "Initializes empty *part_species* array.\n"
         ),
        AUTHORS( "Daniel Kreyling" ),
        OUT( "part_species" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));
    
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "ParticleSpeciesSet" ),
        DESCRIPTION
        (
         "Sets the WSV *part_species*."
         "\n"
         "With this function, the user specifies settings for the \n"
         "particle number density calculations using *pnd_fieldSetup*.\n"
         "The input is an ArrayOfString that needs to be in a specific format,\n"
         "for details, see WSV *part_species*.\n"
         "\n"         
         "*Example:* \t ['IWC-MH97-Ice-0.1-200', 'LWC-H98_STCO-Water-0.1-50'] \n"
         "\n"
         "NOTE: The order of the Strings need to match the order of the\n"
         "*atm_fields_compact* field names, their number determines how many fields\n"
         "of *atm_fields_compact* are considered particle profiles.\n"
         ),
        AUTHORS( "Daniel Kreyling" ),
        OUT( "part_species" ),
        GOUT( ),
        GOUT_TYPE( ),
        GOUT_DESC( ),
        IN(),
        GIN( "particle_tags", "delim" ),
        GIN_TYPE(  "ArrayOfString", "String" ),
        GIN_DEFAULT( NODEF, "-" ),
        GIN_DESC("Array of pnd calculation parameters.",
                 "Delimiter string of *part_species* elements." )
        ));


  md_data_raw.push_back
    ( MdRecord
      ( NAME( "ParticleTypeAdd" ),
        DESCRIPTION
        (
         "Reads single scattering data and corresonding particle number\n"
         "density fields.\n"
         "\n"
         "The methods reads the specified files and appends the obtained data\n"
         "to *scat_data_array* and *pnd_field_raw*.\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT( "scat_data_array", "pnd_field_raw" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atmosphere_dim", "f_grid" ),
        GIN(         "filename_scat_data", "filename_pnd_field" ),
        GIN_TYPE(    "String",             "String"             ),
        GIN_DEFAULT( NODEF,                NODEF                ),
        GIN_DESC( "Name of single scattering data file.",
                  "Name of the corresponding pnd_field file." 
                  )
        ));

 
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "ParticleTypeAddAll" ),
        DESCRIPTION
        (
         "Reads single scattering data and particle number densities.\n"
         "\n"
         "The WSV *pnd_field_raw* containing particle number densities for all\n"
         "scattering particle species can be generated outside ARTS, for example by using\n"
         "PyARTS. This method needs as input an XML-file containing an array of filenames\n"
         "(ArrayOfString) of single scattering data and a file containing the corresponding\n"
         "*pnd_field_raw*. In contrast to the scattering data, all corresponding pnd-fields\n"
         "are stored in a single XML-file containing an ArrayofGriddedField3\n"
         "\n"
         "Important note:\n"
         "The order of the filenames for the scattering data files has to\n"
         "correspond to the order of the pnd-fields, stored in the variable\n"
         "*pnd_field_raw*.\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT( "scat_data_array", "pnd_field_raw" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atmosphere_dim", "f_grid" ),
        GIN(         "filelist_scat_data", "filename_pnd_fieldarray" ),
        GIN_TYPE(    "String",             "String"             ),
        GIN_DEFAULT( NODEF,                NODEF                ),
        GIN_DESC( "Name of file with array of single scattering data filenames.",
                  "Name of file holding the correspnding array of pnd_field data." 
                  )
        ));


  md_data_raw.push_back
    ( MdRecord
      ( NAME( "ParticleTypeInit" ),
        DESCRIPTION
        (
         "Initializes *scat_data_array* and *pnd_field_raw*.\n"
         "\n"
         "This method initializes variables containing data about the\n"
         "optical properties of particles (*scat_data_array*) and about the\n"
         "particle number distribution (*pnd_field_raw*)\n"
         "\n"
         "This method has to be executed before executing e.g.\n"
         "*ParticleTypeAdd*.\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT( "scat_data_array", "pnd_field_raw" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(), 
        GIN_TYPE(), 
        GIN_DEFAULT(),
        GIN_DESC()
        ));


  md_data_raw.push_back
    ( MdRecord
      ( NAME( "ParticleType2abs_speciesAdd" ),
        DESCRIPTION
        (
         "Appends an instance of species 'particles' to *abs_species* including\n"
         "reading single scattering data and corresponding pnd field.\n"
         "\n"
         "The methods reads the specified single scattering and pnd_field\n"
         "data and appends the obtained data to *scat_data_array* and\n"
         "*vmr_field_raw*. It also appends one instance of species 'particles'\n"
         "to *abs_species*.\n"
         ),
        AUTHORS( "Jana Mendrok" ),
        OUT( "scat_data_array", "vmr_field_raw", "abs_species",
             "propmat_clearsky_agenda_checked", "abs_xsec_agenda_checked" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "vmr_field_raw", "abs_species",
            "propmat_clearsky_agenda_checked", "abs_xsec_agenda_checked",
            "atmosphere_dim", "f_grid" ),
        GIN(         "filename_scat_data", "filename_pnd_field" ),
        GIN_TYPE(    "String",             "String"             ),
        GIN_DEFAULT( NODEF,                NODEF                ),
        GIN_DESC( "Name of single scattering data file.",
                  "Name of the corresponding pnd_field file." 
                  )
        ));

 
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "pha_matCalc" ),
        DESCRIPTION
        (
         "This function sums up the phase matrices for all particle\n"
         "types weighted with particle number density.\n"
         ),
        AUTHORS( "Sreerekha T.R." ),
        OUT( "pha_mat" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "pha_mat_spt", "pnd_field", "atmosphere_dim", "scat_p_index",
            "scat_lat_index", "scat_lon_index" ),
        GIN(),
        GIN_TYPE(), 
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "pha_mat_sptFromData" ),
        DESCRIPTION
        (
         "Calculation of the phase matrix for the single particle types.\n"
         "\n"
         "This function can be used in *pha_mat_spt_agenda* as part of\n"
         "the calculation of the scattering integral.\n"
         "\n"
         "The interpolation of the data on the actual frequency is the first\n"
         "step in this function. This is followed by a transformation from the\n"
         "database coordinate system to the laboratory coordinate system.\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT( "pha_mat_spt" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "pha_mat_spt", "scat_data_array", "scat_za_grid", "scat_aa_grid", 
            "scat_za_index", "scat_aa_index", "f_index", "f_grid",
            "rtp_temperature", "pnd_field", "scat_p_index", "scat_lat_index",
            "scat_lon_index" ),
        GIN(),
        GIN_TYPE(), 
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "pha_mat_sptFromMonoData" ),
        DESCRIPTION
        (
         "Calculation of the phase matrix for the single particle types.\n"
         "\n"
         "This function is the monochromatic version of *pha_mat_sptFromData*.\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT( "pha_mat_spt" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "pha_mat_spt", "scat_data_array_mono", "doit_za_grid_size",
            "scat_aa_grid", "scat_za_index", "scat_aa_index", "rtp_temperature",
            "pnd_field", "scat_p_index", "scat_lat_index", "scat_lon_index" ),
        GIN(),
        GIN_TYPE(), 
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "pha_mat_sptFromDataDOITOpt" ),
        DESCRIPTION
        (
         "Calculation of the phase matrix for the single particle types.\n"
         "\n"
         "In this function the phase matrix is extracted from\n"
         "*pha_mat_sptDOITOpt*. It can be used in the agenda\n"
         "*pha_mat_spt_agenda*. This method must be used in \n "
         "combination with *DoitScatteringDataPrepare*.\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT( "pha_mat_spt" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "pha_mat_spt", "pha_mat_sptDOITOpt", "scat_data_array_mono", 
            "doit_za_grid_size",
            "scat_aa_grid", 
            "scat_za_index", "scat_aa_index", "rtp_temperature",
            "pnd_field", "scat_p_index", "scat_lat_index", "scat_lon_index" ),
        GIN(),
        GIN_TYPE(), 
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "pnd_fieldCalc" ),
        DESCRIPTION
        ( "Interpolation of particle number density fields to calculation grid\n"
          "inside cloudbox.\n"
          "\n"
          "This method interpolates the particle number density field\n"
          "from the raw data *pnd_field_raw* to obtain *pnd_field*.\n"
          "For 1D cases, where internally *GriddedFieldPRegrid* and\n"
          "*GriddedFieldLatLonRegrid* are applied, *zeropadding*=1 sets the\n"
          "*pnd_field* at pressure levels levels exceeding pnd_field_raw's\n"
          "pressure grid to 0 (not implemented for 2D and 3D yet). Default:\n"
          "zeropadding=0, which throws an error if the calculation pressure grid\n"
          "*p_grid* is not completely covered by pnd_field_raw's pressure grid.\n"
          ),
        AUTHORS( "Sreerekha T.R.", "Claudia Emde", "Oliver Lemke" ),
        OUT( "pnd_field" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "p_grid", "lat_grid", "lon_grid", "pnd_field_raw", "atmosphere_dim",
            "cloudbox_limits" ),
        GIN( "zeropadding" ),
        GIN_TYPE( "Index" ),
        GIN_DEFAULT( "0" ),
        GIN_DESC( "Allow zeropadding of pnd_field." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "pnd_fieldExpand1D" ),
        DESCRIPTION
        (
         "Maps a 1D pnd_field to a (homogeneous) 2D or 3D pnd_field.\n"
         "\n"
         "This method takes a 1D *pnd_field* and converts it to a 2D or 3D\n"
         "\"cloud\". It is assumed that a complete 1D case has been created,\n"
         "and after this *atmosphere_dim*, *lat_grid*, *lon_grid* and\n"
         "*cloudbox_limits* have been changed to a 2D or 3D case (without\n"
         "changing the vertical extent of the cloudbox.\n"
         "\n"
         "No modification of *pnd_field* is made for the pressure dimension.\n"
         "At the latitude and longitude cloudbox edge points *pnd_field* is set to\n"
         "zero. This corresponds to nzero=1. If you want a larger margin between\n"
         "the lat and lon cloudbox edges and the \"cloud\" you increase\n"
         "*nzero*, where *nzero* is the number of grid points for which\n"
         "*pnd_field* shall be set to 0, counted from each lat and lon edge.\n"
         "\n"
         "See further *AtmFieldsExpand1D*.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "pnd_field" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "pnd_field", "atmosphere_dim",
            "cloudbox_on", "cloudbox_limits" ),
        GIN( "nzero" ),
        GIN_TYPE( "Index"),
        GIN_DEFAULT( "1" ),
        GIN_DESC( "Number of zero values inside lat and lon limits." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "pnd_fieldSetup" ),
        DESCRIPTION
        (
         "Calculation of *pnd_field* using ScatteringMetaData and *massdensity_field*.\n"
         "\n"
         "The WSM first checks if cloudbox is empty. If so, the pnd calculations\n"
         "will be skipped.\n"
         "The *cloudbox_limits* are used to determine the p, lat and lon size for\n"
         "the *pnd_field* tensor.\n"
         "Currently there are three particle size distribution (PSD) parameterisations\n"
         "implemented:\n"
         "\t1. 'MH97' for ice particles. Parameterisation in temperature and mass content.\n"
         "\t Using a first-order gamma distribution for particles smaller than \n"
         "\t 100 microns (melted diameter) and a lognormal distribution for\n"
         "\t particles bigger 100 microns. Values from both modes are cumulative.\n"
         "\t See internal function 'IWCtopnd_MH97' for implementation/units/output.\n"
         "\t (src.: McFarquhar G.M., Heymsfield A.J., 1997)"
         "\n"
	 "\t2. 'H11' for cloud ice and precipitating ice (snow). H11 is NOT dependent\n"
	 "\t on mass content of ice/snow, but only on atmospheric temperature.\n"
	 "\t The PSD is scaled to the current IWC/Snow density in an additional step.\n"
	 "\t See internal function 'pnd_H11' and 'scale_H11' for implementation/units/output.\n"
	 "\t (src.: Heymsfield A.J., 2011, not published yet)\n"
         "\t3. 'H98_STCO' for liquid water clouds. Using a gamma distribution with\n"
         "\t parameters from Hess et al., 1998, continental stratus.\n"
         "\t See internal function 'LWCtopnd' for implementation/units/output.\n"
         "\t (src.: Deirmendjian D., 1963 and Hess M., et al 1998)\n"
         "\n"
         "According to the selection criteria in *part_species*, the first specified\n" 
         "psd parametrisation is selected together with all particles of specified phase\n"
         "and size. Then pnd calculations are performed on all levels inside the cloudbox.\n"
         "The *massdensity_field* input weights the pnds by the amount of scattering\n" 
         "particles in each gridbox inside the cloudbox. Where *massdensity_field* is zero,\n"
         "the *pnd_field* will be zero as well.\n"
         "Subsequently the pnd values get written to *pnd_field*.\n"
         "\n"
         "Now the next selection criteria string in *part_species* is used to repeat\n"
         "the process.The new pnd values will be appended to the existing *pnd_field*.\n"
         "And so on...\n"
         "\n"
         "NOTE: the order of scattering particle profiles in *massdensity_field* has to\n"
         "fit the order of part_species tags!\n"
         ),
        AUTHORS( "Daniel Kreyling" ),
        OUT( "pnd_field"),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atmosphere_dim","cloudbox_on", "cloudbox_limits",
            "massdensity_field", "t_field", "scat_meta_array",
            "part_species", "scat_data_per_part_species" ),
        GIN( "delim" ),
        GIN_TYPE( "String" ),
        GIN_DEFAULT( "-" ),
        GIN_DESC( "Delimiter string of *part_species* elements" )
        ));  
    
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "pnd_fieldZero" ),
        DESCRIPTION
        (
         "Sets *pnd_field* to hold only zeros.\n"
         "\n"
         "Scattering calculations using the DOIT method include\n"
         "interpolation errors. If one is interested in this effect, one\n"
         "should compare the DOIT result with a clearsky calculation using\n"
         "an empty cloudbox. That means that the iterative method is\n"
         "performed for a cloudbox including no particles. This method sets\n"
         "the particle number density field to zero and creates a\n"
         "dummy *scat_data_array* structure. \n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT( "pnd_field", "scat_data_array" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "p_grid", "lat_grid", "lon_grid" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "ppathCalc" ),
        DESCRIPTION
        (
         "Stand-alone calculation of propagation paths.\n"
         "\n"
         "Beside a few checks of input data, the only operation of this\n"
         "method is to execute *ppath_agenda*.\n"
         "\n"
         "Propagation paths are normally calculated as part of the radiative\n"
         "transfer calculations, and this method is not part of the control\n"
         "file. A reason to call this function directly would be to obtain a\n"
         "propagation path for plotting. Anyhow, use this method instead\n"
         "of calling e.g.*ppathStepByStep directly.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "ppath" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "ppath_agenda", "ppath_lraytrace", "atmgeom_checked", "t_field", 
            "z_field", "vmr_field", "f_grid",  "cloudbox_on", 
            "cloudbox_checked", "ppath_inside_cloudbox_do", 
            "rte_pos", "rte_los", "rte_pos2" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "ppathFromRtePos2" ),
        DESCRIPTION
        (
         "Determines the propagation path from *rte_pos2* to *rte_pos*.\n"
         "\n"
         "The propagation path linking *rte_pos* and *rte_pos2* is calculated\n"
         "and returned. The method determines the path in a pure numerical\n"
         "manner, where a simple algorithm is applied. The task is to find\n"
         "the value of *rte_los* (at *rte_pos*) linking the two positions.\n"
         "\n"
         "See the user guide for a description of the search algorithm,\n"
         "including a more detailed definition of *za_accuracy*, \n"
         "*pplrt_factor* and *pplrt_lowest*.\n"
         "\n"
         "The standard application of this method should be to radio link\n"
         "calculations, where *rte_pos2* corresponds to a transmitter, and\n"
         "*rte_pos* to the receiver/sensor.\n"
         "\n"
         "The details of the ray tracing is controlled by *ppath_step_agenda*\n"
         "as usual.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "ppath", "rte_los", "ppath_lraytrace" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "ppath_step_agenda", "atmosphere_dim", "p_grid", 
            "lat_grid", "lon_grid", "t_field", "z_field", "vmr_field", 
            "f_grid", "refellipsoid", "z_surface", 
            "rte_pos", "rte_pos2", "rte_los", "ppath_lraytrace" ),
        GIN( "za_accuracy", "pplrt_factor", "pplrt_lowest" ),
        GIN_TYPE( "Numeric", "Numeric", "Numeric" ),
        GIN_DEFAULT( "2e-5", "5", "0.5"),
        GIN_DESC( 
                 "Required accuracy, in form of the maximum allowed angular "
                 "off-set [deg].",
                 "The factor with which ppath_lraytrace is decreased if "
                 "no solution is found.",
                 "Lowest value ppath_lraytrace to consider. The calculations "
                 "are halted if this length is passed.")
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "ppathStepByStep" ),
        DESCRIPTION
        (
         "Standard method for calculation of propagation paths.\n"
         "\n"
         "This method calculates complete propagation paths in a stepwise\n"
         "manner. Each step is denoted as a \"ppath_step\" and is the path\n"
         "through/inside a single grid box.\n"
         "\n"
         "The definition of a propgation path cannot be accommodated here.\n"
         "For more information read the chapter on propagation paths in the\n"
         "ARTS user guide.\n"
         "\n"
         "This method should never be called directly. Use *ppathCalc* instead\n"
         "if you want to extract propagation paths.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "ppath" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "ppath_step_agenda", "ppath_inside_cloudbox_do", "atmosphere_dim", 
            "p_grid", "lat_grid", "lon_grid", "t_field", "z_field", "vmr_field",
            "f_grid", "refellipsoid", "z_surface", 
            "cloudbox_on", "cloudbox_limits", "rte_pos", "rte_los", 
            "ppath_lraytrace" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "ppathWriteXMLPartial" ),
        DESCRIPTION
        (
         "WSM to only write a reduced Ppath, omitting grid positions.\n"
         "\n"
         "The following fields are set to be empty: gp_p, gp_lat and gp_lon.\n"
         "This cam drastically decrease the time for reading the structure\n"
         "by some external software.\n"
         "\n"
         "If *file_index is >= 0, the variable is written to a file with name:\n"
         "   <filename>.<file_index>.xml.\n"
         "where <file_index> is the value of *file_index*.\n"
         "\n"
         "This means that *filename* shall here not include the .xml\n"
         "extension. Omitting filename works as for *WriteXML*.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT(),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "output_file_format", "ppath" ),
        GIN(          "filename", "file_index" ),
        GIN_TYPE(     "String",   "Index" ),
        GIN_DEFAULT(  "",         "-1" ),
        GIN_DESC( "File name. See above.",
                  "Optional file index to append to filename."
                  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "ppath_stepGeometric" ),
        DESCRIPTION
        (
         "Calculates a geometrical propagation path step.\n"
         "\n"
         "This function determines a propagation path step by pure\n"
         "geometrical calculations. That is, refraction is neglected. Path\n"
         "points are always included for crossings with the grids, tangent\n"
         "points and intersection points with the surface. The WSV *ppath_lmax*\n"
         "gives the option to include additional points to ensure that the\n"
         "distance along the path between the points does not exceed the\n"
         "selected maximum length. No additional points are included if\n"
         "*ppath_lmax* is set to <= 0.\n"
         "\n"
         "For further information, type see the on-line information for\n"
         "*ppath_step_agenda*.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "ppath_step" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "ppath_step", "atmosphere_dim", "lat_grid", "lon_grid", 
            "z_field", "refellipsoid", "z_surface", "ppath_lmax" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "ppath_stepRefractionBasic" ),
        DESCRIPTION
        (
         "Calculates a propagation path step, considering refraction by a\n"
         "basic approach.\n"
         "\n"
         "Refraction is taken into account by probably the simplest approach\n"
         "possible. The path is treated to consist of piece-wise geometric\n"
         "steps. A geometric path step is calculated from each point by\n"
         "using the local line-of-sight. Snell's law for spherical symmetry\n"
         "is used for 1D to determine the zenith angle at the new point.\n"
         "For 2D and 3D, the zenith angle is calculated using the average\n"
         "gradient of the refractive index between the two points. For 3D,\n"
         "the azimuth angle is treated in the same way as the zenith one.\n"
         "\n"
         "The maximum length of each ray tracing step is given by the WSV\n"
         "*ppath_lraytrace*. The length will never exceed the given maximum,\n" 
         "but it can be smaller. The ray tracing steps are only used to\n"
         "determine the path. Points to describe the path are included as\n"
         "for *ppath_stepGeometric*, this including the functionality of\n"
         "*ppath_lmax*.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "ppath_step" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "refr_index_air_agenda", "ppath_step", "atmosphere_dim", "p_grid", 
            "lat_grid", "lon_grid", "z_field", "t_field", "vmr_field", 
            "refellipsoid", "z_surface", "f_grid",
            "ppath_lmax", "ppath_lraytrace" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "Print" ),
        DESCRIPTION
        (
         "Prints a variable on the screen.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT(),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(         "in"   ,
                     "level" ),
        GIN_TYPE(    "Any",
                     "Index" ),
        GIN_DEFAULT( NODEF,
                     "1" ),
        GIN_DESC(    "Variable to be printed.",
                     "Output level to use." ),
        SETMETHOD(      false ),
        AGENDAMETHOD(   false ),
        USES_TEMPLATES( true  )
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "PrintWorkspace" ),
        DESCRIPTION
        (
         "Prints a list of the workspace variables.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT(),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN( "only_allocated", "level" ),
        GIN_TYPE(    "Index",          "Index" ),
        GIN_DEFAULT( "1",              "1" ),
        GIN_DESC( "Flag for printing either all variables (0) or only "
                  "allocated ones (1).",
                  "Output level to use." ),
        SETMETHOD(      false ),
        AGENDAMETHOD(   false ),
        USES_TEMPLATES( true  ),
        PASSWORKSPACE( true  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "propmat_clearskyAddFaraday" ),
        DESCRIPTION
        (
         "Calculates absorption matrix describing Faraday rotation.\n"
         "\n"
         "Faraday rotation is a change of polarization state of an\n"
         "electromagnetic wave propagating through charged matter by\n"
         "interaction with a magnetic field. Hence, this method requires\n"
         "*abs_species* to contain 'free_electrons' and electron content field\n"
         "(as part of *vmr_field*) as well as magnetic field (*mag_u_field*,\n"
         "*mag_v_field*, *mag_w_field*) to be specified.\n"
         "\n"
         "Faraday rotation affects Stokes parameters 2 and 3 (but not\n"
         "intensity!). Therefore, this method requires stokes_dim>2.\n"
         "\n"
         "Like all 'propmat_clearskyAdd*' methods, the method is additive,\n"
         "i.e., does not overwrite the propagation matrix *propmat_clearsky*,\n"
         "but adds further contributions.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "propmat_clearsky" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "propmat_clearsky", "stokes_dim", "atmosphere_dim", "f_grid", 
            "abs_species", "rtp_vmr", "rtp_los", "rtp_mag" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "propmat_clearskyAddFromAbsCoefPerSpecies" ),
        DESCRIPTION
        (
         "Copy *propmat_clearsky* from *abs_coef_per_species*. This is handy for putting an\n"
         "explicit line-by-line calculation into the\n"
         "*propmat_clearsky_agenda*. This method is also used internally by.\n"
         "*propmat_clearskyAddOnTheFly*.\n"
         "Like all other propmat_clearsky methods, this method does not overwrite\n"
         "prior content of *propmat_clearsky*, but adds to it.\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT( "propmat_clearsky" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "propmat_clearsky","abs_coef_per_species" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));
  
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "propmat_clearskyAddFromLookup" ),
        DESCRIPTION
        (
         "Extract gas absorption coefficients from lookup table.\n"
         "\n"
         "This extracts the absorption coefficient for all species from the\n"
         "lookup table, and adds them to the propagation matrix. Extraction is\n"
         "for one specific atmospheric condition, i.e., a set of pressure,\n"
         "temperature, and VMR values.\n"
         "\n"
         "Some special species are ignored, for example Zeeman species and free\n"
         "electrons, since their absorption properties are not simple scalars\n"
         "and cannot be handled by the lookup table.\n"
         "\n"
         "The interpolation order in T and H2O is given by *abs_t_interp_order*\n"
         "and *abs_nls_interp_order*, respectively.\n"
         "\n"
         "Extraction is done for the frequencies in f_grid. Frequency\n"
         "interpolation is controlled by *abs_f_interp_order*. If this is zero,\n"
         "then f_grid must either be the same as the internal frequency grid of\n"
         "the lookup table (for efficiency reasons, only the first and last\n"
         "element of f_grid are checked), or must have only a single element.\n"
         "If *abs_f_interp_order* is above zero, then frequency is interpolated\n"
         "along with the other interpolation dimensions. This is useful for\n"
         "calculations with Doppler shift.\n"
         "\n"
         "For Doppler calculations, you should generate the table with a\n"
         "somewhat larger frequency grid than the calculation itself has, since\n"
         "the Doppler shift will push the frequency grid out of the table range\n"
         "on one side. Alternatively, you can set the input\n"
         "parameter *extpolfac* to a larger value, to allow extrapolation at the\n"
         "edges.\n"
         "\n"
         "See also: *propmat_clearskyAddOnTheFly*.\n"
         ),
        AUTHORS( "Stefan Buehler, Richard Larsson" ),
        OUT( "propmat_clearsky" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "propmat_clearsky", "abs_lookup", "abs_lookup_is_adapted",
            "abs_p_interp_order", "abs_t_interp_order", "abs_nls_interp_order",
            "abs_f_interp_order", "f_grid",
            "rtp_pressure", "rtp_temperature", "rtp_vmr" ),
        GIN("extpolfac"),
        GIN_TYPE("Numeric"),
        GIN_DEFAULT("0.5"),
        GIN_DESC("Extrapolation factor (for grid edges).")
        ));
    
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "propmat_clearskyAddOnTheFly" ),
        DESCRIPTION
        (
         "Calculates gas absorption coefficients line-by-line.\n"
         "\n"
         "This method can be used inside *propmat_clearsky_agenda* just like\n"
         "*propmat_clearskyAddFromLookup*. It is a shortcut for putting in some\n"
         "other methods explicitly, namely:\n"
         "\n"
         "  1. *AbsInputFromRteScalars*\n"
         "  2. Execute *abs_xsec_agenda*\n"
         "  3. *abs_coefCalcFromXsec*\n"
         "  4. *propmat_clearskyAddFromAbsCoefPerSpecies*\n"
         "\n"
         "The calculation is for one specific atmospheric condition, i.e., a set\n"
         "of pressure, temperature, and VMR values.\n"
         ),
        AUTHORS( "Stefan Buehler, Richard Larsson" ),
        OUT( "propmat_clearsky" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "propmat_clearsky",
            "f_grid",
            "abs_species",
            "rtp_pressure", "rtp_temperature", "rtp_vmr",
            "abs_xsec_agenda"
           ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "propmat_clearskyAddParticles" ),
        DESCRIPTION
        (
         "Calculates absorption coefficients of particles to be used in\n"
         "clearsky (non-cloudbox) calculations.\n"
         "\n"
         "This is a method to include particles (neglecting possible\n"
         "scattering components) in a clearsky calculation, i.e. without\n"
         "applying the cloudbox and scattering solvers. Particles are handled\n"
         "as absorbing species with one instance of 'particles' per particle\n"
         "type considered added to *abs_species*. Particle absorption cross-\n"
         "sections at current atmospheric conditions are extracted from the\n"
         "single scattering data stored in *scat_data_array*, i.e., one array\n"
         "element per 'particles' instance in *abs_species* is required. Number\n"
         "densities are stored in *vmr_field_raw* or *vmr_field* as for all\n"
         "*abs_species*, but can be taken from (raw) pnd_field type data.\n"
         "\n"
         "A line-of-sight direction *rtp_los* is required as particles can\n"
         "exhibit directional dependent absorption properties, which is taken\n"
         "into account by this method."
         "\n"
         "*ParticleType2abs_speciesAdd* can be used to add all required\n"
         "settings/data for a single particle type at once, i.e. a 'particles'\n"
         "tag to *abs_species*, a set of single scattering data to\n"
         "*scat_data_array* and a number density field to *vmr_field_raw*\n"
         "(*vmr_field* is derived applying AtmFieldsCalc once VMRs for all\n"
         "*abs_species* have been added).\n"
         "\n"
         "Like all 'propmat_clearskyAdd*' methods, the method is additive,\n"
         "i.e., does not overwrite the propagation matrix *propmat_clearsky*,\n"
         "but adds further contributions.\n"
         ),
        AUTHORS( "Jana Mendrok" ),
        OUT( "propmat_clearsky" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "propmat_clearsky", "stokes_dim", "atmosphere_dim",
            "f_grid", "abs_species",
            "rtp_vmr", "rtp_los", "rtp_temperature", "scat_data_array" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "propmat_clearskyAddZeeman" ),
        DESCRIPTION
        (
        "Calculates Zeeman-effected absorption coefficients.\n"
        "\n"
        "This method will, for each Zeeman species, make a local\n"
        "ArrayOfLineRecord for the various transition types with Zeeman\n"
        "altered LineRecord(s).  These are then composed into a single\n"
        "ArrayOfArrayOfLineRecord which is processed as per the scalar case.\n"
        "\n"
        "The line broadened absorption coefficients are finally multiplied with\n"
        "the transition type rotation matrix and the new variable is inserted into\n"
        "the out variable. Only species containing a -Z- tag are treated.\n"
        "\n"
        "Note that between 55 GHz and 65 GHz there is usually ~700 O_2 lines,\n"
        "however, when this Zeeman splitting method is used, the number of\n"
        "lines is increased to about 45,000. Be aware that this is a time\n"
        "consuming method.\n"
        "\n"
        "The 'manual_zeeman*' variables will let the user set their own simple\n"
        "magnetic field.  This path can be accessed by setting\n"
        "*manual_zeeman_tag* different from zero.  The user is also advided to\n"
        "read the theory guide to understand what the different variables will\n"
        "do in the Zeeman theory.  Note that angles are in degrees and strength\n"
        "in Tesla.\n"
         ),
        AUTHORS( "Richard Larsson" ),
        OUT("propmat_clearsky"),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN("propmat_clearsky",
           "f_grid",
           "abs_species",
           "abs_lines_per_species",
           "abs_lineshape",
           "isotopologue_ratios",
           "isotopologue_quantum",
           "rtp_pressure", "rtp_temperature", "rtp_vmr",
           "rtp_mag", "rtp_los", "atmosphere_dim",
           "line_mixing_data", "line_mixing_data_lut" ),
        GIN("manual_zeeman_tag","manual_zeeman_magnetic_field_strength",
            "manual_zeeman_theta","manual_zeeman_eta"),
        GIN_TYPE("Index","Numeric","Numeric","Numeric"),
        GIN_DEFAULT("0","1.0","0.0","0.0"),
        GIN_DESC("Manual angles tag","Manual Magnetic Field Strength",
                 "Manual theta given positive tag","Manual eta given positive tag")
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "propmat_clearskyInit" ),
        DESCRIPTION
        (
         "Initialize *propmat_clearsky*.\n"
         "\n"
         "This method must be used inside *propmat_clearsky_agenda* and then\n"
         "be called first.\n"
         ),
        AUTHORS( "Oliver Lemke, Richard Larsson" ),
        OUT( "propmat_clearsky" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_species",
            "f_grid",
            "stokes_dim",
            "propmat_clearsky_agenda_checked"
        ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));
    
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "propmat_clearskyZero" ),
        DESCRIPTION
        (
         "Sets *propmat_clearsky* to match zero attenuation.\n"
         "\n"
         "Use this method just if you know what you are doing!\n"
         "\n"
         "If you want to make a calculation with no clear-sky attenuation at\n"
         "all, fill *propmat_clearsky_agenda* with this method and required\n"
         "Ignore statements (don't include *propmat_clearskyInit*).\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "propmat_clearsky" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "f_grid", "stokes_dim" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));
    
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "propmat_clearsky_agenda_checkedCalc" ),
        DESCRIPTION
        (
         "Checks if the *propmat_clearsky_agenda* contains all necessary\n"
         "methods to calculate all the species in *abs_species*.\n"
         "\n"
         "This method should be called just before the *propmat_clearsky_agenda*\n"
         "is used, e.g. *CloudboxGetIncoming*, *ybatchCalc*, *yCalc*\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( "propmat_clearsky_agenda_checked" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_species", "propmat_clearsky_agenda" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "propmat_clearsky_fieldCalc" ),
        DESCRIPTION
        (
         "Calculate (vector) gas absorption coefficients for all points in the\n"
         "atmosphere.\n"
         "\n"
         "This is useful in two different contexts:\n"
         "\n"
         "1. For testing and plotting gas absorption. (For RT calculations, gas\n"
         "absorption is calculated or extracted locally, therefore there is no\n"
         "need to calculate a global field. But this method is handy for easy\n"
         "plotting of absorption vs. pressure, for example.)\n"
         "\n"
         "2. Inside the scattering region, monochromatic absorption is\n"
         "pre-calculated for the entire atmospheric field.\n"
         "\n"
         "The calculation itself is performed by the\n"
         "*propmat_clearsky_agenda*.\n"
         ),
        AUTHORS( "Stefan Buehler, Richard Larsson" ),
        OUT( "propmat_clearsky_field" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atmfields_checked", "f_grid", "stokes_dim",
            "p_grid", "lat_grid", "lon_grid",
            "t_field", "vmr_field",
            "mag_u_field", "mag_v_field", "mag_w_field",
            "propmat_clearsky_agenda" ),
        GIN("doppler", "los"),
        GIN_TYPE("Vector", "Vector"),
        GIN_DEFAULT("[]", "[]"),
        GIN_DESC("A vector of doppler shift values in Hz. Must either be "
                 "empty or have same dimension as p_grid.",
                 "Line of sight"
                 )
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "p_gridDensify" ),
        DESCRIPTION
        (
         "A simple way to make *p_grid* more dense.\n"
         "\n"
         "The method includes new values in *p_grid*. For each intermediate\n"
         "pressure range, *nfill* points are added. That is, setting *nfill*\n"
         "to zero returns an unmodified *p_grid*. The number of elements of\n"
         "the new *p_grid* is (n0-1)*(1+nfill)+1, where n0 is the original\n"
         "length.\n"
         "\n"
         "The new points are distributed equidistant in log(p).\n"         
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "p_grid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "p_grid" ),
        GIN(         "nfill" ),
        GIN_TYPE(    "Index" ),
        GIN_DEFAULT( "-1" ),
        GIN_DESC( "Number of points to add between adjacent pressure points."
                  "The default value (-1) results in an error." )
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "p_gridFromZRaw" ),
        DESCRIPTION
        (
         "Sets *p_grid* according to input atmosphere's raw z_field, derived\n"
         "e.g. from *AtmRawRead*.\n"
         "Attention: as default only pressure values for altitudes >= 0 are\n"
         "extracted. If negative altitudes shall also be selected, set no_neg=0.\n"
         ),
        AUTHORS( "Claudia Emde, Jana Mendrok" ),
        OUT( "p_grid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "z_field_raw" ),
        GIN(         "no_negZ" ),
        GIN_TYPE(    "Index" ),
        GIN_DEFAULT( "1" ),
        GIN_DESC(    "Exclude negative altitudes." )
        ));
 
  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "p_gridFromGasAbsLookup" ),
        DESCRIPTION
        (
         "Sets *p_grid* to the pressure grid of *abs_lookup*.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "p_grid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_lookup" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "ReadNetCDF" ),
        DESCRIPTION
        (
         "Reads a workspace variable from a NetCDF file.\n"
         "\n"
         "This method can read variables of any group.\n"
         "\n"
         "If the filename is omitted, the variable is read\n"
         "from <basename>.<variable_name>.nc.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT(),
        GOUT(      "out"    ),
        GOUT_TYPE( "Vector, Matrix, Tensor3, Tensor4, Tensor5, ArrayOfVector,"
                   "ArrayOfMatrix, GasAbsLookup" ),
        GOUT_DESC( "Variable to be read." ),
        IN(),
        GIN(         "filename" ),
        GIN_TYPE(    "String"   ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC(    "Name of the NetCDF file." ),
        SETMETHOD(      false ),
        AGENDAMETHOD(   false ),
        USES_TEMPLATES( true  ),
        PASSWORKSPACE(  false ),
        PASSWSVNAMES(   true  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "ReadXML" ),
        DESCRIPTION
        (
         "Reads a workspace variable from an XML file.\n"
         "\n"
         "This method can read variables of any group.\n"
         "\n"
         "If the filename is omitted, the variable is read\n"
         "from <basename>.<variable_name>.xml.\n"
         "If the given filename does not exist, this method will\n"
         "also look for files with an added .xml, .xml.gz and .gz extension\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT(),
        GOUT(      "out"    ),
        GOUT_TYPE( "Any" ),
        GOUT_DESC( "Variable to be read." ),
        IN(),
        GIN(         "filename" ),
        GIN_TYPE(    "String"   ),
        GIN_DEFAULT( "" ),
        GIN_DESC(    "Name of the XML file." ),
        SETMETHOD(      false ),
        AGENDAMETHOD(   false ),
        USES_TEMPLATES( true  ),
        PASSWORKSPACE(  false ),
        PASSWSVNAMES(   true  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Reduce" ),
        DESCRIPTION
        (
         "Reduces a larger class to a smaller class of same size.\n"
         "\n"
         "The Reduce command reduces all \"1\"-dimensions to nil.  Examples:\n"
         "\t1) 1 Vector can be reduced to a Numeric\n"
         "\t2) 2x1 Matrix can be reduced to 2 Vector\n"
         "\t3) 1x3x1 Tensor3 can be reduced to 3 Vector\n"
         "\t4) 1x1x1x1 Tensor4 can be reduced to a Numeric\n"
         "\t5) 3x1x4x1x5 Tensor5 can only be reduced to 3x4x5 Tensor3\n"
         "\t6) 1x1x1x1x2x3 Tensor6 can be reduced to 2x3 Matrix\n"
         "\t7) 2x3x4x5x6x7x1 Tensor7 can be reduced to 2x3x4x5x6x7 Tensor6\n"
         "And so on\n"
         ),
        AUTHORS( "Oliver Lemke", "Richard Larsson" ),
        OUT(),
        GOUT( "o" ),
        GOUT_TYPE( "Numeric, Numeric, Numeric, Numeric, Numeric, Numeric, Numeric,"
                   "Vector, Vector, Vector, Vector, Vector, Vector,"
                   "Matrix, Matrix, Matrix, Matrix, Matrix,"
                   "Tensor3, Tensor3, Tensor3, Tensor3,"
                   "Tensor4, Tensor4, Tensor4,"
                   "Tensor5, Tensor5,"
                   "Tensor6"),
        GOUT_DESC( "Reduced form of input." ),
        IN(),
        GIN( "i" ),
        GIN_TYPE( "Vector, Matrix, Tensor3, Tensor4, Tensor5, Tensor6, Tensor7,"
                  "Matrix, Tensor3, Tensor4, Tensor5, Tensor6, Tensor7,"
                  "Tensor3, Tensor4, Tensor5, Tensor6, Tensor7,"
                  "Tensor4, Tensor5, Tensor6, Tensor7,"
                  "Tensor5, Tensor6, Tensor7,"
                  "Tensor6, Tensor7,"
                  "Tensor7"),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "Over-dimensioned input" ),
        SETMETHOD(      false ),
        AGENDAMETHOD(   false ),
        USES_TEMPLATES( false  )
        ));
        
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "refellipsoidEarth" ),
        DESCRIPTION
        (
         "Earth reference ellipsoids.\n"
         "\n"
         "The reference ellipsoid (*refellipsoid*) is set to model the Earth,\n"
         "following different models. The options are:\n"
         "\n"
         "   \"Sphere\" : A spherical Earth. The radius is set following\n"
         "      the value set for the Earth radius in constants.cc.\n"
         "\n"
         "   \"WGS84\" : The reference ellipsoid used by the GPS system.\n"
         "      Should be the standard choice for a non-spherical Earth.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "refellipsoid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(  ),
        GIN( "model" ),
        GIN_TYPE(    "String" ),
        GIN_DEFAULT( "Sphere" ),
        GIN_DESC( "Model ellipsoid to use. Options listed above." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "refellipsoidForAzimuth" ),
        DESCRIPTION
        (
         "Conversion of 3D ellipsoid to 1D curvature radius.\n"
         "\n"
         "Calculates the curvature radius for the given latitude and azimuth\n"
         "angle, and uses this to set a spherical reference ellipsoid\n"
         "suitable for 1D calculations. The curvature radius is a better\n"
         "local approximation than using the local ellipsoid radius.\n"
         "\n"
         "The used expression assumes a geodetic latitude, but also\n"
         "latitudes should be OK as using this method anyhow signifies\n"
         "an approximation.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "refellipsoid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "refellipsoid" ),
        GIN( "latitude", "azimuth" ),
        GIN_TYPE( "Numeric", "Numeric" ),
        GIN_DEFAULT( NODEF, NODEF ),
        GIN_DESC( "Latitude.", "Azimuth angle." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "refellipsoidJupiter" ),
        DESCRIPTION
        (
         "Jupiter reference ellipsoids.\n"
         "\n"
         "The reference ellipsoid (*refellipsoid*) is set to model Jupiter,\n"
         "folowing different models. The options are:\n"
         "\n"
         "   \"Sphere\" : A spherical planet. The radius is taken from a\n"
         "      report of the IAU/IAG Working Group.\n"
         "\n"
         "   \"Ellipsoid\" : A reference ellipsoid with parameters taken from\n"
         "      a report of the IAU/IAG Working Group.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "refellipsoid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(  ),
        GIN( "model" ),
        GIN_TYPE(    "String" ),
        GIN_DEFAULT( "Sphere" ),
        GIN_DESC( "Model ellipsoid to use. Options listed above." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "refellipsoidMars" ),
        DESCRIPTION
        (
         "Mars reference ellipsoids.\n"
         "\n"
         "The reference ellipsoid (*refellipsoid*) is set to model Mars,\n"
         "folowing different models. The options are:\n"
         "\n"
         "   \"Sphere\" : A spherical planet. The radius is taken from a\n"
         "      report of the IAU/IAG Working Group.\n"
         "\n"
         "   \"Ellipsoid\" : A reference ellipsoid with parameters taken from\n"
         "      a report of the IAU/IAG Working Group.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "refellipsoid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(  ),
        GIN( "model" ),
        GIN_TYPE(    "String" ),
        GIN_DEFAULT( "Sphere" ),
        GIN_DESC( "Model ellipsoid to use. Options listed above." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "refellipsoidMoon" ),
        DESCRIPTION
        (
         "Moon reference ellipsoids.\n"
         "\n"
         "The reference ellipsoid (*refellipsoid*) is set to model Moon,\n"
         "folowing different models. The options are:\n"
         "\n"
         "   \"Sphere\" : A spherical planet. The radius is taken from a\n"
         "      report of the IAU/IAG Working Group.\n"
         "\n"
         "   \"Ellipsoid\" : A reference ellipsoid with parameters taken from\n"
         "      Wikepedia (see code for details). The IAU/IAG working group\n"
         "      defines the Moon ellipsoid to be a sphere.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "refellipsoid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(  ),
        GIN( "model" ),
        GIN_TYPE(    "String" ),
        GIN_DEFAULT( "Sphere" ),
        GIN_DESC( "Model ellipsoid to use. Options listed above." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "refellipsoidOrbitPlane" ),
        DESCRIPTION
        (
         "Conversion of 3D ellipsoid to 2D orbit track geometry.\n"
         "\n"
         "Determines an approximate reference ellipsoid following an orbit\n"
         "track. The new ellipsoid is determined simply, by determining the\n"
         "radius at the maximum latitude and from this value calculate a new\n"
         "new eccentricity. The orbit is specified by giving the orbit\n"
         "inclination (*orbitinc*), that is normally a value around 100 deg\n"
         "for polar sun-synchronous orbits.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "refellipsoid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "refellipsoid" ),
        GIN( "orbitinc" ),
        GIN_TYPE(    "Numeric" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "Orbit inclination." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "refellipsoidSet" ),
        DESCRIPTION
        (
         "Manual setting of the reference ellipsoid.\n"
         "\n"
         "The two values of *refellipsoid* can here be set manually. The two\n"
         "arguments correspond directly to first and second element of\n"
         "*refellipsoid*.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "refellipsoid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(  ),
        GIN( "re", "e" ),
        GIN_TYPE(    "Numeric", "Numeric" ),
        GIN_DEFAULT( NODEF, "0" ),
        GIN_DESC( "Average or equatorial radius.", "Eccentricity" )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "refellipsoidVenus" ),
        DESCRIPTION
        (
         "Venus reference ellipsoids.\n"
         "\n"
         "The reference ellipsoid (*refellipsoid*) is set to model Venus,\n"
         "folowing different models. The options are:\n"
         "\n"
         "   \"Sphere\" : A spherical planet. The radius is taken from a\n"
         "      report of the IAU/IAG Working Group.\n"
         "\n"
         "According to the report used above, the Venus ellipsoid lacks\n"
         "eccentricity and no further models should be required.\n"         
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "refellipsoid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(  ),
        GIN( "model" ),
        GIN_TYPE(    "String" ),
        GIN_DEFAULT( "Sphere" ),
        GIN_DESC( "Model ellipsoid to use. Options listed above." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "refr_index_airFreeElectrons" ),
        DESCRIPTION
        (
         "Microwave refractive index due to free electrons.\n"
         "\n"
         "The refractive index of free electrons is added to *refr_index_air*.\n"
         "To obtain the complete value, *refr_index_air* should be set to 1\n"
         "before calling this WSM. This applies also to *refr_index_air_group*.\n"
         "\n"
         "The expression applied is n=sqrt(1-wp^2/w^2) where wp is the plasma\n"
         "frequency, and w is the angular frequency (the function returns\n"
         "n-1, that here is slightly negative). This expressions is found in\n"
         "many textbooks, e.g. Rybicki and Lightman (1979). The above refers\n"
         "to *refr_index*. *refr_index_group* is sqrt(1+wp^2/w^2).\n"
         "\n"
         "The expression is dispersive. The frequency applied is the mean of\n"
         "first and last element of *f_grid* is selected. This frequency must\n"
         "be at least twice the plasma frequency.\n"
         "\n"
         "An error is issued if free electrons not are part of *abs_species*\n"
         "(and there exist a corresponding \"vmr\"-value). This demand is\n" 
         "removed if *demand_vmr_value* is set to 0, but use this option\n"
         "with care.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "refr_index_air", "refr_index_air_group" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "refr_index_air", "refr_index_air_group", "f_grid", "abs_species", 
            "rtp_vmr" ),
        GIN( "demand_vmr_value" ),
        GIN_TYPE( "Index" ),
        GIN_DEFAULT( "1" ),
        GIN_DESC( "Flag to control if it is demanded that free electrons are "
                  "in *abs_species*. Default is that this is demanded." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "refr_index_airIR" ),
        DESCRIPTION
        (
         "Calculates the IR refractive index due to gases in the\n"
         "Earth's atmosphere.\n"
         "\n"
         "Only refractivity of dry air is considered. The formula used is\n"
         "contributed by Michael Hoefner, Forschungszentrum Karlsruhe.\n"
         "\n"
         "The refractivity of dry air is added to *refr_index_air*. To obtain\n"
         "the complete value, *refr_index_air* should be set to 1 before\n"
         "calling this WSM. This applies also to *refr_index_air_group*.\n"
         "\n"
         "The expression used is non-dispersive. Hence, *refr_index_air* and\n"
         "*refr_index_air_group* are identical.\n"
         ),
        AUTHORS( "Mattias Ekstrom" ),
        OUT( "refr_index_air", "refr_index_air_group" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "refr_index_air", "refr_index_air_group", "rtp_pressure", 
            "rtp_temperature" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "refr_index_airMWgeneral" ),
        DESCRIPTION
        (
         "Microwave refractive index due to gases in planetary atmospheres.\n"
         "\n"
         "The refractivity of a specified gas mixture is calculated and added\n"
         "to *refr_index_air*. To obtain the complete value, *refr_index_air*\n"
         "should be set to 1 before calling this WSM. This applies also to\n"
         "*refr_index_air_group.\n"
         "\n"
         "The expression used is non-dispersive. Hence, *refr_index_air* and\n"
         "*refr_index_air_group* are identical.\n"
         "\n"
         "Uses the methodology introduced by Newell&Baird (1965) for calculating\n"
         "refractivity of variable gas mixtures based on refractivity of the\n"
         "individual gases at reference conditions. Assuming ideal gas law for\n"
         "converting reference refractivity to actual pressure and temperature\n"
         "conditions. Reference refractivities are also taken from Newell&Baird (1965)\n"
         "and are vailable for N2, O2, CO2, H2, and He. Additionally, H2O reference\n"
         "refractivity has been derived from H2O contribution in Thayer (see\n"
         "*refr_index_airThayer*) for T0=273.15K. Any mixture of these gases\n"
         "can be taken into account.\n"
         ),
        AUTHORS( "Jana Mendrok" ),
        OUT( "refr_index_air", "refr_index_air_group" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "refr_index_air", "refr_index_air_group", "rtp_pressure", 
            "rtp_temperature", "rtp_vmr", "abs_species" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "refr_index_airThayer" ),
        DESCRIPTION
        (
         "Microwave refractive index due to gases in the Earth's atmosphere.\n"
         "\n"
         "The refractivity of dry air and water vapour is added to\n"
         "*refr_index_air*. To obtain the complete value, *refr_index_air*\n"
         "shoul be set to 1 before calling this WSM. This applies also to\n"
         "*refr_index_air_group.\n"
         "\n"
         "The expression used is non-dispersive. Hence, *refr_index_air* and\n"
         "*refr_index_air_group* are identical.\n"
         "\n"
         "The parameterisation of Thayer (Radio Science, 9, 803-807, 1974)\n"
         "is used. See also Eq. 3 and 5 of Solheim et al. (JGR, 104,\n"
         "pp. 9664). The expression can be written as\n"
         "   N = aP/T + be/T + ce/T^2\n"
         "where N is refractivity, P is pressure, T is temperature and\n"
         "e is water vapour partial pressure. The values of a, b and c can\n"
         "be modified. Default values are taken from Thayer (1974).\n"
         "Note that Thayer uses mbar for pressures, while in ARTS Pa is used\n"
         "and a, b and c must be scaled accordingly.\n" 
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "refr_index_air", "refr_index_air_group" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "refr_index_air", "refr_index_air_group", "rtp_pressure", 
            "rtp_temperature", "rtp_vmr", "abs_species" ),
        GIN( "a", "b", "c" ),
        GIN_TYPE( "Numeric", "Numeric", "Numeric" ),
        GIN_DEFAULT( "77.6e-8", "64.8e-8", "3.776e-3" ),
        GIN_DESC( "Coefficient a, see above", "Coefficient b, see above",
                  "Coefficient c, see above" )
        ));

    md_data_raw.push_back
    ( MdRecord
      ( NAME( "rte_losGeometricFromRtePosToRtePos2" ),
        DESCRIPTION
        (
         "The geometric line-of-sight between two points.\n"
         "\n"
         "The method sets *rte_los* to the line-of-sight, at *rte_pos*,\n"
         "that matches the geometrical propagation path between *rte_pos*\n"
         "and *rte_pos2*.\n"
         "\n"
         "The standard case should be that *rte_pos2* corresponds to a\n"
         "transmitter, and *rte_pos* to the receiver/sensor.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "rte_los" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atmosphere_dim", "lat_grid", "lon_grid", "refellipsoid", 
            "rte_pos", "rte_pos2" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "rte_losSet" ),
        DESCRIPTION
        (
         "Sets *rte_los* to the given angles.\n"
         "\n"
         "The azimuth angle is ignored for 1D and 2D.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "rte_los" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atmosphere_dim" ),
        GIN( "za",      "aa"      ),
        GIN_TYPE(    "Numeric", "Numeric" ),
        GIN_DEFAULT( NODEF,     NODEF ),
        GIN_DESC( "Zenith angle of sensor line-of-sight.",
                  "Azimuth angle of sensor line-of-sight." 
                  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "rte_posSet" ),
        DESCRIPTION
        (
         "Sets *rte_pos* to the given co-ordinates.\n"
         "\n"
         "The longitude is ignored for 1D and 2D, and the latitude is also \n"
         "ignored for 1D.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "rte_pos" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atmosphere_dim" ),
        GIN( "z",  "lat",     "lon"     ),
        GIN_TYPE(    "Numeric", "Numeric", "Numeric" ),
        GIN_DEFAULT( NODEF,     NODEF,     NODEF ),
        GIN_DESC( "Geometrical altitude of sensor position.",
                  "Latitude of sensor position.",
                  "Longitude of sensor position." 
                  )
        ));
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "rte_pos_losMoveToStartOfPpath" ),
        DESCRIPTION
        (
         "Sets *rte_pos* and *rte_los* to values for last point in *ppath*.\n"
         "\n"
         "For example, if the propagation path intersects with the surface,\n"
         "this method gives you the position and angle of *ppath* at the\n"
         "surface.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "rte_pos", "rte_los" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atmosphere_dim", "ppath" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "ScatteringDisort" ),
        DESCRIPTION
        (
         "Calls DISORT RT solver from ARTS.\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT( "scat_i_p", "scat_i_lat", "scat_i_lon", 
             "f_index", "scat_data_array_mono", "doit_i_field1D_spectrum" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atmfields_checked", "atmgeom_checked",
            "cloudbox_checked", "cloudbox_limits", "stokes_dim", 
            "opt_prop_part_agenda", "propmat_clearsky_agenda", 
            "spt_calc_agenda", "pnd_field", "t_field",
            "z_field", "p_grid", "vmr_field", "scat_data_array", "f_grid", 
            "scat_za_grid", "surface_emissivity_DISORT" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "ScatteringDoit" ),
        DESCRIPTION
        (
         "Main DOIT method.\n"
         "\n"
         "This method executes *doit_mono_agenda* for each frequency\n"
         "in *f_grid*. The output is the radiation field inside the cloudbox\n"
         "(*doit_i_field*) and on the cloudbox boundary (*scat_i_p* (1D),\n"
         "*scat_i_lat* and *scat_i_lon* (3D)).\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT( "doit_i_field", 
             "scat_i_p", "scat_i_lat", "scat_i_lon",
             "doit_i_field1D_spectrum" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atmfields_checked", "atmgeom_checked",
            "cloudbox_checked", "cloudbox_on", "f_grid", 
            "scat_i_p", "scat_i_lat", "scat_i_lon",
            "doit_mono_agenda", "doit_is_initialized" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));
    
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "ScatteringDoitMergeParticles1D" ),
        DESCRIPTION
        (
         "This method pre-calculates a weighted sum of all particles per pressure level.\n"
         "before the actual DOIT calculation is taking place in *ScatteringDoit*.\n"
         "It should be called directly after *pnd_fieldSetup* (but after\n"
         "*cloudbox_checkedCalc*). It's purpose is speeding up DOIT calculations.\n"
         "\n"
         "*pnd_field* is resized to [np, np, 1, 1]. Where np is the number of pressure levels\n"
         "inside the cloudbox. The diagonal elements of the new *pnd_field* are set to 1, all\n"
         "others to 0. Accordingly, *scat_data_array* is resized to np. Each particle\n"
         "is the weighted sum of all particles at this presssure level.\n"
         "This is an experimental method currently only working for very specific cases.\n"
         "All particles must be of the same type and all particles must share the same\n"
         "f_grid and za_grid. And pha_mat_data, ext_mat_data and abs_vec_data must be all\n"
         "the same size.\n"
         "This method can only be used with a 1D atmosphere.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( "pnd_field", "scat_data_array"),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "pnd_field", "scat_data_array", "atmosphere_dim", "cloudbox_on", "cloudbox_limits",
            "t_field", "z_field", "z_surface", "cloudbox_checked" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));  
    
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "ScatteringParticleTypeAndMetaRead" ),
        DESCRIPTION
        (
         "Reads single scattering data and scattering meta data.\n"
         "\n"
         "This method's input needs two XML-files, one containing an array \n"
         "of path/filenames (*ArrayOfString*) of single scattering data and the \n"
         "corresponding path/filenames to scattering meta data.\n"
         "For each single scattering file, there needs to be exactly one\n"
         "scattering meta data file.\n"
         "\n"
         "Currently particles of phase ice and/or water can be added for the same calculation.\n"
         "It is also possible to read *SingleScatteringData* for different shapes of\n"
         "ice particles. But all ice particels will share the same IWC, while performing\n"
         "the *pnd_field* calculations with *pnd_fieldSetup*.\n"
         "Also make sure, that two scattering particles of the same phase are never equal\n"
         "in size. This will break the calculations in *pnd_fieldSetup*\n"
         "\n"
         "Very important note:\n"
         "The order of the filenames for the single scattering data files has to\n"
         "exactly correspond to the order of the scattering meta data files.\n"
         ),
        AUTHORS( "Daniel Kreyling" ),
        OUT( "scat_data_array", "scat_meta_array" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "f_grid" ),
        GIN(         "filename_scat_data", "filename_scat_meta_data" ),
        GIN_TYPE(    "String",             "String"             ),
        GIN_DEFAULT( NODEF,                NODEF                ),
        GIN_DESC( "File containing single scattering data file names.",
                  "File containing scattering meta data file names." 
                  )
        ));

 
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "ScatteringParticlesSelect" ),
        DESCRIPTION
        (
         "Selects data of *scat_data_array* corresponding to particles that\n"
         "according to *part_species* shall be considered in the scattering\n"
         "calculation.\n"
         "\n"
         "Selection is controlled by *part_species* settings and done based on\n"
         "particle type and size. *scat_meta_array* is searched\n"
         "for particles that fulfill the selection criteria. Selection is done\n"
         "individually for each element of *part_species*, i.e. for each\n"
         "considered particle field (implying a sorting of the selected\n"
         "*scat_meta_array* and *scat_data_array* according to the\n"
         "particle field they correspond to).\n"
         "Additionaly *scat_data_per_part_species* is created, which contains the number\n"
         "of particles that have been selected for each of the particle fields.\n"
         ),
        AUTHORS( "Daniel Kreyling" ),
        OUT( "scat_data_array", "scat_meta_array", "scat_data_per_part_species" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "scat_data_array", "scat_meta_array", "part_species" ),
        GIN( "delim" ),
        GIN_TYPE( "String" ),
        GIN_DEFAULT( "-" ),
        GIN_DESC( "Delimiter string of *part_species* elements." )
         ));
        
  md_data_raw.push_back
    ( MdRecord
    ( NAME( "scat_meta_arrayAddTmatrix" ),
      DESCRIPTION
      (
       "This method adds particle meta data to the workspace variable\n"
       "*scat_meta_array*.\n"
       "\n"
       "One set of meta data is created and added to the array for each combination of\n"
       "maximum diameter and aspect ratio in the GINs diamter_max_grid and aspect_ratio_grid. The size of *scat_meta_array*\n"
       "and hence the usage has been extended. For that reason, a short\n"
       "summary below tells which input parameters are required for certain further\n"
       "calculations.\n"
       "\n"
       "String[description]\t\tNot used for any particular calculations\n"
       "String[material]\t\tUsed for PND calculations\n"
       "String[shape]\t\t\tUsed for scattering and PND calculations\n"
       "Numeric[particle_type]\t\tUsed for scattering calculations\n"
       "Numeric[density]\t\tUsed for PND calculations\n"
       "Vector[diameter_max_grid]\t\tUsed for both scattering and PND calculations\n"
       "Vector[aspect_ratio_grid]\t\tUsed for scattering calculations and PND calculations\n"
       "Vector[scat_f_grid]\t\tUsed for scattering calculations\n"
       "Vector[scat_T_grid]\t\tUsed for scattering calculations\n"
       "Tensor3[complex_refr_index]\tUsed for scattering calculations\n"
      ),
      AUTHORS( "Johan Strandgren" ),
      OUT("scat_meta_array"),
      GOUT(),
      GOUT_TYPE(),
      GOUT_DESC(),
      IN( "scat_meta_array", "complex_refr_index" ),
      GIN( "description", "material", "shape", "particle_type", "density", 
           "aspect_ratio_grid", "diameter_max_grid", "scat_f_grid", "scat_T_grid" ),
      GIN_TYPE( "String", "String", "String", "String", "Numeric", "Vector",
           "Vector", "Vector", "Vector" ),
      GIN_DEFAULT( "", "undefined", NODEF, NODEF, "-999", NODEF, NODEF,
                   NODEF, NODEF ),
      GIN_DESC( "Particle description", "Water or Ice", "spheroidal or cylinder", 
               "Particle Type: MACROS_ISO (20) or PARTICLE_TYPE_HORIZ_AL (30)", 
               "Particle mass density",
               "Particle aspect ratio vector",
               "Maximum diameter vector (diameter of a sphere that fully encloses the particle)",
               "Frequency grid vector", "Temperature grid vector" )
      ));

  md_data_raw.push_back
    ( MdRecord
    ( NAME( "scat_meta_arrayAddTmatrixOldVersion" ),
      DESCRIPTION
      (
       "This method adds particle meta data to the workspace variable\n"
       "*scat_meta_array*.\n"
       "\n"
       "One set of meta data is created and added to the array for each\n"
       "diameter in the GIN diamter_grid. The size of *scat_meta_array*\n"
       "and hence the usage has been extended. For that reason, a short\n"
       "summary below tells which input parameters are required for certain further\n"
       "calculations.\n"
       "\n"
       "String[description]\t\tNot used for any particular calculations\n"
       "String[material]\t\tNot used for any particular calculations\n"
       "String[shape]\t\t\tUsed for scattering properties calculations\n"
       "Numeric[particle_type]\t\tUsed for scattering properties calculations\n"
       "Numeric[density]\t\tUsed for PSD calculations\n"
       "Numeric[aspect_ratio]\t\tUsed for scattering properties calculations\n"
       "Numeric[diameter_grid]\t\tUsed for both scattering properties and PSD calculations\n"
       "Vector[scat_f_grid]\t\tUsed for scattering properties calculations\n"
       "Vector[scat_T_grid]\t\tUsed for scattering properties calculations\n"
       "Tensor3[complex_refr_index]\tUsed for scattering properties calculations\n"
      ),
      AUTHORS( "Johan Strandgren" ),
      OUT("scat_meta_array"),
      GOUT(),
      GOUT_TYPE(),
      GOUT_DESC(),
      IN( "scat_meta_array", "complex_refr_index" ),
      GIN( "description", "material", "shape", "particle_type", "density", 
           "aspect_ratio", "diameter_grid", "scat_f_grid", "scat_T_grid" ),
      GIN_TYPE( "String", "String", "String", "String", "Numeric", "Numeric",
           "Vector", "Vector", "Vector" ),
      GIN_DEFAULT( "", "undefined", NODEF, NODEF, "-999", NODEF, NODEF,
                   NODEF, NODEF ),
      GIN_DESC( "Particle description", "Water or Ice", "spheroidal or cylinder", 
               "Particle Type: MACROS_ISO (20) or PARTICLE_TYPE_HORIZ_AL (30)", 
               "Particle mass density",
               "Particle aspect ratio (can differ between WSMs. Check the userguide)",
               "equivalent diameter vector", "Frequency grid vector",
               "Temperature grid vector" )
      ));
    
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "scat_meta_arrayInit" ),
        DESCRIPTION
        (
         "Initializes the workspace variable *scat_meta_array*.\n"
         ),
        AUTHORS( "Johan Strandgren" ),
        OUT("scat_meta_array"),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "scat_data_array_monoCalc" ),
        DESCRIPTION
        (
         "Interpolates *scat_data_array* by frequency to give *scat_data_array_mono*.\n"
         ),
        AUTHORS( "Cory Davis" ),
        OUT( "scat_data_array_mono" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "scat_data_array", "f_grid", "f_index" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "scat_data_arrayCheck" ),
        DESCRIPTION
        (
         "Method for checking the consistency of the optical properties\n"
         "in the database.\n"
         "\n"
         "This function can be used to check datafiles containing data for\n"
         "randomly oriented scattering media. For other particle types, the\n"
         "check is skipped and a warning is printed to screen.\n"
         "It is checked whether that the integral over\n"
         "the phase matrix element Z11 is equal (or: close to) the scattering\n"
         "cross section as derived from the difference of (scalar) extinction\n"
         "and absorption cross sections: <int_Z11> == <C_sca> = <K11> - <a1>.\n"
         "\n"
         "An error is thrown, if the product of the single scattering\n"
         "albedo and the fractional deviation of <int_Z11> from <C_sca>\n"
         "(which is actually equal the absolute albedo deviation) exceeds\n"
         "the given threshold:\n"
         "\n"
         "( <int_Z11>/<C_sca>-1. ) * ( <C_sca>/<K11> ) > threshold\n"
         "\n"
         "The results for all calculated quantities are printed on the screen,\n"
         "if verbosity>1.\n"
         ),
        AUTHORS( "Claudia Emde", "Jana Mendrok" ),
        OUT(),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "scat_data_array" ),
        GIN( "threshold" ),
        GIN_TYPE( "Numeric" ),
        GIN_DEFAULT( "1e-3" ),
        GIN_DESC( "Threshold for allowed deviation in albedo when using integrated "
                  "phase matrix vs. using extinction-absorption difference." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "scat_data_arrayFromMeta" ),
        DESCRIPTION
        (
         "This workspace method calculates scattering data and adds it to\n"
         "*scat_data_array* using particle meta data in *scat_meta_array*.\n"
         "The scattering data is calculated with the T-matrix method.\n"
         "\n"
         "One set of scattering data is calculated for each particle in\n"
         "*scat_meta_array*\n"
         ),
        AUTHORS( "Johan Strandgren, Oliver Lemke" ),
        OUT("scat_data_array"),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN("scat_meta_array"),
        GIN( "za_grid", "aa_grid", "precision" ),
        GIN_TYPE("Vector", "Vector", "Numeric" ),
        GIN_DEFAULT(NODEF, NODEF, NODEF ),
        GIN_DESC("Zenith angle grid",
                 "Azimuth angle grid",
                 "Precision"
                 )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Select" ),
        DESCRIPTION
        (
         "Method to select some elements from one array and copy them to\n"
         "a new array. (Works also for vectors.)\n"
         "\n"
         "This works also for higher dimensional objects, where the selection is\n"
         "always performed in the first dimension.\n"
         "\n"
         "For example:\n"
         "\n"
         "Select(y,x,[0,3])\n"
         "\n"
         "will select the first and fourth row of matrix x and copy them to the\n"
         "output matrix y.\n"
         "\n"
         "Note that it is even safe to use this method if needles and haystack\n"
         "are the same variable.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT(),
        GOUT(      "needles" ),
        GOUT_TYPE( ARRAY_GROUPS + ", Vector, Matrix, Sparse" ),
        GOUT_DESC( "Selected elements. Must have the same variable type as "
                   "haystack." ),
        IN(),
        GIN(       "haystack", "needleindexes" ),
        GIN_TYPE(  ARRAY_GROUPS + ", Vector, Matrix, Sparse",
                   "ArrayOfIndex" ),
        GIN_DEFAULT( NODEF, NODEF ),
        GIN_DESC( "Variable to select from. May be the same variable as needles.",
                  "The elements to select (zero based indexing, as always.)" ),
        SETMETHOD(      false ),
        AGENDAMETHOD(   false ),
        USES_TEMPLATES( true  )
        ));
 
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "sensor_checkedCalc" ),
        DESCRIPTION
        (
         "Checks consistency of the sensor variables.\n"
         "\n"
         "The following WSVs are treated: *sensor_pos*, *sensor_los*,\n"
         "*transmitter_pos*, *mblock_za_grid*, *mblock_aa_grid*,\n"
         "*antenna_dim*, *sensor_response*, *sensor_response_f*,\n"
         "*sensor_response_pol*, *sensor_response_za*, *sensor_response_aa*.\n"
         "If any of these variables are changed, then this method shall be\n"
         "called again (no automatic check that this is fulfilled!).\n"
         "\n"
         "The main tests are that dimensions of sensor variables agree\n"
         "with other settings, e.g., the size of f_grid, atmosphere_dim,\n"
         "stokes_dim, etc.\n"
         "\n"
         "If any test fails, there is an error. Otherwise, *sensor_checked*\n"
         "is set to 1.\n"
         ),
        AUTHORS( "Jana Mendrok" ),
        OUT( "sensor_checked" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atmosphere_dim", "stokes_dim", "f_grid", "sensor_pos",
            "sensor_los", "transmitter_pos", "mblock_za_grid", "mblock_aa_grid",
            "antenna_dim", "sensor_response", "sensor_response_f",
            "sensor_response_pol", "sensor_response_za", "sensor_response_aa"),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "sensorOff" ),
        DESCRIPTION
        (
         "Sets sensor WSVs to obtain monochromatic pencil beam values.\n"
         "\n"
         "A 1D antenna pattern is assumed. The variables are set as follows:\n"
         "   antenna_dim             : 1.\n"
         "   mblock_za_grid          : Length 1, value 0.\n"
         "   mblock_aa_grid          : Empty.\n"
         "   sensor_response*        : As returned by *sensor_responseInit*.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "sensor_response", "sensor_response_f", 
             "sensor_response_pol", "sensor_response_za",
             "sensor_response_aa", 
             "sensor_response_f_grid", "sensor_response_pol_grid",
             "sensor_response_za_grid", "sensor_response_aa_grid",
             "antenna_dim", "mblock_za_grid", "mblock_aa_grid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "stokes_dim", "f_grid" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "sensor_responseAntenna" ),
        DESCRIPTION
        (
         "Includes response of the antenna.\n"
         "\n"
         "The function returns the sensor response matrix after the antenna\n" 
         "characteristics have been included.\n"
         "\n"
         "The function handles \"multi-beam\" cases where the polarisation\n"
         "coordinate system is the same for all beams.\n"
         "\n"         
         "See *antenna_dim*, *antenna_los* and *antenna_response* for\n"
         "details on how to specify the antenna response.\n"
         ),
        AUTHORS( "Mattias Ekstrom", "Patrick Eriksson" ),
        OUT( "sensor_response", "sensor_response_f", "sensor_response_pol",
             "sensor_response_za", "sensor_response_aa", 
             "sensor_response_za_grid", "sensor_response_aa_grid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "sensor_response", "sensor_response_f", "sensor_response_pol",
            "sensor_response_za", "sensor_response_aa", "sensor_response_f_grid",
            "sensor_response_pol_grid", "sensor_response_za_grid",
            "sensor_response_aa_grid", "atmosphere_dim", "antenna_dim", 
            "antenna_los", "antenna_response", "sensor_norm" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "sensor_responseBackend" ),
        DESCRIPTION
        (
         "Includes response of the backend (spectrometer).\n"
         "\n"
         "The function returns the sensor response matrix after the backend\n" 
         "characteristics have been included.\n"
         "\n"
         "See *f_backend*, *backend_channel_response* and *sensor_norm* for\n"
         "details on how to specify the backend response.\n"
         ),
        AUTHORS( "Mattias Ekstrom", "Patrick Eriksson" ),
        OUT( "sensor_response", "sensor_response_f", "sensor_response_pol",
             "sensor_response_za", "sensor_response_aa", 
             "sensor_response_f_grid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "sensor_response", "sensor_response_f", "sensor_response_pol",
            "sensor_response_za", "sensor_response_aa", 
            "sensor_response_f_grid", "sensor_response_pol_grid", 
            "sensor_response_za_grid", "sensor_response_aa_grid",
            "f_backend", "backend_channel_response", "sensor_norm" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "sensor_responseBackendFrequencySwitching" ),
        DESCRIPTION
        (
         "Frequency switching for a pure SSB reciever.\n"
         "\n"
         "This function can be used for simulation of frequency switching.\n"
         "That is, when the final spectrum is the difference of two spectra\n"
         "shifted in frequency. The switching is performed by the LO, but\n" 
         "for a pure singel sideband reciever this is most easily simulated\n"
         "by instead shifting the backend, as done here.\n"
         "\n"
         "A strightforward frequency switching is modelled (no folding)\n"
         "The channel positions for the first measurement cycle are\n"
         "f_backend+df1, and for the second f_backend+df2. The first\n"
         "measurement cycle is given the negive weight. That is, the output\n"
         "is the spectrum for cycle2 minus the spectrum for cycle1.\n"
         "Output frequency grids are set to *f_backend*.\n"
         "\n"
         "Use *sensor_responseFrequencySwitching* for double sideband cases.\n"
         "\n"
         "The method has the same general functionality as, and can replace,\n"
         "*sensor_responseBackend*.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "sensor_response", "sensor_response_f", "sensor_response_pol",
             "sensor_response_za", "sensor_response_aa", 
             "sensor_response_f_grid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "sensor_response", "sensor_response_f", "sensor_response_pol",
            "sensor_response_za", "sensor_response_aa", 
            "sensor_response_f_grid", "sensor_response_pol_grid", 
            "sensor_response_za_grid", "sensor_response_aa_grid",
            "f_backend", "backend_channel_response", "sensor_norm" ),
        GIN(    "df1", "df2" ),
        GIN_TYPE(   "Numeric", "Numeric" ),
        GIN_DEFAULT( NODEF, NODEF ),
        GIN_DESC( "Frequency throw for cycle1.", "Frequency throw for cycle2.")
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "sensor_responseBeamSwitching" ),
        DESCRIPTION
        (
         "Simulation of \"beam switching\".\n"
         "\n"
         "The measurement procedure is based on taking the difference between\n"
         "two spectra measured in different directions, and the calculation\n"
         "set-up must treat exactly two observation directions.\n"
         "\n"
         "The returned spectrum is y = w1*y + w2*y2, where y1 and w1 are the\n"
         "spectrum and weight for the first direction, respectively (y2 and\n"
         "(w2 defined correspondingly for the second direction).\n"
         "\n"
         "Zenith and azimuth angles after beam switching are set to the\n"
         "values of the second direction.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "sensor_response", "sensor_response_f", "sensor_response_pol",
             "sensor_response_za", "sensor_response_aa", 
             "sensor_response_za_grid", "sensor_response_aa_grid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "sensor_response", "sensor_response_f", "sensor_response_pol",
            "sensor_response_za", "sensor_response_aa",
            "sensor_response_f_grid", "sensor_response_pol_grid", 
            "sensor_response_za_grid", "sensor_response_aa_grid" ),
        GIN( "w1", "w2" ),
        GIN_TYPE( "Numeric", "Numeric" ),
        GIN_DEFAULT( "-1", "1" ),
        GIN_DESC( "Weight for values from first viewing direction.", 
                  "Weight for values from second viewing direction." 
                  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "sensor_responseFillFgrid" ),
        DESCRIPTION
        (
         "Polynomial frequency interpolation of spectra.\n"
         "z\n"
         "The sensor response methods treat the spectra to be piece-wise linear\n"
         "functions. This method is a workaround for making methods handling\n"
         "the spectra in a more elaborate way: it generates spectra on a more\n"
         "dense grid by polynomial interpolation. The interpolation is not\n"
         "done explicitly, it is incorporated into *sensor_response*.\n"
         "\n"
         "This method should in general increase the calculation accuracy for\n"
         "a given *f_grid*. However, the selection of (original) grid points\n"
         "becomes more sensitive when using this method. A poor choice of grid\n"
         "points can result in a decreased accuracy, or generation of negative\n"
         "radiances. Test calculations indicated that the error easily can\n"
         "increase with this method close the edge of *f_grid*, and it could\n"
         "be wise to make *f_grid* a bit wider than actually necessary to avoid\n"
         "this effect\n"
         "\n"
         "The method shall be inserted before the antenna stage. That is, this\n"
         "method shall normally be called directly after *sensor_responseInit*.\n"
         "\n"
         "Between each neighbouring points of *f_grid*, this method adds\n"
         "*nfill* grid points. The polynomial order of the interpolation is\n"
         "*polyorder*.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "sensor_response", "sensor_response_f", "sensor_response_pol",
             "sensor_response_za", "sensor_response_aa", 
             "sensor_response_f_grid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "sensor_response", "sensor_response_f", "sensor_response_pol",
            "sensor_response_za", "sensor_response_aa", 
            "sensor_response_f_grid", "sensor_response_pol_grid", 
            "sensor_response_za_grid", "sensor_response_aa_grid" ),
        GIN( "polyorder", "nfill" ),
        GIN_TYPE( "Index", "Index" ),
        GIN_DEFAULT( "3", "2" ),
        GIN_DESC( "Polynomial order of interpolation", 
                  "Number of points to insert in each gap of f_grid" )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "sensor_responseFrequencySwitching" ),
        DESCRIPTION
        (
         "Simulation of \"frequency switching\".\n"
         "\n"
         "A general method for frequency switching. The WSM\n"
         "*sensor_responseBackendFrequencySwitching* gives a description of\n"
         "this observation technique, and is also a more straightforward\n"
         " method for pure singel sideband cases.\n"
         "\n"
         "It is here assume that *sensor_responseMultiMixerBackend* has been\n"
         "used to calculate the spectrum for two LO positions. This method\n"
         "calculates the difference between these two spectra, where the\n" 
         "second spectrum gets weight 1 and the first weight -1 (as in\n"
         "*sensor_responseBackendFrequencySwitching*).\n"
         "\n"
         "Output frequency grids are taken from the second spectrum..\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "sensor_response", "sensor_response_f", "sensor_response_pol",
             "sensor_response_za", "sensor_response_aa", 
             "sensor_response_f_grid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "sensor_response", "sensor_response_f", "sensor_response_pol",
            "sensor_response_za", "sensor_response_aa", 
            "sensor_response_f_grid", "sensor_response_pol_grid", 
            "sensor_response_za_grid", "sensor_response_aa_grid" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "sensor_responseIF2RF" ),
        DESCRIPTION
        (
         "Converts sensor response variables from IF to RF.\n"
         "\n"
         "The function converts intermediate frequencies (IF) in\n"
         "*sensor_response_f* and *sensor_response_f_grid* to radio\n"
         "frequencies (RF). This conversion is needed if the frequency\n"
         "translation of a mixer is included and the position of backend\n"
         "channels are specified in RF.\n"
         "\n"
         "A direct frequency conversion is performed. Values are not\n"
         "sorted in any way.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "sensor_response_f", "sensor_response_f_grid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "sensor_response_f", "sensor_response_f_grid", "lo", 
            "sideband_mode" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "sensor_responseInit" ),
        DESCRIPTION
        (
         "Initialises the variables summarising the sensor response.\n"
         "\n"
         "This method sets the variables to match monochromatic pencil beam\n"
         "calculations, to be further modified by inclusion of sensor\n"
         "characteristics. Use *sensorOff* if pure monochromatic pencil\n"
         "beam calculations shall be performed.\n"
         "\n"
         "The variables are set as follows:\n"
         "   sensor_response : Identity matrix, with size matching *f_grid*,\n"
         "                     *stokes_dim* *mblock_za_grid* and\n"
         "                     *mblock_aa_grid*.\n"
         "   sensor_response_f       : Repeated values of *f_grid*.\n"
         "   sensor_response_pol     : Data matching *stokes_dim*.\n"
         "   sensor_response_za      : Repeated values of *mblock_za_grid*.\n"
         "   sensor_response_aa      : Repeated values of *mblock_aa_grid*.\n"
         "   sensor_response_f_grid  : Equal to *f_grid*.\n"
         "   sensor_response_pol_grid: Set to 1:*stokes_dim*.\n"
         "   sensor_response_za_grid : Equal to *mblock_za_grid*.\n"
         "   sensor_response_aa_grid : Equal to *mblock_aa_grid*.\n"
         ),
        AUTHORS( "Mattias Ekstrom", "Patrick Eriksson" ),
        OUT( "sensor_response", "sensor_response_f", "sensor_response_pol", 
             "sensor_response_za", "sensor_response_aa", 
             "sensor_response_f_grid", "sensor_response_pol_grid",
             "sensor_response_za_grid", "sensor_response_aa_grid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "f_grid", "mblock_za_grid", "mblock_aa_grid", "antenna_dim",
            "atmosphere_dim", "stokes_dim", "sensor_norm" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "sensor_responseMixer" ),
        DESCRIPTION
        (
         "Includes response of the mixer of a heterodyne system.\n"
         "\n"
         "The function returns the sensor response matrix after the mixer\n" 
         "characteristics have been included. Frequency variables are\n"
         "converted from radio frequency (RF) to intermediate frequency (IF).\n"
         "The returned frequency grid covers the range [0,max_if], where\n"
         "max_if is the highest IF covered by the sideband response grid.\n" 
         "\n"
         "See *lo* and *sideband_response* for details on how to specify the\n"
         "mixer response\n"
         ),
        AUTHORS( "Mattias Ekstrom", "Patrick Eriksson" ),
        OUT( "sensor_response", "sensor_response_f", "sensor_response_pol",
             "sensor_response_za", "sensor_response_aa", 
             "sensor_response_f_grid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "sensor_response", "sensor_response_f", "sensor_response_pol",
            "sensor_response_za", "sensor_response_aa", "sensor_response_f_grid",
            "sensor_response_pol_grid", "sensor_response_za_grid",
            "sensor_response_aa_grid", "lo", "sideband_response", "sensor_norm" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "sensor_responseMultiMixerBackend" ),
        DESCRIPTION
        (
         "Handles mixer and backend parts for an instrument having multiple\n"
         "mixer chains.\n"
         "\n"
         "The WSMs *sensor_responseMixer*, *sensor_responseIF2RF* and\n"
         "*sensor_responseBackend* are called for each mixer chain, and a\n"
         "complete *sensor_response* is assembled. The instrument responses\n"
         "are described by *lo_multi*, *sideband_response_multi*,\n"
         "*sideband_mode_multi*, *f_backend_multi* and\n"
         "*backend_channel_response_multi*. All these WSVs must have same\n"
         "vector or array length. As *sensor_responseIF2RF* is called,\n"
         "*f_backend_multi* must hold RF (not IF) and output frequencies\n"
         "will be in absolute frequency (RF).\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "sensor_response", "sensor_response_f", "sensor_response_pol",
             "sensor_response_za", "sensor_response_aa", 
             "sensor_response_f_grid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "sensor_response", "sensor_response_f", "sensor_response_pol",
            "sensor_response_za", "sensor_response_aa", 
            "sensor_response_f_grid", "sensor_response_pol_grid", 
            "sensor_response_za_grid", "sensor_response_aa_grid",
            "lo_multi", "sideband_response_multi", 
            "sideband_mode_multi", "f_backend_multi",
            "backend_channel_response_multi", "sensor_norm" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "sensor_responsePolarisation" ),
        DESCRIPTION
        (
         "Extraction of non-default polarisation components.\n"
         "\n"
         "The default is to output the Stokes elements I, Q, U and V (up to\n" 
         "*stokes_dim*). This method allows to change the \"polarisation\" of\n"
         "the output. Polarisation components to be extracted are selected by\n"
         "*sensor_pol*. This method can be applied at any step of the sensor\n"
         "matrix set-up.\n"
         "\n"
         "The method can only be applied on data for I, Q, U and V. The value\n"
         "of *stokes_dim* must be sufficiently large for the selected\n"
         "components. For example, I+45 requires that *stokes_dim* is at\n"
         "least 3. \n"
         "\n"
         "See *sensor_pol* for coding of polarisation states.\n"
         "\n"
         "Note that the state of *iy_unit* is considered. This WSV must give\n"
         "the actual unit of the data. This as, the extraction of components\n"
         "is slightly different if data are radiances or brightness\n"
         "temperatures.  In practise this means that *iy_unit* (as to be\n"
         "applied inside *iy_main_agenda*) must be set before calling this\n"
         "method.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "sensor_response", "sensor_response_f", "sensor_response_pol",
             "sensor_response_za", "sensor_response_aa", 
             "sensor_response_pol_grid" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "sensor_response", "sensor_response_f", "sensor_response_pol",
            "sensor_response_za", "sensor_response_aa", "sensor_response_f_grid",
            "sensor_response_pol_grid", "sensor_response_za_grid",
            "sensor_response_aa_grid", "stokes_dim", "iy_unit", "sensor_pol" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "sensor_responseStokesRotation" ),
        DESCRIPTION
        (
         "Includes a rotation of the Stokes H and V directions.\n"
         "\n"
         "The method applies the rotations implied by *stokes_rotation*.\n"
         "See the description of that WSV for details.\n"
         "\n"
         "This method does not change the size of *sensor_response*, and\n"
         "the auxiliary variables (sensor_response_f etc.) are not changed.\n"
         "\n"
         "To apply the method, *stokes_dim* must be >= 3. The complete effect\n"
         "of the rotation can not be determibed with lower *stokes_dim*.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "sensor_response" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "sensor_response", "sensor_response_f_grid",
            "sensor_response_pol_grid", "sensor_response_za_grid",
            "sensor_response_aa_grid", "stokes_dim", "stokes_rotation" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "sensor_responseSimpleAMSU" ),
        DESCRIPTION
        (
         "Simplified sensor setup for an AMSU-type instrument.\n"
         "\n"
         "This method allows quick and simple definition of AMSU-type\n"
         "sensors. Assumptions:\n"
         "\n"
         "1. Pencil beam antenna.\n"
         "2. Double sideband receivers.\n"
         "3. Sideband mode \"upper\"\n"
         "4. The channel response is rectangular.\n"
         "\n"
         "Under these assumptions the only inputs needed are the LO positions,\n"
         "the offsets from the LO, and the IF bandwidths. They are provieded\n"
         "in sensor_description_amsu.\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT( "f_grid", 
         "antenna_dim", 
         "mblock_za_grid", 
         "mblock_aa_grid",
         "sensor_response", 
         "sensor_response_f", 
         "sensor_response_pol", 
         "sensor_response_za", 
         "sensor_response_aa", 
         "sensor_response_f_grid", 
         "sensor_response_pol_grid", 
         "sensor_response_za_grid", 
         "sensor_response_aa_grid", 
         "sensor_norm"
        ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atmosphere_dim",
            "stokes_dim",
            "sensor_description_amsu" ),
        GIN( "spacing" ),
        GIN_TYPE(    "Numeric" ),
        GIN_DEFAULT( ".1e9" ),
        GIN_DESC( "Desired grid spacing in Hz." )
        ));


  md_data_raw.push_back
    ( MdRecord
      ( NAME( "sensor_responseGenericAMSU" ),
        DESCRIPTION
        (
         "Simplified sensor setup for an AMSU-type instrument.\n"
         "\n"
         "This function is derived from 'sensor_responseSimpleAMSU' \n"
         "but is more generalized since the number of passbands in each \n"
         "can be in the range from 1 to 4 - in order to correctly simulate\n"
         "AMSU-A type sensors \n"
         "\n"
         "This method allows quick and simple definition of AMSU-type\n"
         "sensors. Assumptions:\n"
         "\n"
         "1. Pencil beam antenna.\n"
         "2. 1-4 Passband/sidebands per channel.\n"
         "3. Sideband mode \"upper\"\n"
         "4. The channel response is rectangular.\n"
         "\n"
         "Under these assumptions the only inputs needed are the LO positions,\n"
         "the offsets from the LO, and the IF bandwidths. They are provided\n"
         "in sensor_description_amsu.\n"
        ),
        AUTHORS( "Oscar Isoz" ),
        OUT( "f_grid", 
          "antenna_dim", 
          "mblock_za_grid", 
          "mblock_aa_grid",
          "sensor_response", 
          "sensor_response_f", 
          "sensor_response_pol", 
          "sensor_response_za", 
          "sensor_response_aa", 
          "sensor_response_f_grid", 
          "sensor_response_pol_grid", 
          "sensor_response_za_grid", 
          "sensor_response_aa_grid", 
          "sensor_norm"
          ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atmosphere_dim",
            "stokes_dim",
            "sensor_description_amsu" ),
        GIN( "spacing" ),
        GIN_TYPE(    "Numeric" ),
        GIN_DEFAULT( ".1e9" ),
        GIN_DESC( "Desired grid spacing in Hz." )
        ));
  

        /* Not yet updated
     md_data_raw.push_back
     ( MdRecord
     ( NAME( "sensor_responsePolarisation" ),
     DESCRIPTION
     (
     "Adds polarisation to the response matrix.\n"
     "\n"
     "The output polarisations are given by matrix *sensor_pol*.\n"
     ),
     AUTHORS( "Mattias Ekstrom" ),
     OUT( "sensor_response", "sensor_response_pol" ),
     GOUT(),
     GOUT_TYPE(),
     GOUT_DESC(),
     IN( "sensor_pol", "sensor_response_za", "sensor_response_aa",
     "sensor_response_f", "stokes_dim" ),
     GIN(),
     GIN_TYPE(),
     GIN_DEFAULT(),
     GIN_DESC()
     ));
  */

  /* Not yet updated
     md_data_raw.push_back
     ( MdRecord
     ( NAME( "sensor_responseRotation" ),
     DESCRIPTION
     (
     "Adds rotation to the response matrix.\n"
     "\n"
     "The rotations are given by *sensor_rot* combined with *antenna_los*.\n"
     "The rotations are performed within each measurement block for the\n"
     "individual antennae.\n"
     "\n"
     "If used this method has to be run after the antenna response\n"
     "function and prior to sensor_responsePolarisation.\n"
     ),
     AUTHORS( "Mattias Ekstrom" ),
     OUT( "sensor_response" ),
     GOUT(),
     GOUT_TYPE(),
     GOUT_DESC(),
     IN( "sensor_rot", "antenna_los", "antenna_dim", "stokes_dim",
     "sensor_response_f", "sensor_response_za" ),
     GIN(),
     GIN_TYPE(),
     GIN_DEFAULT(),
     GIN_DESC()
     ));
  */

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "sensor_responseWMRF" ),
        DESCRIPTION
        (
         "Adds WMRF weights to sensor response.\n"
         "\n"
         "This method adds a spectrometer response that has been calculated\n"
         "with the weighted mean of representative frequencies (WMRF) method. It\n"
         "consists of a set of selected frequencies, and associated weights.\n"
         ),
        AUTHORS( "Stefan Buehler, based on Patrick Erikssons sensor_responseBackend" ),
        OUT( "sensor_response",
             "sensor_response_f",
             "sensor_response_pol",
             "sensor_response_za",
             "sensor_response_aa", 
             "sensor_response_f_grid"),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "sensor_response", "sensor_response_f", "sensor_response_pol",
            "sensor_response_za", "sensor_response_aa", 
            "sensor_response_f_grid", "sensor_response_pol_grid", 
            "sensor_response_za_grid", "sensor_response_aa_grid",
            "wmrf_weights",
            "f_backend" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));
    
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "SparseSparseMultiply" ),
        DESCRIPTION
        (
         "Multiplies a Sparse with another Sparse, result stored in Sparse.\n"
         "\n"
         "Makes the calculation: out = m1 * m2\n"
        ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT(      "out"       ),
        GOUT_TYPE( "Sparse" ),
        GOUT_DESC( "Product, can be same variable as any of the inputs." ),
        IN(),
        GIN(      "m1"      , "m2"       ),
        GIN_TYPE(    "Sparse", "Sparse" ),
        GIN_DEFAULT( NODEF   , NODEF    ),
        GIN_DESC( "Left sparse matrix.",
                  "Right sparse matrix." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "specular_losCalc" ),
        DESCRIPTION
        (
         "Calculates the specular direction for intersections with the\n"
         "surface.\n"
         "\n"
         "A help method to set up the surface properties. This method\n"
         "calculates *specular_los*, that is required in several methods\n"
         "to convert zenith angles to incidence angles.\n"
         "\n"
         "The method also returns the line-of-sight for the surface normal.\n"
        ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "specular_los", "surface_normal" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "rtp_pos", "rtp_los", "atmosphere_dim", "lat_grid", "lon_grid", 
            "refellipsoid", "z_surface" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "StringSet" ),
        DESCRIPTION
        (
         "Sets a String to the given text string.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT(      "out"      ),
        GOUT_TYPE( "String" ),
        GOUT_DESC( "Variable to initialize." ),
        IN(),
        GIN(         "text"   ),
        GIN_TYPE(    "String" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "Input text string." ),
        SETMETHOD( true )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "surfaceBlackbody" ),
        DESCRIPTION
        (
         "Creates variables to mimic a blackbody surface.\n"
         "\n"
         "This method sets up *surface_los*, *surface_rmatrix* and\n"
         "*surface_emission* for *surface_rtprop_agenda*. Here, *surface_los*\n"
         "and *surface_rmatrix* are set to be empty, and *surface_emission*\n"
         "to hold blackbody radiation for a temperature of *surface_skin_t*.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "surface_los", "surface_rmatrix", "surface_emission" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "f_grid", "stokes_dim", "surface_skin_t", 
            "blackbody_radiation_agenda" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "surfaceFlatRefractiveIndex" ),
        DESCRIPTION
        (
         "Creates variables to mimic specular reflection by a (flat) surface\n"
         "where the complex refractive index is specified.\n"
         "\n"
         "The dielectric properties of the surface are described by\n"
         "*surface_complex_refr_index*. The Fresnel equations are used to\n"
         "calculate amplitude reflection coefficients. The method can thus\n"
         "result in that the reflection properties differ between frequencies\n"
         "and polarisations.\n"
         "\n"
         "Local thermodynamic equilibrium is assumed, which corresponds to\n"
         "that the reflection and emission coefficients add up to 1.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "surface_los", "surface_rmatrix", "surface_emission" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "f_grid", "stokes_dim", "atmosphere_dim", "rtp_los", "specular_los",
            "surface_skin_t", "surface_complex_refr_index",
            "blackbody_radiation_agenda" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "surfaceFlatReflectivity" ),
        DESCRIPTION
        (
         "Creates variables to mimic specular reflection by a (flat) surface\n"
         "where *surface_reflectivity* is specified.\n"
         "\n"
         "Works basically as *surfaceFlatScalarReflectivity* but is more\n"
         "general as also vector radiative transfer is handled. See\n"
         "the ARTS theory document (ATD) for details around how\n"
         "*surface_emission* is determined. In the nomenclature of ATD,\n"
         "*surface_reflectivity* gives R.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "surface_los", "surface_rmatrix", "surface_emission" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "f_grid", "stokes_dim", "atmosphere_dim", 
            "specular_los", "surface_skin_t", "surface_reflectivity", 
            "blackbody_radiation_agenda" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "surfaceFlatScalarReflectivity" ),
        DESCRIPTION
        (
         "Creates variables to mimic specular reflection by a (flat) surface\n"
         "where *surface_scalar_reflectivity* is specified.\n"
         "\n"
         "The method can only be used for *stokes_dim* equal to 1. Local\n"
         "thermodynamic equilibrium is assumed, which corresponds to that\n"
         "reflectivity and emissivity add up to 1.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "surface_los", "surface_rmatrix", "surface_emission" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "f_grid", "stokes_dim", "atmosphere_dim",
            "specular_los", "surface_skin_t", "surface_scalar_reflectivity",
            "blackbody_radiation_agenda" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "surfaceLambertianSimple" ),
        DESCRIPTION
        (
        "Creates variables to mimic a Lambertian surface.\n"
        "\n"
        "The method can only be used for 1D calculations.\n"        
        "\n"
        "A Lambertian surface can be characterised solely by its\n"
        "reflectivity, here taken from *surface_scalar_reflectivity*.\n"
        "\n"
        "The down-welling radiation field is estimated by making calculations\n"
        "for *lambertian_nza* directions. The range of zenith angles ([0,90])\n"
        "is divided in an equidistant manner. The values for *surface_rmatrix*\n"
        "are assuming a constant radiance over each zenith angle range.\n"
        "See AUG.\n"
        "\n"
        "Default is to select the zenith angles for *sensor_los* to be placed\n"
        "centrally in the grid ranges. For example, if *lambertian_nza* is set\n"
        "to 9, down-welling radiation will be calculated for zenith angles = \n"
        "5, 15, ..., 85. The position of these angles can be shifted by\n"
        "*za_pos*. This variable specifies the fractional distance inside the\n"
        "ranges. For example, a *za_pos* of 0.7 (np still 9) gives the angles\n"
        "7, 17, ..., 87.\n"
        "\n"
        "Local thermodynamic equilibrium is assumed, which corresponds to\n"
        "that the reflection and emission coefficients \"add up to 1\".\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "surface_los", "surface_rmatrix", "surface_emission" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "f_grid", "stokes_dim", "atmosphere_dim", "rtp_los", 
            "surface_skin_t", "surface_scalar_reflectivity", "lambertian_nza",
            "blackbody_radiation_agenda" ),
        GIN(         "za_pos"  ),
        GIN_TYPE(    "Numeric" ),
        GIN_DEFAULT( "0.5"     ),
        GIN_DESC( "Position of angle in *surface_los* inside ranges of zenith "
                  "angle grid. See above."
                  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "surface_complex_refr_indexFromGriddedField5" ),
        DESCRIPTION
        (
         "Extracts complex refractive index from a field of such data.\n"
         "\n"
         "The method allows to obtain *surface_complex_refr_index* by\n"
         "interpolation of a geographical field of such data. The position\n"
         "for which refraction shall be extracted is given by *rtp_pos*.\n"
         "The refractive index field is expected to be stored as:\n"
         "   GriddedField5:\n"
         "      Vector f_grid[N_f]\n"
         "      Vector T_grid[N_T]\n"
         "      ArrayOfString Complex[2]\n"
         "      Vector \"Latitude\"  [N_lat]\n"
         "      Vector \"Longitude\" [N_lon]\n"
         "      Tensor5 data[N_f][N_T][2][N_lat][N_lon]\n"
         "\n"
         "Definition and treatment of the three first dimensions follows\n"
         "*complex_refr_index*, e.g. the temperature grid is allowed\n"
         "to have length 1. The grids for latitude and longitude must have\n"
         "a length of >= 2 (ie. no automatic expansion).\n"
         "\n"
         "Hence, this method performs an interpolation only in the lat and\n"
         "lon dimensions, to a single point. The remaining GriddedField3 is\n"
         "simply returned as *surface_complex_refr_index*.\n"
        ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "surface_complex_refr_index" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atmosphere_dim", "lat_grid", "lat_true", "lon_true", "rtp_pos" ),
        GIN( "complex_refr_index_field" ),
        GIN_TYPE( "GriddedField5" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "A field of complex refractive index." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "surface_reflectivityFromGriddedField6" ),
        DESCRIPTION
        (
         "Extracts surface reflectivities from a field of such data.\n"
         "\n"
         "This method allows to specify a field of surface reflectivity for\n"
         "automatic interpolation to points of interest. The position and\n"
         "direction for which the reflectivity shall be extracted are given\n"
         "by *rtp_pos* and *rtp_los*. The reflectivity field is expected to\n"
         "be stored as:\n"
         "   GriddedField6:\n"
         "      Vector \"Frequency\"       [N_f]\n"
         "      Vector \"Stokes element\"  [N_s1]\n"
         "      Vector \"Stokes_element\"  [N_s2]\n"
         "      Vector \"Incidence angle\" [N_ia]\n"
         "      Vector \"Latitude\"        [N_lat]\n"
         "      Vector \"Longitude\"       [N_lon]\n"
         "      Tensor6 data[N_f][N_s1][N_s2][N_ia][N_lat][N_lon]\n"
         "\n"
         "Grids for incidence angle, latitude and longitude must have a\n"
         "length of >= 2 (ie. no automatic expansion). If the frequency grid\n"
         "has length 1, this is taken as that the reflectivity is constant,\n"
         "following the definition of *surface_scalar_reflectivity*.\n"
         "The data can cover higher Stokes dimensionalities than set by\n"
         "*stokes_dim*. Data for non-used Stokes elements are just cropped.\n"
         "The order between the two Stokes dimensions is the same as in\n"
         "*surface_reflectivity* and surface_rmatrix*.\n"
         "\n"
         "The interpolation is done in steps:\n"
         "   1: Linear interpolation for lat and lon (std. extrapolation).\n"
         "   2: Interpolation in incidence angle (std. extrapolation).\n"
         "      If the grid has a length of >= 4, cubic interpolation is\n"
         "      applied. Otherwise linear interpolation.\n"
         "   3. Linear interpolation in frequency (if input data have more\n"
         "      than one frequency).\n"
        ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "surface_reflectivity" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "stokes_dim", "f_grid", "atmosphere_dim", "lat_grid", "lat_true", 
            "lon_true", "rtp_pos", "rtp_los" ),
        GIN( "r_field" ),
        GIN_TYPE( "GriddedField6" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "A field of surface reflectivities" )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "surface_scalar_reflectivityFromGriddedField4" ),
        DESCRIPTION
        (
         "Extracts scalar surface reflectivities from a field of such data.\n"
         "\n"
         "This method allows to specify a field of surface reflectivity for\n"
         "automatic interpolation to points of interest. The position and\n"
         "direction for which the reflectivity shall be extracted are given\n"
         "by *rtp_pos* and *rtp_los*. The reflectivity field is expected to\n"
         "be stored as:\n"
         "   GriddedField4:\n"
         "      Vector \"Frequency\"       [N_f]\n"
         "      Vector \"Incidence angle\" [N_ia]\n"
         "      Vector \"Latitude\"        [N_lat]\n"
         "      Vector \"Longitude\"       [N_lon]\n"
         "      Tensor4 data[N_f][N_ia][N_lat][N_lon]\n"
         "\n"
         "Grids for incidence angle, latitude and longitude must have a\n"
         "length of >= 2 (ie. no automatic expansion). If the frequency grid\n"
         "has length 1, this is taken as the reflectivity is constant,\n"
         "following the definition of *surface_scalar_reflectivity*.\n"
         "\n"
         "The interpolation is done in steps:\n"
         "   1: Linear interpolation for lat and lon (std. extrapolation).\n"
         "   2: Interpolation in incidence angle (std. extrapolation).\n"
         "      If the grid has a length of >= 4, cubic interpolation is\n"
         "      applied. Otherwise linear interpolation.\n"
         "   3. Linear interpolation if frequency (if input data have more\n"
         "      than one frequency).\n"
        ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "surface_scalar_reflectivity" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "stokes_dim", "f_grid", "atmosphere_dim", "lat_grid", "lat_true", 
            "lon_true", "rtp_pos", "rtp_los" ),
        GIN( "r_field" ),
        GIN_TYPE( "GriddedField4" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "A field of scalar surface reflectivities" )
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "TangentPointExtract" ),
        DESCRIPTION
        (
         "Finds the tangent point of a propagation path.\n"
         "\n"
         "The tangent point is here defined as the point with the lowest\n"
         "altitude (which differes from the definition used in the code\n"
         "where it is the point with the lowest radius, or equally the point\n"
         "with a zenith angle of 90 deg.)\n"
         "\n"
         "The tangent point is returned as a vector, with columns matching\n"
         "e.g. *rte_pos*. If the propagation path has no tangent point, the\n"
         "vector is set to NaN.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT( "tan_pos" ),
        GOUT_TYPE( "Vector" ),
        GOUT_DESC( "The position vector of the tangent point." ),
        IN( "ppath" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "TangentPointPrint" ),
        DESCRIPTION
        (
         "Prints information about the tangent point of a propagation path.\n"
         "\n"
         "The tangent point is here defined as the point with the lowest\n"
         "altitude (which differes from the definition used in the code\n"
         "where it is the point with the lowest radius, or equally the point\n"
         "with a zenith angle of 90 deg.)\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "ppath" ),
        GIN( "level" ),
        GIN_TYPE(    "Index" ),
        GIN_DEFAULT( "1" ),
        GIN_DESC( "Output level to use." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Tensor3AddScalar" ),
        DESCRIPTION
        (
         "Adds a scalar value to all elements of a tensor3.\n"
         "\n"
         "The result can either be stored in the same or another\n"
         "variable.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT(      "out"    ),
        GOUT_TYPE( "Tensor3" ),
        GOUT_DESC( "Output tensor." ),
        IN(),
        GIN(         "in",     "value"   ),
        GIN_TYPE(    "Tensor3", "Numeric" ),
        GIN_DEFAULT( NODEF    , NODEF     ),
        GIN_DESC( "Input tensor.",
                  "The value to be added to the tensor." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Tensor3Scale" ),
        DESCRIPTION
        (
         "Scales all elements of a tensor with the specified value.\n"
         "\n"
         "The result can either be stored in the same or another\n"
         "variable.\n"
         ),
        AUTHORS( "Mattias Ekstrom" ),
        OUT(),
        GOUT(      "out"    ),
        GOUT_TYPE( "Tensor3" ),
        GOUT_DESC( "Output tensor." ),
        IN(),
        GIN(         "in",     "value"   ),
        GIN_TYPE(    "Tensor3", "Numeric" ),
        GIN_DEFAULT( NODEF    , NODEF     ),
        GIN_DESC( "Input tensor.",
                  "The value to be multiplied with the tensor." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Tensor3SetConstant" ),
        DESCRIPTION
        (
         "Creates a tensor and sets all elements to the specified value.\n"
         "\n"
         "The size is determined by *ncols*, *nrows* etc.\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT(),
        GOUT(      "out"   ),
        GOUT_TYPE( "Tensor3" ),
        GOUT_DESC( "Variable to initialize." ),
        IN( "npages", "nrows", "ncols" ),
        GIN(         "value"   ),
        GIN_TYPE(    "Numeric" ),
        GIN_DEFAULT( NODEF     ),
        GIN_DESC( "Tensor value." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Tensor4AddScalar" ),
        DESCRIPTION
        (
         "Adds a scalar value to all elements of a tensor4.\n"
         "\n"
         "The result can either be stored in the same or another\n"
         "variable.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT(      "out"    ),
        GOUT_TYPE( "Tensor4" ),
        GOUT_DESC( "Output tensor." ),
        IN(),
        GIN(         "in",     "value"   ),
        GIN_TYPE(    "Tensor4", "Numeric" ),
        GIN_DEFAULT( NODEF    , NODEF     ),
        GIN_DESC( "Input tensor.",
                  "The value to be added to the tensor." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Tensor4Scale" ),
        DESCRIPTION
        (
         "Scales all elements of a tensor with the specified value.\n"
         "\n"
         "The result can either be stored in the same or another\n"
         "variable.\n"
         ),
        AUTHORS( "Mattias Ekstrom" ),
        OUT(),
        GOUT(      "out"    ),
        GOUT_TYPE( "Tensor4" ),
        GOUT_DESC( "Output tensor." ),
        IN(),
        GIN(         "in",     "value"   ),
        GIN_TYPE(    "Tensor4", "Numeric" ),
        GIN_DEFAULT( NODEF    , NODEF     ),
        GIN_DESC( "Input tensor.",
                  "The value to be multiplied with the tensor." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Tensor4SetConstant" ),
        DESCRIPTION
        (
         "Creates a tensor and sets all elements to the specified value.\n"
         "\n"
         "The size is determined by *ncols*, *nrows* etc.\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT(),
        GOUT(      "out"       ),
        GOUT_TYPE( "Tensor4" ),
        GOUT_DESC( "Variable to initialize." ),
        IN( "nbooks", "npages", "nrows", "ncols" ),
        GIN(         "value"   ),
        GIN_TYPE(    "Numeric" ),
        GIN_DEFAULT( NODEF     ),
        GIN_DESC( "Tensor value." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Tensor5Scale" ),
        DESCRIPTION
        (
         "Scales all elements of a tensor with the specified value.\n"
         "\n"
         "The result can either be stored in the same or another\n"
         "variable.\n"
         ),
        AUTHORS( "Mattias Ekstrom" ),
        OUT(),
        GOUT(      "out"    ),
        GOUT_TYPE( "Tensor5" ),
        GOUT_DESC( "Output tensor." ),
        IN(),
        GIN(         "in",     "value"   ),
        GIN_TYPE(    "Tensor5", "Numeric" ),
        GIN_DEFAULT( NODEF    , NODEF     ),
        GIN_DESC( "Input tensor.",
                  "The value to be multiplied with the tensor." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Tensor5SetConstant" ),
        DESCRIPTION
        (
         "Creates a tensor and sets all elements to the specified value.\n"
         "\n"
         "The size is determined by *ncols*, *nrows* etc.\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT(),
        GOUT(      "out"       ),
        GOUT_TYPE( "Tensor5" ),
        GOUT_DESC( "Variable to initialize." ),
        IN( "nshelves", "nbooks", "npages", "nrows", "ncols" ),
        GIN(         "value"   ),
        GIN_TYPE(    "Numeric" ),
        GIN_DEFAULT( NODEF     ),
        GIN_DESC( "Tensor value." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Tensor6Scale" ),
        DESCRIPTION
        (
         "Scales all elements of a tensor with the specified value.\n"
         "\n"
         "The result can either be stored in the same or another\n"
         "variable.\n"
         ),
        AUTHORS( "Mattias Ekstrom" ),
        OUT(),
        GOUT(      "out"    ),
        GOUT_TYPE( "Tensor6" ),
        GOUT_DESC( "Output tensor." ),
        IN(),
        GIN(         "in",     "value"   ),
        GIN_TYPE(    "Tensor6", "Numeric" ),
        GIN_DEFAULT( NODEF    , NODEF     ),
        GIN_DESC( "Input tensor.",
                  "The value to be multiplied with the tensor." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Tensor6SetConstant" ),
        DESCRIPTION
        (
         "Creates a tensor and sets all elements to the specified value.\n"
         "\n"
         "The size is determined by *ncols*, *nrows* etc.\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT(),
        GOUT(      "out"       ),
        GOUT_TYPE( "Tensor6" ),
        GOUT_DESC( "Variable to initialize." ),
        IN( "nvitrines", "nshelves", "nbooks", "npages", "nrows", "ncols" ),
        GIN(         "value"   ),
        GIN_TYPE(    "Numeric" ),
        GIN_DEFAULT( NODEF     ),
        GIN_DESC( "Tensor value." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Tensor7Scale" ),
        DESCRIPTION
        (
         "Scales all elements of a tensor with the specified value.\n"
         "\n"
         "The result can either be stored in the same or another\n"
         "variable.\n"
         ),
        AUTHORS( "Mattias Ekstrom" ),
        OUT(),
        GOUT(      "out"    ),
        GOUT_TYPE( "Tensor7" ),
        GOUT_DESC( "Output tensor." ),
        IN(),
        GIN(         "in",     "value"   ),
        GIN_TYPE(    "Tensor7", "Numeric" ),
        GIN_DEFAULT( NODEF    , NODEF     ),
        GIN_DESC( "Input tensor.",
                  "The value to be multiplied with the tensor." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Tensor7SetConstant" ),
        DESCRIPTION
        (
         "Creates a tensor and sets all elements to the specified value.\n"
         "\n"
         "The size is determined by *ncols*, *nrows* etc.\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT(),
        GOUT(      "out"       ),
        GOUT_TYPE( "Tensor7" ),
        GOUT_DESC( "Variable to initialize." ),
        IN( "nlibraries", "nvitrines", "nshelves", "nbooks", "npages", "nrows",
            "ncols" ),
        GIN(         "value"   ),
        GIN_TYPE(    "Numeric" ),
        GIN_DEFAULT( NODEF     ),
        GIN_DESC( "Tensor value." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Test" ),
        DESCRIPTION
        (
         "A dummy method that can be used for test purposes.\n"
         "\n"
         "This method can be used by ARTS developers to quickly test stuff.\n"
         "The implementation is in file m_general.cc. This just saves you the\n"
         "trouble of adding a dummy method everytime you want to try\n"
         "something out quickly.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "timerStart" ),
        DESCRIPTION
        (
         "Initializes the CPU timer."
         "\n"
         "Use *timerStop* to stop the timer.\n"
         "\n"
         "Usage example:\n"
         "   timerStart\n"
         "   ReadXML(f_grid,\"frequencies.xml\")\n"
         "   timerStop\n"
         "   Print(timer)\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( "timer" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "timerStop" ),
        DESCRIPTION
        (
         "Stops the CPU timer."
         "\n"
         "See *timerStart* for example usage.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( "timer" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "timer" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "TMatrixTest" ),
        DESCRIPTION
        (
         "T-Matrix validation test.\n"
         "\n"
         "Executes the standard test included with the T-Matrix Fortran code.\n"
         "Should give the same as running the tmatrix_lp executable in\n"
         "3rdparty/tmatrix/.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT(),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "Touch" ),
        DESCRIPTION
        (
         "As *Ignore* but for agenda output.\n"
         "\n"
         "This method is handy for use in agendas in order to suppress\n"
         "warnings about unused output workspace variables. What it does is:\n"
         "Nothing!\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT(),
        GOUT(      "in"    ),
        GOUT_TYPE( "Any" ),
        GOUT_DESC( "Variable to do nothing with." ),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC(),
        SETMETHOD(      false ),
        AGENDAMETHOD(   false ),
        USES_TEMPLATES( true  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "VectorAddScalar" ),
        DESCRIPTION
        (
         "Adds a scalar to all elements of a vector.\n"
         "\n"
         "The result can either be stored in the same or another vector.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT(      "out"     ),
        GOUT_TYPE( "Vector" ),
        GOUT_DESC( "Output vector" ),
        IN(),
        GIN(         "in"    , "value"   ),
        GIN_TYPE(    "Vector", "Numeric" ),
        GIN_DEFAULT( NODEF   , NODEF     ),
        GIN_DESC( "Input vector", "The value to be added to the vector." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "VectorCrop" ),
        DESCRIPTION
        (
         "Keeps only values of a vector inside the specified range.\n"
         "\n"
         "All values outside the range [min_value,max-value] are removed.\n"
         "Note the default values, that basically should act as -+Inf.\n"
         "\n"
         "The result can either be stored in the same or another vector.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT(      "out"     ),
        GOUT_TYPE( "Vector" ),
        GOUT_DESC( "Cropped vector" ),
        IN(),
        GIN(         "in"    , "min_value", "max_value"   ),
        GIN_TYPE(    "Vector", "Numeric", "Numeric" ),
        GIN_DEFAULT( NODEF   , "-99e99", "99e99"    ),
        GIN_DESC( "Original vector", "Minimum value to keep",
                                     "Maximum value to keep" )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "VectorExtractFromMatrix" ),
        DESCRIPTION
        (
         "Extracts a Vector from a Matrix.\n"
         "\n"
         "Copies row or column with given Index from input Matrix variable\n"
         "to create output Vector.\n"
         ),
        AUTHORS( "Patrick Eriksson, Oliver Lemke, Stefan Buehler" ),
        OUT(),
        GOUT(      "out"      ),
        GOUT_TYPE( "Vector" ),
        GOUT_DESC( "Extracted vector." ),
        IN(),
        GIN(          "in"    , "i"    , "direction" ),
        GIN_TYPE(     "Matrix", "Index", "String"    ),
        GIN_DEFAULT(  NODEF   , NODEF  , NODEF       ),
        GIN_DESC( "Input matrix.",
                  "Index of row or column.",
                  "Direction. \"row\" or \"column\"." 
                  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "VectorFlip" ),
        DESCRIPTION
        (
         "Flips a vector.\n"
         "\n"
         "The output is the input vector in reversed order. The result can\n"
         "either be stored in the same or another vector.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT(      "out"       ),
        GOUT_TYPE( "Vector" ),
        GOUT_DESC( "Output vector." ),
        IN(),
        GIN(      "in"     ),
        GIN_TYPE( "Vector" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "Input vector." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "VectorInsertGridPoints" ),
        DESCRIPTION
        (
         "Insert some additional points into a grid.\n"
         "\n"
         "This method can for example be used to add line center frequencies to\n"
         "a regular frequency grid. If the original grid is [1,2,3], and the\n"
         "additional points are [2.2,2.4], the result will be [1,2,2.2,2.4,3].\n"
         "\n"
         "It is assumed that the original grid is sorted, otherwise a runtime\n"
         "error is thrown. The vector with the points to insert does not have to\n"
         "be sorted. If some of the input points are already in the grid, these\n"
         "points are not inserted again. New points outside the original grid are\n"
         "appended at the appropriate end. Input vector and output vector can be\n"
         "the same.\n"
         "\n"
         "Generic output:\n"
         "  Vector : The new grid vector.\n"
         "\n"
         "Generic input:\n"
         "  Vector : The original grid vector.\n"
         "  Vector : The points to insert.\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT(),
        GOUT(      "out"       ),
        GOUT_TYPE( "Vector" ),
        GOUT_DESC( "The new grid vector" ),
        IN(),
        GIN(       "in"      , "points"       ),
        GIN_TYPE(     "Vector", "Vector" ),
        GIN_DEFAULT(  NODEF   , NODEF    ),
        GIN_DESC( "The original grid vector",
                  "The points to insert" )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "VectorLinSpace" ),
        DESCRIPTION
        (
         "Initializes a vector with linear spacing.\n"
         "\n"
         "The first element equals always the start value, and the spacing\n"
         "equals always the step value, but the last value can deviate from\n"
         "the stop value. *step* can be both positive and negative.\n"
         "\n"
         "The created vector is [start, start+step, start+2*step, ...]\n "
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT(      "out"      ),
        GOUT_TYPE( "Vector" ),
        GOUT_DESC( "Output vector." ),
        IN(),
        GIN(         "start",   "stop",    "step"    ),
        GIN_TYPE(    "Numeric", "Numeric", "Numeric" ),
        GIN_DEFAULT( NODEF,     NODEF,     NODEF     ),
        GIN_DESC( "Start value.",
                  "Maximum/minimum value of the end value",
                  "Spacing of the vector." 
                  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "VectorLogSpace" ),
        DESCRIPTION
        (
         "Initializes a vector with logarithmic spacing.\n"
         "\n"
         "The first element equals always the start value, and the spacing\n"
         "equals always the step value, but note that the last value can \n"
         "deviate from the stop value. The keyword step can be both positive\n"
         "and negative.\n"
         "\n"
         "Note, that although start has to be given in direct coordinates,\n"
         "step has to be given in log coordinates.\n"
         "\n"
         "Explicitly, the vector is:\n"
         " exp([ln(start), ln(start)+step, ln(start)+2*step, ...])\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT(),
        GOUT(      "out"       ),
        GOUT_TYPE( "Vector" ),
        GOUT_DESC( "Variable to initialize." ),
        IN(),
        GIN( "start",   "stop",    "step"    ),
        GIN_TYPE(    "Numeric", "Numeric", "Numeric" ),
        GIN_DEFAULT( NODEF,     NODEF,     NODEF ),
        GIN_DESC( "The start value. (Direct coordinates!)",
                  "The maximum value of the end value. (Direct coordinates!)",
                  "The spacing of the vector. (Log coordinates!)" )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "VectorMatrixMultiply" ),
        DESCRIPTION
        (
         "Multiply a Vector with a Matrix and store the result in another\n"
         "Vector.\n"
         "\n"
         "This just computes the normal Matrix-Vector product, y=M*x. It is ok\n"
         "if input and output Vector are the same. This function is handy for\n"
         "multiplying the H Matrix to spectra.\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT(),
        GOUT(      "out"       ),
        GOUT_TYPE( "Vector" ),
        GOUT_DESC( "The result of the multiplication (dimension m)." ),
        IN(),
        GIN(       "m"      , "v"       ),
        GIN_TYPE(     "Matrix", "Vector" ),
        GIN_DEFAULT(  NODEF   , NODEF    ),
        GIN_DESC( "The Matrix to multiply (dimension mxn).",
                  "The original Vector (dimension n)." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "VectorNLinSpace" ),
        DESCRIPTION
        (
         "Creates a vector with length *nelem*, equally spaced between the\n"
         "given end values.\n"
         "\n"
         "The length (*nelem*) must be larger than 1.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT(      "out"      ),
        GOUT_TYPE( "Vector" ),
        GOUT_DESC( "Variable to initialize." ),
        IN( "nelem" ),
        GIN(         "start",   "stop"    ),
        GIN_TYPE(    "Numeric", "Numeric" ),
        GIN_DEFAULT( NODEF,     NODEF     ),
        GIN_DESC( "Start value.",
                  "End value." 
                  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "VectorNLogSpace" ),
        DESCRIPTION
        (
         "Creates a vector with length *nelem*, equally logarithmically\n"
         "spaced between the given end values.\n"
         "\n"
         "The length (*nelem*) must be larger than 1.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT(      "out"      ),
        GOUT_TYPE( "Vector" ),
        GOUT_DESC( "Variable to initialize." ),
        IN( "nelem" ),
        GIN(         "start",   "stop"    ),
        GIN_TYPE(    "Numeric", "Numeric" ),
        GIN_DEFAULT( NODEF,     NODEF     ),
        GIN_DESC( "Start value.",
                  "End value." 
                  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "VectorScale" ),
        DESCRIPTION
        (
         "Scales all elements of a vector with the same value.\n"
         "\n"
         "The result can either be stored in the same or another vector.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT(      "out"       ),
        GOUT_TYPE( "Vector" ),
        GOUT_DESC( "Output vector." ),
        IN(),
        GIN(      "in"      ,
                  "value" ),
        GIN_TYPE(    "Vector",
                     "Numeric" ),
        GIN_DEFAULT( NODEF   ,
                     NODEF ),
        GIN_DESC( "Input vector.",
                  "Scaling value." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "VectorSetConstant" ),
        DESCRIPTION
        (
         "Creates a vector and sets all elements to the specified value.\n"
         "\n"
         "The vector length is determined by *nelem*.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT(      "out"      ),
        GOUT_TYPE( "Vector" ),
        GOUT_DESC( "Variable to initialize." ),
        IN( "nelem" ),
        GIN(         "value"   ),
        GIN_TYPE(    "Numeric" ),
        GIN_DEFAULT( NODEF     ),
        GIN_DESC( "Vector value." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "VectorSet" ),
        DESCRIPTION
        (
         "Create a vector from the given list of numbers.\n"
         "\n"
         "   VectorSet(p_grid, [1000, 100, 10] )\n"
         "   Will create a p_grid vector with these three elements.\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT(),
        GOUT(      "out"       ),
        GOUT_TYPE( "Vector" ),
        GOUT_DESC( "Variable to initialize." ),
        IN(),
        GIN( "value"   ),
        GIN_TYPE(    "Vector" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC( "The vector elements." ),
        SETMETHOD( true )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "VectorZtanToZaRefr1D" ),
        DESCRIPTION
        (
         "Converts a set of true tangent altitudes to zenith angles.\n"
         "\n"
         "The tangent altitudes are given to the function as a vector, which\n"
         "are converted to a generic vector of zenith angles. The position of\n"
         "the sensor is given by the WSV *sensor_pos*. The function works\n"
         "only for 1D. The zenith angles are always set to be positive.\n"
         ),
        AUTHORS( "Patrick Eriksson", "Mattias Ekstrom" ),
        OUT(),
        GOUT(      "v_za"       ),
        GOUT_TYPE( "Vector" ),
        GOUT_DESC( "Vector with zenith angles." ),
        IN( "refr_index_air_agenda", "sensor_pos", "p_grid", "t_field", 
            "z_field", "vmr_field", "refellipsoid", "atmosphere_dim", 
            "f_grid" ),
        GIN(         "v_ztan" ),
        GIN_TYPE(    "Vector" ),
        GIN_DEFAULT( NODEF    ),
        GIN_DESC( "Vector with tangent altitudes." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "VectorZtanToZa1D" ),
        DESCRIPTION
        (
         "Converts a set of geometrical tangent altitudes to zenith angles.\n"
         "\n"
         "The tangent altitudes are given to the function as a vector, which\n"
         "are converted to a generic vector of zenith angles. The position of\n"
         "the sensor is given by the WSV *sensor_pos*. The function works\n"
         "only for 1D. The zenith angles are always set to be positive.\n"
         ),
        AUTHORS( "Patrick Eriksson", "Mattias Ekstrom" ),
        OUT(),
        GOUT(      "v_za"       ),
        GOUT_TYPE( "Vector" ),
        GOUT_DESC( "Vector with zenith angles." ),
        IN( "sensor_pos", "refellipsoid", "atmosphere_dim" ),
        GIN(         "v_ztan" ),
        GIN_TYPE(    "Vector" ),
        GIN_DEFAULT( NODEF    ),
        GIN_DESC( "Vector with tangent altitudes." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "verbosityInit" ),
        DESCRIPTION
        (
         "Initializes the verbosity levels.\n"
         "\n"
         "Sets verbosity to defaults or the levels specified by -r on the command line.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( "verbosity" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "verbositySet" ),
        DESCRIPTION
        (
         "Sets the verbosity levels.\n"
         "\n"
         "Sets the reporting level for agenda calls, screen and file.\n"
         "All reporting levels can reach from 0 (only error messages)\n"
         "to 3 (everything). The agenda setting applies in addition\n"
         "to both screen and file output.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( "verbosity" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(         "agenda", "screen", "file" ),
        GIN_TYPE(    "Index",  "Index",  "Index" ),
        GIN_DEFAULT( NODEF,    NODEF,    NODEF),
        GIN_DESC(    "Agenda verbosity level",
                     "Screen verbosity level",
                     "Report file verbosity level")
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "verbositySetAgenda" ),
        DESCRIPTION
        (
         "Sets the verbosity level for agenda output.\n"
         "\n"
         "See *verbositySet*\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( "verbosity" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "verbosity" ),
        GIN(         "level" ),
        GIN_TYPE(    "Index" ),
        GIN_DEFAULT( NODEF),
        GIN_DESC(    "Agenda verbosity level")
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "verbositySetFile" ),
        DESCRIPTION
        (
         "Sets the verbosity level for report file output.\n"
         "\n"
         "See *verbositySet*\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( "verbosity" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "verbosity" ),
        GIN(         "level" ),
        GIN_TYPE(    "Index" ),
        GIN_DEFAULT( NODEF),
        GIN_DESC(    "Report file verbosity level")
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "verbositySetScreen" ),
        DESCRIPTION
        (
         "Sets the verbosity level for screen output.\n"
         "\n"
         "See *verbositySet*\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT( "verbosity" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "verbosity" ),
        GIN(         "level" ),
        GIN_TYPE(    "Index" ),
        GIN_DEFAULT( NODEF),
        GIN_DESC(    "Screen verbosity level")
        ));

  md_data_raw.push_back     
    ( MdRecord
      ( NAME( "WMRFSelectChannels" ),
        DESCRIPTION
        (
         "Select some channels for WMRF calculation.\n"
         "\n"
         "The HIRS fast setup consists of a precalculated frequency grid\n"
         "covering all HIRS channels, and associated weights for each channel,\n"
         "stored in a weight matrix. (A *sensor_response* matrix.)\n"
         "\n"
         "If not all channels are requested for\n"
         "simulation, then this method can be used to remove the unwanted\n"
         "channels. It changes a number of variables in consistent fashion:\n"
         "\n"
         "- Unwanted channels are removed from f_backend. \n"
         "- Unwanted channels are removed from wmrf_weights.\n"
         "- Unnecessary frequencies are removed from f_grid.\n"
         "- Unnecessary frequencies are removed from wmrf_weights.\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT( "f_grid", "wmrf_weights",
             "f_backend" ),
        GOUT(      ),
        GOUT_TYPE( ),
        GOUT_DESC(),
        IN( "f_grid", "f_backend", 
            "wmrf_weights", "wmrf_channels"  ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "WriteMolTau" ),
        DESCRIPTION
        (
         "Writes a 'molecular_tau_file' as required for libRadtran.\n"
         "\n"
         "The libRadtran (www.libradtran.org) radiative transfer package is a \n"
         "comprehensive package for various applications, it can be used to \n"
         "compute radiances, irradiances, actinic fluxes, ... for the solar \n"
         "and the thermal spectral ranges. Absorption is usually treated using \n"
         "k-distributions or other parameterizations. For calculations with high \n"
         "spectral resolution it requires absorption coefficients from an external \n"
         "line-by-line model. Using this method, arts generates a file that can be \n"
         "used by libRadtran (option molecular_tau_file)."
         "\n"
         ),
        AUTHORS( "Claudia Emde" ),
        OUT(),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN("f_grid", "z_field", "propmat_clearsky_field", "atmosphere_dim" ),
        GIN("filename"),
        GIN_TYPE("String"),
        GIN_DEFAULT( NODEF),
        GIN_DESC("Name of the *molecular_tau_file*." )
        ));
  
  md_data_raw.push_back
    ( MdRecord
      ( NAME( "WriteNetCDF" ),
        DESCRIPTION
        (
         "Writes a workspace variable to a NetCDF file.\n"
         "\n"
         "This method can write variables of limited groups.\n"
         "\n"
         "If the filename is omitted, the variable is written\n"
         "to <basename>.<variable_name>.nc.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT(),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN(),
        GIN(          "in",
                      "filename" ),
        GIN_TYPE(     "Vector, Matrix, Tensor3, Tensor4, Tensor5, ArrayOfVector,"
                      "ArrayOfMatrix, GasAbsLookup",
                      "String" ),
        GIN_DEFAULT(  NODEF,
                      "" ),
        GIN_DESC(     "Variable to be saved.",
                      "Name of the NetCDF file." ),
        SETMETHOD(      false ),
        AGENDAMETHOD(   false ),
        USES_TEMPLATES( true  ),
        PASSWORKSPACE(  false ),
        PASSWSVNAMES(   true  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "WriteNetCDFIndexed" ),
        DESCRIPTION
        (
         "As *WriteNetCDF*, but creates indexed file names.\n"
         "\n"
         "This method can write variables of any group.\n"
         "\n"
         "If the filename is omitted, the variable is written\n"
         "to <basename>.<variable_name>.nc.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT(),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "file_index" ),
        GIN(          "in",
                      "filename" ),
        GIN_TYPE(     "Vector, Matrix, Tensor3, Tensor4, Tensor5, ArrayOfVector,"
                      "ArrayOfMatrix, GasAbsLookup",
                      "String" ),
        GIN_DEFAULT(  NODEF,
                      "" ),
        GIN_DESC(     "Variable to be saved.",
                      "Name of the NetCDF file." ),
        SETMETHOD(      false ),
        AGENDAMETHOD(   false ),
        USES_TEMPLATES( true  ),
        PASSWORKSPACE(  false ),
        PASSWSVNAMES(   true  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "WriteXML" ),
        DESCRIPTION
        (
         "Writes a workspace variable to an XML file.\n"
         "\n"
         "This method can write variables of any group.\n"
         "\n"
         "If the filename is omitted, the variable is written\n"
         "to <basename>.<variable_name>.xml.\n"
         "If no_clobber is set to 1, an increasing number will be\n"
         "appended to the filename if the file already exists.\n"
         ),
        AUTHORS( "Oliver Lemke" ),
        OUT(),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "output_file_format" ),
        GIN(         "in",
                     "filename",
                     "no_clobber"),
        GIN_TYPE(    "Any",
                     "String",
                     "Index"),
        GIN_DEFAULT( NODEF,
                     "",
                     "0"),
        GIN_DESC(    "Variable to be saved.",
                     "Name of the XML file.",
                     "0: Overwrite existing files, 1: Use unique filenames"),
        SETMETHOD(      false ),
        AGENDAMETHOD(   false ),
        USES_TEMPLATES( true  ),
        PASSWORKSPACE(  false ),
        PASSWSVNAMES(   true  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "WriteXMLIndexed" ),
        DESCRIPTION
        (
         "As *WriteXML*, but creates indexed file names.\n"
         "\n"
         "The variable is written to a file with name:\n"
         "   <filename>.<file_index>.xml.\n"
         "where <file_index> is the value of *file_index*.\n"
         "\n"
         "This means that *filename* shall here not include the .xml\n"
         "extension. Omitting filename works as for *WriteXML*.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT(),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "output_file_format", "file_index" ),
        GIN(          "in", "filename" ),
        GIN_TYPE(     "Any", "String"   ),
        GIN_DEFAULT(  NODEF, ""         ),
        GIN_DESC( "Workspace variable to be saved.",
                  "File name. See above." 
                  ),
        SETMETHOD(      false ),
        AGENDAMETHOD(   false ),
        USES_TEMPLATES( true  ),
        PASSWORKSPACE(  false ),
        PASSWSVNAMES(   true  )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "yApplyUnit" ),
        DESCRIPTION
        (
         "Conversion of *y* to other spectral units.\n"
         "\n"
         "Any conversion to brightness temperature is normally made inside\n"
         "*yCalc*. This method makes it possible to also make this conversion\n"
         "after *yCalc*, but with restrictions for *jacobian* and with.\n"
         "respect to the n2-law of radiance.\n"
         "\n"
         "The conversion made inside *iyEmissionStandard* is mimiced\n"
         "and see that method for constraints and selection of output units.\n"
         "This with the restriction that the n2-law can be ignored. The later\n"
         "is the case if the sensor is placed in space, or if the refractive\n"
         "only devaites slightly from unity.\n"
         "\n"
         "The method handles *y* and *jacobian* in parallel, where\n"
         "the last variable is only considered if it is set. The\n"
         "input data must be in original radiance units. A completely\n"
         "stringent check of this can not be performed.\n"
         "\n"
         "The method can not be used with jacobian quantities that are not\n"
         "obtained through radiative transfer calculations. One example on\n"
         "quantity that can not be handled is *jacobianAddPolyfit*. There\n"
         "are no automatic checks warning for incorrect usage!\n"
         "\n" 
         "If you are using this method, *iy_unit* should be set to \"1\" when\n"
         "calling *yCalc*, and be changed before calling this method.\n"
         "\n" 
         "Conversion of *y_aux* is not supported.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "y", "jacobian" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "y", "jacobian", "y_f", "y_pol", "iy_unit" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "ybatchCalc" ),
        DESCRIPTION
        (
         "Performs batch calculations for the measurement vector y.\n"
         "\n"
         "We perform *ybatch_n* jobs, starting at index *ybatch_start*. (Zero\n"
         "based indexing, as usual.) The output array *ybatch* will have\n"
         "ybatch_n elements. Indices in the output array start\n"
         "with zero, independent of *ybatch_start*.\n"
         "\n"
         "The method performs the following:\n"
         "   1. Sets *ybatch_index* = *ybatch_start*.\n"
         "   2. Performs a-d until\n"
         "      *ybatch_index* = *ybatch_start* + *ybatch_n*.\n"
         "        a. Executes *ybatch_calc_agenda*.\n"
         "        b. If *ybatch_index* = *ybatch_start*, resizes *ybatch*\n"
         "           based on *ybatch_n* and length of *y*.\n"
         "        c. Copies *y* to *ybatch_index* - *ybatch_start*\n"
         "           of *ybatch*.\n"
         "        d. Adds 1 to *ybatch_index*.\n"
         "\n"
         "Beside the *ybatch_calc_agenda*, the WSVs *ybatch_start*\n"
         "and *ybatch_n* must be set before calling this method.\n"
         "Further, *ybatch_calc_agenda* is expected to produce a\n"
         "spectrum and should accordingly include a call of *yCalc*\n"
         "(or asimilar method).\n"
         "\n"
         "The input variable *ybatch_start* is set to a default of zero in\n"
         "*general.arts*.\n"
         "\n"
         "An agenda that calculates spectra for different temperature profiles\n"
         "could look like this:\n"
         "\n"
         "   AgendaSet(ybatch_calc_agenda){\n"
         "      Extract(t_field,tensor4_1,ybatch_index)\n"
         "      yCalc\n"
         "   }\n"
         "\n"
         "Jacobians are also collected, and stored in output variable *ybatch_jacobians*. \n"
         "(This will be empty if yCalc produces empty Jacobians.)\n"
         "\n"
         "See the user guide for further practical examples.\n"
         ),
        AUTHORS( "Stefan Buehler" ),
        OUT( "ybatch", "ybatch_aux", "ybatch_jacobians" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "ybatch_start", "ybatch_n", "ybatch_calc_agenda" ), 
        GIN( "robust" ),
        GIN_TYPE(    "Index" ),
        GIN_DEFAULT( "0" ),
        GIN_DESC(
                 "A flag with value 1 or 0. If set to one, the batch\n"
                 "calculation will continue, even if individual jobs\n"
                 "fail. In that case, a warning message is written to\n"
                 "screen and file (out1 output stream), and ybatch for the\n"
                 "failed job is set to -1. The robust behavior does only work\n"
                 "properly if your control file is run single threaded.\n"
                 "Set \"--numthreads 1\". See \"arts --help\"."
                 )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "ybatchMetProfiles" ),
        DESCRIPTION
        (
         "This method is used for simulating ARTS for metoffice model fields"
         "\n"
         "This method reads in *met_amsu_data* which contains the\n"
         "lat-lon of the metoffice profile files as a Matrix. It then\n"
         "loops over the number of profiles and corresponding to each\n"
         "longitude create the appropriate profile basename. Then,\n"
         "corresponding to each basename we have temperature field, altitude\n"
         "field, humidity field and particle number density field. The\n"
         "temperature field and altitude field are stored in the same dimensions\n"
         "as *t_field_raw* and *z_field_raw*. The oxygen and nitrogen VMRs are\n"
         "set to constant values of 0.209 and 0.782, respectively and are used\n"
         "along with humidity field to generate *vmr_field_raw*. \n"
         "\n"
         "The three fields *t_field_raw*, *z_field_raw*, and *vmr_field_raw* are\n"
         "given as input to *met_profile_calc_agenda* which is called in this\n"
         "method. See documentation of WSM *met_profile_calc_agenda* for more\n"
         "information on this agenda. \n"
         "\n"
         "The method also converts satellite zenith angle to appropriate\n"
         "*sensor_los*. It also sets the *p_grid* and *cloudbox_limits*\n"
         "from the profiles inside the function\n"
         ),
        AUTHORS( "Sreerekha T.R." ),
        OUT( "ybatch" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_species", "met_profile_calc_agenda", "f_grid", "met_amsu_data",
            "sensor_pos", "refellipsoid", "lat_grid", "lon_grid", 
            "atmosphere_dim", "scat_data_array" ),
        GIN( "nelem_p_grid", "met_profile_path", "met_profile_pnd_path" ),
        GIN_TYPE(    "Index",        "String",           "String" ),
        GIN_DEFAULT( NODEF,          NODEF,              NODEF ),
        GIN_DESC( "FIXME DOC",
                  "FIXME DOC",
                  "FIXME DOC" )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "ybatchMetProfilesClear" ),
        DESCRIPTION
        (
         "This method is used for simulating ARTS for metoffice model fields\n"
         "for clear sky conditions.\n"
         "\n"
         "This method reads in *met_amsu_data* which contains the\n"
         "lat-lon of the metoffice profile files as a Matrix. It then\n"
         "loops over the number of profiles and corresponding to each\n"
         "longitude create the appropriate profile basename. Then,\n"
         "Corresponding to each basename we have temperature field, altitude\n"
         "field, humidity field and particle number density field. The\n"
         "temperature field and altitude field are stored in the same dimensions\n"
         "as *t_field_raw* and *z_field_raw*. The oxygen and nitrogen VMRs are\n"
         "set to constant values of 0.209 and 0.782, respectively and are used\n"
         "along with humidity field to generate *vmr_field_raw*. \n"
         "\n"
         "The three fields *t_field_raw*, *z_field_raw*, and *vmr_field_raw* are\n"
         "given as input to *met_profile_calc_agenda* which is called in this\n"
         "method. See documentation of WSM *met_profile_calc_agenda* for more\n"
         "information on this agenda. \n"
         "\n"
         "The method also converts satellite zenith angle to appropriate\n"
         "*sensor_los*. It also sets the *p_grid* and *cloudbox_limits*\n"
         "from the profiles inside the function\n"
         ),
        AUTHORS( "Seerekha T.R." ),
        OUT( "ybatch" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "abs_species", "met_profile_calc_agenda", 
            "f_grid", "met_amsu_data", "sensor_pos", "refellipsoid" ),
        GIN( "nelem_p_grid", "met_profile_path" ),
        GIN_TYPE(    "Index",        "String" ),
        GIN_DEFAULT( NODEF,          NODEF ),
        GIN_DESC( "FIXME DOC",
                  "FIXME DOC" )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "yCalc" ),
        DESCRIPTION
        (
         "Calculation of complete measurement vectors (y).\n"
         "\n"
         "The method performs radiative transfer calculations from a sensor\n"
         "perspective. Radiative transfer calculations are performed for\n"
         "monochromatic pencil beams, following *iy_main_agenda* and\n"
         "associated agendas. Obtained radiances are weighted together by\n"
         "*sensor_response*, to include the characteristics of the sensor.\n"
         "The measurement vector obtained can contain anything from a single\n"
         "frequency value to a series of measurement scans (each consisting\n"
         "of a series of spectra), all depending on the settings. Spectra\n"
         "and jacobians are calculated in parallel.\n"
         "\n"
         "The frequency, polarisation etc. for each measurement value is\n" 
         "given by *y_f*, *y_pol*, *y_pos* and *y_los*.\n"
         "\n"
         "See the method selected for *iy_main_agenda* for quantities\n"
         "that can be obtained by *y_aux*. However, in no case data of\n"
         "along-the-path type can be extracted.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "y", "y_f", "y_pol", "y_pos", "y_los", "y_aux", "jacobian" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atmgeom_checked", "atmfields_checked", 
            "atmosphere_dim", "t_field", "z_field", 
            "vmr_field", "cloudbox_on", "cloudbox_checked", "sensor_checked", 
            "stokes_dim", "f_grid", "sensor_pos", "sensor_los",
            "transmitter_pos", "mblock_za_grid", "mblock_aa_grid",
            "antenna_dim", "sensor_response", "sensor_response_f",
            "sensor_response_pol", "sensor_response_za", "sensor_response_aa",
            "iy_main_agenda", "jacobian_agenda", "jacobian_do", 
            "jacobian_quantities", "jacobian_indices", "iy_aux_vars" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "yCalcAppend" ),
        DESCRIPTION
        (
         "Replaces *yCalc* if a measurement shall be appended to an\n"
         "existing one.\n"
         "\n"
         "The method works basically as *yCalc* but appends the results to\n"
         "existing data, instead of creating completely new *y* and its\n"
         "associated variables. This method is required if your measurement\n"
         "consists of data from two instruments using different observation\n"
         "techniques (corresponding to different iyCalc-methods). One such\n"
         "example is if emission and transmission data are combined into a\n"
         "joint retrieval. The method can also be used to get around the\n"
         "constrain that *sensor_response* is required to be the same for\n"
         "all data.\n"
         "\n"
         "The new measurement is simply appended to the input *y*, and the\n"
         "other output variables are treated correspondingly. Data are\n"
         "appended \"blindly\" in *y_aux*. That is, data of different type\n"
         "are appended if *iy_aux_vars* differs between the two measurements,\n"
         "the data are appended strictly following the order. First variable\n"
         "of second measurement is appended to first variable of first\n"
         "measurement, and so on. The number of auxiliary variables can differ\n"
         "between the measurements. Missing data are set to zero.\n"
         "\n"
         "The set of retrieval quantities can differ between the two\n"
         "calculations. If an atmospheric quantity is part of both Jacobians,\n"
         "the same retrieval grids must be used in both cases.\n"
         "The treatment of instrument related Jacobians (baseline fits,\n"
         "pointing ...) follows the *append_instrument_wfs* argument.\n"
         "\n"
         "A difference to *yCalc* is that *jacobian_quantities* and\n"
         "*jacobian_indices* are both in- and output variables. The input\n"
         "version shall match the measurement to be calculated, while the\n"
         "version matches the output *y*, the combined, measurements. Copies\n"
         "of *jacobian_quantities* and * jacobian_indices* of the first\n"
         "measurement must be made and shall be provided to the method as\n"
         "*jacobian_quantities_copy* and *jacobian_indices_copy*.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "y", "y_f", "y_pol", "y_pos", "y_los", "y_aux", 
             "jacobian", "jacobian_quantities", "jacobian_indices" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "y", "y_f", "y_pol", "y_pos", "y_los", "y_aux", "jacobian",
            "atmgeom_checked", "atmfields_checked", 
            "atmosphere_dim", "t_field", "z_field", 
            "vmr_field", "cloudbox_on", "cloudbox_checked", "sensor_checked", 
            "stokes_dim", "f_grid", "sensor_pos", "sensor_los",
            "transmitter_pos", "mblock_za_grid", "mblock_aa_grid",
            "antenna_dim", "sensor_response", "sensor_response_f",
            "sensor_response_pol", "sensor_response_za", "sensor_response_aa",
            "iy_main_agenda", "jacobian_agenda", "jacobian_do", 
            "jacobian_quantities", "jacobian_indices", "iy_aux_vars" ),
        GIN( "jacobian_quantities_copy", "jacobian_indices_copy", 
             "append_instrument_wfs" ),
        GIN_TYPE( "ArrayOfRetrievalQuantity", "ArrayOfArrayOfIndex", "Index" ),
        GIN_DEFAULT( NODEF, NODEF, "0" ),
        GIN_DESC( "Copy of *jacobian_quantities* of first measurement.",
                  "Copy of *jacobian_indices* of first measurement.",
                  "Flag controlling if instrumental weighting functions are "
                  "appended or treated as different retrieval quantities." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "yCloudRadar" ),
        DESCRIPTION
        (
         "Replaces *yCalc* for cloud radar calculations.\n"
         "\n"
         "The output format for *iy* from *iyCloudRadar* differs from the\n"
         "standard one, and *yCalc* can not be used for cloud radar\n"
         "simulations. This method works largely as *yCalc*, but is tailored\n"
         "to handle the output from *iyCloudRadar*.\n"
         "\n"
         "The method requires additional information about the sensor,\n"
         "regarding its recieving properties. First of all, recieved\n"
         "polarisation states are taken from *sensor_pol_array*. Note\n"
         "that this WSV allows to define several measured polarisations\n"
         "for each transmitted siggnal. For example, it is possible to\n"
         "simulate transmission of V and measuring backsacttered V and H.\n"
         "\n"
         "Secondly, the range averaging is described by *range_bins*. These\n"
         "bins can either be specified in altitude or two-way travel time.\n"
         "In both case, the edges of the range bins shall be specified.\n"
         "All data (including auxiliary variables) are returned as the\n"
         "average inside the bins. If any bin extands outisde the covered\n"
         "range, zeros are added reflectivities, while for other quantities\n"
         "(e.g. temperature) the averaging is restricted to covered part.\n"
         "\n"
         "All auxiliary data from *iyCloudRadar* are handled.\n"
         "\n"
         "No Jacobian quantities are yet handled.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "y", "y_aux" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atmgeom_checked", "atmfields_checked", 
            "iy_aux_vars", "stokes_dim",
            "f_grid", "t_field", "z_field", "vmr_field", "cloudbox_on", 
            "cloudbox_checked", "sensor_pos", "sensor_los", "sensor_checked",
            "iy_main_agenda", "sensor_pol_array", "range_bins" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "ySimpleSpectrometer" ),
        DESCRIPTION
        (
         "Converts *iy* to *y* assuming a fixed frequency resolution.\n"
         "\n"
         "This is a short-cut, avoiding *yCalc*, that can be used to convert\n"
         "monochromatic pencil beam data to spectra with a fixed resolution.\n"
         "\n"
         "The method mimics a spectrometer with rectangular response\n"
         "functions, all having the same width (*df*). The position of\n"
         "the first spectrometer channel is set to f_grid[0]+df/2.\n"
         "The centre frequency of channels are returned as *y_f*.\n"
         "\n"
         "Auxiliary variables and *jacobian*s are not handled.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "y", "y_f" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "iy", "stokes_dim", "f_grid" ),
        GIN(      "df" ),
        GIN_TYPE( "Numeric" ),
        GIN_DEFAULT( NODEF ),
        GIN_DESC(    "Selected frequency resolution." )
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "wind_u_fieldIncludePlanetRotation" ),
        DESCRIPTION
        (
         "Maps the planet's rotation to an imaginary wind.\n"
         "\n"
         "This method is of relevance if the observation platform is not\n"
         "following the planet's rotation, and Doppler effects must be\n"
         "considered. Examples include full disk observations from another\n"
         "planet or a satellite not in orbit of the observed planet.\n"
         "\n"
         "The rotation of the planet is not causing any Doppler shift for\n"
         "1D and 2D simulations, and the method can only be used for 3D.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "wind_u_field" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "wind_u_field", "atmosphere_dim", "p_grid", "lat_grid", "lon_grid",
            "refellipsoid", "z_field", "planet_rotation_period" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));

  md_data_raw.push_back
    ( MdRecord
      ( NAME( "z_fieldFromHSE" ),
        DESCRIPTION
        (
         "Force altitudes to fulfil hydrostatic equilibrium.\n"
         "\n"
         "The method applies hydrostatic equilibrium. A mixture of \"dry\n"
         "air\" and water vapour (if present as *abs_species* tag) is assumed.\n"
         "That is, the air is assumed to be well mixed and its weight, apart\n"
         "from the water vapour, is constant (*molarmass_dry_air*). In\n"
         "addition, the effect of any particles (including liquid and ice\n"
         "particles) is neglected.\n"
         "\n"
         "The output is an update of *z_field*. This variable is expected to\n"
         "contain approximative altitudes when calling the function. The\n"
         "altitude matching *p_hse* is kept constant. Other input altitudes can\n"
         "basically be arbitrary, but good estimates give quicker calculations.\n"
         "\n"
         "The calculations are repeated until the change in altitude is below\n"
         "*z_hse_accuracy*. An iterative process is needed as gravity varies\n"
         "with altitude.\n"
         "\n"
         "For 1D and 2D, the geographical position is taken from *lat_true*\n"
         "and *lon_true*.\n"
         ),
        AUTHORS( "Patrick Eriksson" ),
        OUT( "z_field" ),
        GOUT(),
        GOUT_TYPE(),
        GOUT_DESC(),
        IN( "atmosphere_dim", "p_grid", "lat_grid", "lon_grid", "lat_true", 
            "lon_true", "abs_species", "t_field", "z_field", "vmr_field", 
            "refellipsoid", "z_surface", "atmfields_checked", "g0_agenda",
            "molarmass_dry_air", "p_hse", "z_hse_accuracy" ),
        GIN(),
        GIN_TYPE(),
        GIN_DEFAULT(),
        GIN_DESC()
        ));
}
