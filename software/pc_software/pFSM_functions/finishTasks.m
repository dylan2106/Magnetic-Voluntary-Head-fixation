function [handles] = finishTasks(handles)
%general tasks for the finish state

fields = fieldnames(handles.user.program.UI);
for i = 1:numel(fields)
   delete(handles.user.program.UI.(fields{i})); 
end

 set(handles.prevStateDisplay,'string', '[...]')
 set(handles.currentStateDisplay,'string','[...]')
 set(handles.trialNumberDisplay,'string','[...]')

 try
    cla(handles.axes1)
 end
 
%  save trial somewhere
%  handles.user.program.trial
%  
 handles.user.program = [];
 handles.user.currProg = [];     %clear name of this program since we have left it
    
 

end

