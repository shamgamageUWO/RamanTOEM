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

#include <cmath>
#include <iostream>
#include <cstdlib>
#include "matpackVII.h"
#include "exceptions.h"
#include "array.h"
#include "make_array.h"
#include "mystring.h"
#include "make_vector.h"
#include "math_funcs.h"
#include "describe.h"
#include "matpackII.h"
#include "rational.h"
#include "logic.h"
#include "wigner_functions.h"

using std::cout;
using std::endl;
using std::runtime_error;


Numeric by_reference(const Numeric& x)
{
  return x+1;
}

Numeric by_value(Numeric x)
{
  return x+1;
}

void fill_with_junk(VectorView x)
{
  x = 999;
}

void fill_with_junk(MatrixView x)
{
  x = 888;
}

int test1()
{
  Vector v(20);

  cout << "v.nelem() = " << v.nelem() << "\n";

  for (Index i=0; i<v.nelem(); ++i )
    v[i] = (Numeric)i;

  cout << "v.begin() = " << *v.begin() << "\n";

  cout << "v = \n" << v << "\n";

  fill_with_junk(v[Range(1,8,2)][Range(2,joker)]);
  //  fill_with_junk(v);

  Vector v2 = v[Range(2,4)];

  cout << "v2 = \n" << v2 << "\n";

  for (Index i=0 ; i<1000; ++i)
    {
      Vector v3(1000);
      v3 = (Numeric)i;
    }

  v2[Range(joker)] = 88;

  v2[Range(0,2)] = 77;

  cout << "v = \n" << v << "\n";
  cout << "v2 = \n" << v2 << "\n";
  cout << "v2.nelem() = \n" << v2.nelem() << "\n";

  Vector v3;
  v3.resize(v2.nelem());
  v3 = v2;

  cout << "\nv3 = \n" << v3 << "\n";
  fill_with_junk((VectorView)v2);
  cout << "\nv3 after junking v2 = \n" << v3 << "\n";
  v3 *= 2;
  cout << "\nv3 after *2 = \n" << v3 << "\n";

  Matrix M(10,15);
  {
    Numeric n=0;
    for (Index i=0; i<M.nrows(); ++i)
      for (Index j=0; j<M.ncols(); ++j)
        M(i,j) = ++n;
  }

  cout << "\nM =\n" << M << "\n";

  cout << "\nM(Range(2,4),Range(2,4)) =\n" << M(Range(2,4),Range(2,4)) << "\n";

  cout << "\nM(Range(2,4),Range(2,4))(Range(1,2),Range(1,2)) =\n"
       << M(Range(2,4),Range(2,4))(Range(1,2),Range(1,2)) << "\n";

  cout << "\nM(1,Range(joker)) =\n" << M(1,Range(joker)) << "\n";

  cout << "\nFilling M(1,Range(1,2)) with junk.\n";
  fill_with_junk(M(1,Range(1,2)));

  cout << "\nM(Range(0,4),Range(0,4)) =\n" << M(Range(0,4),Range(0,4)) << "\n";

  cout << "\nFilling M(Range(4,2,2),Range(6,3)) with junk.\n";

  MatrixView s = M(Range(4,2,2),Range(6,3));
  fill_with_junk(s);

  cout << "\nM =\n" << M << "\n";

  const Matrix C = M;

  cout << "\nC(Range(3,4,2),Range(2,3,3)) =\n"
       << C(Range(3,4,2),Range(2,3,3)) << "\n";

  cout << "\nC(Range(3,4,2),Range(2,3,3)).transpose() =\n"
       << transpose(C(Range(3,4,2),Range(2,3,3))) << "\n";

  return 0;
}

void test2()
{
  Vector v(50000000);

  cout << "v.nelem() = " << v.nelem() << "\n";

  cout << "Filling\n";
//   for (Index i=0; i<v.nelem(); ++i )
//     v[i] = sqrt(i);
  v = 1.;
  cout << "Done\n";

}


void test4()
{
  Vector a(10);
  Vector b(a.nelem());

  for ( Index i=0; i<a.nelem(); ++i )
    {
      a[i] = (Numeric)(i+1);
      b[i] = (Numeric)(a.nelem()-i);
    }

  cout << "a = \n" << a << "\n";
  cout << "b = \n" << b << "\n";
  cout << "a*b \n= " << a*b << "\n";

  Matrix A(11,6);
  Matrix B(10,20);
  Matrix C(20,5);

  B = 2;
  C = 3;
  mult(A(Range(1,joker),Range(1,joker)),B,C);

  //  cout << "\nB =\n" << B << "\n";
  //  cout << "\nC =\n" << C << "\n";
  cout << "\nB*C =\n" << A << "\n";
  
}

void test5()
{
  Vector a(10);
  Vector b(20);
  Matrix M(10,20);

  // Fill b and M with a constant number:
  b = 1;
  M = 2;

  cout << "b = \n" << b << "\n";
  cout << "M =\n" << M << "\n";

  mult(a,M,b);    // a = M*b
  cout << "\na = M*b = \n" << a << "\n";

  mult(transpose((MatrixView)b),transpose((MatrixView)a),M); // b^t = a^t * M
  cout << "\nb^t = a^t * M = \n" <<  transpose((MatrixView)b) << "\n";
  
}

void test6()
{
  Index n = 5000;
  Vector x(1,n,1), y(n);
  Matrix M(n,n);
  M = 1;
  //  cout << "x = \n" << x << "\n";

  cout << "Transforming.\n";
  //  transform(x,sin,x);
  // transform(transpose(y),sin,transpose(x));
  //  cout << "sin(x) =\n" << y << "\n";
  for (Index i=0; i<1000; ++i)
    {
      //      mult(y,M,x);
      transform(y,sin,static_cast<MatrixView>(x));
      x+=1;
    }
  //  cout << "y =\n" << y << "\n";

  cout << "Done.\n";
}

void test7()
{
  Vector x(1,20000000,1);
  Vector y(x.nelem());
  transform(y,sin,x);
  cout << "min(sin(x)), max(sin(x)) = " << min(y) << ", " << max(y) << "\n";
}

void test8()
{
  Vector x(80000000);
  for ( Index i=0; i<x.nelem(); ++i )
    x[i] = (Numeric)i;
  cout << "Done." << "\n";
}

void test9()
{
  // Initialization of Matrix with view of other Matrix:
  Matrix A(4,8);
  Matrix B(A(Range(joker),Range(0,3)));
  cout << "B = " << B << "\n";
}

void test10()
{
  // Initialization of Matrix with a vector (giving a 1 column Matrix).

  // At the moment doing this with a non-const Vector will result in a
  // warning message. 
  Vector v(1,8,1);
  Matrix M((const Vector)v);
  cout << "M = " << M << "\n";
}

void test11()
{
  // Assignment between Vector and Matrix:

  // At the moment doing this with a non-const Vector will result in a
  // warning message.
  Vector v(1,8,1);
  Matrix M(v.nelem(),1);
  M = v;
  cout << "M = " << M << "\n";
}

void test12()
{
  // Copying of Arrays

  Array<String> sa(3);
  sa[0] = "It's ";
  sa[1] = "a ";
  sa[2] = "test.";

  Array<String> sb(sa), sc(sa.nelem());

  cout << "sb = \n" << sb << "\n";

  sc = sa;

  cout << "sc = \n" << sc << "\n";

}

void test13()
{
  // Mix vector and one-column matrix in += operator.
  const Vector v(1,8,1);        // The const is necessary here to
                                // avoid compiler warnings about
                                // different conversion paths.
  Matrix M(v);
  M += v;
  cout << "M = \n" << M << "\n";
}

void test14()
{
  // Test explicit Array constructors.
  Array<String> a = MakeArray<String>("Test");
  Array<Index>  b = MakeArray<Index>(1,2);
  Array<Numeric> c = MakeArray<Numeric>(1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0);
  cout << "a = \n" << a << "\n";
  cout << "b = \n" << b << "\n";
  cout << "c = \n" << c << "\n";
}

void test15()
{
  // Test String.
  String a = "Nur ein Test.";
  cout << "a = " << a << "\n";
  String b(a,5,-1);
  cout << "b = " << b << "\n";
}

/*void test16()
{
  // Test interaction between Array<Numeric> and Vector.
  Vector a;
  Array<Numeric> b;
  b.push_back(1);
  b.push_back(2);
  b.push_back(3);
  a.resize(b.nelem());
  a = b;
  cout << "b =\n" << b << "\n";
  cout << "a =\n" << a << "\n";
}*/

void test17()
{
  // Test Sum.
  Vector a(1,10,1);
  cout << "a.sum() = " << a.sum() << "\n";
}

void test18()
{
  // Test elementvise square of a vector:
  Vector a(1,10,1);
  a *= a;
  cout << "a *= a =\n" << a << "\n";
}

void test19()
{
  // There exists no explicit filling constructor of the form 
  // Vector a(3,1.7).
  // But you can use the more general filling constructor with 3 arguments.

  Vector a(1,10,1);
  Vector b(5.3,10,0);
  cout << "a =\n" << a << "\n";
  cout << "b =\n" << b << "\n";
}

void test20()
{
  // Test MakeVector:
  MakeVector a(1,2,3,4,5,6,7,8,9,10);
  cout << "a =\n" << a << "\n";
}

void test21()
{
  Numeric s=0;
  // Test speed of call by reference:
  cout << "By reference:\n";
  for ( Index i=0; i<1e8; ++i )
    {
      s += by_reference(s);
      s -= by_reference(s);
    }
  cout << "s = " << s << "\n";  
}

void test22()
{
  Numeric s=0;
  // Test speed of call by value:
  cout << "By value:\n";
  for ( Index i=0; i<1e8; ++i )
    {
      s += by_value(s);
      s -= by_value(s);
    }
  cout << "s = " << s << "\n";
}

void test23()
{
  // Test constructors that fills with constant:
  Vector a(10,3.5);
  cout << "a =\n" << a << "\n";
  Matrix b(10,10,4.5);
  cout << "b =\n" << b << "\n";
}

void test24()
{
  // Try element-vise multiplication of Matrix and Vector:
  Matrix a(5,1,2.5);
  Vector b(1,5,1);
  a *= b;
  cout << "a*=b =\n" << a << "\n";
  a /= b;
  cout << "a/=b =\n" << a << "\n";
  a += b;
  cout << "a+=b =\n" << a << "\n";
  a -= b;
  cout << "a-=b =\n" << a << "\n";
}

void test25()
{
  // Test min and max for Array:
  MakeArray<Index> a(1,2,3,4,5,6,5,4,3,2,1);
  cout << "min/max of a = " << min(a) << "/" << max(a) << "\n";
}

void test26()
{
  cout << "Test filling constructor for Array:\n";
  Array<String> a(4,"Hello");
  cout << "a =\n" << a << "\n";
}

void test27()
{
  cout << "Test Arrays of Vectors:\n";
  Array<Vector> a;
  a.push_back(MakeVector(1.0,2.0));
  a.push_back(Vector(1.0,10,1.0));
  cout << "a =\n" << a << "\n";
}

void test28()
{
  cout << "Test default constructor for Matrix:\n";
  Matrix a;
  Matrix b(a);
  cout << "b =\n" << b << "\n";
}

void test29()
{
  cout << "Test Arrays of Matrix:\n";
  ArrayOfMatrix a;
  Matrix b;

  b.resize(2,2);
  b(0,0) = 1;
  b(0,1) = 2;
  b(1,0) = 3;
  b(1,1) = 4;
  a.push_back(b);
  b *= 2;
  a.push_back(b);

  a[0].resize(2,3);
  a[0] = 4;

  a.resize(3);
  a[2].resize(4,5);
  a[2] = 5;

  cout << "a =\n" << a << "\n";
}

void test30()
{
  cout << "Test Matrices of size 0:\n";
  Matrix a(0,0);
  //  cout << "a(0,0) =\n" << a(0,0) << "\n";
  a.resize(2,2);
  a = 1;
  cout << "a =\n" << a << "\n";

  Matrix b(3,0);
  //  cout << "b(0,0) =\n" << b(0,0) << "\n";
  b.resize(b.nrows(),b.ncols()+3);
  b = 2;
  cout << "b =\n" << b << "\n";

  Matrix c(0,3);
  //  cout << "c(0,0) =\n" << c(0,0) << "\n";
  c.resize(c.nrows()+3,c.ncols());
  c = 3;
  cout << "c =\n" << c << "\n";
}

void test31()
{
  cout << "Test Tensor3:\n";

  Tensor3 a(2,3,4,1.0);

  Index fill = 0;

  // Fill with some numbers
  for ( Index i=0; i<a.npages(); ++i )
    for ( Index j=0; j<a.nrows(); ++j )
      for ( Index k=0; k<a.ncols(); ++k )
        a(i,j,k) = (Numeric)(++fill);

  cout << "a =\n" << a << "\n";

  cout << "Taking out first row of first page:\n"
       << a(0,0,Range(joker)) << "\n";

  cout << "Taking out last column of second page:\n"
       << a(1,Range(joker),a.ncols()-1) << "\n";

  cout << "Taking out the first letter on every page:\n"
       << a(Range(joker),0,0) << "\n";

  cout << "Taking out first page:\n"
       << a(0,Range(joker),Range(joker)) << "\n";

  cout << "Taking out last row of all pages:\n"
       << a(Range(joker),a.nrows()-1,Range(joker)) << "\n";

  cout << "Taking out second column of all pages:\n"
       << a(Range(joker),Range(joker),1) << "\n";

  a *= 2;

  cout << "After element-vise multiplication with 2:\n"
       << a << "\n";

  transform(a,sqrt,a);

  cout << "After taking the square-root:\n"
       << a << "\n";

  Index s = 200;
  cout << "Let's allocate a large tensor, "
       << (Numeric)(s*s*s*8)/1024./1024.
       << " MB...\n";

  a.resize(s,s,s);

  cout << "Set it to 1...\n";

  a = 1;

  cout << "a(900,900,900) = " << a(90,90,90) << "\n";

  fill = 0;

  cout << "Fill with running numbers, using for loops...\n";
  for ( Index i=0; i<a.npages(); ++i )
    for ( Index j=0; j<a.nrows(); ++j )
      for ( Index k=0; k<a.ncols(); ++k )
        a(i,j,k) = (Numeric)(++fill);

  cout << "Max(a) = ...\n";

  cout << max(a) << "\n";

}

void test32()
{
  cout << "Test von X = A*X:\n";
  Matrix X(3,3),A(3,3),B(3,3);
  
  for ( Index j=0; j<A.nrows(); ++j )
    for ( Index k=0; k<A.ncols(); ++k )
      {
        X(j,k) = 1;
        A(j,k) = (Numeric)(j+k);
      }
  cout << "A:\n" << A << "\n";
  cout << "X:\n" << X << "\n";

  mult(B,A,X);
  cout << "B = A*X:\n" << B << "\n";
  mult(X,A,X);
  cout << "X = A*X:\n" << X << "\n";

  cout << "This is not the same, and should not be, because you\n"
       << "are not allowed to use the same matrix as input and output\n"
       << "for mult!\n";
}

void test33()
{
  cout << "Making things look bigger than they are...\n";

  {
    cout << "1. Make a scalar look like a vector:\n";
    Numeric a = 3.1415;         // Just any number here.
    VectorView av(a);
    cout << "a, viewed as a vector: " << av << "\n";
    cout << "Describe a: " << describe(a) << "\n";
    av[0] += 1;
    cout << "a, after the first element\n"
         << "of the vector has been increased by 1: " << a << "\n";
  }

  {
    cout << "\n2. Make a vector look like a matrix:\n"
         << "This is an exception, because the new dimension is added at the end.\n";
    MakeVector a(1,2,3,4,5);
    MatrixView am = a;
    cout << "a, viewed as a matrix:\n" << am << "\n";
    cout << "Trasnpose view:\n" << transpose(am) << "\n";
    cout << "Describe transpose(am): " << describe(transpose(am)) << "\n";

    cout << "\n3. Make a matrix look like a tensor3:\n";
    Tensor3View at3 = am;
    cout << "at3 = \n" << at3 << "\n";
    cout << "Describe at3: " << describe(at3) << "\n";
    at3 (0,2,0) += 1;
    cout << "a after Increasing element at3(0,2,0) by 1: \n" << a << "\n\n";

    Tensor4View at4 = at3;
    cout << "at4 = \n" << at4 << "\n";
    cout << "Describe at4: " << describe(at4) << "\n";

    Tensor5View at5 = at4;
    cout << "at5 = \n" << at5 << "\n";
    cout << "Describe at5: " << describe(at5) << "\n";

    Tensor6View at6 = at5;
    cout << "at6 = \n" << at6 << "\n";
    cout << "Describe at6: " << describe(at6) << "\n";

    Tensor7View at7 = at6;
    cout << "at7 = \n" << at7 << "\n";
    cout << "Describe at7: " << describe(at7) << "\n";

    at7(0,0,0,0,0,2,0) -=1 ;

    cout << "After subtracting 1 from at7(0,0,0,0,0,2,0)\n"
         << "a = " << a << "\n";

    cout << "\nAll in one go:\n";
    Numeric b = 3.1415;         // Just any number here.
    Tensor7View bt7 =
      Tensor6View(
                  Tensor5View(
                              Tensor4View(
                                          Tensor3View(
                                                      MatrixView(
                                                                 VectorView(b)
                                                                 )
                                                      )
                                          )
                              )
                  );
    cout << "bt7:\n" << bt7 << "\n";
    cout << "Describe bt7: " << describe(bt7) << "\n";
  }
}

void junk4(Tensor4View a)
{
  cout << "Describe a: " << describe(a) << "\n";
}

void junk2(ConstVectorView a)
{
  cout << "Describe a: " << describe(a) << "\n";
}

void test34()
{
  cout << "Test, if dimension expansion works implicitly.\n";

  Tensor3 t3(2,3,4);
  junk4(t3);

  Numeric x;
  junk2(ConstVectorView(x));
}

void test35()
{
  cout << "Test the new copy semantics.\n";
  Vector a(1,4,1);
  Vector b;

  b = a;
  cout << "b = " << b << "\n";

  Vector aa(1,5,1);
  ConstVectorView c = aa;
  b = c;
  cout << "b = " << b << "\n";

  Vector aaa(1,6,1);
  VectorView d = aaa;
  b = d;
  cout << "b = " << b << "\n";
}

void test36()
{
  cout << "Test using naked joker on Vector.\n";
  Vector a(1,4,1);
  VectorView b = a[joker];
  cout << "a = " << a << "\n";
  cout << "b = " << b << "\n";
}

void test37(const Index& i)
{
  Vector v1(5e-15, 10, 0.42e-15/11);
  Vector v2=v1;
  //  Index i = 10000000;

  v1 /= (Numeric)i;
  v2 /=(Numeric)i;
  cout.precision(12);
  //  cout.setf(ios_base::scientific,ios_base::floatfield);
  v1*=v1;
  v2*=v2;  
cout << v1 << endl;
  cout << v2 << endl;
}

void test38 ()
{
  Vector v (5, 0.);
  Numeric * const a = v.get_c_array();

  a[4] = 5.;

  cout << v << endl;
  cout << endl << "========================" << endl << endl;

  Matrix m (5, 5, 0.);
  Numeric * const b = m.get_c_array();

  b[4] = 5.;

  cout << m << endl;
  cout << endl << "========================" << endl << endl;

  Tensor3 t3 (5, 6, 7, 0.);
  Numeric * const c = t3.get_c_array();

  c[6] = 5.;

  cout << t3 << endl;
}

void test39 ()
{
  Vector v1(1,5,1),v2(5);
  
  v2 = v1 * 2;
  // Unfortunately, this thing compiles, but at least it gives an
  // assertion failure at runtime. I think what happens is that it
  // implicitly creates a one element vector out of the "2", then
  // tries to do a scalar product with v1.

  cout << v2 << endl;

}

void test40()
{
  Vector v(100);
  
  v = 5;
  
  cout << v << endl;
}

void test41()
{
  const Vector v1(10, 1);
  
  ConstVectorView vv = v1[Range(0, 5)];
  
  cout << "Vector:     " << v1 << endl;
  cout << "VectorView: " << vv << endl;
  
  try {
    vv = 2;
  } catch (runtime_error e) {
    std::cerr << e.what() << endl;
    exit(EXIT_FAILURE);
  }
  
  cout << "VectorView: " << vv << endl;
  cout << "Vector:     " << v1 << endl;
}

// Test behaviour of VectorView::operator MatrixView, for which I have fixed
// a bug today.
// SAB 2013-01-18
void test42()
{
    cout << "test42\n";
    Vector x = MakeVector(1,2,3,4,5,6,7,8,9,10);
    cout << "x: " << x << endl;

    VectorView y = x[Range(2,4,2)];
    cout << "y: " << y << endl;
    
    ConstMatrixView z(y);
    cout << "z:\n" << z << endl;

    cout << "Every other z:\n" << z(Range(1,2,2),joker) << endl;
    
    // Try write access also:
    MatrixView zz(y);
    zz(Range(1,2,2),joker) = 0;
    cout << "zz:\n" << zz << endl;
    cout << "New x: " << x << endl;
}


void test43()
{
    Rational r(3,2);
    Rational r2;
    r2 = 1;
    cout << r2+r << endl;
    cout << 1+r << endl;
    cout << r+1 << endl;
}


void test44()
{
#define docheck(fn, val, expect) \
  cout << #fn << "(" << val << ") = " << fn(x) << " (expected " << #expect << ")" << std::endl;

    Vector x = MakeVector(1, 2, 3);
    docheck(is_increasing, x, 1)
    docheck(is_decreasing, x, 0)
    docheck(is_sorted, x, 1)

    x = MakeVector(3, 2, 1);
    docheck(is_increasing, x, 0)
    docheck(is_decreasing, x, 1)
    docheck(is_sorted, x, 0)

    x = MakeVector(1, 2, 2);
    docheck(is_increasing, x, 0)
    docheck(is_decreasing, x, 0)
    docheck(is_sorted, x, 1)

    x = MakeVector(2, 2, 1);
    docheck(is_increasing, x, 0)
    docheck(is_decreasing, x, 0)
    docheck(is_sorted, x, 0)

    x = MakeVector(1, NAN, 2);
    docheck(is_increasing, x, 0)
    docheck(is_decreasing, x, 0)
    docheck(is_sorted, x, 0)

    x = MakeVector(2, NAN, 1);
    docheck(is_increasing, x, 0)
    docheck(is_decreasing, x, 0)
    docheck(is_sorted, x, 0)

    x = MakeVector(NAN, NAN, NAN);
    docheck(is_increasing, x, 0)
    docheck(is_decreasing, x, 0)
    docheck(is_sorted, x, 0)
    
#undef docheck
}


void test45()
{
    //Rational j1=1,j2=1,j3=1,m1=0,m2=0,m3=0;
    //std::cout << "My function " << wigner3j(j1,j2,j3,m1,m2,m3)  << std::endl;
/*    
    ArrayOfIndex a,b;
    a=MakeArray<Index>(1,4,5);b=MakeArray<Index>(20,10,10);
    std::cout << "My factorials for nominators ["<<a<<" ] and denominators ["<<b<<" ]: " << factorials(a,b)  <<"." << std::endl;*/
    
/*    
    for(Rational L(1);L<3;L++)
    {
        std::cout << "L="<<L<<std::endl;
        for(Rational ii=1;ii<11;ii++)
        {
            for(Rational jj=1;jj<11;jj++)
            {
                std::cout << " "<< wigner3j(ii,jj,L,0,0,0);
            }
            std::cout << std::endl;
        }
        std::cout << std::endl;
    }*/
std::cout<<pow(0,0.3)<<std::endl;
ArrayOfIndex N;N=MakeArray<Index>(1, 1, 3, 3, 5, 5, 7, 7, 9,  9, 11, 11, 13, 13, 15, 15, 17, 17, 19, 19, 21, 21, 23, 23, 25, 25, 27, 27, 29, 29, 
                                  31, 31, 33, 33, 35, 35, 37, 37);
ArrayOfIndex J;J=MakeArray<Index>(0, 2, 2, 4, 4, 6, 6, 8, 8, 10, 10, 12, 12, 14, 14, 16, 16, 18, 18, 20, 20, 22, 22, 24, 24, 26, 26, 28, 28, 30, 
                                  30, 32, 32, 34, 34, 36, 36, 38);

    for(Index II = 0; II<N.nelem(); II++)
    {
        for(Index JJ = 0; JJ<N.nelem(); JJ++)
        {
            const Rational Nl(N[II]),Nk(N[JJ]);
            Numeric A=0;
            for(Index L(0);L<=10*max(J);L++)
            {
                //if(l<k)
                {
                    A+=
                    sqrt(2*Nk.toNumeric()+1)*
                    sqrt(2*Nl.toNumeric()+1)*
                    sqrt(sqrt(2*Nk.toNumeric()+1)*
                    sqrt(2*Nl.toNumeric()+1)*
                    sqrt(2*J[II]+1)*
                    sqrt(2*J[JJ]+1))*
                    ECS_wigner(L,Nl,Nk,Nk,Nl,J[II],J[JJ])*
                    pow(-1., (Nk+Nl+L+1).toNumeric());
                }
            }
            std::cout << " " << A;
        }
        std::cout << std::endl;        
    }
    
    Vector d; d.resize(38);
    
    for(Index II = 0; II<N.nelem(); II++)
        d[II] = wigner6j(1, 1, 1, J[II], N[II], N[II]) * pow(-1.,2.*(Numeric)N[II]) * sqrt(6*(2*N[II]+1)*(2*J[II]+1));
    
    std::cout<<d<<std::endl;
    
//     for(Index a = 1; a<6; a++)
//         for(Index b = 1; b<6; b++)
//             for(Index c = 1; c<6; c++)
//                     std::cout << wigner3j(a,b,c,0,0,0)<<std::endl;
    
}

int main()
{
//   test1();
//   test2();
//   test3();
//   test4();
//   test5();
//   test6();
//   test7();
//   test8();
//   test9();
//   test10();
//   test11();
//   test12();
//   test13();
//   test14();
//   test15();
//   test16();
//   test17();
//   test18();
//   test19();
//   test20();
//   test21();
//   test22();
//   test23();
//   test24();
//   test25();
//   test26();
//   test27();
//   test28();
//   test29();
//   test30();
//   test31();
//   test32();
//   test33();
//   test34();
//   test35();
//   test36();
//  Index i = 10000000;
//  test37(i);
//  test38();
//  test39();
//  test40();
//  test41();
//    test42();
//    test43();
//    test44();
    test45();

  return 0;
}
