%simpleGoalGenerator
%This goal generator only tries to balance 2 location 2 odors with 3 doors,
%presenting all combinations
% a thrid lcoation has got an equal number of each odor, but is not
% balanced
%

thirdLoc = repmat([1 2]',12,1);

T = [[3 3 3 3 4 4 4 4 5 5 5 5]' repmat([1 1; 1 2; 2 1; 2 2],3,1) thirdLoc(randperm(12))];
Tmix = T(randperm(12),:);
while any(diff(Tmix(:,1)) == 0)
    Tmix = T(randperm(12),:);

end
Tmix