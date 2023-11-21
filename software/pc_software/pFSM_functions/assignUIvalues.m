function [] = assignUIvalues(handles)
%assigns variables from the string of the UI elements [...USE] as variable in the
%caller workspace,

if isfield(handles.user,'program') &&  isfield(handles.user.program,'trial') && isfield(handles.user.program.trial,'vars')
    nTrial = handles.user.program.nTrial;
    if nTrial == sum(arrayfun(@(x)~isempty(x.vars),handles.user.program.trial))
        varNames = fieldnames(handles.user.program.trial(nTrial).vars);
        for i =1:numel(varNames)
            value = handles.user.program.trial(nTrial).vars.(varNames{i});
            assignin('caller',varNames{i},value);
        end
    end
end
end
%
%     fields = fieldnames(handles.user.program.UI);
% 
% 
% 
% 
% take = find(cellfun(@(x)~isempty(x),regexp(fields,'Use','match')));
% 
% for i = 1:numel(take)
%     
%     temp = get(handles.user.program.UI.(fields{take(i)}),'string');
%     value = str2double(temp );
%     
%     varName = fields{take(i)}(1:end-3);  %strip off the "end";
%     assignin('caller',varName,value)
%     
% end
% 
% end
% end

