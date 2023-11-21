 function []= log2file(handles)
 state = handles.user.program.state;
 i = handles.user.program.nTrial;
 fprintf(handles.user.serial.user.dlogFid,'MS %s,%s,trial%i,%.10f\n',state,mfilename,i,now);
 end