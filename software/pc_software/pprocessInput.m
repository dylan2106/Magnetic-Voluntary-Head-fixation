function pprocessInput(serialObj,eventData,handles)
 
bytesToRead = get(serialObj,'BytesAvailable');
packet = fscanf(serialObj);

packet =regexprep(packet,'\r\n|\n|\r','');
if get(handles.serialDumpCheckBox,'value')
    fprintf(['\n' 'rx: ' packet '\n'])
end

%write to file
fprintf(handles.user.serial.user.dlogFid,'pprocessInput,%s,%.10f\n',packet,now);

pdispatch(packet,handles);