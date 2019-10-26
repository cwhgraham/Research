
classdef Csignal_analysis
    properties
        fs=16;
        %video;
    end
    methods
        function obj=Csignal_analysis(fs)
            %obj.video=video;
            obj.fs=fs;
        end
        
        function freq_analysis(obj,video,i,j,time_interval) % time_interval is where we want obeserve
            time_interval=(time_interval(1)*obj.fs:time_interval(2)*obj.fs)+1;
            
            % video pixel vs time
            time_axis=1/obj.fs:1/obj.fs:1/obj.fs*size(video,3);
            figure('name','Frequency Analysis')
            subpt1_h=subplot(311);
            plot(time_axis,squeeze(video(i,j,1:size(video,3))))
            y_lim=get(subpt1_h,'ylim');
            hold on
            
            time_interval_h=fill([time_interval(1)/obj.fs time_interval(1)/obj.fs time_interval(end)/obj.fs time_interval(end)/obj.fs], ... 
                 [y_lim(1) y_lim(2) y_lim(2) y_lim(1)],'y');
            set(time_interval_h,'facealpha',.5)
            set(time_interval_h,'EdgeColor','none')
            
            ylim([y_lim(1) y_lim(2)])
            xlabel('time(sec)')
            ylabel('degree')
            title(sprintf('(%d,%d) pixel vs time',i,j))
            
            % Autocorrelation
            pixel_time=squeeze(video(i,j,time_interval))-mean(squeeze(video(i,j,time_interval)));
            autocorrelation=xcorr(pixel_time,'coeff');
            autocorrelation=autocorrelation((length(autocorrelation)+1)/2:length(autocorrelation));
            
            subplot(312)
            plot(0:1/obj.fs:1/obj.fs*(length(autocorrelation)-1),autocorrelation)
            xlabel('delay(sec)')
            title('Autocorrelation')
            
            % Fourier Transform
            win=hann(length(pixel_time));
            pixel_time_w=pixel_time.*win;
            N_FFT=length(pixel_time_w);
            fft_pixel_time=abs(fft(pixel_time_w));
            freq_axis=1:ceil(length(fft_pixel_time)/2);
            fft_pixel_time=fft_pixel_time(freq_axis);
            freq_axis=(obj.fs/N_FFT)*(freq_axis-1);
            
            subplot(313)
            plot(freq_axis,fft_pixel_time)
            title('Fourier Transfrom')
            xlabel('frequency (Hz)')
            
            %{
            figure
            plot(1/obj.fs:1/obj.fs:1/obj.fs*16*40,squeeze(video(i,j,1:obj.fs*40))-6)
            xlabel('Time(s)','fontsize',12)
            ylabel('Temperature( ^\circC)','fontsize',12)
            set(gca,'fontsize',12)
            ylim([24 32])
            %title('(a)','fontsize',12)
            %title('pixel(x,y) vs time','fontsize',14)
            
            ind=1;
            for i=1:4
                for j=1:16
                    variance(ind)=var(squeeze(video(i,j,1:obj.fs*20)));
                    ind=ind+1;
                end
            end
            variance=mean(variance)
            %}
        end % end freq_analysis()
        
        function [track dist]=tracking(obj,video) % this video with min 0
            track=zeros(1,size(video,3));
            dist=zeros(1,size(video,3));
            dist_1=zeros(1,size(video,3));
            dist_2=zeros(1,size(video,3));
            degree=60/size(video,2)*(1:size(video,2))-0.5*60/size(video,2);
            
            for frame=1:size(video,3)
                %obj.position(frame)=location(obj,squeeze(video2_img(:,:,frame)));
                
                for i=1:size(video,1)
                    for j=1:size(video,2)
                        if video(i,j,frame)<=0
                            video(i,j,frame)=0;
                        else
                            dist_1(frame)=dist_1(frame)+1;
                        end
                        dist_2(frame)=dist_2(frame)+video(i,j,frame);
                    end
                    track(frame)=track(frame)+video(i,:,frame)*degree(1:size(video,2))'; % position
                end
                
                dist(frame)=dist_1(frame)*0.2+dist_2(frame)*0.8;
                
                if track(frame)~=0
                    track(frame)=track(frame)/sum(reshape(video(:,:,frame),1,[]));
                else
                    track(frame)=0;
                end
            end
        end
        
        function v=velocity(obj,video)
            v=zeros(1,size(video,3));
            max_T=zeros(1,size(video,3));
            for frame=1:size(video,3)
                for i=1:size(video,1)
                    v_tmp(i)=sum(squeeze(video(i,:,frame)));
                    v_c(i,frame)=v_tmp(i);
                end
                
                [row column]=find(max(max(squeeze(video(:,:,frame)))));
                if numel(row)>0
                row=row(1);column=column(1);
                max_T(frame)=sum(sum(squeeze(video(:,:,frame))));
                end
                
                for ii=4:-1:2
                    v(frame)=v(frame)+v_tmp(ii)-v_tmp(ii-1);
                end
                m(frame)=max(max(video(:,:,frame)));
            end
            %
            fig=figure;
            subplot(311)
            for i=1:size(video,1)
                plot(1/obj.fs:1/obj.fs:1/obj.fs*size(video,3),v_c(i,:))
                
                Legend{i}=sprintf('i=%d',i);
                %Legend{i}=['i=' num2str(i)];
                hold all % draw different color and hold on
            end
            title('number of foreground in each row')
            legend(Legend(:)) % must column style
            sub2=subplot(312);
            plot(1/obj.fs:1/obj.fs:1/obj.fs*size(video,3),m)
            title('max temperature of foreground')
            
            subplot(313)
            plot(max_T)
            title('sum of foreground temperature')
            
            %sequence_segment(sub2);
            
            %}
        end % end velocity()
    end % end methods
end % end classdef