function [handles] = constructToneOffTimer(handles)

handles.user.program.timers.toneOff =timer('timerfcn',@(~,~)psendPacket(guidata(handles.figure1),'TON,0,0,0'),...
    'startDelay',0.001);
                               

end

