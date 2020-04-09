function [ dataC ] = preprocess_data_taucorrected_2sec_laggedlag( data, features, tau, lagged )
%   PRE-PROCESS DATA to the form for applying Kernel-Ridge regression
%   dataP is processed data
%   N = data points, T = time points, nV = no of voxels, tau = time lag and F = no of requency bands
%   features is 1 x N cell of T x F
%   dataP is is 1 x N cell where each cell is T x (nV)tau
%   T is differnet for each data point, the idea is to take trim of excess
%   of time points from MEG recordings

%-------------------------VARIABLE INTITIALIZATION----------------------%
[n_dataPts, ~, n_voxels] = size(data);
[n_dataPtsF] = length(features);

% Insert ASSERTION that data points in features (spectrogram) is same
% as that in MEG data
% assert(n_dataPts == n_dataPtsF);
tau=tau-1;
lagged = lagged-2;
% dataP = zeros(n_dataPts*n_timePts, (tau+1)*n_voxels);
% featuresP = zeros(n_dataPts*n_timePts, nF);
dataP = cell(1,n_dataPts);
dataC = cell(1,n_dataPts);
%------------------------------------------------------------------------%

%--------------------------PROCESS THE DATA POINTS-----------------------%
for i = 1:n_dataPts
    n_timePts = size(features{i},1);
%      dataPt = data(i,:,:);
%      % Permuted data point to the form Voxel X Time
%      dataPt = permute(dataPt,[3,2,1]);
%      
%      
%      % trim the time points in MEG data if they are in excess
%      if n_timePts < size(dataPt,2) 
%          dataPt(:,[n_timePts+1:end]) = [];
%      end
%      
%      % the i-th entry of dataP cell
%      dataPt_p = zeros(n_timePts, (tau+1)*n_voxels);
%      
%      iter1 = 0;
%      for j = 1:n_timePts
%          iter1 = iter1+1;
%          for k = 1:n_voxels
%              % The data point in processed matrix will be as follows:
%              % [R(1,t) R(1,t-1).....R(1,t-tau)....R(n,t) R(n,t-1).....R(n,t-tau)]
%              % where t corresponds to time point (j here)
%              % This is done for each time point of each data point
%              iter2 = (k-1)*(tau+1) + 1;
%              if (j - tau) <= 0
%                  X = fliplr(dataPt(k,[1:j]));
%                  Y = zeros(1,tau+1-j);
%                  dataPt_p(iter1,[iter2:(iter2+tau)]) = [X,Y];
%              else
%                  X = fliplr(dataPt(k,[(j-tau):j]));
%                  dataPt_p(iter1,[iter2:(iter2+tau)]) = X;   
%              end % endif
%          end % end voxels
%      end % end timePts
%      dataP{i} = dataPt_p;
%      
    dataCausal = data(i,:,:);
    dataCausal = permute(dataCausal, [3,2,1]);
    n_timePts = size(features{i}, 1);
    %dataCausal_p = zeros(n_timePts, ((2*tau)+1)*n_voxels);
    dataCausal_p = zeros(n_timePts, (tau+1-lagged)*n_voxels);
    iter1 = 0;	
    for j = 1:n_timePts
      iter1 = iter1+1;
      for k = 1:n_voxels
	  %The data points in processed matrix will be as follows:
	  %[ R(1,t), R(1, t+1)...R(1,t+tau)... R(k,t), R(k,t+1).... R(k, t+tau)]
	  %where t corresponds to time points (j here) and k are the voxels
	  iter2 = (k-1)*(tau+1-lagged) + 1;
	  if (j + tau + 1) <= size(dataCausal,2)
	    %X = dataCausal(k,[j:j+tau]);
	    X = dataCausal(k,[j+lagged:j+tau]);      
	    %dataCausal_p(iter1, [iter2:(iter2+tau)]) = X;
	    dataCausal_p(iter1, [iter2:(iter2+tau-lagged)]) = X;
	  else
	    X = dataCausal(k,[j+lagged:size(dataCausal,2)]);
	    Y = zeros(1,(tau+1-lagged)-length(X));
	    dataCausal_p(iter1, [iter2:(iter2+tau-lagged)]) = [X,Y];
	  end %end if
      end %end voxels
    end %end timePts
    dataC{i} = dataCausal_p;
end % end dataPts
%------------------------------------------------------------------------%

end

