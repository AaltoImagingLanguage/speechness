%Ali Faisal 
%Last updated: 31st May 2015

%Compute predictions using ALL time points in MEG Speech data (0 to 1000ms - to change this see "windStrt" and "windEnd" below)

%OUTPUT: The output is printed on console, the first set of accuracies are mean predictions across all items, 
%while the second set of accuracies are within speaker i.e. across category predcitions and this latter set 
%is more relevant as it removes speaker bias, details on how the speaker bias is removed are on the Aalto 
%project wiki, there is also an optional third set of poutput that will output speaker-prediction results if 
%"predict_speaker" is set to 1.

%norm_ver: selects the norm version to use for prediction - valid values (so far) are:
%'ourQuestions' - Our 99 questions
%'corpusGinterLemma' - Ginter lemmatized corpus norms
%'combined' - Ginter and our 99 Question norms combined
%'fourier' - Fourier transfor with 128 frequencies
%'fouANDourQues' - FFT and Our 99 Questions combined.
%'MTFjointFreq' - MTF-based joint frequency model - see Santoro R et al., PLoS Comp Bio. 2014.
%'MTFjointFreq_Trans' - Similar to 'MTFjointFreq' but training on NS and prediction on S
%'MTFjointFreq_Trans_v2' - Similar to 'MTFjointFreq' but raining on NS and S and prediction on S.
%'MTFANDcombined' - MTFjointFreq and Ginter and our 99 Question norms combined.

%Note: This script outputs first item-level prediction results and then outputs the more interesting category-level predictions where 
%speaker bias is removed. If predict_speaker is set to True it will output speaker-prediction results as the third set of outputs

norm_ver = 'MTFjointFreq_Trans_v2' %'MTFjointFreq'%''combined' %'ourQuestions'%corpusGinterLemma';%'fouANDourQues'%'fourier'%'ourQuestions'

modality={'NS','S'};
subjNumber=3
windStrt=0 %Define starting time from stimulus onset in the MEG data to use 
windEnd=1000 %Define ending time from stimulus onset in the MEG data to use
predict_speaker = 1 %Set to 1, to predict speakers.

%%% Save item-level predictions on disk - these computations take a long time 10 - 24 hours %%%%

for k = 1:length(subjNumber)
  if(strcmp(norm_ver, 'MTFjointFreq_Trans') | strcmp(norm_ver, 'MTFjointFreq_Trans_v2'))
    mainNSF_sXX_NStraining_Stest(norm_ver, subjNumber(k), windStrt, windEnd); %Use non-speech modaility for training
  else
    mainNSF_sXX(norm_ver, subjNumber(k), modality{2}, windStrt, windEnd); %Use speech modaility
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read results that were saved int he above code and compute category level and/or speaker predictions - this is quick %

fprintf('\nNow removing same speaker bias - Category level prediction...\n')

samspk_ind = load('main_itemlevel_indices_for_sameSpk_IN 946job_indfile.mat'); fnam = fieldnames(samspk_ind); %indices for sound pairs spoken by same speaker
samspk_ind = samspk_ind.(fnam{1});

for i = subjNumber
  if(i < 10)
    subId=['s0' num2str(i)'];
  else
    subId=['s' num2str(i)];
  end
  sublab=['s' num2str(i)]; %suffix for filenames that will contain the results.
  res_matfile = sprintf('%s/%s_itemlevel_acc_%s_%s_wind%sto%s_PCA.mat',[num2str(subId), '_itemlevel'], num2str(sublab),norm_ver,modality{2},num2str(windStrt),num2str(windEnd));
  load(fullfile(pwd,res_matfile));
  fprintf('\n%s: %0.2f',num2str(subId), mean(result(samspk_ind))*100); %Cross category (i.e. within speaker) prediction results
end

fprintf('\nNow - Speaker prediction...\n')

if predict_speaker
  for i = subjNumber
    if(i < 10)
      subId=['s0' num2str(i)'];
    else
      subId=['s' num2str(i)];
    end
    sublab=['s' num2str(i)]; %suffix for filenames that will contain the results.
    res_matfile = sprintf('%s/%s_itemlevel_acc_%s_%s_wind%sto%s_PCA.mat',[num2str(subId), '_itemlevel'], num2str(sublab),norm_ver,modality{2},num2str(windStrt),num2str(windEnd));
    load(fullfile(pwd,res_matfile));
    fprintf('\n%s: %0.2f',num2str(subId), mean(result(setdiff(1:946,samspk_ind)))*100); %Speaker prediction results
  end
end