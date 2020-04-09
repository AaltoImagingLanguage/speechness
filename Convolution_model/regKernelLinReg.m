function [weightMatrixFinal, minerr,selected_param] = regKernelLinReg(trainingData, trainingTargets)
% (c) Ali Faisal

% Usage: [weightMatrix, minerr] =
% regKernelLinearRegressionSeparateLambda(trainingData, trainingTargets, fCrossValidate)
%
% Set fCrossValidate to true to test different regularization params.
% trainingData is examples x features and trainingTargets is examples x
% targets.
% 
% This function uses kernel ridge regression with a linear kernel. This allows us to use the full
% brain as input features because we avoid the large inversion of the
% voxels/voxels matrix. It also uses the Hastie trick to do fast cross
% validation with several lambdas. This function is almost an exact copy of
% Mark's learn_text_from_fmri_kernel.m, except that it doesn't use sparse
% identity matrices, which allows the code to handle single precision data
% (like MEG), and run faster this way (i.e. it runs faster with singles than
% doubles).
%
% Original code by Mark Palatucci, then modified by Alona Fyshe to
% calculate the lambdas independently for each target, and the modified by
% Gus Sudre to add more comments based on the papers where we read this
% stuff, not use sparse matrices, allocate memory for weight matrix so
% it goes a bit faster, and re-named a few variables

% append a vector of ones so we can learn weights and biases together
%  tic
trainingData(:,end+1) = 1; 

params = [.0000001 .000001 .00001 .0001 .001 .01 .1 .5 1 5 10 50 100 500 1000 10000 20000 50000 ...
    100000 500000 1000000 5000000 10000000];
%params = [.00001 .0001 .001 .01 .1  1 10 100 1000 10000];
%params = [1];
n_params = length(params);
n_targs = size(trainingTargets,2);
n_features = size(trainingData,2);
n_examples = size(trainingData,1);

CVerr = zeros(2, n_targs);
minerr = zeros(1,n_targs);
selected_param = zeros(1,n_targs);
weightMatrixFinal = zeros(n_features, n_targs);

% If we do an eigendecomp first we can quickly compute the inverse for
% many different values of lambda. SVD uses X = UDV' form. First
% compute K0 = (XX' + lambda*I) where lambda = 0.
[obs feat] = size(trainingData);
if(obs < feat)
  kernelReg = 1;
else
  kernelReg = 0;
end

if(kernelReg)
  K0 = trainingData*trainingData';
else
  K0 = trainingData'*trainingData;
end
  
[U,D,V] = svd(K0);

% try all possible lambdas (see list above) and save the
% mean-square-error of the given lambda for all targets
for i = 1:n_params
    regularizationParam = params(i);
    
    % Now we can obtain Kinv for any lambda doing Kinv = V * (D +
    % lambda*I)^-1 U'
    dlambda = D + regularizationParam*eye(size(D));
    dlambdaInv = diag(1 ./ diag(dlambda));
    KlambdaInv = V * dlambdaInv * U';
    
    % Compute pseudoinverse of linear kernel.
    if(kernelReg)
      KP = trainingData' * KlambdaInv;
    else
      KP = KlambdaInv * trainingData';
    end
    
    % Compute S matrix of Hastie Trick X*KP
    S = trainingData * KP;
    
    % Solve for weight matrix so we can compute residual
    weightMatrix = KP * trainingTargets;
    
    % This is the same formula (Guyon, 2005) uses to compute the MSE of
    % leave-one-out, except that here we're calling XX+ = S
    Snorm = repmat(1 - diag(S), 1, n_targs);
    YdiffMat = (trainingTargets - (trainingData*weightMatrix));
    YdiffMat = YdiffMat ./ Snorm;
    CVerr(2,:) = (1/n_examples).*sum(YdiffMat .* YdiffMat);
    
    if i == 1
        % For the first iteration weight matrix is same as estimated
        weightMatrixFinal = weightMatrix;
        minerr = CVerr(2,:);
        selected_param = repmat(params(i),size(selected_param));
    else
        for j = 1:n_targs
            if CVerr(2,j) < CVerr(1,j)
                % If its better replace the weight matrix
                % For each target, use the lambda with minimum error
                weightMatrixFinal(:,j) = weightMatrix(:,j);
                minerr(j) = CVerr(2,j);
                selected_param(1,j) = i;
            else
                CVerr(2,j) = CVerr(1,j);
            end
        end
    end
    CVerr(1,:) = CVerr(2,:);
end

%minerr
%display(selected_param(1:10))
%  toc
end


