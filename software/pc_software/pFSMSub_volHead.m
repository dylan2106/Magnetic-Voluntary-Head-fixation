function [handles] = pFSMSub_volHead(event,handles,stage,headHoldDur,exitStates,varargin)
 %pFSMSub_volHead(event,handles,stage,headHoldDur,exitStates,var1name,var1Value,...,varNname,varNValue)
 %
 %name value pairs.
 % - odorProg - 0/1
 % - goSound - 0/1
 % - rewardProb - 0 - 1; %probability of getting a reward on volHeadRew
%parse the events into a single string based on a number of conditions
%default varaibles

nTrial = handles.user.program.nTrial;

   
if numel(varargin)>0
    for i =1: numel(varargin)/2
        %assignin('caller',varargin{(i*2) - 1},varargin{i*2})
        if isnumeric(varargin{i*2})
            eval([varargin{(i*2) - 1} '=' num2str(varargin{i*2}) ';'])
        else
           eval([varargin{(i*2) - 1} '=' char(varargin{i*2}) ';'])
        end
    end
end

if ~exist('odorProg','var');        odorProg = 0;end
if ~exist('goSound','var');         goSound = 0;end
if ~exist('rewardProb','var');      rewardProb = 1;end
if ~exist('postRewDur','var');      postRewDur = 5;end
if ~exist('LEDvolHeadWait','var');  LEDvolHeadWait = 1;end
if ~exist('waitRewTone','var');     waitRewTone = 25;end
if ~exist('waitRewToneDur','var');  waitRewToneDur = 0.5;end
if ~exist('numRewHold','var');      numRewHold = 1;end                             %number of rewards total for continued hold
if ~exist('rewHoldDurFunc','var');  rewHoldDurFunc = @()exprnd(3)+1;end            %function for generatg the intervals
if ~exist('numExtraRewFirstAttempt','var');  numExtraRewFirstAttempt = 0;end       %the number of extra rewards they get if the hold was sustained on the first attempt
if ~exist('flushResetOnIncomplete','var');  flushResetOnIncomplete = 0;end       %does the flush reset on an incomplete hold

if isempty(event)
    entering = true;
else
    entering = false; %we are not entering a state but checking an event
    events = strsplit(event,',');
end
    state = handles.user.program.state;

 
    
loc = 1; %default volutary head fix location.
frontBearings = 15; %default volutary head DIO pins
allBearings =   16; %default volutary head fix DIO pins

parsedEvent = [];

%translate the events diferrently depending on what stage of training you
%are in
if ~entering
    switch stage
        case 0
            switch events{1}
                case 'IRB';
                    if (str2num(events{2}) ==  loc);parsedEvent = 'STEP1';end
                case 'GPIO';
                    if (str2num(events{2}) ==  frontBearings);parsedEvent = 'STEP2';end
            end
        case 1
            switch events{1}
                case {'IRB','IRS'};    %NB of entering state'volHeadWait' and IRQ query is sent out This is beacuse if the nose poke and the bearings are independently coded, so we need to assertain the nose pokes curetn state
                    if (str2num(events{2}) ==  loc);parsedEvent = 'STEP0';end
                case 'GPIO';
                    if (str2num(events{2}) ==  frontBearings);parsedEvent = 'STEP1';end
                    if (str2num(events{2}) ==  allBearings);  parsedEvent = 'STEP2';end
            end
        case 2
            switch events{1}
                case {'GPIO','GPS'};
                    if (str2num(events{2}) ==  frontBearings);parsedEvent = 'STEP0';end
                    if (str2num(events{2}) ==  allBearings);  parsedEvent = 'STEP1';end
            end
    end
    
    %add the HIGH low transistion to the string
    if  ~isempty(parsedEvent);
        if  str2num(events{3})==1; parsedEvent = [parsedEvent 'H'];
        else                       parsedEvent = [parsedEvent 'L'];end
    else;parsedEvent = events{1}; %default value
    end
end


switch state
    case 'volHeadSetup'
        if entering
            if ~isfield(handles.user.program.trial(nTrial).vars,'numRewHoldRem') || ...
                    isempty(handles.user.program.trial(nTrial).vars.numRewHoldRem)
                handles.user.program.trial(nTrial).vars.numRewHoldRem = numRewHold;  
            end
            psendPacket(handles,'MOD,1,1,-70');   %turn the master volume off
            psendPacket(handles,'TON,40,1,1,1');  %start the nose in centre tone 
            %initialise the attempt counter
            handles.user.program.trial(nTrial).volHeadAttempts = 0;
            handles.user.program.trial(nTrial).volHeadAttemptTime = [];

            handles = moveto(handles,'volHeadWait');   
        end   
    case 'volHeadWait'
        if entering
            psendPacket(handles,'MOD,1,1,-70');   %turn the master volume off
            if LEDvolHeadWait == 1; psendPacket(handles,'LED,1,0,-1');end
            %send a query anout hte nose poke, if in stage 1, we need to cehck to see if we should promote to next state/
            if stage == 1;handles = pdispatch(sprintf('IRQ,%i',loc),handles);end 

        else; switch parsedEvent
                case 'STEP0H';psendPacket(handles,'LED,1,0,0'); handles = moveto(handles,'volHead0');   
                case 'STEP1H';psendPacket(handles,'LED,1,0,0'); handles = moveto(handles,'volHead1');
                case 'STEP2H';psendPacket(handles,'LED,1,0,0'); handles = moveto(handles,'volHeadRewDouble');
            end
        end
    case  'volHead0'
        if entering
            psendPacket(handles,'MOD,1,1,-5');   %turn the master volume to low
            psendPacket(handles,'MOD,2,1,-15000') %and decrease the sampling freq
            if stage == 2;handles = pdispatch(sprintf('GPQ,%i',frontBearings),handles);end %sometimes we we can miss the step0L transition, so best to check for it again here
        else; switch parsedEvent
                case 'STEP0L'; psendPacket(handles,'LED,1,0,0');handles = moveto(handles,'volHeadWait'); 
                case 'STEP1H'; handles = moveto(handles,'volHead1');
            end
        end
    case  'volHead1'
        if entering
            psendPacket(handles,'MOD,1,1,0');   %turn the master volume to normal 
            psendPacket(handles,'MOD,2,1,0'); %and set the volume to normal
            if odorProg == 1;start(handles.user.program.olfEvtObj);end
            handles.user.program.trial(nTrial).volHeadAttempts =  handles.user.program.trial(nTrial).volHeadAttempts+1;
            handles.user.program.trial(nTrial).volHeadAttemptTime =  [handles.user.program.trial(nTrial).volHeadAttemptTime now];
            psendPacket(handles,sprintf('SYN,1,%i',nTrial)); %send a trial number sync command

            startTup(handles,headHoldDur);
        else; switch parsedEvent
                case 'STEP1L'
                    %read the odor program  state, if the odor has not bee
                    %presented already, can go back donw to prev state,
                    %however if the odor has already been presented, then
                    %have to wait for the flush
                    if odorProg == 1
                        switch handles.user.program.olfEvtObj.status
                            case {'preOdor', 'idle'}
                                stop(handles.user.program.olfEvtObj);
                                if stage == 2; handles = moveto(handles,'volHead0');
                                else; handles = moveto(handles,'volHeadWait');end
                            case {'odor','flush'}
                                if flushResetOnIncomplete
                                    stop(handles.user.program.olfEvtObj);
                                    psendPacket(handles,'MOD,1,1,-70');   %turn the master volume off
                                    handles = moveto(handles,'volHeadWaitFlushRestart');
                                else
                                    hardStop(handles.user.program.olfEvtObj)
                                    handles = moveto(handles,'volHead0');
                                end
                        end
                    else
                        if stage == 2; handles = moveto(handles,'volHead0');
                        else; handles = moveto(handles,'volHeadWait');end

                    end
                  
                case 'TUP'   ;handles = moveto(handles,'volHeadRew');
                case 'STEP2H';handles = moveto(handles,'volHeadRewDouble');
            end
        end
    case 'volHeadWaitFlushRestart'
        if entering     
        else;switch events{1}
                case 'ODORFLUSHEND'
                    %if there is an odor program, set teh default to a
                    %blank stream
                    if odorProg==1;psendPacket(handles,'OLF,1,1');end
                    handles = moveto(handles,'volHeadWait');
                    %after the transition to volHeadWait, send a query
                    %about the all bearing state
                    if stage == 2;handles = pdispatch(sprintf('GPQ,%i',allBearings),handles);end %if the animal is already in all the bearings

            end
        end
        
    case 'volHeadRew' 
        if entering
            handles.user.program.trial(nTrial).volHeadOutcome = 'step1';
            handles.user.program.trial(nTrial).volHeadOutcomeTime = now;
            psendPacket(handles,'TON,0,0,0');
            if rand > (1-rewardProb)
                numGive = 1;
                %give extra reward if there was only one attempt in the
                %hold
                if handles.user.program.trial(nTrial).vars.numRewHoldRem == numRewHold && ... %we are still on the first reward
                        handles.user.program.trial(nTrial).volHeadAttempts == 1               %there was only one attempt to sustaim the hold
                    numGive = numGive+numExtraRewFirstAttempt;
                end
                giveReward(handles,loc,numGive);
            end
            
            handles.user.program.trial(nTrial).vars.numRewHoldRem = handles.user.program.trial(nTrial).vars.numRewHoldRem - 1;
            if handles.user.program.trial(nTrial).vars.numRewHoldRem > 0
                startTup(handles,rewHoldDurFunc());
            else
                if postRewDur == 0;handles = moveto(handles,'volHeadWaitStep1L');
                else; startTup(handles,postRewDur);end
            end
        else; switch parsedEvent
                case 'STEP2H';handles = moveto(handles,'volHeadRewExtra'); 
                case 'STEP1L'
                   % handles = moveto(handles,exitStates{2});          %did not hold this state for long enough
                   if goSound == 1
                       psendPacket(handles,sprintf('TON,%d,1,1,1',waitRewTone));
                       if ~isinf(waitRewToneDur)
                           set(handles.user.program.timers.toneOff,'startDelay',waitRewToneDur);
                           start(handles.user.program.timers.toneOff);
                   end; end
                   handles = moveto(handles,'volHeadWaitNosepokeL'); 
                case 'TUP' 
                    if handles.user.program.trial(nTrial).vars.numRewHoldRem > 0
                        handles = moveto(handles,'volHeadRew'); 
                    else
                        handles = moveto(handles,'volHeadWaitStep1L'); 
                    end
            end
        end 
        
    case 'volHeadRewExtra'
        if entering;giveReward(handles,loc,1);
        else; switch parsedEvent
                  case 'STEP1L';handles = moveto(handles,'volHeadWaitNosepokeL'); 
             end
        end
        
    case 'volHeadRewDouble'
        if entering
            handles.user.program.trial(nTrial).volHeadOutcome = 'step2';
            handles.user.program.trial(nTrial).volHeadOutcomeTime = now;

            psendPacket(handles,'TON,0,0,0');
            psendPacket(handles,'MOD,1,1,0');   %turn the master volume to normal 
            psendPacket(handles,'MOD,2,1,0'); %and set the volume to normal
            giveReward(handles,loc,3,100);        
        else; switch parsedEvent
                case 'STEP2L';handles = moveto(handles,'volHeadWaitNosepokeL'); end
        end
    case  'volHeadWaitStep1L'
            if entering
                if goSound == 1
                psendPacket(handles,sprintf('TON,%d,1,1,1',waitRewTone));
                if ~isinf(waitRewToneDur) 
                    set(handles.user.program.timers.toneOff,'startDelay',waitRewToneDur);
                    start(handles.user.program.timers.toneOff);
                end; end  
            else;switch parsedEvent
                   case 'STEP1L';handles = moveto(handles,'volHeadWaitNosepokeL');
                end
            end  
    case 'volHeadWaitNosepokeL'
        if entering;handles = pdispatch(sprintf('IRQ,%i',loc),handles);       
        else; switch events{1}
                case {'IRB','IRS'}
                    if str2num(events{2}) ==  loc && str2num(events{3})==0 
                        handles = moveto(handles,exitStates{1});
                    end
            end
        end    

end