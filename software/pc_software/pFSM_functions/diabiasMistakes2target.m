function output = diabiasMistakes2target(target,goal,choices)
%
%
%this function gives out a new proportion of
%target    - 1xN array that sums to 1, each elemen is the goal proportion 
%             eg [0.3 0.2 0.5]
%goal      - 1xK array of the goal indexes for the goal
%choice    - 1xK array of the goal indexes for the choice
%outcome   - 1xK array [1 correct, 0 incorrect]

outcome = goal == choices;

nBlock = numel(goal);
mistakes = zeros(size(target));

output = nan(size(target));
for i = 1:numel(target)
    mistakes(i) = sum(goal == i & outcome == 0);
    output(i) = target(i) + mistakes(i)./nBlock;
end

output = output./sum(output);

