function [x, mu, sigma] = myzscore_extended(x)
sigma=max(std(x),eps);
mu=mean(x);
x=bsxfun(@minus,x,mu);
x=bsxfun(@rdivide,x,sigma);
end
