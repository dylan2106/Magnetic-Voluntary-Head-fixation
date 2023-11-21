function [ handles ] = pdispatch(event,handles)

if ~ischar(event)
   event
   error('event is not formatted correctly')
end



%write to file
fprintf(handles.user.serial.user.dlogFid,'pdispatch    ,%s,%.10f\n',event,now);
% 

%the follwoign block of code has been moved until after hte GUI display
%update code. this is because sometimes a FSM Calls a state read (IRQ) on
%an event that has just changed, so it would have not had the time to
%update yet.

% %all events come through here
% %check to see if there is a FSM program running at the moment
% if ~isempty(handles.user.currProg)
%     %if there is let it know about the event that occured
%     handles = handles.user.currProg(event,handles);
% 
% end

events = strsplit(event,',');
    
switch events{1}
    
    case 'CON'
     %recevied a confirmation packet from the micro
      switch events{2}
          case 'OLF'
            %update the OLfactory panel on the gui
            odourRadios = get(handles.uipanel_odor,'children');
            set(odourRadios,'backgroundcolor',[0.914 0.914 0.914]);
            currentOdour = cell2mat(get(odourRadios,'userdata')) == str2num(events{4});
            set(odourRadios(currentOdour),'backgroundcolor',[1 0 0]);
            set(handles.uipanel_odor,'selectedObject',odourRadios(currentOdour));
            
            locationRadios = get(handles.uipanel_odor_location,'children');
            set(locationRadios,'backgroundcolor',[0.914 0.914 0.914]);
            currentLocation = cell2mat(get(locationRadios,'userdata')) == str2num(events{3});
            set(locationRadios(currentLocation),'backgroundcolor',[1 0 0]);
            set(handles.uipanel_odor_location,'selectedObject',locationRadios(currentLocation));

          case 'GPO'
              GPIOoutputIndicators = get(handles.uipanel_GPIOoutput,'children');
              ind = cellfun(@(x)(sscanf(x,'%d')),get(GPIOoutputIndicators,'string'),'uni',1) == str2num(events{3});
              
              if str2num(events{4}) == 0
                  color= [1 1 1];  
              elseif str2num(events{4}) == 1
                  color= [1 0 0];
              elseif str2num(events{4}) == 2
                  color= [0.9 0.9 0.9];  %cofigured in the hardware as an input
              end
              set(GPIOoutputIndicators(ind),'backGroundColor',color);
              
          case 'LED';
          case 'REW';
            
      end
    case 'IRB'
        %received an IR beam packet 
        %update the gui display
        IRIndicators = get(handles.uipanel_IR,'children');
        
        ind = cellfun(@(x)(sscanf(x,'%*s%d')),get(IRIndicators,'string'),'uni',1) == str2num(events{2});
        
        if str2num(events{3}) == 0
            color= [1 1 1];
        elseif str2num(events{3}) == 1
            color= [1 0 0];
        end
        set(IRIndicators(ind),'backGroundColor',color);

    case 'GPIO'
        GPIOIndicators = get(handles.uipanel_GPIO,'children');      
        ind = cellfun(@(x)(sscanf(x,'%d')),get(GPIOIndicators,'string'),'uni',1) == str2num(events{2});
       
        if str2num(events{3}) == 0
            color= [1 1 1];
        elseif str2num(events{3}) == 1
            color= [1 0 0];
        elseif str2num(events{3}) == 2
            color= [0.9 0.9 0.9];  %cofigured in the hardware as an output
        end
        set(GPIOIndicators(ind),'backGroundColor',color);
        
    case 'IRQ'
        % query  an IR state for a prescribed location
        IRIndicators = get(handles.uipanel_IR,'children');
        ind = cellfun(@(x)(sscanf(x,'%*s%d')),get(IRIndicators,'string'),'uni',1) == str2num(events{2});
        
        color = get(IRIndicators(ind),'backGroundColor');
        if all(color == [1 1 1])
            state = 0;
        elseif all(color == [1 0 0])
            state = 1;
        end
        %send off a state event for that location
        newEvent = ['IRS,' events{2} ',' num2str(state)];
        handles  = pdispatch(newEvent,handles);

    case 'GPQ'
        % query  an IR state for a prescribed location
        GPIndicators = get(handles.uipanel_GPIO,'children');
        ind = cellfun(@(x)(sscanf(x,'%d')),get(GPIndicators,'string'),'uni',1) == str2num(events{2});
        color = get(GPIndicators(ind),'backGroundColor');
        if all(color == [1 1 1])
            state = 0;
        elseif all(color == [1 0 0])
            state = 1;
        else
            state = 2; %configured as an output
        end
        %send off a state event for that location
        newEvent = ['GPS,' events{2} ',' num2str(state)];
        handles  = pdispatch(newEvent,handles);
end

%all events come through here
%check to see if there is a FSM program running at the moment
if ~isempty(handles.user.currProg)
    %if there is let it know about the event that occured
   
    handles = handles.user.currProg(event,handles);

end

guidata(handles.figure1, handles);
end
% end
%     
%     %photobeam breaks always update the GUI
%     case hex2dec('84')
%         if ~isempty(handles.user.panels)
%         %find which unit gave this code
%         sendID = event(8);
%         panelNo = find(sendID == [handles.user.panels.address]);
%         
%         state = sum(bitget(uint8(event(2)),1:2));  %0 none, 1 either , 2 both
%         if state==0
%             color = [1 1 1];
%         elseif state == 1 || state == 2
%             color = [1 0 0];
%         else
%             color = [0 1 0];
%             warning('unknown photo beam message')
%         end
%         
%         
%         %panelNo
%         set(handles.(sprintf('end%iPho',panelNo)),'BackGroundColor',color)
%         handles.user.panels(panelNo).phoState =  state;
%         
%         
%         
%         end
%         
%        
%         %special case for the start box
%         try
% %             if sendID == 7
% %             state = sum(bitget(uint8(event(2)),1:2));  %0 none, 1 either , 2 both
% %             state = state~=0 +0;
% %             dsendPacket(handles,[hex2dec('01') state 0 0 0 0 7 0])
% % 
% %             
% %             
% %             end
%         catch
%             warning('cannot do this block')
%         end
%         
%     %led or solnoid confirmations always update the GUI
%     case arrayfun(@(x){x},hex2dec({'80','81','82','83'})')
%         %find which unit gave this code
%         sendID = event(8);
%         panelNo = find(sendID == [handles.user.panels.address]);
%         
%         %choose whether sol or led
%         switch event(1) 
%             case arrayfun(@(x){x},hex2dec({'80','81'})')
%                 buttonStr = 'Led';
%             case arrayfun(@(x){x},hex2dec({'82','83'})')
%                 buttonStr = 'Sol';
%         end
%         
%         if event(2)==0
%             color = [0.9412 0.9412 0.9412];
%         elseif event(2)==1;
%             color = [1 0 0];
%         end
%         try
%             set(handles.(sprintf('end%i%sPush',panelNo,buttonStr)),'BackGroundColor',color)
%         catch
%             warning('there is an extra panelAdress here, you need to work out where it came from')
%             set(handles.(sprintf('end%i%sPush',panelNo(1),buttonStr)),'BackGroundColor',color)
%         end
%     %error codes are handled here    
%     case hex2dec('A0')
%         %error codes
%          switch event(2)
%             case 1 %setup complete and serial communication established with COORD
%                 
%                 set(handles.coordConnectPush,'string','disconnect')
%                 set(handles.coordStatus,'string','ONLINE',...
%                     'foregroundColor',[0 1 0]);
%                 
%                 
%                 %now make teh required controls in the coordinator panel active
%                 children = get(handles.coordPanel,'children');
%                 
%                 %exclude here
%                 
%                 disableOnSerialClose = strcmp(get(children,'enable'),'off');
%                 
%                 set(children(disableOnSerialClose),'enable','on');
%                 
%                 
%                 
%                 handles.user.serialCloseDisable = children(disableOnSerialClose);
%                 
%                 %add the exceptions that shoudl stay diaabled
%                 set(handles.saveLogCheckbox,'enable','off')
%                 set(handles.pushbuttonChangeDir,'enable','off')
% 
%                 
%          end
%          
%     case hex2dec('05')
%         %need to send a battery request to end devices
%         dsendPacket(handles,event);
%         
%     case hex2dec('85')
%         %have received a battery status from a device
%         %disp('got bat');
%         
%         %these are the values which the volatege divider gives.. ask dylan 
%         ADC = (event(2) + ((2^8)*event(3)))/(2^10);
%         %vBat = (ADC*5)/(10/(10+20));
%         
%         
%         %r1 = 4700;
%         r1 = 10000; 
%         r2 = 10000;
%         vBat = ((ADC*3.3)*(r1+r2))/r2;
% 
%         
%         %find the correct address
%         if ~isempty(handles.user.panels)
%             ind = find(event(8) == [handles.user.panels.address]);
%             set(handles.(sprintf('end%iBat',ind)),'string', sprintf('%.1fV',vBat),'enable','on')
%       
% %         %RESET THE BATTERY TIME OUT CODE HERE
%             stop(handles.user.panels(ind).batTimerTimeout);
%             start(handles.user.panels(ind).batTimerTimeout);
%          
% %             stop(handles.user.panels(ind).batTimer);
% %             start(handles.user.panels(ind).batTimer);
% %             
%             handles.user.panels(ind).batRecord = cat(1,handles.user.panels(ind).batRecord,[now vBat]);
% 
%             %if lost make sure the panel is online again'
%              curObj = handles.(sprintf('end%iStatus',ind));
%              set( curObj,'string','ONLINE',...
%                     'foregroundColor',[0 1 0]);
%             
%            else
%             %ignore
%         end
% %         
%     case hex2dec('E3')
%         %have have recieved a battery timeout timer code. 
%        % warning('device not responding')
%         
%         %find the panel numbder
%         ind = find(event(7) == [handles.user.panels.address]);
% 
%         %mark the panel as lost
%         curObj = handles.(sprintf('end%iStatus',ind));
%         set( curObj,'string','CONN ERROR',...
%                     'foregroundColor',[1 0.5 0]);
%                 
%          stop(handles.user.panels(ind).batTimerTimeout);
%          start(handles.user.panels(ind).batTimerTimeout);
% %          
% %          stop(handles.user.panels(ind).batTimer);
% %          start(handles.user.panels(ind).batTimer);
% %         
%     case hex2dec('E4')
%        %start a behavioural trial
%        %send a ping to the first end device
%        %this is to make sure there is some log in teh serial port and
%        %parramlle out put ports
%        addr = handles.user.panels(1).address;
%        dsendPacket(handles,[07 event(1) 00 00 00 00 addr 00]);
%        %sound([0 0.2 0.5 0])
%        
%     case hex2dec('E5')
%        %reset a behavioural trial
%        %send a ping to the first end device
%        %this is to make sure there is some log in teh serial port and
%        %parramlle out put ports
%        addr = handles.user.panels(1).address;
%        dsendPacket(handles,[07 event(1) 00 00 00 00 addr 00]);
%        %sound([0 0.2 0.5 0])
%        
%     case hex2dec('E6')
%        %cancel a behavioural trial
%        %send a ping to the first end device
%        %this is to make sure there is some log in teh serial port and
%        %parramlle out put ports
%        addr = handles.user.panels(1).address;
%        dsendPacket(handles,[07 event(1) 00 00 00 00 addr 00]);
%        %sound([0 0.2 0.5 0])
%        
%     case hex2dec('E7')
%         %barrier up on a behavioural trial
%         addr = handles.user.panels(1).address;
%         dsendPacket(handles,[07 event(1) 00 00 00 00 addr 00]);
%         
%      case hex2dec('E8')
%         %restart up on a behavioural trial
%         addr = handles.user.panels(1).address;
%         dsendPacket(handles,[07 event(1) 00 00 00 00 addr 00]);
% 
%         
% end
% 
% guidata(handles.figure1, handles);
%    
% end

