      IMPLICIT NONE

      INTEGER   I, Nwavln
      REAL      fact, TEMP, WL, WLmin, WLmax
      COMPLEX   REFICE, REFWAT, new

      EXTERNAL  REFICE, REFWAT


c              ** Step across the entire wavelength range covered
c              ** by REFICE using a logarithmic grid

      Nwavln = 1000
      WLmin = 2E-01
      WLmax = 1E+06
      fact = ( WLmax / WLmin )**( 1./(Nwavln-1) )

      TEMP = 240.0
      WRITE(*,'(A)') 
     & 'ICE=['
      DO 10  I = 1, Nwavln
         WL = WLmin * fact**(I-1)
         new = REFICE( WL, TEMP )
         WRITE(*,'(1P,5E15.5)') 1.0E-6*WL, REAL(new), AIMAG(new)
   10 CONTINUE
      WRITE(*,'(A)') 
     & '];'

      TEMP = 280.0
      WRITE(*,'(A)') 
     & 'WATER=['
      DO 20  I = 1, Nwavln
         WL = WLmin * fact**(I-1)
         new = REFWAT( WL, TEMP )
         WRITE(*,'(1P,5E15.5)') 1.0E-6*WL, REAL(new), AIMAG(new)
   20 CONTINUE
      WRITE(*,'(A)') 
     & '];'


      END

