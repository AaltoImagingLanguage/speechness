% Update (ali) - Dec. 2nd 2014: Experiment redesigned and new pilot data arrived
% Update (shakir) - July 21st 2014: Original Data Arrived

% add path of all the scripts
if ~isdeployed 
  addpath('../../');
end

%  lagged=32; % lag within tau from which to start decoding data.
% lagged=5;
%lagged=10;
 lagged=18;
% lagged=26;

fprintf('LOADING THE DATA...\n');
data = load('../../../../../data/semspeech_model_s03.mat'); %Finalized sensor level data 
clear mat;

fname = fieldnames(data);

item = data.(fname{1}).item;
brainData = data.(fname{1}).brain;
spectrogram = data.(fname{1}).acoustic128;
clear data

% Raw Data Dimensions
%size(brainData)
%size(spectrogram)

% Data should be of the form: STIMULUS X TIME X CHANNEL
brainData = permute(brainData, [1,3,2]);

% Features (spectrogram) should be of form: 1 X STIMULUS cell of TIME X FREQUENCY
for i = 1:length(spectrogram)
    spectrogram{i} = (spectrogram{i})';
end



fprintf('SAMPLING DOWN THE DATA...\n');
tic
% Sample down 5 time points to 1 time point (Avg recording over 5ms in both
% MEG and spectrogram)
T0 = 10; % Sample down by 5ms
[brainDataS, spectrogramS] = sample_down(brainData, spectrogram, T0, 1);
toc
size(brainDataS)
size(spectrogramS)
clear brainData
clear spectrogram

% Verify the vaule of tau
% Mesgerani et al has used tau = 100 temporal lags
tau_index=0;
tau = ((20+(80*(tau_index)))/10)-1;
fprintf('Value of temporal lag is: %d ms\n', (tau+1)*10);
%tau = 41;%100;%/T0; % lag also sampled down


ind = extract_auditory_channels_deployed();
brainDataS = brainDataS(:,:,ind);
size(brainDataS)
% Pre-process data: trim time points and create the lag vector
fprintf('PRE-PROCESSING DATA...\n');
tic
[ brainDataP ] = preprocess_data_taucorrected_2sec_laggedlag(brainDataS, spectrogramS, tau, lagged);
toc
size(brainDataP)
%size(spectrogramS)
clear brainDataS

% USE 'brainDataP'AND 'spectrogramS' FOR FURTHER PREDICTION

% separate data for different types of Audio, viz Speech, Non-speech and Foil
brainData_NS = cell(1); spectrogram_NS = cell(1); iter1 = 1;
brainData_S = cell(1); spectrogram_S = cell(1); iter2 = 1;
brainData_F = cell(1); spectrogram_F = cell(1); iter3 = 1;
for i = 1:length(brainDataP)
    %if strcmp(item(i).type,'NS')
 %    if strcmp(item(i).type,'NS') && ~(strcmp(item(i).category,'X') || strcmp(item(i).category,'F'))
    if strcmp(item(i).type,'S') && ~(strcmp(item(i).category,'X'))
        brainData_S{iter1} = brainDataP{i};
        spectrogram_S{iter1} = spectrogramS{i};
        iter1 = iter1+1;
    elseif strcmp(item(i).type,'NS')
        brainData_NS{iter2} = brainDataP{i};
        spectrogram_NS{iter2} = spectrogramS{i};
        iter2 = iter2+1;
    else
        brainData_F{iter3} = brainDataP{i};
        spectrogram_F{iter3} = spectrogramS{i};
        iter3 = iter3+1;
    end
end

clear spectrogram_NS brainData_NS

fprintf('LEAVE TWO OUT CROSS VALIDATION...\n');
JOB_PATH = pwd
[ accuracy ] = crossValidateLeave2Out_featureScore([brainData_S],[spectrogram_S],1,100,JOB_PATH);
%[ accuracy ] = crossValidateLeave2Out([brainData_NS],[spectrogram_NS],1,100,JOB_PATH); %For PRNI submitted article
fprintf('Average accuracy is %f\n',accuracy);

