function [handles] = updateUIvalues(handles,nameIn,valueIn)
%assigns teh values from the UI to the .vars structure so they are locked
%in and can be used during a session.
%also assigns any session variables from handles.user.program.sessionVars into teh same place


if nargin <3
    valueIn = [];
end

if nargin <2
    nameIn = [];
end

if ~isempty(valueIn)
    if isnumeric(valueIn)
        valueIn = num2str(valueIn);
    end
end


if isfield(handles.user,'program') && isfield(handles.user.program,'UI')
    
    if isempty(nameIn)
        fields = fieldnames(handles.user.program.UI);
        take = find(cellfun(@(x)~isempty(x),regexp(fields,'Input','match')));
    else
        fields = {[nameIn 'Input']};
        take = find(cellfun(@(x)~isempty(x),regexp(fields,'Input','match')));
    end
    
    for i = 1:numel(take)
        set(handles.user.program.UI.(fields{take(i)}),'backgroundColor',[1 1 1]);
        
        if isempty(valueIn)
            switch handles.user.program.UI.(fields{take(i)}).Style
                case 'edit'
                    valueString = get(handles.user.program.UI.(fields{take(i)}),'string');
                    value = str2num(valueString);
                case 'popupmenu'
                    allOptions = get(handles.user.program.UI.(fields{take(i)}),'string');
                    valueString = allOptions{get(handles.user.program.UI.(fields{take(i)}),'value')};
                    value = valueString;
            end
                    
        else
            %it has been supplied as an input argument
            switch handles.user.program.UI.(fields{take(i)}).Style
                case 'edit'
                    valueString = valueIn;
                    set(handles.user.program.UI.(fields{take(i)}),'string',valueString);  %must be written to the UI
                    value = str2num(valueString);
                case 'popupmenu'
                    valueString = valueIn;
                    allOptions = get(handles.user.program.UI.(fields{take(i)}),'string');
                    value = find(strcmp(allOptions,valueString));
                    set(handles.user.program.UI.(fields{take(i)}),'value',value);  %must be written to the U                   
            end
        end
        
        if isempty(value)
            try
                eval([ 'value =' valueString ';'])
                 if  ~iscell(value)
                    value = (round(value+1000))/1000;
                 end
            catch
                set(handles.user.program.UI.(fields{take(i)}),'backgroundColor',[1 0 0]);
                value = [];
            end
        end
        
        varName = fields{take(i)}(1:end-5);  %strip off the "Input";
        
        %update the use strings
        if ~isempty(value)
            set(handles.user.program.UI.([varName 'Use']),'string',valueString)
            try
                    if isnumeric(value)
                        set(handles.user.program.UI.([varName 'Use']),'string',num2str(value))
                    else
                         set(handles.user.program.UI.([varName 'Use']),'string',char(value))
                    end
            catch
                            set(handles.user.program.UI.([varName 'Use']),'string',valueString)
            end
        else
            value = str2num( get(handles.user.program.UI.([varName 'Use']),'string'));
        end
        
        %save them into the trial data structure
        nTrial = handles.user.program.nTrial;
        handles.user.program.trial(nTrial).vars.(varName) = value;
        handles.user.program.trial(nTrial).uiValue.(varName) = valueString;
        
    end
    
    %now assign in the session variables
    sesVarName = fieldnames(handles.user.program.sessionVars);
    for i = 1:numel(sesVarName)
        nTrial = handles.user.program.nTrial;
        handles.user.program.trial(nTrial).vars.(sesVarName{i}) = handles.user.program.sessionVars.(sesVarName{i});
    end
    
end
end