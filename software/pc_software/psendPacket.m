function[] = psendPacket( handles,packet )
%wrapper to send packets to the serial port

switch get(handles.coordStatus,'string')
    case 'ONLINE'
        fprintf(handles.user.serial,packet);
        if get(handles.serialDumpCheckBox,'value')
            fprintf(['\n' 'tx: ' packet '\n'])
        end

        %write to file
        fprintf(handles.user.serial.user.dlogFid,' psendPacket ,%s,%.10f\n',packet,now);

    case 'emulation'
        %do nothing
end
%%pause(0.001)
end

