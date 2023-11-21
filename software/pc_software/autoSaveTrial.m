function [outcome] = autoSaveTrial(handles)
try
    if ~isempty(handles.user.currProg)
        currProg = [cell2mat(regexp(func2str(handles.user.currProg),'(?<=\))\w+(?=\()','match')) '_'];
    else
        currProg = '';
    end
    Q = datevec(now);
    file = sprintf('autoSave_%s%i%02i%02i_%02i%02i',currProg,Q(1),Q(2),Q(3),Q(4),Q(5));
    trial = handles.user.program.trial;
    save([handles.user.logDir '\autosave\' file],'trial');
    outcome = 1;
catch
    outcome = 0;
end


