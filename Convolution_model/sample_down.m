function [brainDataS, spectrogramS] = sample_down(brainData, spectrogram, T0, spectrogram_downsampled)
%   Sample down Data and spectrogram by T0 ms
%   brainData is of form STIMULI X TIME X VOXELS
%   element of spectrogram cell is of form TIME X FREQUENCY
%   spectrogram_downsampled (set to False to perform downsampling also for spectrogram otherwise it is assumed that spectrogram is already downsampled)

timepts = size(brainData,2);
if mod(timepts,2) == 1
  brainData(:,timepts,:)=[];
end
brainDataS = zeros(size(brainData,1), size(brainData,2)/T0, size(brainData,3));
spectrogramS = cell(size(spectrogram));

n_dataPts = size(brainData,1); %length(spectrogram);
nT = size(brainData,2)/T0; % New number of time points

% Sample down brain data
for i = 1:nT
    idx = 1 + (i-1)*T0;
    avg = zeros(size(brainData(:,1,:)));
    for j = 1:T0
        avg = avg + brainData(:,idx+j-1,:);
    end
    brainDataS(:,i,:) = avg/T0;
end

if ~spectrogram_downsampled
	% sample down spectrogram
	for i = 1:n_dataPts
	    sp = spectrogram{i};
	    % trim down all time points after maximum time points in MEG recording
	    if size(sp,1) > size(brainData,2)
		sp([size(brainData,2)+1:end],:) = [];
	    end
	   
	    if mod(size(sp,1),T0) == 0
		sp_new = zeros(size(sp,1)/T0, size(sp,2));
	    else
		sp_new = zeros(floor(size(sp,1)/T0)+1, size(sp,2));
	    end
	    
	    nT = floor(size(sp,1)/T0);
	    nT_residue = mod(size(sp,1),T0);
	    for j = 1:nT
		idx = 1 + (j-1)*T0;
		avg = zeros(size(sp(1,:)));
		for k = 1:T0
		    avg = avg + sp(idx+k-1,:);
		end
		sp_new(j,:) = avg/T0;
	    end
	    
	    if nT_residue ~= 0
		avg = zeros(size(sp(1,:)));
		idx = 1 + nT*T0;
		for j = 1:nT_residue
		    avg = avg + sp(idx+j-1,:);
		end
		sp_new(end,:) = avg/nT_residue;
	    end
	    
	    spectrogramS{i} = sp_new;
	end
else
	for i = 1:n_dataPts
	    sp = spectrogram{i};
	    % trim down all time points after maximum time points in MEG recording because otherwise in convolution model it is technically not possible to perform the decoding - Note In semspeech project this was only used in testing convolution modeling on 1sec. MEG data, in the actual results we used 2 sec. of MEG data and since all spectrograms are less than 2sec. this if loop is never called.
	    if size(sp,1) > size(brainDataS,2)
		sp([size(brainDataS,2)+1:end],:) = [];
	    end
	    spectrogramS{i} = sp;
        end
end

end

