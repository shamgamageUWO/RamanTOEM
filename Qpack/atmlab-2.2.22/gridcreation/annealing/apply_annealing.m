function result=apply_annealing(filename_H,filename_y_mono,nlos,Cloop,C)
% APPLY_ANNEALING control the simulated annealing for an individual channel
%
% apply_annealing reads the required input from xml files (ARTS
% output), and uses the provided accuracy to initiate the loop to
% obtain the simulated annealing grid. The loop continues until the
% desired accuracy is reached. This run should be applied for each
% individual channel
%
% FORMAT
%
%   Result=apply_annealing(filename_H,filename_y_mono,nlos,Cloop,C)
%
% IN
%        filename_H:      File containing the H matrix (ARTS-xml)
%
%        filename_y_mono: File containing the ARTS monochromatic
%                         radiances on a fine frequency grid for
%                         nspec atmospheric states (ARTS-xml)
%
%        nlos:            number of geometries used to calculate
%                         the spectra 
%
%        Cloop:           Structure containing parameters
%                         controling the iteration loops during the
%                         annealing procedure
%
%        Cloop.accuracy:  desired accuray for the iterative
%                         annealing result. (obligatory)
%        Cloop.n_start:   The initial minimum number of frequencies
%                         for the annealing frequency grid. (You
%                         should take at least one per channel.)
%                         (OPTIONAL: Default=1) 
%   
%        Cloop.n_incr     Increment n in each iteration by which
%                         the number of annealing frequencies is
%                         increased. (OPTIONAL: Default=1)
%  
%        Cann:            (Optional) control-parameters for the
%                         actual annealing algorithm 
%                         (see function find_best_freq_set_anneal)
% OUT
%
%       result            An array of n-iter structures. Each
%                         structure has elements:
%                         sb = Solution as a logical array
%                              (selected gridpoints).
%                         Wb = Associated weight matrix.
%                         eb = Associated error.
%                         h  = Structure with the history of the
%                              annealing 
%
% By Stefan Buehler/Mathias Milz
%
% Default contol options
Cloopdef = struct(...
    'n_start', 1, ...          % The starting number of frequencies.
    'n_incr',  1 ...          % increment.
    );
% User gave control structure, check which elements are present.
  if ~isstruct(Cloop)
    error('Input argument ''Cloop'' is not a structure.')
  end
  if ~isfield(Cloop,'accuracy')
    error('Structure ''Cloop'' has to contain the element accuracy!')
  end
  fs = {'n_start', 'n_incr'};
  for nm=1:length(fs)
    if ~isfield(Cloop,fs{nm})
      Cloop.(fs{nm}) = Cloopdef.(fs{nm}); 
    end
  end

% read H matrix
H=xmlLoad(filename_H);
% read monochromatic spectra
y_mono_array=xmlLoad(filename_y_mono);
% use absolute error
% C.use_rel_error=false;
nspec=length(y_mono_array);
ngrid=length(y_mono_array{1})/nlos;
ngridH=length(H);
% Do matrix dimenaions agree?
if (ngridH ~= ngrid) 
    error('Gridsize of ''H'' and spectra do not agree, check input');
end
% Reformat spectra
y_mono=zeros(ngrid,nspec*nlos);
for ii=1:nspec
    for ilos=1:nlos
       % tmp=nlos*(ii-1)+ilos
        y_mono(:,(nlos*(ii-1))+ilos)=[y_mono_array{ii}((ilos-1)*ngrid+1:ilos*ngrid)];
    end
end
%call Annealing
Cgiven=exist ('Cann');
if (Cgiven==1)
    result=loop_anneal(H,y_mono,Cloop.n_start,Cloop.n_incr,Cloop.accuracy,Cann);
else
% use default settings for Cann
  result=loop_anneal(H,y_mono,Cloop.n_start,Cloop.n_incr,Cloop.accuracy);
end