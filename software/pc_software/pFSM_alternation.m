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
        if entering
            disp('setting initial parameters for alternation')
            %here is the setup code
            
            %clear any previous program data
            handles.user.program = [];

            %assign the variables for the program
            handles.user.program.state  = 'setup';     %current state;
              
            handles.user.program.goal = 3;
            handles.user.program.nextGoal = 4;
            handles.user.program.trial = 1;
            
            set(handles.pushbuttonStartProg,'enable','on');
            
            log2file(handles);
        else
            %we are responding to an event
            switch events{1}
               
                case 'TASKSTART'
                        %go to the reward state
                        handles = moveto(handles,'wait');  
            end            
        end
        
        
    case 'wait'
        if entering
            log2file(handles);
            
            %start the goal location flashing
            loc = handles.user.program.goal;
            interval  = str2num(get(handles.LED_interval,'string'));

            psendPacket( handles,sprintf('LED,%d,%d,-1', loc ,interval));
        else
            switch events{1}
                case 'IRB'
                    %photobeam was broken.
                    %check which device
                    
                    loc = str2num(events{2});
                   
                    if loc ==  handles.user.program.goal && str2num(events{3})==1 
                        disp('arrived at goal!')
                        
                        %go to the reward state
                        handles = moveto(handles,'reward');
                        
                    elseif loc ~=  handles.user.program.goal && str2num(events{3})==1
                        %he went to a different place 
                        disp('wrong location')  
                    else
                        %leaving the goal
                    end
            end
        end
        
    case 'reward'
        if entering
            log2file(handles);
            %start the reward delivary
            
            %get the rew button handle so we can use its code to
            %execute the reward delivary.
            allTags = fields(handles);
            ind = ~cellfun(@isempty,regexp(allTags,sprintf('REW_but_%d',handles.user.program.goal)));
            
            hObject = handles.(allTags{ind});
            
            controllerGUI('general_REW_callback',hObject,[],guidata(hObject))

            %advance to the next goal
            prevGoal = handles.user.program.goal;
            handles.user.program.goal = handles.user.program.nextGoal;
            handles.user.program.nextGoal(1) = [];
            handles.user.program.nextGoal = [handles.user.program.nextGoal prevGoal]; %add to the end of the list
            
            %advance the trial counter
            handles.user.program.trial = handles.user.program.trial +1;
            
           %go to the wait state
           handles = moveto(handles,'wait');

        else
            
        end
        
    case 'finish'
        %we only enter here once
        disp('finishing task')
        
        %now we can clean up and make sure that data is correctly saved
        
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
 
 %%%%%%%%%%%%%%%%%%%%%%%%HOUSEKEEPING%%%%%%%%%%%%%%%%%
 function []= log2file(handles)
 state = handles.user.program.state;
 i = handles.user.program.trial;
 fprintf(handles.user.serial.user.dlogFid,'MS %s,%s,trial%i,%.10f\n',state,mfilename,i,now);
 end



