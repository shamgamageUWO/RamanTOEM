%  Liu_Database extracts the DDA calculations for randomly oriented ice
%  particles with some different shapes which are defined in Liu Database ( Liu, G. (2008) ) 
%  "A DATABASE OF MICROWAVE SINGLE-SCATTERING PROPERTIES FOR NONSPHERICAL ICE PARTICLES. Bulletin of the American Meteorological Society, 89(10), 1563-1570."
%
%  To use this function download and compile the Liu database from http://cirrus.met.fsu.edu/research/scatdb.html                               
%   
%  The rules and limits of using the Database are explaind in the scatdb.c file. 
%  For example the frequency shoud be between 3e9 and 340e9 Hz.
%  
%  The function takes frequency (f), temperature (T), vector of shape id (nshape),
%  vector of maximum diameter (d_max), and returns an array of scattering properties. 
%  
%
% FORMAT   Data =Liu_Database(f,T,nshape,d_max)
%        
% OUT      Data          Array of Liu_DDA single scattering data
%
% IN       f             Frequency                        [Hz]
%          T             Temperature                      [K]
%          nshape        a vector of shape ids which its element should be an
%                        integer number between 0 and 10
%          d_max         a vector of maximum diameters    [um]
%
%History: 2013-12-02  Created by Maryam Jamali



function  Data =Liu_Database(f,T,nshape,d_max)

format shortE
n=length(nshape);
m=length(d_max);

if f < 3e9 || f >340e9
   error('Only frequencies 3e9 < f < 340e9 are allowed.')
end

if T < 233.15 || T >273.15
   error('Only temperatures 233.15 < t_grid < 273.15 are allowed.')
end

for i =1:n
    if ((nshape(i)~=0) && (nshape(i)~=1) && (nshape(i)~=2) && (nshape(i)~=3) && (nshape(i)~=4)...
        && (nshape(i)~=5) && (nshape(i)~=6) && (nshape(i)~=7) && (nshape(i)~=8) && (nshape(i)~=9) ...
        && (nshape(i)~=10) && (nshape(i)~=11) )
       error('Only nshape 0,1,2,3,4,5,6,7,8,9,or 10 are allowed.')
    end
end 


delete ( sprintf('output_Liu.txt') )
shape      =  cell(n);
Data_basic =  zeros(13*m,4,n);

for i=1:n
    if     nshape(i)==0
             shape{i}='long hexagonal column';
    elseif nshape(i)==1
             shape{i}='short hexagonal column';
    elseif nshape(i)==2
             shape{i}='block hexagonal column';
    elseif nshape(i)==3
             shape{i}='thick hexagonal plate';
    elseif nshape(i)==4
             shape{i}='thin hexagonal plate';
    elseif nshape(i)==5
             shape{i}='3-bullet rosette';
    elseif nshape(i)==6
             shape{i}='4-bullet rosette';
    elseif nshape(i)==7
             shape{i}='5-bullet rosette';
    elseif nshape(i)==8
             shape{i}='6-bullet rosette';
    elseif nshape(i)==9
             shape{i}='sector-like snowflake';
    elseif nshape(i)==10
             shape{i}='dendrite snowflake';
    end
        
      for j= 1: length (d_max)
          unix ( sprintf('./rddb -f %-3.3f -t %-3.3f -s %1.0f -d %d >>output_Liu.txt', f/1e9, T, nshape(i), d_max(j) ) )
      end
    
    Data_basic(:,:,i) = importdata ( sprintf('output_Liu.txt') );
    delete(sprintf('output_Liu.txt') )

end


Data=cell(1,n);

for  i = 1:n
    
    Data{1,i}.pshape            =  shape{i};
    Data{1,i}.frequency         =  f;
    Data{1,i}.abs_cross(:,1)    =  Data_basic(2:13:end-11,1,i);
    Data{1,i}.sca_cross(:,1)    =  Data_basic(2:13:end-11,2,i);
    Data{1,i}.bac_cross(:,1)    =  Data_basic(2:13:end-11,3,i);
    Data{1,i}.g(:,1)            =  Data_basic(2:13:end-11,4,i);
    Data{1,i}.d_e(:,1)          =  Data_basic(3:13:end-10,1,i);
    Data{1,i}.d_max(:,1)        =  Data_basic(1:13:end-12,4,i);
    Data{1,i}.control(:,1)      =  Data_basic(3:13:end-10,2,i);
    
end

                                
