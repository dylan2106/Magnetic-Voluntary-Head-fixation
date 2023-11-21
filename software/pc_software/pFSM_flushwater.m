function[handles] = pFSM_flushwater(event,handles)

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
    %%
    case 'setup'
        if entering
            disp('setting initial parameters ')
            %here is the setup code
            
            %clear any previous program data
            handles.user.program = [];

            %assign the variables for the program
            handles.user.program.state  = 'setup';     %current state;
              
            handles.user.program.loc = [];
            set(handles.pushbuttonStartProg,'enable','on');
            
        else
            %we are responding to an event
            switch events{1}
               
                case 'TASKSTART'
                        %go to the reward state
                        handles = moveto(handles,'wait');  
            end            
        end
        
    %%    
    case 'wait'
        if entering

        else
            switch events{1}
                case 'IRB'
                    if str2num(events{3}) == 1 %entering
                        %photobeam was broken.
                        %check which device
                        loc = str2num(events{2});
                        
                        handles.user.program.loc = loc;
                        
                        %open the reward valve at this location
                        packet = sprintf('REW,%d,%d',loc,1000*60);
                        psendPacket(handles,packet)

                        handles = moveto(handles,'reward');
                    end   
            end
        end
   %%     
    case 'reward'
        if entering
   
        else
            switch events{1}
                case 'IRB' 
                    if str2num(events{3}) == 0  && str2num(events{2}) == handles.user.program.loc 
                        packet = sprintf('REW,%d,%d',handles.user.program.loc,0);
                        psendPacket(handles,packet)
                        handles = moveto(handles,'wait');
                    end
            end
            
        end
    %%    
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
 
%  %%%%%%%%%%%%%%%%%%%%%%%%HOUSEKEEPING%%%%%%%%%%%%%%%%%
%  function []= log2file(handles)
%  state = handles.user.program.state;
%  i = handles.user.program.trial;
%  fprintf(handles.user.serial.user.dlogFid,'MS %s,%s,trial%i,%.10f\n',state,mfilename,i,now);
%  end



