function varargout = controllerGUI(varargin)
% CONTROLLERGUI MATLAB code for controllerGUI.fig
%      CONTROLLERGUI, by itself, creates a new CONTROLLERGUI or raises the existing
%      singleton*.
%
%      H = CONTROLLERGUI returns the handle to a new CONTROLLERGUI or the handle to
%      the existing singleton*.
%
%      CONTROLLERGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONTROLLERGUI.M with the given input arguments.
%
%      CONTROLLERGUI('Property','Value',...) creates a new CONTROLLERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before controllerGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to controllerGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help controllerGUI

% Last Modified by GUIDE v2.5 07-May-2019 16:17:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @controllerGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @controllerGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before controllerGUI is made visible.
function controllerGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to controllerGUI (see VARARGIN)

% Choose default command line output for controllerGUI
handles.output = hObject;

%logDir = [cd '\logFiles'];
home = [getenv('HOMEDRIVE') getenv('HOMEPATH')];
logDir = [home '\Dropbox\experimental_records\behavioural_data\logs'];
if isdir(logDir)
    handles.user.logDir = logDir;
else
    mkdir(logDir);
    handles.user.logDir = logDir;
end

set(handles.textLogDir,'string',logDir,...
    'fontsize',6);

set(handles.figure1,'KeyPressFcn',@(hObject,eventdata)controllerGUI('keypressCallback',hObject,eventdata,guidata(hObject)))
%set(handles.figure1,'WindowKeyPressFcn',@(x,y)keytest(x,y))

handles = uipanel_REW_create(hObject, eventdata, handles);
handles = uipanel_LED_create(hObject, eventdata, handles);
handles.user.currProg = [];

%create the reward evet timers onces
handles.user.rewEvt.timerS = timer;
handles.user.rewEvt.timerR = timer;
handles.user.rewEvt.timerStop = timer;
handles.user.rewEvt.stopToneOveride = false;
handles.user.rewEvt.s2rDelay = str2num(get(handles.rewEvt_S2R_delay,'string'));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes controllerGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = controllerGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in coordConnectPush.
function coordConnectPush_Callback(hObject, eventdata, handles)
switch get(hObject,'string')
    case 'connect'
        
        %get the com port we want
        comNum = str2num(get(handles.comNumber,'string'));
        
        rec = get(handles.saveLogCheckbox,'value') == 1;
        obj = initialiseSerialCoord(comNum,rec,handles.user.logDir,handles);
        obj.user.GUIhandle = gcf;
        handles.user.serial = obj;
        set(hObject,'string','disconnect');
        
        set(handles.textlogFile,'string',handles.user.serial.user.logFile,...
                                'fontsize',6);
        
        set(handles.saveLogCheckbox,'enable','off')
        set(handles.pushbuttonChangeDir,'enable','off');
        
        set(handles.hardware_panel,'visible','on')

        drawnow
        
%         %start a serial flush timer
%         eval(['flushCallBack = @(x,y)' mfilename '(''flushSerial_Callback'',0,0,guidata(handles.figure1))'])
%         handles.flushTimer     = timer('TimerFcn',flushCallBack,...
%                                                 'StartDelay',60,...
%                                                 'period',120,...
%                                                 'executionmode','fixedrate');
%         start(handles.flushTimer);
    if strcmp( get(obj,'status'),'closed')
         set(handles.coordStatus,'string','EMULATION',...
        'foregroundColor',[1 0.6 0]);
    else
        set(handles.coordStatus,'string','ONLINE',...
        'foregroundColor',[0 1 0]);
    end
    
    case {'disconnect','cancel'}
        %if there is a FSM program running
        %to do here invoke the callback for that button and close the program
%         pushbuttonStartProg_Callback(hObject, eventdata, handles)
        
        %close the log File
        fclose(handles.user.serial.user.dlogFid);
        
        %close the actual serial port
        fclose(handles.user.serial)
         
        set(handles.hardware_panel,'visible','off')

        
        set(handles.coordStatus,'string','OFFLINE',...
            'foregroundColor',[1 0 0]);

%         %make certain objects disabled       
%         set(handles.user.serialCloseDisable,'enable','off')
         set(hObject,'string','connect');
        
%         %go through the end device panels and disable the controls needed
%         disableEndDevicePanels(hObject, eventdata, handles);
        handles = guidata(hObject);
        
        set(handles.saveLogCheckbox,'enable','on')
        set(handles.pushbuttonChangeDir,'enable','on');

         set(handles.textlogFile,'string',['prevfile:' handles.user.serial.user.logFile],...
                                'fontsize',6);
%          stop(handles.flushTimer);       
end

guidata(hObject, handles);

function serialBase_Callback(hObject, eventdata, handles)
assignin('base', 'serialObj', handles.user.serial)

function comNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushbutton4_Callback(hObject, eventdata, handles)
assignin('base', 'handles', handles)

function pushbuttonChangeDir_Callback(hObject, eventdata, handles)
if isfield(handles.user,'serial')
    
end

dirSel = uigetdir;
if dirSel ~=0
    
    handles.user.logDir = dirSel;
    set(handles.textLogDir,'string', handles.user.logDir,...
        'fontsize',6);
    guidata(hObject, handles);
end

function flushSerial_Callback(hObject, eventdata, handles)
% try
%     sObj = handles.user.serial;
%     sObj.BytesAvailable
%     fread(sObj , sObj.BytesAvailable)
% catch
%     disp('serial buffer empty');
% end

function reenableBytes_Callback(hObject, eventdata, handles)
%check to see if the bytes available funciton is disabled
%do not kno how to do that
if 1
    fclose(handles.user.serial)
    fopen(handles.user.serial)
else
    
end

function close_all_serial_Callback(hObject, eventdata, handles)
fclose(instrfind)

function obj = initialiseSerialCoord(comNumber,rec,logDir,handles)

if nargin <2
    rec = true;
end
obj = serial(sprintf('com%i',comNumber));
obj.BaudRate = 115200;
set(obj,'bytesAvailableFcn',@(obj,event)pprocessInput(obj,event,guidata(handles.figure1)))
obj.RecordDetail = 'verbose';
%obj.OutputEmptyFcn = @(obj,event)disp(event);

timeStamp = sprintf('%02i-',round(clock));
logFile = ['dserialLog_' timeStamp(1:end-1) '.txt'];

logFileNative = ['dserialLogNative_' timeStamp(1:end-1) '.txt'];

obj.RecordName = [handles.user.logDir '\' logFileNative];

try
    fopen(obj)
    %record(obj)
catch
    warning('communication with serial port not established, running in emulation mode')
end

%always record a log file!
fid = fopen([logDir '\' logFile],'w');
obj.user.dlogFid = fid;
obj.user.logFile = logFile;

%%%
function keypressCallback(hObject, eventdata, handles)
disp('key pusshed')
eventdata;
%
switch(eventdata.Character)
    case {'1','2','3','4','5','6'}
        n = str2num(eventdata.Character);
        general_RewEvt_callback(handles.(sprintf('rewEvt%i_1x',n)),eventdata,handles)

end


%%%%%%%%%%%%%%%%%%%%% program panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pushbuttonLoadProg_Callback(hObject, eventdata, handles)

file = uigetfile;

%strip off the extension
file2 = regexp(file,'pFSM[^\.]+(?=(\.m))','match');

if isempty(file2)
    error('file not reconised')
end

set(handles.programString,'string',file2);

%set file as a functio handle for the
eval(sprintf('handles.user.currProg = @(x,y)%s(x,y);',file2{1}))

%initiate the starting state of the program
handles = handles.user.currProg([],handles);

%make  sure the start button is in the correct state
set(handles.pushbuttonStartProg,'string','start');

%and update the handles structure
guidata(hObject, handles);

function pushbuttonStartProg_Callback(hObject, eventdata, handles)


switch get(hObject,'string')
    case 'start'  
    
        handles = pdispatch('TASKSTART',handles);    
        set(hObject,'string','stop')
        guidata(hObject, handles);
              
    case 'stop'
        button = questdlg('save and quit behavioural task?','','save and quit','just quit','cancel','cancel');
        
        if strcmp(button,'save and quit') 
            Q = datevec(now);
            dirOrig = cd;
            cd(handles.user.logDir);
            if ~isempty(handles.user.currProg)
                currProg = [cell2mat(regexp(func2str(handles.user.currProg),'(?<=\))\w+(?=\()','match')) '_'];
            else
                currProg = '';
            end
            [file, path] = uiputfile(['\*.mat'],[],sprintf('AMN_%s%i%02i%02i_%02i%02i',currProg,Q(1),Q(2),Q(3),Q(4),Q(5)));
            cd(dirOrig);
            if file ~= 0
                trial = handles.user.program.trial;
                save([path file],'trial');
                
                button2 = questdlg('continue or quit?','','continue','quit','quit');
                if strcmp(button2,'quit')
                    button  = 'just quit';
                elseif strcmp(button2,'continue')
                    button  = 'cancel';
                end
            else
                button  = 'cancel';
            end
        end
        
        if strcmp(button,'just quit')
         
            %change the program state
            handles.user.program.state = 'finish';
            
            %call the program to finish up
            if ~isempty(handles.user.currProg);handles = handles.user.currProg([],handles);
            else
                % we acidently deleted the function...
                warning('you deleted the funciton handle before calling the finishing state')  
            end
            %change the string
            set(hObject,'string','reload')
            guidata(hObject, handles);
            
        elseif strcmp(button,'cancel')
            
            %do nothing
        end
        
    case 'reload'
        %initiate the program so that it can go through setup
        
        file = get(handles.programString,'string');
        
        %set file as a functio handle for the
        eval(sprintf('handles.user.currProg = @(x,y)%s(x,y);',file{1}))
        
        handles = handles.user.currProg([],handles);
        
        %if the program structure is not empty then we have loaded and
        %set up a program
        if ~isempty(handles.user.program)
            %change the string
            set(hObject,'string','start')
            guidata(hObject, handles);
        end
        %if not then do not change the string of the button
               
end

%%%%%%%%%%%%%%%%%%%%% olfactometer panel%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function olfactory_send_command_but_Callback(hObject, eventdata, handles)
%read which radio button is selected in the olfactory panel

odourChannel = get(get(handles.uipanel_odor,'selectedObject'),'userData');
odourLocation = get(get(handles.uipanel_odor_location,'selectedObject'),'userData');

command = sprintf('OLF,%d,%d',odourLocation,odourChannel);

psendPacket(handles,command);

%%%%%%%%%%%%%%%%%%%%%% reward button panel %%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles = uipanel_REW_create(hObject, eventdata, handles)
%apply a callback to all the buttons in this panel

allElements = get(handles.uipanel_REW,'children');
buttons = allElements(strcmp(get(allElements,'style') ,'pushbutton'));
for i = 1:numel(buttons)
       set(buttons(i),'callBack',...
        @(hObject,eventdata)controllerGUI('general_REW_callback',buttons(i),eventdata,guidata(hObject)))   
end
 
function general_REW_callback(hObject, eventdata, handles)
location = sscanf(get(hObject,'string'),'%*s%d');
duration = str2num(get(handles.REW_duration,'string'));
packet = sprintf('REW,%d,%d',location,duration);
psendPacket(handles,packet)

function REW_duration_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function REW_duration_Callback(hObject, eventdata, handles)

%%%%%%%%%%%%%%%%%%%%%% reward events button panel %%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function general_RewEvt_callback(hObject,eventdata,handles,location,numRew,rewDelayFun,firstRewDelay)
%This function is called at teh start of a reward event and sets up the parammeter for a reward event
%as well as starting it
%
%it is called by the buttons on the rewevt pannel, 
%but can also be invoked by other programs eg FSM to give standard rewards
%
%the location and the number of rewards are inout arguemts if they need to
%be spesified

if nargin < 4 
    %get the location based on a button press
    location = sscanf(get(hObject,'tag'),'rewEvt%d_%*s'); 
    %also get whether they want a single shot, or multiple shots (depends
    %on which button was presses
else
    %the location was passed directly as an input argument
end

handles.user.rewEvt.stopToneOveride = false;
if nargin < 5 || isempty(numRew)
    %different number of rewards depending on which button is pressed
    if ~isempty(strfind(get(hObject,'tag'),'Nx'))
        %numRew = str2num(get(handles.num_rewEvt,'string'));
        numRewInput = get(handles.num_rewEvt,'string') ;
        eval(['numRew = ' numRewInput ';']);

    elseif ~isempty(strfind(get(hObject,'tag'),'1x'))
        numRew = 1;
        %diable the stop tone
        handles.user.rewEvt.stopToneOveride = true;
    else
        %if no button was pressed but no number of rewards was passed, use
        %the num rew evt
        %numRew = str2num(get(handles.num_rewEvt,'string'));
        numRewInput = get(handles.num_rewEvt,'string') ;
        eval(['numRew = ' numRewInput ';']);

    end
else
    %the number of rewards was passed directly
end

s2rDelay = str2num(get(handles.rewEvt_S2R_delay,'string'));
handles.user.rewEvt.s2rDelay = s2rDelay;

if nargin < 6 || isempty(rewDelayFun)
    %the rewDelay has to be handled specialy since it could be expression
    %I couldnt work out how to do it with function handles eg str2func
    %since  str2func('exprnd(2)') doesn't work it can;t handle arguemnts.. :(
    rewDelayInput = get(handles.rewEvt_delay,'string');
    rewDelay = nan(numRew,1);
    for i = 1:numRew
        eval(['x = ' rewDelayInput ';']);
        rewDelay(i) = x;
    end
    if get(handles.first_rew_zero_delay,'value')
      rewDelay(1) = 0;  
    end
else
    %function handle was passed
    rewDelay = nan(numRew,1);
    for i = 1:numRew
        rewDelay(i) = rewDelayFun();
    end
    %still keep the first being zero convnetion
    if get(handles.first_rew_zero_delay,'value')
      rewDelay(1) = 0;  
    end
end

%can spesify the explicit first delay with this argument
%passed in seconds
if nargin < 7 
    firstRewDelay = [];
else
    rewDelay(1) = firstRewDelay*1000;
end


%handles.user.rewEvt.rewDelay = rewDelay;

%|<----rewDelay(1)---->S<--s2r--->R
%                      |<--rewDelay(2)-->S<--s2r--->R
%                                        |<-------rewDelay(3)------->S<--s2r--->R
%                                                                    |<----rewDelay(4)--->S<--s2r--->R

%handles.user.rewEvt.numRew = numRew;
% handles.user.rewEvt.currRew= numRew;    %cannot store teh current rew in
% the handles, since it is passed around in other places, too  hard to keep
% updated instead store it later in hte timer obj
currRew = 1;
%handles.user.rewEvt.location = location;

%check to see if timers exist and or are running
if isfield(handles.user.rewEvt, 'timerS')
   if ~isempty(timerfind(handles.user.rewEvt.timerS))
       stop(handles.user.rewEvt.timerS);
   end
end
if isfield(handles.user.rewEvt, 'timerR')
   if ~isempty(timerfind(handles.user.rewEvt.timerR))
       stop(handles.user.rewEvt.timerR);
   end
end


set(handles.user.rewEvt.timerS,'startdelay',round(rewDelay(currRew))./1000,...
                                   'TimerFcn',@(x,eventdata)controllerGUI('RewEvtS_callback',x,eventdata,guidata(handles.figure1)),...
                                   'BusyMode','error');
data.currRew = currRew;
data.location = location;
data.rewDelay = rewDelay;

set(handles.user.rewEvt.timerR ,   'startdelay',round((rewDelay(currRew)+s2rDelay))./1000,...
                                   'TimerFcn',@(x,eventdata)controllerGUI('RewEvtR_callback',x,eventdata,guidata(handles.figure1)),...
                                   'stopfcn',@(x,eventdata)controllerGUI('RewEvtR_stop_callback',x,eventdata,guidata(handles.figure1)),...
                                   'BusyMode','error',...
                                    'userdata',data);
guidata(hObject, handles);

%start timers
start(handles.user.rewEvt.timerS);
start(handles.user.rewEvt.timerR);


function RewEvtS_callback(hObject,eventdata,handles)
%this function when the pre rew stimulus is required

%if requested, produce pre-rew simulus
%disp('pre rew stim!!!')

data = get(handles.user.rewEvt.timerR,'userdata');

location = data.location;
if get(handles.toneAt1,'value') == 1
    toneLocation = 1;
else
    toneLocation = data.location;
end


tone = str2num(get(handles.rewEvt_tone,'string'));
if tone>0
    packet = sprintf('TON,%d,%d,1,0',tone,toneLocation);
    psendPacket(handles,packet)
end

led = str2num(get(handles.rewEvt_led,'string'));
if led>0
    packet = sprintf('LED,%d,%d,1',location,led);
    psendPacket(handles,packet)
end

function RewEvtR_callback(hObject,eventdata,handles)
%this function is called at the end of each reward event cycle
%disp('deliver Reward')

%always deliver a reward
duration = str2num(get(handles.REW_duration,'string'));

data = get(handles.user.rewEvt.timerR,'userdata');
location = data.location;

packet = sprintf('REW,%d,%d',location,duration);
psendPacket(handles,packet)


function RewEvtR_stop_callback(hObject,eventdata,handles)
%currRew =  handles.user.rewEvt.currRew;
handles = guidata(handles.figure1);
data = get(handles.user.rewEvt.timerR,'userdata');
data.currRew = data.currRew + 1;
currRew = data.currRew;

%finally check that the numRewRem   ain is not zero
if currRew == numel(data.rewDelay)+1
   % disp('stopped');
%    %delete the timers
%    delete(handles.user.rewEvt.timerS);
%    delete(handles.user.rewEvt.timerR);
   
   %if requested make the reward stop sound
   location = data.location;
   if get(handles.toneAt1,'value') == 1
       toneLocation = 1;
   else
       toneLocation = data.location;
   end
   tone = str2num(get(handles.rewEvt_end_tone,'string'));
    
   if ~isempty(tone) && tone>0 && ~handles.user.rewEvt.stopToneOveride
       packet = sprintf('TON,%d,%d,1,0',tone,toneLocation);
       psendPacket(handles,packet)
   end
   
   %have a dispatch message at the end of the rewEVT
   %it must be called from a separate timer, in case we want to restart a
   %rewEvt, and so it cannot occur within its own callback
   set(handles.user.rewEvt.timerStop,'timerfcn',@(~,~)pdispatch('REWEVTEND',guidata(handles.figure1)),'startdelay',0.005);
   start(handles.user.rewEvt.timerStop)

else
   %update the periods for the timers
   rewDelay = data.rewDelay;
   sDelay = round(rewDelay(currRew))./1000;
   set(handles.user.rewEvt.timerS,'startdelay',sDelay)
   rDelay = round(rewDelay(currRew)+handles.user.rewEvt.s2rDelay)./1000;
   set(handles.user.rewEvt.timerR,'startdelay',sDelay)
    
   set(handles.user.rewEvt.timerR,'userData',data)
   start(handles.user.rewEvt.timerS)
   start(handles.user.rewEvt.timerR)
   
end
guidata(handles.figure1, handles);
   
function rewEvt_stop_Callback(hObject, eventdata, handles)
if isfield(handles.user.rewEvt, 'timerR')
   if ~isempty(timerfind(handles.user.rewEvt.timerR))
       data = get(handles.user.rewEvt.timerR,'userdata');
       data.currRew = numel(data.rewDelay);
       set(handles.user.rewEvt.timerR,'userData',data)      
       stop(handles.user.rewEvt.timerS)
       stop(handles.user.rewEvt.timerR)

   end
end


   

%%%%%%%%%%%%%%%%%%%%%% LED button panel %%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles = uipanel_LED_create(hObject, eventdata, handles)
%apply a callback to all the buttons in this panel

allElements = get(handles.uipanel_LED,'children');
buttons = allElements(strcmp(get(allElements,'style') ,'pushbutton'));
for i = 1:numel(buttons)
       set(buttons(i),'callBack',...
        @(hObject,eventdata)controllerGUI('general_LED_callback',buttons(i),eventdata,guidata(hObject)))   
end
 
function general_LED_callback(hObject, eventdata, handles)
location = sscanf(get(hObject,'string'),'%*s%d');
duration = str2num(get(handles.LED_duration,'string'));
interval = str2num(get(handles.LED_interval,'string'));
count = floor((duration*1000) /(interval*2));
if mod(count,2) == 1
    count = count-1;
end
packet = sprintf('LED,%d,%d,%d',location,interval,count);
psendPacket(handles,packet)

function LED_interval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LED_interval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function LED_duration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LED_duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%%%%%%%%%%%%useless callbacks%%%%%
%can't be deleted though...
function comNumber_Callback(hObject, eventdata, handles)
function saveLogCheckbox_Callback(hObject, eventdata, handles)
function serialDumpCheckBox_Callback(hObject, eventdata, handles)
function LED_interval_Callback(hObject, eventdata, handles)
function LED_duration_Callback(hObject, eventdata, handles)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton51.
function pushbutton51_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton51 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton52.
function pushbutton52_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton52 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton53.
function pushbutton53_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton53 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton54.
function pushbutton54_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton54 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton55.
function pushbutton55_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton55 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton56.
function pushbutton56_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton57.
function pushbutton57_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton57 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton58.
function pushbutton58_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton58 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton59.
function pushbutton59_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton59 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton60.
function pushbutton60_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton60 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton61.
function pushbutton61_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton61 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton62.
function pushbutton62_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton62 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton63.
function pushbutton63_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton63 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton64.
function pushbutton64_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton64 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton65.
function pushbutton65_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton65 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton66.
function pushbutton66_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton66 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton67.
function pushbutton67_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton67 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton68.
function pushbutton68_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton68 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function rewEvt1_1x_Callback(hObject, eventdata, handles)
general_RewEvt_callback(hObject,eventdata,handles)

function rewEvt2_1x_Callback(hObject, eventdata, handles)
general_RewEvt_callback(hObject,eventdata,handles)

function rewEvt3_1x_Callback(hObject, eventdata, handles)
general_RewEvt_callback(hObject,eventdata,handles)

function rewEvt4_1x_Callback(hObject, eventdata, handles)
general_RewEvt_callback(hObject,eventdata,handles)

function rewEvt5_1x_Callback(hObject, eventdata, handles)
general_RewEvt_callback(hObject,eventdata,handles)

function rewEvt6_1x_Callback(hObject, eventdata, handles)
general_RewEvt_callback(hObject,eventdata,handles)

function rewEvt7_1x_Callback(hObject, eventdata, handles)
general_RewEvt_callback(hObject,eventdata,handles)

function rewEvt8_1x_Callback(hObject, eventdata, handles)
general_RewEvt_callback(hObject,eventdata,handles)


function rewEvt1_Nx_Callback(hObject, eventdata, handles)
general_RewEvt_callback(hObject,eventdata,handles)

function rewEvt2_Nx_Callback(hObject, eventdata, handles)
general_RewEvt_callback(hObject,eventdata,handles)

function rewEvt3_Nx_Callback(hObject, eventdata, handles)
general_RewEvt_callback(hObject,eventdata,handles)

function rewEvt4_Nx_Callback(hObject, eventdata, handles)
general_RewEvt_callback(hObject,eventdata,handles)

function rewEvt5_Nx_Callback(hObject, eventdata, handles)
general_RewEvt_callback(hObject,eventdata,handles)

function rewEvt6_Nx_Callback(hObject, eventdata, handles)
general_RewEvt_callback(hObject,eventdata,handles)

function rewEvt7_Nx_Callback(hObject, eventdata, handles)
general_RewEvt_callback(hObject,eventdata,handles)

function rewEvt8_Nx_Callback(hObject, eventdata, handles)
general_RewEvt_callback(hObject,eventdata,handles)

function rewEvt_delay_Callback(hObject, eventdata, handles)
% hObject    handle to rewEvt_delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rewEvt_delay as text
%        str2double(get(hObject,'String')) returns contents of rewEvt_delay as a double


% --- Executes during object creation, after setting all properties.
function rewEvt_delay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rewEvt_delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rewEvt_S2R_delay_Callback(hObject, eventdata, handles)
% hObject    handle to rewEvt_S2R_delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rewEvt_S2R_delay as text
%        str2double(get(hObject,'String')) returns contents of rewEvt_S2R_delay as a double


% --- Executes during object creation, after setting all properties.
function rewEvt_S2R_delay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rewEvt_S2R_delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rewEvt_tone_Callback(hObject, eventdata, handles)
% hObject    handle to rewEvt_tone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rewEvt_tone as text
%        str2double(get(hObject,'String')) returns contents of rewEvt_tone as a double


% --- Executes during object creation, after setting all properties.
function rewEvt_tone_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rewEvt_tone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rewEvt_led_Callback(hObject, eventdata, handles)
% hObject    handle to rewEvt_led (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rewEvt_led as text
%        str2double(get(hObject,'String')) returns contents of rewEvt_led as a double


% --- Executes during object creation, after setting all properties.
function rewEvt_led_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rewEvt_led (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit21_Callback(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit21 as text
%        str2double(get(hObject,'String')) returns contents of edit21 as a double


% --- Executes during object creation, after setting all properties.
function edit21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function num_rewEvt_Callback(hObject, eventdata, handles)
% hObject    handle to num_rewEvt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of num_rewEvt as text
%        str2double(get(hObject,'String')) returns contents of num_rewEvt as a double


% --- Executes during object creation, after setting all properties.
function num_rewEvt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_rewEvt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in first_rew_zero_delay.
function first_rew_zero_delay_Callback(hObject, eventdata, handles)
% hObject    handle to first_rew_zero_delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of first_rew_zero_delay





function rewEvt_end_tone_Callback(hObject, eventdata, handles)
% hObject    handle to rewEvt_end_tone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rewEvt_end_tone as text
%        str2double(get(hObject,'String')) returns contents of rewEvt_end_tone as a double


% --- Executes during object creation, after setting all properties.
function rewEvt_end_tone_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rewEvt_end_tone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in toneAt1.
function toneAt1_Callback(hObject, eventdata, handles)
% hObject    handle to toneAt1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of toneAt1



% --- Executes on button press in pushbutton_load_settings.
function pushbutton_load_settings_Callback(hObject, eventdata, handles)
disp('loading settings')

if ~isempty(handles.user.currProg)
    [file, pathname] = uigetfile(handles.user.logDir);
    
    currProgStr = cell2mat(regexp(func2str(handles.user.currProg),'pFSM[^(]+','match'));
    
   %check that the file is the ac 
   if ~isempty( regexp(file,[currProgStr '(?=_[0-9]+)']))
        prevData = load([pathname '\' file]);
      
        %extract the current variable names 
        dummyHandles = updateUIvalues(handles);
        curVars = fieldnames(dummyHandles.user.program.trial.uiValue);
        prevVars = fieldnames(prevData.trial(1).uiValue);
        if isequal(curVars,prevVars)
%             for i = 1:numel(curVars)
%                 [handles] = updateUIvalues(handles,curVars{i},prevData.trial(end).uiValue.(curVars{i}));
%             end
%             disp('settings loaded')
        else 
            disp('prev file not the same, loading matches')
        end
        
        vars2Load = find(ismember(curVars,prevVars));
        lastValid = max(find((cellfun(@isempty,{prevData.trial.vars}) == 0)));
        for i = 1:numel(vars2Load)
            [handles] = updateUIvalues(handles,curVars{vars2Load(i)},prevData.trial(lastValid).uiValue.(curVars{vars2Load(i)}));
        end
        disp('settings loaded')
   end
    
    
end




