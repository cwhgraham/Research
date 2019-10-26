classdef Cforeground
    properties
        video;
        Ta;
        fs=16;
        
        video_img;
        
        foreground;
        foreground_mask;
        background;
        lim_background;
        std_background;
        mean_background;
        
    end
    properties (Access=private)
        Tb=20;
        var=6; % foreground background difference
    end
    methods
        function obj=Cforeground(varargin)
            switch nargin
                case 3 % video
                    obj.video=varargin{1};
                    obj.Ta=varargin{2};
                    
                    %%% ----- W4 -----%%%%%
                    if strcmp(varargin{3}, 'W4') % W4 foreground
                        % parameter
                        D_scale=3; % the more higher the more background
                        initial_background_time=10; % sec
                        Ntap=3*obj.fs;
                        
                        % stage 1 : pixelwise median filter to generate stationary pixels and excluding the moving pixels
                        for j=1:size(obj.video,2)
                            for i=1:size(obj.video,1)
                                video_tmp(i,j,:)=cat(3, ones(1,1,Ntap)*obj.video(i,j,1), obj.video(i,j,1:obj.fs*initial_background_time));
                                video_tmp(i,j,:)=cat(3, obj.video(i,j,1:obj.fs*initial_background_time) , ones(1,1,Ntap)*video_tmp(i,j,end));
                                
                                stationary_background(i,j,:)=medfilt1(video_tmp(i,j,:),Ntap);
                                
                                %stationary_background(i,j,:)=medfilt1(video(i,j,1:fs*initial_background_time),fs*2);
                            end
                        end
                        
                        stationary_background=stationary_background(:,:,floor(Ntap/2+1):end-floor(Ntap/2));
                        %size(stationary_background)
                        %plot(squeeze(stationary_background(1,1,:)))
    
                        % stage 2 : use stationary pixels to construct initial background model
                        for j=1:size(obj.video,2)
                            for i=1:size(obj.video,1)
                                % determine each pixel's minimum, maximum and maximum difference
                                m(i,j)=min(stationary_background(i,j,:)); % minimum
                                M(i,j)=max(stationary_background(i,j,:)); % maximum
                                for ind=1:length(stationary_background(i,j,:))-1
                                    D_tmp(ind)=abs(stationary_background(i,j,ind+1)-stationary_background(i,j,ind));
                                end
                                D(i,j)=max(D_tmp); % maximum difference
                            end
                        end
                        
                        % generate foreground
                        
                        %hold_time=0.2*obj.fs;
                        %count=zeros(size(obj.video,1),size(obj.video,2));
                        for j=1:size(obj.video,2)
                            for i=1:size(obj.video,1)
                                for frame=1:size(obj.video,3)
                                    if abs(m(i,j)-obj.video(i,j,frame))<D(i,j)*D_scale ...
                                       && abs(M(i,j)-obj.video(i,j,frame))<D(i,j)*D_scale % background
                                        obj.foreground(i,j,frame)=obj.Tb;
                                        %count(i,j)=0;
                                    else % foreground
                                        obj.foreground(i,j,frame)=obj.video(i,j,frame);
                                        %count(i,j)=count(i,j)+1;
                                    end
                                end
                            end
                        end
                    % end W4
                    
                    %%%%% ----- Ave ----- %%%%%
                    elseif strcmp(varargin{3}, 'Ave') % average foreground
                        % parameter
                        Ntap=3*obj.fs;
                        std_scale=0.7; % the more higher the more background
                        
                        t_end=Ntap;
                        
                        for frame=1:size(obj.video,3)
                            if frame<Ntap
                                t_interval=1:frame;
                            else
                                t_interval=t_end-Ntap+1:t_end;
                                t_end=t_end+1;
                            end
                            
                            for i=1:size(obj.video,1)
                                for j=1:size(obj.video,2)
                                    u(i,j,frame)=mean(obj.video(i,j,t_interval)); % mean in each pixel
                                    s=std(obj.video(i,j,t_interval),1); % standard deviation
                                    if abs(obj.video(i,j,frame)-u(i,j,frame))<std_scale*s
                                        obj.foreground(i,j,frame)=obj.Tb;
                                    else
                                        obj.foreground(i,j,frame)=obj.video(i,j,frame);
                                    end
                                end
                            end
                        end % end frame
                    % end Ave
                    
                    %%%%% ----- Hold ----- %%%%%
                    elseif strcmp(varargin{3}, 'Hold')
                        % parameter
                        hold_time=0.2*obj.fs; % the bigger this value, the low chance to detect higher speed
                        hold_time=3;
                        init_time=10; % sec
                        updata_rate=0.0001; % 20141010
                        
                        % Initialized background
                        % mean background
                        %init_time=obj.fs*init_time*0.5:obj.fs*init_time*1.5;
                        init_time=1:obj.fs*init_time;
                        obj.background(:,:,1)=mean(obj.video(:,:,init_time),3);
                        for i=1:size(obj.video,1)
                            for j=1:size(obj.video,2)
                                obj.std_background(i,j)=std(obj.video(i,j,init_time),1,3);
                            end
                        end

                        count=zeros(size(obj.video,1),size(obj.video,2));
                        for frame=1:size(obj.video,3)

                            for i=1:size(obj.video,1)
                                for j=1:size(obj.video,2)
                                    % background update
                                    if frame<=length(init_time)
                                        obj.background(:,:,frame)=obj.background(:,:,1);
                                        obj.std_background=obj.std_background;
                                    else
                                        %
                                        if obj.foreground_mask(i,j,frame-1)==1
                                            obj.background(i,j,frame)=obj.background(i,j,frame-1);
                                            obj.std_background(i,j)=obj.std_background(i,j);
                                        elseif obj.foreground_mask(i,j,frame-1)==0
                                            obj.background(i,j,frame)=(1-updata_rate)*obj.background(i,j,frame-1)+updata_rate*obj.video(i,j,frame);
                                            obj.std_background(i,j)=(1-updata_rate)*obj.std_background(i,j)+updata_rate*abs(obj.video(i,j,frame)-obj.background(i,j,frame-1));
                                        end
                                        %}
                                    end
                                    std_b(frame)=obj.std_background(2,7);
                                    
                                    obj.lim_background(i,j,frame)=obj.background(i,j,frame)+obj.std_background(i,j)*2.5;% *1, +0.5 %
                                    if obj.video(i,j,frame)>obj.lim_background(i,j,frame)
                                        count(i,j)=count(i,j)+1; % accumulate how much time the high temperature hold
                                    else
                                        count(i,j)=0;
                                    end
                                    
                                    if count(i,j)<hold_time % backround
                                        %obj.foreground(i,j,frame)=obj.Tb;
                                        obj.foreground(i,j,frame)=obj.lim_background(i,j,frame);
                                        obj.foreground_mask(i,j,frame)=0;
                                    else % foreground
                                        obj.foreground(i,j,frame)=obj.video(i,j,frame);
                                        obj.foreground_mask(i,j,frame)=1;
                                    end % end foreground   
                                end % end for j
                            end % end for i
							
							%% remove single pixel noise
                            for i=1:size(obj.video,1)
								for j=1:size(obj.video,2)
									if i==1
                                        if j==1
                                            if obj.foreground_mask(i+1,j,frame)+obj.foreground_mask(i,j+1,frame)==0
                                                obj.foreground(i,j,frame)=obj.lim_background(i,j,frame);
                                                obj.foreground_mask(i,j,frame)=0;
                                            end
                                        elseif j==size(obj.video,2)
                                            if obj.foreground_mask(i+1,j,frame)+obj.foreground_mask(i,j-1,frame)==0
                                                obj.foreground(i,j,frame)=obj.lim_background(i,j,frame);
                                                obj.foreground_mask(i,j,frame)=0;
                                            end
                                        else 
                                            if obj.foreground_mask(i+1,j,frame)+obj.foreground_mask(i,j-1,frame)+obj.foreground_mask(i,j+1,frame)==0
                                                obj.foreground(i,j,frame)=obj.lim_background(i,j,frame);
                                                obj.foreground_mask(i,j,frame)=0;
                                            end
                                        end
                                    elseif i==size(obj.video,1)
                                        if j==1
                                            if obj.foreground_mask(i-1,j,frame)+obj.foreground_mask(i,j+1,frame)==0
                                                obj.foreground(i,j,frame)=obj.lim_background(i,j,frame);
                                                obj.foreground_mask(i,j,frame)=0;
                                            end
                                        elseif j==size(obj.video,2)
                                            if obj.foreground_mask(i-1,j,frame)+obj.foreground_mask(i,j-1,frame)==0
                                                obj.foreground(i,j,frame)=obj.lim_background(i,j,frame);
                                                obj.foreground_mask(i,j,frame)=0;
                                            end
                                        else
                                            if obj.foreground_mask(i-1,j,frame)+obj.foreground_mask(i,j-1,frame)+obj.foreground_mask(i,j+1,frame)==0
                                                obj.foreground(i,j,frame)=obj.lim_background(i,j,frame);
                                                obj.foreground_mask(i,j,frame)=0;
                                            end
                                        end
                                    else % i=2,3
                                        if j==1
                                            if obj.foreground_mask(i-1,j,frame)+obj.foreground_mask(i+1,j,frame)+obj.foreground_mask(i,j+1,frame)==0
                                                obj.foreground(i,j,frame)=obj.lim_background(i,j,frame);
                                                obj.foreground_mask(i,j,frame)=0;
                                            end
                                        elseif j==size(obj.video,2)
                                            if obj.foreground_mask(i-1,j,frame)+obj.foreground_mask(i+1,j,frame)+obj.foreground_mask(i,j-1,frame)==0
                                                obj.foreground(i,j,frame)=obj.lim_background(i,j,frame);
                                                obj.foreground_mask(i,j,frame)=0;
                                            end
                                        else
                                            if obj.foreground_mask(i-1,j,frame)+obj.foreground_mask(i+1,j,frame)+obj.foreground_mask(i,j-1,frame)+obj.foreground_mask(i,j+1,frame)==0
                                                obj.foreground(i,j,frame)=obj.lim_background(i,j,frame);
                                                obj.foreground_mask(i,j,frame)=0;
                                            end
                                        end
									end
                                end % end for j
                            end % end for i
                        end % end for frame
                        
                        figure
                        subplot(211)
                        plot(1/obj.fs:1/obj.fs:1/obj.fs*size(obj.video,3),squeeze(obj.background(2,7,:)))
                        title('Mean background')
                        subplot(212)
                        plot(1/obj.fs:1/obj.fs:1/obj.fs*size(obj.video,3),std_b)
                        title('Std background')
                    % end Hold
                    else
                        error('can not find any name fit the foreground method!')
                    end
                otherwise
                    error('Wrong input arguements with class constructor!')
            end % end switch
        end % end constructor function
        function background=gen_background(obj)
            
        end
    end % end methods
end