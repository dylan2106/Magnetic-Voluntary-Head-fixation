classdef rewEvt < handle
    %the odorEvt class spesifies and sequences the control of oodor
    %delivery to different locations, including the flsuhing of the odor
    %line
    
    properties
        
        location     %where the reward is delivered
        numRew       %the number of rewards to give
        rewDelayFun  %function which generates the reward event delays.
        s2rDelayFun  %function which generates the delay from the stimulus to teh reward
        
    end
    
    %hidden properties
    properties (Hidden = true)
        guiFigure
        evtDelay  %only populated when teh reward event is started
        
        RDelay  %only populated when teh reward event is started
        SDelay
        
        RTimer
        STimer 
        
        numRewCurrent = 0;  %lists the current rew that we are delivering
        %dispOpt = false;
    end
    
    properties (Dependent = true)
        status
    end
        
    %|<----invSDelay(1)--->S<--SDelay(1)--->| 
    %|<------------------------RDelay(1)--->R
    %                                       |<----invSDelay(2)--->S<--SDelay(2)--->| 
    %                                       |<------------------------RDelay(2)--->R
      
    
    
    methods
        
        %constructor
        function obj = rewEvt(guiFigure,location,odorID,odorDelay,odorDur,flushID,flushDur)
            
            obj.RTimer = timer('timerFcn',@(~,~)RTimerCallBack(obj));
            obj.STimer = timer('timerFcn',@(~,~)STimerCallBack(obj));         
         
            obj.guiFigure = guiFigure;  
            obj.location = location;

            %check the other input arguments, and if empty take them from
            %the gui
            
        end
        
        
        function RTimerCallBack(obj)
           handles = guidata(obj.guiFigure);
           
           %deliver the reward
           
           %start the reward timer for the next rew
           start(obj.RTimer);
           
           %start the stimulus timer
           start(obj.STimer);

        end
        
        function STimerCallBack(obj)
            handles = guidata(obj.guiFigure);
            
            %excute the stimulus items
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

