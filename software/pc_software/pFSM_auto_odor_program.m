function[handles] = pFSM_auto_odor_program(event,handles)

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

% if ~isempty(event) && strcmp(events{1},'NEXTTRIAL')
%     psendPacket(handles,'TON,0,0,0');                     %turn off
%     handles.user.program.trial(nTrial).userReset = 'normal';
%     
%     %handles.user.program.nTrial = handles.user.program.nTrial +1;
%     %handles = moveto(handles, 'trialsetup');
%     handles = moveto(handles, 'trialFinish');
%     return; %have to have a return in here so we do not flow down to the regular states
% end


if(strcmp(state, 'setup'))
    if entering
        disp('setting initial parameters for alternation')
        
        %clear any previous program data
        handles.user.program = [];
        
        %assign the variables for the program
        handles.user.program.state  = 'setup';     %current state;
        
        UIdata = {'odor','odor','edit','4',{'TooltipString','odor to present'};...
            'odorDelay','odorDelay','edit','2',{};...
            'odorDur','odorDur','edit','1',{};...
            'flushDur','flushDur','edit','3',{};...
            'flushID','flushID','edit','-1',{};...
            'nextTrial','nextTrial','pushbutton',[],{'callback',@(~,~)pdispatch('NEXTTRIAL',guidata(handles.figure1))}};
         
        [handles] = makeTaskUIelements(handles, UIdata);
        [handles] = constructTUP(handles);

        handles.user.program.olfEvtObj = odorEvt(handles.figure1,1,1,1,1,1,1);
        
        set(handles.pushbuttonStartProg,'enable','on');
        
        handles.user.program.nTrial = 1;
        handles.user.program.trial = [];    %<< the trial data structure
    else
        %we are responding to an event
        switch events{1}
            case 'TASKSTART'
                handles = moveto(handles,'trialsetup');
        end
    end
    
    
elseif(strcmp(state, 'trialsetup'))
    if entering
        %set(handles.trialNumberDisplay,'string',num2str(nTrial))
        [handles] = updateUIvalues(handles);
        assignUIvalues(handles); %assigns all the UI values to variables in the current workspace
        
        %program the odor timer system
        set(handles.user.program.olfEvtObj,'location',1,...
            'odorID',  odor,...
            'odorDelay',odorDelay,...
            'odorDur',  odorDur,...
            'flushDur', flushDur,...
            'flushID',flushID,...
            'offLoc',1,'offID',1);
        
        start(handles.user.program.olfEvtObj);
        handles = moveto(handles,'waitFlushEnd');
        
    end
    
elseif(strcmp(state, 'waitFlushEnd'))
    if entering
    else;switch events{1}
            case 'ODORFLUSHEND'
                handles.user.program.nTrial = handles.user.program.nTrial +1;
                handles = moveto(handles,'trialsetup');
        end
    end
        
elseif(strcmp(state, 'finish'))
    %we only enter here once
    disp('finishing task')
    try
        psendPacket(handles,'TON,0,0,0');                     %turn off
        psendPacket(handles	,'LED,0,0,0');                     %turn off
        psendPacket(handles ,'OLF,0,0');
    end
    handles = finishTasks(handles);
end