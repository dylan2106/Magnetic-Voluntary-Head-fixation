function[handles] = pFSM_paired_association_cued(event,handles)

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
   isfield(handles.user.program,'state');

    state = handles.user.program.state;
else
    state = 'setup';
end


switch state
    case 'setup'
               
            %get teh panel position 
            pos = get(handles.programPanel,'position');
            
            %create a function for converting panel relative position
            %vectors into figure realtive
            convPos = @(posIn)[(posIn(1)*pos(3) + pos(1)),...
                               (posIn(2)*pos(4) + pos(2)),...
                               (posIn(3)*pos(3)),...
                               (posIn(4)*pos(4))];
            ystart = 0.80;
            ysize =  0.08;
            yspace = 0.02;
            xstart = 0.03;
            xsize  = 0.1;
            xspace = 0.01;   

            handles.user.program.olfEvtObj = odorEvt(handles.figure1,1,1,1,1,1,1);

        if entering
            disp('setting initial parameters for alternation')
            
            %here is the setup code
            %we create the session spesfic parameters,
            %these are parameters which are set once at the start of the
            %trial and then are not changed
            
            %clear any previous program data
            handles.user.program = [];
            
            %clear any children in the program panel
            delete(get(handles.programPanel,'children'));
            
            %set the name of teh sessoin so we can make unique autosaves
             handles.user.program.sessionName = datestr(now,'yymmdd_HHMM');

            
           set(handles.pushbuttonStartProg,'enable','on');
        else
            %we are responding to an event
            switch events{1}
                
                case 'TASKSTART'
                     %we create trial by trial parameter boxes which can be
                     %changed on a trial by trial basis
                    
                        % UIdata = {name,string,type,editValue} 

                        UIdata = {'sampleLocs','edit','2,3',{};...
                                  'sampleOdors','edit','2,3',{};...
                                  'randSampleOrder','edit','1',{'TooltipString','0 - false, 1 - true'};...
                                  'autoSampleAdvance','edit','1',{'TooltipString','advances to next sample automatically'};...
                                  'autoCueAdvance','edit','1',{'TooltipString','advances to cue phase automatically'};...
                                  'goalLoc','edit','0',{'TooltipString','0 - random'};... 
                                  'numRewardResponse','edit','12',{'TooltipString','number of rewards upon a correct response'};...
                                  'firstResRewDelay','edit','0.5',{'TooltipString','delays the first reward on a response at the correct location'};...
                                  'odorOnCorResponse','edit','1',{'TooltipString','presents the animal with the odor after a correct response'};...
                                  'allowCorrections','edit','0',{'TooltipString','allows animal to make anther response'};...
                                  'numRewardCorrection','edit','1',{'TooltipString','number of rewards after an incorrect response, at the correct(ion) location'};...
                                  'incorrectTone','edit','15',{};... 
                                  'cueLoc','edit','1',{};...
                                  'cueEndTone','edit','23',{};...
                                  'cueWaitTime','edit','nan',{'TooltipString','timer for cuewait to end'};...
                                  'waitResponseTime','edit','nan',{'TooltipString','timer for waitResponse to end'};...
                                  'waitResponseTimeTone','edit','24',{'TooltipString','tone to play at the end waitResponseTime'}};
                     
                    handles = taskUIelements(handles, UIdata);
                    
                    %the following input fields will be read out at the
                    %start of teh trial (when the start button is pressed)
                    %and will then be disabled.
                    handles.user.program.UI.trialDataFields = {'cueLoc','incorrectTone','cueEndTone','cueWaitTime','numRewardResponse',...
                                       'numRewardCorrection','firstResRewDelay','waitResponseTime','waitResponseTimeTone'};

                    %make the buttons
                    
                    %trial start button
                    row = 1; col = 7;
                    handles.user.program.UI.startButton = uicontrol('style','pushbutton',...
                        'units','normalized',...
                        'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize]),...
                        'string','start trial',...
                        'callback',@(~,~)pdispatch('TRIALSTART',guidata(handles.figure1)),...
                        'enable','off');
                 
                    row = 2; col =7;
                    handles.user.program.UI.phaseButton = uicontrol('style','pushbutton',...
                        'units','normalized',...
                        'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize]),...
                        'string','next',...
                        'callback',@(~,~)pdispatch('PHASESTART',guidata(handles.figure1)),...
                        'enable','off');
                    
                    row = 3; col = 7;
                    handles.user.program.UI.cancelButton = uicontrol('style','pushbutton',...
                        'units','normalized',...
                        'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize]),...
                        'string','cancel trial',...
                        'callback',@(~,~)pdispatch('CANCEL',guidata(handles.figure1)),...
                        'enable','off');
                    
                    row = 4; col = 7;
                    handles.user.program.UI.cuePokeButton = uicontrol('style','pushbutton',...
                        'units','normalized',...
                        'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize]),...
                        'string','cue poke',...
                        'callback',@(~,~)pdispatch('CUEPOKE',guidata(handles.figure1)),...
                        'enable','off');
                    
                    %make a currnet state display
                     row = 2; col = 9;
                     handles.user.program.UI.curStateText = uicontrol('style','text','units','normalized',...
                        'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize*2  ysize*2]),...
                        'string','trialSetup');
                    
                    handles.user.program.olfEvtObj = odorEvt(handles.figure1,1,1,1,1,1,1);
                    
                    %assign the variables for the program
                    handles.user.program.state  = 'setup';     %current state;
                    
                    %set to the default flow location
                    command = sprintf('OLF,%d,%d',6,1);
                    psendPacket(handles,command);
                    
                    handles.user.program.nVisit = 1;
                    handles.user.program.nTrial = 0;
                    
                    handles.user.program.cueWaitTimer = timer('timerfcn',@(~,~)pdispatch('CUEWAITUP',guidata(handles.figure1)),...
                                                                    'startdelay',1.1);
                    
                    handles.user.program.waitResponseTimer = timer('timerfcn',@(~,~)pdispatch('WAITRESPONSEUP',guidata(handles.figure1)),...
                                                                    'startdelay',1.1);
                    
                                                                
                    %a TUP cannot start itself if it in in hte middle  of  its own callback, 
                    %therefor we need to hide the callback that sends the
                    %event behind another timer that has a very short
                    %delay. This way tupTimerCallback is never resarted
                    %from within its own callback
                    handles.user.program.tupTimerCallback = timer('timerfcn',@(~,~)pdispatch('TUP',guidata(handles.figure1)),...
                                                                    'startdelay',0.001,'BusyMode','Queue'); 
                                                                
                    %general Time up event, this timer is automatically stopped when there is a state change
                    handles.user.program.tupTimer = timer('timerfcn',@(~,~)start(handles.user.program.tupTimerCallback),...
                                                                    'startdelay',1.1,'BusyMode','Queue');
                                                                   
                    %go to the next state
                    handles = moveto(handles,'trialSetup');
            end
            
        end
        
    case 'trialSetup'
        if entering
            handles.user.program.nTrial =  handles.user.program.nTrial + 1;

            log2file(handles);
           
            %enable all the input UI elements that can be changed only
            %between each trial
            for i = 1:numel(handles.user.program.UI.trialDataFields)
                set(handles.user.program.UI.(handles.user.program.UI.trialDataFields{i}),'enable','on')
            end
            
            set(handles.user.program.UI.startButton ,'enable','on')
            uicontrol(handles.user.program.UI.startButton)
                                
            nTrial = handles.user.program.nTrial;
            fprintf('*********** trial %i ***************\n',nTrial)         

        else
            switch events{1}
                case 'TRIALSTART'
                    
                    nTrial = handles.user.program.nTrial;


                    %disable all the edit boxes
                    
                    %allocate the sample locations
                    handles.user.program.trial(nTrial).sampleLocs = ...
                        sscanf(get(handles.user.program.UI.sampleLocs,'string'),'%i,')';
                    handles.user.program.trial(nTrial).sampleOdors = ...
                        sscanf(get(handles.user.program.UI.sampleOdors,'string'),'%i,')';

                    if str2num(get(handles.user.program.UI.randSampleOrder,'string')) == 1
                        randOrder = randperm(2);
                        handles.user.program.trial(nTrial).sampleLocs = handles.user.program.trial(nTrial).sampleLocs(randOrder);
                        handles.user.program.trial(nTrial).sampleOdors = handles.user.program.trial(nTrial).sampleOdors(randOrder);

                    end
                    handles.user.program.trial(nTrial).sampleInd = 1;   %which sample we are on
                    
                    handles.user.program.trial(nTrial).choice =[];
                    handles.user.program.trial(nTrial).outcome =[];
                    handles.user.program.trial(nTrial).choiceTime =[];
                    handles.user.program.trial(nTrial).startTime = now;
                    
                    handles.user.program.trial(nTrial).sampleChoiceLoc = {};
                    handles.user.program.trial(nTrial).sampleChoiceTime = {};
                    
                    handles.user.program.trial(nTrial).cuePokeTime = [];
                   
                    handles.user.program.trial(nTrial).responseSample     = [];
                    handles.user.program.trial(nTrial).responseSampleTime = [];
                    
                    %read off some of the inputs and put them into the
                    %trial data structure
                    trialDataFields = handles.user.program.UI.trialDataFields;
                                   
                    for i = 1:numel(trialDataFields)
                        handles.user.program.trial(nTrial).(trialDataFields{i}) = ...
                            str2num(get(handles.user.program.UI.(trialDataFields{i}),'string'));
                        set(handles.user.program.UI.(trialDataFields{i}),'enable','off')
                        
                    end
                        
%                     handles.user.program.trial(nTrial).cueLoc =         str2num(get(handles.user.program.UI.cueLoc,'string'));
%                     handles.user.program.trial(nTrial).incorrectTone =  str2num(get(handles.user.program.UI.incorrectTone ,'string'));   %tone when arrives at incorrect location during the response phase
%                     handles.user.program.trial(nTrial).cueEndTone =     str2num(get(handles.user.program.UI.cueEndTone,'string'));
%                     handles.user.program.trial(nTrial).cueWaitTime =    str2num(get(handles.user.program.UI.cueWaitTime,'string'));
%                     handles.user.program.trial(nTrial).numRewardResponse = str2num(get(handles.user.program.UI.numRewardResponse,'string'));
%                     handles.user.program.trial(nTrial).numRewardCorrection = str2num(get(handles.user.program.UI.numRewardCorrection,'string'));
%                     handles.user.program.trial(nTrial).firstResRewDelay = str2num(get(handles.user.program.UI.firstResRewDelay,'string'));    
%                     handles.user.program.trial(nTrial).waitResponseTime = str2num(get(handles.user.program.UI.waitResponseTime,'string'));

                    if ~isnan(handles.user.program.trial(nTrial).cueWaitTime)
                        set(handles.user.program.cueWaitTimer,'startDelay', handles.user.program.trial(nTrial).cueWaitTime);
                    end
                    
                    
                    set(handles.user.program.UI.startButton ,'enable','off') 
                    set(handles.user.program.UI.phaseButton ,'enable','on') 

                    fprintf('sample order is %i, %i \n',handles.user.program.trial(nTrial).sampleLocs)

                    handles = moveto(handles,'waitUserSample');
                    
            end
            
        end
        
    case 'waitUserSample' 
       nTrial = handles.user.program.nTrial;

        if entering
            log2file(handles);
            set(handles.user.program.UI.phaseButton ,'enable','on')              
            uicontrol(handles.user.program.UI.phaseButton)
            fprintf('this sample location is %i\n',handles.user.program.trial(nTrial).sampleLocs(handles.user.program.trial(nTrial).sampleInd))
       
        else
            switch events{1}
                case 'PHASESTART'
                    %turn off the phase button
                    set(handles.user.program.UI.phaseButton ,'enable','off')              
                    handles = moveto(handles,'waitSample');
                    
                case 'ODORFLUSHEND'
                    %if user has requested auto advance
                    if str2num(get(handles.user.program.UI.autoSampleAdvance,'string')) == 1
                          set(handles.user.program.UI.phaseButton ,'enable','off')              
                          handles = moveto(handles,'waitSample');
                    end
            end
        end
        
    case 'waitSample'
         nTrial = handles.user.program.nTrial;

         if entering
              fprintf('entering waitSample #%i\n',handles.user.program.trial(nTrial).sampleInd);
              
              log2file(handles);
              fprintf('current targets are location(s)')
              sampleInd = handles.user.program.trial(nTrial).sampleInd;
              disp(handles.user.program.trial(nTrial).sampleLocs(sampleInd))
              
              %start an odor flow to teh sample location
              %program the odor timer system
              set(handles.user.program.olfEvtObj,'location', handles.user.program.trial(nTrial).sampleLocs(sampleInd),...
                                                 'odorID',   handles.user.program.trial(nTrial).sampleOdors(sampleInd),...
                                                 'odorDelay',0,...
                                                 'odorDur', 2e6,...  %stay on utill we do something
                                                 'flushDur',3,...
                                                 'flushID',1,...
                                                 'offLoc',6,'offID',1);
                                             
              start(handles.user.program.olfEvtObj);
         else
             switch events{1}
                 case 'IRB'
                     %photobeam was broken %check which device
                     loc = str2num(events{2});
                     
                     if str2num(events{3})==1
                         sampleInd = handles.user.program.trial(nTrial).sampleInd;
                         % handles.user.program.trial(nTrial).sampleChoiceLoc{sampleInd}  = [handles.user.program.trial(nTrial).sampleChoiceLoc{sampleInd} loc];
                         % handles.user.program.trial(nTrial).sampleChoiceTime{sampleInd} = [handles.user.program.trial(nTrial).sampleChoiceLoc{sampleInd} now];
%                         
                         if handles.user.program.trial(nTrial).sampleLocs(sampleInd) == loc
                       
                                % handles.user.program.trial(nTrial).sampleChoiceOutcome = [handles.user.program.trial(nTrial).sampleChoiceOutcome 'correctLoc'];
                                 
                                 %update his current location
                                 handles = moveto(handles,'sample');
                         end
                     end
             end
         end
         
    case 'sample'
        nTrial = handles.user.program.nTrial;
        
       sampleInd = handles.user.program.trial(nTrial).sampleInd;
       sampleLoc = handles.user.program.trial(nTrial).sampleLocs(sampleInd);
       
       if entering
            
            log2file(handles)
            disp('entering sample')

              %start the reward event    
              controllerGUI('general_RewEvt_callback',handles.figure1,1,handles,sampleLoc,2)
        
        else
            switch events{1}
                case 'IRB'
                    %photobeam was broken %check which device
                    loc = str2num(events{2});
                    nTrial = handles.user.program.nTrial;
                    
                    %if it was a pokeout
                    if sampleLoc == loc && str2num(events{3})==0
                        %stop the odor evt (cause it to flush)
                        handles.user.program.olfEvtObj.stop;
                        handles.user.program.trial(nTrial).sampleInd = handles.user.program.trial(nTrial).sampleInd+1;
                        
                        if handles.user.program.trial(nTrial).sampleInd <= numel(handles.user.program.trial(nTrial).sampleLocs)
                            %there are still more samples to do
                            handles = moveto(handles,'waitUserSample');
                        else
                            handles = moveto(handles,'waitUserCue');
                        end

                    end
            end
       end
     
     case 'waitUserCue' 
        nTrial = handles.user.program.nTrial;

        if entering
            log2file(handles);
            set(handles.user.program.UI.phaseButton ,'enable','on')              
            uicontrol(handles.user.program.UI.phaseButton)
            fprintf('ready for cue phase\n') 
        else
            switch events{1}
                case 'PHASESTART'
                    %turn off the phase button
                    set(handles.user.program.UI.phaseButton ,'enable','off')              
                    %move to a cue state
                    handles = moveto(handles,'waitCue');
                    
                case 'ODORFLUSHEND'
                    %if user has requested auto advance
                    if str2num(get(handles.user.program.UI.autoCueAdvance,'string')) == 1
                        set(handles.user.program.UI.phaseButton ,'enable','off')
                        handles = moveto(handles,'waitCue');
                    end
            end
        end       
    case 'waitCue'
        nTrial = handles.user.program.nTrial;
       
       if entering
              fprintf('entering waitCue \n');
              
              log2file(handles);
              goalOpt = str2num(get(handles.user.program.UI.goalLoc,'string'));
              if goalOpt == 0
                  handles.user.program.trial(nTrial).goalInd = randi(numel(handles.user.program.trial(nTrial).sampleLocs));
              elseif goalOpt <= numel(handles.user.program.trial.sampleLocs)
                  handles.user.program.trial(nTrial).goalInd = goalOpt;
              end
              goalInd = handles.user.program.trial(nTrial).goalInd;
              
              fprintf('goal is location(s)')
              disp(handles.user.program.trial(nTrial).sampleLocs(goalInd))
              
              %start an odor flow to the cue location, using the odor from
              %the goal location
              set(handles.user.program.olfEvtObj,'location', str2num(get(handles.user.program.UI.cueLoc,'string')),...
                                                 'odorID',   handles.user.program.trial(nTrial).sampleOdors(goalInd),...
                                                 'odorDelay',0,...
                                                 'odorDur', 2e6,...  %stay on utill we do something
                                                 'flushDur',3,...
                                                 'flushID',1,...
                                                 'offLoc',0,'offID',0);  %make the off state just a pause, no flush
                                             
              start(handles.user.program.olfEvtObj);
              
              %if there is a number called for the cueWait time, 
              %then start the timer
              if ~isnan(handles.user.program.trial(nTrial).cueWaitTime)
                  start(handles.user.program.cueWaitTimer) 
              end
              
              %enable the cue poke button 
              set(handles.user.program.UI.cuePokeButton,'enable','on')
              %and set the focus there
              uicontrol(handles.user.program.UI.cuePokeButton)
              
       else
             switch events{1}
                 case 'IRB'
                     uicontrol(handles.user.program.UI.startButton)
                     set(handles.user.program.UI.cuePokeButton,'enable','off')

                     %photobeam was broken %check which device
                     loc = str2num(events{2});
                     
                     if str2num(events{3})==1                     
                         if handles.user.program.trial(nTrial).cueLoc == loc
                            handles = moveto(handles,'cue'); 
                         end
                     end
                 case {'CUEWAITUP' ,'CUEPOKE'}
                      set(handles.user.program.UI.cuePokeButton,'enable','off')
                        uicontrol(handles.user.program.UI.startButton)

                      packet = sprintf('TON,%d,%d,1,0',handles.user.program.trial(nTrial).cueEndTone,handles.user.program.trial(nTrial).cueLoc);
                      psendPacket(handles,packet)
                      
                      %go straight to the waitresponse, since we will not
                      %have a poke out and a hold in the nosepoke
                      handles.user.program.olfEvtObj.hardStop;
                      handles = moveto(handles,'waitResponse');
             end
       end
       
  case 'cue'
        nTrial = handles.user.program.nTrial;       
       if entering
              handles.user.program.trial(nTrial).cuePokeTime = [handles.user.program.trial(nTrial).cuePokeTime now];
              %if this is the first cue poke then play the door open tone
              handles.user.program.trial(nTrial).cuePokeTime
              if numel(handles.user.program.trial(nTrial).cuePokeTime) == 1   
                  packet = sprintf('TON,%d,%d,1,0',handles.user.program.trial(nTrial).cueEndTone,handles.user.program.trial(nTrial).cueLoc);
                  psendPacket(handles,packet)
              end
              
              fprintf('entering Cue \n');
              log2file(handles);
        else
              switch events{1}
                case 'IRB'
                    %photobeam was broken %check which device
                    loc = str2num(events{2});
                    
                    %if it was a pokeout
                    if handles.user.program.trial(nTrial).cueLoc == loc && str2num(events{3})==0
                        handles.user.program.olfEvtObj.hardStop; %hard stop the odor delivery (so it can be resumed)
                        handles = moveto(handles,'postCue');
                    end
              end         
       end
    %this is a delay state that keeps the odorant primed in the system for re presentation to the cue poke
    %it lasts for a certain time and then advances 
    case 'postCue'
       nTrial = handles.user.program.nTrial;       
       if entering
               log2file(handles);
               set(handles.user.program.tupTimer,'startDelay',5);
               start(handles.user.program.tupTimer)
       else
           switch events{1}
               case 'IRB'
                     %photobeam was broken %check which device
                     loc = str2num(events{2});
                     if str2num(events{3})==1                     
                         if handles.user.program.trial(nTrial).cueLoc == loc
                              handles = moveto(handles,'cue');
                         end
                     end
                     
               case 'TUP'
                   %flush the odor lines
                   %send blank air to 6 (though all manifolds)
                   %there will be sme residual odor left in the cue poke, but we can ignore it for now since
                   %it will behind valves, andd will get flushed at the end of the trial
                   command = sprintf('OLF,%d,%d',6,1);
                   psendPacket(handles,command);
                   handles = moveto(handles,'waitResponseSample');
           end
       end
        
    case 'waitResponseSample'   
       nTrial = handles.user.program.nTrial;       
       if entering
            log2file(handles);
            fprintf('goal is location = %i\n',handles.user.program.trial(nTrial).sampleLocs(handles.user.program.trial(nTrial).goalInd))
       else
           switch events{1}
                 case 'IRB'
                     %photobeam was broken %check which device
                     loc = str2num(events{2});
                     
                     if any(handles.user.program.trial(nTrial).sampleLocs == loc)
                         %save a log of the event
                         handles.user.program.trial(nTrial).responseSample     =  [handles.user.program.trial(nTrial).responseSample loc];
                         handles.user.program.trial(nTrial).responseSampleTime =  [handles.user.program.trial(nTrial).responseSampleTime now];
                         
                         %present odor to that location
                         set(handles.user.program.olfEvtObj,'location', loc,...
                                                 'odorID',   handles.user.program.trial(nTrial).sampleOdors(handles.user.program.trial(nTrial).sampleLocs == loc),...
                                                 'odorDelay',0,'odorDur', 2,...  
                                                 'flushDur',3,'flushID',1,...
                                                 'offLoc',6,'offID',1);
                          start(handles.user.program.olfEvtObj)
                          handles = moveto(handles,'responseSample');

                     end                     
           end
       end
    case 'responseSample'
       nTrial = handles.user.program.nTrial;       
       if entering
            log2file(handles);
            set(handles.user.program.tupTimer,'startDelay',1);
            start(handles.user.program.tupTimer)
       else
            switch events{1}
                 case 'TUP'
                   handles = moveto(handles,'waitResponse');
            end
       end
       
    case 'waitResponse'
       nTrial = handles.user.program.nTrial;       
       if entering
            log2file(handles);
            set(handles.user.program.tupTimer,'startDelay',1);
            start(handles.user.program.tupTimer)
                
            %query the current state of the the IR beam for the current location
            handles = pdispatch(['IRQ,',num2str(handles.user.program.trial(nTrial).responseSample(end))],handles);
            
       else
           events{1}
           switch events{1}
                 case 'TUP'
                   handles = moveto(handles,'waitResponseSample');
                   
                 case {'IRB','IRS'}
                     %photobeam was broken %check which device
                     loc = str2num(events{2});
                     if str2num(events{3})==1  
                          
                          %if the poke is at the current location
                          if loc == handles.user.program.trial(nTrial).responseSample(end)
                              
                              %poked at the goal
                              if handles.user.program.trial(nTrial).sampleLocs(handles.user.program.trial(nTrial).goalInd) == loc;
                                  handles.user.program.trial(nTrial).choice = [handles.user.program.trial(nTrial).choice loc];
                                  handles.user.program.trial(nTrial).choiceTime = [handles.user.program.trial(nTrial).choiceTime now];
                                  if isempty(handles.user.program.trial(nTrial).outcome)
                                      %animal made first choice correct
                                      handles.user.program.trial(nTrial).outcome = 'correct';
                                      controllerGUI('general_RewEvt_callback',handles.figure1,1,handles,loc ,handles.user.program.trial(nTrial).numRewardResponse,[],handles.user.program.trial(nTrial).firstResRewDelay)
                                  else
                                      %animal ahs previously made an incorrect
                                      %choice
                                      %give a smaller reward
                                      controllerGUI('general_RewEvt_callback',handles.figure1,1,handles,loc ,handles.user.program.trial(nTrial).numRewardCorrection,[],handles.user.program.trial(nTrial).firstResRewDelay)
                                  end
                                  handles = moveto(handles,'endTrial');
                                  
                              %poked at one of the other locations
                              elseif any(handles.user.program.trial(nTrial).sampleLocs == loc)
                                  handles.user.program.trial(nTrial).outcome = 'incorrect';
                                  handles.user.program.trial(nTrial).choice = [handles.user.program.trial(nTrial).choice loc];
                                  
                                  %make a worng locaiton sound?
                                  packet = sprintf('TON,%d,%d,1,0',handles.user.program.trial(nTrial).incorrectTone,loc);
                                  psendPacket(handles,packet)
                                  
                                  if str2num(get(handles.user.program.UI.allowCorrections,'string')) == 1
                                      handles = moveto(handles,'waitResponse');
                                  else
                                      handles = moveto(handles,'endTrial');
                                  end        
                              end
                          end
                     end                
           end
%                           %if he poked back into the cue location
%                           if  handles.user.program.trial(nTrial).cueLoc == loc
%                               %represent the cue odor
%                                handles.user.program.olfEvtObj.start
%                                handles = moveto(handles,'cue');             %move back to the cue state
%                                
% 
%                           %poked at the goal
%                           elseif handles.user.program.trial(nTrial).sampleLocs(handles.user.program.trial(nTrial).goalInd) == loc
%                              handles.user.program.trial(nTrial).choice = [handles.user.program.trial(nTrial).choice loc];
%                              handles.user.program.trial(nTrial).choiceTime = [handles.user.program.trial(nTrial).choiceTime now];
%                              if isempty(handles.user.program.trial(nTrial).outcome)
%                                  %animal made first choice correct
%                                  handles.user.program.trial(nTrial).outcome = 'correct';
%                                  controllerGUI('general_RewEvt_callback',handles.figure1,1,handles,loc ,handles.user.program.trial(nTrial).numRewardResponse,[],handles.user.program.trial(nTrial).firstResRewDelay)
%                              else
%                                  %animal ahs previously made an incorrect
%                                  %choice
%                                  %give a smaller reward
%                                  controllerGUI('general_RewEvt_callback',handles.figure1,1,handles,loc ,handles.user.program.trial(nTrial).numRewardCorrection,[],handles.user.program.trial(nTrial).firstResRewDelay)
%                              end
%                                 
%                              %deliver the odor to that location if
%                              %requested
%                              if str2num(get(handles.user.program.UI.odorOnCorResponse,'string')) == 1
%                                  set(handles.user.program.olfEvtObj,'location', loc,...
%                                                  'odorID',   handles.user.program.trial(nTrial).sampleOdors(handles.user.program.trial(nTrial).goalInd),...
%                                                  'odorDelay',0,...
%                                                  'odorDur', 3,...  
%                                                  'flushDur',3,...
%                                                  'flushID',1,...
%                                                  'offLoc',6,'offID',1);
%                                   start(handles.user.program.olfEvtObj)
%                              
%                              end
%                              
% 
%                              handles = moveto(handles,'endTrial');
%                          
%                          %poked at one of the other locations    
%                          elseif any(handles.user.program.trial(nTrial).sampleLocs == loc)
%                             handles.user.program.trial(nTrial).outcome = 'incorrect';
%                             handles.user.program.trial(nTrial).choice = [handles.user.program.trial(nTrial).choice loc];
%                             
%                             %make a worng locaiton sound?
%                             packet = sprintf('TON,%d,%d,1,0',handles.user.program.trial(nTrial).incorrectTone,loc);
%                             psendPacket(handles,packet)
%                           
%                             if str2num(get(handles.user.program.UI.allowCorrections,'string')) == 1
%                                 handles = moveto(handles,'waitResponse');
%                             else
%                                 handles = moveto(handles,'endTrial');
%                             end
%                             
%                          end
%                      end
                     
%                case 'WAITRESPONSEUP'          
%                    %timer callback has occured
%                    disp('wait response timer up')
%                    handles.user.program.trial(nTrial).outcome = 'outoftime';
%                    
%                    %play sound if requested
%                    if ~isnan(handles.user.program.trial(nTrial).waitResponseTimeTone)
%                        packet = sprintf('TON,%d,%d,1,0',handles.user.program.trial(nTrial).waitResponseTimeTone,handles.user.program.trial(nTrial).cueLoc);
%                        psendPacket(handles,packet)
%                    end
%                    
%                    handles = moveto(handles,'endTrial');
%                    
%            end
       end
  case 'endTrial'
        nTrial = handles.user.program.nTrial;       
       if entering
              fprintf('entering endTrial\n');
              log2file(handles);
              
             %stop timers
             try
                stop(handles.user.program.waitResponseTimer)
             end
             
         
              %if we are not waiting for a flush program to complete,
              %start a flush for the cue and move to the next trial
              handles.user.program.olfEvtObj.status
              if strcmp(handles.user.program.olfEvtObj.status,'idle')
                  % make flush of the cue location (as it could still have some residual odor
                   set(handles.user.program.olfEvtObj,'location', handles.user.program.trial(nTrial).cueLoc,...
                                                 'odorID',   1,...
                                                 'odorDelay',0,...
                                                 'odorDur', 5,...  
                                                 'flushDur',0.1,...
                                                 'flushID',1,...
                                                 'offLoc',6,'offID',1);
                    
                  start( handles.user.program.olfEvtObj);                        
                  handles = moveto(handles,'endTrialTasks');
              end
       else
            switch events{1}
                 case 'ODORFLUSHEND'
                   %make flush of the cue location (as it could still have some residual odor
                   set(handles.user.program.olfEvtObj,'location', handles.user.program.trial(nTrial).cueLoc,...
                                                 'odorID',   1,...
                                                 'odorDelay',0,...
                                                 'odorDur', 5,...  
                                                 'flushDur',0.1,...
                                                 'flushID',1,...
                                                 'offLoc',6,'offID',1);
                    
                  start( handles.user.program.olfEvtObj);                        
                  handles = moveto(handles,'endTrialTasks');
            end
           
       end
  case 'endTrialTasks'
       nTrial = handles.user.program.nTrial;       
       if entering
              fprintf('entering endTrialTasks\n');
              log2file(handles);
              
              %just permute teh odor mappings automatically
              switch get(handles.user.program.UI.sampleOdors,'string')
                  case '2,3'
                      set(handles.user.program.UI.sampleOdors,'string','4,5')
                  case '4,5'
                      set(handles.user.program.UI.sampleOdors,'string','2,3')
              end     
              
              %do the auto save here
              trial = handles.user.program.trial;
              try
                  userStem = cell2mat(regexp(userpath,'C:\\\Users\\[^\\]+\\','match'));
                  fileName =[userStem 'Dropbox\behavioural_data\logs\' handles.user.program.sessionName '.mat'];
                  save(fileName,'trial')
              catch
                  fileName =['C:\Users\richp\Dropbox\Princeton\behavioural_data\logs\' handles.user.program.sessionName '.mat'];
                  save(fileName,'trial')
                  
              end
              handles.user.program.sessionName
              handles = moveto(handles,'trialSetup');
       end
      
  case 'finish'
        disp('finishing task')
      
        delete(get(handles.programPanel,'children'));
         try
         toDelete = fields(handles.user.program.UI);
         for i = 1:numel(toDelete)
             try
             delete(handles.user.program.UI.(toDelete{i}))
             end
         end
         end
         handles.user.program = [];
        handles.user.currProg = [];     %clear name of this program since we have left it
    otherwise
        disp(state)
        error('invalid state')
end

guidata(handles.figure1,handles);

end

 %%%%%%%%%%%%%%%%%%%ACTIONS%%%%%%%%%%%%%%
 function handles = moveto(handles,destination)
 %this is the interface for moving to another state,
 %inputs - handles:    the handles structure
 %       - destination: a string with the destination state name
 %
 %outputs - handles:  the handles structure

 %stop the tup timer from the previous state (if running)
 if isfield(handles.user.program,'tupTimer') && strcmp(get(handles.user.program.tupTimer,'running'),'on')     
    stop(handles.user.program.tupTimer);
 end
 
 %set the state to the destination
 handles.user.program.state  = destination;  
 
 %generate the filename
 thisFile = mfilename;
 
 %evaluate the function 
 eval(sprintf('handles =%s([],handles);',thisFile));
 
 end
 
 function [] = giveReward(handles,numReward,location)
 if isempty(numReward)
     numReward = 1;
 end
 if nargin < 3
     location = handles.user.program.goal;
 end
 
 %trigger it through the interface
 %but overide the number of rewards to give
 %all other setting are default
 guidata(handles.figure1,handles);
 controllerGUI('general_RewEvt_callback',handles.figure1,0,handles,location,numReward )
 
 end
 
 
 %%%%%%%%%%%%%%%%%%%%%%%%HOUSEKEEPING%%%%%%%%%%%%%%%%%
 function []= log2file(handles)
 state = handles.user.program.state;
 i = handles.user.program.nTrial;
 set(handles.user.program.UI.curStateText,'string',sprintf('trial %d, %s',i,state))
 
 fprintf(handles.user.serial.user.dlogFid,'MS %s,%s,trial%i,%.10f\n',state,mfilename,i,now);
 end

 function handles = updateOdorMapping(handles)
 %this function gets invoked when parameteres are changed and will put
 %those parameters into the correct data structures as well do any UI stuff
 %that needs doing
 
handles.user.program.odorLib = sscanf(get(handles.user.program.UI.odorLibEdit,'string'),'%d,');                                  
handles.user.program.sampleLocsLib = sscanf(get(handles.user.program.UI.sampleLocsEdit,'string'),'%d,');                                  
for i = 1:4
    if i <= numel(handles.user.program.sampleLocsLib);
        
    set(handles.user.program.UI.(sprintf('odorMapLoc%d',i)),...
        'string',num2str(handles.user.program.odorLib(i)),'visible','on')
    
    set(handles.user.program.UI.(sprintf('odorMapOdor%d',i)),...
        'string',[arrayfun(@(x){num2str(x)},handles.user.program.odorLib)]',...
        'value',i,'visible','on')
    else
        set(handles.user.program.UI.(sprintf('odorMapLoc%d',i)),'visible','off')
        set(handles.user.program.UI.(sprintf('odorMapOdor%d',i)),'visible','off')

    end
end

if get(handles.user.program.UI.randOdorMappingCheck,'value') == 1
    %disable the dropdowns
    for i = 1:4
        set(handles.user.program.UI.(sprintf('odorMapOdor%d',i)),'enable',0)
    end
    
end

end
 
 

