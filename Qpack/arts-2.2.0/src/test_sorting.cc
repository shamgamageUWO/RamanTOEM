/* Copyright (C) 2003-2012 Oliver Lemke <olemke@core-dump.info>

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License as
   published by the Free Software Foundation; either version 2 of the
   License, or (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
   USA. */

#include <ctime>
#include <cstdlib>
#include <iostream>

#include "arts.h"

#if HAVE_UNISTD_H
# include <sys/types.h>
# include <unistd.h>
#endif

#include "matpackI.h"
#include "sorting.h"

void
testVector ()
{
  // Array for output of sorted indexes
  ArrayOfIndex i;

  Vector v (10);
  v [0] = 2.2;
  v [1] = 1.1;
  v [2] = 3.3;
  v [3] = 7.7;
  v [4] = 6.6;
  v [5] = 9.9;
  v [6] = 4.4;
  v [7] = 8.8;
  v [8] = 5.5;
  v [9] = 10.01;

  cout << "Vector before sort:     " << v << endl;
  get_sorted_indexes (i, v);
  cout << "Index array after sort: " << i << endl;
  cout << "Sorted Vector:         ";
  for (Index j = 0; j < v.nelem (); j++)
    cout << " " << setw (3) << v[i[j]];
  cout << endl << endl;

}

#ifdef _POSIX_VERSION
void
testArray ()
{
  // Array for output of sorted indexes
  ArrayOfIndex i;

  ArrayOfIndex a (10);
  a [0] = 2;
  a [1] = 1;
  a [2] = 3;
  a [3] = 7;
  a [4] = 6;
  a [5] = 9;
  a [6] = 4;
  a [7] = 8;
  a [8] = 5;
  a [9] = 10;

  cout << "Array before sort:      " << a << endl;
  get_sorted_indexes (i, a);
  cout << "Index array after sort: " << i << endl;
  cout << "Sorted Array:          ";
  for (Index j = 0; j < a.nelem (); j++)
    cout << " " << setw (3) << a[i[j]];
  cout << endl << endl;
}

void
profileVector (Index n)
{
  cout << "Creating Vector with random numbers" << endl;

  srandom ((unsigned int)time (NULL));
  Vector v(n);
  for (Index i = 0; i < n; i++)
    v[i] = Numeric (random ());

  cout << "Now sorting" << endl;
  ArrayOfIndex i;
  get_sorted_indexes (i, v);
}
#endif

int
main (void)
{
#ifdef _POSIX_VERSION
  testVector ();
  testArray ();
#else
  cerr << "This test is only available when compiled with POSIX support."
    << endl;
#endif

//  profileVector (100 * 100 * 20 * 20);

  return (0);
}

