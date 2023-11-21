function[handles] = pFSM_NAFC(event,handles)

%inputs are the event and the handles structure for the GUI
%if event is empty we are entering a state

%since al;l events come through here we can log the data here


if isempty(event)
    entering = true;
else
    entering = false; %we are not entering a state but checking an event
    events = strsplit(event,',');
end


if isfield(handles,'user') && ...
        isfield(handles.user,'program') && ...
        isfield(handles.user.program,'state')
    
    state = handles.user.program.state;
else
    state = 'setup';
end

assignUIvalues(handles); %assigns all the UI values to variables in the current workspace

parsedEvent=[];

try
    nTrial = handles.user.program.nTrial;
end

%special case if event is a next trial
if ~isempty(event) && strcmp(events{1},'NEXTTRIAL')
    psendPacket(handles,'TON,0,0,0');                     %turn off
    handles.user.program.trial(nTrial).userReset = 'normal';
    
    %handles.user.program.nTrial = handles.user.program.nTrial +1;
    %handles = moveto(handles, 'trialsetup');
    handles = moveto(handles, 'trialFinish');
    return; %have to have a return in here so we do not flow down to the regular states
end
if ~isempty(event) && strcmp(events{1},'OPENALLDOORS')
    toOpen = handles.user.program.trial(1).vars.doorAddress;
    for i = 1:numel(toOpen)
        psendPacket(handles,sprintf('GPO,%i,0',toOpen(i)))
    end
    return; %have to have a return in here so we do not flow down to the regular states
end



if(strcmp(state, 'setup'))
    if entering
        disp('setting initial parameters')
        %here is the setup code
        
        %clear any previous program data
        handles.user.program = [];
        
        %assign the variables for the program
        handles.user.program.state  = 'setup';     %current state;
        
        %configure the UI elements
        %name, label, type, value, {arument pair}
        UIdata = {'rewLocations','rewLocations','edit','[4,6]',{'TooltipString','example'};...
            'odorsNum','odorsNum','edit','[4,5]',{'TooltipString','which odor'};...
            'rewLocProbs','rewLocProbs','edit','[0.5,0.5]',{'TooltipString','[0 - 1]; nan means that the location is not counted in any reward probability changes)'};...
            'trialSeqMode','trialSeqMode','popupmenu',{'randProb','debias2target','adverHistory','alternation'},{'TooltipString',''};...
            'closedDoor','closedDoor','edit','[]',{'TooltipString','which door is to remain closed during this block'};...
            'correctDoorDelay','correctDoorDelay','edit','0',{'TooltipString','s [0 - inf]; 0 no delay on the correct door(s), 0 the door openings are delayed by [] seconds '};...
            'incorrectActionDoorDelay','incorrectActionDoorDelay','edit','0',{'TooltipString','s [0 - inf]; 0 - free choice; inf - forced choice; num - time that the incorrect action door is delayed opening (following correct door)'};...
            'actionDoorsEveryTrial','actionDoorsEveryTrial','edit','0',{'TooltipString','bool - whether or not the two action doors (1 & 2) close (at reset) and open (after fixation) every trial'};...
            'wrongActionDoorReward','wrongActionDoorReward','edit','nan',{'TooltipString','[nan, number, functionHandle] - determins the number of rewards at a correct location IF the animal had initially made the wrong action door choice'};...
            'wrongActionDoorTone','wrongActionDoorTone','edit','0',{'TooltipString','tone to play on the wrong action door, eg 17 for white noise'};...
            'wrongActionDoorTimeoutDur','wrongActionDoorTimeoutDur','edit','0',{'TooltipString','[0 - real],s duration to close the correct action door if the wrong action door was chosen'};...
            'correctActionDoorTone','correctActionDoorTone','edit','0',{'TooltipString','tone to play on the correct action door, eg 37 for reward tone'};...
            'nPsuedoRand','nPsuedoRand','edit','inf',{'TooltipString','use pseudorandom trials, exact freqs in a block length of n  -inf'};...
            'repeatLastIncorrectGoal','repeatLastIncorrectGoal','edit','0',{'TooltipString','if the previous trial was incorrect the repeat that same goal on the next trial, [0 1]'};...
            'nNewRouteGoalBias','nNewRouteGoalBias','edit','nan',{'TooltipString','for a certain goal w new route, the number of other goal new route trials that must occur before the first trial of that certain goal'};
            ...%'nResponseFlip','nResponseFlip','edit','inf',{'TooltipString','if there is a run of N responses, set that option to zero probability '};...
            'advanceAfterN','advanceAfterN','edit','inf',{'TooltipString','[default inf] advance to next in seq after ntrials )'};
            'advanceAfterNcorOnly','advanceAfterNcorOnly','edit','0',{'TooltipString','whether to require N correct trials in a row'};
            'advanceSequence','advanceSequence','edit','nan',{'TooltipString','[rewLoc eg "4"] the next in the squence if advance is set, nan-random'};
            'numRewCorrect','numRewCorrect','edit','5',{'TooltipString','-number of rewards given on Correct trials'};...
            'correctionResp','correctionResp','edit','1',{'TooltipString','-bool if a correction response is allowed after an incorrect response'};...
            'numRewIncorrect','numRewIncorrect','edit','nan',{'TooltipString','-nan no difference from correct trials'};...
            'toneOnIncorrect','toneOnIncorrect','edit','17',{'TooltipString','tone to play on incorrect choice (17 white noise)'};...
            'timeOutIncorrectDur','timeOutIncorrectDur','edit','0',{'TooltipString','duration 0f timeout, 0 - no time out'};...
            'timeOutIncorrectDoorClose','timeOutIncorrectDoorClose','edit','0',{'TooltipString','close the incorrect action door for the duration of the time out'};...
            'resetReward','resetReward','edit','1',{'TooltipString','number of rewards given at reset location [0-1;2;3 ..], if [0-1] represents a probability'};...
            'resetLight','resetLight','edit','0',{'TooltipString','if the reset location should be lit'};...
            'resetOnly','resetOnly','edit','0',{'TooltipString','if only the reset location and vol head should be done'};...
            'roomLight','roomLight','edit','1',{'TooltipString','turns on room light during the response phase not for location 2'};...
            'volHeadStage','volHeadStage','edit','2',{'TooltipString','voluntary head stage','enable','off'};...
            'volHeadHoldDur','volHeadHoldDur','edit','1.5',{'TooltipString','time the state 1 should be held'};...
            'volHeadHoldNWarmUp','volHeadHoldNWarmUp','edit','15',{'TooltipString','how many trials of warmup should there be'};...
            'volHeadHoldWarmUpDur','volHeadHoldWarmUpDur','edit','0.5',{'TooltipString','the base time for warm up trials'};...
            'volHeadNumRewHold','volHeadNumRewHold','edit','1',{'TooltipString','number of rewards to give on during the hold -inf keep giving until animal leaves'};...
            'volHeadRewHoldDurFunc','volHeadRewHoldDurFunc','edit','@()exprnd(1)+0.1',{'TooltipString','function that generates the time in between rewards'};...
            'flushResetOnIncomplete','flushResetOnIncomplete','edit','0',{'TooltipString','whether an incomplete hold should go to a flush and then restet or just pause'};...
            'volHeadNumExtraRewFirstAttempt','xRew1stAttempt','edit','0',{'TooltipString','Nummber of ExtraRew if hold is made in FirstAttempt'};...
            'odorDur','odorDur','edit','1',{'TooltipString','how long the odor is presented for'};...
            'odorDelay','odorDelay','edit','0.3',{'TooltipString','delay before the odor is presented'};...
            'flushDur','flushDur','edit','3',{'TooltipString','how long the vacuum flush is applied for following an incomplete hold'};...
            'nextTrial','nextTrial','pushbutton',[],{'callback',@(~,~)pdispatch('NEXTTRIAL',guidata(handles.figure1))};...
            'userResetPoke','userResetPoke','pushbutton',[],{'callback',@(~,~)pdispatch('USERRESETPOKE',guidata(handles.figure1))};...
            'openAllDoors','openAllDoors','pushbutton',[],{'callback',@(~,~)pdispatch('OPENALLDOORS',guidata(handles.figure1))};...
            'userCuePoke','userCuePoke','pushbutton',[],{'callback',@(~,~)pdispatch('USERCUEPOKE',guidata(handles.figure1))}};
        
        [handles] = makeTaskUIelements(handles, UIdata);
        
        %write any session persistant, uneditable varibles someplace
        %separate, they will be assigned into the .vars by updateUIvalues
        %so that they will be assigned every time by assignUIvalues(
        handles.user.program.sessionVars = struct('doorAddress',[9,10,nan,nan,nan,nan],...
                                                  'doorIRAddress',[12,5,nan,nan,nan,nan],...
                                                  'resetLoc',2);
        
        [handles] = constructTUP(handles);
        [handles] = constructToneOffTimer(handles);

        %make odor event object
        handles.user.program.olfEvtObj = odorEvt(handles.figure1,1,1,1,1,1,1);
        
        set(handles.pushbuttonStartProg,'enable','on');
        
        handles.user.program.nTrial = 1;
        handles.user.program.trial = [];    %<< the trial data structure
        
    else
        %we are responding to an event
        switch events{1}
            case 'TASKSTART'
                handles = moveto(handles,'trialsetup');
        end
    end
    
elseif(strcmp(state, 'trialsetup'))
    if entering
        %psendPacket(handles,'TON,0,0,0');                     %turn off
        set(handles.trialNumberDisplay,'string',num2str(nTrial))
        fprintf('**** trial %i ******\n',nTrial)

        [handles] = updateUIvalues(handles);                    %happens once at teh start of the trial
        
        assignUIvalues(handles); %assigns all the UI values to variables in the current workspace
        
        handles.user.program.trial(nTrial).startTime = now;
        handles.user.program.trial(nTrial).outcome = [];
        handles.user.program.trial(nTrial).userReset = [];
        
        handles.user.program.trial(nTrial).responseDoorLoc = [];
        handles.user.program.trial(nTrial).responseDoorTime = [];

        handles.user.program.trial(nTrial).responseLoc = [];
        handles.user.program.trial(nTrial).responseTime = [];
        
        handles.user.program.trial(nTrial).outcome =  [];
        handles.user.program.trial(nTrial).outcomeTime =  [];
        
        %decide what the next trial goal should be
        handles = choose_next_goal(handles,trialSeqMode);
        
        %DOOR setup code
        [correctActionDoor,incorrectActionDoor,actionDoorLookUpData] = lookUpActionDoor(handles.user.program.trial(nTrial).goalLoc,closedDoor,'maze2');
        handles.user.program.trial(nTrial).correctActionDoor =   correctActionDoor;
        handles.user.program.trial(nTrial).incorrectActionDoor = incorrectActionDoor;
        handles.user.program.trial(nTrial).lookUpData = actionDoorLookUpData;
        if nTrial == 1
            fprintf(actionDoorLookUpData.mazeLayout);
        end
        %setup the door state vectors,
        %0 is open and 1 is closed        
%         doorStateBegin          state begins at reset poke              
%         doorStateResponse       state begins at end of fixation
%         doorStateResponseDelay  state begins at end of fixation + incorrectActionDoorDelay
        
         handles.user.program.trial(nTrial).doorStateResponse              = zeros(1,numel(doorAddress));%all open
         handles.user.program.trial(nTrial).doorStateResponse(closedDoor)  = 1;                          %close the closedDoor
       
        if incorrectActionDoorDelay ==0
              %free choice 
              handles.user.program.trial(nTrial).doorStateResponseDelay = nan(1,numel(doorAddress)); %timer does not exectute
       
        elseif isinf(incorrectActionDoorDelay)
              %forced choice 
              handles.user.program.trial(nTrial).doorStateResponse(incorrectActionDoor)  = 1;       %incorrectActionDoor closed
              handles.user.program.trial(nTrial).doorStateResponseDelay = nan(1,numel(doorAddress));%timer does not exectute
              
        elseif incorrectActionDoorDelay<inf
              %partial choice 
              handles.user.program.trial(nTrial).doorStateResponse(incorrectActionDoor)  = 1;          %incorrectActionDoor
              handles.user.program.trial(nTrial).doorStateResponseDelay = zeros(1,numel(doorAddress)); %all open

        end
        
         %doorStateBegin default is the same as the response period
         handles.user.program.trial(nTrial).doorStateBegin                 = handles.user.program.trial(nTrial).doorStateResponse;
         %if action doors are to close each trial just edit them
         if actionDoorsEveryTrial   
           handles.user.program.trial(nTrial).doorStateBegin([1 2])        = 1;     
         end
        
        [handles] = constructDoorOpenTimers(handles,doorAddress,repmat(incorrectActionDoorDelay,[1,numel(doorAddress)]));

        if ~isnan(nNewRouteGoalBias)
            
        end
        
        set(handles.trialTypeDisplay,'string','~');
        set(handles.goalLocDisplay,'string',num2str(handles.user.program.trial(nTrial).goalLoc));
        set(handles.odorDisplay,'string',num2str(handles.user.program.trial(nTrial).odor));

        %warm up volHead
        if nTrial <=volHeadHoldNWarmUp
            %overwrite the original user supplied value
            handles.user.program.trial(nTrial).vars.volHeadHoldDur = volHeadHoldWarmUpDur;
            %set the odor delay to zero, since the holsd is pretty
            %small
            handles.user.program.trial(nTrial).vars.odorDelay = 0;
            odorDelay = 0;
        end
        
        %program the odor timer system
        set(handles.user.program.olfEvtObj,'location',1,...
            'odorID',   handles.user.program.trial(nTrial).odor,...
            'odorDelay',odorDelay,...
            'odorDur',  odorDur,...
            'flushDur', flushDur,...
            'flushID',-1,...
            'offLoc',1,'offID',-1);            %set the resting state to be a flush, so that after the head fix is complete we are flushing the system this allows flushDur to be short so that the time out for incomlpete fixations is not as long

        handles = moveto(handles,'waitResetPoke');
        
    end
    
elseif(strcmp(state, 'waitResetPoke'))
    if entering
        assignUIvalues(handles); %assigns all the UI values to variables in the current workspace
        if isnan(resetLoc) || resetLoc ==  handles.user.program.trial(nTrial).goalLoc
             if roomLight  && handles.user.program.trial(nTrial).goalLoc ~=2
                        psendPacket(handles,'GPO,1,0');
             end
                 
            handles = moveto(handles,'volHeadSetup');
        else
             if resetLight
                  psendPacket(handles,sprintf('LED,%d,1,-1',resetLoc));
             end

        end
    else;switch events{1}
            case {'IRB', 'USERRESETPOKE'}
                
                if  strcmp(events{1},'USERRESETPOKE') || (str2num(events{2}) ==  resetLoc && str2num(events{3})==1) 
                    if roomLight  && handles.user.program.trial(nTrial).goalLoc ~=2
                        psendPacket(handles,'GPO,1,0');
                    end
                    %start the blank air flow 
                    psendPacket(handles,'OLF,1,1')
       
                    %do the doors for this trial
                    for i = 1:numel(handles.user.program.trial(nTrial).doorStateBegin)
                        if ~isnan(doorAddress(i))
                            psendPacket(handles,sprintf('GPO,%i,%i',doorAddress(i),handles.user.program.trial(nTrial).doorStateBegin(i)))
                        end
                    end
                    
                     if resetLight
                         psendPacket(handles,sprintf('LED,%d,0,0',resetLoc));
                     end
 
                    switch events{1}
                        case 'IRB'
                            if resetReward >=1;giveReward(handles,resetLoc,resetReward);    handles.user.program.trial(nTrial).resetPokeReward = resetReward;
                            elseif resetReward >0
                                if rand < resetReward;giveReward(handles,resetLoc,1);       handles.user.program.trial(nTrial).resetPokeReward = 1;
                                else;                                                       handles.user.program.trial(nTrial).resetPokeReward = 0;
                                end
                            elseif resetReward == 0;                                        handles.user.program.trial(nTrial).resetPokeReward = 0;
                            end
                            handles.user.program.trial(nTrial).resetPokeTime = now;
                                   
                            handles = moveto(handles,'waitRewReset');
                        case 'USERRESETPOKE'
                            handles = moveto(handles,'volHeadSetup');
                    end
                end
        end
    end
    
elseif(strcmp(state, 'waitRewReset'))
    if entering
    else;switch events{1}
            case 'REWEVTEND';handles = moveto(handles,'volHeadSetup');end
    end        
    
elseif(contains(state, 'volHead'))      %any of the vol headfixation states
    %[handles] = pFSMSub_volHead(event,handles,stage,headHoldDur,exitStates);
    [handles] = pFSMSub_volHeadedit(event,handles,volHeadStage,volHeadHoldDur,{'preWaitResponse','preWaitResponse'},'postRewDur',0.1,'goSound',1,'odorProg',1,'numRewHold',volHeadNumRewHold,'rewHoldDurFunc',volHeadRewHoldDurFunc,'numExtraRewFirstAttempt',volHeadNumExtraRewFirstAttempt,'flushResetOnIncomplete',flushResetOnIncomplete);

elseif(strcmp(state, 'preWaitResponse'))
        if entering
            if exist('correctDoorDelay','var') && correctDoorDelay > 0
                startTup(handles,  correctDoorDelay);
            else
                handles = moveto(handles,'waitResponse');
            end
        else;switch events{1}
                case 'TUP';handles = moveto(handles,'waitResponse');end
           
        end
elseif(strcmp(state, 'waitResponse'))
    if entering
        if resetOnly
            %skip the Reseponse phase and only go to the next trial
            handles = moveto(handles,'waitFlush');
        else
            handles.user.program.trial(nTrial).waitResponse1Time = now;
            
            %do the doors for this trial
            for i = 1:numel(handles.user.program.trial(nTrial).doorStateBegin)
                if handles.user.program.trial(nTrial).doorStateResponse(i) ~= ...
                        handles.user.program.trial(nTrial).doorStateBegin(i)
                    if ~isnan(doorAddress(i))
                        psendPacket(handles,sprintf('GPO,%i,%i',doorAddress(i),handles.user.program.trial(nTrial).doorStateResponse(i)))
                    end
                end
                %start the timer if required
                if ~isnan(doorAddress(i))
                    if incorrectActionDoorDelay>0 && ~isinf(incorrectActionDoorDelay)
                        if handles.user.program.trial(nTrial).doorStateResponse(i) ~=  ...
                                handles.user.program.trial(nTrial).doorStateResponseDelay
                            start(handles.user.program.timers.doorOpen(i));
                            %disp('starting')
                            %handles.user.program.timers.doorOpen(i)
                        end
                    end
                end
            end
            if roomLight && handles.user.program.trial(nTrial).goalLoc ~=2
                psendPacket(handles,'GPO,1,1');
            end
        end
    else
        switch events{1}
            case 'IRB'
                thisLoc = str2num(events{2});
                
                %poke at at a rewardf location
                if any(thisLoc ==  rewLocations) && str2num(events{3})==1
                    if thisLoc ==  handles.user.program.trial(nTrial).goalLoc
                        handles.user.program.trial(nTrial).responseLoc = [handles.user.program.trial(nTrial).responseLoc thisLoc];
                        handles.user.program.trial(nTrial).responseTime = [handles.user.program.trial(nTrial).responseTime now];
                        if isempty(handles.user.program.trial(nTrial).outcome)
                            handles.user.program.trial(nTrial).outcome = 'correct';
                            handles.user.program.trial(nTrial).outcomeTime = now;
                        end
                        handles = moveto(handles,'goalArrival');
                    else
                        handles.user.program.trial(nTrial).responseLoc = [handles.user.program.trial(nTrial).responseLoc thisLoc];
                        handles.user.program.trial(nTrial).responseTime = [handles.user.program.trial(nTrial).responseTime now];
                        if isempty(handles.user.program.trial(nTrial).outcome)
                            handles.user.program.trial(nTrial).outcome = 'incorrect';
                            handles.user.program.trial(nTrial).outcomeTime = now;
                            if toneOnIncorrect >0
                                psendPacket(handles,sprintf('TON,%i,1,1',toneOnIncorrect));
                            end
                        end
                        if timeOutIncorrectDur > 0
                            handles = moveto(handles,'timeOut');
                        else
                            if correctionResp == 1
                                %just allow to fall through (ie no state
                                %change)
                            else
                                %advance to the next trial
                                handles = moveto(handles,'waitFlush');
                            end
                        end
                    end
                end
            case 'GPIO'
                thisLoc = str2num(events{2});

                %poke/pass through a door    
                if any(thisLoc ==  doorIRAddress) && str2num(events{3})==1
                    
                    if isempty(handles.user.program.trial(nTrial).responseDoorLoc)
                        handles.user.program.trial(nTrial).firstDoorChoice      = find(thisLoc == doorIRAddress);
                        handles.user.program.trial(nTrial).firstDoorChoiceTime  = now;
                        
                        if handles.user.program.trial(nTrial).firstDoorChoice ==   handles.user.program.trial(nTrial).correctActionDoor
                            handles.user.program.trial(nTrial).firstDoorCorrect = true;
                            if correctActionDoorTone > 0
                                psendPacket(handles,sprintf('TON,%i,1,1',correctActionDoorTone));
                            end
                            %if 
                                
                            %end
                        %went through incorrect door    
                        elseif  handles.user.program.trial(nTrial).firstDoorChoice ==  handles.user.program.trial(nTrial).incorrectActionDoor
                            handles.user.program.trial(nTrial).firstDoorCorrect = false;
                            if wrongActionDoorTone > 0
                                 psendPacket(handles,sprintf('TON,%i,1,1',wrongActionDoorTone));
                            end
                            
                            if wrongActionDoorTimeoutDur > 0
                                  handles = moveto(handles,'wrongActionDoorTimeout');
                            end
                            
                            %timer based solution... not prefered , since there would have to be a way to not return here
                            %it would only be needed if we wanted the other door to close for both correct and incorrect action door choices  %
%                             if any(strcmp(otherActionDoorClose,{'correct','both'))
%                                 correctActionDoor = handles.user.program.trial(nTrial).correctActionDoor;
%                                 %close the door
%                                 safeCloseDoor(handles,doorAddress(correctActionDoor),doorIRAddress(correctActionDoor));
%                                 
%                                 %set the timer for the door to open 
%                                  set(handles.user.program.timers.doorOpen(handles.user.program.timers.doorOpen),'startDelay',otherActionDoorCloseDur)
%                                  start(handles.user.program.timers.doorOpen(correctActionDoor));
% 
%                                 
%                             end
                        end
                    end
                    
                    handles.user.program.trial(nTrial).responseDoorLoc = [handles.user.program.trial(nTrial).responseDoorLoc find(thisLoc == doorIRAddress)];
                    handles.user.program.trial(nTrial).responseDoorTime = [handles.user.program.trial(nTrial).responseDoorTime now];
                    
                end
        end
    end
    
elseif(strcmp(state, 'wrongActionDoorTimeout'))
    if entering
        disp('closing correct action door due to wrong choice')
        
        %close the door
        correctActionDoor = handles.user.program.trial(nTrial).correctActionDoor;
        safeCloseDoor(handles,doorAddress(correctActionDoor),doorIRAddress(correctActionDoor));
        if roomLight;psendPacket(handles,'GPO,1,0');end
        
        startTup(handles, wrongActionDoorTimeoutDur);
  
    else;switch events{1}
            case 'TUP'
                %open the door
                correctActionDoor = handles.user.program.trial(nTrial).correctActionDoor;
                psendPacket(handles,sprintf('GPO,%i,%i',doorAddress(correctActionDoor),0))
                if roomLight;psendPacket(handles,'GPO,1,1');end
                handles = moveto(handles,'waitResponse');
        end
    end


elseif(strcmp(state, 'goalArrival'))
    if entering
        switch handles.user.program.trial(nTrial).outcome
            case 'correct'
                if isnan(wrongActionDoorReward)
                    giveReward(handles,handles.user.program.trial(nTrial).goalLoc,numRewCorrect);
                else
                    if isempty(handles.user.program.trial(nTrial).responseDoorLoc) ||...   %there have been no responseDoorEvents
                               handles.user.program.trial(nTrial).firstDoorCorrect         %the first door was correct
                        giveReward(handles,handles.user.program.trial(nTrial).goalLoc,numRewCorrect);
                    else
                        giveReward(handles,handles.user.program.trial(nTrial).goalLoc,wrongActionDoorReward);
                    end
                end
            case 'incorrect'
                if     isnan(numRewIncorrect);  giveReward(handles,handles.user.program.trial(nTrial).goalLoc);
                elseif numRewIncorrect>0;       giveReward(handles,handles.user.program.trial(nTrial).goalLoc,numRewIncorrect);
                elseif numRewIncorrect==0;      handles = moveto(handles,'waitFlush');
                end
        end
        
    else;switch events{1}
            case 'REWEVTEND'; handles = moveto(handles,'waitFlush');
        end
    end
elseif(strcmp(state, 'timeOut'))
    if entering
        disp('timeOut')
        startTup(handles, timeOutIncorrectDur);
        if timeOutIncorrectDoorClose
           actionDoors = [handles.user.program.trial(nTrial).correctActionDoor...
                          handles.user.program.trial(nTrial).incorrectActionDoor];
           GPIOstate = checkGPIOState(handles);
           for d = 1:numel(actionDoors)
               safeCloseDoor(handles,doorAddress(actionDoors(d)),doorIRAddress(actionDoors(d)),GPIOstate);
           end
           if roomLight;psendPacket(handles,'GPO,1,0');end              

        end
    else;switch events{1}
            case 'TUP'
                if timeOutIncorrectDoorClose
                    actionDoors = [handles.user.program.trial(nTrial).correctActionDoor...
                                   handles.user.program.trial(nTrial).incorrectActionDoor];
                    for d = 1:numel(actionDoors)
                        psendPacket(handles,sprintf('GPO,%i,%i',doorAddress(actionDoors(d)),0))
                    end
                    if roomLight;psendPacket(handles,'GPO,1,1');end
                    
                end
                handles = moveto(handles,'waitFlush');
        end
    end
    
elseif(strcmp(state, 'waitFlush'))
    if entering;if strcmp(handles.user.program.olfEvtObj.status,'idle')
            handles = moveto(handles,'trialFinish'); end
    else;switch events{1}
            case 'ODORFLUSHEND';handles = moveto(handles,'trialFinish');
        end
    end
    
elseif(strcmp(state, 'trialFinish'))
    if entering
        
        %if any door opening  timers are still running stop them
        for i = 1:size(handles.user.program.timers.doorOpen,2)
            if strcmp(handles.user.program.timers.doorOpen(i).Running,'on')
                stop(handles.user.program.timers.doorOpen(i));
            end
        end
        
        %do the trial plotting
        hold(handles.axes1,'on');
        trial = handles.user.program.trial(1:nTrial);
        
        try
            if ~isempty(trial(nTrial).outcome) 
%                 if all(trial(nTrial).doorStateResponse([1 2]) == 0)
%                     %free choice trial
%                 else
%                     if isnan(all(isnan(trial(nTrial).doorStateResponseDelay)))
%                         %forced choice trial
%                          patch(handles.axes1,[nTrial-0.5 nTrial+0.5 nTrial+0.5 nTrial-0.5],[1 1 6 6],[0.8 0.8 0.8],'edgecolor','none');
%                     elseif all(trial(nTrial).doorStateResponseDelay([1 2]) == 0) 
%                         %slight delay
%                         patch(handles.axes1,[nTrial-0.5 nTrial+0.5 nTrial+0.5 nTrial-0.5],[1 1 6 6],[0.9 0.9 0.9],'edgecolor','none');
%                     else
%                         warning('unknown action door states')
%                     end
%                     
%                 end
            if incorrectActionDoorDelay == 0
                %free chioice
            elseif isinf(incorrectActionDoorDelay)
                %forced choice trial
                patch(handles.axes1,[nTrial-0.5 nTrial+0.5 nTrial+0.5 nTrial-0.5],[1 1 6 6],[0.8 0.8 0.8],'edgecolor','none');
            else
                %slight delay
                patch(handles.axes1,[nTrial-0.5 nTrial+0.5 nTrial+0.5 nTrial-0.5],[1 1 6 6],[0.9 0.9 0.9],'edgecolor','none');
            end
                
                plot(handles.axes1,nTrial,[trial(nTrial).goalLoc],'ko')
                switch trial(nTrial).outcome
                    case 'correct'
                        plot(handles.axes1,nTrial,trial(nTrial).responseLoc(1),'g*')
                    case 'incorrect'
                        plot(handles.axes1,nTrial,trial(nTrial).responseLoc(1),'r*')
                end
                if isfield(trial(nTrial),'firstDoorCorrect') && ~isempty(handles.user.program.trial(nTrial).responseDoorLoc)
                    if trial(nTrial).firstDoorCorrect == 0
                        plot(handles.axes1,nTrial,[trial(nTrial).goalLoc],'d','markerEdgeColor',[0.95 0.6 0.25])
                    end
                end             
                set(handles.axes1,'ylim',[1 6],'xlim',[0 nTrial+2],'ytick',sort(trial(1).vars.rewLocations))           
                
                freeChoice =arrayfun(@(x)x.vars.incorrectActionDoorDelay,trial) == 0;


                ind = arrayfun(@(x)~isempty(x.outcome),trial) & freeChoice;
                cor = strcmp({trial(ind).outcome},'correct');
                pcCorrect = sum(cor)/sum(ind);
                pVal = 1-binocdf(sum(cor),sum(ind),1/numel(trial(1).vars.rewLocations));
                choice = arrayfun(@(x)x.responseLoc(1),trial(ind));
                bias = sum(choice' == trial(1).vars.rewLocations,1)./numel(choice);
                delete(findobj(handles.axes1,'type','text'));
                %text(handles.axes1,nTrial*0.6,3.5,[sprintf('p/c Correct = %.2f (p = %.3f) \n',pcCorrect,pVal) 'bias=' sprintf(' %.2f',bias)])
                text(handles.axes1,nTrial*0.6,3.5,[sprintf('p/c Correct = %.2f\n',pcCorrect) 'bias=' sprintf(' %.2f',bias)])
                hold(handles.axes1,'off');
            end
        end
        
        %autosave every 10 trials
        if rem(handles.user.program.nTrial,10) == 0
            outcome = autoSaveTrial(handles);
            if outcome == 0
                warning('auto save not sucessful')
            end
        end
        
        %advance the trial counter
        handles.user.program.nTrial = handles.user.program.nTrial +1;
        handles = moveto(handles,'trialsetup');
        
    end
    
elseif(strcmp(state, 'finish'))
    %we only enter here once
    disp('finishing task')
    try
        psendPacket(handles,'TON,0,0,0');                     %turn off
        psendPacket(handles	,'LED,0,0,0');                     %turn off
        psendPacket(handles ,'OLF,0,0');
    end
    
    %open the two doors
    psendPacket(handles,sprintf('GPO,%i,%i',handles.user.program.sessionVars.doorAddress(1),0))
    psendPacket(handles,sprintf('GPO,%i,%i',handles.user.program.sessionVars.doorAddress(2),0))

    
    
    handles = finishTasks(handles);
    
else
    state
    error('invalid state')
    
end

guidata(handles.figure1,handles);

end

function handles = choose_next_goal(handles,trialSeqModeFunc)
        assignUIvalues(handles); %assigns all the UI values to variables in the current workspace
        nTrial = handles.user.program.nTrial;


        switch trialSeqModeFunc
             case {'randProb','debias2target'}
                 if isinf(nPsuedoRand)
                     
                     if strcmp(trialSeqModeFunc,'debias2target')
                         warning('cannot debias2target without using psuedo blocks')
                         warning('implementing randProb')
                         %need to  make it change the actual gui here.
                     end
                     
                     %ind = randi(n);
                     %randomly select the trial type based on the probabilities
                     %here
                     if nansum(rewLocProbs) == 1
                         rewLocProbsScaled = rewLocProbs;
                     elseif abs(nansum(rewLocProbs) - 1) <= 0.01
                         rewLocProbsScaled = rewLocProbs./nansum(rewLocProbs);
                     else
                         warning('rewLocProbs do not sum to 1, scaling to sum to 1')
                         rewLocProbsScaled = rewLocProbs./nansum(rewLocProbs);
                     end
                     
                     %advanceAfterNCorrect
                     if  (nTrial > advanceAfterN && ~isinf(advanceAfterN)) 
                         
                         prevOutcome = {handles.user.program.trial(nTrial-advanceAfterN : nTrial-1).outcome};
                         prevGoals = [handles.user.program.trial(nTrial-advanceAfterN : nTrial-1).goalLoc];
                         prevInd = arrayfun(@(x)find(x==rewLocations),prevGoals);
                         
                         if advanceAfterNcorOnly == 1
                             testCond = all(strcmp(prevOutcome,'correct')) && numel(unique(prevInd)) == 1;
                         else
                             testCond = numel(unique(prevInd)) == 1;
                         end
                         
                         %if the text condition was true
                         if testCond
                             
                             %rewLocProbsScaled = 1 - rewLocProbsScaled;
                             rewLocProbsScaled = zeros(size(rewLocProbsScaled));
                             
                             %find what reward location is next
                             if  isempty(advanceSequence) || isnan(advanceSequence(1))
                                 next = rewLocations(randi(numel(rewLocations)));
                             else
                                 next = advanceSequence(1);
                             end
                         
                             
                             if sum(next == rewLocations)  == 0
                                 next = rewLocations(randi(numel(rewLocations)));
                                 warning('next in sequence is nont a location, randomly selecting from list')
                             end
                             rewLocProbsScaled(next == rewLocations) = 1;
                             
                             %delete this entry
                             advanceSequence(1) = [];
                             
                             %if it is empty then choose the current 
                             if isempty(advanceSequence)
                                 advanceSequence(1) = prevGoals(1);
                             end
                             
                             %need to also write this new value to the gui and
                             %the data structure
                             [handles] = updateUIvalues(handles,'rewLocProbs',num2str(rewLocProbsScaled));
                             [handles] = updateUIvalues(handles,'advanceSequence',num2str(advanceSequence));
  
                         end
                     end
                     
                     rewLocProbsScaled(isnan(rewLocProbsScaled)) = 0;                     
                     goalInd = find(rand < cumsum(rewLocProbsScaled),1,'first');

                    handles.user.program.trial(nTrial).goalLoc = rewLocations(goalInd);
                    handles.user.program.trial(nTrial).odor = odorsNum(goalInd);
                    
                 else
                     %%%psuedoRandom random trials%%
                     
                     %check to see if the rewLocProbs has changed, from the
                     %previous trial
                     if nTrial>1 && any(handles.user.program.trial(nTrial-1).vars.rewLocProbs ~= rewLocProbs & ~isnan(rewLocProbs))
                         disp('rewProbs changed')
                         %if so then we will empty out all the future trials of
                         %any preallocated goal locations
                         for j = nTrial:numel(handles.user.program.trial)
                             handles.user.program.trial(j).goalLoc = []; handles.user.program.trial(j).odor    = [];
                         end
                     end
                     
                     % check to see if the closed door has changed, if so generate
                     % new goals
                     if nTrial>1 &&  handles.user.program.trial(nTrial).vars.closedDoor ~=  handles.user.program.trial(nTrial-1).vars.closedDoor
                         disp('closed door changed')
                         for j = nTrial:numel(handles.user.program.trial)
                             handles.user.program.trial(j).goalLoc = []; handles.user.program.trial(j).odor    = [];
                         end
                     end
                     
                     %check to see if trialSeqModeFunc has changed
                      if nTrial>1 && ~strcmp(trialSeqModeFunc,handles.user.program.trial(nTrial - 1).vars.trialSeqMode)
                         disp('trialSeqModeFunc')
                         for j = nTrial:numel(handles.user.program.trial)
                             handles.user.program.trial(j).goalLoc = []; handles.user.program.trial(j).odor    = [];
                         end
                      end
                     
                     %lookup to see if there is a goal preallocated for this
                     %trial
                     if ~isfield(handles.user.program.trial(nTrial),'goalLoc') || ... %if it is not a field OR
                             isempty(handles.user.program.trial(nTrial).goalLoc)           %it is empty
                         
                         %need to generate a new psuedorandom block of
                         %trials
                         disp('generating new psuedo block')
                         switch trialSeqModeFunc
                             case'randProb'
                                 n = sum(~isnan(rewLocProbs) & rewLocProbs>0);
                                % nPsuedoRandActual = floor(nPsuedoRand/n) * n;
                                 nPsuedoRandActual = nPsuedoRand;
                                 
                                 %update the UI field here if needed
                                 if nPsuedoRandActual ~= nPsuedoRand
                                    [handles] = updateUIvalues(handles,'nPsuedoRand',nPsuedoRandActual);
                                 end
                                 
                                 if nPsuedoRandActual < n; error('too small value for nPsuedoRand');end
                                 rewLocProbs(isnan(rewLocProbs)) =0;
                                 rewLocProbs = rewLocProbs./(sum(rewLocProbs));
                                 rewIndFreqs = round(rewLocProbs*nPsuedoRandActual)

                             case 'debias2target'
                                 if nTrial < nPsuedoRand
                                     handles = choose_next_goal(handles,'randProb');
                                     return;
                                 elseif nTrial>1 &&  handles.user.program.trial(nTrial).vars.closedDoor ~=  handles.user.program.trial(nTrial-1).vars.closedDoor
                                     disp('first pseudoblock for new closed door state defaulting to randProb')
                                     handles = choose_next_goal(handles,'randProb');
                                     return;
                                 end
                                 disp('using debias2target to adjust probabilities')
                                 %look back in the last psuedoblock to calculate teh previous observed values
                                 ind = find(arrayfun(@(x)~isempty(x.outcome),handles.user.program.trial(1:nTrial-1)) ...           %valid trials
                                          & arrayfun(@(x)x.vars.closedDoor,handles.user.program.trial(1:nTrial-1)) == closedDoor); %with the same closed door
                                 
                                 if numel(ind) >= nPsuedoRand
                                     indUse = ind(end-nPsuedoRand+1:end);
                                 else
                                     handles = choose_next_goal(handles,'randProb');
                                     return;
                                 end
                                 
                                 observedLoc = [handles.user.program.trial(indUse).responseLoc];
                                 for j = 1:numel(rewLocations)
                                    observed(j) =  sum(observedLoc == rewLocations(j));
                                 end
                                 observed = observed./nansum(observed);
                                 rewLocProbs = debias2target(rewLocProbs, observed, -0.5);
                                 disp('new reward location probabilities')
                                 disp(rewLocProbs)
                                 %we need to do a slightly different conversion of reward loc probabilities
                                 %into frequencies here, since we are goingto be dealing with more intermeadiate
                                 %probability values that will not factor into nPsuedo properly
                                 nPsuedoRandActual = nPsuedoRand;
                                 realFreqs = rewLocProbs * nPsuedoRand;    %frequencies in real numbers (not just integers)         
                                 remFreqsProb = rem(realFreqs,1);          %the left over number of trials split between options
                                 nRem = round(sum(remFreqsProb));
                                 remFreqs = sum(diff(cat(2,zeros(nRem,1) ,(rand(nRem,1)*nRem)<cumsum(remFreqsProb)),1,2),1);
                                 
                                 handles.user.program.trial(nTrial).vars.rewLocProbsSeqMode = rewLocProbs; %if we used the debiasing, then save the actual probabilities
                             
                                 rewIndFreqs = floor(realFreqs)  + remFreqs;
                         end
                         
                         rewIndList = [];
                         for j = 1:numel(rewIndFreqs)
                             rewIndList  = [rewIndList repmat(j, 1,rewIndFreqs(j))];
                         end
                         rewIndList = rewIndList(randperm(nPsuedoRandActual)); %dhuffle the list
                         
                         %if we want to bias the goal order distribution to enhance
                         %the number of trials of experience with a certain world
                         %state
                         %must be a new closed dor block
                         try
                             if ~isnan(nNewRouteGoalBias)
                                 if nTrial==1 ||   handles.user.program.trial(nTrial).vars.closedDoor ~=   handles.user.program.trial(nTrial-1).vars.closedDoor
                                     if nNewRouteGoalBias<min(rewIndFreqs)
                                         if nTrial > 1
                                             trial  = handles.user.program.trial;
                                             [~,~,lookUpData] = lookUpActionDoor([],[],'maze1');
                                             correctActionDoor(1,:) = lookUpData.correctActionDoorLookup(lookUpData.possClosedDoor == trial(nTrial-1).vars.closedDoor,:);
                                             correctActionDoor(2,:) = lookUpData.correctActionDoorLookup(lookUpData.possClosedDoor == trial(nTrial).vars.closedDoor,:);
                                             correctActionDoorChanged = find(diff(correctActionDoor,1,1)~=0);
                                         else
                                             %first trial, all are changed
                                             correctActionDoorChanged = 1:numel(rewLocations);
                                         end
                                         
                                         if numel(correctActionDoorChanged)>1  %must be more than one goal location to have a change of action door
                                             %choose a certainRew location
                                             certainRew = correctActionDoorChanged(randi(numel(correctActionDoorChanged)));
                                             
                                             %find the number of prev action change, not certain rew trial
                                             numPrevTrials = cumsum(ismember(rewIndList,correctActionDoorChanged) & certainRew ~= rewIndList);
                                             move2end = numPrevTrials<nNewRouteGoalBias & rewIndList == certainRew;    %find trials that need to moved to the end
                                             startOfEnd = find(numPrevTrials==nNewRouteGoalBias,1,'first')+1;          %find the index of the start of the end
                                             rewIndListNew = rewIndList;
                                             rewIndListNew(move2end) = nan;                                            %blank the ones you want to move
                                             rewIndListNew = [rewIndListNew repmat(certainRew ,1,sum(move2end))];      %add them to the end of the list
                                             rewIndListTail = rewIndListNew(startOfEnd:end);                           %shuffle the end block  of teh list
                                             rewIndListNew(startOfEnd:end) =  rewIndListTail(randperm(numel(rewIndListTail)));%insert into teh list
                                             rewIndListNew(isnan(rewIndListNew)) = [];                                 %remove nans
                                             %plot(1:numel(rewIndListNew),rewIndListNew,'o');ylim([0 4])               %test plotting
                                             rewIndList = rewIndListNew;
                                         end
                                     else
                                         warning('nNewRouteGoalBias ids greater than indidivual goal frequencies, not applying biasing')
                                     end
                                 end
                             end
                         catch
                             warning('cant evaulate nNewRouteGoalBias block')
                         end
                         
                         for j = 1:nPsuedoRandActual
                             handles.user.program.trial(nTrial+j-1).goalLoc = rewLocations(rewIndList(j));
                             handles.user.program.trial(nTrial+j-1).odor =        odorsNum(rewIndList(j));
                             
                         end
                     else
                         %just continue, using whatever data is in there
                     end
%                      %generate the goal index (which is referenced later)
%                      goalInd = find(handles.user.program.trial(nTrial).goalLoc == rewLocations);
                 end
                 
            case 'adverHistory'
                %clear out any following trials that may have been preallocated from previous control modes
                if numel(handles.user.program.trial)>nTrial
                    handles.user.program.trial = handles.user.program.trial(1:nTrial);
                end
                
                %only take valid trials;
                takeT = arrayfun(@(x)~isempty(x.outcome),handles.user.program.trial);
                
                %for all prevoius trials check to see what reward locations
                %there are.
                rewLocsPrev = arrayfun(@(x)x.vars.rewLocations,handles.user.program.trial(takeT),'uni',0)';
                rewLocsPrev = cat(1,rewLocsPrev{:});
                rewLocsPrevUniq = unique(rewLocsPrev,'rows');
                
                if ~(size(rewLocsPrevUniq,1) == 1 && size(rewLocsPrevUniq,2) == 2 )  %can only operate if there were only two previous goals
                    warning('too many goal locations to implment adverserial history, reverting to randProb')
                    handles = choose_next_goal(handles,'randProb');
                    return;
                elseif nTrial==1
                    handles = choose_next_goal(handles,'randProb');
                    return;
                else
                    try
                        choices = [handles.user.program.trial(takeT).responseLoc]' == rewLocsPrevUniq(2);
                        outcomes = strcmp({handles.user.program.trial(takeT).outcome},'correct')';
                        %[lPort, rPort, lProb, rProb, choice] = binomialPrediction([choices outcomes],[],[],[],1);
                        [portProb]  = adverserialPrediction(choices, outcomes,2);
                        if isnan(portProb(1))
                            fprintf('reverting to random probabilities\n')
                            handles = choose_next_goal(handles,'randProb');
                            return;
                        end
                        goalInd = find(rand < cumsum(portProb),1,'first');
                        fprintf('new averserial probs = ');
                        fprintf('%.2f,',portProb);
                        fprintf('\n');

                        handles.user.program.trial(nTrial).vars.rewLocProbsSeqMode = portProb;  %save the probailities in the vars structure
                        handles.user.program.trial(nTrial).goalLoc = rewLocations(goalInd);
                        handles.user.program.trial(nTrial).odor = odorsNum(goalInd);
                    catch
                        warning('unable to run adversserial debiasing, reverting to randProb')
                        handles = choose_next_goal(handles,'randProb');
                        return;
                    end
                end 
                
           case 'alternation'
                %this debiaser corrects alternation by first calculating
                %an alternation index and then ussing that to vias the
                %next trial.
                backWindow = 10;
                %only take valid trials;
                takeT = arrayfun(@(x)~isempty(x.outcome),handles.user.program.trial);
                
                %for all prevoius trials check to see what reward locations
                %there are.
                rewLocsPrev = arrayfun(@(x)x.vars.rewLocations,handles.user.program.trial(takeT),'uni',0)';
                rewLocsPrev = cat(1,rewLocsPrev{:});
                rewLocsPrevUniq = unique(rewLocsPrev,'rows');
                
                if ~(size(rewLocsPrevUniq,1) == 1 && size(rewLocsPrevUniq,2) == 2 )  %can only operate if there were only two previous goals
                    warning('too many goal locations to implment alternation, reverting to randProb')
                    handles = choose_next_goal(handles,'randProb');
                    return;
                elseif nTrial<backWindow
                    handles = choose_next_goal(handles,'randProb');
                    return;
                else
                    choices = [handles.user.program.trial(takeT).responseLoc]' == rewLocsPrevUniq(2);
                    choices = choices(end-(backWindow-1):end);
                    
                    altScore = sum(diff(choices)~=0)./backWindow;     %positive alternation score indicates likelihood of switching
                    fprintf('alternation score in last %i trials = %.2f\n',backWindow,altScore )
                    if rand < altScore
                        %stay on the same goal    %add one to make an index
                        goalInd = choices(end)     +1;
                    else
                        %switch to the other goal
                        goalInd = mod(choices(end)+1,2) +  1;
                    end
                     
                     handles.user.program.trial(nTrial).goalLoc = rewLocations(goalInd);
                     handles.user.program.trial(nTrial).odor = odorsNum(goalInd);
                end
                
         
        
        end

        %if last trial was incorrect then repeat goal location
        if repeatLastIncorrectGoal && nTrial>1 && strcmp(handles.user.program.trial(nTrial-1).outcome,'incorrect')
            %starting from the end shift any future trials one step into
            %the future, and do  this up to and including the previous
            %trial.
            disp('repeating last incorrect goal location')
            for nT = numel(handles.user.program.trial):-1:(nTrial-1)
                handles.user.program.trial(nT+1).goalLoc = handles.user.program.trial(nT).goalLoc;
                handles.user.program.trial(nT+1).odor = handles.user.program.trial(nT).odor;
            end
        end
end
