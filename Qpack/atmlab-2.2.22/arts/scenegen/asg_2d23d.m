%ASG_2D23D  expand 2-dimensional Gformat data into
%           3-dimensional data using an Iterative
%           Amplitude Adapted Fourier Transform (IAAFT)
%           algorithm.
% 
%
%OUT  G   Modified Gformat data
%    
%IN  
%     G   ASG data.
%     Q   Qarts setting structure
%         Only Q.SENSOR_LOS and Q.SENSOR_POS are considered
%

% 2007-12-04   Created by Bengt Rydberg

function G = asg_2d23d( G, Q );

X.p_grid=G.GRID1;
X.lat_grid=G.GRID2;
X.data=G.DATA;

%the function reguires the input matrix to be of even size
if isodd(length(X.lat_grid))
  X.data=X.data(:,1:end-1);
  X.lat_grid=X.lat_grid(1:end-1);
end
if isodd(length(X.p_grid))
  X.data=X.data(1:end-1,:);
  X.p_grid=X.p_grid(1:end-1);
end

%now prepare data for surrogate_2d_3d

template=X.data;
[no_values_y, no_values_x] = size(template); 
x = 1:no_values_x;
y = 1:no_values_y;
mean_pdf_profile = squeeze(mean(template, 2));

% Make sorted vector.
template = remove_average_profile(template, mean_pdf_profile);
sorted_values_prof = sort(template, 2);
sorted_values_prof = sorted_values_prof';
total_variance_pdf = std(sorted_values_prof(:)).^2;
    
% Calculate Fourier coeffients and scale them.
fourier_coeff_2d = abs(ifft2( template ));
power = fourier_coeff_2d.^2;
total_variance_spec = sum(sum(power));
power = power * total_variance_pdf / total_variance_spec;
fourier_coeff_2d = sqrt(power');

surrogate_2d_3d


[i1,i2,i3]=size(surrogate);
%rearrange the data grid
P=zeros(i3,i1,i2);
for i=1:i1
  for j=1:i2
     P(:,i,j)=surrogate(i,j,:);  
 end
end

Y.p_grid=X.p_grid;
Y.lat_grid=X.lat_grid;
%dlat=abs(X.lat_grid(end)-X.lat_grid(1));
%Y.lon_grid=linspace(-dlat/2,dlat/2,length(X.lat_grid));
Y.data=P;

data=zeros([size(G.DATA) size(G.DATA,2)]);

%if the size of the input matrix was odd 
%fill out the last elements with the same values
%as the neighbouring
ilen=1:length(Y.p_grid);

if isodd(length(G.GRID2))
  data(ilen,1:end-1,1:end-1)=Y.data;
  data(ilen,1:end-1,end)=Y.data(ilen,:,end);
  data(ilen,end,1:end-1)=Y.data(ilen,end,:);
  data(ilen,end,end)=Y.data(ilen,end,end);
  Y.data=data;
end

if isodd(length(G.GRID1))
  data(end,:,:)=Y.data(end-1,:,:);
  Y.data=data;
end

%the data is now on a lon_grid corresponding to our lat_grid
%we want to have it on Q.LON_GRID, so we bin it on this grid
G.DATA=Y.data;
G.GRID3=G.GRID2-mean(G.GRID2);
G.DIM=3;
m1=mean(Q.LON_GRID);
GRIDS{1}=Q.LON_GRID-m1;
DIMS=3;

%round off the grids not to have any problems 
G.GRID3=round(G.GRID3*1e6)/1e6;
GRIDS{1}=round(GRIDS{1}*1e6)/1e6;
G=asg_bin( G, GRIDS , DIMS);
G.GRID3=G.GRID3+m1;
