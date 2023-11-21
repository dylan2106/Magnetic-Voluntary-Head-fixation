function[handles] = pFSM_single_location_presentation(event,handles)

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
                    
                    %trial start button
                    row = 1; col = 5;
                    handles.user.program.UI.startButton = uicontrol('style','pushbutton',...
                        'units','normalized',...
                        'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize]),...
                        'string','start trial',...
                        'callback',@(~,~)pdispatch('TRIALSTART',guidata(handles.figure1)),...
                        'enable','off');
                    
                    %make a currnet state display
                     row = 2; col = 5;
                     handles.user.program.UI.curStateText = uicontrol('style','text','units','normalized',...
                        'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize]),...
                        'string','trialSetup');
                    
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
            
                    
                    handles.user.program.trial(nTrial).sampleOdorDelay = 0;
                    handles.user.program.trial(nTrial).sampleOdorDur =  str2num(get(handles.user.program.UI.odorDurEdit,'string'));
                    handles.user.program.trial(nTrial).sampleFlushDur = str2num(get(handles.user.program.UI.flushDurEdit,'string'));
                    
                    %handles.user.program.trial(nTrial).currentTarget = handles.user.program.trial(nTrial).sampleLoc;  %the current target where he has to go/where he is
                    nlocs = numel(handles.user.program.trial(nTrial).sampleLoc);
                    handles.user.program.trial(nTrial).currentTarget = handles.user.program.trial(nTrial).sampleLoc(randi(nlocs));
                    
                    %handles.user.program.trial(nTrial).sampleVisited = zeros(1,numel(sampleLoc));
                    handles.user.program.trial(nTrial).sampleVisited = ones(1,numel(sampleLoc));  % has "visited" all the non targets this trial
                    handles.user.program.trial(nTrial).sampleVisited(sampleLoc == handles.user.program.trial(nTrial).currentTarget) = 0; %except the actual target
                    
                    handles.user.program.trial(nTrial).incorrectTone = str2num(get(handles.user.program.UI.incorrectToneEdit,'string'));   %tone when arrives at incorrect location during the response phase

                    
                    handles.user.program.trial(nTrial).outcome = [];
                    
                    set(handles.user.program.UI.startButton ,'enable','off')
               
                    %setup some of that data save fields
                    handles.user.program.trial(nTrial).sampleChoiceLoc = [];
                    handles.user.program.trial(nTrial).sampleChoiceTime = [];
                    handles.user.program.trial(nTrial).sampleChoiceOutcome = [];
                    
                    handles = moveto(handles,'waitSample');
                    
            end
            
        end

    case 'waitSample'
         nTrial = handles.user.program.nTrial;

         if entering
              disp('entering waitSample')
              fprintf('current targets are location(s)')
              disp(handles.user.program.trial(nTrial).currentTarget)
              log2file(handles);
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
                                         set(handles.user.program.olfEvtObj,'offLoc',6,'offID',1)    
                                   end
                                   
                                    %move to the next trial
                                    handles.user.program.nTrial = handles.user.program.nTrial+1;
                                    handles = moveto(handles,'trialSetup');

                                    
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
  case 'finish'
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
 
 

