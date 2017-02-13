function all_binned_data = coadd2(data, bin_size, bin_from_top)
% all_binned_data = coadd2(data, bin_size, [bin_from_top=True])
% 
% Combines together `bin_size` succesive bins from the list `data`.
%
% If `data` is a matrix, then the adding is performed on
% each column.
%
% If you want to coadd the columns rather than the rows, simlpy do
% coadd2(data',bin_size)' <-- note: inverse of result

if nargin < 3,
    bin_from_top = false;
end

% If the input data is a matrix, then each column will be co-added
% individually
if ismatrix(data)
    [rows, cols] = size(data);
    num_bins = floor(cols/bin_size);
    all_binned_data = zeros(rows,num_bins);
    for i = 1:rows
        all_binned_data(i,:) = coadd_one(data(i,:), bin_size, bin_from_top);
    end
else
    all_binned_data = coadd_one(data, bin_size, bin_from_top);
end




function binned_data = coadd_one(data, bin_size, bin_from_top)

num_bins = floor(length(data)/bin_size);

% reshape(l,n,m) takes a list of numbers (l) and orders them into a n x m matrix

% Bin the list
if bin_from_top
    binned_data = reshape(data(end - (bin_size * num_bins) + 1:end), bin_size, num_bins);
else
    binned_data = reshape(data(1:bin_size * num_bins), bin_size, num_bins);
    
end

% Perform averaging (if reshaped matrix isn't a vector)
%Note from emily: seems like this is summing and not averaging...
if ~(bin_size == 1)
	binned_data = nansum(binned_data);
end

