function [handles] = makeTaskUIelements(handles, UIdata)

%name UIdata = {name,string,type,editValue,{uicontrol string value pairs}} 

%get teh panel position
pos = get(handles.programPanel,'position');

%create a function for converting panel relative position
%vectors into figure realtive
convPos = @(posIn)[(posIn(1)*pos(3) + pos(1)),...
    (posIn(2)*pos(4) + pos(2)),...
    (posIn(3)*pos(3)),...
    (posIn(4)*pos(4))];

ystart = 0.9;
ysize =  0.09;
yspace = -0.025;
xstart = 0.03;
xsize  = 0.12;
xspace = 0.01;

ytextoffset = - 0.03;

labelFontSize = 6   ;
xExtraText = 0.05;  %space taken from the inputs and given to the text
xExtraText = 0.02;  %space taken from the inputs and given to the text
xExtraText = 0.01;  %space taken from the inputs and given to the text

%clear any children in the program panel
delete(get(handles.programPanel,'children'));

%work out how many rows and columns you can fit into th           

%work out how many elements you can fit in a row
numElperCol = floor(1/(ysize + yspace));

%function for computing the row number
rowFun = @(x)rem(x-1,numElperCol)+ 1;

%function for computing the column number
colNum = @(x)(ceil(x/numElperCol) * 2)-1;

%select only the edit inputs first
take = find(strcmp(UIdata(:,3),'edit') | strcmp(UIdata(:,3),'popupmenu'));

for i = 1:numel(take)
    
    row = rowFun(i);
    col = colNum(i);
    
    %do the label
    handles.user.program.UI.([UIdata{take(i),1} 'Text']) =  uicontrol('style','text','units','normalized',...
                                          'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace))+ytextoffset (xsize+xExtraText)  ysize]),...
                                          'string',UIdata{take(i),2}, 'enable','on','fontsize',labelFontSize,'HorizontalAlignment','Right');
    %and the actual UI control
    switch UIdata{take(i),3}
        case 'popupmenu'
              handles.user.program.UI.([UIdata{take(i),1} 'Input'])  =  uicontrol('style','popupmenu','units','normalized',...
                                          'position',convPos([xstart+((col-1+1)*(xsize+xspace))+xExtraText ystart-((row-1)*(ysize+yspace)) (xsize-xExtraText)*0.5  ysize/1.5]),...
                                          'string',UIdata{take(i),4}, 'enable','on','backgroundcolor',[1 1 1],extrArgs{:});
               
               val = get(handles.user.program.UI.([UIdata{take(i),1} 'Input']),'value');
               strings = get(handles.user.program.UI.([UIdata{take(i),1} 'Input']),'string');
               
               handles.user.program.UI.([UIdata{take(i),1} 'Use'])  =  uicontrol('style','text','units','normalized',...
                                          'position',convPos([xstart+((col-1+1)*(xsize+xspace))+(xsize*0.5)+(xExtraText*0.5)  ystart-((row-1)*(ysize+yspace)) (xsize-xExtraText)*0.5  ysize/1.5]),...
                                          'string',strings{val},'backgroundcolor',[0.7 0.7 0.7],extrArgs{:});                          
                                      
        case 'edit'
           extrArgs = UIdata{take(i),5};
           handles.user.program.UI.([UIdata{take(i),1} 'Input'])  =  uicontrol('style','edit','units','normalized',...
                                          'position',convPos([xstart+((col-1+1)*(xsize+xspace))+xExtraText ystart-((row-1)*(ysize+yspace)) (xsize-xExtraText)*0.5  ysize/1.5]),...
                                          'string',UIdata{take(i),4}, 'enable','on','backgroundcolor',[1 1 1],extrArgs{:});
                                      
           handles.user.program.UI.([UIdata{take(i),1} 'Use'])  =  uicontrol('style','text','units','normalized',...
                                          'position',convPos([xstart+((col-1+1)*(xsize+xspace))+(xsize*0.5)+(xExtraText*0.5)  ystart-((row-1)*(ysize+yspace)) (xsize-xExtraText)*0.5  ysize/1.5]),...
                                          'string',UIdata{take(i),4},'backgroundcolor',[0.7 0.7 0.7],extrArgs{:});
    end
            
end

%now do the buttons

ystart = 0.87;
ysize =  0.14;
yspace = 0.001;
xstart = 0.1;
xsize  = 0.17;
xspace = 0.01;

ytextoffset = - 0.03;

%work out how many rows and columns you can fit into th           

%work out how many elements you can fit in a row
numElperCol = floor(1/(ysize + yspace));

%function for computing the row number
rowFun = @(x)rem(x-1,numElperCol)+ 1;

%function for computing the column number
colNum = @(x)(ceil(x/numElperCol) * 2)-1;


take = find(strcmp(UIdata(:,3),'pushbutton'));
for i = 1:numel(take)
    
    row = rowFun(i);
    col = colNum(i) + 3;
    extrArgs = UIdata{take(i),5};

    handles.user.program.UI.([UIdata{take(i),1} 'Button'])  =  uicontrol('style','pushbutton','units','normalized','string',UIdata{take(i),2},...
                                          'position',convPos([xstart+((col-1+1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize/1.5]),...
                                          extrArgs{:});
    
end

