% Function to map the sidebands of the combined MARSS,Deimos and ISMAR 
% channel definition to the specific channel. To use this funtion each 
% sideband has to be use within the arts simulation with each sideband used 
% once.
%
%   Input:
%       T_bf, the quantity that should be mapped. The dimensions of T_bf
%       doesn't matter as least the first dimension is the frequency
%       dimension.
%   
%   Output:
%       T_bch, the input quantity mapped to the channels
%       ChannelDef, the combined channel definition of MARSS,Deimos and 
%       ISMAR 
%
%   30.9.2014, Manfred Brath

function [T_bch,ChannelDef]=ismar_freq2ch_simple(T_bf)



% ISMAR channel definition
ChannelDef=[  23.80e9, 0.07e9;
              50.10e9, 0.08e9;
              89.00e9, 1.10e9;
             118.75e9, 1.10e9;
             118.75e9, 1.50e9;
             118.75e9, 2.10e9;
             118.75e9, 3.00e9;
             118.75e9, 5.00e9;
             157.05e9, 2.60e9;
             183.31e9, 1.00e9;
             183.31e9, 3.00e9;
             183.31e9, 7.00e9;
             243.20e9, 2.50e9;
             325.15e9, 1.50e9;
             325.15e9, 3.50e9;
             325.15e9, 9.50e9;
             424.70e9, 1.00e9;
             424.70e9, 1.50e9;
             424.70e9, 4.00e9;
             448.00e9, 1.40e9;
             448.00e9, 3.00e9;
             448.00e9, 7.20e9;
             664.00e9, 4.20e9;
             874.40e9, 6.00e9]; 


%build up frequencies
temp1=ChannelDef(:,1)+ChannelDef(:,2);
temp2=ChannelDef(:,1)-ChannelDef(:,2);
[~,~,iF]=unique([temp1;temp2]);

iF=reshape(iF,[size(ChannelDef,1),2]);


if nargin<1
    T_bch=[];
else

    if numel(iF)~=size(T_bf)
        error(['amtlab:' mfilename],'Wrong Dimension or wrong number of frequencies')
    end
    
    %Get size of input quantity
    qT=size(T_bf);

    %allocate matrix
    T_bch=nan([size(ChannelDef,1),qT(2:end)]);

    % Map T_b to channels
    for i=1:size(iF,1)   

        T_bch(i,:,:,:)=(T_bf(iF(i,1),:,:,:)+T_bf(iF(i,2),:,:,:))/2;

    end
end

