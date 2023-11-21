function[handles] = pFSM_alternation(event,handles)

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
          %[handles] = taskUIelements(handles, UIdata)

           %name UIdata = {name,string,type,editValue} 

            

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
            
          
             row = 2; col = 2; 
             handles.user.program.UI.odorLibEdit = uicontrol('style','edit','units','normalized',...
                                          'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize/1.5]),...
                                          'string','2,3,4', 'enable','on');
             row = 2; col = 1; 
             handles.user.program.UI.odorLibText = uicontrol('style','text','units','normalized',...
                                          'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize]),...
                                          'string','odor library', 'enable','on');
                                      
             row = 3; col = 2; 
             handles.user.program.UI.sampleLocsEdit = uicontrol('style','edit','units','normalized',...
                                          'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize/1.5]),...
                                          'string','2,3', 'enable','on');
             row = 3; col = 1; 
             handles.user.program.UI.sampleLocsText = uicontrol('style','text','units','normalized',...
                                          'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize]),...
                                          'string','sampleLocs', 'enable','on');
                                      
             set(handles.pushbuttonStartProg,'enable','on');

        else
            %we are responding to an event
            switch events{1}
                
                case 'TASKSTART'
                     %we create trial by trial parameter boxes which can be
                     %changed on a trial by trial basis
                    
                    %disable all of the other UI controls that are involved
                    %in the set
                    fieldNames = fields(handles.user.program.UI);
                    for i = 1:numel(fieldNames)
                        if ~strcmp(get(handles.user.program.UI.(fieldNames{i}),'style'),'text')
                            set(handles.user.program.UI.(fieldNames{i}),'enable','off')
                        end
                    end
                    
                    row = 4; col = 1;
                    handles.user.program.UI.randOdorMappingText = uicontrol('style','text','units','normalized',...
                        'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize]),...
                        'string','rand odor mapping', 'enable','on');
                    
                    row = 4; col = 2;
                    handles.user.program.UI.randOdorMappingCheck = uicontrol('style','checkbox','units','normalized',...
                        'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize/1.5]),...
                        'enable','on');
                    
                    %create the drop downs for the location odor mapping
                    for i = 1:4
                        row = 4+i; col = 1;
                        handles.user.program.UI.(sprintf('odorMapLoc%d',i)) = uicontrol('style','text','units','normalized',...
                            'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize]),...
                            'string','~~~', 'enable','off');
                        
                        row = 4+i; col = 2;
                        handles.user.program.UI.(sprintf('odorMapOdor%d',i)) = uicontrol('style','popupmenu','units','normalized',...
                            'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize/1.5]),...
                            'enable','on');
                    end
                    
                    handles = updateOdorMapping(handles);

                    
                    %ui elements for the odor dration                   
                    row = 1; col = 4;
                    handles.user.program.UI.odorDurEdit = uicontrol('style','edit','units','normalized',...
                        'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize/1.5]),...
                        'string','1', 'enable','on');
                    
                    row = 1; col = 3;
                    handles.user.program.UI.odorDurText = uicontrol('style','text','units','normalized',...
                        'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize]),...
                        'string','odorDur (s)', 'enable','on');
                    
                   %ui elements for the flush duration                
                    row = 2; col = 4;
                    handles.user.program.UI.flushDurEdit = uicontrol('style','edit','units','normalized',...
                        'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize/1.5]),...
                        'string','2', 'enable','on');
                    
                    row = 2; col = 3;
                    handles.user.program.UI.flushDurText = uicontrol('style','text','units','normalized',...
                        'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize]),...
                        'string','flushDur (s)', 'enable','on');
                    
                    %ui elements for error sound
                    row = 3; col = 4;
                    handles.user.program.UI.incorrectToneEdit = uicontrol('style','edit','units','normalized',...
                        'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize/1.5]),...
                        'string','15', 'enable','on');
                    
                    row = 3; col = 3;
                    handles.user.program.UI.incorrectToneText = uicontrol('style','text','units','normalized',...
                        'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize]),...
                        'string','incorrect tone', 'enable','on');
                    
%                     %incorrect choice ends trial
%                     row = 4; col = 3;
%                       handles.user.program.UI.incorrectEndTrialText = uicontrol('style','text','units','normalized',...
%                         'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize]),...
%                         'string','incorrect ends trial', 'enable','on');
%                     
%                     row = 4; col = 4;
%                      handles.user.program.UI.incorrectEndTrialCheck = uicontrol('style','checkbox','units','normalized',...
%                         'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize/1.5]),...
%                         'enable','on');

                    %probabilityt that incorrect choice ends trial
                     row = 4; col = 3;
                      handles.user.program.UI.incorrectEndTrialText = uicontrol('style','text','units','normalized',...
                        'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize*1.25  ysize]),...
                        'string','prob incorrect ends trial', 'enable','on');
                    
                    row = 4; col = 4;
                     handles.user.program.UI.incorrectEndTrialEdit =  uicontrol('style','edit','units','normalized',...
                        'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize/1.5]),...
                        'string','0', 'enable','on');
                    
                    %make a timer for putting a beep at the correct
                    %location if the teh incorrect choice does not end the
                    %trial
                     
                    handles.user.program.incorrectTutorTimer = timer('startdelay',1);
                    
                    
   
                    
                     %incorrect timeout
                     row = 5; col = 3;
                      handles.user.program.UI.incorrectTimeOutText = uicontrol('style','text','units','normalized',...
                        'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize]),...
                        'string','incorrect time out (s)', 'enable','on');
                    
                    row = 5; col = 4;
                     handles.user.program.UI.incorrectincorrectTimeOutEdit = uicontrol('style','edit','units','normalized',...
                        'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize/1.5]),...
                        'string','0', 'enable','on');
                    
                     %play odor on incorrec
                     row = 6; col = 3;
                      handles.user.program.UI.incorrectOdorText = uicontrol('style','text','units','normalized',...
                        'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize]),...
                        'string','odor on incorrect', 'enable','on');
                    
                    row = 6; col = 4;
                      handles.user.program.UI.incorrectOdorCheck = uicontrol('style','checkbox','units','normalized',...
                                            'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize/1.5]),...
                                            'enable','on');

                    
                     
                    %trial start button
                    row = 1; col = 5;
                    handles.user.program.UI.startButton = uicontrol('style','pushbutton',...
                        'units','normalized',...
                        'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize]),...
                        'string','start trial',...
                        'callback',@(~,~)pdispatch('TRIALSTART',guidata(handles.figure1)),...
                        'enable','off');
                    
                    %cue poke button
                    row = 1; col = 6;
                    handles.user.program.UI.cuePokeButton = uicontrol('style','pushbutton',...
                        'units','normalized',...
                        'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize]),...
                        'string','cue poke',...
                        'callback',@(~,~)pdispatch('CUEPOKE',guidata(handles.figure1)),...
                        'enable','off');
                    
                    handles.user.program.cuePokeButtonTimer = timer('timerfcn',@(~,~)pdispatch('CUEPOKE',guidata(handles.figure1)),...
                                                                    'startdelay',1.1);
                    
                    %make a currnet state display
                     row = 2; col = 5;
                     handles.user.program.UI.curStateText = uicontrol('style','text','units','normalized',...
                        'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize]),...
                        'string','trialSetup');
                    
                    %checkbox for skip samples
                    row = 7; col = 1;
                    handles.user.program.UI.skipSampleText = uicontrol('style','text','units','normalized',...
                        'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize]),...
                        'string','skip sample', 'enable','on');
                    
                    row = 7; col = 2;
                    handles.user.program.UI.skipSampleCheck = uicontrol('style','checkbox','units','normalized',...
                        'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize/1.5]),...
                        'enable','on');
                 
                    
%                     %checkbox for just tone on cue
%                     row = 8; col = 1;
%                     handles.user.program.UI.justToneOnCueText = uicontrol('style','text','units','normalized',...
%                         'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize]),...
%                         'string','just Tone On Cue', 'enable','on');
%                     
%                     row = 8; col = 2;
%                     handles.user.program.UI.justToneOnCueCheck = uicontrol('style','checkbox','units','normalized',...
%                         'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize/1.5]),...
%                         'enable','on');
                    
                    %probability of reward on cue
                     row = 8; col = 1;
                    handles.user.program.UI.probRewardOnCueText = uicontrol('style','text','units','normalized',...
                        'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize*1.2  ysize]),...
                        'string','prob reward on cue', 'enable','on');
                    
                    row = 8; col = 2;
                    handles.user.program.UI.probRewardOnCueEdit =uicontrol('style','edit','units','normalized',...
                        'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize/1.5]),...
                        'string','1', 'enable','on');
                    
                     
                    %probability of debiasing algo to be used
                     row = 8; col = 3;
                    handles.user.program.UI.probDebiasText = uicontrol('style','text','units','normalized',...
                        'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize]),...
                        'string','prob debias used', 'enable','on');
                    
                    row = 8; col = 4;
                    handles.user.program.UI.probDebiasEdit =uicontrol('style','edit','units','normalized',...
                        'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize/1.5]),...
                        'string','1', 'enable','on');
                    
                      %display for goal 
                    row = 4; col = 8;
                    handles.user.program.UI.currentGoalDisplay = uicontrol('style','text','units','normalized',...
                        'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize*3]),...
                        'string','0', 'enable','on','fontsize',50,'BackgroundColor',[1 1 1]);
                    
                   
                 
                    
                    handles.user.program.olfEvtObj = odorEvt(handles.figure1,1,1,1,1,1,1);
                    
                    %assign the variables for the program
                    handles.user.program.state  = 'setup';     %current state;
                    
                    
                    %set to the default flow location
                    command = sprintf('OLF,%d,%d',6,1);
                    psendPacket(handles,command);
                    
                    handles.user.program.nVisit = 1;
                    handles.user.program.nTrial = 1;
                    %go to the next state
                    handles = moveto(handles,'trialSetup');
            end
            
        end
        
    case 'trialSetup'
        if entering
            log2file(handles);
            
            odorLib = handles.user.program.odorLib;
            
            if get(handles.user.program.UI.randOdorMappingCheck,'value') == 1
                %randomise the drop down odor maps
                picks = randperm(numel(odorLib));
                for i = 1:numel(handles.user.program.sampleLocsLib)
                    set(handles.user.program.UI.(sprintf('odorMapOdor%d',i)),'value',picks(i));
                end
            else
                
                for i = 1:numel(handles.user.program.sampleLocsLib)
                    set(handles.user.program.UI.(sprintf('odorMapOdor%d',i)),'enable','on');
                end
                
            end
            
            %activate certain inputs
            set(handles.user.program.UI.odorDurEdit,'enable','on')
            set(handles.user.program.UI.flushDurEdit,'enable','on')
            set(handles.user.program.UI.incorrectToneEdit,'enable','on')

            
            set(handles.user.program.UI.startButton ,'enable','on')
            uicontrol(handles.user.program.UI.startButton)
              
              
        else
            switch events{1}
                case 'TRIALSTART'
                    
                    nTrial = handles.user.program.nTrial;
                    
                    sampleLoc = handles.user.program.sampleLocsLib';
                    handles.user.program.trial(nTrial).sampleLoc =  sampleLoc;
                    odorLib = handles.user.program.odorLib;
                    
                    if get(handles.user.program.UI.randOdorMappingCheck,'value') == 1
                        %randomise the drop down odor maps
                        picks = randperm(numel(odorLib));
                        for i = 1:numel(handles.user.program.sampleLocsLib)
                            set(handles.user.program.UI.(sprintf('odorMapOdor%d',i)),'value',picks(i));
                        end
                    end
                    
                    %read the mapping from the odor drop down menus
                    handles.user.program.trial(nTrial).sampleOdor = [];
                    for i = 1:numel(handles.user.program.sampleLocsLib)
                        set(handles.user.program.UI.(sprintf('odorMapOdor%d',i)),'enable','off');
                        ind = get(handles.user.program.UI.(sprintf('odorMapOdor%d',i)),'value');
                        handles.user.program.trial(nTrial).sampleOdor(i) = odorLib(ind);
                    end
                    
                    %deactivate certain inputs
                    set(handles.user.program.UI.odorDurEdit,'enable','off')
                    set(handles.user.program.UI.flushDurEdit,'enable','off')
                    set(handles.user.program.UI.incorrectToneEdit,'enable','off')
            
                    handles.user.program.trial(nTrial).sampleVisited = zeros(1,numel(sampleLoc));
                    
                    handles.user.program.trial(nTrial).sampleOdorDelay = 0;
                    handles.user.program.trial(nTrial).sampleOdorDur =  str2num(get(handles.user.program.UI.odorDurEdit,'string'));
                    handles.user.program.trial(nTrial).sampleFlushDur = str2num(get(handles.user.program.UI.flushDurEdit,'string'));
                    
                    handles.user.program.trial(nTrial).currentTarget = handles.user.program.trial(nTrial).sampleLoc;  %the current target where he has to go/where he is
                    
                    handles.user.program.trial(nTrial).cueLoc = 1; %the location of the cue
                    
                    %this is the the one of hte sample locations that is teh ultiamte goal location
                    %this is the debiasng protocol
                    if numel(handles.user.program.trial)>4
                       for i = 1:3
                           if strcmp(handles.user.program.trial(nTrial-i).outcome,'correct')
                              prevChoice(i) = handles.user.program.trial(nTrial-i).goalLoc;
                           else
                               prevChoice(i) = rem(handles.user.program.trial(nTrial-i).goalLoc+1,2)+2;
                           end
                       end
                       
                       %if the last three trials were the same choice
                       %(regardless of the outcome)
                       probDebias = str2num(get(handles.user.program.UI.probDebiasEdit,'string'));
                       if rand > probDebias 
                           deBias = false;
                       else
                           deBias = true;
                       end
                       
                       if deBias && numel(unique(prevChoice)) == 1 
                           %make this trial the other option
                           switch prevChoice(1)
                               case 2;handles.user.program.trial(nTrial).goalLoc = 3;
                               case 3;handles.user.program.trial(nTrial).goalLoc = 2;
                           end
                       else
                           handles.user.program.trial(nTrial).goalLoc = handles.user.program.trial(nTrial).sampleLoc(randi(numel(sampleLoc)));
                       end
                    else 
                        handles.user.program.trial(nTrial).goalLoc = handles.user.program.trial(nTrial).sampleLoc(randi(numel(sampleLoc)));

                    end
                    set(handles.user.program.UI.currentGoalDisplay,'string',num2str(handles.user.program.trial(nTrial).goalLoc));
                    
                    %find the goal locaiton in teh possible sample location array
                    ind = handles.user.program.trial(nTrial).goalLoc == handles.user.program.trial(nTrial).sampleLoc;
                    
                    handles.user.program.trial(nTrial).cueOdor = handles.user.program.trial(nTrial).sampleOdor(ind);
                    handles.user.program.trial(nTrial).cueOdorDelay = 0;
                    handles.user.program.trial(nTrial).cueOdorDur =   str2num(get(handles.user.program.UI.odorDurEdit,'string'));
                    handles.user.program.trial(nTrial).cueFlushDur =  str2num(get(handles.user.program.UI.flushDurEdit,'string'));
                    
                    handles.user.program.trial(nTrial).incorrectTone = str2num(get(handles.user.program.UI.incorrectToneEdit,'string'));   %tone when arrives at incorrect location during the response phase

                    
                    handles.user.program.trial(nTrial).outcome = [];
                    
                    set(handles.user.program.UI.startButton ,'enable','off')
                    set(handles.user.program.UI.cuePokeButton,'enable','on')
                    
                    %setup some of that data save fields
                    handles.user.program.trial(nTrial).sampleChoiceLoc = [];
                    handles.user.program.trial(nTrial).sampleChoiceTime = [];
                    handles.user.program.trial(nTrial).sampleChoiceOutcome = [];
                    
                    handles.user.program.trial(nTrial).startTime = now;
                    handles.user.program.trial(nTrial).randnum = rand;
                    
                    handles = moveto(handles,'waitSample');
                    
            end
            
        end

    case 'waitSample'
         nTrial = handles.user.program.nTrial;

         if entering
              disp('entering waitSample')
              
              %if we are being asked to skip the sample phase
              if get(handles.user.program.UI.skipSampleCheck,'value') == 1
                  fprintf('skipping sample phase')
                  log2file(handles);
                  handles = moveto(handles,'waitCue');

              else
                  fprintf('current targets are location(s)')
                  disp(handles.user.program.trial(nTrial).currentTarget)
                  log2file(handles);
              end
         else
             switch events{1}
                 case 'IRB'
                     %photobeam was broken %check which device
                     loc = str2num(events{2});
                     
                     if str2num(events{3})==1
                         handles.user.program.trial(nTrial).sampleChoiceLoc  = [handles.user.program.trial(nTrial).sampleChoiceLoc loc];
                         handles.user.program.trial(nTrial).sampleChoiceTime = [handles.user.program.trial(nTrial).sampleChoiceTime now];
                         
                         if any(handles.user.program.trial(nTrial).currentTarget == loc)
                             %check that there is not an odor flush event still
                             %occuring (if there is cannot proceed)
                             if strcmp(handles.user.program.olfEvtObj.status,'idle')
                                 handles.user.program.trial(nTrial).sampleChoiceOutcome = [handles.user.program.trial(nTrial).sampleChoiceOutcome 'correctLoc'];
                                 
                                 %update his current location
                                 handles.user.program.trial(nTrial).currentTarget = loc;
                                 handles = moveto(handles,'sample');
                             else
                                 %stay in the same state
                                 handles.user.program.trial(nTrial).sampleChoiceOutcome = [handles.user.program.trial(nTrial).sampleChoiceOutcome 'olfNotIdle'];
                                 
                             end
                             handles.user.program.trial(nTrial).sampleChoiceOutcome = [handles.user.program.trial(nTrial).sampleChoiceOutcome 'wrongLoc'];
                             
                         end
                     end
             end
         end
         
    case 'sample'
        
        nTrial = handles.user.program.nTrial;
        sampleLoc = handles.user.program.trial(nTrial).currentTarget;
        sampleInd =  sampleLoc == handles.user.program.trial(nTrial).sampleLoc;
        if entering
            
            log2file(handles)
            disp('entering sample')

              %program the odor timer system
              set(handles.user.program.olfEvtObj,'location',sampleLoc,...
                                                 'odorID',   handles.user.program.trial(nTrial).sampleOdor(sampleInd),...
                                                 'odorDelay',handles.user.program.trial(nTrial).sampleOdorDelay,...
                                                 'odorDur',  handles.user.program.trial(nTrial).sampleOdorDur,...
                                                 'flushDur', handles.user.program.trial(nTrial).sampleFlushDur,...
                                                 'flushID',1,...
                                                 'offLoc',6,'offID',1);
              start(handles.user.program.olfEvtObj);
              
              %start the reward event    
              controllerGUI('general_RewEvt_callback',handles.figure1,1,handles,sampleLoc,2)
        
        else
            switch events{1}
                case 'IRB'
                    %photobeam was broken %check which device
                    loc = str2num(events{2});
                    nTrial = handles.user.program.nTrial;
                    
                    if handles.user.program.trial(nTrial).currentTarget == loc && str2num(events{3})==0
                        olfStatus = handles.user.program.olfEvtObj.status;
                        switch olfStatus
                            case 'preOdor'
                                %stop the odor
                                stop(handles.user.program.olfEvtObj);
                                %stop the reward
                                
                                %but do not mark this sample location as being
                                %visited
                                handles = moveto(handles, 'waitSample');
                                
                            case {'flush','idle', 'odor'}
                                
                                if strcmp(olfStatus,'odor')
                                    %stop(handles.user.program.olfEvtObj)
                                end 
                              
                                %record that he has visited this sample location
                                ind = sampleLoc == handles.user.program.trial(nTrial).sampleLoc;
                                handles.user.program.trial(nTrial).sampleVisited(ind) = 1;
                                
                                if all(handles.user.program.trial(nTrial).sampleVisited == 1)
               
                                 %set the odor off state to blank air at the cue location 
                                   switch olfStatus
                                       case 'idle'
                                         command = sprintf('OLF,%d,%d',handles.user.program.trial(nTrial).cueLoc,1);
                                         psendPacket(handles,command);
                                       case {'flush', 'odor'}
                                         set(handles.user.program.olfEvtObj,'offLoc',handles.user.program.trial(nTrial).cueLoc,'offID',1)    
                                   end
                                   
                                    %move to the cue wait state
                                    handles = moveto(handles, 'waitCue');
                                    
                                else
                                    %he still has some samples to do
                                    currentTarget = handles.user.program.trial(nTrial).sampleLoc(~handles.user.program.trial(nTrial).sampleVisited);
                                    handles.user.program.trial(nTrial).currentTarget = currentTarget;
                                    handles = moveto(handles, 'waitSample');

                                end
                        end
                    end
            end
        end
        
    case 'waitCue'
      nTrial = handles.user.program.nTrial;
       if entering
              log2file(handles);
              disp('entering waitCue')
              handles.user.program.trial(nTrial).currentTarget  = handles.user.program.trial(nTrial).cueLoc;
              switch handles.user.program.olfEvtObj.status
                  case 'idle'
                      command = sprintf('OLF,%d,%d',handles.user.program.trial(nTrial).cueLoc,1);
                      psendPacket(handles,command);
                  case {'flush', 'odor','preOdor'}
                      set(handles.user.program.olfEvtObj,'offLoc',handles.user.program.trial(nTrial).cueLoc,'offID',1)
              end
       else
           switch events{1}
                                           

                case 'IRB'
                    loc = str2num(events{2});
                    if handles.user.program.trial(nTrial).currentTarget == loc && str2num(events{3})==1 
                        handles.user.program.trial(nTrial).cuePokeTime = now; 
                        handles = moveto(handles, 'cue');        
                    end
               case 'CUEPOKE'
                   %this can act as a synthetic cue poke
                   handles.user.program.trial(nTrial).cuePokeTime = now; 
                   handles = moveto(handles, 'cue'); 
                   start(handles.user.program.cuePokeButtonTimer)

           end
       end
       
    case 'cue'
        nTrial = handles.user.program.nTrial;
        if entering
              log2file(handles);
              disp('entering cue')
              
              %program the odor timer system
              set(handles.user.program.olfEvtObj,'location' ,handles.user.program.trial(nTrial).cueLoc,...
                                                 'odorID',   handles.user.program.trial(nTrial).cueOdor,...
                                                 'odorDelay',handles.user.program.trial(nTrial).cueOdorDelay,...
                                                 'odorDur',  handles.user.program.trial(nTrial).cueOdorDur,...
                                                 'flushDur', handles.user.program.trial(nTrial).cueFlushDur,...
                                                 'flushID',1,...
                                                 'offLoc',6,'offID',1);
              start(handles.user.program.olfEvtObj);
              
              probRewardOnCue = str2num(get(handles.user.program.UI.probRewardOnCueEdit,'string'));
              
              if rand > probRewardOnCue
                  
                  disp('no reward, only sound')
                  %just play the (current) reward tone
                  location = handles.user.program.trial(nTrial).cueLoc;

                   tone = str2num(get(handles.rewEvt_tone,'string'));
                    packet = sprintf('TON,%d,%d,1,0',tone,location);
                    psendPacket(handles,packet)

              else
                  disp('sound and reward')

                  %start the reward event 
                  controllerGUI('general_RewEvt_callback',handles.figure1,1,handles,handles.user.program.trial(nTrial).cueLoc,1)
              end
        else
             switch events{1}
                case {'IRB' , 'CUEPOKE'}
                    %photobeam was broken check which device
                    if strcmp(events{1},'IRB')
                        loc = str2num(events{2});
                    else
                        loc = nan;
                    end
               
                    if strcmp(events{1}, 'CUEPOKE') || (handles.user.program.trial(nTrial).currentTarget == loc && str2num(events{3})== 0) 
                        %if photobeam unbroken at current location
                        
                        switch handles.user.program.olfEvtObj.status
                            case 'preOdor'
                                %stop the odor
                                %but do not mark this sample location as being
                                %visited
                                handles = moveto(handles, 'waitCue');
                                %(perhaps need to implement a timout
                                %here..?) to stop him just multi hitting
                                %for rewards...
                            case {'flush','idle', 'odor'}
                                if strcmp(handles.user.program.olfEvtObj.status,'odor')
                                    %stop(handles.user.program.olfEvtObj)
                                end
                                %stop the reward timer

                                handles.user.program.trial(nTrial).currentTarget =  handles.user.program.trial(nTrial).goalLoc;
                                handles = moveto(handles, 'waitResponse'); 
                        end
                    end         
             end
        end
         
    case 'waitResponse'
        nTrial = handles.user.program.nTrial;
        if entering
            log2file(handles);
            disp('entering waitResponse')

        else
            switch events{1}
                case 'IRB'
                    loc = str2num(events{2});
                    if handles.user.program.trial(nTrial).currentTarget == loc && str2num(events{3})==1
                        %animal visited a correct location
                        if  isempty(handles.user.program.trial(nTrial).outcome)
                            %only update the outcome if he did not make
                            %any previous choices
                            handles.user.program.trial(nTrial).outcome = 'correct';
                            handles.user.program.trial(nTrial).firstChoice = loc;
                            handles.user.program.trial(nTrial).firstChoiceTime = now;
                        end
                        disp('correct location')
                        handles = moveto(handles, 'response');
                        
                    elseif  any(loc == handles.user.program.trial(nTrial).sampleLoc) && str2num(events{3})==1
                        %animal visited a wrong location
                        %stay in the same state, but just record some data
                        
                        if isempty(handles.user.program.trial(nTrial).outcome)
                            handles.user.program.trial(nTrial).outcome = 'incorrect';
                             handles.user.program.trial(nTrial).firstChoice = loc;
                             handles.user.program.trial(nTrial).firstChoiceTime = now;
                             
                            firstVisit = true;
                        else
                            firstVisit = false;

                        end
                        disp('incorrect location')
                        
                        %make a worng locaiton sound?
                        packet = sprintf('TON,%d,%d,1,0',handles.user.program.trial(nTrial).incorrectTone,loc);
                        psendPacket(handles,packet)
                        
                        
                        
                        %if requested present the odor of this incorrect
                        %location
                        if get(handles.user.program.UI.incorrectOdorCheck,'value') && firstVisit
                            ind = loc == handles.user.program.trial(nTrial).sampleLoc;
                            set(handles.user.program.olfEvtObj,'location' ,loc,...
                                'odorID',   handles.user.program.trial(nTrial).sampleOdor(ind),...
                                'odorDelay',handles.user.program.trial(nTrial).sampleOdorDelay,...
                                'odorDur',  handles.user.program.trial(nTrial).sampleOdorDur,...
                                'flushDur', handles.user.program.trial(nTrial).sampleFlushDur,...
                                'flushID',1);
                            start(handles.user.program.olfEvtObj);
                        end
                        
                        
                        
                        %if incorrect is to start a new trial, then move to
                        %the next trial, 
                        %if get(handles.user.program.UI.incorrectEndTrialCheck,'value') == 1
                        
                        %probabalistic
                        if  handles.user.program.trial(nTrial).randnum  < str2num(get(handles.user.program.UI.incorrectEndTrialEdit,'string'))
                            %now check to see if there is a timeout
                            %resquested
                            if str2num(get(handles.user.program.UI.incorrectincorrectTimeOutEdit,'string')) ~=0
                                %go to timeout state
                                handles = moveto(handles,'timeOut');

                                
                            else
                              %go straight to next trial
                              handles.user.program.nTrial = handles.user.program.nTrial+1;
                              handles = moveto(handles,'trialSetup');
                            end
                            
                        
                        else
                              %stay in the same state 
                              %(the trial is marked as incorrect, so a
                              % subsequent correction with give smaller
                              % reward)
                              if firstVisit
                                  %make a beep at the actual reward place
                                  location = handles.user.program.trial(nTrial).currentTarget;
                                  tone = str2num(get(handles.rewEvt_tone,'string'));
                                  packet = sprintf('TON,%d,%d,1,0',tone,location);
                                  set(handles.user.program.incorrectTutorTimer,'timerfcn',@(~,~)psendPacket(guidata(handles.figure1),packet),'startDelay',1);
                                  start(handles.user.program.incorrectTutorTimer);
                                  
                              end
                        end
                    end
            end
        end
       
    case 'response'
        if entering
             log2file(handles);
             disp('entering response')
             nTrial = handles.user.program.nTrial;
             %present odor
             ind = handles.user.program.trial(nTrial).goalLoc == handles.user.program.trial(nTrial).sampleLoc;
             set(handles.user.program.olfEvtObj,'location' ,handles.user.program.trial(nTrial).goalLoc,...
                 'odorID',   handles.user.program.trial(nTrial).sampleOdor(ind),...
                 'odorDelay',handles.user.program.trial(nTrial).sampleOdorDelay,...
                 'odorDur',  handles.user.program.trial(nTrial).sampleOdorDur,...
                 'flushDur', handles.user.program.trial(nTrial).sampleFlushDur,...
                 'flushID',1);
             start(handles.user.program.olfEvtObj);
             
             %check to see whether this was a correct or incorrect response
             switch handles.user.program.trial(nTrial).outcome
                 case 'correct'
                     %give large reward
                     %disp('large reward')
                     %controllerGUI('general_RewEvt_callback',handles.figure1,1,handles,handles.user.program.trial(nTrial).goalLoc,8,@()exprnd(300))
                     controllerGUI('general_RewEvt_callback',handles.figure1,1,handles,handles.user.program.trial(nTrial).goalLoc)
                     
                 case 'incorrect'
                     
                     if 1
                         %give normal reward
                         disp('normal')
                         controllerGUI('general_RewEvt_callback',handles.figure1,1,handles,handles.user.program.trial(nTrial).goalLoc)        
                     else
                     
                        %give small reward
                        disp('small reward')
                        controllerGUI('general_RewEvt_callback',handles.figure1,1,handles,handles.user.program.trial(nTrial).goalLoc,1)
                     end

              end
        else
            switch events{1}
                case 'IRB'
                    loc = str2num(events{2});
                    nTrial = handles.user.program.nTrial;
                    if handles.user.program.trial(nTrial).currentTarget == loc && str2num(events{3})== 0
                         if strcmp(handles.user.program.olfEvtObj.status,'odor')
                                    %stop(handles.user.program.olfEvtObj)
                         end
                        
                        handles.user.program.nTrial = handles.user.program.nTrial+1;
                        handles = moveto(handles,'trialSetup');

                    end
            end
        end
        
    case 'timeOut'
        if entering
             log2file(handles);
             disp('entering timeout')
            %put the time out time in the timer
            timeOutTime = str2num(get(handles.user.program.UI.incorrectincorrectTimeOutEdit,'string'));
            if ~isfield(handles.user.program,'timeOutTimer')
                handles.user.program.timeOutTimer = timer('timerfcn',@(~,~)pdispatch('TIMEOUT',guidata(handles.figure1)),...
                                                                    'startdelay',timeOutTime );
            else
                set(handles.user.program.timeOutTimer,'startdelay',timeOutTime);
            end
            start(handles.user.program.timeOutTimer);
            
        else
            switch events{1}
                case 'TIMEOUT'
                    %play the end of timeout sound
                    packet = sprintf('TON,%d,%d,1,0',10,1);
                    psendPacket(handles,packet)
                    handles.user.program.nTrial = handles.user.program.nTrial+1;
                    handles = moveto(handles,'trialSetup');
            end
        end

        
    case 'finish'
        %we only enter here once
        disp('finishing task')
      
        delete(get(handles.programPanel,'children'));

         toDelete = fields(handles.user.program.UI);
         for i = 1:numel(toDelete)
             delete(handles.user.program.UI.(toDelete{i}))
         end
         handles.user.program = [];
        handles.user.currProg = [];     %clear name of this program since we have left it
        
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
 
 

