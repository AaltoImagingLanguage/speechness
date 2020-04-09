%Ali Faisal 

%Last Updated: 26th July 2015 %Added support for restricting analyses to auditory cortex (new argument "region" added).
%Update: 31st May 2015 %First version copied to taito /proj/kieliSemspeech directory

%Compute predictions using ALL time points in MEG Non-speech data (0 to 1000ms)
%(in the output, printed on console, the first set of accuracies are mean predictions across all items, while the second set of accuracies are within speaker i.e. across category predcitions and this latter set is more relevant as it removes speaker bias, details on Aalto project wiki)

%norm_ver: selects the norm version to use for prediction - valid values (so far) are:
%'ourQuestions' - Our 99 questions
%'corpusGinterLemma' - Ginter lemmatized corpus norms
%'combined' - Ginter and our 99 Question norms combined
%'fourier' - Fourier transfor with 128 frequencies
%'fouANDourQues' - FFT and Our 99 Questions combined.
%'MTFjointFreq' - MTF-based joint frequency model - see Santoro R et al., PLoS Comp Bio. 2014.

%Choose either all channels or one of a specific region, (see region below)

norm_ver = 'fourier'%'MTFjointFreq'%'combined'%'ourQuestions'%'corpusGinterLemma';%'fouANDourQues'%'fourier'%'ourQuestions'
modality={'NS','S'};
subjNumber=3:18
windStrt=0;
windEnd=1000;
region = 'audcortex'; %Valid arguments are region='' for entire head, region = 'audcortex' for auditory cortex

for k = 1:length(subjNumber)
  mainNSF_sXX(norm_ver, subjNumber(k), modality{2}, windStrt, windEnd, region); %Use Non-speech modaility
end

samspk_ind = load('main_itemlevel_indices_for_sameSpk_IN 946job_indfile.mat'); fnam = fieldnames(samspk_ind);
samspk_ind = samspk_ind.(fnam{1});

for i = subjNumber
  if(i < 10)
    subId=['s0' num2str(i)'];
  else
    subId=['s' num2str(i)];
  end
  sublab=['s' num2str(i)]; %suffix for filenames that will contain the results.
  res_matfile = sprintf('%s/%s_itemlevel_acc_%s_%s_%s_wind%sto%s_PCA.mat',[num2str(subId), '_itemlevel'], num2str(sublab),norm_ver,modality{2},region,num2str(windStrt),num2str(windEnd));
  load(fullfile(pwd,res_matfile));
  fprintf('\n%s: %0.2f',num2str(subId), mean(result(samspk_ind))*100);
end
