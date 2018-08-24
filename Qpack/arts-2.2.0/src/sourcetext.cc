/* Copyright (C) 2012 Oliver Lemke <olemke@core-dump.info>

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

#include <iostream>
#include "sourcetext.h"
#include "file.h"


void SourceText::AppendFile(const String& name) 
{
  mSfLine.push_back(mText.nelem());
  mSfName.push_back(name);

  read_text_from_file(mText, name);    
}


void SourceText::AdvanceChar() 
{
  if ( mColumn < mText[mLine].nelem()-1 )
    {
      ++mColumn;
    }
  else
    {
      mLineBreak = true;
      do
        {
          if (mLine>=mText.nelem())
            {
              throw Eot( "",
                         this->File(),
                         this->Line(),
                         this->Column() ); 
            }
          else if (mLine==mText.nelem()-1)
            {
              mColumn++;
              break;
            }
          else
            {
              ++mLine;
              mColumn = 0;
            }
        }
      while ( 1 > mText[mLine].nelem() ); // Skip empty lines.
    }
}


void SourceText::AdvanceLine() 
{
  mLineBreak = true;
  mColumn = 0;
  do
    {
      if (mLine>=mText.nelem()-1)
        {
          throw Eot( "",
                     this->File(),
                     this->Line(),
                     this->Column() ); 
        }
      else
        {
          ++mLine;
        }
    }
  while ( 1 > mText[mLine].nelem() ); // Skip empty lines.
}


const String& SourceText::File()
{
  Index i    = 0;
  bool   stop = false;

  while ( i<mSfLine.nelem()-1 && !stop )
    {
      if (mLine>=mSfLine[i+1]) ++i;
      else                     stop = true;
    }

  return mSfName[i];
}


Index SourceText::Line()
{
  Index i    = 0;
  bool   stop = false;

  while ( i<mSfLine.nelem()-1 && !stop )
    {
      if (mLine>=mSfLine[i+1]) ++i;
      else                     stop = true;
    }

  return mLine - mSfLine[i] + 1; 
}


void SourceText::Init()
{
  mLine   = 0;
  mColumn = 0;
    
  if ( 1 > mText.nelem() )
    {
      throw Eot( "Empty text!",
                 this->File(),
                 this->Line(),
                 this->Column() ); 
    }
  else
    {
      // Skip empty lines:
      while ( 1 > mText[mLine].nelem() )
        {
          if (mLine>=mText.nelem()-1)
            {
              throw Eot( "",
                         this->File(),
                         this->Line(),
                         this->Column() ); 
            }
          else
            {
              mLineBreak = true;
              ++mLine;
            }
        }
    }
}


std::ostream& operator << (std::ostream& os, const SourceText& text)
{
  for (Index i=0; i<text.mText.nelem();++i)
    os << i
       << "(" << text.mText[i].nelem() << ")"
       << ": " << text.mText[i] << '\n';
  return(os);
}

