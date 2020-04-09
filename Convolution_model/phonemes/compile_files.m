
for l = [1:3 5]
  lagged_at = num2str((l-1)*80+20); %lag within tau from which to start decoding data.
  lag = num2str(l*80+20);
  for i = 3:18
    if i < 10
      sid = ['0' num2str(i)];
    else
      sid = num2str(i);
    end
      cd(['s' sid '_OnlyMeaningful_audcortex_16msWind_tauLAGGEDat' lagged_at '_scorefeat_senFinal_lag' lag])
      makefile
    cd ..
  end
end