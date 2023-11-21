


pright = nan(1000,1);
for i = 1:1000
    %binomialPrediction(decisions, thresh, verbose, binary, nbackMax)
    [pright(i)] = binomialPrediction(rand(2000,2)>0.5, 5, false,[],2);
end

ecdf(pright)
hold on
ecdf(100-pright)

prightOneBackOnly = nan(1000,1);
for i = 1:1000
    %binomialPrediction(decisions, thresh, verbose, binary, nbackMax)
    [prightOneBackOnly(i)] = binomialPrediction(rand(2000,2)>0.5, 5, false,[],1);
end
ecdf(prightOneBackOnly)
grid on
legend({'pright1-2back','pleft1-2back','pright1back'})
