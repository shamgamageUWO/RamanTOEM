% ASG_CROP  crop the data in G
%
%          asg_crop just simply cut out the data
%          in G inside the specified limits
%
% FORMAT   G=asg_crop( G, LIMITS, DIMS)
% 
% IN        
%          G        original gformat data             
%          LIMITS   a two column matrix
%                   specifying limits.
%                   The first row corresponds
%                   to the dimension specified
%                   in DIMS(1)
%          DIMS     a vector with dimensions                   
%
% example usage:
% LIMITS(1,1:2)=[10e3 18e3];
% LIMITS(2,1:2)=[2 4];
% DIMS(1)=1;DIMS(2)=2;
% grid=[-1:0.1:1];
% F=asg_crop(D,G,LIMITS,DIMS);    
%
%  2007-11-13 created by Bengt Rydberg

function [G]=asg_crop(G,LIMITS,DIMS);


if size(LIMITS,2)~=2
   error('LIMITS must be a 2 column matrix or a row vector of length 2') 
end

if ~isvector(DIMS)
   error('DIMS must be a vector')
end

if length(DIMS)~=size(LIMITS,1)
   error('mismatch in size of DIMS and LIMITS')
end

for i=1:length(G)
  for j=1:length(DIMS)
      gname = sprintf( 'GRID%d', DIMS(j) );
      if ~isempty(G(i).(gname))
	ind=find(G(i).(gname)>=LIMITS(j,1) & G(i).(gname)<=LIMITS(j,2));
        if isempty(ind)
	   error('no data exist inside the specified limits')
        else
           G(i).(gname)=G(i).(gname)(ind);
           %shift the data so the first dimension holds 
           %the data of interest
           data_dim=dimens(G(i).DATA);
           old_dim=DIMS(j);
           data=G(i).DATA;
           if isvector(data)
	     data=vec2col(data);
           end
           data=shiftdim(G(i).DATA,old_dim-1);
           data=data(ind,:,:,:,:,:,:,:,:,:,:);        
           %shift back
           data=shiftdim(data,data_dim-old_dim+1);
           G(i).DATA=data;
        end
      end
  end
end


         
