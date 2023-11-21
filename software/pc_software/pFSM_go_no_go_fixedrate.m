function[handles] = pFSM_go_no_go(event,handles)

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
                     'pokeInHoldTime','poke hold','edit','0.05',{'TooltipString','length of time a poke must be held'};...
                     'rewPokeWaitDur','rewPokeWaitDur','edit','20',{'TooltipString','time to wait for before exiting rewPokeWait'};...
                     'waitRewTone','waitRewTone','edit','25',{'TooltipString','tone index for reward availibility'};...
                     'waitRewToneDur','waitRewToneDur','edit','0.5',{'TooltipString','tone duration for reward availibility'};...
                     'volHeadStage','volHeadStage','edit','2',{'TooltipString','voluntary head stage','enable','off'};...
                     'volHeadHoldDur','volHeadHoldDur','edit','1',{'TooltipString','time the state 1 should be held'};...
                     'volHeadRewProb','volHeadRewProb','edit','1',{'TooltipString','probability of a reward at the end of voleHead'};...
                     'odorDur','odorDur','edit','1',{'TooltipString','how long the odor is presented for'};...
                     'odorNum','odorNum','edit','4',{'TooltipString','which odor'};...
                     'flushDur','flushDur','edit','3',{'TooltipString','how long the vacuum flush is applied for'};...
                     'response1Dur','response1Dur','edit','3',{'TooltipString','time after exiting vol head where we are not allowed to restart a trial (make a no go response)'};...
                     'response1Reset','response1Reset','edit','1',{'TooltipString','this dur is reset if there is an early response at the vol head location, if 0 it is not'};...
                     'forceGoResponse','forceGoResponse..','edit','1',{'TooltipString','must make a go response to progress to next trial, on go trials only'};...
                     'goProb','goProb','edit','1',{'TooltipString','probability of getting a go trial'};...
                     'noRunsofN','noRunsofN','edit','inf',{'TooltipString','if there is a run of N trials of a certain type, do the other type'};...
                     'resampleOdor','resampleOdor','edit','0',{'TooltipString','if true, re present odor if a S+ trial, and animal makes a nogo response(with force go response being true)'};...
                     'nextTrial','nextTrial','pushbutton',[],{'callback',@(~,~)pdispatch('NEXTTRIAL',guidata(handles.figure1))};...
                     'userCuePoke','userCuePoke','pushbutton',[],{'callback',@(~,~)pdispatch('USERCUEPOKE',guidata(handles.figure1))}};
                                   

            [handles] = makeTaskUIelements(handles, UIdata);
            [handles] = constructTUP(handles);
             
            [handles] = constructToneOffTimer(handles);
            
            %make odor event object
            handles.user.program.olfEvtObj = odorEvt(handles.figure1,1,1,1,1,1,1);
            
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
              assignUIvalues(handles); %assigns all the UI values to variables in the current workspace

              handles.user.program.trial(nTrial).startTime = now;
              handles.user.program.trial(nTrial).outcome = [];
              
              chooseGo =  rand < goProb;
              if nTrial > noRunsofN && ~isinf(noRunsofN)
                if all(strcmp('go',{handles.user.program.trial(nTrial-noRunsofN : nTrial-1).type}))
                    chooseGo = false;
                elseif all(strcmp('nogo',{handles.user.program.trial(nTrial-noRunsofN : nTrial-1).type}))
                    chooseGo = true;
                end
              end
              
              if chooseGo
                  handles.user.program.trial(nTrial).type = 'go';
                  handles.user.program.trial(nTrial).goal = 2;
                  handles.user.program.trial(nTrial).odor = odorNum;
              else
                  handles.user.program.trial(nTrial).type = 'nogo';
                  handles.user.program.trial(nTrial).goal = nan;
                  handles.user.program.trial(nTrial).odor = 2;  %blank odor
              end
              set(handles.trialTypeDisplay,'string',handles.user.program.trial(nTrial).type);
              set(handles.goalLocDisplay,'string',num2str(handles.user.program.trial(nTrial).goal));

              %program the odor timer system
              set(handles.user.program.olfEvtObj,'location',1,...
                                                 'odorID',   handles.user.program.trial(nTrial).odor,...
                                                 'odorDelay',0.2,...
                                                 'odorDur',  odorDur,...
                                                 'flushDur', flushDur,...
                                                 'flushID',-1,...
                                                 'offLoc',0,'offID',0);
              psendPacket(handles,'OLF,1,1')
              handles = moveto(handles,'volHeadSetup');
          end
         
        
    case {'volHeadSetup','volHeadWait','volHead0','volHead1','volHeadRew','volHeadRewExtra','volHeadRewDouble','volHeadWaitStep1L','volHeadWaitNosepokeL'}
        %[handles] = pFSMSub_volHead(event,handles,stage,headHoldDur,exitStates);
        [handles] = pFSMSub_volHead(event,handles,volHeadStage,volHeadHoldDur,{'waitResponse1','waitResponse1'},'postRewDur',0.1,'goSound',1,'odorProg',1,'rewardProb',volHeadRewProb,'waitRewToneDur',waitRewToneDur,'waitRewTone',waitRewTone);
  
    case 'waitResponse1'
        if entering
            handles.user.program.trial(nTrial).waitResponse1Time = now;
            startTup(handles, response1Dur);
        else;switch events{1}
                case 'IRB'                    
                    if str2num(events{2}) ==  rewLocation && str2num(events{3})==1 
                        if  strcmp(handles.user.program.trial(nTrial).type,'go')
                            handles = moveto(handles,'remotePokeArrival');
                        else
                            if isempty(handles.user.program.trial(nTrial).outcome)
                                handles.user.program.trial(nTrial).outcome = 'incorrect';
                                handles.user.program.trial(nTrial).outcomeTime = now;
                            end 
                        end
                    end
                case 'GPIO'; if str2num(events{2})== 15  && str2num(events{3})==1    %front bearing
                    if response1Reset
                        handles = moveto(handles,'pauseResponse1');end;end
                case 'TUP'
                    handles = moveto(handles,'waitResponse2');

            end
        end
        
    case 'pauseResponse1'
        if entering
        else;switch events{1}
                case 'GPIO'; if str2num(events{2})== 15 && str2num(events{3})==0    %front bearing
                        handles = moveto(handles,'waitResponse1');end
            end
         end
         
    case 'waitResponse2'
            if entering
                psendPacket(handles,'LED,1,0,-1') %turn home LED on
                psendPacket(handles,'OLF,1,1')    %turn blank air on

            else;switch events{1}
                case 'IRB'                    
                    if str2num(events{2}) ==  rewLocation && str2num(events{3})==1 
                        handles = moveto(handles,'remotePokeArrival');
                    end
                case 'GPIO'; if str2num(events{2})== 15  && str2num(events{3})==1    %front bearing
                        handles = moveto(handles,'rejection');end   
                end
            end
            
    case 'rejection'
        if entering
          switch handles.user.program.trial(nTrial).type
              case 'go'
                  if isempty(handles.user.program.trial(nTrial).outcome)
                      handles.user.program.trial(nTrial).outcome = 'incorrect';
                      handles.user.program.trial(nTrial).outcomeTime = now;
                  end
                  if ~forceGoResponse                      
                      handles = moveto(handles,'waitFlush');
                  else
                      if resampleOdor
                          handles.user.program.olfEvtObj.hardStop;
                          handles.user.program.olfEvtObj.start;
                      end
                  end
                  
              case 'nogo'
                  if isempty(handles.user.program.trial(nTrial).outcome)
                      handles.user.program.trial(nTrial).outcome = 'correct';
                      handles.user.program.trial(nTrial).outcomeTime = now;
                  end
                  handles = moveto(handles,'waitFlush');
          end
        else;switch events{1}
                case 'GPIO'; if str2num(events{2})== 15  && str2num(events{3})==0    %front bearing low
                        if resampleOdor
                            handles.user.program.olfEvtObj.stop;
                        end
                        handles = moveto(handles,'waitResponse2');
                    end
            end
            
        end
          
    case 'remotePokeArrival'
      if entering
          switch handles.user.program.trial(nTrial).type
              case 'go'
                  giveReward(handles,rewLocation);
                  if isempty(handles.user.program.trial(nTrial).outcome)
                      handles.user.program.trial(nTrial).outcome = 'correct';
                      handles.user.program.trial(nTrial).outcomeTime = now;
                  end
              case 'nogo'
                  if isempty(handles.user.program.trial(nTrial).outcome)
                      
                      handles.user.program.trial(nTrial).outcome = 'incorrect';
                      handles.user.program.trial(nTrial).outcomeTime = now;
                  end
                  handles = moveto(handles,'waitFlush');
          end         
      else;switch events{1}
              case 'REWEVTEND'; handles = moveto(handles,'waitFlush');
           end
      end
      
    case 'waitFlush'
        if entering;if strcmp(handles.user.program.olfEvtObj.status,'idle')
              handles = moveto(handles,'reset'); end
        else;switch events{1}
                case 'ODORFLUSHEND';handles = moveto(handles,'reset');
            end
        end
        
    case 'reset'
        if entering           
            
%             %do the trial plotting
%             hold(handles.axes1,'on');
%             trial = handles.user.program.trial;
%             if ~isempty(trial(nTrial).outcome)
%                 plot(handles.axes1,nTrial,[trial(nTrial).goalLoc],'ko')
%                 switch trial(nTrial).outcome
%                     case 'correct'
%                         plot(handles.axes1,nTrial,trial(nTrial).responseLoc(1),'g*')
%                     case 'incorrect'
%                         plot(handles.axes1,nTrial,trial(nTrial).responseLoc(1),'r*')
%                 end
%                 set(handles.axes1,'ylim',[1 4],'xlim',[0 nTrial+2],'ytick',trial(1).vars.rewLocations)
%                 
%                 ind = arrayfun(@(x)~isempty(x.outcome),trial);
%                 cor = strcmp({trial(ind).outcome},'correct');
%                 pcCorrect = sum(cor)/sum(ind);
%                 pVal = 1-binocdf(sum(cor),sum(ind),1/numel(trial(1).vars.rewLocations));
%                 choice = arrayfun(@(x)x.responseLoc(1),trial(ind));
%                 bias = sum(choice' == trial(1).vars.rewLocations,1)./numel(choice);
%                 delete(findobj(handles.axes1,'type','text'));
%                 text(handles.axes1,nTrial*0.7,3.5,sprintf('p/c Correct = %.2f (p = %.3f) \n bias = %.2f %.2f',pcCorrect,pVal,bias))
%                 hold(handles.axes1,'off');
%             end
            
            %advance the trial counter
            handles.user.program.nTrial = handles.user.program.nTrial +1;  
            handles = moveto(handles,'trialsetup');

        end
        
    case 'finish'
        %we only enter here once
        disp('finishing task')
        psendPacket(handles,'TON,0,0,0');                     %turn off
        psendPacket(handles,'LED,1,0,0');
        handles = finishTasks(handles);
        
    otherwise
        state
        error('invalid state')
        
end

guidata(handles.figure1,handles);

end

 
 