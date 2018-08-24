function annot_format = getAnnotFormat(quantity)
%% getAnnotFormat
% Guess a reasonable annotation format for gmtlab based on the provided quantity.
% in.tick_annotation_format overrides this function. 
%
% IN     quantity          (scalar or a vector)
% OUT    annot_format      string to be used in e.g. fprintf
%
% EXAMPLE  >> getAnnotFormat(0.00358)
%          
%          ans =
%
%          '%.3f'
%               
% Created by Salomon Eliasson

assert(nargin==1,['gmtlab:' mfilename ':badInput'],...
    'USAGE: annot_format = getAnnotFormat(quantity)')

% if quantity ~= 0
%     sz = floor(log10(abs(quantity)));
% end

% doesn't matter if the value is possitive or negative
quantity = abs(quantity); 

cond1 = quantity == 0;
cond2 = ceil(log10(quantity)) == 0;
cond3 = quantity - floor(quantity) == 0;



if cond1
    annot_format = '%.0f';
elseif cond2 && cond3
    annot_format = '%1.0f';
    
elseif cond2
    annot_format = sprintf('%%1.%if',...
        min(abs(floor(log10(quantity - floor(quantity))))));
    
elseif cond3
    annot_format = sprintf('%%%i.0f',...
        min(abs(ceil(log10(quantity)))));
    
else
    
    annot_format = sprintf('%%%i.%if',...
        min(abs(ceil(log10(quantity)))),...
        min(abs(floor(log10(quantity - floor(quantity))))));
end