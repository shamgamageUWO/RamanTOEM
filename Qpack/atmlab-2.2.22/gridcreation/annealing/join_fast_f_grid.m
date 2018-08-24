function join_fast_f_grid(cpara)
% JOIN_FAST_F_GRID combine the optimized f_grids and weights from
% individual channels to one dataset
%
% join_fast_f_grid: Reads the f_grid from the individual channels
% which should be combined together with the annealing results of
% these channels and combines them to
% one long f_grid with the according weights in a sparse matrix

% FORMAT
%
%   Result=apply_annealing(filename_H,filename_y_mono,nlos,Cloop,C)
%
% IN 
%   cpara a structure with required parameters for the function
%
%    cpara.f_grid_files Cell-array which contains all names
%                       of files with the original frequency grids
%                       of the individual channels. 
%
%    cpara.annealing_result_files Cell-array which contains all names
%                                of files with the Annealing results 
%                                of the individual channels
%
%    cpara.file_f_grid_fast filename where the new reduced
%                           frequency grid shall be written
%
%    cpara.file_Weights filename where the weights for the new
%                           frequencygrid shall be written as
%                           sparse matrix
%
% By Stefan Buehler/Mathias Milz
%

%
disp('Post-processing...')

% Now we have to put together the results for the different
% channels. Far from trivial, unfortunately.

% Collect all frequencies and weights for all channels:
fgf = [];
Wf  = sparse([]);
nchan=length(cpara.f_grid_files)
ncheck=length(cpara.annealing_result_files)
for i=1:nchan
   
    Annealresfile=cpara.annealing_result_files{i};
    load(Annealresfile);
    R=Result;
    channel_f_grid_file=cpara.f_grid_files{i};
    channel_f_grid=xmlLoad(channel_f_grid_file);
    
% What we get back for each channel is a logical vector, with those
% indices that we want to keep set to true.

  % Position of this channel in the total fgf: 
  pos = length(fgf);

  % Get those frequencies and weights for this channel that
  % correspond to active channels: 
  this_f_grid_x = channel_f_grid(R(end).sb)';
  this_Wb_x = R(end).Wb(:,R(end).sb);

  % Check if there are frequencies with weight zero, and remove
  % them.
  this_f_grid = [];
  this_Wb     = [];
  for j=1:length(this_f_grid_x)

    % Get this column of this_Wb:
    tc = this_Wb_x(:,j);

    % Find nonzero elements:
    nz = find(tc);

    if (length(nz)>1)
      error(sprintf('Internal error in zero weight removal loop, length(nz) = %d.',length(nz)))
    end

    % If weight is ok, append to f_grid and Wb:
    if (length(nz)==1)
      this_f_grid = [this_f_grid, this_f_grid_x(j)];
      this_Wb     = [this_Wb,     this_Wb_x(:,j)];
    end

    % If weight is zero, ignore this frequency:
    if (length(nz)==0)
      disp(sprintf(['Ignoring zero weight frequency, number = %d, ' ...
                    'value = %f.'], j, this_f_grid_x(j)));
    end

  end

  fgf = [fgf, this_f_grid];
  Wf(i,pos+1:pos+length(this_f_grid)) = this_Wb;
end

% Now it gets tricky. We have to sort and remove duplicate values
[f_grid_fast, m, n] = unique(fgf);

% f_grid_fast is the sorted frequency grid, with duplicate values
% removed. m and n are such that:
%    f_grid_fast = fgf(m) and fgf = f_grid_fast(n)
% 
% The n is crucial for us, we can use it to construct the new
% weight matrix.

W_fast = sparse(nchan, length(f_grid_fast));
for i=1:length(n)
  % Get this column of Wf:
  tc = Wf(:,i);

  % Find nonzero elements:
  nz = find(tc);

  % There should only be a single nonzero element, since each
  % channel had its own frequency grid.
  if (length(nz)~=1)
    error(sprintf('Internal error, length(nz) = %d.',length(nz)))
  end

  % Check that field is not already occupied (it should never
  % happen, since each channel had its own frequency grid).
  if (W_fast(nz,n(i))~=0)
    error(sprintf('Internal error, weight position (%d,%d) already occupied.',...
                  nz, n(i)));
  end

  % Store the weight in the right place:
  W_fast(nz,n(i)) = tc(nz);

end

disp(sprintf('Removed duplicate frequencies: %d', length(fgf)-length(f_grid_fast)));


% Store frequency grid:
xmlStore(cpara.file_f_grid_fast, f_grid_fast, 'Vector');

% Store weight matrix:  
xmlStore(cpara.file_weights, W_fast, 'Sparse');



  
