function [] = safeCloseDoor(handles,doorAddress,doorIRAddress,GPIOstate)
%SAFECLOSEDOOR closes a spesified door but first checks that the IR
%associated with door is not blocked.

if nargin < 4 || isempty(GPIOstate)
    [GPIOstate] = checkGPIOState(handles);
end

if GPIOstate(doorIRAddress)== 0
    psendPacket(handles,sprintf('GPO,%i,%i',doorAddress,1))
else
    warning('cannot close door as IR beam is blocked')
end

end

