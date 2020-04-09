clear all
%windset=[0,100,200,300,400,500,600,700, 800, 900, 1000];
  %windset = -200:100:1000;
  windset = -200:50:1000;
  norm_ver = 'MTFjointFreq'%'combined';%'ourQuestions'; 
%norm_ver = 'combined'; 
modality={'NS','S'};
%for m =1:2
m=2;
  for subjNumber = [11:14]%[3:18]
    for w=1:(length(windset)-1)
      fprintf('\nExecuting for %s %d %s Wind%dto%d', norm_ver, subjNumber, modality{m}, windset(w), windset(w+1))
      mainNSF_sXX(norm_ver, subjNumber, modality{m}, windset(w), windset(w+1));
    end
  end
%end
