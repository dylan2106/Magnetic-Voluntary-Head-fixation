 function [] = startTup(handles,tupTime)
 %start TUP timer
 
 if strcmp(handles.user.program.timers.TUP.running,'on')
     stop(handles.user.program.timers.TUP.running);
 end
 if isinf(tupTime)
     %do nothings
 elseif (tupTime == 0)
     pdispatch('TUP',guidata(handles.figure1))
 else
     set(handles.user.program.timers.TUP,'startDelay',(round(tupTime*1000))/1000);
     start(handles.user.program.timers.TUP);
     
 end
 end