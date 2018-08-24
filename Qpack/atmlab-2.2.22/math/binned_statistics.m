function out = binned_statistics(data_bins, statistics, filter, replace, opt)
%% BINNED_STATISTICS Calculate statistics for a cell array of binned data.
%
% This functions calculates statistics for binned data. data_bins has to
% be a cell array where each cell contains an array of values.
% Each function given in the statistics parameter is called for each
% cell of data_bins. Optionally, a filter function can be passed which is
% applied to the binned data.
%
% FORMAT   out = binned_statistics(data_bins, statistics, filter, replace, opt)
%
% OUT   out          Structure containing the results for each applied
%                    statistics function.
% IN    data_bins    Cell of gridded vectors of data.
%       statistics   Cell array of statistic function references.
%       filter       Function to filter the binned data.  Function is
%                    expected to return a subset of the original data, i.e.
%                    @(X)X(X>0).  May also be cell thereof with multiple.
%       replace      replace empty cells with <replace> (optional argument).
%                         "replace" may also be a cell with as many elements as there are function
%                         handles that you plan to use,
%                         e.g., replace = {[0 0 0],NaN,-9} for 3 suitable
%                         function handles. If "replace" is not a cell, the same
%                         entry will be used for each function handle
% OPT         structure of extra options:
%       opt.dataClass = 'class' (e.g., 'single'); This ensures
%                   that all the data in the cell is your class of choosing
%
% EXAMPLES
% * Calculate number of elements per bin, mean value for each bin:
%   out = binned_statistics(data_bins, {@numel, @mean});
%
% * Calculate mean and standard deviation, ignore all elements smaller
%   than zero by passing the filter criteria as an anonymous function:
%   out = binned_statistics(data_bins, {@mean, @std}, @(x)(x(x>=0)));
%
% NOTE
% * It's recommended to use binning_fast.m to set up the cell array from
%   ungridded data.
%
% See also: bin, binning_fast, bin_nd
%
% modified by Salomon Eliasson
% 2010-07-08 Oliver Lemke

if ~exist('opt', 'var')
    opt = struct();
end

assert(iscell(statistics),['atmlab:' mfilename ':badInput'],'function handles must be in a cell')
if exist('filter','var') && ~isempty(filter)
    assert( isa( filter, 'function_handle' )||iscell(filter),['atmlab:' mfilename ':BadInput'],'filter must be a function handle or cell thereof')
    if iscell(filter)
        for i = 1:length(filter)
            data_bins = cellfun(filter{i}, data_bins, 'UniformOutput', false);
        end
    else
        data_bins = cellfun(filter, data_bins, 'UniformOutput', false);
    end
end

for i = 1:length(statistics)
    try
        A.(func2str(statistics{i}))=0; %#ok<STRNU> % it like a "isvalidfieldname" test
        statname= func2str(statistics{i});
    catch ME
        if strcmp(ME.identifier,'MATLAB:AddField:InvalidFieldName')
            statname = sprintf('statistic%.0f',i);
        else
            ME.rethrow();
        end
    end
    
    out.(statname) = cellfun(statistics{i}, data_bins, 'UniformOutput', false);

end

F = fieldnames(out)';
for i = 1:length(F)
    
    % ---------------
    % assign relace values to empty cells
    if exist('replace','var')
        
        if ~iscell(replace), replace={replace};end
        if length(replace)==1, replace=repmat(replace,1,length(F));end
        
        
        % putting back [] if the input was empty to begin with would be desirable, since e.g. nansum([])=0,
        %
        test =  cellfun('isempty',data_bins) | cellfun('isempty',out.(F{i}));
        if any(test(:)) && ~all(test(:))
            % find a cell that is not empty and check if the class matches the
            % class of the replace value
            x = cellfun(@isempty,data_bins);
            x = data_bins(~x);
            if ~strcmp(class(replace{i}),class(x{1})) && ~isfield(opt,'dataClass')
                warning(['atmlab:' mfilename ':dataClass'],...
                    ['replace  value/s is not the same class as data_bins\n'...
                    'E.g. this means you cannot call cell2mat without an error\n'...
                    'replace value/s is/are class: "%s". data class is: "%s"'],...
                    class(replace{i}),class(data_bins{1,1}))
            end
            out.(F{i})(test)=replace(i);
        elseif all(test(:))
            logtext(atmlab('OUT'),'Data is empty')
        end
    end
    
    % -------------------
    % Make sure all the data is the same class
    if isfield(opt,'dataClass')
        if any(~cellfun(@(x)(strcmp(class(x),opt.dataClass)),out.(F{i})(:)))
            out.(F{i}) = cellfun(@(x)(cast(x,opt.dataClass)), out.(F{i}), 'UniformOutput', false);
        end
    end
end
