% play video
classdef Cplay_video
    properties
        video1;
        video2;
        Ta;
        background;
        To;
        video_binary;
        
        background1;
        background2;
        
        track;
        velocity;
        
        video1_img;
        video2_img;
    end
    properties (Access=private)
        fs=16;
        map='gray'; % colormap
        %map='default';
        var=6; % temperature variation
        Ta_low=1; %04190 1.5 04191 0
        
        
    end
    methods 
        % constructors
        function obj = Cplay_video(varargin)
            switch nargin % number of input arguments
                case 2 % video1_img, video2_img
                    obj.video1_img=varargin{1};
                    obj.video2_img=varargin{2};
                case 3 % video1, video2, background/Ta
                    if length(size(varargin{3}))==3 % background
                        obj.video1=varargin{1};
                        obj.video2=varargin{2};
                        obj.background=varargin{3};%+1
                        
                        
                        
                        for frame=1:size(obj.video1,3)
                            obj.video1_img(:,:,frame)=(obj.video1(:,:,frame)-obj.background(:,:,frame))./obj.var;
                            obj.video2_img(:,:,frame)=(obj.video2(:,:,frame)-obj.background(:,:,frame))./obj.var;
                            
                            %
                            for i=1:size(obj.video1,1)
                                for j=1:size(obj.video1,2)
                                    if obj.video2_img(i,j,frame)<=0
                                        obj.video_binary(i,j,frame)=0;
                                        obj.video2_img(i,j,frame)=0;
                                    else
                                        obj.video_binary(i,j,frame)=1;
                                    end
                                end
                            end
                            %}
                            %obj.To(frame)=max(max(obj.video2_img(:,:,frame)));
                        end
                    end
                case 4 % video1, video2, background1, background2
                    obj.video1=varargin{1};
                    obj.video2=varargin{2};
                    obj.background1=varargin{3};%+1
                    obj.background2=varargin{4};
                    
                    for frame=1:size(obj.video1,3)
                        obj.video1_img(:,:,frame)=(obj.video1(:,:,frame)-obj.background1(:,:,frame))./obj.var;
                        obj.video2_img(:,:,frame)=(obj.video2(:,:,frame)-obj.background2(:,:,frame))./obj.var;
                            
                        %
                        for i=1:size(obj.video1,1)
                            for j=1:size(obj.video1,2)
                                if obj.video1_img(i,j,frame)<=0
                                    obj.video1_img(i,j,frame)=0;
                                end
                                if obj.video2_img(i,j,frame)<=0
                                    obj.video2_img(i,j,frame)=0;
                                end
                            end
                        end
                        %}
                        %obj.To(frame)=max(max(obj.video2_img(:,:,frame)));
                    end
                otherwise
                    error('Wrong input arguements with class constructor!')
            end % end switch
        end % end constructor
        %
        function play(obj,varargin)
            if ~isempty(varargin)
                t_interval=varargin{1}; % [t_start t_end] sec
                t_start=t_interval(1);t_end=t_interval(2);
                %t_start=varargin{1}
                %t_end=varargin{2}
                if t_start*obj.fs>size(obj.video1_img,3)
                    t_start=size(obj.video1_img,3);
                else
                    t_start=t_start*obj.fs;
                end
                
                if t_end*obj.fs>size(obj.video1_img,3)
                    t_end=size(obj.video1_img,3);
                else
                    t_end=t_end*obj.fs;
                end
             else
                t_start=1;
                t_end=size(obj.video1_img,3);
            end
            
            screensize=get(0,'ScreenSize');
            
            figure('name','video_comparison','numberTitle','off','position',[screensize(1)+20 screensize(2)+100 floor(screensize(3)/2)-100 floor(screensize(4)/2)-20]) % [x y width height]
            subv1_h(1)=subplot(211);
            image_handle1=image(zeros(size(obj.video1_img,1),size(obj.video1_img,2)),'EraseMode','none','CDataMapping','scaled');
            colormap(obj.map)
            set(gca,'Clim',[0,1]) % set the color limit value
            % Data values in between are linearly interpolated across the colormap, while data values outside are clamped to either the first or last colormap color.
            xlabel('60 degree')
            ylabel('15 degree')
            
            subv2_h(2)=subplot(212);
            image_handle2=image(zeros(size(obj.video1_img,1),size(obj.video1_img,2)),'EraseMode','none','CDataMapping','scaled');
            colormap(obj.map)
            set(gca,'Clim',[0,1]) % set the color limit value
            xlabel('60 degree')
            ylabel('15 degree')
            %{
            figure('name','video2 surface','numberTitle','off')
            surf_h=surf('ZData',zeros(size(obj.video1,1),size(obj.video1,2)));
            zlim([-0.5 1.5])
            %}
            if ~isempty(obj.track),
                figure('name','Tracking','numberTitle','off')
                plot(obj.track,1/obj.fs:1/obj.fs:1/obj.fs*size(obj.video1_img,3),'b*','MarkerSize',4);
                ylim([1/obj.fs 1/obj.fs*size(obj.video1_img,3)])
                xlim([0 60])
                ylabel('Time(sec)')
                xlabel('degree')
                title('Tracking')
                
                hold on
                track_h=plot(obj.track(1),'r*','EraseMode','none','MarkerSize',4);
            end
            
			if ~isempty(obj.velocity),
                figure('name','Velocity','numberTitle','off')
                plot(1/obj.fs:1/obj.fs:1/obj.fs*size(obj.video1_img,3),obj.velocity,'b');
                xlim([1/obj.fs 1/obj.fs*size(obj.video1_img,3)])
                ylim([-4 4])
                xlabel('Time(sec)')
                ylabel('Velocity')
                title('Velocity')
                
                hold on
                velocity_h=plot(obj.velocity(1),'r','EraseMode','none');
            end
            
            %{
            videoobj=VideoWriter('test.avi');
            videoobj.Quality = 100;
            videoobj.FrameRate=16;
            open(videoobj);
            %}
            %videoobj = avifile('test.avi', 'fps',16);
            
            
            %for frame=1:size(obj.video1_img,3)
            for frame=t_start:t_end
                
                set(image_handle1,'CData',obj.video1_img(:,:,frame))
                %title(subv1_h(1),sprintf('To = %.2f degree\nTime = %.2f sec', max(max(obj.video1(:,:,frame))), frame/obj.fs ))
                title(subv1_h(1),sprintf('Time = %.2f sec', frame/obj.fs ))
                
                set(image_handle2,'CData',obj.video2_img(:,:,frame))
                %title(subv2_h(2),sprintf('To = %.2f degree\nTime = %.2f sec', max(max(obj.video2(:,:,frame))), frame/obj.fs ))
                title(subv2_h(2),sprintf('Time = %.2f sec', frame/obj.fs ))
                
                %axes(subv2_h(2))
                %writeVideo(videoobj,getframe);
                %videoobj = addframe(videoobj, getframe(gca));
                %set(surf_h,'ZData',obj.video2_img(:,:,frame))
                
                if frame>2
				    if ~isempty(obj.track),
                        set(track_h,'XData',obj.track(frame),'YData',1/obj.fs*frame)
                    end
				    
                    if ~isempty(obj.velocity),
                        set(velocity_h,'XData',[1/obj.fs*(frame-1) 1/obj.fs*frame],'YData',[obj.velocity(frame-1) obj.velocity(frame)])
                    end
                end
                %M(frame)=getframe;
                drawnow
                pause(1/obj.fs/2)
            end 
            %close(videoobj);
            %videoobj=close(videoobj);
        end % end play(ogj)
         
        function track=location(obj,imag)
            track=0;
            for i=1:size(imag,1)
                for j=1:size(imag,2)
                    if imag(i,j)<=0
                        imag(i,j)=0;
                    end
                end
                track=track+imag(i,:)*(1:size(imag,2))';
            end
            
            if track~=0
                track=track/sum(imag(:));
            else
                track=0;
            end
        end
        %}
        function image_strength(obj)
            
        end
    end % end methods
end % end classdef
