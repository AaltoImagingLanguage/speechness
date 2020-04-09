#!/bin/bash
### Parameters ##
lagged_at="$((($2-1)*80+20))" # lag within tau from which to start decoding data.
# echo $lagged_at
run_name="s$1_OnlyMeaningful_audcortex_16msWind_tauLAGGEDat${lagged_at}_scorefeat_senFinal" # Finalized data - Sensor level
# echo $run_name
# run_name="s$1_OnlyMeaningful_audcortex_16msWind_tauLAGGEDat320_scorefeat_senFinal" # Finalized data - Sensor level
# run_name="s$1_OnlyMeaningful_audcortex_16msWind_tauLAGGEDat50_scorefeat_senFinal" # Finalized data - Sensor level
# run_name="s$1_OnlyMeaningful_audcortex_16msWind_tauLAGGEDat100_scorefeat_senFinal" # Finalized data - Sensor level
# run_name="s$1_OnlyMeaningful_audcortex_16msWind_tauLAGGEDat180_scorefeat_senFinal" # Finalized data - Sensor level
# # run_name="s$1_OnlyMeaningful_audcortex_16msWind_tauLAGGEDat260_scorefeat_senFinal" # Finalized data - Sensor level
numAudio=44
lag_number=$3

suffix2="_lag$((${lag_number}*80+20))" #add suffix (lag-number) to the directory 
run_name=$run_name$suffix2
laggedat_downsampled=$((${lagged_at}/10))
# echo $laggedat_downsampled

### copy master files to the folder ##
echo "Working dir name:" $run_name
mkdir $run_name
cp mainNSF.m $run_name/
cp mainNSF.sh $run_name/
cp makefile.m $run_name/
cp job_index1.csv $run_name/
cp job_index2.csv $run_name/

### create job indexes ##
# cd $run_name
# DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
# cd ..
# module load matlab
# matlab -nojvm -r "mycreateJobNSF('$DIR','$numAudio'); quit"

### create multiple triton job/batch scripts uisng the above indexes ##
cd $run_name
total_tests=$(wc -l job_index1.csv | awk '{print $1}')
echo "Total tests:" $total_tests

if [ "$1" -lt 10 ]
then
  cur_subj_idx=$((${run_name:2:1}-1)) #This is the index to the sub_ids array
  echo $cur_subj_idx
else
  cur_subj_idx=$((${run_name:1:2}-1)) #This is the index to the sub_ids array
  echo $cur_subj_idx
fi

cur_subj_idx=$(($cur_subj_idx + 1))

echo "Subject no. " $cur_subj_idx 

echo "Reading file: semspeech_model_"$cur_subj_idx".mat"

for st_idx in $(seq 1 100 $total_tests)
do
  end_idx=$(($st_idx+99))
  if (("$end_idx" >= "$total_tests"))
  then
    end_idx=$total_tests
  fi
  
  echo "sed -e 's/1,100/$st_idx,$end_idx/g' -e 's/model_aw/model_$id/g' -e 's/_20150417/$data_ver/g' -e 's/tau_index=0/tau_index=$lag_number/g' -e 's/lagged=26/lagged=$laggedat_downsampled/g' -e 's/phonetic_model_3.mat/phonetic_model_$cur_subj_idx.mat/g' mainNSF.m >mainNSF_$st_idx.m" >> Create_Scripts.sh  
  echo "sed -e 's/run_mainNSF_1.sh/run_mainNSF_$st_idx.sh/g' mainNSF.sh >mainNSF_$st_idx.sh" >> Create_Scripts.sh

  echo "sbatch -o mainNSF_$st_idx.log mainNSF_$st_idx.sh" >> batch.sh
  echo "sleep 1" >> batch.sh

done

chmod u+x Create_Scripts.sh
./Create_Scripts.sh
chmod u+x batch.sh

# # module load matlab/R2014a
# module load matlab #Matlab version should match with the version used in mainNSF.sh where we include matlab libraries, if it does not then use e.g. 2014a or 2014b matlab release above and also uncomment the line in mainNSF.sh for 2014a
# matlab -nojvm -r "makefile; quit"
# 
# ./batch.sh

cd ..
chmod -R go+rwx $run_name
# strlen=$((${#run_name}-1))
#echo "lag_index " ${run_name:$strlen:1}
