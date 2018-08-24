/* Copyright (C) 2012 
Richard Larsson <ric.larsson@gmail.com>

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

/** Contains some additional functionality of the rational class
   \file   rational.cc
   
   \author Richard Larsson
   \date   2012-10-31
**/

#include "rational.h"

#include <stdexcept>
#include "mystring.h"


Index Rational::toIndex() const
{
    if (mdenom != 1)
    {
        std::ostringstream os;
        os << "Cannot convert Rational " << *this << " to Index.";
        throw std::runtime_error(os.str());
    }
    return mnom;
}


void Rational::Simplify()
{
    Index ii = mdenom;

    while( ii != 0 )
    {
        if( mnom % ii == 0 && mdenom % ii == 0 )
        {
            mnom /= ii;
            mdenom /= ii;

            if( mnom == 1 || mdenom == 1 || mnom == 0 || mnom == -1 )
                break;
        }
        if( mdenom < ii )
            ii = mdenom;
        else
            ii--;
    }
}

std::ostream& operator<<(std::ostream& os, const Rational& a)
{
    os << a.Nom() << "/" << a.Denom();
    return os;
}

std::istream& operator>>(std::istream& is, Rational& a)
{
    String s;
    Index nom;
    Index denom;
    char* endptr;

    is >> s;

    ArrayOfString as;

    s.split(as, "/");

    if (as.nelem() == 1)
    {
        nom=strtol(s.c_str(), &endptr, 10);
        if (endptr != s.c_str()+s.nelem())
            throw std::runtime_error("Error parsing quantum number");
        a = Rational(nom, 1);
    }
    else if (as.nelem() == 2)
    {
        nom=strtol(as[0].c_str(), &endptr, 10);
        if (endptr != as[0].c_str()+as[0].nelem())
            throw std::runtime_error("Error parsing quantum number nominator");
        denom=strtol(as[1].c_str(), &endptr, 10);
        if (endptr != as[1].c_str()+as[1].nelem())
            throw std::runtime_error("Error parsing quantum number denominator");
        a = Rational(nom, denom);
    }
    else
        throw std::runtime_error("Error parsing quantum number");

    return is;
}

Rational abs(const Rational& a)
{
    return a<Rational(0)?-a:a;
}
