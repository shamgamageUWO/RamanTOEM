/* Copyright (C) 2013 Oliver Lemke <olemke@core-dump.info>

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
  \file   m_xml.cc
  \author Oliver Lemke <olemke@core-dump.info>
  \date   2013-03-04

  \brief  Non-template implementations of workspace methods for XML IO.

*/

#include "m_xml.h"

/* Workspace method: Doxygen documentation will be auto-generated */
void
ReadXML (Workspace&    ws _U_,
         // WS Generic Output:
         Agenda&       v,
         // WS Generic Output Names:
         const String& v_name,
         // WS Generic Input:
         const String& f,
         // WS Generic Input Names:
         const String& f_name,
         const Verbosity& verbosity)
{
  ReadXML (v, v_name, f, f_name, verbosity);
}


/* Workspace method: Doxygen documentation will be auto-generated */
void
WriteXML (Workspace& ws _U_,
          //WS Input:
          const String& file_format,
          // WS Generic Input:
          const Agenda& v,
          const String& f,
          const Index&  no_clobber,
          // WS Generic Input Names:
          const String& v_name,
          const String& f_name,
          const String& no_clobber_name,
          const Verbosity& verbosity)
{
  WriteXML (file_format, v, f, no_clobber,
            v_name, f_name, no_clobber_name, verbosity);
}


/* Workspace method: Doxygen documentation will be auto-generated */
void
WriteXMLIndexed (Workspace& ws _U_,
                 //WS Input:
                 const String& file_format,
                 const Index&  file_index,
                 // WS Generic Input:
                 const Agenda& v,
                 const String& f,
                 // WS Generic Input Names:
                 const String& v_name,
                 const String& f_name,
                 const Verbosity& verbosity)
{
  WriteXMLIndexed (file_format, file_index, v, f, v_name, f_name, verbosity);
}


/* Workspace method: Doxygen documentation will be auto-generated */
void
output_file_formatSetAscii (// WS Output:
                            String& file_format,
                            const Verbosity&)
{
  file_format = "ascii";
}


/* Workspace method: Doxygen documentation will be auto-generated */
void
output_file_formatSetZippedAscii (// WS Output:
                                  String& file_format,
                                  const Verbosity&)
{
  file_format = "zascii";
}


/* Workspace method: Doxygen documentation will be auto-generated */
void
output_file_formatSetBinary (// WS Output:
                             String& file_format,
                             const Verbosity&)
{
  file_format = "binary";
}

