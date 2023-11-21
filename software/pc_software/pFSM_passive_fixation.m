function[handles] = pFSM_passive_fixation(event,handles)

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
            UIdata = {'ITIDur','ITIDur','edit','1',{'TooltipString','duration of ITI'};...
                     'headHoldDur','headHoldDur','edit','2',{'TooltipString','time the state 1 should be held'};...
                     'stage','stage','edit','0',{'TooltipString','vole head pos stage'};...
                     'numRewHold','numRewHold','edit','1',{'TooltipString','number of rewards to give on during the hold -inf keep giving until animal leaves'};...
                     'rewHoldDurFunc','rewHoldDurFunc','edit','@()exprnd(1)+0.1',{'TooltipString','function that generates the time in between rewards'};...
                     'nextTrial','nextTrial','pushbutton',[],{'callback',@(~,~)pdispatch('NEXTTRIAL',guidata(handles.figure1))}};
                                   

            [handles] = makeTaskUIelements(handles, UIdata);
            [handles] = constructTUP(handles);
             
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
              set(handles.trialNumberDisplay,'string',num2str(handles.user.program.nTrial))
              [handles] = updateUIvalues(handles);
              handles = moveto(handles,'ITI');
          end
          
    case 'ITI' 
        if entering
            startTup(handles,ITIDur);
        else; switch events{1}
                case 'IRB'
                    if str2num(events{2}) ==  1 && str2num(events{3})==1
                       handles = moveto(handles, 'ITIpoke');end
                case 'TUP'
                    psendPacket(handles,'TON,43,1,1');                     %Go sound
                    handles = moveto(handles,'volHeadSetup');
            end
        end
    case 'ITIpoke'
        if entering
        else; switch events{1}
                case 'IRB';if str2num(events{2}) ==  1 && str2num(events{3})==0
                       handles = moveto(handles, 'ITI');end
            end
        end
        
      case {'volHeadSetup','volHeadWait','volHead0','volHead1','volHeadRew','volHeadRewExtra','volHeadRewDouble','volHeadWaitStep1L','volHeadWaitNosepokeL'}
        %[handles] = pFSMSub_volHead(event,handles,stage,headHoldDur,exitStates);
        [handles] = pFSMSub_volHead(event,handles,stage,headHoldDur,{'reset','reset'},'LEDvolHeadWait',0,'numRewHold',numRewHold,'rewHoldDurFunc',rewHoldDurFunc);
        
        %[handles] = pFSMSub_volHead(event,handles,stage,headHoldDur,{'reset'},'LEDvolHeadWait',0);
        
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
        psendPacket(handles,'TON,0,0,0');                     %turn off all sounds
        handles = finishTasks(handles);
        
    otherwise
        state
        error('invalid state')
        
end

guidata(handles.figure1,handles);

end

 
 