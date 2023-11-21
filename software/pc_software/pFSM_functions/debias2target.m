function output = debias2target(target, observed, alpha)
%this function will adjust reward location probabilities in order to try
%and get the observed perfomance to match the target distribution
%
% target    - 1xN array that sums to 1, each elemen is the goal proportion 
%             eg [0.3 0.2 0.5]
% observed  - 1xN array that sums to 1, observed proportion of animal's choice
% alpha     - 1x1 scalar, describes the agressiveness of the correction for
%             small deviations. 
%              negative = more agressive at low deviations
%              positive = less agressive at low deviations
%              a good range is  [-1.5 0]
%
% algorithm
% the error is calculated as the difference between target and observed
% the error is passed through a non-linearity that keeps it centred  and
% mapped between [-1 1].
% x' =  |x|.^(exp(alpha)) .* sign(x) 
%
%The error is then multiplied with the target value itself to give an
%adjustment ammount, which is added to the orginal target to give the
%update,
%the update is then rescaled to sum to 1.

%examples
% output = debias2target([0.333 0.333 0.333], [0.4 0.3 0.3], 0)


if nargin<3 || isempty(alpha)
    alpha = 0;
end

target = target./sum(target);

observed(isnan(observed)) = 0;
if sum(observed) ~=1
    %error('observed must sum to 1')
end

err   = target - observed;    %[-1 1]
funcNL  = @(x,a) (abs(x).^(exp(a))) .* sign(x);
errNL = funcNL(err,alpha);   %negative == more agressive at low deviation, Positive = less agressive at low deviation

adj = target .* errNL;   %[-1 1]

update = target + adj;
output = update./sum(update);

