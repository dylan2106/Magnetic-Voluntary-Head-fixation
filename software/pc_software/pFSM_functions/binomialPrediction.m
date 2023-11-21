function [lPort, rPort, lProb, rProb, choice] = binomialPrediction(decisions, thresh, verbose, binary, nbackMax, side, p)
% function [lPort, rPort, lProb, rProb, choice] = binomialPrediction(decisions, thresh, verbose, binary, nbackMax, side, p)
%
% Adversarial Debiasing using Binomial Prediction
%
% A prediction algorithm adopted from previous work in primates (Barraclough et al., 2004; Lee et al., 2004)
% and rodents (Tervo et al. 2014). On each trial, the history of the animal’s past choices in a
% 2 alternate forced choice task session is used to estimate the conditional probabilities of a
% left choice given the animal’s choices and reward in the past n trials (n = 1 to 2).
% A one-sided binomial test is then used to estimate for each of the two observed conditional probabilities
% the confidence that they are greater than 0.5. The largest confidence is then used to bias
% the reward ports. For exmaple, if the binomial test yields confidence of 94.3% for a left-side bias,
% the right port (rPort) will be primed with a probability of 94.3% and the left port (lPort)
% with the remaining 5.7%.
%
% Args:
%     decisions (array_like): an array (n,2) containing trial history, where the first column is choice
%     and the second is reward.
%     thresh (int, optional): minimum number of 2bac instances to consider 2bac confidence
%     (default 5)
%     verbose (logical, optional): to control summary outputs (default 0)
%     binary (logical, optional): whether to normalize decision matrix to 0 and 1 (default 0)
%     nbackMax (int, optional): number of nback to test (default 2) 
%     side (string, optional): sidedness of binomial test to run (default 'two')
%     p (double, optional): the hypothesized probability of success (0<=p<=1) for the binomial test (default 0.5)
% Raises:
%     error: trial history length < 2
%     warning: Number of 1bac instances < 1
%     warning: Number of 2bac instances < thresh
% Returns:
%     lPort, rPort (double): Priming probabilities for the left and right reward ports in %
%     lProb, rProb (double): Conditional probabilities for the left and right
%     choice (double): Which bac condition was used to select the final priming probability

if nargin < 2 || isempty(thresh)
    thresh = 5;
end

if nargin < 3 || isempty(verbose)
    verbose = 0;
end

if nargin < 4 || isempty(binary)
    binary = 0; 
end

if nargin < 5 || isempty(nbackMax)
    nbackMax = 2;
end

if nargin < 6 || isempty(side)
    side = 'two';
end

if nargin < 6 || isempty(p)
    p = 0.5;
end

nDecisions = length(decisions);

if ~all(decisions >= 0 & decisions <= 1 | isnan(decisions))
    error('Trial values must be in [0,1] or NaN')
end

if binary == 1
    decisions = decisions-1;
end

if nDecisions<2 
   warning('Number of trial length < 2, lPort and rPort randomly primed')
   lPort = randi([0 1])*100;
   rPort = 100-lPort;
   lProb = 0.5;
   rProb = 0.5;
   choice = 0;
   return
end

% For 1bac
% Get subsequent turn choices for 1bac (1bac+1)
template = decisions(end,:);

bac1Consecutive = {};
for i = 1:length(decisions)-1
    match = isequal(decisions(i,:),template);
    if match
        bac1Consecutive = [bac1Consecutive, decisions(i+1,1)];
    end
end

bac1Consecutive = cell2mat(bac1Consecutive)';
num1Consecutive = length(bac1Consecutive);
    
if num1Consecutive < thresh
    lPort = nan;
    rPort = nan;
    lProb = nan;
    rProb = nan;
    choice = 0;
    if verbose == 1
        warning('Number of 1bac instances < thress, lPort and rPort randomly primed')

        horzcat(sprintf('Left port priming prob: %d%s \n', lPort, '%'),...
        sprintf('Right port priming prob: %d%s \n', rPort, '%'))
    end
    return
end

nLeft = length(bac1Consecutive(bac1Consecutive == 0));

% Compute 1bac conditional probabilites and run the binomial test on these values
probLeft1 = nLeft/num1Consecutive;
probRight1 = 1-probLeft1;

pval = binocdf(nLeft,num1Consecutive, p);
lPort1 = (pval*100)
rPort1 = lPort1
 if probLeft1 >= 0.5
            rPort1 = (1-pval1)*100;
            lPort1 = 100-rPort1;
        else 
            lPort1 = (1-pval1)*100;
            rPort1 = 100-lPort1;    
        end

switch side
    case 'greater'
        pval1 = oneSidedBinomialTest(nLeft, num1Consecutive, p, 'greater');
        lPort1 = (1-pval1)*100;
        rPort1 = 100-lPort1;
    case 'less'
        pval1 = oneSidedBinomialTest(nLeft, num1Consecutive, p, 'less');
        rPort1 = (1-pval1)*100;
        lPort1 = 100-rPort1;
    case 'one'
        pval1 = myBinomTest(nLeft, num1Consecutive, p, 'one');
        if probLeft1 >= 0.5
            rPort1 = (1-pval1)*100;
            lPort1 = 100-rPort1;
        else 
            lPort1 = (1-pval1)*100;
            rPort1 = 100-lPort1;    
        end
end

% If requested do not go any further here and just take the 1bac conditional
% probabilities
if nbackMax == 1
    lPort = lPort1;
    rPort = rPort1;
    lProb = probLeft1;
    rProb = probRight1;
    choice = 1;
    if verbose == 1
        horzcat(sprintf('Using 1bac (%d)', num1Consecutive), sprintf('LP: %d%s \n', lPort1, '%'),...
            sprintf('RP: %d%s \n', rPort1, '%'))
    end
    return
end

% For 2bac
template = decisions(end-1:end,:);
    
bac2Consecutive = {};
for j = 1:length(decisions)-2
    match = isequal(decisions(j:j+1,:),template);
    if match
        bac2Consecutive = [bac2Consecutive, decisions(j+2,1)];
    end
end
    
bac2Consecutive = cell2mat(bac2Consecutive)';
num2Consecutive = length(bac2Consecutive);
    
% Use 1bac port priming probabilites if there are too few 2bac instances
if num2Consecutive < thresh
    warning('Number of 2bac instances (%d) < %d; using 1bac (%d) to prime', num2Consecutive, thresh, num1Consecutive)
    lPort = lPort1;
    rPort = rPort1;
    lProb = probLeft1;
    rProb = probRight1;
    choice = 1;
    if verbose == 1
        horzcat(sprintf('Using 1bac (%d)', num1Consecutive), sprintf('LP: %d%s \n', lPort1, '%'),...
            sprintf('RP: %d%s \n', rPort1, '%'))
    end
    return
end

% Get 2bac+1 unique values and counts
nLeft = length(bac2Consecutive(bac2Consecutive == 0));

% Compute 2bac conditional probabilites and run the binomial test on these values
probLeft2 = nLeft/num2Consecutive;
probRight2 = 1-probLeft2;

switch side
    case 'greater'
        pval2 = oneSidedBinomialTest(nLeft, num2Consecutive, p, 'greater');
        lPort2 = (1-pval2)*100;
        rPort2 = 100-lPort2;
    case 'less'
        pval2 = oneSidedBinomialTest(nLeft, num2Consecutive, p, 'less');
        rPort2 = (1-pval2)*100;
        lPort2 = 100-rPort2;
    case 'two'
        pval2 = myBinomTest(nLeft, num2Consecutive, p, 'two');
        if probLeft2 >= 0.5
            rPort2 = (1-pval2)*100;
            lPort2 = 100-rPort2;
        else 
            lPort2 = (1-pval2)*100;
            rPort2 = 100-lPort2;    
        end
end

% Use the largest confidence to bias reward port priming

if pval1 <= pval2
    lPort = lPort1;
    rPort = rPort1;
    lProb = probLeft1;
    rProb = probRight1;
    choice = 1;
    if verbose ==1
        horzcat(sprintf('Using 1bac (%d)', num1Consecutive), sprintf('LP: %d%s \n', lPort1, '%'),...
            sprintf('RP: %d%s \n', rPort1, '%'))
    end
else
    lPort = lPort2;
    rPort = rPort2;
    lProb = probLeft2;
    rProb = probRight2;
    choice = 2;
    if verbose ==1
        horzcat(sprintf('Using 1bac (%d)', num1Consecutive), sprintf('LP: %d%s \n', lPort1, '%'),...
            sprintf('RP: %d%s \n', rPort1, '%'))
    end

end

end

%%%%%%%%%%%%%%%%%%%% Dependencies %%%%%%%%%%%%%%%%%%%%

function pout = oneSidedBinomialTest(x, n, p, alternative)
% function pout = binomialTest(x, n, p, alternative)
%
% This is an adaptation of the source code for scipy.stats.binom_test, available at: 
% https://github.com/scipy/scipy/blob/v1.3.0/scipy/stats/morestats.py#L2357-L2448
%
% Perform a test that the probability of success is p.
% This is an exact, two-sided test of the null hypothesis
% that the probability of success in a Bernoulli experiment
% is p.
%
% Parameters
% ----------
% x : integer or array_like
%     the number of successes, or if x has length 2, it is the
%     number of successes and the number of failures.
% n : integer
%     the number of trials.  This is ignored if x gives both the
%     number of successes and failures
% p : float, optional
%     The hypothesized probability of success.  0 <= p <= 1. The
%     default value is p = 0.5
% alternative : {'greater', 'less'}, optional
%     Indicates the alternative hypothesis. The default value is
%     'greater'.
%
% Returns
% -------
% p-value : float
%     The p-value of the hypothesis test
%
% To do: add two-sided functionality

if nargin<4 || isempty(alternative)
    alternative = 'greater';      
end

if nargin<3 || isempty(p)
    p = 0.5;      
end

if length(x) > 2
    error('Incorrect length for x, must be <= 2')
end 

if length(x) == 2
    n = sum(x);
    x = x(1);
end

if length(x) > n
    error('n must be >= x')
end

if (p > 1.0) || (p < 0.0)
    error('p must be in range [0,1]')
end

if ~ismember(1, strcmpi(["less", "greater"], alternative))
   error('alternative not recognized, should be less or greater')
end

if alternative == "less"
    pout = binocdf(x, n, p);
end 

if alternative == "greater"
    pout = binocdf(x-1, n, p, 'upper');
end
end

function pout=myBinomTest(s, n, p, Sided)
%function pout=myBinomTest(s,n,p,Sided)
%
% Performs a binomial test of the number of successes given a total number 
% of outcomes and a probability of success. Can be one or two-sided.
%
% Inputs:
%       s-      (Scalar or Array) The observed number of successful outcomes
%       n-      (Scalar or Array) The total number of outcomes (successful or not)
%       p-      (Scalar or Array) The proposed probability of a successful outcome
%       Sided-  (String) can be 'one', 'two' (the default), or 'two, equal 
%               counts'. A value of 'one' will perform a one-sided test to
%               determine if the observed number of successes are either 
%               significantly greater than or less than the expected number
%               of successes, depending on whether s is greater than or less 
%               than the observed number of successes. 'Two' will use the
%               method of small p-values (see reference below) to perform a
%               two-tailed test to calculate the probability of observing
%               any equally unlikely or more unlikely value greater than or
%               less than the expected number of successes (ie with the 
%               same cdf value of the distribution. 'Two, equal counts' 
%               will perform a two-sided test that the that the actual 
%               number of success is different from the expected number of 
%               successes in any direction.
%
% Outputs:
%       pout-   The probability of observing the resulting value of s or
%               another value more extreme (the precise meaning of which 
%               depends on the value of Sided) given n total outcomes with 
%               a probability of success of p.               
%
%       s, n and p can be scalars or arrays of the same size. The
%       dimensions and size of pout will match that of these inputs.
%
%   For example, the signtest is a special case of this where the value of p
%   is equal to 0.5 (and a 'success' is dfeined by whether or not a given
%   sample is of a particular sign.), but the binomial test and this code is 
%   more general allowing the value of p to be any value between 0 and 1.
%
%   The results when Sided='two' and when Sided='two, equal counts' are 
%   identical only when p=0.5, but are different otherwise. For more
%   description, see the second reference below.
%
% References:
%   http://en.wikipedia.org/wiki/Binomial_test
%   http://www.graphpad.com/guides/prism/6/statistics/index.htm?stat_binomial.htm
%
% by Matthew Nelson July 21st, 2009
%
% Last Updated by Matthew Nelson May 23, 2015
% matthew.nelson.neuro@gmail.com


if nargin<4 || isempty(Sided);    Sided='two';      end
if nargin<3 || isempty(p);      p=0.5;      end
    
s=floor(s);
[s,n,p]= EqArrayAndScalars(s,n,p);

E=p.*n;

GreaterInds=s>=E;
pout=zeros(size(GreaterInds));

Prec=1e-14;  % there are some rounding errors in matlab's binopdf, such that we need to specify a level of tolerance when using the 'two' test     

switch lower(Sided)
    case {'two','two, equal counts'}        
        if all(p)==0.5 && strcmpi(Sided,'two')
            % to avoid the rounding problems mentioned above, use the equal counts method which is is theoretically identical in this special case and is not susceptible to this rounding error    
            Sided='two, equal counts';
        end
            
        dE=pout;
        
        %note that matlab's binocdf(s,n,p) gives the prob. of getting up to AND INCLUDING s # of successes...
        %Calc pout for GreaterInds first
        if any(GreaterInds)
            pout(GreaterInds)=1-binocdf( s(GreaterInds)-1,n(GreaterInds),p(GreaterInds));  %start with the prob of getting >= s # of successes
            
            %now figure the difference from the expected value, and figure the prob of getting lower than that difference from the expected value # of successes
            dE(GreaterInds)=s(GreaterInds)-E(GreaterInds);
            
            if strcmpi(Sided,'two, equal counts')            
                s2= floor(E(GreaterInds)-dE(GreaterInds));
                
                % if s2<0 we add nothing because a negative number of sucesses is impossible    
                if s2>=0
                    pout(GreaterInds)=pout(GreaterInds)+ binocdf(s2,n(GreaterInds),p(GreaterInds));    %the binonmial is a discrete dist. ... so it's value over non-integer args has no meaning... this flooring of E-dE actually doesn't affect the outcome (the result is the same if the floor was removed) but it's included here as a reminder of the discrete nature of the binomial
                end     
                
                %If the expected value is exactly equaled, the above code would have added the probability at that discrete value twice, so we need to adjust (in this case, pout will always = 1 anyways)
                EqInds=dE==0;
                if any(EqInds)
                    pout(EqInds)=pout(EqInds)- binopdf( E(EqInds),n(EqInds),p(EqInds) );
                end
            else
                Inds=find(GreaterInds);                
                
                % find the first value on the other side of the expected value with probability less than or equal to the probability that we found...
                targy=binopdf(s(GreaterInds),n(GreaterInds),p(GreaterInds));                                
                
                % start by guessing a constant dE, and adjusting from there   
                s2=max(floor(E(GreaterInds)-dE(GreaterInds)),0);      %the binonmial is a discrete dist. ... so it's value over non-integer args has no meaning... this flooring of E-dE actually doesn't affect the outcome (the result is the same if the floor was removed) but it's included here as a reminder of the discrete nature of the binomial    
                
                y=binopdf(s2,n(GreaterInds),p(GreaterInds));
                for ii=1:length(Inds)            
                    SkipPAdd=false;
                    if y(ii) <= targy(ii)
                        % search forward until we find the correct limit
                        while y(ii) <= targy(ii) && s2(ii)<E(Inds(ii))
                            s2(ii)=s2(ii)+1;
                            y(ii)=binopdf(s2(ii),n(Inds(ii)),p(Inds(ii)));
                        end
                        s2(ii)=s2(ii)-1;    % because the last iteration would have crossed the boundary, and we want the first s2 with a binopdf <= targy
                    else
                        %while y(ii) > targy(ii) && s2(ii)<n(Inds(ii))  % sometimes this is susceptible to rounding errors which we want to avoid with the line below     
                        while (y(ii) - targy(ii)) > Prec && s2(ii)<n(Inds(ii))
                            s2(ii)=s2(ii)-1;
                            y(ii)=binopdf(s2(ii),n(Inds(ii)),p(Inds(ii)));
                        end
                        % if y(ii)>targy(ii) % bc of rounding error again, avoid this line   
                        if (y(ii) - targy(ii)) > Prec % in this case s2 is at 0, and the prob stil wasn't low enough so we need to add nothing new to pout
                            SkipPAdd=true;
                        end
                    end
                    
                    if ~SkipPAdd
                        % adding the lesser-than tail here   
                        pout(Inds(ii))=pout(Inds(ii))+ binocdf(s2(ii),n(Inds(ii)),p(Inds(ii)));  
                    end
                end
            end                        
        end
        
        %Calc pout for LesserInds second
        if any(~GreaterInds)            
            pout(~GreaterInds)=binocdf(s(~GreaterInds),n(~GreaterInds),p(~GreaterInds));  %start with the prob of getting <= s # of successes
            
            %now figure the difference from the expected value, and figure the prob of getting greater than that difference from the expected value # of successes
            dE(~GreaterInds)=E(~GreaterInds)-s(~GreaterInds);
            
            if strcmpi(Sided,'two, equal counts')
                s2=ceil(E(~GreaterInds)+dE(~GreaterInds));
                
                if s2<=n(~GreaterInds)
                    pout(~GreaterInds)=pout(~GreaterInds) + 1-binocdf(s2-1,n(~GreaterInds),p(~GreaterInds));
                end
            else
                Inds=find(~GreaterInds);
                
                % find the first value on the other side of the expected value with probability less than or equal to the probability that we found...
                targy=binopdf(s(~GreaterInds),n(~GreaterInds),p(~GreaterInds));                  
                
                % start by guessing a constant dE, and adjusting from there   
                s2=min(ceil(E(~GreaterInds)+dE(~GreaterInds)),n(~GreaterInds));      %the binonmial is a discrete dist. ... so it's value over non-integer args has no meaning... this flooring of E-dE actually doesn't affect the outcome (the result is the same if the floor was removed) but it's included here as a reminder of the discrete nature of the binomial    

                y=binopdf(s2,n(~GreaterInds),p(~GreaterInds));
                for ii=1:length(Inds)                
                    SkipPAdd=false;
                    if y(ii) <= targy(ii)
                        % search backward until we find the correct limit
                        while y(ii) <= targy(ii) && s2(ii)>E(Inds(ii))
                            s2(ii)=s2(ii)-1;
                            y(ii)=binopdf(s2(ii),n(Inds(ii)),p(Inds(ii)));
                        end
                        s2(ii)=s2(ii)+1;    % because the last iteration would have crossed the boundary, and we want the first s2 with a binopdf <= targy
                    else
                        %while y(ii) > targy(ii) && s2(ii)<n(Inds(ii))  % sometimes this is susceptible to rounding errors which we want to avoid with the line below     
                        while (y(ii) - targy(ii)) > Prec && s2(ii)<n(Inds(ii))    
                            s2(ii)=s2(ii)+1;
                            y(ii)=binopdf(s2(ii),n(Inds(ii)),p(Inds(ii)));
                        end
                        %if y(ii)>targy(ii) % bc of rounding error again, avoid this line   
                        if (y(ii) - targy(ii)) > Prec   % in this case s2 is at n, and the prob stil wasn't low enough so we need to add nothing new to pout
                            SkipPAdd=true;
                        end
                    end
                    
                    if ~SkipPAdd
                        % adding the greater-than tail here
                        pout(Inds(ii))=pout(Inds(ii))+ 1-binocdf(s2(ii)-1,n(Inds(ii)),p(Inds(ii)));   
                    end
                end
                        
            end
        end
    case 'one'  %one-sided
        if any(GreaterInds)
            pout(GreaterInds)=1-binocdf(s(GreaterInds)-1,n(GreaterInds),p(GreaterInds));  %just report the prob of getting >= s # of successes
        end
        if any(~GreaterInds)                    
            pout(~GreaterInds)=binocdf(s(~GreaterInds),n(~GreaterInds),p(~GreaterInds));  %just report the prob of getting <= s # of successes
        end
    otherwise
        error(['In myBinomTest, Sided variable is: ' Sided '. Unkown sided value.'])
end

function varargout=EqArrayAndScalars(varargin)
%function varargout=EqArrayAndScalars(varargin)
%
% This will compare a collection of inputs that must be either scalars or 
% arrays of the same size. If there is at least one array input, all scalar
% inputs will be replicated to be the array of that same size. If there are
% two or more array inputs that have different sizes, this will return an
% error.
%
% created by Matthew Nelson on April 13th, 2010
% matthew.j.nelson.vumail@gmail.com                        

d=zeros(nargin,1);
for ia=1:nargin    
    d(ia)=ndims(varargin{ia});
end
maxnd=max(d);

s=ones(nargin,maxnd);
    
for ia=1:nargin
    s(ia,1:d(ia))=size(varargin{ia});
end
maxs=max(s);

varargout=cell(nargin,1);
for ia=1:nargin
    if ~all(s(ia,:)==maxs)
        if ~all(s(ia,:)==1)
            error(['Varargin{' num2str(ia) '} needs to be a scalar or equal to the array size of other array inputs.'])
        else
            varargout{ia}=repmat(varargin{ia},maxs);
        end
    else
        varargout{ia}=varargin{ia};
    end
end
end
end