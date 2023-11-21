function [adverPrimeProbs] = adverserialPrediction(choices, outcomes, thresh)
%
% Adversarial Debiasing using Binomial Prediction
%generates a priming probability for two options given a predictor which
%calculates the probability 

%inputs 
%choices  -  Kx1 vector on [0 1] with the two choices
%outcomes -  Kx1 vector on [0 1] with the two outcomes
%thresh   - minimum number of examples


if nargin<3
   thresh = 5; 
end

if any(ismember([0 1],unique(choices)) == 0)
    error('choices must be [0 1]')
end

if any(ismember([0 1],unique(outcomes)) == 0)
    error('choices must be [0 1]')
end

hits = choices(1:end-1) == choices(end) & outcomes(1:end-1) == outcomes(end);
hitsSub = find(hits)+1;  %generate teh index for the next choice
if numel(hitsSub)>thresh
   choiceNum = sum(choices(hitsSub) == 0);
   hitsNum   = numel(hitsSub);
   choiceProb = choiceNum./hitsNum;
   choiceProb(2) = 1-choiceProb(1);
   if  choiceProb(1)<0.5
     pval = binocdf(choiceNum,numel(hitsSub),0.5);
   elseif choiceProb(1)==0.5
     pval = 0.5;
   else
     pval = binocdf(choiceNum-1,numel(hitsSub),0.5); %upper tail, since cdf at x == N  is one
   end
    adverPrimeProbs =  1-pval;
    adverPrimeProbs(2) =  1-adverPrimeProbs(1); 
else
    adverPrimeProbs = [nan, nan];
end