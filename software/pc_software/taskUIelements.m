function [handles] = taskUIelements(handles, UIdata)

%name UIdata = {name,string,type,editValue} 

%get teh panel position
pos = get(handles.programPanel,'position');

%create a function for converting panel relative position
%vectors into figure realtive
convPos = @(posIn)[(posIn(1)*pos(3) + pos(1)),...
    (posIn(2)*pos(4) + pos(2)),...
    (posIn(3)*pos(3)),...
    (posIn(4)*pos(4))];

ystart = 0.87;
ysize =  0.08;
yspace = 0.01;
xstart = 0.03;
xsize  = 0.17;
xspace = 0.01;

ytextoffset = - 0.03;

%clear any children in the program panel
delete(get(handles.programPanel,'children'));

%work out how many rows and columns you can fit into th           

%work out how many elements you can fit in a row
numElperCol = floor(1/(ysize + yspace));

%function for computing the row number
rowFun = @(x)rem(x-1,numElperCol)+ 1;

%function for computing the column number
colNum = @(x)(ceil(x/numElperCol) * 2)-1;

for i = 1:size(UIdata,1)
    
    row = rowFun(i);
    col = colNum(i);
    
    %do the label
    handles.user.program.UI.([UIdata{i,1} 'Text']) =  uicontrol('style','text','units','normalized',...
                                          'position',convPos([xstart+((col-1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace))+ytextoffset xsize  ysize]),...
                                          'string',UIdata{i,1}, 'enable','on');
    %and the actual UI control
    switch UIdata{i,2}
        case 'popupmenu'
            %not sure on the exact popup syntax..
        case 'edit'
           extrArgs = UIdata{i,4};
           handles.user.program.UI.([UIdata{i,1}])  =  uicontrol('style','edit','units','normalized',...
                                          'position',convPos([xstart+((col-1+1)*(xsize+xspace)) ystart-((row-1)*(ysize+yspace)) xsize  ysize/1.5]),...
                                          'string',UIdata{i,3}, 'enable','on','backgroundcolor',[1 1 1],extrArgs{:});
    end
            
end