%Author: Ali Faisal
%Dated: 26th Dec. 2014

function [ accuracy, result ] = crossValidateLeave2Out_fft_parallel( brainData, spectrogram, start_idx, end_idx, JOB_PATH,norm_ver)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here  

JOB_PATH1 = sprintf('%s/job_index1.csv',JOB_PATH);
JOB_PATH2 = sprintf('%s/job_index2.csv',JOB_PATH);
job_index1 = csvread(JOB_PATH1);
job_index2 = csvread(JOB_PATH2);
totalJobs = length(job_index1);
n_dataPts = size(brainData,1);

completeExamples = reshape(brainData,size(brainData,1),size(brainData,2)*size(brainData,3));
completeExamples = myzscore(completeExamples);
completeTargets = myzscore(spectrogram);

%fprintf('The data sizes are: \n');
%size(completeExamples)
%size(completeTargets)

result = zeros(1,end_idx-start_idx+1);
%result_file = sprintf('%s/acc_%dto%d_%s.csv',JOB_PATH, start_idx, end_idx,norm_ver);
result_file = sprintf('%s/acc_%dto%d_%s_PCA.csv',JOB_PATH, start_idx, end_idx,norm_ver);
for i = start_idx:end_idx
    %fprintf('\njob: %d / %d',i,totalJobs);
       
    % Leave out the two Audios from training and test examples
    % Get the two test examples and get the two test Audio
    trainingExamples = completeExamples;
    trainingTargets = completeTargets;
    trainingExamples([job_index1(i),job_index2(i)],:) = [];
    trainingTargets([job_index1(i),job_index2(i)],:) = [];
    
    testBrainData1 = completeExamples([job_index1(i)],:);
    testBrainData2 = completeExamples([job_index2(i)],:);
    testSpect1 = completeTargets([job_index1(i)],:);
    testSpect2 = completeTargets([job_index2(i)],:);

    %tic
    [targetSpect1, targetSpect2] = ...
        getTargetEstimates(trainingExamples, trainingTargets, testBrainData1, testBrainData2);
    
    clear trainingExamples trainingTargets testBrainData1 testBrainData2
    
    [ correct ] = scoreLeave2Out(targetSpect1, targetSpect2, testSpect1, testSpect2);

    clear targetSpect1 targetSpect2 testSpect1 testSpect2
   % toc
    
    result(i) = correct;
 %   fprintf('\n%d',correct)
    %fprintf(' the accuracy over %d tests is: %f', iter, sum(result)/iter * 100)
    dlmwrite(result_file,correct,'-append');
end

iter = end_idx-start_idx+1;
accuracy = sum(result)/iter * 100;

end



function [targetSpect1, targetSpect2] = ...
    getTargetEstimates(trainingExamples, trainingTargets, testBrainData1, testBrainData2)

[ weightMatrix, ~] = regKernelLinReg(trainingExamples, trainingTargets);

testBrainData1(:,end+1) = 1;
testBrainData2(:,end+1) = 1;
        
targetSpect1 = testBrainData1*weightMatrix;
targetSpect2 = testBrainData2*weightMatrix;

end
