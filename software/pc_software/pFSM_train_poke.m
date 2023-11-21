function[handles] = pFSM_train_poke(event,handles)

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
    handles = moveto(handles, 'reset');
    return; %have to have a return in here so we do not flow down to the regular states
end

switch state
    case 'setup'
        if entering
            disp('setting initial parameters for alternation')
            %here is the setup code
            
            %clear any previous program data
            handles.user.program = [];

            %assign the variables for the program
            handles.user.program.state  = 'setup';     %current state;
              
            %configure the UI elements
            %name, label, type, value, {arument pair}
            UIdata = {'rewLocation','rewLocation','edit','2',{'TooltipString','example'};...
                      'cueLocation','cueLocation','edit','1',{'TooltipString','example'};...
                     'ITIDur','ITIDur','edit','1',{'TooltipString','can enter range eg 0-2'};...
                     'pokeInHoldTime','poke hold','edit','0.05',{'TooltipString','length of time a poke must be held'};...
                     'cuePoke','cue poke','edit','1',{'TooltipString','whether we need a cue poke to start reward availibility'};...
                     'cuePokeWaitDur','cuePokeWaitDur','edit','inf',{'TooltipString','time to wait for before exiting cuePokeWait'};...
                     'cuePokeWaitReset','cuePokeWaitReset','edit','1',{'TooltipString','0-noreset,1-reset cuePokeWait'};...
                     'cuePokeWaitAir','cuePokeWaitAir','edit','1',{'TooltipString','present black air during cue poke wait'};...
                     'cuePokeWaitRew','cuePokeWaitRew','edit','0',{'TooltipString','give a reward at the start of cue poke wait (only if last trial was a cue poke and correct)'};...
                     'cuePokeRew','cuePokeRew','edit','1',{'TooltipString','give a reward at the start of cue poke wait (only if last trial was a cue poke and correct)'};...
                     'volHeadRewProb','volHeadRewProb','edit','1',{'TooltipString','probability of a reward at the end of voleHead'};...
                     'rewPokeWaitDur','rewPokeWaitDur','edit','20',{'TooltipString','time to wait for before exiting rewPokeWait'};...
                     'waitRewTone','waitRewTone','edit','25',{'TooltipString','tone index for reward availibility'};...
                     'waitRewToneDur','waitRewToneDur','edit','0.5',{'TooltipString','tone duration for reward availibility'};...
                     'waitRewLED','waitRewLED','edit','0',{'TooltipString','LED on for reward availibility 0/1'};...
                     'volHeadEn','volHeadEn','edit','0',{'TooltipString','enable voluntary head positioning'};...
                     'volHeadStage','volHeadStage','edit','0',{'TooltipString','voluntary head stage'};...
                     'volHeadHoldDur','volHeadHoldDur','edit','0.1',{'TooltipString','time the state 1 should be held'};...
                     'volHeadNumRewHold','volHeadNumRewHold','edit','1',{'TooltipString','number of rewards to give on during the hold -inf keep giving until animal leaves'};...
                     'volHeadRewHoldDurFunc','volHeadRewHoldDurFunc','edit','@()exprnd(1)+0.1',{'TooltipString','function that generates the time in between rewards'};...
                     'nextTrial','nextTrial','pushbutton',[],{'callback',@(~,~)pdispatch('NEXTTRIAL',guidata(handles.figure1))};...
                     'userCuePoke','userCuePoke','pushbutton',[],{'callback',@(~,~)pdispatch('USERCUEPOKE',guidata(handles.figure1))}};
                                   

            [handles] = makeTaskUIelements(handles, UIdata);
            [handles] = constructTUP(handles);
             
            [handles] = constructToneOffTimer(handles);
            
            set(handles.pushbuttonStartProg,'enable','on');

            handles.user.program.nTrial = 1;
            handles.user.program.trial = [];    %<< the trial date structure
            

        else
            %we are responding to an event
            switch events{1}
                case 'TASKSTART'
                        handles = moveto(handles,'trialsetup');  
            end            
        end
        
    case 'trialsetup'
          if entering
              psendPacket(handles,'TON,0,0,0');                     %turn off
              set(handles.trialNumberDisplay,'string',num2str(nTrial))
              [handles] = updateUIvalues(handles);
              handles.user.program.trial(nTrial).startTime = now;
              handles = moveto(handles,'ITI');
          end
          
    case 'ITI' 
        if entering; startTup(handles,ITIDur);
        else;switch events{1}
                case 'TUP'
                    if      cuePoke == 0;handles = moveto(handles,'waitRewPoke');
                    elseif  cuePoke == 1
                        if cuePokeWaitAir == 1;psendPacket(handles,'OLF,1,1');end
                        if cuePokeWaitRew == 1
                            if  nTrial == 1 || ( strcmp(handles.user.program.trial(nTrial-1).outcome,'correct') ...
                                    && strcmp(handles.user.program.trial(nTrial-1).waitCueEnd,'cuePoke'))
                                giveReward(handles,cueLocation,1);
                        end;end
                        if volHeadEn
                            handles = moveto(handles,'volHeadSetup');
                        else
                           handles = moveto(handles,'waitCuePoke');
                        end
                    end
            end
        end
        
    case {'volHeadSetup','volHeadWait','volHead0','volHead1','volHeadRew','volHeadRewExtra','volHeadRewDouble','volHeadWaitStep1L','volHeadWaitNosepokeL'}
        %[handles] = pFSMSub_volHead(event,handles,stage,headHoldDur,exitStates);
        [handles] = pFSMSub_volHead(event,handles,volHeadStage,volHeadHoldDur,{'waitRewPoke','waitRewPoke'},'numRewHold',volHeadNumRewHold,'rewHoldDurFunc',volHeadRewHoldDurFunc);
        
    case 'waitCuePoke'
        if entering;startTup(handles,cuePokeWaitDur);
           
        else; switch events{1}
                case 'TUP';         handles = moveto(handles,'waitRewPoke');
                                    handles.user.program.trial(nTrial).waitCueEnd = 'tup';
                case 'USERCUEPOKE'; handles = moveto(handles,'waitRewPoke');
                                    handles.user.program.trial(nTrial).waitCueEnd = 'user';
                case 'IRB'
                      if(str2num(events{2}) ==  cueLocation) && str2num(events{3})==1
                          if cuePokeRew == 1;giveReward(handles,cueLocation,1); end
                          handles.user.program.trial(nTrial).waitCueEnd = 'cuePoke';
                          handles = moveto(handles,'waitRewPoke');
                      elseif (str2num(events{2}) == rewLocation) && str2num(events{3})==1
                          if cuePokeWaitReset == 1; handles = moveto(handles,'resetWaitCuePoke');end
                      end
              end
        end
    case 'resetWaitCuePoke'
        if entering
        else; switch events{1}
                case 'IRB'
                    if (str2num(events{2}) == rewLocation) && str2num(events{3})==0
                        handles = moveto(handles,'waitCuePoke');
                    end
            end
        end
    case 'waitRewPoke'
        if entering; startTup(handles,rewPokeWaitDur);
            if cuePokeWaitAir == 1;psendPacket(handles,'OLF,0,0');end
            handles.user.program.trial(nTrial).waitRewPokeTime = now;
            if waitRewLED == 1;psendPacket(handles,sprintf('LED,%d,1,-1',rewLocation));  end
            if waitRewTone > 0
                psendPacket(handles,sprintf('TON,%d,1,1,1',waitRewTone));
                if ~isinf(waitRewToneDur) 
                    set(handles.user.program.timers.toneOff,'startDelay',waitRewToneDur);
                    start(handles.user.program.timers.toneOff);
                end
            end  %turn on 
        else;switch events{1}
                case 'TUP'
                    stop(handles.user.program.timers.toneOff);
                    psendPacket(handles,sprintf('LED,%d,1,0',rewLocation));  %turn off 
                    psendPacket(handles,'TON,25,1,0,0');                     %turn off
                    handles.user.program.trial(nTrial).outcome = 'noResponse';
                    handles.user.program.trial(nTrial).outcomeTime = now;
                    handles = moveto(handles,'reset');
                case 'IRB'                    
                    if str2num(events{2}) ==  rewLocation && str2num(events{3})==1 
                        stop(handles.user.program.timers.toneOff);
                        psendPacket(handles,sprintf('LED,%d,1,0',rewLocation));  %turn off 
                        psendPacket(handles,'TON,25,1,0,0');                     %turn off 
                        handles = moveto(handles,'pokeIn');
                    
                    %next two cases are to turn off the led if hte animal makes another headfix
                    %although no FSM contigency, it will still be recording
                    %data we do not want contaminated
                    elseif str2num(events{2}) ==  1 && str2num(events{3})==1          %vol head poke in
                         psendPacket(handles,sprintf('LED,%d,1,0',rewLocation));  %turn off 
                    elseif str2num(events{2}) ==  1 && str2num(events{3})==0          %vol head poke out
                        if waitRewLED == 1;psendPacket(handles,sprintf('LED,%d,1,-1',rewLocation));  end

                    end
            end
        end
        
    case 'pokeIn'
        if entering; startTup(handles,pokeInHoldTime);
        else;switch events{1}
                case 'TUP';handles = moveto(handles,'reward');
%                 case 'IRB'
%                     loc = str2num(events{2});
%                     if loc ==  rewLocation && str2num(events{3})==0 %poke out at goal location
%                          handles = moveto(handles,'waitRewPoke');
%                     end                    
            end
        end
        
    case 'reward'
        
        if entering
            giveReward(handles,rewLocation);
            handles.user.program.trial(nTrial).outcome = 'correct';
            handles.user.program.trial(nTrial).outcomeTime = now;
        else;switch events{1}
                case 'REWEVTEND'; handles = moveto(handles,'waitLeaveRew');

%                
            end
        end
        
    case 'waitLeaveRew'
        if entering
            handles = pdispatch(sprintf('IRQ,%i',rewLocation),handles);
        else;switch events{1}
                case {'IRB','IRS'}
                    loc = str2num(events{2});
                    if loc ==  rewLocation && str2num(events{3})==0 %poke out at goal location
                        handles = moveto(handles,'reset');
                    end
            end
        end
        
    case 'reset'
        if entering
%             %advance to the next goal
%             prevGoal = handles.user.program.goal;
%             handles.user.program.goal = handles.user.program.nextGoal;
%             handles.user.program.nextGoal(1) = [];
%             handles.user.program.nextGoal = [handles.user.program.nextGoal prevGoal]; %add to the end of the list
%             
            %advance the trial counter
            handles.user.program.nTrial = handles.user.program.nTrial +1;  
            handles = moveto(handles,'trialsetup');

        end
        
    case 'finish'
        %we only enter here once
        disp('finishing task')
        psendPacket(handles,'TON,0,0,0');                     %turn off

        handles = finishTasks(handles);
        
    otherwise
        state
        error('invalid state')
        
end

guidata(handles.figure1,handles);

end

 
 