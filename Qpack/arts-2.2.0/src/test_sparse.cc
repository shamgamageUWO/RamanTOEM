/* Copyright (C) 2003-2012
   Stefan Buehler <sbuehler@ltu.se>
   Mattias Ekstroem <ekstrom@rss.chalmers.se>

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
  \file   test_sparse.cc
  \author Stefan Buehler <sbuehler@ltu.se>
  \date   Tue Jul 15 15:10:44 2003
  
  \brief  Tests for sparse matrices.
  
  Add more tests here as necessary...
*/

#include <stdexcept>
#include <iostream>
#include "matpackII.h"
#include "xml_io.h"

void test3()
{
  Sparse M(10,15);

  /*
  cout << "M.nrows(), M.ncols() = "
       << M.nrows() << ", " << M.ncols() << "\n";
  */
  for (Index i=3; i<10; ++i)
    M.rw(i,i) = (Numeric)i+1;
  M.rw(0,0) = 1;
  M.rw(0,1) = 2;
  M.rw(0,2) = 3;


  cout << "\nM = \n" << M;

  /*
  // Test Sparse matrix-Matrix multiplication
  Matrix A(10,5);
  Matrix C(15,5,2.0);
  // C = 2;

  mult(A, M, C(Range(joker), Range(joker)));
  cout << "\nA = \n" << A << "\n";

  */

  // Test Sparse-Sparse multiplication
//   Sparse A(10,5);
//   Sparse C(15,5);
//   for (Index i=0; i<5; i++) {
//     C.rw(i*3,i) = i*3+1;
//     C.rw(i*3+1,i) = i*3+2;
//     C.rw(i*3+2,i) = i*3+3;
//   }

//   mult(A,M,C);

//   cout << "\nA = \n" << A;

  /*
  // Test transpose
  Sparse B(15,10);

  transpose(B,M);
  cout << "\nM' = \n" << B;
  */

  /*
  // Test rw-operator
  Sparse S(M);
  S.rw(2,0) = 5;

  cout << "\nS(2,0) = " << S.ro(2,0) << "\n";

  cout << "\nS = \n" << S;
  */

  /*
  // Test vector multiplication
  Vector y(20, 0.0);
  Vector x(1,30,1);

  mult(y[Range(1,10,2)], S, x[Range(1,15,2)]);

  cout << "\ny = \n" << y << "\n";
  */
}


// void test38()
// {
//   cout << "Test sparse matrix - sparse matrix multiplication\n";

//   Sparse B(757,2271);
//   Sparse C(B.ncols(),B.ncols());
//   Sparse A(B.nrows(),B.ncols());

//   Index i=0;
//   for (Index j=0; j<B.ncols(); j++) {
//     B.rw(i,j) = (j+1.0);
//     if( i<B.nrows()-1 )
//       i++;
//     else
//       i=0;
//   }

//   for (Index i=0; i<C.nrows(); i++)
//     C.rw(i,i) = 1;

//   mult(A,B,C);

//   cout << "\n(Sparse) A = \n" << A;
//   cout << "\n(Sparse) B = \n" << B;
//   cout << "\n(Sparse) C = \n" << C;

//   Matrix a(5,15), b(5,15), c(15,15);

//   i=0;
//   for (Index j=0; j<15; j++) {
//     b(i,j) = j+1;
//     if( i<4 )
//       i++;
//     else
//       i=0;
//   }

//   for (Index i=0; i<15; i++)
//     c(i,i) = 1;

//   mult(a,b,c);

//   //cout << "\n(Full) a = \n" << a << "\n";

// //  cout << "\n(Sparse) B = \n" << B << "\n";
// //  cout << "\n(Full) b = \n" << b << "\n";
// //  cout << "\n(Sparse) C = \n" << C << "\n";
// //  cout << "\n(Full) c = \n" << c << "\n";

// }

// void test39() 
// {
//   //Test sparse transpose function
//   Sparse B(1000,2000);
//   Sparse Bt(B.ncols(), B.nrows());

//   Index i=0;
//   for (Index j=0; j<B.ncols(); j=j+2) {
//     B.rw(i,j) = j+1;
//     if( i<B.nrows()-2 )
//       i += 2;
//     else
//       i=0;
//   }

//   cout << "\nB = \n" << B;

//   transpose(Bt,B);

//   cout << "\ntranspose(B) = \n" << Bt << "\n";
// }

void test40() 
{
  cout << "Testing the new simplified Sparse matrices:\n";

  Sparse A(3,3);
  cout << "Empty A: " << A << "\n";

  A.rw(0,0) = 11;
  A.rw(1,1) = 22;
  A.rw(2,2) = 33;
  cout << "Diagonal A:\n" << A << "\n";

  Vector b(1,3,1), c(3);
  cout << "b:\n" << b << "\n";

  mult(c,A,b);
  cout << "c = A*b (should be [11,44,99]):\n" << c << "\n";

  Matrix D(3,2);
  D(joker,0) = b;
  D(joker,1) = b;
  D(joker,1) *= 2;
  cout << "D:\n" << D << "\n";

  Matrix E(3,2);
  mult(E,A,D);
  cout << "E = A*D (should be [11,22],[44,88],[99,198]):\n" << E << "\n";
}

void test41()
{
  cout << "Testing transpose for the new simplified sparse matrices:\n";
  
  Sparse B(4,5);
  Index r[] = {0, 1, 1, 2, 2, 2, 3, 1, 3};
  Index c[] = {0, 0, 1, 1, 2, 3, 3, 4, 4};
  for ( Index i=0; i<9; i++ )
    B.rw(r[i],c[i]) = (Numeric)(i+1);

  cout << "B:\n" << B << "\n";

  Sparse A(5,4);
  
  transpose(A, B);

  cout << "A:\n" << A << "\n";

  cout << "Testing with a fully occupied matrix:\n";

  for ( Index ri=0; ri<4; ri++ )
    for ( Index ci=0; ci<5; ci++ )
      {
        B.rw(ri,ci) = (Numeric)(ri*10+ci);
      }

  cout << "B:\n" << B << "\n";
  transpose(A, B);
  cout << "A:\n" << A << "\n";
}

void test42()
{
  cout << "Testing sparse-sparse matrix multiplication:\n";
  
  Sparse B(4,5);
  Index r[] = {0, 1, 1, 2, 2, 2, 3, 1, 3};
  Index c[] = {0, 0, 1, 1, 2, 3, 3, 4, 4};
  for ( Index i=0; i<9; i++ )
    B.rw(r[i],c[i]) = (Numeric)(i+1);

  Sparse A(4,4), Bt(5,4);
  transpose(Bt,B);
  mult(A,B,Bt);

  cout << "A:\n" << A << "\n";
}

void test43()
{
  cout << "Testing sparse copying:\n";

  Sparse B(4,5);
  Index r[] = {0, 1, 1, 2, 2, 2, 3, 1, 3};
  Index c[] = {0, 0, 1, 1, 2, 3, 3, 4, 4};
  for ( Index i=0; i<9; i++ )
    B.rw(r[i],c[i]) = (Numeric)(i+1);

  cout << "B:\n" << B << "\n";

  Sparse A;

  A = B;

  cout << "A:\n" << A << "\n";

  for ( Index i=0; i<100; ++i )
    {
      B.rw(0,0) += 1;
      A = B;
    }

  cout << "A now:\n" << A << "\n";
}

void test44()
{
  cout << "Test to insert row in sparse:\n";

  Vector v(5,10);

  Sparse B(4,5);
  Index r[] = {0, 1, 1, 2, 2, 2, 3, 1, 3};
  Index c[] = {0, 0, 1, 1, 2, 3, 3, 4, 4};
  for ( Index i=0; i<9; i++ )
    B.rw(r[i],c[i]) = (Numeric)(i+1);

  cout << "B["<<B.nrows()<<","<<B.ncols()<<"]:\n" << B << "\n";
  cout << "v:\n" << v << "\n";

  B.insert_row(3, v);

  cout << "B (after insertion):\n" << B << "\n";
}

void test45()
{
  cout << "Test Sparse-Sparse multiplication reading matrices from xml "
          "files:\n";

  Sparse A, B;
  String a = "antenna.xml";
  String b = "backend.xml";

  try {
    cout << "  Reading " << a << "...";
    xml_read_from_file (a, A, Verbosity());
    cout << "done.\n  Reading " << b << "...";
    xml_read_from_file (b, B, Verbosity());
    cout << "done.\n";
  } catch (runtime_error e) {
    cerr << e.what () << endl;
  }

  Sparse C(B.nrows(),A.ncols());
  cout << "  Performing multiplication...";
  mult(C,B,A);
  cout << "done.\n";

  //cout << "C=A*B:\n" << A << "\n";
  try {
    cout << "  Writing product to file: test45.xml...";
    xml_write_to_file ("test45.xml", C, FILE_TYPE_ASCII, 0, Verbosity());
    cout << "done.\n";
  } catch (runtime_error e) {
    cerr << e.what () << endl;
  }
}

void test46()
{
  cout << "Test transpose with large matrix read from xml file:\n";

  Sparse A;
  String a = "backend.xml";

  try {
    cout << "  Reading " << a << "...";
    xml_read_from_file (a, A, Verbosity());
    cout << "done.\n";
  } catch (runtime_error e) {
    cerr << e.what () << endl;
  }

  //cout << "A:\n" << A << endl;

  Sparse B(A.ncols(), A.nrows());
  transpose(B,A);

  try {
    cout << "  Writing transpose(A) to file test46.xml" << endl;
    xml_write_to_file ("test46.xml", B, FILE_TYPE_ASCII, 0, Verbosity());
  } catch (runtime_error e) {
    cerr << e.what () << endl;
  }

  //cout << "transpose(A):\n" << B << endl;
}

void test47()
{
  cout << "Test make Identity matrix:\n";

  Sparse A;

  A.make_I(6,5);

  cout << "A:\n" << A << endl;
}

void test48()
{
  cout << "Test absolute values of sparse matrix:\n";
  
  Sparse B(4,5);
  Index r[] = {0, 1, 1, 2, 2, 2, 3, 1, 3};
  Index c[] = {0, 0, 1, 1, 2, 3, 3, 4, 4};
  for ( Index i=0; i<9; i++ )
    B.rw(r[i],c[i]) = -(Numeric)i*0.5;
  cout << "B:\n" << B << endl;
      
  Sparse A( B );
  abs(A,B);
  
  cout << "abs(B):\n" << A << endl;
  
}
    
void test49()
{
  cout << "Testing sparse adding:\n";

  Sparse B(4,5);
  Index rb[] = {1, 3};
  Index cb[] = {1, 3};
  for ( Index i=0; i<2; i++ )
    B.rw(rb[i],cb[i]) = (Numeric)(i+1);

  Sparse C(4,5);
  Index rc[] = {0, 1, 2};
  Index cc[] = {0, 1, 2};
  for ( Index i=0; i<3; i++ )
    C.rw(rc[i],cc[i]) = (Numeric)(i+1);

  cout << "B:\n" << B << "\n";
  cout << "C:\n" << C << "\n";

  Sparse A;
  add (A, B, C);
  cout << "A=B+C:\n" << A << "\n";
  Sparse D;
  sub (D, B, C);
  cout << "D=B-C:\n" << D << "\n";
}

int main()
{
  //  test3();
  //  test38();
  //  test39();
  //  test40();
  //  test41();
  //  test42();
  //  test43();
  //  test44();
  //  test45();
  //  test46();
  //  test47();
  //  test48();
  test49();
  
  return 0;
}
