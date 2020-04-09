for i = 3:18
  if i < 10
    sid = ['0' num2str(i)];
  else
    sid = num2str(i);
  end

%    cd(['s' sid '_OnlyMeaningful_audcortex_16msWind_tauLAGGEDat20_scorefeat_senFinal_lag100'])
%    cd(['s' sid '_OnlyMeaningful_audcortex_16msWind_tauLAGGEDat100_scorefeat_senFinal_lag180'])
    cd(['s' sid '_OnlyMeaningful_audcortex_16msWind_tauLAGGEDat180_scorefeat_senFinal_lag260'])
%    cd(['s' sid '_OnlyMeaningful_audcortex_16msWind_tauLAGGEDat260_scorefeat_senFinal_lag340'])
%    cd(['s' sid '_OnlyMeaningful_audcortex_16msWind_tauLAGGEDat320_scorefeat_senFinal_lag420'])


  makefile
  cd ..
end
