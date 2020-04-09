function [ accuracy ] = crossValidateLeave2Out_featureScore( brainData, spectrogram, start_idx, end_idx, JOB_PATH )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here  

JOB_PATH1 = sprintf('%s/job_index1.csv',JOB_PATH);
JOB_PATH2 = sprintf('%s/job_index2.csv',JOB_PATH);
job_index1 = csvread(JOB_PATH1);
job_index2 = csvread(JOB_PATH2);
totalJobs = length(job_index1);
n_dataPts = length(brainData);

nT = 0;
for i = 1:n_dataPts
    nT = nT + size(brainData{i},1);
end

completeExamples = zeros(nT,size(brainData{1},2));
completeTargets = zeros(nT,size(spectrogram{1},2));
audioIdx = cell(1,n_dataPts); % Stores time index-range of data point

result = zeros(1,end_idx-start_idx+1);
result_file = sprintf('%s/acc_%dto%d.csv',JOB_PATH, start_idx, end_idx);

iter = 0;
for i = 1:n_dataPts
    nT = size(brainData{i},1);
    completeExamples([iter+1:iter+nT],:) = brainData{i};
    completeTargets([iter+1:iter+nT],:) = spectrogram{i};
    audioIdx{i} = [iter+1, iter+nT];    
    iter = iter+nT;
end
clear brainData sectrogram
iter = 0;

completeExamples = myzscore(completeExamples);
completeTargets = myzscore(completeTargets);

fprintf('The data sizes are: \n');
size(completeExamples)
size(completeTargets)

maxfreq = size(spectrogram{1},2)
b=[];
for i = 1:length(spectrogram); b = [b size(spectrogram{i},1)]; end
b = max(b);
numJobs = end_idx-start_idx+1;
targets = single(repmat(NaN, numJobs*2,size(completeTargets,2)*max(b)));
predictions = single(repmat(NaN,numJobs*2,size(completeTargets,2)*max(b))); %200 tests-folds X 20480 features (20480 = 128 freq @ 160 points)
totfeat = b*maxfreq;

j=1;
for i = start_idx:end_idx
%    fprintf('\njob: %d / %d',i,totalJobs);
       
    % Leave out the two Audios from training and test examples
    % Get the two test examples and get the two test Audio
    [trainingExamples, trainingTargets, testBrainData1, testBrainData2, testSpect1, testSpect2] = ...
        createTrainDataMatrix(completeExamples, completeTargets, job_index1(i), job_index2(i), audioIdx);
    
 %   tic
    [targetSpect1, targetSpect2] = ...
        getTargetEstimates(trainingExamples, trainingTargets, testBrainData1, testBrainData2);
    
    clear trainingExamples trainingTargets testBrainData1 testBrainData2
    
    [ correct ] = scoreLeave2Out_2(targetSpect1, targetSpect2, testSpect1, testSpect2);
    
    
    predictions(j,:) = reshape([targetSpect1; repmat(NaN, length(size(targetSpect1,1)+1:max(b)), maxfreq)], 1, totfeat);
    predictions(j+1,:) = reshape([targetSpect2; repmat(NaN, length(size(targetSpect2,1)+1:max(b)), maxfreq)], 1, totfeat);
    targets(j,:) = reshape([testSpect1; repmat(NaN, length(size(testSpect1,1)+1:max(b)), maxfreq)], 1, totfeat);
    targets(j+1,:) = reshape([testSpect2; repmat(NaN, length(size(testSpect2,1)+1:max(b)), maxfreq)], 1, totfeat);

    j=j+2;
     
    clear targetSpect1 targetSpect2 testSpect1 testSpect2
  %  toc
    
    iter = iter+1;
    result(iter) = correct;
%correct
    fprintf('\nthe accuracy over %d tests is: %f', iter, sum(result)/iter * 100)
    %dlmwrite(result_file,correct,'-append');
end

accuracy = sum(result)/iter * 100;
save([num2str(start_idx) '.mat'], 'targets','predictions');

end

function [targetSpect1, targetSpect2] = ...
    getTargetEstimates(trainingExamples, trainingTargets, testBrainData1, testBrainData2)

[ weightMatrix, ~] = regKernelLinReg(trainingExamples, trainingTargets);

testBrainData1(:,end+1) = 1;
testBrainData2(:,end+1) = 1;
        
targetSpect1 = testBrainData1*weightMatrix;
targetSpect2 = testBrainData2*weightMatrix;

end

function [trainingExamples, trainingTargets, testBrainData1, testBrainData2, testSpect1, testSpect2] = ...
    createTrainDataMatrix(completeExamples, completeTargets, idx1, idx2, audioIdx)
%Takes out the two test audios
trainingExamples = completeExamples;
trainingTargets = completeTargets;

i = audioIdx{idx1};
testBrainData1 = completeExamples([i(1):i(2)],:);
testSpect1 = completeTargets([i(1):i(2)],:);

j = audioIdx{idx2};
testBrainData2 = completeExamples([j(1):j(2)],:);
testSpect2 = completeTargets([j(1):j(2)],:);

trainingExamples([i(1):i(2),j(1):j(2)],:) = [];
trainingTargets([i(1):i(2),j(1):j(2)],:) = [];

len1 = size(testBrainData1,1);
len2 = size(testBrainData2,1);

  if(len2 < len1)
    testBrainData1(len2+1:len1,:) = [];
    testSpect1(len2+1:len1,:) = [];
  elseif(len1 < len2)
    testBrainData2(len1+1:len2,:) = [];
    testSpect2(len1+1:len2,:) = [];
  end


end
