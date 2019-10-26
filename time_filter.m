function video_out=time_filter(video)
global fs;
i_length=size(video,1);
j_length=size(video,2);
frame_length=size(video,3);
%% IIR Notch filter
fstop=[3.2 3.42]; % stop band (Hz)
[b,a]=butter(2,fstop/(fs/2),'stop');
%figure
%freqz(b,a,512,fs) % 512 is default value
%{
for n=1:floor(length(w)/2)
    video_tmp=cat(3,video_tmp(:,:,1),video_tmp,video_tmp(:,:,end));
end
%}
for i=1:i_length
    for j=1:j_length
        %video_out(i,j,:)=filter(b,a,video(i,j,:));
        video_out(i,j,:)=filtfilt(b,a,video(i,j,:)); % zero face filter do not have delay after filter
        %video_out(i,j,:)=filter(w,1,video(i,j,:));
    end
end
%}

%% Moving average filter
%
w=[1 1 1]; % filter coefficient
w=w(:)/sum(w(:));
%figure
%freqz(w,1,512,fs)
 
% copy the start and the end of the frame data
% if not copy, the data would be go to zero after convolution at the start and the end of the data
video_tmp=video_out;
clear video_out
% expand the wave to prevent the 
for n=1:floor(length(w)/2)
    video_tmp=cat(3,video_tmp(:,:,1),video_tmp,video_tmp(:,:,end));
end

for i=1:i_length
    for j=1:j_length
        video_out(i,j,:)=conv(squeeze(video_tmp(i,j,:)),w);
        %video_out(i,j,:)=conv(squeeze(video(i,j,:)),w,'same');
    end
end
% cut the full convolution to the same length as original
if mod(length(w),2) % length(w) is odd
    video_out=video_out(:,:,floor(length(w)/2)+1+floor(length(w)/2):end-floor(length(w)/2)-floor(length(w)/2));
else % length(w) is even
    video_out=video_out(:,:,length(w)/2+1+floor(length(w)/2):end-length(w)/2+1-floor(length(w)/2));
% equal to conv(,'same')
%}
end