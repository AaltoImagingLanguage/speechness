for i = 3:10
  if i < 10
    sid = ['0' num2str(i)];
  else
    sid = num2str(i);
  end
  ['s' sid '_OnlyMeaningful_audcortex_16msWind_taufixed_scorefeat_senFinal_amplitudeEnv_lag420']
  cd(['s' sid '_OnlyMeaningful_audcortex_16msWind_taufixed_scorefeat_senFinal_amplitudeEnv_lag420'])
  makefile_ampEnv
  cd ..
end