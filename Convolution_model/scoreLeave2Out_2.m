function [ correct ] = scoreLeave2Out_2(targ1, targ2, pred1, pred2)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

length1 = size(targ1,1);
length2 = size(targ2,1);

% make size of the spectrogram equal
diff = length1 - length2;
if diff ~= 0
   if diff > 0
       targ1([length1-diff+1:length1],:) = [];
       pred1([length1-diff+1:length1],:) = [];
   else
       targ2([length2+diff+1:length2],:) = [];
       pred2([length2+diff+1:length2],:) = [];
   end
end

% Convert each spectrogram to vector and then calculate the correlation
% coeff and compare.
targ1 = targ1(:);
targ2 = targ2(:);
pred1 = pred1(:);
pred2 = pred2(:);

temp = corrcoef(targ1,pred1);
cor11 = temp(1,2);

temp = corrcoef(targ1,pred2);
cor12 = temp(1,2);

temp = corrcoef(targ2,pred1);
cor21 = temp(1,2);

temp = corrcoef(targ2,pred2);
cor22 = temp(1,2);

% Correct if cor11 + cor22 > cor21 + cor12
if ( (cor11 + cor22) > (cor21 + cor12) )
    correct = 1;
else
    correct = 0;
end

end

