function [GPIOstate] = checkGPIOState(handles)
%CHECKGPIOSTATE reads the state of the GPIO from the gui display


GPIOBlobs = get(handles.uipanel_GPIO,'children');
GPIOstate = nan(numel(GPIOBlobs),1);

for i = 1:numel(GPIOBlobs)
    ind = str2num(GPIOBlobs(i).String);
    
    if all(GPIOBlobs(i).BackgroundColor == [1 1 1])
        GPIOstate(ind) = 0;
    elseif all(GPIOBlobs(i).BackgroundColor == [1 0 0])
        GPIOstate(ind) = 1;
    end
   
end

