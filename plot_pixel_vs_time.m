function [mean_out std_out]=plot_pixel_vs_time(video)
global fs;
time_interval=[0 10]; % sec
time_interval=(time_interval(1)*fs:time_interval(2)*fs)+1;

i=2;
j=4;

% pixel vs time
time_axis=1/fs:1/fs:1/fs*size(video,3);
figure
subplot(211)
plot(time_axis,squeeze(video(i,j,1:size(video,3))))
xlabel('time(sec)')
ylabel('degree')

% autocorrelation
pixel_time=squeeze(video(i,j,time_interval))-mean(squeeze(video(i,j,time_interval)));
autocorrelation=xcorr(pixel_time,'coeff');
autocorrelation=autocorrelation((length(autocorrelation)+1)/2:length(autocorrelation));
subplot(212)
plot(0:1/fs:1/fs*(length(autocorrelation)-1),autocorrelation)
xlabel('delay(sec)')
title('autocorrelation')
%plot(autocorr(squeeze(video(i,j,1:size(video,3)))))

% standard deviation
for i=1:size(video,1)
    for j=1:size(video,2)
        std_out(i,j)=std(video(i,j,time_interval),1,3);
        mean_out(i,j)=mean(video(i,j,time_interval),3);
    end
end


end