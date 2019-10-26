function feature=Feature_extract_filebased(varargin)
%memory

filename=varargin{1};
event_frame=varargin{2}; % sec
if nargin==3
    sel=varargin{3};
else
    sel=0;
end

DefaultSetting;
global fs;
global window_size;
global visible;

video_struct=importdata(['data\preprocessed_data\' filename '.mat']);
location=Tracking(video_struct.video1_foreground_masked(:,:,:),video_struct.video2_foreground_masked(:,:,:));
video_struct.location=location;

figure('visible',visible.Feature_extraction)
plot(1/fs:1/fs:1/fs*length(location.vertical_angle1),location.vertical_angle1); hold on;
plot(1/fs:1/fs:1/fs*length(location.vertical_angle1),location.vertical_angle2,'r');


vertical_angle1_globalpadded=globalpadding(video_struct.location.vertical_angle1);
horizontal_angle1_globalpadded=globalpadding(video_struct.location.horizontal_angle1);
vertical_angle2_globalpadded=globalpadding(video_struct.location.vertical_angle2);
horizontal_angle2_globalpadded=globalpadding(video_struct.location.horizontal_angle2);

% 
if sel==1
    video_struct.location.vertical_angle=location.vertical_angle1;
    video_struct.location.horizontal_angle=location.horizontal_angle1;
    video_struct.preprocessed_feature.vertical_angle_globalpadded=vertical_angle1_globalpadded;
    video_struct.preprocessed_feature.horizontal_angle_globalpadded=horizontal_angle1_globalpadded;
    video_struct.video_foreground_mask=video_struct.video1_foreground_mask;
elseif sel==2
    video_struct.location.vertical_angle=location.vertical_angle2;
    video_struct.location.horizontal_angle=location.horizontal_angle2;
    video_struct.preprocessed_feature.vertical_angle_globalpadded=vertical_angle2_globalpadded;
    video_struct.preprocessed_feature.horizontal_angle_globalpadded=horizontal_angle2_globalpadded;
    video_struct.video_foreground_mask=video_struct.video2_foreground_mask;
end

%}


if event_frame==0
    Feature_extraction(video_struct,1:size(video_struct.video1_foreground_masked,3));
    return
end

event_frame=floor(event_frame*fs); % frame (sec*fs) about the middle of the window size
start_frame=event_frame-0.5*fs*window_size+1;

for fallevent_ind=1:length(event_frame)
    frame_interval=start_frame(fallevent_ind):start_frame(fallevent_ind)+fs*window_size-1;
    
    % compare use which video
    if sel==0
        if video_select(video_struct,frame_interval)==1
            video_struct.location.vertical_angle=location.vertical_angle1;
            video_struct.location.horizontal_angle=location.horizontal_angle1;
            video_struct.preprocessed_feature.vertical_angle_globalpadded=vertical_angle1_globalpadded;
            video_struct.preprocessed_feature.horizontal_angle_globalpadded=horizontal_angle1_globalpadded;
            video_struct.video_foreground_mask=video_struct.video1_foreground_mask;
        elseif video_select(video_struct,frame_interval)==2
            video_struct.location.vertical_angle=location.vertical_angle2;
            video_struct.location.horizontal_angle=location.horizontal_angle2;
            video_struct.preprocessed_feature.vertical_angle_globalpadded=vertical_angle2_globalpadded;
            video_struct.preprocessed_feature.horizontal_angle_globalpadded=horizontal_angle2_globalpadded;
            video_struct.video_foreground_mask=video_struct.video2_foreground_mask;
        end
    end
    
    if fallevent_ind==1 % used to preallocate the memory for variable 'feature'
        feature_tmp=Feature_extraction(video_struct,frame_interval);
        feature=nan(length(event_frame),length(feature_tmp)); 
        feature(fallevent_ind,:)=feature_tmp;
        clear feature_tmp
        %evalin('caller','clear feature_tmp')
    else
        feature(fallevent_ind,:)=Feature_extraction(video_struct,frame_interval);
    end
    
end
clearvars -except feature
%clearvars
%evalin('caller','clearvars -except feature')
end % Feature_extract_filebased

function signal_padded=globalpadding(signal) % padding zero with last nonzero signal
global fs;
global visible;

%{
if signal(1)==0
    signal(1)=8.2;
end
%}

for frame=2:length(signal)
    if signal(frame)==0
        signal(frame)=signal(frame-1);
    end
end

signal_padded=signal;

%figure('name','global signal padding','numberTitle','off','Visible',visible.Feature_extraction)
%plot(1/fs:1/fs:1/fs*length(signal_padded),signal_padded)
end

% compare use which video
function sel=video_select(video_struct,frame_interval)
video1_foreground_mask=video_struct.video1_foreground_mask(:,:,frame_interval);
video2_foreground_mask=video_struct.video2_foreground_mask(:,:,frame_interval);

if sum(video1_foreground_mask(:))>=sum(video2_foreground_mask(:))
    sel=1;
else
    sel=2;
end

end
