tic
for i = 1:10
psendPacket(handles,sprintf('MOD,1,1,%i',i));
toc
end

%%
data = dserialLog20190226171904;
data = dserialLog20190226173203;
data = dserialLog20190226173741;
data = dserialLog20190226174044;
data = dserialLog20190226180817
%%
sentInd = find(data.MOD == 'MOD');
recInd  = find(data.MOD == 'CON' & data.psendPacket == 'pprocessInput');
recIndCorresp=[];
timeStamps = [];
for i = 1:numel(sentInd)
    dat = data(sentInd(i),5);
    recIndCorresp(i) = recInd(data{recInd,6} == dat{1,1});
    
    timeStamps(i,1) = data{sentInd(i),6};
    timeStamps(i,2) = data{recIndCorresp(i),7};
    
end
timeStamps = timeStamps-timeStamps(1);
timeStamps =timeStamps*24*60*60;

plot(timeStamps',1:size(timeStamps,1),'o')

