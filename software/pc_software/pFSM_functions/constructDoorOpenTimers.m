function [handles] = constructDoorOpenTimers(handles,doorAddresses,delays)

%NB do not edit this function to be able to construct door close timers,
%door closing should only happen in direct response to a poke with zero
%latency


if nargin <3
    delays = repmat(0.001,numel(doorAddresses));
end


for i = 1:numel(doorAddresses)
    if isnan(doorAddresses(i))
        continue
    end
    if isinf(delays(i))
        delays(i) = nan;
    end
        if ~isfield(handles.user.program,'timers') || ...
                ~isfield(handles.user.program.timers,'doorOpen') || ...
                numel(handles.user.program.timers.doorOpen) < i
            
            packet = sprintf('GPO,%i,0',doorAddresses(i));
            handles.user.program.timers.doorOpen(i) = timer('timerfcn',@(~,~)psendPacket(guidata(handles.figure1),packet),...
                'startDelay',delays(i));
        else
            packet = sprintf('GPO,%i,0',doorAddresses(i));
            set(handles.user.program.timers.doorOpen(i),...
                'timerfcn',@(~,~)psendPacket(guidata(handles.figure1),packet),...
                'startDelay',delays(i));
            
        end
    

end

