
/* Copyright (C) 2001-2012 Stefan Buehler <sbuehler@ltu.se>

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

/**
   Implementation of Tensors of Rank 7.

   Dimensions are called: library, vitrine, shelf, book, page, row, column.
   or short:              l,       v,       s,     b,    p,    r,   c
  
   \author Stefan Buehler
   \date   2001-11-22
*/

#ifndef matpackVII_h
#define matpackVII_h

#include "matpackVI.h"

/** The outermost iterator class for rank 7 tensors. This takes into
    account the defined strided. */
class Iterator7D {
public:
  // Constructors:
  /** Default constructor. */
  Iterator7D() : msv(), mstride(0) { /* Nothing to do here. */ }

  /** Explicit constructor. */
  Iterator7D(const Tensor6View& x, Index stride) : msv(x), mstride(stride)
      { /* Nothing to do here. */ }

  // Operators:
  /** Prefix increment operator. */
  Iterator7D& operator++() { msv.mdata += mstride; return *this; }

  /** Not equal operator, needed for algorithms like copy.
      FIXME: Is it really necessary to have such a complicated check
      here? It could be sufficient to just test
      msv.mdata!=other.msv.mdata. */
  bool operator!=(const Iterator7D& other) const
    { if ( msv.mdata +
           msv.mvr.mstart +
           msv.msr.mstart +
           msv.mbr.mstart +
           msv.mpr.mstart +
           msv.mrr.mstart +
           msv.mcr.mstart 
           !=
           other.msv.mdata +
           other.msv.mvr.mstart +
           other.msv.msr.mstart +
           other.msv.mbr.mstart +
           other.msv.mpr.mstart +
           other.msv.mrr.mstart +
           other.msv.mcr.mstart )
        return true;
      else
        return false;
    }

  /** The -> operator is needed, so that we can write i->begin() to get
    the 1D iterators. */
  Tensor6View* operator->() { return &msv; }

  /** Dereferencing. */
  Tensor6View& operator*() { return msv; }

private:
  /** Current position. */
  Tensor6View msv;
  /** Stride. */
  Index mstride;
};

/** Const version of Iterator7D. */
class ConstIterator7D {
public:
  // Constructors:
  /** Default constructor. */
  ConstIterator7D() : msv(), mstride(0) { /* Nothing to do here. */ }

  /** Explicit constructor. */
  ConstIterator7D(const ConstTensor6View& x, Index stride)
    : msv(x), mstride(stride)
      { /* Nothing to do here. */ }

  // Operators:
  /** Prefix increment operator. */
  ConstIterator7D& operator++() { msv.mdata += mstride; return *this; }

  /** Not equal operator, needed for algorithms like copy. 
      FIXME: Is it really necessary to have such a complicated check
      here? It could be sufficient to just test
      msv.mdata!=other.msv.mdata. */
  bool operator!=(const ConstIterator7D& other) const
    { if ( msv.mdata +
           msv.mvr.mstart +
           msv.msr.mstart +
           msv.mbr.mstart +
           msv.mpr.mstart +
           msv.mrr.mstart +
           msv.mcr.mstart
           !=
           other.msv.mdata +
           other.msv.mvr.mstart +
           other.msv.msr.mstart +
           other.msv.mbr.mstart +
           other.msv.mpr.mstart +
           other.msv.mrr.mstart +
           other.msv.mcr.mstart )
        return true;
      else
        return false;
    }

  /** The -> operator is needed, so that we can write i->begin() to get
    the 1D iterators. */
  const ConstTensor6View* operator->() const { return &msv; }

  /** Dereferencing. */
  const ConstTensor6View& operator*() const { return msv; }

private:
  /** Current position. */
  ConstTensor6View msv;
  /** Stride. */
  Index mstride;
};


// Declare class Tensor7:
class Tensor7;


/** A constant view of a Tensor7.

This, together with the derived class Tensor7View, contains the
main implementation of a Tensor7. It defines the concepts of
Tensor7View. Plus additionally the recursive subrange operator,
which makes it possible to create a Tensor7View from a subrange of
a Tensor7View.

Dimensions are called: library, vitrine, shelf, book, page, row, column.
or short:              l,       v,       s,     b,    p,    r,   c

The class Tensor7 is just a special case of a Tensor7View
which also allocates storage. */
class ConstTensor7View {
public:
  // Member functions:
  Index nlibraries() const;
  Index nvitrines()  const;
  Index nshelves()   const;
  Index nbooks()     const;
  Index npages()     const;
  Index nrows()      const;
  Index ncols()      const;

  // Const index operators:

  // Result 7D (1 combination)
  // -------
  ConstTensor7View operator()( const Range& l,
                               const Range& v, const Range& s, const Range& b,
                               const Range& p, const Range& r, const Range& c) const;

  // Result 6D (7 combinations)
  // ------|
  ConstTensor6View operator()( const Range& l,
                               const Range& v, const Range& s, const Range& b,
                               const Range& p, const Range& r, Index        c) const;
  // -----|-
  ConstTensor6View operator()( const Range& l,
                               const Range& v, const Range& s, const Range& b,
                               const Range& p, Index        r, const Range& c) const;
  // ----|--
  ConstTensor6View operator()( const Range& l,
                               const Range& v, const Range& s, const Range& b,
                               Index        p, const Range& r, const Range& c) const;
  // ---|---
  ConstTensor6View operator()( const Range& l,
                               const Range& v, const Range& s, Index        b,
                               const Range& p, const Range& r, const Range& c) const;
  // --|----
  ConstTensor6View operator()( const Range& l,
                               const Range& v, Index        s, const Range& b,
                               const Range& p, const Range& r, const Range& c) const;
  // -|-----
  ConstTensor6View operator()( const Range& l,
                               Index        v, const Range& s, const Range& b,
                               const Range& p, const Range& r, const Range& c) const;
  // |------
  ConstTensor6View operator()( Index        l,
                               const Range& v, const Range& s, const Range& b,
                               const Range& p, const Range& r, const Range& c) const;

  // Result 5D (6+5+4+3+2+1 = 21 combinations)
  // -----||
  ConstTensor5View operator()( const Range& l,
                               const Range& v, const Range& s, const Range& b,
                               const Range& p, Index        r, Index        c) const;
  // ----|-|
  ConstTensor5View operator()( const Range& l,
                               const Range& v, const Range& s, const Range& b,
                               Index        p, const Range& r, Index        c) const;
  // ---|--|
  ConstTensor5View operator()( const Range& l,
                               const Range& v, const Range& s, Index        b,
                               const Range& p, const Range& r, Index        c) const;
  // --|---|
  ConstTensor5View operator()( const Range& l,
                               const Range& v, Index        s, const Range& b,
                               const Range& p, const Range& r, Index        c) const;
  // -|----|
  ConstTensor5View operator()( const Range& l,
                               Index        v, const Range& s, const Range& b,
                               const Range& p, const Range& r, Index        c) const;
  // |-----|
  ConstTensor5View operator()( Index l,
                               const Range& v, const Range& s, const Range& b,
                               const Range& p, const Range& r, Index        c) const;
  // ----||-
  ConstTensor5View operator()( const Range& l,
                               const Range& v, const Range& s, const Range& b,
                               Index        p, Index        r, const Range& c) const;
  // ---|-|-
  ConstTensor5View operator()( const Range& l,
                               const Range& v, const Range& s, Index        b,
                               const Range& p, Index        r, const Range& c) const;
  // --|--|-
  ConstTensor5View operator()( const Range& l,
                               const Range& v, Index        s, const Range& b,
                               const Range& p, Index        r, const Range& c) const;
  // -|---|-
  ConstTensor5View operator()( const Range& l,
                               Index        v, const Range& s, const Range& b,
                               const Range& p, Index        r, const Range& c) const;
  // |----|-
  ConstTensor5View operator()( Index l,
                               const Range& v, const Range& s, const Range& b,
                               const Range& p, Index        r, const Range& c) const;
  // ---||--
  ConstTensor5View operator()( const Range& l,
                               const Range& v, const Range& s, Index        b,
                               Index        p, const Range& r, const Range& c) const;
  // --|-|--
  ConstTensor5View operator()( const Range& l,
                               const Range& v, Index        s, const Range& b,
                               Index        p, const Range& r, const Range& c) const;
  // -|--|--
  ConstTensor5View operator()( const Range& l,
                               Index        v, const Range& s, const Range& b,
                               Index        p, const Range& r, const Range& c) const;
  // |---|--
  ConstTensor5View operator()( Index l,
                               const Range& v, const Range& s, const Range& b,
                               Index        p, const Range& r, const Range& c) const;
  // --||---
  ConstTensor5View operator()( const Range& l,
                               const Range& v, Index        s, Index        b,
                               const Range& p, const Range& r, const Range& c) const;
  // -|-|---
  ConstTensor5View operator()( const Range& l,
                               Index        v, const Range& s, Index        b,
                               const Range& p, const Range& r, const Range& c) const;
  // |--|---
  ConstTensor5View operator()( Index l,
                               const Range& v, const Range& s, Index        b,
                               const Range& p, const Range& r, const Range& c) const;
  // -||----
  ConstTensor5View operator()( const Range& l,
                               Index        v, Index        s, const Range& b,
                               const Range& p, const Range& r, const Range& c) const;
  // |-|----
  ConstTensor5View operator()( Index l,
                               const Range& v, Index        s, const Range& b,
                               const Range& p, const Range& r, const Range& c) const;
  // ||-----
  ConstTensor5View operator()( Index l,
                               Index        v, const Range& s, const Range& b,
                               const Range& p, const Range& r, const Range& c) const;

  // Result 4D (5+4+3+2+1 +4+3+2+1 +3+2+1 +2+1 +1 = 35 combinations)
  // ----|||
  ConstTensor4View operator()( const Range& l,
                               const Range& v, const Range& s, const Range& b,
                               Index        p, Index        r, Index        c) const;
  // ---|-||
  ConstTensor4View operator()( const Range& l,
                               const Range& v, const Range& s, Index        b,
                               const Range& p, Index        r, Index        c) const;
  // --|--||
  ConstTensor4View operator()( const Range& l,
                               const Range& v, Index        s, const Range& b,
                               const Range& p, Index        r, Index        c) const;
  // -|---||
  ConstTensor4View operator()( const Range& l,
                               Index        v, const Range& s, const Range& b,
                               const Range& p, Index        r, Index        c) const;
  // |----||
  ConstTensor4View operator()( Index        l,
                               const Range& v, const Range& s, const Range& b,
                               const Range& p, Index        r, Index        c) const;
  // ---||-|
  ConstTensor4View operator()( const Range& l,
                               const Range& v, const Range& s, Index        b,
                               Index        p, const Range& r, Index        c) const;
  // --|-|-|
  ConstTensor4View operator()( const Range& l,
                               const Range& v, Index        s, const Range& b,
                               Index        p, const Range& r, Index        c) const;
  // -|--|-|
  ConstTensor4View operator()( const Range& l,
                               Index        v, const Range& s, const Range& b,
                               Index        p, const Range& r, Index        c) const;
  // |---|-|
  ConstTensor4View operator()( Index        l,
                               const Range& v, const Range& s, const Range& b,
                               Index        p, const Range& r, Index        c) const;
  // --||--|
  ConstTensor4View operator()( const Range& l,
                               const Range& v, Index        s, Index        b,
                               const Range& p, const Range& r, Index        c) const;
  // -|-|--|
  ConstTensor4View operator()( const Range& l,
                               Index        v, const Range& s, Index        b,
                               const Range& p, const Range& r, Index        c) const;
  // |--|--|
  ConstTensor4View operator()( Index        l,
                               const Range& v, const Range& s, Index        b,
                               const Range& p, const Range& r, Index        c) const;
  // -||---|
  ConstTensor4View operator()( const Range& l,
                               Index        v, Index        s, const Range& b,
                               const Range& p, const Range& r, Index        c) const;
  // |-|---|
  ConstTensor4View operator()( Index        l,
                               const Range& v, Index        s, const Range& b,
                               const Range& p, const Range& r, Index        c) const;
  // ||----|
  ConstTensor4View operator()( Index        l,
                               Index        v, const Range& s, const Range& b,
                               const Range& p, const Range& r, Index        c) const;
  // ---|||-
  ConstTensor4View operator()( const Range& l,
                               const Range& v, const Range& s, Index        b,
                               Index        p, Index        r, const Range& c) const;
  // --|-||-
  ConstTensor4View operator()( const Range& l,
                               const Range& v, Index        s, const Range& b,
                               Index        p, Index        r, const Range& c) const;
  // -|--||-
  ConstTensor4View operator()( const Range& l,
                               Index        v, const Range& s, const Range& b,
                               Index        p, Index        r, const Range& c) const;
  // |---||-
  ConstTensor4View operator()( Index        l,
                               const Range& v, const Range& s, const Range& b,
                               Index        p, Index        r, const Range& c) const;
  // --||-|-
  ConstTensor4View operator()( const Range& l,
                               const Range& v, Index        s, Index        b,
                               const Range& p, Index        r, const Range& c) const;
  // -|-|-|-
  ConstTensor4View operator()( const Range& l,
                               Index        v, const Range& s, Index        b,
                               const Range& p, Index        r, const Range& c) const;
  // |--|-|-
  ConstTensor4View operator()( Index        l,
                               const Range& v, const Range& s, Index        b,
                               const Range& p, Index        r, const Range& c) const;
  // -||--|-
  ConstTensor4View operator()( const Range& l,
                               Index        v, Index        s, const Range& b,
                               const Range& p, Index        r, const Range& c) const;
  // |-|--|-
  ConstTensor4View operator()( Index        l,
                               const Range& v, Index        s, const Range& b,
                               const Range& p, Index        r, const Range& c) const;
  // ||---|-
  ConstTensor4View operator()( Index        l,
                               Index        v, const Range& s, const Range& b,
                               const Range& p, Index        r, const Range& c) const;
  // --|||--
  ConstTensor4View operator()( const Range& l,
                               const Range& v, Index        s, Index        b,
                               Index        p, const Range& r, const Range& c) const;
  // -|-||--
  ConstTensor4View operator()( const Range& l,
                               Index        v, const Range& s, Index        b,
                               Index        p, const Range& r, const Range& c) const;
  // |--||--
  ConstTensor4View operator()( Index        l,
                               const Range& v, const Range& s, Index        b,
                               Index        p, const Range& r, const Range& c) const;
  // -||-|--
  ConstTensor4View operator()( const Range& l,
                               Index        v, Index        s, const Range& b,
                               Index        p, const Range& r, const Range& c) const;
  // |-|-|--
  ConstTensor4View operator()( Index        l,
                               const Range& v, Index        s, const Range& b,
                               Index        p, const Range& r, const Range& c) const;
  // ||--|--
  ConstTensor4View operator()( Index        l,
                               Index        v, const Range& s, const Range& b,
                               Index        p, const Range& r, const Range& c) const;
  // -|||---
  ConstTensor4View operator()( const Range& l,
                               Index        v, Index        s, Index        b,
                               const Range& p, const Range& r, const Range& c) const;
  // |-||---
  ConstTensor4View operator()( Index        l,
                               const Range& v, Index        s, Index        b,
                               const Range& p, const Range& r, const Range& c) const;
  // ||-|---
  ConstTensor4View operator()( Index        l,
                               Index        v, const Range& s, Index        b,
                               const Range& p, const Range& r, const Range& c) const;
  // |||----
  ConstTensor4View operator()( Index        l,
                               Index        v, Index        s, const Range& b,
                               const Range& p, const Range& r, const Range& c) const;

  // Result 3D (5+4+3+2+1 +4+3+2+1 +3+2+1 +2+1 +1 = 35 combinations)
  // ||||---
  ConstTensor3View operator()( Index        l,
                               Index        v, Index        s, Index        b,
                               const Range& p, const Range& r, const Range& c) const;
  // |||-|--
  ConstTensor3View operator()( Index        l,
                               Index        v, Index        s, const Range& b,
                               Index        p, const Range& r, const Range& c) const;
  // ||-||--
  ConstTensor3View operator()( Index        l,
                               Index        v, const Range& s, Index        b,
                               Index        p, const Range& r, const Range& c) const;
  // |-|||--
  ConstTensor3View operator()( Index        l,
                               const Range& v, Index        s, Index        b,
                               Index        p, const Range& r, const Range& c) const;
  // -||||--
  ConstTensor3View operator()( const Range& l,
                               Index        v, Index        s, Index        b,
                               Index        p, const Range& r, const Range& c) const;
  // |||--|-
  ConstTensor3View operator()( Index        l,
                               Index        v, Index        s, const Range& b,
                               const Range& p, Index        r, const Range& c) const;
  // ||-|-|-
  ConstTensor3View operator()( Index        l,
                               Index        v, const Range& s, Index        b,
                               const Range& p, Index        r, const Range& c) const;
  // |-||-|-
  ConstTensor3View operator()( Index        l,
                               const Range& v, Index        s, Index        b,
                               const Range& p, Index        r, const Range& c) const;
  // -|||-|-
  ConstTensor3View operator()( const Range& l,
                               Index        v, Index        s, Index        b,
                               const Range& p, Index        r, const Range& c) const;
  // ||--||-
  ConstTensor3View operator()( Index        l,
                               Index        v, const Range& s, const Range& b,
                               Index        p, Index        r, const Range& c) const;
  // |-|-||-
  ConstTensor3View operator()( Index        l,
                               const Range& v, Index        s, const Range& b,
                               Index        p, Index        r, const Range& c) const;
  // -||-||-
  ConstTensor3View operator()( const Range& l,
                               Index        v, Index        s, const Range& b,
                               Index        p, Index        r, const Range& c) const;
  // |--|||-
  ConstTensor3View operator()( Index        l,
                               const Range& v, const Range& s, Index        b,
                               Index        p, Index        r, const Range& c) const;
  // -|-|||-
  ConstTensor3View operator()( const Range& l,
                               Index        v, const Range& s, Index        b,
                               Index        p, Index        r, const Range& c) const;
  // --||||-
  ConstTensor3View operator()( const Range& l,
                               const Range& v, Index        s, Index        b,
                               Index        p, Index        r, const Range& c) const;
  // |||---|
  ConstTensor3View operator()( Index        l,
                               Index        v, Index        s, const Range& b,
                               const Range& p, const Range& r, Index        c) const;
  // ||-|--|
  ConstTensor3View operator()( Index        l,
                               Index        v, const Range& s, Index        b,
                               const Range& p, const Range& r, Index        c) const;
  // |-||--|
  ConstTensor3View operator()( Index        l,
                               const Range& v, Index        s, Index        b,
                               const Range& p, const Range& r, Index        c) const;
  // -|||--|
  ConstTensor3View operator()( const Range& l,
                               Index        v, Index        s, Index        b,
                               const Range& p, const Range& r, Index        c) const;
  // ||--|-|
  ConstTensor3View operator()( Index        l,
                               Index        v, const Range& s, const Range& b,
                               Index        p, const Range& r, Index        c) const;
  // |-|-|-|
  ConstTensor3View operator()( Index        l,
                               const Range& v, Index        s, const Range& b,
                               Index        p, const Range& r, Index        c) const;
  // -||-|-|
  ConstTensor3View operator()( const Range& l,
                               Index        v, Index        s, const Range& b,
                               Index        p, const Range& r, Index        c) const;
  // |--||-|
  ConstTensor3View operator()( Index        l,
                               const Range& v, const Range& s, Index        b,
                               Index        p, const Range& r, Index        c) const;
  // -|-||-|
  ConstTensor3View operator()( const Range& l,
                               Index        v, const Range& s, Index        b,
                               Index        p, const Range& r, Index        c) const;
  // --|||-|
  ConstTensor3View operator()( const Range& l,
                               const Range& v, Index        s, Index        b,
                               Index        p, const Range& r, Index        c) const;
  // ||---||
  ConstTensor3View operator()( Index        l,
                               Index        v, const Range& s, const Range& b,
                               const Range& p, Index        r, Index        c) const;
  // |-|--||
  ConstTensor3View operator()( Index        l,
                               const Range& v, Index        s, const Range& b,
                               const Range& p, Index        r, Index        c) const;
  // -||--||
  ConstTensor3View operator()( const Range& l,
                               Index        v, Index        s, const Range& b,
                               const Range& p, Index        r, Index        c) const;
  // |--|-||
  ConstTensor3View operator()( Index        l,
                               const Range& v, const Range& s, Index        b,
                               const Range& p, Index        r, Index        c) const;
  // -|-|-||
  ConstTensor3View operator()( const Range& l,
                               Index        v, const Range& s, Index        b,
                               const Range& p, Index        r, Index        c) const;
  // --||-||
  ConstTensor3View operator()( const Range& l,
                               const Range& v, Index        s, Index        b,
                               const Range& p, Index        r, Index        c) const;
  // |---|||
  ConstTensor3View operator()( Index        l,
                               const Range& v, const Range& s, const Range& b,
                               Index        p, Index        r, Index        c) const;
  // -|--|||
  ConstTensor3View operator()( const Range& l,
                               Index        v, const Range& s, const Range& b,
                               Index        p, Index        r, Index        c) const;
  // --|-|||
  ConstTensor3View operator()( const Range& l,
                               const Range& v, Index        s, const Range& b,
                               Index        p, Index        r, Index        c) const;
  // ---||||
  ConstTensor3View operator()( const Range& l,
                               const Range& v, const Range& s, Index        b,
                               Index        p, Index        r, Index        c) const;

  // Result 2D (6+5+4+3+2+1 = 21 combinations)
  // |||||--
  ConstMatrixView  operator()( Index        l,
                               Index        v, Index        s, Index        b,
                               Index        p, const Range& r, const Range& c) const;
  // ||||-|-
  ConstMatrixView  operator()( Index        l,
                               Index        v, Index        s, Index        b,
                               const Range& p, Index        r, const Range& c) const;
  // |||-||-
  ConstMatrixView  operator()( Index        l,
                               Index        v, Index        s, const Range& b,
                               Index        p, Index        r, const Range& c) const;
  // ||-|||-
  ConstMatrixView  operator()( Index        l,
                               Index        v, const Range& s, Index        b,
                               Index        p, Index        r, const Range& c) const;
  // |-||||-
  ConstMatrixView  operator()( Index        l,
                               const Range& v, Index        s, Index        b,
                               Index        p, Index        r, const Range& c) const;
  // -|||||-
  ConstMatrixView  operator()( const Range& l,
                               Index        v, Index        s, Index        b,
                               Index        p, Index        r, const Range& c) const;
  // ||||--|
  ConstMatrixView  operator()( Index        l,
                               Index        v, Index        s, Index        b,
                               const Range& p, const Range& r, Index        c) const;
  // |||-|-|
  ConstMatrixView  operator()( Index        l,
                               Index        v, Index        s, const Range& b,
                               Index        p, const Range& r, Index        c) const;
  // ||-||-|
  ConstMatrixView  operator()( Index        l,
                               Index        v, const Range& s, Index        b,
                               Index        p, const Range& r, Index        c) const;
  // |-|||-|
  ConstMatrixView  operator()( Index        l,
                               const Range& v, Index        s, Index        b,
                               Index        p, const Range& r, Index        c) const;
  // -||||-|
  ConstMatrixView  operator()( const Range& l,
                               Index        v, Index        s, Index        b,
                               Index        p, const Range& r, Index        c) const;
  // |||--||
  ConstMatrixView  operator()( Index        l,
                               Index        v, Index        s, const Range& b,
                               const Range& p, Index        r, Index        c) const;
  // ||-|-||
  ConstMatrixView  operator()( Index        l,
                               Index        v, const Range& s, Index        b,
                               const Range& p, Index        r, Index        c) const;
  // |-||-||
  ConstMatrixView  operator()( Index        l,
                               const Range& v, Index        s, Index        b,
                               const Range& p, Index        r, Index        c) const;
  // -|||-||
  ConstMatrixView  operator()( const Range& l,
                               Index        v, Index        s, Index        b,
                               const Range& p, Index        r, Index        c) const;
  // ||--|||
  ConstMatrixView  operator()( Index        l,
                               Index        v, const Range& s, const Range& b,
                               Index        p, Index        r, Index        c) const;
  // |-|-|||
  ConstMatrixView  operator()( Index        l,
                               const Range& v, Index        s, const Range& b,
                               Index        p, Index        r, Index        c) const;
  // -||-|||
  ConstMatrixView  operator()( const Range& l,
                               Index        v, Index        s, const Range& b,
                               Index        p, Index        r, Index        c) const;
  // |--||||
  ConstMatrixView  operator()( Index        l,
                               const Range& v, const Range& s, Index        b,
                               Index        p, Index        r, Index        c) const;
  // -|-||||
  ConstMatrixView  operator()( const Range& l,
                               Index        v, const Range& s, Index        b,
                               Index        p, Index        r, Index        c) const;
  // --|||||
  ConstMatrixView  operator()( const Range& l,
                               const Range& v, Index        s, Index        b,
                               Index        p, Index        r, Index        c) const;

  // Result 1D (7 combinations)
  // ||||||-
  ConstVectorView  operator()( Index        l,
                               Index        v, Index        s, Index        b,
                               Index        p, Index        r, const Range& c) const;
  // |||||-|
  ConstVectorView  operator()( Index        l,
                               Index        v, Index        s, Index        b,
                               Index        p, const Range& r, Index        c) const;
  // ||||-||
  ConstVectorView  operator()( Index        l,
                               Index        v, Index        s, Index        b,
                               const Range& p, Index        r, Index        c) const;
  // |||-|||
  ConstVectorView  operator()( Index        l,
                               Index        v, Index        s, const Range& b,
                               Index        p, Index        r, Index        c) const;
  // ||-||||
  ConstVectorView  operator()( Index        l,
                               Index        v, const Range& s, Index        b,
                               Index        p, Index        r, Index        c) const;
  // |-|||||
  ConstVectorView  operator()( Index        l,
                               const Range& v, Index        s, Index        b,
                               Index        p, Index        r, Index        c) const;
  // -||||||
  ConstVectorView  operator()( const Range& l,
                               Index        v, Index        s, Index        b,
                               Index        p, Index        r, Index        c) const;

  // Result scalar (1 combination)
  // |||||||
  Numeric operator() ( Index        l,
                       Index        v, Index        s, Index        b,
                       Index        p, Index        r, Index        c) const
      { CHECK(l);
        CHECK(v);
        CHECK(s);
        CHECK(b);
        CHECK(p);
        CHECK(r);
        CHECK(c);
        return get(l, v, s, b, p, r, c);
      }

  /** Get element implementation without assertions. */
  Numeric get( Index        l,
               Index        v, Index        s, Index        b,
               Index        p, Index        r, Index        c) const
      {
        return                *(mdata + OFFSET(l) +
                                OFFSET(v) + OFFSET(s) + OFFSET(b) +
                                OFFSET(p) + OFFSET(r) + OFFSET(c)    );
      }


  // Functions returning iterators:
  ConstIterator7D begin() const;
  ConstIterator7D end() const;
  
  //! Destructor.
  virtual ~ConstTensor7View() {}

  // Friends:
  friend class Tensor7View;

  // Special constructor to make a Tensor7 view of a Tensor6.
  ConstTensor7View(const ConstTensor6View& a);

protected:
  // Constructors:
  ConstTensor7View();
  ConstTensor7View(Numeric *data,
                   const Range& l,
                   const Range& v, const Range& s, const Range& b,
                   const Range& p, const Range& r, const Range& c);
  ConstTensor7View(Numeric *data,
                   const Range& pl,
                   const Range& pv, const Range& ps, const Range& pb,
                   const Range& pp, const Range& pr, const Range& pc,
                   const Range& nl,
                   const Range& nv, const Range& ns, const Range& nb,
                   const Range& np, const Range& nr, const Range& nc);

  // Data members:
  // -------------
  /** The library range of mdata that is actually used. */
  Range mlr;
  /** The vitrine range of mdata that is actually used. */
  Range mvr;
  /** The shelf range of mdata that is actually used. */
  Range msr;
  /** The book range of mdata that is actually used. */
  Range mbr;
  /** The page range of mdata that is actually used. */
  Range mpr;
  /** The row range of mdata that is actually used. */
  Range mrr;
  /** The column range of mdata that is actually used. */
  Range mcr;
  /** Pointer to the plain C array that holds the data */
  Numeric *mdata;
};

/** The Tensor7View class

This contains the main implementation of a Tensor7. It defines
the concepts of Tensor7View. Plus additionally the recursive
subrange operator, which makes it possible to create a Tensor7View
from a subrange of a Tensor7View. 

The class Tensor7 is just a special case of a Tensor7View
which also allocates storage. */
class Tensor7View : public ConstTensor7View {
public:

  // Const index operators:

  // Result 7D (1 combination)
  // -------
  ConstTensor7View operator()( const Range& l,
                               const Range& v, const Range& s, const Range& b,
                               const Range& p, const Range& r, const Range& c) const;

  // Result 6D (7 combinations)
  // ------|
  ConstTensor6View operator()( const Range& l,
                               const Range& v, const Range& s, const Range& b,
                               const Range& p, const Range& r, Index        c) const;
  // -----|-
  ConstTensor6View operator()( const Range& l,
                               const Range& v, const Range& s, const Range& b,
                               const Range& p, Index        r, const Range& c) const;
  // ----|--
  ConstTensor6View operator()( const Range& l,
                               const Range& v, const Range& s, const Range& b,
                               Index        p, const Range& r, const Range& c) const;
  // ---|---
  ConstTensor6View operator()( const Range& l,
                               const Range& v, const Range& s, Index        b,
                               const Range& p, const Range& r, const Range& c) const;
  // --|----
  ConstTensor6View operator()( const Range& l,
                               const Range& v, Index        s, const Range& b,
                               const Range& p, const Range& r, const Range& c) const;
  // -|-----
  ConstTensor6View operator()( const Range& l,
                               Index        v, const Range& s, const Range& b,
                               const Range& p, const Range& r, const Range& c) const;
  // |------
  ConstTensor6View operator()( Index        l,
                               const Range& v, const Range& s, const Range& b,
                               const Range& p, const Range& r, const Range& c) const;

  // Result 5D (6+5+4+3+2+1 = 21 combinations)
  // -----||
  ConstTensor5View operator()( const Range& l,
                               const Range& v, const Range& s, const Range& b,
                               const Range& p, Index        r, Index        c) const;
  // ----|-|
  ConstTensor5View operator()( const Range& l,
                               const Range& v, const Range& s, const Range& b,
                               Index        p, const Range& r, Index        c) const;
  // ---|--|
  ConstTensor5View operator()( const Range& l,
                               const Range& v, const Range& s, Index        b,
                               const Range& p, const Range& r, Index        c) const;
  // --|---|
  ConstTensor5View operator()( const Range& l,
                               const Range& v, Index        s, const Range& b,
                               const Range& p, const Range& r, Index        c) const;
  // -|----|
  ConstTensor5View operator()( const Range& l,
                               Index        v, const Range& s, const Range& b,
                               const Range& p, const Range& r, Index        c) const;
  // |-----|
  ConstTensor5View operator()( Index l,
                               const Range& v, const Range& s, const Range& b,
                               const Range& p, const Range& r, Index        c) const;
  // ----||-
  ConstTensor5View operator()( const Range& l,
                               const Range& v, const Range& s, const Range& b,
                               Index        p, Index        r, const Range& c) const;
  // ---|-|-
  ConstTensor5View operator()( const Range& l,
                               const Range& v, const Range& s, Index        b,
                               const Range& p, Index        r, const Range& c) const;
  // --|--|-
  ConstTensor5View operator()( const Range& l,
                               const Range& v, Index        s, const Range& b,
                               const Range& p, Index        r, const Range& c) const;
  // -|---|-
  ConstTensor5View operator()( const Range& l,
                               Index        v, const Range& s, const Range& b,
                               const Range& p, Index        r, const Range& c) const;
  // |----|-
  ConstTensor5View operator()( Index l,
                               const Range& v, const Range& s, const Range& b,
                               const Range& p, Index        r, const Range& c) const;
  // ---||--
  ConstTensor5View operator()( const Range& l,
                               const Range& v, const Range& s, Index        b,
                               Index        p, const Range& r, const Range& c) const;
  // --|-|--
  ConstTensor5View operator()( const Range& l,
                               const Range& v, Index        s, const Range& b,
                               Index        p, const Range& r, const Range& c) const;
  // -|--|--
  ConstTensor5View operator()( const Range& l,
                               Index        v, const Range& s, const Range& b,
                               Index        p, const Range& r, const Range& c) const;
  // |---|--
  ConstTensor5View operator()( Index l,
                               const Range& v, const Range& s, const Range& b,
                               Index        p, const Range& r, const Range& c) const;
  // --||---
  ConstTensor5View operator()( const Range& l,
                               const Range& v, Index        s, Index        b,
                               const Range& p, const Range& r, const Range& c) const;
  // -|-|---
  ConstTensor5View operator()( const Range& l,
                               Index        v, const Range& s, Index        b,
                               const Range& p, const Range& r, const Range& c) const;
  // |--|---
  ConstTensor5View operator()( Index l,
                               const Range& v, const Range& s, Index        b,
                               const Range& p, const Range& r, const Range& c) const;
  // -||----
  ConstTensor5View operator()( const Range& l,
                               Index        v, Index        s, const Range& b,
                               const Range& p, const Range& r, const Range& c) const;
  // |-|----
  ConstTensor5View operator()( Index l,
                               const Range& v, Index        s, const Range& b,
                               const Range& p, const Range& r, const Range& c) const;
  // ||-----
  ConstTensor5View operator()( Index l,
                               Index        v, const Range& s, const Range& b,
                               const Range& p, const Range& r, const Range& c) const;

  // Result 4D (5+4+3+2+1 +4+3+2+1 +3+2+1 +2+1 +1 = 35 combinations)
  // ----|||
  ConstTensor4View operator()( const Range& l,
                               const Range& v, const Range& s, const Range& b,
                               Index        p, Index        r, Index        c) const;
  // ---|-||
  ConstTensor4View operator()( const Range& l,
                               const Range& v, const Range& s, Index        b,
                               const Range& p, Index        r, Index        c) const;
  // --|--||
  ConstTensor4View operator()( const Range& l,
                               const Range& v, Index        s, const Range& b,
                               const Range& p, Index        r, Index        c) const;
  // -|---||
  ConstTensor4View operator()( const Range& l,
                               Index        v, const Range& s, const Range& b,
                               const Range& p, Index        r, Index        c) const;
  // |----||
  ConstTensor4View operator()( Index        l,
                               const Range& v, const Range& s, const Range& b,
                               const Range& p, Index        r, Index        c) const;
  // ---||-|
  ConstTensor4View operator()( const Range& l,
                               const Range& v, const Range& s, Index        b,
                               Index        p, const Range& r, Index        c) const;
  // --|-|-|
  ConstTensor4View operator()( const Range& l,
                               const Range& v, Index        s, const Range& b,
                               Index        p, const Range& r, Index        c) const;
  // -|--|-|
  ConstTensor4View operator()( const Range& l,
                               Index        v, const Range& s, const Range& b,
                               Index        p, const Range& r, Index        c) const;
  // |---|-|
  ConstTensor4View operator()( Index        l,
                               const Range& v, const Range& s, const Range& b,
                               Index        p, const Range& r, Index        c) const;
  // --||--|
  ConstTensor4View operator()( const Range& l,
                               const Range& v, Index        s, Index        b,
                               const Range& p, const Range& r, Index        c) const;
  // -|-|--|
  ConstTensor4View operator()( const Range& l,
                               Index        v, const Range& s, Index        b,
                               const Range& p, const Range& r, Index        c) const;
  // |--|--|
  ConstTensor4View operator()( Index        l,
                               const Range& v, const Range& s, Index        b,
                               const Range& p, const Range& r, Index        c) const;
  // -||---|
  ConstTensor4View operator()( const Range& l,
                               Index        v, Index        s, const Range& b,
                               const Range& p, const Range& r, Index        c) const;
  // |-|---|
  ConstTensor4View operator()( Index        l,
                               const Range& v, Index        s, const Range& b,
                               const Range& p, const Range& r, Index        c) const;
  // ||----|
  ConstTensor4View operator()( Index        l,
                               Index        v, const Range& s, const Range& b,
                               const Range& p, const Range& r, Index        c) const;
  // ---|||-
  ConstTensor4View operator()( const Range& l,
                               const Range& v, const Range& s, Index        b,
                               Index        p, Index        r, const Range& c) const;
  // --|-||-
  ConstTensor4View operator()( const Range& l,
                               const Range& v, Index        s, const Range& b,
                               Index        p, Index        r, const Range& c) const;
  // -|--||-
  ConstTensor4View operator()( const Range& l,
                               Index        v, const Range& s, const Range& b,
                               Index        p, Index        r, const Range& c) const;
  // |---||-
  ConstTensor4View operator()( Index        l,
                               const Range& v, const Range& s, const Range& b,
                               Index        p, Index        r, const Range& c) const;
  // --||-|-
  ConstTensor4View operator()( const Range& l,
                               const Range& v, Index        s, Index        b,
                               const Range& p, Index        r, const Range& c) const;
  // -|-|-|-
  ConstTensor4View operator()( const Range& l,
                               Index        v, const Range& s, Index        b,
                               const Range& p, Index        r, const Range& c) const;
  // |--|-|-
  ConstTensor4View operator()( Index        l,
                               const Range& v, const Range& s, Index        b,
                               const Range& p, Index        r, const Range& c) const;
  // -||--|-
  ConstTensor4View operator()( const Range& l,
                               Index        v, Index        s, const Range& b,
                               const Range& p, Index        r, const Range& c) const;
  // |-|--|-
  ConstTensor4View operator()( Index        l,
                               const Range& v, Index        s, const Range& b,
                               const Range& p, Index        r, const Range& c) const;
  // ||---|-
  ConstTensor4View operator()( Index        l,
                               Index        v, const Range& s, const Range& b,
                               const Range& p, Index        r, const Range& c) const;
  // --|||--
  ConstTensor4View operator()( const Range& l,
                               const Range& v, Index        s, Index        b,
                               Index        p, const Range& r, const Range& c) const;
  // -|-||--
  ConstTensor4View operator()( const Range& l,
                               Index        v, const Range& s, Index        b,
                               Index        p, const Range& r, const Range& c) const;
  // |--||--
  ConstTensor4View operator()( Index        l,
                               const Range& v, const Range& s, Index        b,
                               Index        p, const Range& r, const Range& c) const;
  // -||-|--
  ConstTensor4View operator()( const Range& l,
                               Index        v, Index        s, const Range& b,
                               Index        p, const Range& r, const Range& c) const;
  // |-|-|--
  ConstTensor4View operator()( Index        l,
                               const Range& v, Index        s, const Range& b,
                               Index        p, const Range& r, const Range& c) const;
  // ||--|--
  ConstTensor4View operator()( Index        l,
                               Index        v, const Range& s, const Range& b,
                               Index        p, const Range& r, const Range& c) const;
  // -|||---
  ConstTensor4View operator()( const Range& l,
                               Index        v, Index        s, Index        b,
                               const Range& p, const Range& r, const Range& c) const;
  // |-||---
  ConstTensor4View operator()( Index        l,
                               const Range& v, Index        s, Index        b,
                               const Range& p, const Range& r, const Range& c) const;
  // ||-|---
  ConstTensor4View operator()( Index        l,
                               Index        v, const Range& s, Index        b,
                               const Range& p, const Range& r, const Range& c) const;
  // |||----
  ConstTensor4View operator()( Index        l,
                               Index        v, Index        s, const Range& b,
                               const Range& p, const Range& r, const Range& c) const;

  // Result 3D (5+4+3+2+1 +4+3+2+1 +3+2+1 +2+1 +1 = 35 combinations)
  // ||||---
  ConstTensor3View operator()( Index        l,
                               Index        v, Index        s, Index        b,
                               const Range& p, const Range& r, const Range& c) const;
  // |||-|--
  ConstTensor3View operator()( Index        l,
                               Index        v, Index        s, const Range& b,
                               Index        p, const Range& r, const Range& c) const;
  // ||-||--
  ConstTensor3View operator()( Index        l,
                               Index        v, const Range& s, Index        b,
                               Index        p, const Range& r, const Range& c) const;
  // |-|||--
  ConstTensor3View operator()( Index        l,
                               const Range& v, Index        s, Index        b,
                               Index        p, const Range& r, const Range& c) const;
  // -||||--
  ConstTensor3View operator()( const Range& l,
                               Index        v, Index        s, Index        b,
                               Index        p, const Range& r, const Range& c) const;
  // |||--|-
  ConstTensor3View operator()( Index        l,
                               Index        v, Index        s, const Range& b,
                               const Range& p, Index        r, const Range& c) const;
  // ||-|-|-
  ConstTensor3View operator()( Index        l,
                               Index        v, const Range& s, Index        b,
                               const Range& p, Index        r, const Range& c) const;
  // |-||-|-
  ConstTensor3View operator()( Index        l,
                               const Range& v, Index        s, Index        b,
                               const Range& p, Index        r, const Range& c) const;
  // -|||-|-
  ConstTensor3View operator()( const Range& l,
                               Index        v, Index        s, Index        b,
                               const Range& p, Index        r, const Range& c) const;
  // ||--||-
  ConstTensor3View operator()( Index        l,
                               Index        v, const Range& s, const Range& b,
                               Index        p, Index        r, const Range& c) const;
  // |-|-||-
  ConstTensor3View operator()( Index        l,
                               const Range& v, Index        s, const Range& b,
                               Index        p, Index        r, const Range& c) const;
  // -||-||-
  ConstTensor3View operator()( const Range& l,
                               Index        v, Index        s, const Range& b,
                               Index        p, Index        r, const Range& c) const;
  // |--|||-
  ConstTensor3View operator()( Index        l,
                               const Range& v, const Range& s, Index        b,
                               Index        p, Index        r, const Range& c) const;
  // -|-|||-
  ConstTensor3View operator()( const Range& l,
                               Index        v, const Range& s, Index        b,
                               Index        p, Index        r, const Range& c) const;
  // --||||-
  ConstTensor3View operator()( const Range& l,
                               const Range& v, Index        s, Index        b,
                               Index        p, Index        r, const Range& c) const;
  // |||---|
  ConstTensor3View operator()( Index        l,
                               Index        v, Index        s, const Range& b,
                               const Range& p, const Range& r, Index        c) const;
  // ||-|--|
  ConstTensor3View operator()( Index        l,
                               Index        v, const Range& s, Index        b,
                               const Range& p, const Range& r, Index        c) const;
  // |-||--|
  ConstTensor3View operator()( Index        l,
                               const Range& v, Index        s, Index        b,
                               const Range& p, const Range& r, Index        c) const;
  // -|||--|
  ConstTensor3View operator()( const Range& l,
                               Index        v, Index        s, Index        b,
                               const Range& p, const Range& r, Index        c) const;
  // ||--|-|
  ConstTensor3View operator()( Index        l,
                               Index        v, const Range& s, const Range& b,
                               Index        p, const Range& r, Index        c) const;
  // |-|-|-|
  ConstTensor3View operator()( Index        l,
                               const Range& v, Index        s, const Range& b,
                               Index        p, const Range& r, Index        c) const;
  // -||-|-|
  ConstTensor3View operator()( const Range& l,
                               Index        v, Index        s, const Range& b,
                               Index        p, const Range& r, Index        c) const;
  // |--||-|
  ConstTensor3View operator()( Index        l,
                               const Range& v, const Range& s, Index        b,
                               Index        p, const Range& r, Index        c) const;
  // -|-||-|
  ConstTensor3View operator()( const Range& l,
                               Index        v, const Range& s, Index        b,
                               Index        p, const Range& r, Index        c) const;
  // --|||-|
  ConstTensor3View operator()( const Range& l,
                               const Range& v, Index        s, Index        b,
                               Index        p, const Range& r, Index        c) const;
  // ||---||
  ConstTensor3View operator()( Index        l,
                               Index        v, const Range& s, const Range& b,
                               const Range& p, Index        r, Index        c) const;
  // |-|--||
  ConstTensor3View operator()( Index        l,
                               const Range& v, Index        s, const Range& b,
                               const Range& p, Index        r, Index        c) const;
  // -||--||
  ConstTensor3View operator()( const Range& l,
                               Index        v, Index        s, const Range& b,
                               const Range& p, Index        r, Index        c) const;
  // |--|-||
  ConstTensor3View operator()( Index        l,
                               const Range& v, const Range& s, Index        b,
                               const Range& p, Index        r, Index        c) const;
  // -|-|-||
  ConstTensor3View operator()( const Range& l,
                               Index        v, const Range& s, Index        b,
                               const Range& p, Index        r, Index        c) const;
  // --||-||
  ConstTensor3View operator()( const Range& l,
                               const Range& v, Index        s, Index        b,
                               const Range& p, Index        r, Index        c) const;
  // |---|||
  ConstTensor3View operator()( Index        l,
                               const Range& v, const Range& s, const Range& b,
                               Index        p, Index        r, Index        c) const;
  // -|--|||
  ConstTensor3View operator()( const Range& l,
                               Index        v, const Range& s, const Range& b,
                               Index        p, Index        r, Index        c) const;
  // --|-|||
  ConstTensor3View operator()( const Range& l,
                               const Range& v, Index        s, const Range& b,
                               Index        p, Index        r, Index        c) const;
  // ---||||
  ConstTensor3View operator()( const Range& l,
                               const Range& v, const Range& s, Index        b,
                               Index        p, Index        r, Index        c) const;

  // Result 2D (6+5+4+3+2+1 = 21 combinations)
  // |||||--
  ConstMatrixView  operator()( Index        l,
                               Index        v, Index        s, Index        b,
                               Index        p, const Range& r, const Range& c) const;
  // ||||-|-
  ConstMatrixView  operator()( Index        l,
                               Index        v, Index        s, Index        b,
                               const Range& p, Index        r, const Range& c) const;
  // |||-||-
  ConstMatrixView  operator()( Index        l,
                               Index        v, Index        s, const Range& b,
                               Index        p, Index        r, const Range& c) const;
  // ||-|||-
  ConstMatrixView  operator()( Index        l,
                               Index        v, const Range& s, Index        b,
                               Index        p, Index        r, const Range& c) const;
  // |-||||-
  ConstMatrixView  operator()( Index        l,
                               const Range& v, Index        s, Index        b,
                               Index        p, Index        r, const Range& c) const;
  // -|||||-
  ConstMatrixView  operator()( const Range& l,
                               Index        v, Index        s, Index        b,
                               Index        p, Index        r, const Range& c) const;
  // ||||--|
  ConstMatrixView  operator()( Index        l,
                               Index        v, Index        s, Index        b,
                               const Range& p, const Range& r, Index        c) const;
  // |||-|-|
  ConstMatrixView  operator()( Index        l,
                               Index        v, Index        s, const Range& b,
                               Index        p, const Range& r, Index        c) const;
  // ||-||-|
  ConstMatrixView  operator()( Index        l,
                               Index        v, const Range& s, Index        b,
                               Index        p, const Range& r, Index        c) const;
  // |-|||-|
  ConstMatrixView  operator()( Index        l,
                               const Range& v, Index        s, Index        b,
                               Index        p, const Range& r, Index        c) const;
  // -||||-|
  ConstMatrixView  operator()( const Range& l,
                               Index        v, Index        s, Index        b,
                               Index        p, const Range& r, Index        c) const;
  // |||--||
  ConstMatrixView  operator()( Index        l,
                               Index        v, Index        s, const Range& b,
                               const Range& p, Index        r, Index        c) const;
  // ||-|-||
  ConstMatrixView  operator()( Index        l,
                               Index        v, const Range& s, Index        b,
                               const Range& p, Index        r, Index        c) const;
  // |-||-||
  ConstMatrixView  operator()( Index        l,
                               const Range& v, Index        s, Index        b,
                               const Range& p, Index        r, Index        c) const;
  // -|||-||
  ConstMatrixView  operator()( const Range& l,
                               Index        v, Index        s, Index        b,
                               const Range& p, Index        r, Index        c) const;
  // ||--|||
  ConstMatrixView  operator()( Index        l,
                               Index        v, const Range& s, const Range& b,
                               Index        p, Index        r, Index        c) const;
  // |-|-|||
  ConstMatrixView  operator()( Index        l,
                               const Range& v, Index        s, const Range& b,
                               Index        p, Index        r, Index        c) const;
  // -||-|||
  ConstMatrixView  operator()( const Range& l,
                               Index        v, Index        s, const Range& b,
                               Index        p, Index        r, Index        c) const;
  // |--||||
  ConstMatrixView  operator()( Index        l,
                               const Range& v, const Range& s, Index        b,
                               Index        p, Index        r, Index        c) const;
  // -|-||||
  ConstMatrixView  operator()( const Range& l,
                               Index        v, const Range& s, Index        b,
                               Index        p, Index        r, Index        c) const;
  // --|||||
  ConstMatrixView  operator()( const Range& l,
                               const Range& v, Index        s, Index        b,
                               Index        p, Index        r, Index        c) const;

  // Result 1D (7 combinations)
  // ||||||-
  ConstVectorView  operator()( Index        l,
                               Index        v, Index        s, Index        b,
                               Index        p, Index        r, const Range& c) const;
  // |||||-|
  ConstVectorView  operator()( Index        l,
                               Index        v, Index        s, Index        b,
                               Index        p, const Range& r, Index        c) const;
  // ||||-||
  ConstVectorView  operator()( Index        l,
                               Index        v, Index        s, Index        b,
                               const Range& p, Index        r, Index        c) const;
  // |||-|||
  ConstVectorView  operator()( Index        l,
                               Index        v, Index        s, const Range& b,
                               Index        p, Index        r, Index        c) const;
  // ||-||||
  ConstVectorView  operator()( Index        l,
                               Index        v, const Range& s, Index        b,
                               Index        p, Index        r, Index        c) const;
  // |-|||||
  ConstVectorView  operator()( Index        l,
                               const Range& v, Index        s, Index        b,
                               Index        p, Index        r, Index        c) const;
  // -||||||
  ConstVectorView  operator()( const Range& l,
                               Index        v, Index        s, Index        b,
                               Index        p, Index        r, Index        c) const;

  // Result scalar (1 combination)
  // |||||||
  Numeric operator() ( Index        l,
                       Index        v, Index        s, Index        b,
                       Index        p, Index        r, Index        c) const
      { return ConstTensor7View::operator()(l,v,s,b,p,r,c); }

  /** Get element implementation without assertions. */
  Numeric get( Index        l,
                       Index        v, Index        s, Index        b,
                       Index        p, Index        r, Index        c) const
      { return ConstTensor7View::get(l,v,s,b,p,r,c); }


  // Non-const index operators:

  // Result 7D (1 combination)
  // -------
  Tensor7View operator()( const Range& l,
                          const Range& v, const Range& s, const Range& b,
                          const Range& p, const Range& r, const Range& c);

  // Result 6D (7 combinations)
  // ------|
  Tensor6View operator()( const Range& l,
                          const Range& v, const Range& s, const Range& b,
                          const Range& p, const Range& r, Index        c);
  // -----|-
  Tensor6View operator()( const Range& l,
                          const Range& v, const Range& s, const Range& b,
                          const Range& p, Index        r, const Range& c);
  // ----|--
  Tensor6View operator()( const Range& l,
                          const Range& v, const Range& s, const Range& b,
                          Index        p, const Range& r, const Range& c);
  // ---|---
  Tensor6View operator()( const Range& l,
                          const Range& v, const Range& s, Index        b,
                          const Range& p, const Range& r, const Range& c);
  // --|----
  Tensor6View operator()( const Range& l,
                          const Range& v, Index        s, const Range& b,
                          const Range& p, const Range& r, const Range& c);
  // -|-----
  Tensor6View operator()( const Range& l,
                          Index        v, const Range& s, const Range& b,
                          const Range& p, const Range& r, const Range& c);
  // |------
  Tensor6View operator()( Index        l,
                          const Range& v, const Range& s, const Range& b,
                          const Range& p, const Range& r, const Range& c);

  // Result 5D (6+5+4+3+2+1 = 21 combinations)
  // -----||
  Tensor5View operator()( const Range& l,
                          const Range& v, const Range& s, const Range& b,
                          const Range& p, Index        r, Index        c);
  // ----|-|
  Tensor5View operator()( const Range& l,
                          const Range& v, const Range& s, const Range& b,
                          Index        p, const Range& r, Index        c);
  // ---|--|
  Tensor5View operator()( const Range& l,
                          const Range& v, const Range& s, Index        b,
                          const Range& p, const Range& r, Index        c);
  // --|---|
  Tensor5View operator()( const Range& l,
                          const Range& v, Index        s, const Range& b,
                          const Range& p, const Range& r, Index        c);
  // -|----|
  Tensor5View operator()( const Range& l,
                          Index        v, const Range& s, const Range& b,
                          const Range& p, const Range& r, Index        c);
  // |-----|
  Tensor5View operator()( Index l,
                          const Range& v, const Range& s, const Range& b,
                          const Range& p, const Range& r, Index        c);
  // ----||-
  Tensor5View operator()( const Range& l,
                          const Range& v, const Range& s, const Range& b,
                          Index        p, Index        r, const Range& c);
  // ---|-|-
  Tensor5View operator()( const Range& l,
                          const Range& v, const Range& s, Index        b,
                          const Range& p, Index        r, const Range& c);
  // --|--|-
  Tensor5View operator()( const Range& l,
                          const Range& v, Index        s, const Range& b,
                          const Range& p, Index        r, const Range& c);
  // -|---|-
  Tensor5View operator()( const Range& l,
                          Index        v, const Range& s, const Range& b,
                          const Range& p, Index        r, const Range& c);
  // |----|-
  Tensor5View operator()( Index l,
                          const Range& v, const Range& s, const Range& b,
                          const Range& p, Index        r, const Range& c);
  // ---||--
  Tensor5View operator()( const Range& l,
                          const Range& v, const Range& s, Index        b,
                          Index        p, const Range& r, const Range& c);
  // --|-|--
  Tensor5View operator()( const Range& l,
                          const Range& v, Index        s, const Range& b,
                          Index        p, const Range& r, const Range& c);
  // -|--|--
  Tensor5View operator()( const Range& l,
                          Index        v, const Range& s, const Range& b,
                          Index        p, const Range& r, const Range& c);
  // |---|--
  Tensor5View operator()( Index l,
                          const Range& v, const Range& s, const Range& b,
                          Index        p, const Range& r, const Range& c);
  // --||---
  Tensor5View operator()( const Range& l,
                          const Range& v, Index        s, Index        b,
                          const Range& p, const Range& r, const Range& c);
  // -|-|---
  Tensor5View operator()( const Range& l,
                          Index        v, const Range& s, Index        b,
                          const Range& p, const Range& r, const Range& c);
  // |--|---
  Tensor5View operator()( Index l,
                          const Range& v, const Range& s, Index        b,
                          const Range& p, const Range& r, const Range& c);
  // -||----
  Tensor5View operator()( const Range& l,
                          Index        v, Index        s, const Range& b,
                          const Range& p, const Range& r, const Range& c);
  // |-|----
  Tensor5View operator()( Index l,
                          const Range& v, Index        s, const Range& b,
                          const Range& p, const Range& r, const Range& c);
  // ||-----
  Tensor5View operator()( Index l,
                          Index        v, const Range& s, const Range& b,
                          const Range& p, const Range& r, const Range& c);

  // Result 4D (5+4+3+2+1 +4+3+2+1 +3+2+1 +2+1 +1 = 35 combinations)
  // ----|||
  Tensor4View operator()( const Range& l,
                          const Range& v, const Range& s, const Range& b,
                          Index        p, Index        r, Index        c);
  // ---|-||
  Tensor4View operator()( const Range& l,
                          const Range& v, const Range& s, Index        b,
                          const Range& p, Index        r, Index        c);
  // --|--||
  Tensor4View operator()( const Range& l,
                          const Range& v, Index        s, const Range& b,
                          const Range& p, Index        r, Index        c);
  // -|---||
  Tensor4View operator()( const Range& l,
                          Index        v, const Range& s, const Range& b,
                          const Range& p, Index        r, Index        c);
  // |----||
  Tensor4View operator()( Index        l,
                          const Range& v, const Range& s, const Range& b,
                          const Range& p, Index        r, Index        c);
  // ---||-|
  Tensor4View operator()( const Range& l,
                          const Range& v, const Range& s, Index        b,
                          Index        p, const Range& r, Index        c);
  // --|-|-|
  Tensor4View operator()( const Range& l,
                          const Range& v, Index        s, const Range& b,
                          Index        p, const Range& r, Index        c);
  // -|--|-|
  Tensor4View operator()( const Range& l,
                          Index        v, const Range& s, const Range& b,
                          Index        p, const Range& r, Index        c);
  // |---|-|
  Tensor4View operator()( Index        l,
                          const Range& v, const Range& s, const Range& b,
                          Index        p, const Range& r, Index        c);
  // --||--|
  Tensor4View operator()( const Range& l,
                          const Range& v, Index        s, Index        b,
                          const Range& p, const Range& r, Index        c);
  // -|-|--|
  Tensor4View operator()( const Range& l,
                          Index        v, const Range& s, Index        b,
                          const Range& p, const Range& r, Index        c);
  // |--|--|
  Tensor4View operator()( Index        l,
                          const Range& v, const Range& s, Index        b,
                          const Range& p, const Range& r, Index        c);
  // -||---|
  Tensor4View operator()( const Range& l,
                          Index        v, Index        s, const Range& b,
                          const Range& p, const Range& r, Index        c);
  // |-|---|
  Tensor4View operator()( Index        l,
                          const Range& v, Index        s, const Range& b,
                          const Range& p, const Range& r, Index        c);
  // ||----|
  Tensor4View operator()( Index        l,
                          Index        v, const Range& s, const Range& b,
                          const Range& p, const Range& r, Index        c);
  // ---|||-
  Tensor4View operator()( const Range& l,
                          const Range& v, const Range& s, Index        b,
                          Index        p, Index        r, const Range& c);
  // --|-||-
  Tensor4View operator()( const Range& l,
                          const Range& v, Index        s, const Range& b,
                          Index        p, Index        r, const Range& c);
  // -|--||-
  Tensor4View operator()( const Range& l,
                          Index        v, const Range& s, const Range& b,
                          Index        p, Index        r, const Range& c);
  // |---||-
  Tensor4View operator()( Index        l,
                          const Range& v, const Range& s, const Range& b,
                          Index        p, Index        r, const Range& c);
  // --||-|-
  Tensor4View operator()( const Range& l,
                          const Range& v, Index        s, Index        b,
                          const Range& p, Index        r, const Range& c);
  // -|-|-|-
  Tensor4View operator()( const Range& l,
                          Index        v, const Range& s, Index        b,
                          const Range& p, Index        r, const Range& c);
  // |--|-|-
  Tensor4View operator()( Index        l,
                          const Range& v, const Range& s, Index        b,
                          const Range& p, Index        r, const Range& c);
  // -||--|-
  Tensor4View operator()( const Range& l,
                          Index        v, Index        s, const Range& b,
                          const Range& p, Index        r, const Range& c);
  // |-|--|-
  Tensor4View operator()( Index        l,
                          const Range& v, Index        s, const Range& b,
                          const Range& p, Index        r, const Range& c);
  // ||---|-
  Tensor4View operator()( Index        l,
                          Index        v, const Range& s, const Range& b,
                          const Range& p, Index        r, const Range& c);
  // --|||--
  Tensor4View operator()( const Range& l,
                          const Range& v, Index        s, Index        b,
                          Index        p, const Range& r, const Range& c);
  // -|-||--
  Tensor4View operator()( const Range& l,
                          Index        v, const Range& s, Index        b,
                          Index        p, const Range& r, const Range& c);
  // |--||--
  Tensor4View operator()( Index        l,
                          const Range& v, const Range& s, Index        b,
                          Index        p, const Range& r, const Range& c);
  // -||-|--
  Tensor4View operator()( const Range& l,
                          Index        v, Index        s, const Range& b,
                          Index        p, const Range& r, const Range& c);
  // |-|-|--
  Tensor4View operator()( Index        l,
                          const Range& v, Index        s, const Range& b,
                          Index        p, const Range& r, const Range& c);
  // ||--|--
  Tensor4View operator()( Index        l,
                          Index        v, const Range& s, const Range& b,
                          Index        p, const Range& r, const Range& c);
  // -|||---
  Tensor4View operator()( const Range& l,
                          Index        v, Index        s, Index        b,
                          const Range& p, const Range& r, const Range& c);
  // |-||---
  Tensor4View operator()( Index        l,
                          const Range& v, Index        s, Index        b,
                          const Range& p, const Range& r, const Range& c);
  // ||-|---
  Tensor4View operator()( Index        l,
                          Index        v, const Range& s, Index        b,
                          const Range& p, const Range& r, const Range& c);
  // |||----
  Tensor4View operator()( Index        l,
                          Index        v, Index        s, const Range& b,
                          const Range& p, const Range& r, const Range& c);

  // Result 3D (5+4+3+2+1 +4+3+2+1 +3+2+1 +2+1 +1 = 35 combinations)
  // ||||---
  Tensor3View operator()( Index        l,
                          Index        v, Index        s, Index        b,
                          const Range& p, const Range& r, const Range& c);
  // |||-|--
  Tensor3View operator()( Index        l,
                          Index        v, Index        s, const Range& b,
                          Index        p, const Range& r, const Range& c);
  // ||-||--
  Tensor3View operator()( Index        l,
                          Index        v, const Range& s, Index        b,
                          Index        p, const Range& r, const Range& c);
  // |-|||--
  Tensor3View operator()( Index        l,
                          const Range& v, Index        s, Index        b,
                          Index        p, const Range& r, const Range& c);
  // -||||--
  Tensor3View operator()( const Range& l,
                          Index        v, Index        s, Index        b,
                          Index        p, const Range& r, const Range& c);
  // |||--|-
  Tensor3View operator()( Index        l,
                          Index        v, Index        s, const Range& b,
                          const Range& p, Index        r, const Range& c);
  // ||-|-|-
  Tensor3View operator()( Index        l,
                          Index        v, const Range& s, Index        b,
                          const Range& p, Index        r, const Range& c);
  // |-||-|-
  Tensor3View operator()( Index        l,
                          const Range& v, Index        s, Index        b,
                          const Range& p, Index        r, const Range& c);
  // -|||-|-
  Tensor3View operator()( const Range& l,
                          Index        v, Index        s, Index        b,
                          const Range& p, Index        r, const Range& c);
  // ||--||-
  Tensor3View operator()( Index        l,
                          Index        v, const Range& s, const Range& b,
                          Index        p, Index        r, const Range& c);
  // |-|-||-
  Tensor3View operator()( Index        l,
                          const Range& v, Index        s, const Range& b,
                          Index        p, Index        r, const Range& c);
  // -||-||-
  Tensor3View operator()( const Range& l,
                          Index        v, Index        s, const Range& b,
                          Index        p, Index        r, const Range& c);
  // |--|||-
  Tensor3View operator()( Index        l,
                          const Range& v, const Range& s, Index        b,
                          Index        p, Index        r, const Range& c);
  // -|-|||-
  Tensor3View operator()( const Range& l,
                          Index        v, const Range& s, Index        b,
                          Index        p, Index        r, const Range& c);
  // --||||-
  Tensor3View operator()( const Range& l,
                          const Range& v, Index        s, Index        b,
                          Index        p, Index        r, const Range& c);
  // |||---|
  Tensor3View operator()( Index        l,
                          Index        v, Index        s, const Range& b,
                          const Range& p, const Range& r, Index        c);
  // ||-|--|
  Tensor3View operator()( Index        l,
                          Index        v, const Range& s, Index        b,
                          const Range& p, const Range& r, Index        c);
  // |-||--|
  Tensor3View operator()( Index        l,
                          const Range& v, Index        s, Index        b,
                          const Range& p, const Range& r, Index        c);
  // -|||--|
  Tensor3View operator()( const Range& l,
                          Index        v, Index        s, Index        b,
                          const Range& p, const Range& r, Index        c);
  // ||--|-|
  Tensor3View operator()( Index        l,
                          Index        v, const Range& s, const Range& b,
                          Index        p, const Range& r, Index        c);
  // |-|-|-|
  Tensor3View operator()( Index        l,
                          const Range& v, Index        s, const Range& b,
                          Index        p, const Range& r, Index        c);
  // -||-|-|
  Tensor3View operator()( const Range& l,
                          Index        v, Index        s, const Range& b,
                          Index        p, const Range& r, Index        c);
  // |--||-|
  Tensor3View operator()( Index        l,
                          const Range& v, const Range& s, Index        b,
                          Index        p, const Range& r, Index        c);
  // -|-||-|
  Tensor3View operator()( const Range& l,
                          Index        v, const Range& s, Index        b,
                          Index        p, const Range& r, Index        c);
  // --|||-|
  Tensor3View operator()( const Range& l,
                          const Range& v, Index        s, Index        b,
                          Index        p, const Range& r, Index        c);
  // ||---||
  Tensor3View operator()( Index        l,
                          Index        v, const Range& s, const Range& b,
                          const Range& p, Index        r, Index        c);
  // |-|--||
  Tensor3View operator()( Index        l,
                          const Range& v, Index        s, const Range& b,
                          const Range& p, Index        r, Index        c);
  // -||--||
  Tensor3View operator()( const Range& l,
                          Index        v, Index        s, const Range& b,
                          const Range& p, Index        r, Index        c);
  // |--|-||
  Tensor3View operator()( Index        l,
                          const Range& v, const Range& s, Index        b,
                          const Range& p, Index        r, Index        c);
  // -|-|-||
  Tensor3View operator()( const Range& l,
                          Index        v, const Range& s, Index        b,
                          const Range& p, Index        r, Index        c);
  // --||-||
  Tensor3View operator()( const Range& l,
                          const Range& v, Index        s, Index        b,
                          const Range& p, Index        r, Index        c);
  // |---|||
  Tensor3View operator()( Index        l,
                          const Range& v, const Range& s, const Range& b,
                          Index        p, Index        r, Index        c);
  // -|--|||
  Tensor3View operator()( const Range& l,
                          Index        v, const Range& s, const Range& b,
                          Index        p, Index        r, Index        c);
  // --|-|||
  Tensor3View operator()( const Range& l,
                          const Range& v, Index        s, const Range& b,
                          Index        p, Index        r, Index        c);
  // ---||||
  Tensor3View operator()( const Range& l,
                          const Range& v, const Range& s, Index        b,
                          Index        p, Index        r, Index        c);

  // Result 2D (6+5+4+3+2+1 = 21 combinations)
  // |||||--
  MatrixView  operator()( Index        l,
                          Index        v, Index        s, Index        b,
                          Index        p, const Range& r, const Range& c);
  // ||||-|-
  MatrixView  operator()( Index        l,
                          Index        v, Index        s, Index        b,
                          const Range& p, Index        r, const Range& c);
  // |||-||-
  MatrixView  operator()( Index        l,
                          Index        v, Index        s, const Range& b,
                          Index        p, Index        r, const Range& c);
  // ||-|||-
  MatrixView  operator()( Index        l,
                          Index        v, const Range& s, Index        b,
                          Index        p, Index        r, const Range& c);
  // |-||||-
  MatrixView  operator()( Index        l,
                          const Range& v, Index        s, Index        b,
                          Index        p, Index        r, const Range& c);
  // -|||||-
  MatrixView  operator()( const Range& l,
                          Index        v, Index        s, Index        b,
                          Index        p, Index        r, const Range& c);
  // ||||--|
  MatrixView  operator()( Index        l,
                          Index        v, Index        s, Index        b,
                          const Range& p, const Range& r, Index        c);
  // |||-|-|
  MatrixView  operator()( Index        l,
                          Index        v, Index        s, const Range& b,
                          Index        p, const Range& r, Index        c);
  // ||-||-|
  MatrixView  operator()( Index        l,
                          Index        v, const Range& s, Index        b,
                          Index        p, const Range& r, Index        c);
  // |-|||-|
  MatrixView  operator()( Index        l,
                          const Range& v, Index        s, Index        b,
                          Index        p, const Range& r, Index        c);
  // -||||-|
  MatrixView  operator()( const Range& l,
                          Index        v, Index        s, Index        b,
                          Index        p, const Range& r, Index        c);
  // |||--||
  MatrixView  operator()( Index        l,
                          Index        v, Index        s, const Range& b,
                          const Range& p, Index        r, Index        c);
  // ||-|-||
  MatrixView  operator()( Index        l,
                          Index        v, const Range& s, Index        b,
                          const Range& p, Index        r, Index        c);
  // |-||-||
  MatrixView  operator()( Index        l,
                          const Range& v, Index        s, Index        b,
                          const Range& p, Index        r, Index        c);
  // -|||-||
  MatrixView  operator()( const Range& l,
                          Index        v, Index        s, Index        b,
                          const Range& p, Index        r, Index        c);
  // ||--|||
  MatrixView  operator()( Index        l,
                          Index        v, const Range& s, const Range& b,
                          Index        p, Index        r, Index        c);
  // |-|-|||
  MatrixView  operator()( Index        l,
                          const Range& v, Index        s, const Range& b,
                          Index        p, Index        r, Index        c);
  // -||-|||
  MatrixView  operator()( const Range& l,
                          Index        v, Index        s, const Range& b,
                          Index        p, Index        r, Index        c);
  // |--||||
  MatrixView  operator()( Index        l,
                          const Range& v, const Range& s, Index        b,
                          Index        p, Index        r, Index        c);
  // -|-||||
  MatrixView  operator()( const Range& l,
                          Index        v, const Range& s, Index        b,
                          Index        p, Index        r, Index        c);
  // --|||||
  MatrixView  operator()( const Range& l,
                          const Range& v, Index        s, Index        b,
                          Index        p, Index        r, Index        c);

  // Result 1D (7 combinations)
  // ||||||-
  VectorView  operator()( Index        l,
                          Index        v, Index        s, Index        b,
                          Index        p, Index        r, const Range& c);
  // |||||-|
  VectorView  operator()( Index        l,
                          Index        v, Index        s, Index        b,
                          Index        p, const Range& r, Index        c);
  // ||||-||
  VectorView  operator()( Index        l,
                          Index        v, Index        s, Index        b,
                          const Range& p, Index        r, Index        c);
  // |||-|||
  VectorView  operator()( Index        l,
                          Index        v, Index        s, const Range& b,
                          Index        p, Index        r, Index        c);
  // ||-||||
  VectorView  operator()( Index        l,
                          Index        v, const Range& s, Index        b,
                          Index        p, Index        r, Index        c);
  // |-|||||
  VectorView  operator()( Index        l,
                          const Range& v, Index        s, Index        b,
                          Index        p, Index        r, Index        c);
  // -||||||
  VectorView  operator()( const Range& l,
                          Index        v, Index        s, Index        b,
                          Index        p, Index        r, Index        c);

  // Result scalar (1 combination)
  // |||||||
  Numeric& operator() ( Index        l,
                        Index        v, Index        s, Index        b,
                        Index        p, Index        r, Index        c)
      { CHECK(l);
        CHECK(v);
        CHECK(s);
        CHECK(b);
        CHECK(p);
        CHECK(r);
        CHECK(c);
        return get(l, v, s, b, p, r, c);
      }

  /** Get element implementation without assertions. */
  Numeric& get( Index        l,
                Index        v, Index        s, Index        b,
                Index        p, Index        r, Index        c)
      {
        return                *(mdata + OFFSET(l) +
                                OFFSET(v) + OFFSET(s) + OFFSET(b) +
                                OFFSET(p) + OFFSET(r) + OFFSET(c)    );
      }


  // Conversion to a plain C-array
  const Numeric *get_c_array() const;
  Numeric *get_c_array();

  // Functions returning const iterators:
  ConstIterator7D begin() const;
  ConstIterator7D end() const;
  // Functions returning iterators:
  Iterator7D begin();
  Iterator7D end();
  
  // Assignment operators:
  Tensor7View& operator=(const ConstTensor7View& v);
  Tensor7View& operator=(const Tensor7View& v);
  Tensor7View& operator=(const Tensor7& v);
  Tensor7View& operator=(Numeric x);

  // Other operators:
  Tensor7View& operator*=(Numeric x);
  Tensor7View& operator/=(Numeric x);
  Tensor7View& operator+=(Numeric x);
  Tensor7View& operator-=(Numeric x);

  Tensor7View& operator*=(const ConstTensor7View& x);
  Tensor7View& operator/=(const ConstTensor7View& x);
  Tensor7View& operator+=(const ConstTensor7View& x);
  Tensor7View& operator-=(const ConstTensor7View& x);

  //! Destructor.
  virtual ~Tensor7View() {}

  // Friends:

  // Special constructor to make a Tensor7 view of a Tensor6.
  Tensor7View(const Tensor6View& a);

protected:
  // Constructors:
  Tensor7View();
  Tensor7View(Numeric *data,
              const Range& l,
              const Range& v, const Range& s, const Range& b,
              const Range& p, const Range& r, const Range& c);
  Tensor7View(Numeric *data,
              const Range& pl,
              const Range& pv, const Range& ps, const Range& pb,
              const Range& pp, const Range& pr, const Range& pc,
              const Range& nl,
              const Range& nv, const Range& ns, const Range& nb,
              const Range& np, const Range& nr, const Range& nc);
};

/** The Tensor7 class. This is a Tensor7View that also allocates storage
    automatically, and deallocates it when it is destroyed. We take
    all the functionality from Tensor7View. Additionally defined here
    are: 

    1. Constructors and destructor.
    2. Assignment operators.
    3. Resize function. */
class Tensor7 : public Tensor7View {
public:
  // Constructors:
  Tensor7();
  Tensor7(Index        l,
          Index        v, Index        s, Index        b,
          Index        p, Index        r, Index        c);
  Tensor7(Index        l,
          Index        v, Index        s, Index        b,
          Index        p, Index        r, Index        c,
          Numeric fill);
  Tensor7(const ConstTensor7View& v);
  Tensor7(const Tensor7& v);

  // Assignment operators:
  Tensor7& operator=(Tensor7 x);
  Tensor7& operator=(Numeric x);

  // Resize function:
  void resize(Index        l,
              Index        v, Index        s, Index        b,
              Index        p, Index        r, Index        c);

  // Swap function:
  friend void swap(Tensor7& t1, Tensor7& t2);

  // Destructor:
  virtual ~Tensor7();
};


// Function declarations:
// ----------------------

void copy(ConstIterator7D origin,
          const ConstIterator7D& end,
          Iterator7D target);

void copy(Numeric x,
          Iterator7D target,
          const Iterator7D& end);

void transform( Tensor7View y,
                double (&my_func)(double),
                ConstTensor7View x );

Numeric max(const ConstTensor7View& x);

Numeric min(const ConstTensor7View& x);

std::ostream& operator<<(std::ostream& os, const ConstTensor7View& v);

////////////////////////////////
// Helper function for debugging
#ifndef NDEBUG

Numeric debug_tensor7view_get_elem (Tensor7View& tv, Index l, Index v, Index s,
                                    Index b, Index p, Index r, Index c);

#endif
////////////////////////////////

#endif    // matpackVII_h
