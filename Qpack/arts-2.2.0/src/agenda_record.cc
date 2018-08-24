/* Copyright (C) 2002-2012 Stefan Buehler <sbuehler@ltu.se>

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

/*!
  \file   agenda_record.cc
  \author Stefan Buehler <sbuehler@ltu.se>
  \date   Thu Mar 14 08:49:33 2002
  
  \brief  Implementation of agendas.
*/

#include <map>
#include <iostream>
#include "messages.h"
#include "agenda_record.h"
#include "wsv_aux.h"
#include "workspace_ng.h"

namespace global_data {
//! The map associated with agenda_data.
map<String, Index> AgendaMap;

extern const Array<AgRecord> agenda_data;
extern const ArrayOfString wsv_group_names;
}

//! The only non-trivial constructor for AgRecord, which sets all the fields.
/*! 
  We work on the assumption, that the workspace lookup data has been
  defined before. So, what we have to do here is make sure that this
  agenda exists.
  
  \param name Agenda name.
  \param description Agenda documentation.
  \param output List of output WSVs.
  \param input List of input WSVs.
*/
AgRecord::AgRecord(const char               name[],
                   const char               description[],
                   const MakeArray<String>& output,
                   const MakeArray<String>& input) : mname(name),
                                                     mdescription(description),
                                                     moutput(0),
                                                     minput(0)
{ 
  // We must check that this agenda exists in the workspace

  // Find returns end() if the name is not found in the map.  If
  // this assertion fails, it means that we are trying to set the
  // lookup data for an agenda that has not been defined in
  // wsv_data (i.e., in workspace.cc). First make a record entry
  // in workspace.cc for your agenda. If you have done so and
  // still get an assertion failure, then check that you spelled
  // the name in exactly the same way in both places.
  assert(Workspace::WsvMap.end() !=
         Workspace::WsvMap.find(mname));

  moutput.resize(output.nelem());
  for (Index j = 0; j < output.nelem(); ++j)
    {
      moutput[j] = get_wsv_id(output[j]);
      if (moutput[j] == -1)
        {
          ostringstream os;

          os << "Unknown output WSV " << output[j] << " in WSM " << mname;
          throw runtime_error(os.str());
        }
    }

  minput.resize(input.nelem());
  for (Index j = 0; j < input.nelem(); ++j)
    {
      minput[j] = get_wsv_id(input[j]);
      if (minput[j] == -1)
        {
          ostringstream os;

          os << "Unknown input WSV " << input[j] << " in WSM " << mname;
          throw runtime_error(os.str());
        }
    }

}

void define_agenda_map()
{
  using global_data::agenda_data;
  using global_data::AgendaMap;

  for (Index i = 0; i < agenda_data.nelem(); ++i)
    {
      AgendaMap[agenda_data[i].Name()] = i;
    }
}

//! Check that agendas.cc and workspace.cc are consistent.
/*! 
  This functions makes sure, that there is a matching entry in both
  lookup tables for each agenda.

  If the function returns at all, it will return true. The return
  value is only there so that we can put the function call in an
  assert statement.

  \return Always true.
*/
bool check_agenda_data()
{
  // Make external data visible
  using global_data::agenda_data;
  DEBUG_ONLY(using global_data::AgendaMap);

  Index i, j, k;

  k = 0;

  // Check, that each agenda from agenda_data occurs in wsv_data:
  for (i = 0; i < agenda_data.nelem(); ++i)
    {
      //      cout << "Checking wsv_data for " << agenda_data[i].Name() << ".\n";

      // Find returns end() if the name is not found in the map.  If
      // this assertion fails, it means that wsv_data does not contain
      // this agenda.
      // You have to add a record for your agenda in both files:
      // workspace.cc and agendas.cc. The name has to be spelled
      // exactly the same in both places.
      // Uncomment the cout statement above and recompile to see which
      // agenda causes the trouble.
      assert(Workspace::WsvMap.end() !=
             Workspace::WsvMap.find(agenda_data[i].Name()));
    }

  // Check, that each agenda from wsv_data occurs in agenda_data:
  for (j = 0; j < Workspace::wsv_data.nelem(); ++j)
    {
      // Is this an agenda WSV?
      if (get_wsv_group_id("Agenda") == Workspace::wsv_data[j].Group())
        {
          //      cout << "Checking agenda_data for " << Workspace::wsv_data[j].Name() << ".\n";

          // Find returns end() if the name is not found in the map.  If
          // this assertion fails, it means that agenda_data does not contain
          // this agenda.
          // You have to add a record for your agenda in both files:
          // workspace.cc and agendas.cc. The name has to be spelled
          // exactly the same in both places.
          // Uncomment the cout statement above and recompile to see which
          // agenda causes the trouble.
          assert(AgendaMap.end() !=
                 AgendaMap.find(Workspace::wsv_data[j].Name()));

          // Counts the number of agenda WSVs in Workspace::wsv_data:
          ++k;
        }
    }

  // As a last check we make sure that both lists contain the same
  // number of agendas:
  assert(i == k);

  return true;
}

//! Output operator for AgRecord.
/*! 
  
\param os Output stream.
\param agr Agenda record.

\return Output stream.
*/
ostream& operator<<(ostream& os, const AgRecord& agr)
{
  bool first;

  os << "\n*-------------------------------------------------------------------*\n"
  << "Workspace variable = " << agr.Name()
  << "\n---------------------------------------------------------------------\n"
  << "\n" << agr.Description() << "\n"
  << "\n---------------------------------------------------------------------\n";

  os << "Group  = Agenda\n";

  // Output:
  first = true;
  os << "Output = ";
  for (Index i = 0; i < agr.Out().nelem(); ++i)
    {
      if (first) first = false;
      else os << ", ";

      os << Workspace::wsv_data[agr.Out()[i]].Name();
    }
  os << "\n";

  // Input:
  first = true;
  os << "Input  = ";
  for (Index i = 0; i < agr.In().nelem(); ++i)
    {
      if (first) first = false;
      else os << ", ";

      os << Workspace::wsv_data[agr.In()[i]].Name();
    }
      
  os << "\n*-------------------------------------------------------------------*\n";

  return os;
}

//! Output operator for WsvRecord.
/*! 
  This has to be here rather than with workspace.cc or
  workspace_aux.cc, because it uses agenda_data and AgendaMap.

  \param os  Output stream.
  \param wr  Workspace variable record.

  \return Output stream.
*/
ostream& operator<<(ostream& os, const WsvRecord& wr)
{
  using global_data::wsv_group_names;

  // We need a special treatment for the case that the WSV is an agenda.

  if (get_wsv_group_id("Agenda") != wr.Group())
    {
      // No agenda.
      
      os << "\n*-------------------------------------------------------------------*\n"
         << "Workspace variable = " << wr.Name() 
         << "\n---------------------------------------------------------------------\n"
         << "\n" << wr.Description() << "\n" 
         << "\n---------------------------------------------------------------------\n"
         << "Group = " << wsv_group_names[wr.Group()]
         << "\n*-------------------------------------------------------------------*\n";
    }
  else
    {
      // Agenda.

      using global_data::agenda_data;

      // AgendaMap is constant here and should never be changed
      using global_data::AgendaMap;

      map<String, Index>::const_iterator j =
        AgendaMap.find(wr.Name());

      // Just for added safety, check that we really found something:
      assert(j != AgendaMap.end());

      cout << agenda_data[j->second] << "\n";
    }

  return os;
}

//! Write a agenda wrapper header.
/*!
  \param ofs The stream to write to.
  \param agr Agenda record.
*/
void write_agenda_wrapper_header(ofstream&       ofs,
                                 const AgRecord& agr)
{
  using global_data::wsv_group_names;

  // Wrapper function
  ofs << "void " << agr.Name() << "Execute(\n";

  // Wrapper function Workspace parameters
  ofs << "        // Workspace\n";
  ofs << "        Workspace& ws,\n";
  // Wrapper function output parameters
  const ArrayOfIndex& ago = agr.Out();
  ofs << "        // Output\n";
  for (ArrayOfIndex::const_iterator j = ago.begin(); j != ago.end(); j++)
    {
      ofs << "        ";
      ofs << wsv_group_names[Workspace::wsv_data[*j].Group()] << "& ";
      ofs << Workspace::wsv_data[*j].Name() << ",\n";
    }

  // Wrapper function input parameters
  const ArrayOfIndex& agi = agr.In();
  ofs << "        // Input\n";
  for (ArrayOfIndex::const_iterator j = agi.begin(); j != agi.end(); j++)
    {
      // Ignore Input parameters that are also output
      ArrayOfIndex::const_iterator it = ago.begin();
      while (it != ago.end() && *it != *j)
        it++;

      if (it == ago.end())
        {
          String group_name = wsv_group_names[Workspace::wsv_data[*j].Group()];

          ofs << "        const ";
          ofs << group_name;

          // Don't pass by reference for elementary types
          if (group_name != "Index" && group_name != "Numeric")
            {
              ofs << "&";
            }
          ofs << " " << Workspace::wsv_data[*j].Name() << ",\n";
        }
    }

  // Wrapper function agenda and silent parameters
  ofs << "        // Wrapper Input\n";
  ofs << "        const Agenda& input_agenda)";
}

