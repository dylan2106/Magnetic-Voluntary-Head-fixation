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
   isfield(handles.user.program,'state')

    state = handles.user.program.state;
else
    state = 'setup';
end

%special case if there has been a parachange, we need to stop the current
%trial and reintiliase
if  ~isempty(event) && strcmp(events{1},'PARAMCHANGE')
	state = 'setup';
end

switch state
    case 'setup'
        if entering
            %fprintf(handles.user.serial.user.dlogFid,' MS %s,%s,%.10f\n',state,mfilename,now);
            disp('setting initial parameters for alternation')
            %here is the setup code
            
            %clear any previous program data
            handles.user.program = [];
            %initialise the trial structure
            handles.user.program.trial.outcome = [];
            
            %clear any children in the program panel
            delete(get(handles.programPanel,'children'));
            
            %get teh panel position       
            pos = get(handles.programPanel,'position');
            
            %create a function for converting panel relative position
            %vectors into figure realtive
            convPos = @(posIn)[(posIn(1)*pos(3) + pos(1)),...
                               (posIn(2)*pos(4) + pos(2)),...
                               (posIn(3)*pos(3)),...
                               (posIn(4)*pos(4))];
            
            %make a drop down panel to
            ysize =  0.08;
            yspace = 1.25;
            ystart = 0.80;
            handles.user.program.UI.progDrop1 = uicontrol('style','popupmenu',...
                                           'units','normalized',...
                                          'position',convPos([0.03 ystart 0.2 ysize]),...
                                          'string',{'alternation,1,6','alternation,3,4','alternation,5,6','alternation,2,3','alternation,3,2,1','alternation,2,3,1','alternation,6,7','random'},...
                                          'visible','on');
                        
           handles.user.program.UI.rewShotNumEdit = uicontrol('style','edit',...
                                           'units','normalized',...
                                          'position',convPos([0.03+0.15 ystart - (1*ysize*yspace) 0.05 ysize]),...
                                          'string',{'1'},...
                                          'visible','on');
                                      
           handles.user.program.UI.rewShotNumText = uicontrol('style','text',...
                                           'units','normalized',...
                                          'position',convPos([0.03 ystart - (1*ysize*yspace) 0.14 ysize]),...
                                          'string',{'num of rewards'},...
                                          'visible','on','fontsize',6);
                                      
          handles.user.program.UI.rewErrorShotNumEdit = uicontrol('style','edit',...
                                           'units','normalized',...
                                          'position',convPos([0.03+0.15 ystart - (2*ysize*yspace) 0.05 ysize]),...
                                          'string',{'1'},...
                                          'visible','on');
                                      
           handles.user.program.UI.rewErrorShotNumText = uicontrol('style','text',...
                                           'units','normalized',...
                                          'position',convPos([0.03 ystart - (2*ysize*yspace) 0.14 ysize]),...
                                          'string',{'num of rewards on error'},...
                                          'visible','on','fontsize',6);                             
                                      
         handles.user.program.UI.bounceNumEdit = uicontrol('style','edit',...
                                           'units','normalized',...
                                          'position',convPos([0.03+0.15 ystart - (3*ysize*yspace) 0.05 ysize]),...
                                          'string',{'0.5'},...
                                          'visible','on');
                                      
           handles.user.program.UI.bounceNumText = uicontrol('style','text',...
                                           'units','normalized',...
                                          'position',convPos([0.03 ystart - (3*ysize*yspace) 0.14 ysize]),...
                                          'string',{'IR debounce'},...
                                          'visible','on');
                                      

           handles.user.program.UI.goalLedText = uicontrol('style','text',...
                                           'units','normalized',...
                                          'position',convPos([0.03 ystart - (6*ysize*yspace) 0.14 ysize]),...
                                          'string',{'goal Led '},...
                                          'visible','on');
                                      
           handles.user.program.UI.goalLedCheck = uicontrol('style','checkbox',...
                                           'units','normalized',...
                                          'position',convPos([0.03+0.15 ystart - (6*ysize*yspace) 0.05 ysize]),...
                                          'visible','on');
                                      
          handles.user.program.UI.goalAirText = uicontrol('style','text',...
                                           'units','normalized',...
                                          'position',convPos([0.03 ystart - (7*ysize*yspace) 0.14 ysize]),...
                                          'string',{'goal Air flow '},...
                                          'visible','on');
                                      
           handles.user.program.UI.goalAirCheck = uicontrol('style','checkbox',...
                                           'units','normalized',...
                                          'position',convPos([0.03+0.15 ystart - (7*ysize*yspace) 0.05 ysize]),...
                                          'visible','on');
                                      

            %next column
            xspace = 0.1;                           
            handles.user.program.UI.rewDeliverBut = uicontrol('style','pushbutton',...
                                           'units','normalized',...
                                          'position',convPos([0.03+0.15+(xspace*1) ystart-(1*ysize*yspace) 0.15 ysize]),...
                                          'string',{'reward goal (1)'},...
                                          'visible','on',...
                                          'callback',@(~,~)giveReward(guidata(handles.figure1),1));
              %button for each location                        
              for i = 1:6
                  fieldName = sprintf('rewDeliverBut%d',i);
                  handles.user.program.UI.(fieldName) = uicontrol('style','pushbutton',...
                      'units','normalized',...
                      'position',convPos([0.03+0.15+(xspace*1) ystart-((i+1)*ysize*yspace) 0.15 ysize]),...
                      'string',{sprintf('reward loc %d',i)},...
                      'visible','on',...
                      'callback',@(~,~)giveReward(guidata(handles.figure1),1,i));
              end

              %assign the variables for the program
              handles.user.program.state  = 'setup';     %current state;

              set(handles.pushbuttonStartProg,'enable','on');
              
              handles.user.trial  = [];
              handles.user.trialNum = 0;
                                      
        else
            %we are responding to an event
            switch events{1}
                
                case {'TASKSTART','PARAMCHANGE'}
                    if strcmp(events{1},'TASKSTART')
                        trialNumber = 1;
                    elseif strcmp(events{1},'PARAMCHANGE')
                        
                        trialNumber = handles.user.program.trialNum+1;
                    end
                    %disable the UI controls
                    %set(handles.user.program.UI.progDrop1,'enable','off')
                    
                    %read the parameters of the progDrop1
                    strings = get(handles.user.program.UI.progDrop1,'string');
                    val = get(handles.user.program.UI.progDrop1,'value');
                    
                    switch strings{val}
                        case 'alternation,1,6'
                            handles.user.program.trialNum = trialNumber;
                            handles.user.program.goalList = [1 6];
                            handles.user.program.nextGoalFun = @(t,g)handles.user.program.goalList(mod(t-1,numel(handles.user.program.goalList))+1);
                            handles.user.program.goal = handles.user.program.nextGoalFun(handles.user.program.trialNum);
                        case 'alternation,3,4'
                            handles.user.program.trialNum = trialNumber;
                            handles.user.program.goalList = [3 4];
                            handles.user.program.nextGoalFun = @(t,g)handles.user.program.goalList(mod(t-1,numel(handles.user.program.goalList))+1);
                            handles.user.program.goal = handles.user.program.nextGoalFun(handles.user.program.trialNum);
                        case 'alternation,5,6'  
                            handles.user.program.trialNum = trialNumber;
                            handles.user.program.goalList = [5 6];
                            handles.user.program.nextGoalFun = @(t,g)handles.user.program.goalList(mod(t-1,numel(handles.user.program.goalList))+1);
                            handles.user.program.goal = handles.user.program.nextGoalFun(handles.user.program.trialNum);
                        case 'alternation,2,3'
                            handles.user.program.trialNum = trialNumber;
                            handles.user.program.goalList = [2 3];
                            handles.user.program.nextGoalFun = @(t,g)handles.user.program.goalList(mod(t-1,numel(handles.user.program.goalList))+1);
                            handles.user.program.goal = handles.user.program.nextGoalFun(handles.user.program.trialNum);
                         case 'alternation,3,2,1'
                            handles.user.program.trialNum = trialNumber;
                            handles.user.program.goalList = [3 2 1];
                            handles.user.program.nextGoalFun = @(t,g)handles.user.program.goalList(mod(t-1,numel(handles.user.program.goalList))+1);
                            handles.user.program.goal = handles.user.program.nextGoalFun(handles.user.program.trialNum);
                        case 'alternation,2,3,1'
                            handles.user.program.trialNum = trialNumber;
                            handles.user.program.goalList = [2 3 1];
                            handles.user.program.nextGoalFun = @(t,g)handles.user.program.goalList(mod(t-1,numel(handles.user.program.goalList))+1);
                            handles.user.program.goal = handles.user.program.nextGoalFun(handles.user.program.trialNum);     
                    
                        case 'alternation,6,7'
                            handles.user.program.trialNum = trialNumber;
                            handles.user.program.goalList = [6 7];
                            handles.user.program.nextGoalFun = @(t,g)handles.user.program.goalList(mod(t-1,numel(handles.user.program.goalList))+1);
                            handles.user.program.goal = handles.user.program.nextGoalFun(handles.user.program.trialNum);
                        case 'random'
                            handles.user.program.trialNum = trialNumber;
                            handles.user.program.nextGoalFun = @(t,g)randNextTrial(t,g);
                            handles.user.program.goal = handles.user.program.nextGoalFun(handles.user.program.trialNum,0);
                    end
                    
                    %create a timer object that delivers reward to the
                    %animal
                    handles.user.program.timers(1) = timer;
                    handles.user.program.timers(1).ExecutionMode = 'fixedSpacing';
                    
                    %debounce timer
                    handles.user.program.timers(2) = timer;
                    handles.user.program.timers(2).ExecutionMode = 'singleShot';
                    handles.user.program.timers(2).startDelay = 1;
                    
                    %reward tone sound
                    handles.user.program.timers(3) = timer;
                    handles.user.program.timers(3).ExecutionMode = 'fixedSpacing';
                     
                    %reward led 
                    handles.user.program.timers(4) = timer;
                    handles.user.program.timers(4).ExecutionMode = 'fixedSpacing';
                    
                    %once task has been started we can attach the parameter
                    %change callback to the dropdown menu
                    set(handles.user.program.UI.progDrop1,'callback',@(~,~)pdispatch('PARAMCHANGE',guidata(handles.figure1)));
                    %set(handles.user.program.UI.progDrop1,'callback',@(~,~)disp('changed'));

                    %go to the next state
                    handles = moveto(handles,'waitRat');
            end
            
        end
        
        
        
    case 'waitRat'
        if entering
            log2file(handles);
           
            fprintf('trial number %i\n',handles.user.program.trialNum)
            
            %start the goal location flashing if requested
            if get(handles.user.program.UI.goalLedCheck,'Value') == 1
                loc = handles.user.program.goal;
                interval  = str2num(get(handles.LED_interval,'string'));

                psendPacket( handles,sprintf('LED,%d,%d,-1', loc ,interval));
            else
                loc = handles.user.program.goal;
                psendPacket( handles,sprintf('LED,%d,0,0', loc));

            end
            
            %start the gas flow at the location if requested
            if get(handles.user.program.UI.goalAirCheck,'Value') == 1
                command = sprintf('OLF,%d,%d',handles.user.program.goal,1);  %first vial is blank
                psendPacket(handles,command);
            else
                command = sprintf('OLF,%d,%d',0,0);  %first vial is blank
                psendPacket(handles,command)
            end
            
            
            set( handles.user.program.UI.rewDeliverBut,'string',sprintf('reward goal (%d)',loc));
            %initialise teh trial structure element for this trial
            handles.user.program.trial(handles.user.program.trialNum).outcome =[];
        else
            switch events{1}
                case 'IRB'
                    %photobeam was broken.
                    %check which device
                    
                    loc = str2num(events{2});
                   
                    if loc ==  handles.user.program.goal && str2num(events{3})==1 
                        disp('arrived at goal!')
                        
                        if isempty(handles.user.program.trial(handles.user.program.trialNum).outcome)
                            handles.user.program.trial(handles.user.program.trialNum).outcome = 'correct';
                        end
                        
                        %go to the reward state
                        handles = moveto(handles,'reward');
                        
                    elseif loc ~=  handles.user.program.goal && str2num(events{3})==1
                        %he went to a different place 
                        disp('wrong location')
                        handles.user.program.trial(handles.user.program.trialNum).outcome = 'error';
                        
                    else
                        %leaving the goal
                    end
            end
        end
        
    case 'reward'
        if entering
            log2file(handles);
            %start the reward delivary
            
            %read the number of rewards the animal gets
            switch handles.user.program.trial(handles.user.program.trialNum).outcome
                case 'correct'
                    numReward =  str2num(cell2mat(get(handles.user.program.UI.rewShotNumEdit,'string')));
                case 'error'
                    numReward =  str2num(cell2mat(get(handles.user.program.UI.rewErrorShotNumEdit,'string')));
            end     
            giveReward(handles,numReward)
            
        else
            switch events{1}
                case 'IRB'
                    %if it is an exiting IR beam and it is from the current
                    %goal
                    if str2num(events{3}) == 0  && str2num(events{2}) == handles.user.program.goal
                        
                        %start the debounce timer
                        handles.user.program.timers(2).timerfcn = @(~,~)pdispatch('IRBBounce',guidata(handles.figure1));
                        handles.user.program.timers(2).startDelay = str2num(cell2mat(get(handles.user.program.UI.bounceNumEdit,'string')));
                        
                        start(handles.user.program.timers(2));
                        
                    %he is coming back to the same goal before the debounce
                    %has returned
                    elseif str2num(events{3}) == 1  && str2num(events{2}) == handles.user.program.goal
                        %stop the debounce timer
                        stop(handles.user.program.timers(2));

                     end
                        
                 case  'IRBBounce'      
                        %stop the rewards
                        disp('debounce timer arrived')
                        stopReward(handles)

                        %advance the trial counter
                        handles.user.program.trialNum = handles.user.program.trialNum +1;
                        %advance to the next goal
                        handles.user.program.goal = handles.user.program.nextGoalFun(handles.user.program.trialNum,handles.user.program.goal);
                        
                        %go to the wait state
                        handles = moveto(handles,'waitRat');
                    
            end
        end
        
    case 'finish'
        %we only enter here once
        disp('finishing task')
        
        %now we can clean up and make sure that data is correctly saved
        
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
 
 
 %%%%%%%%%%HELPER%%%%%%%%%%%%%
 function newgoal = randNextTrial(trialNum,goal)
 
 possGoal = 1:6;
 possGoal(possGoal == goal) = [];
 newgoal = possGoal(randi(5));
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
 
 function [] = stopReward(handles)
 guidata(handles.figure1,handles);
 controllerGUI('rewEvt_stop_Callback',handles.figure1,0,handles);
 
 end
 
 %%%%%%%%%%%%%%%%%%%%%%%%HOUSEKEEPING%%%%%%%%%%%%%%%%%
 function []= log2file(handles)
 state = handles.user.program.state;
    i = handles.user.program.trialNum;
 
 fprintf(handles.user.serial.user.dlogFid,'MS %s,%s,trial%i,%.10f\n',state,mfilename,i,now);
 end



