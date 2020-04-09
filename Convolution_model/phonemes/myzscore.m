function [x] = myzscore(x)
sigma=max(std(x),eps);
mu=mean(x);
x=bsxfun(@minus,x,mu);
x=bsxfun(@rdivide,x,sigma);
end
