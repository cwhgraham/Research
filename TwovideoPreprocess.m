clc;clear all;close all force; % add force to close implay window
%% Import File

filename=['20141101' '_' '0']; % date_whichtime
whichtime=filename(10:end);
filename1=[filename(1:8) '_' whichtime '_1']; % importdata
filename2=[filename(1:8) '_' whichtime '_2'];
serial_raw_data1=importdata(['data\sync_data\' filename1 '.txt']);
serial_raw_data2=importdata(['data\sync_data\' filename2 '.txt']);
%%
global fs;
fs=16;

angle1_bias=serial_raw_data1(1);
angle2_bias=serial_raw_data2(1);
distance=serial_raw_data1(2);

serial_raw_data1(1:2)=[]; % remove angle and distance information
serial_raw_data2(1:2)=[];

% change serial data to frame vs time
[pixel_raw1,Ta1]=serial2video(serial_raw_data1);
[pixel_raw2,Ta2]=serial2video(serial_raw_data2);

Signal_analysis=Csignal_analysis(fs);

pixel_tmp1=pixel_raw1;
pixel_tmp2=pixel_raw2;
%% Filter
i=2;
j=7;
t_i=[21 31];
t_i=[0 10];
Signal_analysis.freq_analysis(pixel_tmp1,i,j,t_i);
%Signal_analysis.freq_analysis(pixel_tmp2,i,j,t_i);

pixel_tmp1=spatial_filter(pixel_tmp1); % spatial filtering
pixel_tmp2=spatial_filter(pixel_tmp2); % spatial filtering

pixel_tmp1=time_filter(pixel_tmp1); % time domain filtering
pixel_tmp2=time_filter(pixel_tmp2); % time domain filtering
pixel1_filtered=pixel_tmp1;
pixel2_filtered=pixel_tmp2;
Signal_analysis.freq_analysis(pixel_tmp1,i,j,t_i);
%Signal_analysis.freq_analysis(pixel_tmp2,i,j,t_i);
%% Foreground
Foreground1=Cforeground(pixel_tmp1,Ta1,'Hold');
Hold_foreground1=Foreground1.foreground;
%Signal_analysis.freq_analysis(Hold_foreground1,i,j,t_i);
background1=Foreground1.lim_background;

Foreground2=Cforeground(pixel_tmp2,Ta2,'Hold');
Hold_foreground2=Foreground2.foreground;
%Signal_analysis.freq_analysis(Hold_foreground2,i,j,t_i);
background2=Foreground2.lim_background;


%Play_video=Cplay_video(pixel_tmp,Hold_foreground,Ta);
Play_video=Cplay_video(Hold_foreground1,Hold_foreground2,background1,background2);

%% Output processed video
video_out.video1_play=Play_video.video1_img; % for video playing
video_out.video2_play=Play_video.video2_img;
video_out.video1_foreground_masked=Hold_foreground1.*Foreground1.foreground_mask; % background=0, foreground is the raw data x mask
video_out.video2_foreground_masked=Hold_foreground2.*Foreground2.foreground_mask;

video_out.video1_foreground_mask=Foreground1.foreground_mask; % binary foreground mask
video_out.video2_foreground_mask=Foreground2.foreground_mask;
video_out.video1_foreground_unmasked=Hold_foreground1; % background~=Ta
video_out.video2_foreground_unmasked=Hold_foreground2;
video_out.video1_background=Foreground1.lim_background;
video_out.video2_background=Foreground2.lim_background;
video_out.video1_filtered=pixel1_filtered;
video_out.video2_filtered=pixel2_filtered;
video_out.Ta1=Ta1;
video_out.Ta2=Ta2;
video_out.video1_raw=pixel_raw1;
video_out.video2_raw=pixel_raw2;
video_out.twosensor_distance=distance;
video_out.sensor1_anglebias=angle1_bias;
video_out.sensor2_anglebias=angle2_bias;

%location=Tracking(video_out.video1_foreground_masked, video_out.video2_foreground_masked, video_out.sensor1_anglebias, video_out.sensor2_anglebias);
%location=Tracking(video_out.video1_foreground_mask,video_out.video2_foreground_mask);

%figure
%plot(squeeze(video_out.video1_background(2,7,:)))


%% Save .mat file
save(['data\preprocessed_data\' filename '.mat'],'video_out')

%{
clear Play_video;
filename=['20140920' '_' '1']; % date_whichtime
video_struct=importdata(['data\preprocessed_data\' filename '.mat']);
Play_video=Cplay_video(video_struct.video1_play,video_struct.video2_play);
Play_video.play([300 400]);
%}




%{
%Play_video.video2_img
video_binary=Play_video.video_binary*255+1;
writeVideo(Play_video.video2_img)
pixel_tmp=permute(video_binary,[1 2 4 3]); % change the order of dimension from 3d to 4d matrix
pixel_tmp=immovie(pixel_tmp,gray); % jet
implay(pixel_tmp,fs);
%}
