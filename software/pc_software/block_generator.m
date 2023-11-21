
%%
%this script generates a block settings that a psuedorandom and balanced
%for the door transistion and the two location (loc4 and 5) odor changes.
%such that every block transition has an instance of a paritcualr odorant
%change 

%enumerate the possoble transitions between door closed blocks
trans = repmat([3 4; 3 5; 4 3; 4 5; 5 3; 5 4],2,1);

%enumerate the four combinations of odor changing for the two goals
odorChangeInd = repmat([1 2 3 4],6,1);
odorChangeLookup = [0 0; 0 1; 1 0; 1 1];

%circ shit each row, which corresponds to a particular door closed
%transition, this ensures that each door closed block transition (6) has
%each one of the odor change combinations (4), but the order is scrambled
%throughout the 6*4 block transitions.

for i = 1:size(odorChangeInd,1)
    odorChangeInd(i,:) = circshift(odorChangeInd(i,:),randi(4));
end

odorChangeInd =odorChangeInd(:);            %each set of door transitions gets a odorant ind
indTransSave = [];
indOdorSave = [];

for i = 1: (24 ./ size(trans,1))
    flag = true;
    
    while flag
        
        
        if i == 1
            ind = randperm(size(trans,1));
            
        else
            %have an additional constraint that the last door closed block
            %matches the next first one
            final = trans(indTransSave(end),2);
            firstOptions  = find(trans(:,1) == final);
            firstChoose =  firstOptions(randi(numel(firstOptions)));
            
            ind = randperm(size(trans,1));
            ind(ind ==firstChoose) = [];
            ind = [firstChoose ind];
            
        end
        propTrans = trans(ind,:)';
        tempDiff = diff(propTrans(:));
        
        if all(tempDiff(2:2:end) ==0 )
            propTrans
            indTransSave =  [indTransSave ind];
            indOdorSave =   [indOdorSave ind+((i-1)*size(ind,2))];
            flag = false;
        end
        
    end
end

[trans(indTransSave,:) odorChangeInd(indOdorSave)]

%convert the changes into actual block level settings
door = nan(numel( indTransSave)+1,1);
door(1) = trans(indTransSave(1),1);
door(2:end) = trans(indTransSave,2);

odor = nan(numel(indTransSave)+1,2);        %need one more block than we have transitions
odor(1,:) = randi(2,1,2)-1;                 %first block is randomly initiated
for i = 1:numel(indOdorSave)
    odor(i+1,:) = mod(odor(i,:) + odorChangeLookup(odorChangeInd(indOdorSave(i)),:),2);    
end

[door odor]
loc6Odor = cat(1,zeros(13,1) ,ones(12,1));
loc6Odor = loc6Odor(randperm(25));
T = table(door, odor(:,1)+1,odor(:,2)+1,loc6Odor+1,...
          'VariableNames',{'doorClosed','loc4','loc5','loc6'})
 sum(odor,1)

%%