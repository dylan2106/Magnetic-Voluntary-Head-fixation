classdef odorEvt < handle
    %the odorEvt class spesifies and sequences the control of oodor
    %delivery to different locations, including the flsuhing of the odor
    %line
    
    properties
        
        location
        odorID
        odorDelay = 0;
        odorDur = 1;
        flushDur = 1;
        flushID
        offLoc = 0;
        offID       = 0;
    end
    
    %hidden properties
    properties (Hidden = true)
        guiFigure
        odorTimer
        flushTimer
        flushEndTimer  
        dispOpt = false;
    end
    
    properties (Dependent = true)
        status
    end
    
    
    %                T             Odor            Flush         End
    %odorTimer       |------------tFcn(1)---------tFcn(2)
    %flushTimer                                     |-----------tFcn(1)
    %                               |               |              |
    %                <  odorDelay  >|               |              |             
    %                               |<   odorDur   >|              |
    %                                               |< flushDur   >|
    methods
        
        %constructor
        function obj = odorEvt(guiFigure,location,odorID,odorDelay,odorDur,flushID,flushDur)
            
            obj.odorTimer = timer('timerFcn',@(~,~)odorTimerCallBack(obj),...
                                  'ExecutionMode','fixedRate',...
                                  'TasksToExecute',2);
            
            obj.flushTimer = timer('timerFcn',@(~,~)flushTimerCallBack(obj));
            %need a separate callback for diapatch event, otherwise the
            %event will come in the middle of the flushtimercallback and so
            %any querries to the status of the odor obj will return that it
            %is still in flush mode. the time is set to be a little after
            obj.flushEndTimer  = timer('timerFcn',@(~,~)pdispatch('ODORFLUSHEND',guidata(guiFigure)));
        
         
            obj.guiFigure = guiFigure;  
            obj.location = location;
            obj.odorID = odorID;
            obj.odorDelay = odorDelay;
            obj.odorDur = odorDur;
            obj.flushDur= flushDur;
            obj.flushID= flushID; 
            
        end
        
        %general lightweight set command
        function obj = set(obj,varargin)
           for i = 1:(numel(varargin)/2)
               obj.(varargin{(i*2)-1}) = varargin{(i*2)}; 
           end
            
        end
        
        function obj = set.odorDelay(obj,value)
            obj.odorDelay = value;
            set(obj.odorTimer,'startDelay',obj.odorDelay)
            
        end
        
       function obj = set.odorDur(obj,value) % Handle class
              obj.odorDur = value;
              set(obj.odorTimer, 'period', obj.odorDur)
       end
       
       function obj =  set.flushDur(obj,value)
           obj.flushDur = value;
           switch obj.status
               case 'flush'
                   warning('cannot set flushDur while flush is running')
                   %implement a property queueing system here?
               otherwise
                    set(obj.flushTimer, 'startDelay', obj.flushDur)
                    set(obj.flushEndTimer, 'startDelay', 0.005)   %make the callback with teh dispatch a little after the actual callback

           end

       end
        
       function odorTimerCallBack(obj)
           handles = guidata(obj.guiFigure);
           tasksExecuted= get(obj.odorTimer,'TasksExecuted');
           if tasksExecuted == 1
               %send the odor command
               command = sprintf('OLF,%d,%d',obj.location,obj.odorID);
               psendPacket(handles,command);
              if obj.dispOpt
                  fprintf('odor on at location %d, %.2f\n',obj.location,toc)
              end
               
           else
               %send the flush command
               command = sprintf('OLF,%d,%d',obj.location,obj.flushID);
               psendPacket(handles,command);
               if obj.dispOpt
                   fprintf('flush on at location %d, %.2f\n',obj.location,toc)
               end
               %start the flush timer
               start(obj.flushTimer)
           end
       end
       
       %ends the flush period
       function flushTimerCallBack(obj)
           handles = guidata(obj.guiFigure);
           command = sprintf('OLF,%d,%d',obj.offLoc,obj.offID);
           psendPacket(handles,command);
           
           if obj.dispOpt
                fprintf('off state, %.2f\n',toc)
           end
           start(obj.flushEndTimer)
           
       end
       
       %starts the odor event
        function success = start(obj)
            state = obj.status;
            switch state
                case 'idle'
                    start(obj.odorTimer)
                    tic;
                    success = true;
                case 'preOdor'
                    stop(obj.odorTimer) 
                    start(obj.odorTimer)
                    tic;
                    success = true;
                case 'odor'
                     fprintf('cannot start odor, odor ongoing at location %d\n',obj.location)
                     success = false;
                case 'flush'
                    %have to keep flush timer running
                    fprintf('cannot start odor, flush ongoing at location %d\n',obj.location)
                    success = false;
            end
        end
        
        %stops teh odor event
        function [] = stop(obj) 
             
            handles = guidata(obj.guiFigure);   
            state = obj.status;
            switch state
                case 'preOdor'
                    stop(obj.odorTimer) 
                case 'odor'
                    stop(obj.odorTimer)
                    %send the flush command
                    command = sprintf('OLF,%d,%d',obj.location,obj.flushID);
                    psendPacket(handles,command);
                    %start the flush timer
                    start(obj.flushTimer)
                case 'flush'
                    %have to keep flush timer running
                    fprintf('flush still ongoing at location %d\n',obj.location)
            end
        end
        
        %hard stop
        %stops the odor event regradless of what status, and does not
        %proceed to the schedualled flush, goes directly to the off state
        function [] = hardStop(obj) 
             
            handles = guidata(obj.guiFigure);   
            state = obj.status;
            switch state
                case 'preOdor'
                    stop(obj.odorTimer) 
                case 'odor'
                    stop(obj.odorTimer)
                case 'flush'
                    stop(obj.flushTimer)
                    
            end
           %send the command to go the stop state 
           handles = guidata(obj.guiFigure);
           command = sprintf('OLF,%d,%d',obj.offLoc,obj.offID);
           psendPacket(handles,command);
        end
        
        %pauses the presentation of an odor
        %no airflow is made, but there is no flush envent
        function [] = pause(obj)
%             handles = guidata(obj.guiFigure);   
%             state = obj.status;
%             switch state
%                 case 'preOdor'
%                     stop(obj.odorTimer) 
%                 case 'odor'
%                     stop(obj.odorTimer)
%                 case 'flush'
%                     stop(obj.flushTimer)
%                     
%             end
            
        end
        
        %returns the current status (state) of the system
        function result = get.status(obj)
            if strcmp(get(obj.odorTimer,'running'),'on')
                nTask = get(obj.odorTimer,'TasksExecuted');
                if nTask == 0
                    result = 'preOdor';
                elseif nTask == 1
                    result = 'odor';
                end     
            elseif  strcmp(get(obj.flushTimer,'running'),'on')
                result = 'flush';                
            else
                result = 'idle';
            end
            
        end
        
        
    end
    
end

