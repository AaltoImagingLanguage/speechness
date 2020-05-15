###########        Project Speechness      ##################

Analysis code relating to Nora, Faisal et al 2020: Dynamic time-locking mechanism in the cortical representation of spoken words

Last updated 9th Apr 2020 (c) Ali Faisal, Imaging Language group

%NOTE

-THE CODE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 

-Semantic norms are shared for stimuli presented to all participants. Acoustic features vary for each stimulus set (because different speaker sets were used for different participant), and here only one example set for one participant (s03) is given for the acoustic and phoneme feature sets (FFT, MPS, spectrogram, envelope and phonemes)

-Brain data is not included in the current files. In the original code it was uploaded together with the acoustic norms (in fle semspeech_model_s03.mat) 


##########   A) Regression model (semantic decoding, FFT & MPS acoustic decoding): ###########

Scripts: Regression_model
Norms: Feature_sets

A.1) Compute predictions using ALL time points in MEG data (0 to 1000ms), in Matlab run:
mainNSF_total_accS.m (for semantic decoding, all sensors)
mainNSF_total_accS_audcortex.m (for speech FFT/MPS decoding which is limited to auditory cortex)

(In these files, choose the external norm version e.g. fft or 99Questions using the following line: norm_ver = 'fourier'%'ourQuestions')

The results (are saved under subj. subdirectories e.g. s3_itemlevel for s03 etc) and are printed on console, 
the first set of accuracies are mean predictions across all items, 
while the second set of accuracies are within speaker i.e. across category predictions, and this latter
set is more relevant for speech semantic decoding as it removes speaker bias)

A.2) Compute predictions using fixed time window (50ms) in MEG data, in Matlab run:
main_itemlevelS.m



##########   B) Convolution Model (spectrogram, amplitude envelope and phoneme decoding) ###########

Scripts: Convolution_model
Norms: Feature_sets

B.1) Convolution model for spectrogram decoding

Step 1: Set lagged window parameters in submit_run, mainNSF.m, run.sh and compile_files.m (see below)
Step 2: on console run ./submit_run.sh (this creates subfolders and scripts with specified parameters)
Step 3: run compile_files.m in Matlab
Step 4: submit batch jobs (using ./batch_master.sh)

Setting parameters:
-Specify starting time of the window in mainNSF.m 
-specify the subjects and ending time of the window in submit_run.sh

%Example: To perform convolution modelling for subject nro 3, lag window from 180 to 260 ms, 
you would need to specify the lag window as follows:
%Starting time of the window (in mainNSF.m)
lagged = 18 (means 180ms)
%Ending time of the window (in submit_run.sh)
./run.sh 03 3 (here 3 means 260 ms - see table below)

%Table for setting parameters:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%    20   100   180   260   340   420   500   580   660

%     0     1     2     3     4     5     6     7     8 tau_index (end of window 2nd argument in submit_run.sh, 20 + LAG_NUMBER*80)

%     2    10    18    26    34    42    50    58    66 lagged (start of window in mainNSF.m)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The table is based on a code that uses the following:
%>> tau_index = (0:8);                            
%>> [(0:8).*80+20;0:8; ((20+(80*(tau_index)))/10)]

Results will be saved under subdirectories for each subject (e.g. s03_itemlevel for s03 etc).


B.2) Convolution model for amplitude envelope decoding (20-420ms lag window)
Scripts: Convolution_model/amplitude_envelope
Norms: Feature_sets 

batch_master_ampEnv.sh
compile_files_ampEnv.m
mainNSF_leave2out_amplitudeEnvelope.sh
submit_run_leave2out_amplitudeEnvelope.sh


B.3) Convolution model for phoneme decoding, different lag windows
Scripts: Convolution_model/phonemes
Norms: Feature_sets

Run similarly to spectrogram model



############# END OF FILE #################
