function [] =  giveReward(handles,location,numRew,rewDelayFun)
%function acts as a interface to give rewards at a certain location
%it calls the general reward evt callback in he GUI code

%rewDelayFun is the "rew" parameter in teh reward event, and can be a
%single numerical or a an

if nargin < 3
    numRew = [];
end

if nargin < 4
    rewDelayFun = [];
end

 %get the rew button handle so we can use its code to
 %execute the reward delivary.
 allTags = fields(handles);
 ind = ~cellfun(@isempty,regexp(allTags,sprintf('REW_but_%d',location)));
  
  hObject = handles.(allTags{ind});
%  
%  controllerGUI('general_REW_callback',hObject,[],guidata(hObject))
 
  controllerGUI('general_RewEvt_callback',hObject,[],guidata(hObject),location,numRew,rewDelayFun);
 end