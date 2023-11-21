%pFSM_paired_association_cued analysis
animalList = [456 457 384 383];

res = [];

session(1).file ='C:\Users\richp\Documents\logs_princeton\all_171207.mat';
session(1).animalInfo(1).num = 456;
session(1).animalInfo(1).trialInd = [4 9 14 19 24 29 34 39];
session(1).animalInfo(2).num = 457;
session(1).animalInfo(2).trialInd = [4 9 14 19 24 29 34 39]+1;
session(1).animalInfo(3).num = 384;
session(1).animalInfo(3).trialInd = [4 9 14 19 24 29 34 39]+2;
session(1).animalInfo(4).num = 383;
session(1).animalInfo(4).trialInd = [4 9 14 19 24 29 34 39]+3;



session(2).file ='C:\Users\richp\Documents\logs_princeton\all_171208.mat';
session(2).animalInfo(1).num = 456;
session(2).animalInfo(1).trialInd = [2 7 12 17 22 28 34 39];
session(2).animalInfo(2).num = 457;
session(2).animalInfo(2).trialInd = [2 7 12 17 22 28 34 39]+1;
session(2).animalInfo(3).num = 384;
session(2).animalInfo(3).trialInd = [2 7 12 17 22 28 34 39]+2;
session(2).animalInfo(4).num = 383;
session(2).animalInfo(4).trialInd = [2 7 12 17 22 28 34 39]+3;

s = 3;
session(s).file ='C:\Users\richp\Documents\logs_princeton\all_171211.mat';
session(s).animalInfo(1).num = animalList(1);
session(s).animalInfo(1).trialInd = [4 10 15 20 27 33 38 43];
for i = 2:4
session(s).animalInfo(i).num = animalList(1);
session(s).animalInfo(i).trialInd = session(s).animalInfo(1).trialInd + (i-1);
end

s = 4;
session(s).file ='C:\Users\richp\Documents\logs_princeton\all_171212.mat';
session(s).animalInfo(1).num = animalList(1);
session(s).animalInfo(1).trialInd = [2 7 12 17 22 28 33 38];
for i = 2:4
session(s).animalInfo(i).num = animalList(1);
session(s).animalInfo(i).trialInd = session(s).animalInfo(1).trialInd + (i-1);
end

s = 5;
session(s).file ='C:\Users\richp\Documents\logs_princeton\all_171214.mat';
session(s).animalInfo(1).num = animalList(1);
session(s).animalInfo(1).trialInd = [6 11 16 21 26 31 36 41];
for i = 2:4
session(s).animalInfo(i).num = animalList(1);
session(s).animalInfo(i).trialInd = session(s).animalInfo(1).trialInd + (i-1);
end

s = 6;
%need to concatinate the trial structures (do it once)
% % % data1 = load('C:\Users\richp\Documents\logs_princeton\all_171216.mat');
% % % data2 = load('C:\Users\richp\Documents\logs_princeton\all_171216_2.mat');
% % % data1.handles.user.program.trial = cat(2,[data1.handles.user.program.trial],data2.handles.user.program.trial);
% % % handles = data1.handles;
% % % save('C:\Users\richp\Documents\logs_princeton\all_171216_concatinated.mat','handles')

session(s).file ='C:\Users\richp\Documents\logs_princeton\all_171216_concatinated.mat';
session(s).animalInfo(1).num = animalList(1);
session(s).animalInfo(1).trialInd = [10 14]; %<only two trials for him, since bad motivation
session(s).animalInfo(1).excelIndInd = [1 2]; %the index of the excel index (which excel trial in that session block this was)

session(s).animalInfo(2).num = animalList(2);
session(s).animalInfo(2).trialInd = [11 15 18 21 24 28 32 35];
session(s).animalInfo(3).num = animalList(2);
session(s).animalInfo(3).trialInd = [12 16 19 22 25 29 33 37];
session(s).animalInfo(4).num = animalList(2);
session(s).animalInfo(4).trialInd = [13 17 20 23 26 30 34 38];


s = 7;
session(s).file ='C:\Users\richp\Documents\logs_princeton\all_171218.mat';
session(s).animalInfo(1).num = animalList(1);
session(s).animalInfo(1).trialInd = [2 6 10 14 18 22 26 30];
for i = 2:4
session(s).animalInfo(i).num = animalList(1);
session(s).animalInfo(i).trialInd = session(s).animalInfo(1).trialInd + (i-1);
end

s = 8;
session(s).file ='C:\Users\richp\Documents\logs_princeton\all_180103.mat';
session(s).animalInfo(1).num = animalList(1);
session(s).animalInfo(1).trialInd = [2 7 11 15 19 23 27 31];
for i = 2:4
session(s).animalInfo(i).num = animalList(1);
session(s).animalInfo(i).trialInd = session(s).animalInfo(1).trialInd + (i-1);
end
session(s).animalInfo(3).trialInd(1) = 5; 
session(s).animalInfo(4).trialInd(1) = 6; 

s = 9;
session(s).file ='C:\Users\richp\Documents\logs_princeton\all_180105.mat';
session(s).animalInfo(1).num = animalList(1); 
session(s).animalInfo(1).trialInd = [5 9 13 17 21 25 29 33];
for i = 2:4
session(s).animalInfo(i).num = animalList(1);
session(s).animalInfo(i).trialInd = session(s).animalInfo(1).trialInd + (i-1);
end

session(s).animalInfo(2).trialInd = [26 34];
session(s).animalInfo(2).excelIndInd = [6 8]; %the index of the excel index (which excel trial in that session block this was)

s = 10;
session(s).file ='C:\Users\richp\Documents\logs_princeton\all_180108.mat';
session(s).animalInfo(1).num = animalList(1); 
session(s).animalInfo(1).trialInd = [2 6 10 14 18 22 26 30];
for i = 2:4
session(s).animalInfo(i).num = animalList(1);
session(s).animalInfo(i).trialInd = session(s).animalInfo(1).trialInd + (i-1);
end


s = 10;
session(s).file ='C:\Users\richp\Documents\logs_princeton\all_180109.mat';
session(s).animalInfo(1).num = animalList(1); 
session(s).animalInfo(1).trialInd = [19:26];
session(s).animalInfo(2).num = animalList(2); 
session(s).animalInfo(2).trialInd = [2:3 5:10];
session(s).animalInfo(3).num = animalList(3); 
session(s).animalInfo(3).trialInd = [27:29 31:35];
session(s).animalInfo(4).num = animalList(4); 
session(s).animalInfo(4).trialInd = [11:18];

s = 11;
session(s).file ='C:\Users\richp\Documents\logs_princeton\all_180110.mat';
session(s).animalInfo(1).num = animalList(1); 
session(s).animalInfo(1).trialInd = [18 19 21:23 25:27];
session(s).animalInfo(2).num = animalList(2); 
session(s).animalInfo(2).trialInd = [2:9];
session(s).animalInfo(3).num = animalList(3); 
session(s).animalInfo(3).trialInd = [28:35];
session(s).animalInfo(4).num = animalList(4); 
session(s).animalInfo(4).trialInd = [10:17];

s = 12;
session(s).file ='C:\Users\richp\Documents\logs_princeton\all_180111.mat';
session(s).animalInfo(1).num = animalList(1); 
session(s).animalInfo(1).trialInd = [19:26];
session(s).animalInfo(2).num = animalList(2); 
session(s).animalInfo(2).trialInd = [2:7];
session(s).animalInfo(2).excelIndInd = [1:6]; %the index of the excel index (which excel trial in that session block this was)
session(s).animalInfo(3).num = animalList(3); 
session(s).animalInfo(3).trialInd = [27:34];
session(s).animalInfo(4).num = animalList(4); 
session(s).animalInfo(4).trialInd = [10:14 16:18];

%the Matrix A was input manually from the lab notebook
% % save('C:\Users\richp\Dropbox\Princeton\behavioural_data\logs\all_rawmatrixA_180116.mat','A')
% for i =1:size(A,1)
%    inputTrial(i).sampleLocs = A(i,2:3);  
%    inputTrial(i).goalInd = find(inputTrial(i).sampleLocs == A(i,4));
%    
%    if A(i,5) == 1
%        inputTrial(i).outcome = 'correct';
%        inputTrial(i).choice =  inputTrial(i).sampleLocs(inputTrial(i).goalInd);
%    else
%        inputTrial(i).outcome = 'incorrect';
%        inputTrial(i).choice =  inputTrial(i).sampleLocs(rem(inputTrial(i).goalInd+2,2)+1);
% 
%    end
% end
% trial = inputTrial;
%  save('C:\Users\richp\Dropbox\Princeton\behavioural_data\logs\all_manualEntry_180116.mat','trial')
 
s = 13;
session(s).file ='C:\Users\richp\Dropbox\Princeton\behavioural_data\logs\all_manualEntry_180116.mat';
session(s).animalInfo(1).num = animalList(1); 
session(s).animalInfo(1).trialInd = [20:29];
session(s).animalInfo(2).num = animalList(2); 
session(s).animalInfo(2).trialInd = [1:9];
session(s).animalInfo(2).excelIndInd = [1:6 8:10]; %the index of the excel index (which excel trial in that session block this was)

session(s).animalInfo(3).num = animalList(3); 
session(s).animalInfo(3).trialInd = [30:39];
session(s).animalInfo(4).num = animalList(4); 
session(s).animalInfo(4).trialInd = [10:19];

s = 14;
session(s).file ='C:\Users\richp\Dropbox\Princeton\behavioural_data\logs\all_180117.mat';
session(s).animalInfo(1).num = animalList(1); 
session(s).animalInfo(1).trialInd = [23:32];
session(s).animalInfo(2).num = animalList(2); 
session(s).animalInfo(2).trialInd = [3:12];
session(s).animalInfo(3).num = animalList(3); 
session(s).animalInfo(3).trialInd = [33:42];
session(s).animalInfo(4).num = animalList(4); 
session(s).animalInfo(4).trialInd = [13:22];

s = 15;
session(s).file ='C:\Users\richp\Dropbox\Princeton\behavioural_data\logs\all_180118.mat';
session(s).animalInfo(1).num = animalList(1); 
session(s).animalInfo(1).trialInd = [23:32];
session(s).animalInfo(2).num = animalList(2); 
session(s).animalInfo(2).trialInd = [3:12];
session(s).animalInfo(3).num = animalList(3); 
session(s).animalInfo(3).trialInd = [33:42];
session(s).animalInfo(4).num = animalList(4); 
session(s).animalInfo(4).trialInd = [13:22];


s = 16;
session(s).file ='C:\Users\richp\Dropbox\Princeton\behavioural_data\logs\all_180122.mat';
session(s).animalInfo(1).num = animalList(1); 
session(s).animalInfo(1).trialInd = [23:27 29:33];
session(s).animalInfo(2).num = animalList(2); 
session(s).animalInfo(2).trialInd = [2:5 7:12];
session(s).animalInfo(3).num = animalList(3); 
session(s).animalInfo(3).trialInd = [34:43];
session(s).animalInfo(4).num = animalList(4); 
session(s).animalInfo(4).trialInd = [13:22];

s = 17;
session(s).file ='C:\Users\richp\Dropbox\Princeton\behavioural_data\logs\all_180123.mat';
session(s).animalInfo(1).num = animalList(1); 
session(s).animalInfo(1).trialInd = [22:31];
session(s).animalInfo(2).num = animalList(2); 
session(s).animalInfo(2).trialInd = [2:11];
session(s).animalInfo(3).num = animalList(3); 
session(s).animalInfo(3).trialInd = [33:42];
session(s).animalInfo(4).num = animalList(4); 
session(s).animalInfo(4).trialInd = [12:21];

s = 18;
session(s).file ='C:\Users\richp\Dropbox\Princeton\behavioural_data\logs\all_180124.mat';
session(s).animalInfo(1).num = animalList(1); 
session(s).animalInfo(1).trialInd = [22:31];
session(s).animalInfo(2).num = animalList(2); 
session(s).animalInfo(2).trialInd = [2:11];
session(s).animalInfo(3).num = animalList(3); 
session(s).animalInfo(3).trialInd = [32:41];
session(s).animalInfo(4).num = animalList(4); 
session(s).animalInfo(4).trialInd = [12:21];

s = 19;
session(s).file ='C:\Users\richp\Dropbox\Princeton\behavioural_data\logs\all_180125.mat';
session(s).animalInfo(1).num = animalList(1); 
session(s).animalInfo(1).trialInd = [22:31];
session(s).animalInfo(2).num = animalList(2); 
session(s).animalInfo(2).trialInd = [3:11];
session(s).animalInfo(2).excelIndInd = [1:6 8:10]; %the index of the excel index (which excel trial in that session block this was)
session(s).animalInfo(3).num = animalList(3); 
session(s).animalInfo(3).trialInd = [32:41];
session(s).animalInfo(4).num = animalList(4); 
session(s).animalInfo(4).trialInd = [20 21];   %all but two of these trial had no odor due to a mixup with the adressing
session(s).animalInfo(4).excelIndInd = [9:10]; %the index of the excel index (which excel trial in that session block this was)

%
[num,txt,raw]=xlsread('C:\Users\richp\Dropbox\Princeton\behavioural_data\postion_odor_record.xlsx');
%convert the xcell dates from the absurd no padding zeros format (which
%the excel inport function insists!!! on to one with a ppadding zeros
%in the day and month. my fault for using excel i guess.... :(
for i = 1:size(raw,1)
   if ischar(raw{i,1})
       try
        raw{i,1} = datestr(raw{i,1},'mm/dd/yyyy');
       end
   end
end

%import the odor library
[~,odorLib,~]=xlsread('C:\Users\richp\Dropbox\Princeton\behavioural_data\postion_odor_record.xlsx','sheet3');

%%
if exist('allTrials'); clear allTrials;end

for s = 1:numel(session)
    warning off
    dat = load(session(s).file);
    warning on
    
    %some older files have the whole handles structure saved
    if isfield(dat,'handles')    
        trial = dat.handles.user.program.trial;
    elseif isfield(dat,'trial')
        trial = dat.trial;
    end
    for i = 1:numel(session(s).animalInfo)
        allTrials{s,i} = trial(session(s).animalInfo(i).trialInd);
    end
    
    %load up from the excel file
    Q = cellfun(@str2num,regexp(session(s).file,'\d{2}','match'));
    date = datestr([Q+[2000 0 0] 0 0 0],'mm/dd/yyyy');
    
    dateHits = cellfun(@(x)strcmp(x,date),raw(:,1));
    %check teh date hits to see if they have an associated animal string in
    %teh next column
    for a = 1:4
        if sum(dateHits) == 1
            %there is just one date hit, so we assume there is just one 
            sessionHit =  find(dateHits);
        elseif all(~(cellfun(@isempty,raw(dateHits,2))))
           animalHits = cellfun(@(x)x==animalList(a),raw(:,2));
           sessionHit = find(animalHits & dateHits);
           
        else
           sessionHit = nan;
        end
        
        t = 0;
        while ischar(raw{sessionHit+t,3}) || ~isnan(raw{sessionHit+t,3})
            t = t+1;
        end
        ind = sessionHit:sessionHit+t-1;
        
        if numel(ind) == numel(session(s).animalInfo(a).trialInd)
            %we can assign the locations and odors directly
            session(s).animalInfo(a).excelInd = ind;
        else
            %there is some mismatch between teh excel files 
            if~isempty(session(s).animalInfo(a).excelIndInd)
                session(s).animalInfo(a).excelInd  = ind(session(s).animalInfo(a).excelIndInd);
            else
                session(s).animalInfo(a).excelInd = nan;
                sprintf('cannot match up excel and trial indexs s=%i,a=%i\n',s,a)
            end
        end
    
        %load up teh positions
        %postion = physical position
        %location = number of the nosepoke
    for t = 1:numel(allTrials{s,a})
        postion = [raw{session(s).animalInfo(a).excelInd(t),[4 6]}];
        %index the position with the location
        allTrials{s,a}(t).samplePositions = postion(allTrials{s,a}(t).sampleLocs-1);
        %do the same with the odors except that it is a little complicated
        %since for each location (nose poke) there can be two odor lines
        %this is because I switched the odor lines from trial to trial
        %[2,3] then [4 5] to give them a chance to out gas
        odors =  raw(session(s).animalInfo(a).excelInd(t),[3 5]);
        %allTrials{s,a}(t).sampleOdorsID =   odors(rem(allTrials{s,a}(t).sampleOdors - 1 - 1,2)+1);
        
        %can just use the index for the nose ports
        allTrials{s,a}(t).sampleOdorsID = odors(allTrials{s,a}(t).sampleLocs-1);
        
        %while we are here we should generate teh choice
        %(in earlier  dataset we did not record this
        if ~isempty(allTrials{s,a}(t).outcome)
            if ~isfield(allTrials{s,a}(t),'choice') || isempty(allTrials{s,a}(t).choice)
                switch allTrials{s,a}(t).outcome
                    case 'correct'
                        allTrials{s,a}(t).choice =  allTrials{s,a}(t).sampleLocs(allTrials{s,a}(t).goalInd);
                    case 'incorrect'
                        ind = rem(allTrials{s,a}(t).goalInd,2)+1; %if incorrect, converts a 1 to a 2 and 2 to a 1;
                        allTrials{s,a}(t).choice =  allTrials{s,a}(t).sampleLocs(ind);
                    otherwise
                        allTrials{s,a}(t).choice = nan;
                end
            end
        else
            allTrials{s,a}(t).choice = nan;
        end
        
    end
    
    end
end

%%

%%
results.nCor = cellfun(@(trial)sum(strcmp({trial.outcome},'correct')),allTrials);
results.nTrial = cellfun(@(trial)numel(trial),allTrials);
results.p = nan(size(results.nCor));
for i = 1:numel(allTrials)
    trial  = allTrials{i};
    
    %binocdf(X,N,0.5) 
    %p x<=X . so set X to failures, so binocdf(1,8,0.5) is the probability
    %of 1 or less failutes(/successes in 8 trials or 0.5)
    results.pPerSession(i) = binocdf(results.nTrial(i)-results.nCor(i),results.nTrial(i),0.5);
end

[pthr,pcor,padj] = fdr(results.pPerSession(:));
results.padjPerSession = reshape(padj,size(results.p));

for i = 1:size(allTrials,2)

    nTrial = sum(results.nTrial(:,i));
    nCor = sum(results.nCor(:,i));
    
    results.pPerAnimal(i) = binocdf(nTrial - nCor,nTrial,0.5);

end


%%
%compute the latencys from the cue poke to the first choice
results.cueChoiceLatencyMean = nan(size(results.nTrial));
results.trialLengthMean = nan(size(results.nTrial));
results.recency =nan(size(results.nTrial));
results.choiceBias = nan(size(results.nTrial));
results.lastChoice = nan(size(results.nTrial));
results.winStayLooseSwitch = nan(size(results.nTrial));

results.positionChoice = zeros(18,18,4);
results.positionGoal = zeros(2,18,4);

results.odorGoal = zeros(2,size(odorLib,1),4);


for i = 1:numel(allTrials)
    trial = allTrials{i};
    for t = 1:numel(trial)
        try
            cueChoiceLatency=(trial(t).choiceTime(1) - trial(t).cuePokeTime(1)) *24 *60 *60;
            allTrials{i}(t).cueChoiceLatency = cueChoiceLatency;
            trialLength = (trial(t).choiceTime(1) - trial(t).startTime) *24 *60 *60;
            allTrials{i}(t).trialLength = trialLength;
            
        catch
            allTrials{i}(t).cueChoiceLatency = nan;
            allTrials{i}(t).trialLength = nan;
        end
         
    end
    results.cueChoiceLatencyMean(i) = nanmean([allTrials{i}.cueChoiceLatency]);
    results.trialLengthMean(i) = nanmean([allTrials{i}.trialLength]);
    
    if isfield(allTrials{i},'choice')
        ind = find(arrayfun(@(trial)~isempty(trial.choice),allTrials{i}));
        results.choiceBias(i) = sum(arrayfun(@(trial)trial.choice(1),allTrials{i}(ind)) == 2)./numel(allTrials{i}(ind));
        recency = arrayfun(@(trial)trial.choice(1) == trial.sampleLocs(end),allTrials{i}(ind));
        results.recency(i) = sum(recency)./numel(recency);
        
        stay = arrayfun(@(trial)trial.choice(1),trial(ind(1:end-1))) ==...
               arrayfun(@(trial)trial.choice(1),trial(ind(2:end)));
                               
        results.lastChoice(i) = sum(stay) / (numel(ind)-1);
                                                %win on trial n ...                     stay on trial n+1
        results.winStayLooseSwitch(i) = sum(xor(strcmp({trial(ind(1:end-1)).outcome},'correct')' ,stay')) ./(numel(ind)-1);
    else
     
        
    end
    
    %populate teh position choice matrix
    [s, a] = ind2sub(size(allTrials),i);
      for t = 1:numel(trial)
          if isfield(trial(t),'choice')
              ind = trial(t).choice(1) == trial(t).sampleLocs;
              choose = trial(t).samplePositions(ind);
              reject = trial(t).samplePositions(~ind);
              results.positionChoice(choose,reject,a) = results.positionChoice(choose,reject,a)+1;
              
              
              goalPos = trial(t).samplePositions(trial(t).goalInd);
              odorInd = find(strcmp(odorLib,trial(t).sampleOdorsID(trial(t).goalInd)));
              
              if ischar(trial(t).outcome)
                  switch trial(t).outcome
                      case 'correct'
                          results.positionGoal(1,goalPos,a) = ...
                          results.positionGoal(1,goalPos,a)+1;
                          
                          results.odorGoal(1,odorInd,a) = ... 
                          results.odorGoal(1,odorInd,a)+1;
                      
                      case 'incorrect'
                          results.positionGoal(2,goalPos,a) = ...
                          results.positionGoal(2,goalPos,a)+1;
                          results.odorGoal(2,odorInd,a) = ... 
                          results.odorGoal(2,odorInd,a)+1;
                  end
              end
          end
      end
end
%%
figure
subm = 4;
subn = 1;
subplot(subm,subn,[1])
plot(squeeze(sum(results.positionChoice,1)))
ylabel('# rejections')

subplot(subm,subn,[2])
plot(squeeze(sum(results.positionChoice,2)))
ylabel('# chooseing')

subplot(subm,subn,[3])
plot(squeeze(sum(results.positionChoice,2)) - squeeze(sum(results.positionChoice,1)))
hold on
plot([0 18],[0 0],'k:')
ylabel('# chooseing - rejections')

subplot(subm,subn,[4])
plot(squeeze(results.positionGoal(1,:,:) ./sum(results.positionGoal,1)))
ylabel('% correct responses\n given goal')
xlabel('position')
%%
figure
subm = 1;
subn = 1;
subplot(subm,subn,[1])
plot(repmat(1:numel(odorLib),2,1), repmat([0 1]',1,numel(odorLib)),'color',[0.9,0.9,0.9])
hold on
plot(squeeze(results.odorGoal(1,:,:) ./sum(results.odorGoal,1)),'.-')
ylabel('% correct responses\n given odor')
set(gca,'xtick',[1:numel(odorLib)],'xticklabel',odorLib)
rotateticklabel(gca,90)
grid off

xlabel('position')

%%
if ~exist('perfFig')
    perfFig = figure;
else
    figure(perfFig);
end
subm = 7;
subn = 1;
subplot(subm,subn,[1 2])
percentCor = results.nCor./results.nTrial;
plot(1:s,bsxfun(@plus,percentCor ,linspace(0,0.01,4)),'.-')
hold on
plot(1:s,sum(results.nCor,2)./sum(results.nTrial,2),'k','linewidth',2)
plot([1 s],[0.5 0.5],'k:')
scatter((s+1)*[1 1 1 1],sum(results.nCor,1)./sum(results.nTrial,1),50,lines(4),'o')
xlim([0 s+2])
ylim([0 1])
set(gca,'xtick',[1:s],'ytick',[0:0.2:2])
ylabel('prop correct')
xlabel('session')

subplot(subm,subn,3)
plot(1:s,bsxfun(@plus,cumsum(results.nTrial,1),[0:1:3]))
ylabel('number of trials')
set(gca,'xtick',[])
xlim([0 s+2])

subplot(subm,subn,4)
plot(results.choiceBias)
hold on
plot([1 s],[0.5 0.5],'k:')
ylabel('choice Bias')
set(gca,'xtick',[])
xlim([0 s+2])

subplot(subm,subn,5)
plot(results.recency)
hold on
plot([1 s],[0.5 0.5],'k:')
ylabel({'recent sample';' Bias'})
set(gca,'xtick',[])
xlim([0 s+2])

subplot(subm,subn,6)
plot(results.lastChoice)
hold on
plot([1 s],[0.5 0.5],'k:')
ylabel({'last Choice';' Bias'})
set(gca,'xtick',[])
xlim([0 s+2])

subplot(subm,subn,7)
plot(results.winStayLooseSwitch)
hold on
plot([1 s],[0.5 0.5],'k:')
ylabel({'winStay';'LooseSwitch Bias'})
set(gca,'xtick',[])
xlim([0 s+2])
set(gca,'xtick',[1:s])

A = regexp({session.file},'[0-9]{6}','match');
set(gca,'xtick',[1:s],'xticklabel',[A{:}])
rotateticklabel(gca,90)
%%



%%
for s = 1:numel(session)

    res.outcome(:,:,s) = nan(8,4);
    res.goal(:,:,s) = nan(8,4);
    res.choice(:,:,s) = nan(8,4);
    res.sample1(:,:,s) = nan(8,4);
    res.sample2(:,:,s) = nan(8,4);
    res.choiceLastSample(:,:,s) = nan(8,4);

    
    for i = 1:numel(session(s).animalInfo)
        allTrials(s,i) = trial(session(s).animalInfo(i).trialInd);
        
        res.numTrials(s,i) = numel(session(s).animalInfo(i).trialInd);
        n = res.numTrials(s,i);
        res.numCor(s,i) = sum(strcmp({trial(session(s).animalInfo(i).trialInd).outcome},'correct'));
        res.outcome(1:n,i,s) = strcmp({trial(session(s).animalInfo(i).trialInd).outcome},'correct')' +0;
       
        sampleLocs = cat(1,trial(session(s).animalInfo(i).trialInd).sampleLocs);
        for t = 1:size(sampleLocs,1)
            res.goal(t,i,s) =  sampleLocs(t,trial(session(s).animalInfo(i).trialInd(t)).goalInd); 
            res.choice(t,i,s) = rem(  ( res.goal(t,i,s) +~(res.outcome(t,i,s)==1)      )   -2,2)+2;
        end
        res.sample1(1:n,i,s) =  sampleLocs(:,1);
        res.sample2(1:n,i,s) =  sampleLocs(:,1);
        
        if 0
        [res.sample1(:,i,s)  res.sample2(:,i,s) res.choice(:,i,s) res.goal(:,i,s) res.outcome(:,i,s)]
        end
        
        %is the choice just the last one he sampled
        res.choiceLastSample(:,i,s) = (res.sample2(:,i,s) == res.choice(:,i,s) )+0;

    end
    %show the trial indexes and the outcomes
    if 0
        [arrayfun(@(x){x},1:numel(trial))' {trial.outcome}']
    end
%     subplot(numel(session),5, 5*(s-1) + 1)
%     imagesc(res.outcome(:,:,s))
%     
%     subplot(numel(session),5, 5*(s-1) + 2)
%     imagesc(res.choiceLastSample(:,:,s))
%     
%     subplot(numel(session),5, 5*(s-1) + 3)
%     imagesc(res.goal(:,:,s))
%     
%     subplot(numel(session),5, 5*(s-1) + 4)
%     imagesc(res.choice(:,:,s))
end

figure
subplot
percentCor = res.numCor./res.numTrials;
plot(1:s,percentCor)
hold on
plot(1:s,sum(res.numCor,2)./sum(res.numTrials,2),'k','linewidth',2)
plot([1 s],[0.5 0.5],'k:')
scatter((s+1)*[1 1 1 1],sum(res.numCor,1)./sum(res.numTrials,1),50,lines(4),'o')
xlim([0 s+2])
set(gca,'xtick',[1:s])
ylabel('prop correct')
xlabel('session')

