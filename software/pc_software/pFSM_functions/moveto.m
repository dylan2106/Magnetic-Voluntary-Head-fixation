function handles = moveto(handles,destination)
 %this is the interface for moving to another state,
 %inputs - handles:    the handles structure
 %       - destination: a string with the destination state name
 %
 %outputs - handles:  the handles structure

 %stop the current TUP
 if isfield(handles.user.program,'timers')
 if isfield(handles.user.program.timers,'TUP')
    stop(handles.user.program.timers.TUP);
 end
 end
 
 set(handles.prevStateDisplay,'string', handles.user.program.state)
 %set the state to the destination
 handles.user.program.state  = destination;  
 
 %update the display
 set(handles.currentStateDisplay,'string',destination)
 
 log2file(handles);

 handles = handles.user.currProg([],handles);
  
%  %generate the filename
%  thisFile = mfilename;
%  
%  %evaluate the function 
%  eval(sprintf('handles =%s([],handles);',thisFile));
%  
 end
 
