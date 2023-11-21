function [correctActionDoor,incorrectActionDoor,lookUpData] = lookUpActionDoor(rewLoc,closedDoor,mazeConfig)
% [correctActionGoal] = lookUpActionDoor(rewLoc,closedDoor,mazeCofig);
% 
% retrieves the correct action door (first door after the headfix) to take
% for a given reward locaiton adn 
%
% rewLoc       - current reward location
% closedDoor   - which door is to be closed this trial, if no doors are closed pass empty (correctActionDoor will also return an empty)
% mazeCofig    - currently only 'maze1'; any changes to maze, start new one
%
%
%[correctActionGoal,lookUpData] = lookUpActionDoor(rewLoc,closedDoor,mazeCofig);
%includes all the data that go into the lookup
%fields -possRewLoc
%       -possClosedDoor
%       -correctActionDoorLookup
%       -mazeLayout                 -fprintf-able string of the mazeLayout



if nargin < 3
    mazeConfig = 'maze1';
end


switch mazeConfig
    case 'maze1'

       
 mazeLayout=['               r5    \n'...
             '  |    _r1__    |    \n'...
             '  |   |     |   |    \n'...
             '  |-1-|     |-2-|    \n'...
             '  |   |r2___|   |    \n'...
             '  6             3    \n'...
             '  |----5---4----|    \n'...
             '  |      |      |    \n'...
             '  |      |      |    \n'...
             '  r4     r3     r6   \n'];                       

        possRewLoc = [3 4 6];
        possClosedDoor = [1 2 3 4 5 6];
        %                 rewLoc    3,4,6      %closed Door
        correctActionDoorLookup =  [2,2,2;...  % 1
                                    1,1,1;...  % 2
                                    1,1,1;...  % 3
                                    1,1,2;...  % 4
                                    2,1,2;...  % 5
                                    2,2,2];    % 6
    
       %package for export                                
       lookUpData.possRewLoc              = possRewLoc;                              
       lookUpData.possClosedDoor          = possClosedDoor; 
       lookUpData.correctActionDoorLookup = correctActionDoorLookup;
       lookUpData.mazeLayout              = mazeLayout;
       
    case 'maze2'

       
 mazeLayout=[' r7            r3    \n'...
             '  |    _r1__    |    \n'...
             '  |   |     |   |    \n'...
             '  |-d1|     |d2-|    \n'...
             '  |   |r2___|   |    \n'...
             ' d6            d3    \n'...
             '  |---d5---d4---|    \n'...
             '  |      |      |    \n'...
             '  |      |      |    \n'...
             '  r6     r5     r4   \n'];                       

        possRewLoc = [3 4 5 6 7];
        possClosedDoor = [1 2 3 4 5 6];
        %                 rewLoc    3 4 5 6 7      %closed Door
        correctActionDoorLookup =  [2,2,2,2,2;...  % 1
                                    1,1,1,1,1;...  % 2
                                    2,1,1,1,1;...  % 3
                                    2,2,1,1,1;...  % 4
                                    2,2,2,1,1;...  % 5
                                    2,2,2,2,1];    % 6
    
       %package for export                                
       lookUpData.possRewLoc              = possRewLoc;                              
       lookUpData.possClosedDoor          = possClosedDoor; 
       lookUpData.correctActionDoorLookup = correctActionDoorLookup;
       lookUpData.mazeLayout              = mazeLayout;
    otherwise
        error('maze config not found')
        
end

if isempty(closedDoor)
    correctActionDoor = [];
    incorrectActionDoor = [];
else
    rewLocInd = find(possRewLoc == rewLoc);
    if isempty(rewLocInd);error('rewLoc not listed');end
    
    closedDoorInd = find(possClosedDoor == closedDoor);
    if isempty(closedDoorInd);error('closedDoor not listed');end
    
    correctActionDoor = correctActionDoorLookup(closedDoorInd,rewLocInd);
    if all(ismember(unique(correctActionDoorLookup), [1 2]))
        incorrectActionDoor = mod(correctActionDoor,2)+1;
    end
    
    end
end


