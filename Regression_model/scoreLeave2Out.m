function [ correct ] = scoreLeave2Out(targetSpect1, targetSpect2, testSpect1, testSpect2)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

length1 = size(targetSpect1,1);
length2 = size(targetSpect2,1);

% make size of the spectrogram equal
diff = length1 - length2;
if diff ~= 0
   if diff > 0
       targetSpect2([end+1:end+diff],:) = 0;
       testSpect2([end+1:end+diff],:) = 0;
   else
       targetSpect1([end+1:end-diff],:) = 0;
       testSpect1([end+1:end-diff],:) = 0;
   end
end

% Convert each spectrogram to vector and then calculate the correlation
% coeff and compare.
targetSpect1 = targetSpect1(:);
targetSpect2 = targetSpect2(:);
testSpect1 = testSpect1(:);
testSpect2 = testSpect2(:);

temp = corrcoef(targetSpect1,testSpect1);
cor11 = temp(1,2);

temp = corrcoef(targetSpect1,testSpect2);
cor12 = temp(1,2);

temp = corrcoef(targetSpect2,testSpect1);
cor21 = temp(1,2);

temp = corrcoef(targetSpect2,testSpect2);
cor22 = temp(1,2);

% Correct if cor11 + cor22 > cor21 + cor12
if ( (cor11 + cor22) > (cor21 + cor12) )
    correct = 1;
else
    correct = 0;
end

end

