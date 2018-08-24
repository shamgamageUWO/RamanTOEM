Uniform sampling of a sphere

This folder contains functions by Anton Semechko, downloaded from 
the Matlab file exchange central:

http://www.mathworks.com/matlabcentral/fileexchange/37004-uniform-sampling-of-a-sphere

From the web page:

BACKGROUND:

The problem of finding a uniform distribution of points on a
sphere has a relatively long history. Its emergence is commonly
attributed to the physicist named J. J. Thomson, who posed it in
1904 after creating his so-called plum pudding model of the atom
[1]. As such, the problem involves determination of a minimum
energy configuration of N equally charged particles confined to
the surface of the sphere that repel each other with a force
given by Coulomb's law [1]. Although the plum pudding model of
the atom has long been dismissed, the original problem posed by
Thomson has re-emerged across many areas of study and found
practical applications in the fields as diverse as viral
morphology, crystallography, physical chemistry, electrostatics,
geophysics, computer graphics and medical imaging (HARDI).

DESCRIPTION OF THE FUNCTIONS:

The main function is titled 'ParticleSampleSphere' and allows you
to create an approximately uniform triangular tessellation of the
unit radius sphere by minimizing generalized electrostatic
potential energy (aka Reisz s-energy) of the system of charged
particles. Effectively, this function produces a locally optimal
solution to the problem of finding a minimum Reisz s-energy
configuration of N equal charges (s=1 corresponds to the original
Thomson problem). The solution is obtained by iterative
modification of particle positions along the negative gradient of
the energy functional using an adaptive Gauss-Seidel update
scheme. By default, the initializations are based on stratified
sampling of the sphere [3], but user defined initializations are
also permitted. It must be emphasized that in this function, all
energy calculations are based on the geodesic and not Euclidean
distances.

Due to high computational complexity of the problem, it is not
recommended that 'ParticleSampleSphere' be used to solve the
system of more than 1E3 particles. To obtain uniform
tessellations of the sphere composed of more than 1E3 nodes, I
included a function titled 'SubdivideSphericalMesh'. This routine
uses triangular quadrisection to subdivide the input mesh an
arbitrary number of times and automatically re-projects the newly
inserted vertices onto the unit sphere after every iteration. You
can use the following expression to estimate the number of mesh
vertices after k subdivisions

 Nk ~ No*4^k

where No is the original number of vertices.

For convenience, I also included a function titled
'IcosahedronMesh' which generates a triangular mesh of an
icosahedron. High-quality spherical meshes can be easily obtained
by subdividing this base mesh with an aforementioned
'SubdivideSphericalMesh' function. Finally, the function titled
'RandSampleSphere' can be used to obtain random or stratified
sampling of the unit sphere.