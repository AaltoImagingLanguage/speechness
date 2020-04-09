% Update (ali) - Dec. 2nd 2014: Experiment redesigned and new pilot data arrived
% Update (shakir) - July 21st 2014: Original Data Arrived

function [norm_ver] = mainNSF_sXX(norm_ver, subjNumber, modality, windStrt, windEnd, region)


if ~isdeployed
  addpath('../');
end


% add path of all the scripts
%  addpath('../');
%  
%  subjNumber=4;
%  %  norm_ver = 'ourQuestions'; %'corpus';
%  %  modality = 'S'; %NS
%  norm_ver = 'corpus'; %'ourQuestions'; 
%  modality = 'S'; %NS


if(subjNumber < 10)
  subId=['s0' num2str(subjNumber)'];
else
  subId=['s' num2str(subjNumber)];
end
sublab=['s' num2str(subjNumber)]; %suffix for filenames that will contain the results.


data = load(['semspeech_model_' {subjNumber} '.mat']); 
clear mat;

fname = fieldnames(data);

item = data.(fname{1}).item;
brainData = data.(fname{1}).brain;
spectrogram = data.(fname{1}).acoustic128;
brainData_Base = data.(fname{1}).brain_Base;
for i = 1:size(brainData,1); ourFFT(i,:) = data.(fname{1}).fft128{i}; end
clear data

% Raw Data Dimensions
%size(brainData)
%size(spectrogram)

% Data should be of the form: STIMULUS X TIME X CHANNEL
brainData = permute(brainData, [1,3,2]);
brainData_Base = permute(brainData_Base, [1,3,2]);

if(size(brainData,2) > 1000)
  brainData(:,1001:end,:)=[];
end

if(windStrt > -1)
  brainData = brainData(:,windStrt+1:windEnd,:);
else
  brainData_Base(:,1:120,:) = []; % MEG data at -300 (not needed)
  brainData = brainData_Base(:,windStrt+1+200:windEnd+200,:); %+200 is for correct indexing, as matlab does not support negative indexes.
end

% Features (spectrogram) should be of form: 1 X STIMULUS cell of TIME X FREQUENCY
for i = 1:length(spectrogram)
    spectrogram{i} = (spectrogram{i})';
end

%fprintf('SAMPLING DOWN THE DATA...\n');
T0 = 10;  %Sample down MEG to 10ms.
[brainData, spectrogram] = sample_down(brainData, spectrogram, T0, 0);
clear spectrogram

if strcmp(region,'audcortex') %Restrict analyses to a specific region, here auditory cortex
  ind = extract_auditory_channels();
%    ind = extract_auditory_channels_deployed();
  brainData = brainData(:,:,ind);
end  

brainData_S = []; iter=1;
spk = {item(:).speaker};
cat = {item(:).category};
z=[];
zz=[];
for i = 1:size(brainData,1)
      if strcmp(item(i).type, modality) && ~(strcmp(item(i).category,'X'))
	brainData_S = [brainData_S; brainData(i,:,:)];
	z = [z;i];
	zz = [zz;iter];
      end
end

annot.cat = cat(z);
annot.spk = spk(z);
my_items = item(z);
%size(brainData_S)
ourFFT = ourFFT(z,:);
%length(z)

clear spectrogram_S

%fprintf('LEAVE TWO OUT CROSS VALIDATION...\n');
dir_path = [subId, '_itemlevel'];

if exist(dir_path,'dir') ~= 7 %Create subject subdirectory to store results if it does not exist already
mkdir(dir_path); s1=copyfile('job_index1.csv', [dir_path '/']); s2=copyfile('job_index2.csv', [dir_path '/']);
if(s1~=1 || s2~=1) error('Files missing in main folder: job_index1.csv and/or job_index2.csv'); end
end

%  cd(dir_path);
JOB_PATH = dir_path;
%  cd ..
%if(strcmp(norm_ver, 'corpus'))%%%%%%%%% TEST WITH CORPUS SEMANTIC NORMS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  PATH_NORM_DATA = '../semantic_model/words_modif_lemma';
  addpath(PATH_NORM_DATA);
  % Extract corpus based semantic features:
  features = load('vectors.tsv');
  fid = fopen('vocab_English.tsv');
  corpus_words = {};
  tline = fgetl(fid);
  while ischar(tline)
    corpus_words{end+1} = tline;
    tline = fgetl(fid);
  end
  fclose(fid);
  ind = [];
  for i = 1:length(my_items), ind = [ind; find(ismember(corpus_words, my_items(i).item)==1)];, end%Reorder feature matrix
  features = features(ind,:);
  %fprintf('\nCorpusNorms: ')
%else %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% END OF CORPUS NORMS PART %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  PATH_NORM_DATA = '../semantic_model/99questions';
  addpath(PATH_NORM_DATA)
  features_99 = csvread('semspeech_question_norm_Anni.csv');
  features_99 = features_99';
  question_words =load('item_label_FI_to_EN.mat');
  question_words = question_words.item_label;
  question_words = question_words(:,3);
  ind = [];
  for i = 1:length(my_items), ind = [ind; find(ismember(question_words, my_items(i).item)==1)];, end%Reorder feature matrix
  %THE REORDING OF ITEMS IS COMPLICATED BUT THE CODE IS CORRECT AND CAN BE VERIFIED VIA 
  %[question_words_bk(ind,2), annot.cat']
  features_99 = features_99(ind,:);  
  %fprintf('\n99Ques: ')
%end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% END OF QUESTION NORMS PART %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(strcmp(norm_ver, 'ourQuestions'))
  features = features_99;
end
if(strcmp(norm_ver, 'combined'))
  features = [features features_99];
end
if(strcmp(norm_ver, 'fourier'))
  features = ourFFT;
end
if(strcmp(norm_ver, 'fouANDourQues'))
  features = [features_99 ourFFT];
end
if(strcmp(norm_ver, 'corpusGinterLemma')) %Ginter lemma norms from corpus - details in local neuro proj. directory
  features = features;
end
if(strcmp(norm_ver, 'MTFjointFreq')) %Use MTF with joint freq. based averaging
  fname_mtf = ['semspeech_model_' {subjNumber} '_MTF3D.mat'];
  mtf = load(fullfile(PATH_DATA, 'model_input_MTF', fname_mtf));
  for i = 1:size(brainData,1); ourMTF(i,:) = reshape(mtf.MTF3D{i}, [1 size(mtf.MTF3D{i},1)*size(mtf.MTF3D{i},2)*size(mtf.MTF3D{i},3)]); end
  ourMTF = ourMTF(z,:);
 features = ourMTF;
end
if(strcmp(norm_ver, 'MTFANDcombined')) %Use MTF and Corpus and Our99 Question norms
  corp =  [features features_99];
  fname_mtf = ['semspeech_model_' {subjNumber} '_MTF3D.mat'];
  mtf = load(fullfile(PATH_DATA, 'model_input_MTF', fname_mtf));
  for i = 1:size(brainData,1); ourMTF(i,:) = reshape(mtf.MTF3D{i}, [1 size(mtf.MTF3D{i},1)*size(mtf.MTF3D{i},2)*size(mtf.MTF3D{i},3)]); end
  ourMTF = ourMTF(z,:);
  features = [corp ourMTF];
end
%size(features)

norm_ver = [norm_ver '_' modality];
[ accuracy, result ] = crossValidateLeave2Out_fft_parallel(brainData_S,features,1,946,JOB_PATH, norm_ver);
%fprintf('\ns0%d %s Accuracy: %f', subjNumber, norm_ver, accuracy)
%res_matfile = sprintf('%s/%s_itemlevel_acc_%s.mat',JOB_PATH, subId,norm_ver);
fprintf('\ns0%d %s wind%sto%s Accuracy: %f', subjNumber, norm_ver, num2str(windStrt),num2str(windEnd), accuracy)
res_matfile = sprintf('%s/%s_itemlevel_acc_%s_%s_wind%sto%s_PCA.mat',JOB_PATH, sublab,norm_ver,region,num2str(windStrt),num2str(windEnd));
save(res_matfile,'result')
