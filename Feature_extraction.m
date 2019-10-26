function feature=Feature_extraction(video_struct,frame_interval)
%clc;clear all;close all;
global fs;fs=16;
DefaultSetting;
global visible;

if frame_interval==0
    frame_interval=(1:size(video_struct.video1_foreground_masked,3))
end

%location=Tracking(video_struct.video1_foreground_masked(:,:,frame_interval),video_struct.video2_foreground_masked(:,:,frame_interval));
location=video_struct.location; % original not padded location 

%% Padding
% global padding
vertical_angle_globalpadded=video_struct.preprocessed_feature.vertical_angle_globalpadded(frame_interval);
horizontal_angle_globalpadded=video_struct.preprocessed_feature.horizontal_angle_globalpadded(frame_interval);

for frame=1:length(vertical_angle_globalpadded)-1
    ver_gslope(frame)=vertical_angle_globalpadded(frame+1)-vertical_angle_globalpadded(frame);
end
ver_gslope=sum(ver_gslope)/length(ver_gslope);

for frame=1:length(horizontal_angle_globalpadded)-1
    hor1_gv(frame)=abs(horizontal_angle_globalpadded(frame+1)-horizontal_angle_globalpadded(frame));
end
hor1_gv=sum(hor1_gv)/length(hor1_gv);

% local padding
vertical_angle_localpadded=localpadding(location.vertical_angle(frame_interval));
horizontal_angle_localpadded=localpadding(location.horizontal_angle(frame_interval));

for frame=1:length(vertical_angle_localpadded)-1
    ver_lslope(frame)=vertical_angle_localpadded(frame+1)-vertical_angle_localpadded(frame);
end
ver_lslope=sum(ver_lslope)/length(ver_lslope);

for frame=1:length(horizontal_angle_localpadded)-1
    hor_lv(frame)=abs(horizontal_angle_localpadded(frame+1)-horizontal_angle_localpadded(frame));
end
hor_lv=sum(hor_lv)/length(hor_lv);

for frame=1:length(horizontal_angle_localpadded)-1
    hor_lvdir(frame)=horizontal_angle_localpadded(frame+1)-horizontal_angle_localpadded(frame);
end
hor_lvdir=abs(sum(hor_lvdir)/length(hor_lvdir));

% Mean absolute standard deviation
MAD_v=mean(abs(vertical_angle_localpadded-mean(vertical_angle_localpadded)));
MAD_h=mean(abs(horizontal_angle_localpadded-mean(horizontal_angle_localpadded)));

std_absdiff_v=std(abs(vertical_angle_localpadded-mean(vertical_angle_localpadded)));
std_absdiff_h=std(abs(horizontal_angle_localpadded-mean(horizontal_angle_localpadded)));

proj=projection_histogram(video_struct.video_foreground_mask(:,:,frame_interval));
proj.width=localpadding(proj.width);
for frame=1:length(proj.width)-1
    vertical_proj(frame)=proj.width(frame+1)-proj.width(frame);
end
vertical_proj=sum(vertical_proj);

feature=[ver_lslope hor_lvdir hor_lv vertical_proj MAD_v MAD_h ver_gslope hor1_gv std_absdiff_v std_absdiff_h min(vertical_angle_localpadded) std(vertical_angle_localpadded,1) std(horizontal_angle_localpadded,1)];

end % end Feature_extraction


function vertical_filtered=vertical_track(vertical_angle) % caluculate slope of vertical angle before fall
global fs;

vertical_filtered=vertical_filter(vertical_angle);


% detect object disappear
frame=1;
event=NaN(1,length(vertical_filtered));
while frame<=length(vertical_filtered)
    if vertical_filtered(frame)>0 % have object
        
        frame=frame+1;
        while vertical_filtered(frame)>0
            vertical.slope(frame)=vertical_filtered(frame)-vertical_filtered(frame-1);
            frame=frame+1;
            if frame>numel(vertical_filtered)
                break;
            end
        end
        
        %event(frame)=1; % record the event frame
        
        slope_sum=0;
        for ind=1:4 % how many sample slope to sum
            slope_sum=slope_sum+vertical_filtered(frame-ind)-vertical_filtered(frame-(ind+1));
        end
        
        event(frame)=slope_sum; % record the event frame
        
    else
        frame=frame+1;
    end % end if
end % end while
%{
figure('name','Vertical track after low pass filter','numberTitle','off')
plot(1/fs:1/fs:1/fs*length(vertical_filtered),vertical_filtered); hold on;
plot(1/fs:1/fs:1/fs*length(event),event,'r*')

figure('name','Vertical track slope after low pass filter','numberTitle','off')
plot(1/fs:1/fs:1/fs*length(vertical.slope),vertical.slope);
%}
    function  data_out=vertical_filter(data_in) % low pass filter for vertical track
    
    fcutoff=2; % Hz
    [b,a]=butter(2,fcutoff/(fs/2),'high'); % butterworth high-pass filter
    
    fcutoff=3; % Hz
    [b,a]=butter(2,fcutoff/(fs/2),'low'); % butterworth low-pass filter
    %figure
    %freqz(b,a,512,fs) % 512 is default value
    
    filt_en=0;
    ind=1;
    max(length(b),length(a));
    for frame=1:length(data_in)
        
        if data_in(frame)~=0 % have object
            filt_temp(ind)=data_in(frame);
            filt_en=1;
            ind=ind+1;
            if frame==length(data_in)
                if ind>=max(length(b),length(a))*2+2 % data length must more than filter order for filtering
                    %x=filter(b,a,filt_temp); % normal filter
                    x_z=filtfilt(b,a,filt_temp); % zero phase filter (no nonlinear phase distortion and delay of the filter)
                    data_out(frame-length(filt_temp)+1:frame)=x_z;
                else % data is not enough for filter
                    data_out(frame-(ind-1)+1:frame)=zeros(1,ind-1);
                end
                ind=1;
            end
        else % no object
            if filt_en==1 % filter 
                if ind>=max(length(b),length(a))*2+2 % data length must more than filter order for filtering
                    %x=filter(b,a,filt_temp); % normal filter
                    x_z=filtfilt(b,a,filt_temp); % zero phase filter (no nonlinear phase distortion and delay of the filter)
                    data_out(frame-length(filt_temp):frame-1)=x_z;
                else % data is not enough for filter
                    data_out(frame-(ind-1):frame-1)=zeros(1,ind-1);
                end
                clear filt_temp;
                %filt_en=0;
            end
            ind=1;
            data_out(frame)=0;
        end
    end % end for frame
    %{
    figure
    plot(1/fs:1/fs:1/fs*length(data_in),data_in,'g'); hold on;
    plot(1/fs:1/fs:1/fs*length(data_out),(data_out),'r')
    %}
    end % end vertical filter
end % end vertical_velocity

function horizontal_velocity(horizontal_angle)
global fs;
global visible;

horizontal_v=zeros(1,length(horizontal_angle));
for frame=2:length(horizontal_angle)
    if horizontal_angle(frame)==0 || horizontal_angle(frame-1)==0
        horizontal_v(frame)=0;
    else
        horizontal_v(frame)=horizontal_angle(frame)-horizontal_angle(frame-1);
    end
end % end frame

figure('name','Horizontal velocity','numberTitle','off','Visible',visible.Feature_extraction)
plot(1/fs:1/fs:1/fs*length(horizontal_v),horizontal_v)
end % end horizontal_velocity

function track_velocity(x,y)
global fs;

for frame=2:length(x)
    if isnan(x(frame)) || isnan(x(frame-1))
        track_v(frame)=0;
    else
        track_v(frame)=sqrt((x(frame)-x(frame-1))^2+(y(frame)-y(frame-1))^2);
    end
end
track_v_tmp=track_v;

track_v=moving_average(track_v_tmp);

figure('name','Tracking velocity','numberTitle','off','Visible',visible.Feature_extraction)
plot(1/fs:1/fs:1/fs*length(track_v),track_v)

    function  data_out=moving_average(data_in) % low pass filter for vertical track
    
    b=ones(1,4)/4;
    a=1;
    %figure
    %freqz(b,a,512,fs) % 512 is default value
    
    filt_en=0;
    ind=1;
    max(length(b),length(a));
    for frame=1:length(data_in)
        
        if data_in(frame)~=0 % have object
            filt_temp(ind)=data_in(frame);
            filt_en=1;
            ind=ind+1;
        else % no object
            if filt_en==1 % filter 
                if ind>=max(length(b),length(a))*2+2 % data length must more than filter order for filtering
                    %x=filter(b,a,filt_temp); % normal filter
                    x_z=filtfilt(b,a,filt_temp); % zero phase filter (no nonlinear phase distortion and delay of the filter)
                    data_out(frame-length(filt_temp):frame-1)=x_z;
                else % data is not enough for filter
                    data_out(frame-(ind-1):frame-1)=zeros(1,ind-1);
                    
                end
                clear filt_temp;
                filt_en=0;
            end
            ind=1;
            data_out(frame)=0;
        end
    end % end for frame
    %{
    figure
    plot(1/fs:1/fs:1/fs*length(data_in),data_in,'g'); hold on;
    plot(1/fs:1/fs:1/fs*length(data_out),(data_out),'r')
    %}
    end % end moving_average


end % end track velocity

function object=object_detection(horizontal_angle1,horizontal_angle2)
global fs;
global visible;

% detect object
object.detected=zeros(1,length(horizontal_angle1));
ind=find(horizontal_angle1+horizontal_angle2); % locates all nonzero elements of array (i.e. detect object)
object.detected(ind)=1;

% object filter for removing noise
% remove the object detected time which is smaller than 1 sec
frame=1;count=0;
object.event=nan(1,length(object.detected));
while frame<=length(object.detected)
    if object.detected(frame)==1
        count=count+1;
    else
        if count<fs*1 % delete the object that suddenly appear
            object.detected(frame-count:frame-1)=0;
        else
            object.event(frame-1)=1;
        end
        count=0;
    end
    frame=frame+1;
end

figure('name','Object Detection','numberTitle','off','Visible',visible.Feature_extraction)
plot(1/fs:1/fs:1/fs*length(object.detected),object.detected)
hold on
plot(1/fs:1/fs:1/fs*length(object.event),object.event,'r*')
ylim([-0.1 1.1])
end % object_detection

function data_out=removenulldata(data_in)
ind=find(data_in==0);
data_in(ind)=[];
data_out=data_in;
end

function proj=projection_histogram(video_mask)

for frame=1:size(video_mask,3)
    proj.ver(frame,:)=sum(video_mask(:,:,frame),1); % vertical projection
    proj.hor(:,frame)=sum(video_mask(:,:,frame),2); % horizontal projection
    
    proj.width(frame)=numel(find(proj.ver(frame,:)>0));
    proj.height(frame)=numel(find(proj.hor(:,frame)>0));
    
    %proj.max_height(frame)=0;
    
    if proj.height(frame)>0
        proj.max_height(frame)=find(proj.hor(:,frame)>0,1,'first');
    else
        proj.max_height(frame)=0;
    end
end


%figure
%plot(proj.max_height)

end

function angletrack_filtered=andglefilter(angletrack)
global fs;

% low pass filter
%fcutoff=3; % Hz
%[b,a]=butter(2,fcutoff/(fs/2),'low'); % butterworth low-pass filter
%a=[1,-1.72377617276251,0.757546944478829];
%b=[0.00844269292907995,0.0168853858581599,0.00844269292907995];

b=ones(1,7)/7;
a=1;

figure
freqz(b,a,512,fs) % 512 is default value

angletrack_filtered=filtfilt(b,a,angletrack);
figure
plot(angletrack_filtered)



fft_signal=abs(fft(angletrack));

NFFT=length(fft_signal);
fft_signal=fft_signal(1:ceil(length(fft_signal)/2));
freq_axis=1:length(fft_signal);
freq_axis=(fs/NFFT)*(freq_axis-1);

figure('name','FFT','numberTitle','off')
plot(freq_axis,fft_signal)


end

function localsignal_padded=localpadding(localsignal) % padding zero with last nonzero signal
global fs;
global visible;

% pad the begining zeros with the first nonzero value
ind=find(localsignal~=0,1,'first');
if numel(ind)>0
    localsignal(1:ind)=localsignal(ind);
end

% pad zero with the last value
for frame=2:length(localsignal)
    if localsignal(frame)==0
        localsignal(frame)=localsignal(frame-1);
    end
end

localsignal_padded=localsignal;

figure('name','local signal padding','numberTitle','off','Visible',visible.Feature_extraction)
plot(1/fs:1/fs:1/fs*length(localsignal_padded),localsignal_padded)
end

