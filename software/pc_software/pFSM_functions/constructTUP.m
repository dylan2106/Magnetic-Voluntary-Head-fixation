function [handles] = constructTUP(handles)

handles.user.program.timers.TUP2 = timer('timerfcn',@(~,~)pdispatch('TUP',guidata(handles.figure1)),...
    'startDelay',0.001);
handles.user.program.timers.TUP = timer('timerfcn',@(~,~)start(handles.user.program.timers.TUP2));
end

