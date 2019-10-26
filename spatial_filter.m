function filtered_video=spatial_filter(video)
% spatial filter coefficient
w=[0 2 0; ...
   2 8 2; ...
   0 2 0];
w=w./sum(w(:)); % in order to eliminate the divide calculation

i_length=size(video,1);
j_length=size(video,2);
frame_length=size(video,3);

video_tmp=zeros(i_length+2,j_length+2,frame_length);
% replicating rows and columns on borders
video_tmp(1,2:j_length+1,:)=video(1,:,:);
video_tmp(end,2:j_length+1,:)=video(end,:,:);
video_tmp(2:i_length+1,1,:)=video(:,1,:);
video_tmp(2:i_length+1,end,:)=video(:,end,:);
video_tmp(2:i_length+1,2:j_length+1,:)=video; % copy the video
video_tmp(1,1,:)=video(1,1,:); % video_tmp top left corner
video_tmp(1,end,:)=video(1,end,:); % video_tmp top right corner
video_tmp(end,1,:)=video(end,1,:); % video_tmp down left corner
video_tmp(end,end,:)=video(end,end,:); % video_tmp down right corner


for frame=1:frame_length
    for i=1:i_length
        for j=1:j_length
            g=w.*video_tmp(i:i+2,j:j+2,frame);
            
            filtered_video(i,j,frame)=sum(g(:)); % in original : sum(g(:))/sum(w(:))
        end
    end
end

end