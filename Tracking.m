function location=Tracking(video1,video2)
%close all;
global fs;
%global visible_control;visible_control='off';
DefaultSetting;
global visible;
global d;
global sensor1;
global sensor2;
global angle1_bias;
global angle2_bias;
%% Calculate the measured position

d=3.3; % distance between two sensor
sensor1.x=0; sensor1.y=0;
sensor2.x=-d; sensor2.y=0;

angle1_bias=60; % theta1 is the bias between the wall and the orientation of the sensor
angle2_bias=30;


location=Angle2Position(video1,video2,sensor1,sensor2,angle1_bias,angle2_bias);

%
figure('name','Tracking','numberTitle','off','Visible',visible.Tracking)
subplot(222) % right up
plot(location.horizontal_angle1,1/fs:1/fs:1/fs*size(video1,3),'b*','MarkerSize',4);
ylim([1/fs 1/fs*size(video1,3)])
xlim([0 60])
ylabel('Time(sec)')
xlabel('degree')
title('Tracking (horizontal)')

subplot(224) % right down
plot(location.vertical_angle1,1/fs:1/fs:1/fs*size(video1,3),'b*','MarkerSize',4);
ylim([1/fs 1/fs*size(video1,3)])
xlim([0 16.4])
ylabel('Time(sec)')
xlabel('degree')
title('Tracking (vertical)')

subplot(221) % left up
plot(location.horizontal_angle2,1/fs:1/fs:1/fs*size(video1,3),'b*','MarkerSize',4);
ylim([1/fs 1/fs*size(video1,3)])
xlim([0 60])
ylabel('Time(sec)')
xlabel('degree')
title('Tracking (horizontal)')

subplot(223) % left down
plot(location.vertical_angle2,1/fs:1/fs:1/fs*size(video1,3),'b*','MarkerSize',4);
ylim([1/fs 1/fs*size(video1,3)])
xlim([0 16.4])
ylabel('Time(sec)')
xlabel('degree')
title('Tracking (vertical)')
%
figure
plot(1/fs:1/fs:1/fs*size(video1,3),location.horizontal_angle2,'b*','MarkerSize',4);
xlim([27.8 60])
ylim([0.5 60])
ylabel('Angle (degree)')
xlabel('Time (sec)')

x_lim=[sensor2.x sensor1.x];
y_lim=[-5 sensor1.y];
m=tand(-(90-(angle2_bias-30)));
interval=floor(fs*10:size(video1,3));
interval=floor(fs*25.5:fs*42.5); % 25.5:42.5 for 20140822_6 s«¬

%% Predict the corrected tracking
%[mdl_x mdl_y]=Tracking_Regression_Model
load('data\tracking_regression_model\tracking_regression_model2.mat'); % load tracking model mdl_x, mdl_y
%mdl_x
%anova(mdl_x,'summary')
%mdl_y
%surface(predict(mdl_x,[(0:-0.01:-3)' (-1:-0.01:-4)']),predict(mdl_y,(-1:-0.01:-4)'))
location.x_re=predict(mdl_x,[location.x' location.y']);
%location.y_re=predict(mdl_y,location.y');
location.y_re=predict(mdl_y,[location.x' location.y']);
%
figure('name','tracking after regression','numberTitle','off','visible',visible.Tracking);
%plot([sensor2.x 1/m*(y_lim(1)-sensor2.y+m*sensor2.x)],[sensor2.y y_lim(1)])
hold all
%plot(location.x_re(interval),location.y_re(interval),'b*','MarkerSize',4,'EraseMode','none');

%plot(location.x_re(fs*44:fs*145),location.y_re(fs*44:fs*145),'b*','MarkerSize',4,'EraseMode','none'); % 44:145 for 20140822_0
set(gca,'fontsize',12)

plot(location.x_re(interval),location.y_re(interval),'b*','MarkerSize',4,'EraseMode','none');
%plot(-0.8+.03*randn(1,16*3),-3.7+.07*randn(1,16*3),'b*','MarkerSize',4,'EraseMode','none'); % 20140822_0
hold on
axis equal
xlim(x_lim)
ylim(y_lim)
xlabel('Distance (m)','fontsize',12)
ylabel('Distance (m)','fontsize',12)

%% Performance
%Performance;

end % end Tracking

%% Traing Tracking Regression Model
function [mdl_x mdl_y]=Tracking_Regression_Model
    global fs;
    global sensor1;
    global sensor2;
    global angle1_bias;
    global angle2_bias;

    training_data; % feed the training data

    
    mdl_x=LinearModel.fit(dist_x.in',dist_x.out','quadratic');
    mdl_y=LinearModel.fit(dist_y.in',dist_y.out','quadratic');
    
    x=predict(mdl_x,dist_x.in');
    y=predict(mdl_y,dist_y.in');
    
    save('data\tracking_regression_model\tracking_regression_model2.mat','mdl_x','mdl_y')
    
       %% Training data
    function training_data
    % for 20140808_1
    filename='20140822_1';
    video_struct=importdata(['data\preprocessed_data\' filename '.mat']);
    location=Angle2Position(video_struct.video1_foreground_masked,video_struct.video2_foreground_masked,sensor1,sensor2,angle1_bias,angle2_bias);

    dist_y.in1=[location.x(floor(fs*35:fs*38.5)) ...
                location.x(floor(fs*46:fs*49.5)) location.x(floor(fs*51:fs*55)) location.x(floor(fs*56:fs*60)) location.x(floor(fs*61:fs*65)) ...
                location.x(floor(fs*66.5:fs*70)) location.x(floor(fs*70.5:fs*75)) location.x(floor(fs*76:fs*80)) location.x(floor(fs*81:fs*85)) ...
                location.x(floor(fs*86:fs*90)) location.x(floor(fs*91:fs*94)) location.x(floor(fs*96:fs*100)) location.x(floor(fs*101:fs*105)) ...
                location.x(floor(fs*105.5:fs*110)) location.x(floor(fs*111:fs*114)) location.x(floor(fs*115:fs*119)) location.x(floor(fs*121:fs*125.5)) ...
                location.x(floor(fs*126:fs*130)) location.x(floor(fs*131:fs*135)) location.x(floor(fs*136:fs*140)) ...
                location.x(floor(fs*151:fs*154.5)) location.x(floor(fs*155.5:fs*160)) location.x(floor(fs*161:fs*165))];
    dist_y.in2=[location.y(floor(fs*35:fs*38.5)) ...
                location.y(floor(fs*46:fs*49.5)) location.y(floor(fs*51:fs*55)) location.y(floor(fs*56:fs*60)) location.y(floor(fs*61:fs*65)) ...
                location.y(floor(fs*66.5:fs*70)) location.y(floor(fs*70.5:fs*75)) location.y(floor(fs*76:fs*80)) location.y(floor(fs*81:fs*85)) ...
                location.y(floor(fs*86:fs*90)) location.y(floor(fs*91:fs*94)) location.y(floor(fs*96:fs*100)) location.y(floor(fs*101:fs*105)) ...
                location.y(floor(fs*105.5:fs*110)) location.y(floor(fs*111:fs*114)) location.y(floor(fs*115:fs*119)) location.y(floor(fs*121:fs*125.5)) ...
                location.y(floor(fs*126:fs*130)) location.y(floor(fs*131:fs*135)) location.y(floor(fs*136:fs*140)) ...
                location.y(floor(fs*151:fs*154.5)) location.y(floor(fs*155.5:fs*160)) location.y(floor(fs*161:fs*165))];
    dist_y.out=[-0.794*ones(1,length(floor(fs*35:fs*38.5))) ...
                -1.394*ones(1,length(floor(fs*46:fs*49.5))) -1.394*ones(1,length(floor(fs*51:fs*55 ))) -1.394*ones(1,length(floor(fs*56:fs*60))) -1.394*ones(1,length(floor(fs*61:fs*65))) ...
                -1.994*ones(1,length(floor(fs*66.5:fs*70))) -1.994*ones(1,length(floor(fs*70.5:fs*75))) -1.994*ones(1,length(floor(fs*76:fs*80))) -1.994*ones(1,length(floor(fs*81:fs*85))) ...
                -2.594*ones(1,length(floor(fs*86:fs*90))) -2.594*ones(1,length(floor(fs*91:fs*94))) -2.594*ones(1,length(floor(fs*96:fs*100))) -2.594*ones(1,length(floor(fs*101:fs*105))) ...
                -3.194*ones(1,length(floor(fs*105.5:fs*110))) -3.194*ones(1,length(floor(fs*111:fs*114))) -3.194*ones(1,length(floor(fs*115:fs*119))) -3.194*ones(1,length(floor(fs*121:fs*125.5))) ...
                -3.794*ones(1,length(floor(fs*126:fs*130))) -3.794*ones(1,length(floor(fs*131:fs*135))) -3.794*ones(1,length(floor(fs*136:fs*140))) ...
                -4.394*ones(1,length(floor(fs*151:fs*154.5))) -4.394*ones(1,length(floor(fs*155.5:fs*160))) -4.394*ones(1,length(floor(fs*161:fs*165)))];  
    %
    dist_x.in1=[location.x(floor(fs*35:fs*38.5)) ...
                location.x(floor(fs*46:fs*49.5)) location.x(floor(fs*51:fs*55)) location.x(floor(fs*56:fs*60)) location.x(floor(fs*61:fs*65)) ...
                location.x(floor(fs*66.5:fs*70)) location.x(floor(fs*70.5:fs*75)) location.x(floor(fs*76:fs*80)) location.x(floor(fs*81:fs*85)) ...
                location.x(floor(fs*86:fs*90)) location.x(floor(fs*91:fs*94)) location.x(floor(fs*96:fs*100)) location.x(floor(fs*101:fs*105)) ...
                location.x(floor(fs*105.5:fs*110)) location.x(floor(fs*111:fs*114)) location.x(floor(fs*115:fs*119)) location.x(floor(fs*121:fs*125.5)) ...
                location.x(floor(fs*126:fs*130)) location.x(floor(fs*131:fs*135)) location.x(floor(fs*136:fs*140)) ...
                location.x(floor(fs*151:fs*154.5)) location.x(floor(fs*155.5:fs*160)) location.x(floor(fs*161:fs*165))];
    dist_x.in2=[location.y(floor(fs*35:fs*38.5)) ...
                location.y(floor(fs*46:fs*49.5)) location.y(floor(fs*51:fs*55)) location.y(floor(fs*56:fs*60)) location.y(floor(fs*61:fs*65)) ...
                location.y(floor(fs*66.5:fs*70)) location.y(floor(fs*70.5:fs*75)) location.y(floor(fs*76:fs*80)) location.y(floor(fs*81:fs*85)) ...
                location.y(floor(fs*86:fs*90)) location.y(floor(fs*91:fs*94)) location.y(floor(fs*96:fs*100)) location.y(floor(fs*101:fs*105)) ...
                location.y(floor(fs*105.5:fs*110)) location.y(floor(fs*111:fs*114)) location.y(floor(fs*115:fs*119)) location.y(floor(fs*121:fs*125.5)) ...
                location.y(floor(fs*126:fs*130)) location.y(floor(fs*131:fs*135)) location.y(floor(fs*136:fs*140)) ...
                location.y(floor(fs*151:fs*154.5)) location.y(floor(fs*155.5:fs*160)) location.y(floor(fs*161:fs*165))];
    dist_x.out=[-1.994*ones(1,length(floor(fs*35:fs*38.5))) ...
                -2.594*ones(1,length(floor(fs*46:fs*49.5))) -1.994*ones(1,length(floor(fs*51:fs*55))) -1.394*ones(1,length(floor(fs*56:fs*60))) -0.794*ones(1,length(floor(fs*61:fs*65))) ...
                -0.794*ones(1,length(floor(fs*66.5:fs*70))) -1.394*ones(1,length(floor(fs*70.5:fs*75))) -1.994*ones(1,length(floor(fs*76:fs*80))) -2.594*ones(1,length(floor(fs*81:fs*85))) ...
                -2.594*ones(1,length(floor(fs*86:fs*90))) -1.994*ones(1,length(floor(fs*91:fs*94))) -1.394*ones(1,length(floor(fs*96:fs*100))) -0.794*ones(1,length(floor(fs*101:fs*105))) ...
                -0.794*ones(1,length(floor(fs*105.5:fs*110))) -1.394*ones(1,length(floor(fs*111:fs*114))) -1.994*ones(1,length(floor(fs*115:fs*119))) -2.594*ones(1,length(floor(fs*121:fs*125.5))) ...
                -2.594*ones(1,length(floor(fs*126:fs*130))) -1.994*ones(1,length(floor(fs*131:fs*135))) -1.394*ones(1,length(floor(fs*136:fs*140))) ...
                -1.394*ones(1,length(floor(fs*151:fs*154.5))) -1.994*ones(1,length(floor(fs*155.5:fs*160))) -2.594*ones(1,length(floor(fs*161:fs*165)))];
    %}
    
    % for 20140808_2
    filename='20140822_2';
    video_struct=importdata(['data\preprocessed_data\' filename '.mat']);
    location=Angle2Position(video_struct.video1_foreground_masked,video_struct.video2_foreground_masked,sensor1,sensor2,angle1_bias,angle2_bias);
    
    dist_y.in1=[dist_y.in1 location.x(floor(fs*33:fs*35)) ...
                location.x(floor(fs*44.5:fs*48)) location.x(floor(fs*50:fs*53.5)) location.x(floor(fs*54.5:fs*58.5)) location.x(floor(fs*59:fs*63)) ...
                location.x(floor(fs*64.5:fs*68)) location.x(floor(fs*69:fs*73)) location.x(floor(fs*74.5:fs*78)) location.x(floor(fs*79.5:fs*83.5)) ...
                location.x(floor(fs*84.5:fs*88.5)) location.x(floor(fs*90:fs*93.5)) location.x(floor(fs*94.5:fs*97)) location.x(floor(fs*98:fs*101.5)) ...
                location.x(floor(fs*104.5:fs*108.5)) location.x(floor(fs*109:fs*113)) location.x(floor(fs*114:fs*118.5)) location.x(floor(fs*119:fs*123)) ...
                location.x(floor(fs*124.5:fs*128.5)) location.x(floor(fs*129.5:fs*133.5)) location.x(floor(fs*135:fs*138.5)) ...
                location.x(floor(fs*149:fs*153)) location.x(floor(fs*154:fs*158)) location.x(floor(fs*159:fs*164.5))];
    dist_y.in2=[dist_y.in2 location.y(floor(fs*33:fs*35)) ...
                location.y(floor(fs*44.5:fs*48)) location.y(floor(fs*50:fs*53.5)) location.y(floor(fs*54.5:fs*58.5)) location.y(floor(fs*59:fs*63)) ...
                location.y(floor(fs*64.5:fs*68)) location.y(floor(fs*69:fs*73)) location.y(floor(fs*74.5:fs*78)) location.y(floor(fs*79.5:fs*83.5)) ...
                location.y(floor(fs*84.5:fs*88.5)) location.y(floor(fs*90:fs*93.5)) location.y(floor(fs*94.5:fs*97)) location.y(floor(fs*98:fs*101.5)) ...
                location.y(floor(fs*104.5:fs*108.5)) location.y(floor(fs*109:fs*113)) location.y(floor(fs*114:fs*118.5)) location.y(floor(fs*119:fs*123)) ...
                location.y(floor(fs*124.5:fs*128.5)) location.y(floor(fs*129.5:fs*133.5)) location.y(floor(fs*135:fs*138.5)) ...
                location.y(floor(fs*149:fs*153)) location.y(floor(fs*154:fs*158)) location.y(floor(fs*159:fs*164.5))];
    
    dist_y.out=[dist_y.out -0.794*ones(1,length(floor(fs*33:fs*35))) ...
                -1.394*ones(1,length(floor(fs*44.5:fs*48))) -1.394*ones(1,length(floor(fs*50:fs*53.5))) -1.394*ones(1,length(floor(fs*54.5:fs*58.5))) -1.394*ones(1,length(floor(fs*59:fs*63))) ...
                -1.994*ones(1,length(floor(fs*64.5:fs*68))) -1.994*ones(1,length(floor(fs*69:fs*73))) -1.994*ones(1,length(floor(fs*74.5:fs*78))) -1.994*ones(1,length(floor(fs*79.5:fs*83.5))) ...
                -2.594*ones(1,length(floor(fs*84.5:fs*88.5))) -2.594*ones(1,length(floor(fs*90:fs*93.5))) -2.594*ones(1,length(floor(fs*94.5:fs*97))) -2.594*ones(1,length(floor(fs*98:fs*101.5))) ...
                -3.194*ones(1,length(floor(fs*104.5:fs*108.5))) -3.194*ones(1,length(floor(fs*109:fs*113))) -3.194*ones(1,length(floor(fs*114:fs*118.5))) -3.194*ones(1,length(floor(fs*119:fs*123))) ...
                -3.794*ones(1,length(floor(fs*124.5:fs*128.5))) -3.794*ones(1,length(floor(fs*129.5:fs*133.5))) -3.794*ones(1,length(floor(fs*135:fs*138.5))) ...
                -4.394*ones(1,length(floor(fs*149:fs*153))) -4.394*ones(1,length(floor(fs*154:fs*158))) -4.394*ones(1,length(floor(fs*159:fs*164.5)))];
    
    dist_x.in1=[dist_x.in1 location.x(floor(fs*33:fs*35)) ...
                location.x(floor(fs*44.5:fs*48)) location.x(floor(fs*50:fs*53.5)) location.x(floor(fs*54.5:fs*58.5)) location.x(floor(fs*59:fs*63)) ...
                location.x(floor(fs*64.5:fs*68)) location.x(floor(fs*69:fs*73)) location.x(floor(fs*74.5:fs*78)) location.x(floor(fs*79.5:fs*83.5)) ...
                location.x(floor(fs*84.5:fs*88.5)) location.x(floor(fs*90:fs*93.5)) location.x(floor(fs*94.5:fs*97)) location.x(floor(fs*98:fs*101.5)) ...
                location.x(floor(fs*104.5:fs*108.5)) location.x(floor(fs*109:fs*113)) location.x(floor(fs*114:fs*118.5)) location.x(floor(fs*119:fs*123)) ...
                location.x(floor(fs*124.5:fs*128.5)) location.x(floor(fs*129.5:fs*133.5)) location.x(floor(fs*135:fs*138.5)) ...
                location.x(floor(fs*149:fs*153)) location.x(floor(fs*154:fs*158)) location.x(floor(fs*159:fs*164.5))];
    dist_x.in2=[dist_x.in2 location.y(floor(fs*33:fs*35)) ...
                location.y(floor(fs*44.5:fs*48)) location.y(floor(fs*50:fs*53.5)) location.y(floor(fs*54.5:fs*58.5)) location.y(floor(fs*59:fs*63)) ...
                location.y(floor(fs*64.5:fs*68)) location.y(floor(fs*69:fs*73)) location.y(floor(fs*74.5:fs*78)) location.y(floor(fs*79.5:fs*83.5)) ...
                location.y(floor(fs*84.5:fs*88.5)) location.y(floor(fs*90:fs*93.5)) location.y(floor(fs*94.5:fs*97)) location.y(floor(fs*98:fs*101.5)) ...
                location.y(floor(fs*104.5:fs*108.5)) location.y(floor(fs*109:fs*113)) location.y(floor(fs*114:fs*118.5)) location.y(floor(fs*119:fs*123)) ...
                location.y(floor(fs*124.5:fs*128.5)) location.y(floor(fs*129.5:fs*133.5)) location.y(floor(fs*135:fs*138.5)) ...
                location.y(floor(fs*149:fs*153)) location.y(floor(fs*154:fs*158)) location.y(floor(fs*159:fs*164.5))];
    dist_x.out=[dist_x.out -1.994*ones(1,length(floor(fs*33:fs*35))) ...
                -2.594*ones(1,length(floor(fs*44.5:fs*48))) -1.994*ones(1,length(floor(fs*50:fs*53.5))) -1.394*ones(1,length(floor(fs*54.5:fs*58.5))) -0.794*ones(1,length(floor(fs*59:fs*63))) ...
                -0.794*ones(1,length(floor(fs*64.5:fs*68))) -1.394*ones(1,length(floor(fs*69:fs*73))) -1.994*ones(1,length(floor(fs*74.5:fs*78))) -2.594*ones(1,length(floor(fs*79.5:fs*83.5))) ...
                -2.594*ones(1,length(floor(fs*84.5:fs*88.5))) -1.994*ones(1,length(floor(fs*90:fs*93.5))) -1.394*ones(1,length(floor(fs*94.5:fs*97))) -0.794*ones(1,length(floor(fs*98:fs*101.5))) ...
                -0.794*ones(1,length(floor(fs*104.5:fs*108.5))) -1.394*ones(1,length(floor(fs*109:fs*113))) -1.994*ones(1,length(floor(fs*114:fs*118.5))) -2.594*ones(1,length(floor(fs*119:fs*123))) ...
                -2.594*ones(1,length(floor(fs*124.5:fs*128.5))) -1.994*ones(1,length(floor(fs*124.5:fs*128.5))) -1.394*ones(1,length(floor(fs*135:fs*138.5))) ...
                -1.394*ones(1,length(floor(fs*149:fs*153))) -1.994*ones(1,length(floor(fs*154:fs*158))) -2.594*ones(1,length(floor(fs*159:fs*164.5)))];
    
    dist_x.in=[dist_x.in1;dist_x.in2];
    dist_y.in=[dist_y.in1;dist_y.in2];
    end % end training data
end % end regression

function location=Angle2Position(video1,video2,sensor1,sensor2,angle1_bias,angle2_bias) % video1_foreground_masked,video2_foreground_masked,

location.horizontal_angle1=zeros(1,size(video1,3));
location.vertical_angle1=zeros(1,size(video1,3));

location.horizontal_angle2=zeros(1,size(video1,3));
location.vertical_angle2=zeros(1,size(video1,3));

degree_horizontal=60/size(video1,2)*(1:size(video1,2))-0.5*60/size(video1,2);
degree_vertical=16.4/size(video1,1)*(size(video1,1):-1:1)-0.5*16.4/size(video1,1); % the lower bound of degree is near the ground, the upper one is near the ceiling

for frame=1:size(video1,3)
    for i=1:size(video1,1)
        location.horizontal_angle1(frame)=location.horizontal_angle1(frame)+video1(i,:,frame)*degree_horizontal(1:size(video1,2))'; % sum of temperature*position
        location.horizontal_angle2(frame)=location.horizontal_angle2(frame)+video2(i,:,frame)*degree_horizontal(1:size(video1,2))'; % sum of temperature*position
    end
    
    for j=1:size(video1,2)
        location.vertical_angle1(frame)=location.vertical_angle1(frame)+video1(:,j,frame)'*degree_vertical(1:size(video1,1))'; % sum of temperature*position
        location.vertical_angle2(frame)=location.vertical_angle2(frame)+video2(:,j,frame)'*degree_vertical(1:size(video1,1))'; % sum of temperature*position
    end
    
    if location.horizontal_angle1(frame)~=0
        location.horizontal_angle1(frame)=location.horizontal_angle1(frame)/sum(reshape(video1(:,:,frame),1,[])); % weight sum
    else
        location.horizontal_angle1(frame)=0;
    end
    
    if location.vertical_angle1(frame)~=0
        location.vertical_angle1(frame)=location.vertical_angle1(frame)/sum(reshape(video1(:,:,frame),1,[])); % weight sum
    else
        location.vertical_angle1(frame)=0;
    end
    
    if location.horizontal_angle2(frame)~=0
        location.horizontal_angle2(frame)=location.horizontal_angle2(frame)/sum(reshape(video2(:,:,frame),1,[])); % weight sum
    else
        location.horizontal_angle2(frame)=0;
    end
    
    if location.vertical_angle2(frame)~=0
        location.vertical_angle2(frame)=location.vertical_angle2(frame)/sum(reshape(video2(:,:,frame),1,[])); % weight sum
    else
        location.vertical_angle2(frame)=0;
    end
    [location.x(frame) location.y(frame)]=position(location.horizontal_angle1(frame),location.horizontal_angle2(frame));
    %position(location.horizontal_angle1(frame),location.horizontal_angle2(frame))
end % end for frame

    function [xt, yt]=position(theta1,theta2) % angle to position
        if theta1==0 || theta2==0,
            xt=nan;
            yt=nan;
        else
        theta1=theta1+angle1_bias-30;
        theta2=-(90-(theta2+angle2_bias-30));
        
        
        %xt=(tand(theta1)*sensor1.x-tand(theta2)*sensor2.x-sensor1.y+sensor2.y)/(tand(theta1)-tand(theta2));
        %yt=tand(theta1)*(xt-sensor1.x)+sensor1.y;
        %
        A=[tand(theta1) -1;tand(theta2) -1];
        b=[tand(theta1)*sensor1.x-sensor1.y;tand(theta2)*sensor2.x-sensor2.y];
        position_sol=inv(A)*b;
        xt=position_sol(1);yt=position_sol(2);
        end
        %}
    end % end position
end % end Angle2Position

function Performance
global fs;
global sensor1;
global sensor2;
global angle1_bias;
global angle2_bias;

filename='20140822_0'; % data for performance estimation
video_struct=importdata(['data\preprocessed_data\' filename '.mat']);
location=Angle2Position(video_struct.video1_foreground_masked,video_struct.video2_foreground_masked,sensor1,sensor2,angle1_bias,angle2_bias);

[mdl_x mdl_y]=Tracking_Regression_Model;
x_re=predict(mdl_x,[location.x' location.y'])';
y_re=predict(mdl_y,[location.x' location.y'])';

%
x_est=[x_re(floor(fs*44:fs*48)) 0 x_re(floor(fs*49:fs*53)) 0 x_re(floor(fs*54:fs*58)) 0 x_re(floor(fs*59:fs*62)) 0 ...
       x_re(floor(fs*64:fs*68)) 0 x_re(floor(fs*69:fs*72.5)) 0 x_re(floor(fs*74:fs*77.5)) 0 x_re(floor(fs*79:fs*83)) 0 ...
       x_re(floor(fs*83.5:fs*88)) 0 x_re(floor(fs*89:fs*93)) 0 x_re(floor(fs*94:fs*97.5)) 0 x_re(floor(fs*99.5:fs*103)) 0 ...
       x_re(floor(fs*104.5:fs*107.5)) 0 x_re(floor(fs*108.5:fs*112.5)) 0 x_re(floor(fs*113.5:fs*117.5)) 0 x_re(floor(fs*118.5:fs*122.5)) 0 ...
       x_re(floor(fs*124:fs*127.5)) 0 x_re(floor(fs*128.5:fs*132.5)) 0 x_re(floor(fs*134:fs*138))];
x_true=[-2.594*ones(1,length(floor(fs*44:fs*48))) 0 -1.994*ones(1,length(floor(fs*49:fs*53))) 0 -1.394*ones(1,length(floor(fs*54:fs*58))) 0 -0.794*ones(1,length(floor(fs*59:fs*62))) 0 ...
        -0.794*ones(1,length(floor(fs*64:fs*68))) 0 -1.394*ones(1,length(floor(fs*69:fs*72.5))) 0 -1.994*ones(1,length(floor(fs*74:fs*77.5))) 0 -2.594*ones(1,length(floor(fs*79:fs*83))) 0 ...
        -2.594*ones(1,length(floor(fs*83.5:fs*88))) 0 -1.994*ones(1,length(floor(fs*89:fs*93))) 0 -1.394*ones(1,length(floor(fs*94:fs*97.5))) 0 -0.794*ones(1,length(floor(fs*99.5:fs*103))) 0 ...
        -0.794*ones(1,length(floor(fs*104.5:fs*107.5))) 0 -1.394*ones(1,length(floor(fs*108.5:fs*112.5))) 0 -1.994*ones(1,length(floor(fs*113.5:fs*117.5))) 0 -2.594*ones(1,length(floor(fs*118.5:fs*122.5))) 0 ...
        -2.594*ones(1,length(floor(fs*124:fs*127.5))) 0 -1.994*ones(1,length(floor(fs*128.5:fs*132.5))) 0 -1.394*ones(1,length(floor(fs*134:fs*138)))];
y_est=[y_re(floor(fs*44:fs*48)) 0 y_re(floor(fs*49:fs*53)) 0 y_re(floor(fs*54:fs*58)) 0 y_re(floor(fs*59:fs*62)) 0 ...
       y_re(floor(fs*64:fs*68)) 0 y_re(floor(fs*69:fs*72.5)) 0 y_re(floor(fs*74:fs*77.5)) 0 y_re(floor(fs*79:fs*83)) 0 ...
       y_re(floor(fs*83.5:fs*88)) 0 y_re(floor(fs*89:fs*93)) 0 y_re(floor(fs*94:fs*97.5)) 0 y_re(floor(fs*99.5:fs*103)) 0 ...
       y_re(floor(fs*104.5:fs*107.5)) 0 y_re(floor(fs*108.5:fs*112.5)) 0 y_re(floor(fs*113.5:fs*117.5)) 0 y_re(floor(fs*118.5:fs*122.5)) 0 ...
       y_re(floor(fs*124:fs*127.5)) 0 y_re(floor(fs*128.5:fs*132.5)) 0 y_re(floor(fs*134:fs*138))];
y_true=[-1.394*ones(1,length(floor(fs*44:fs*48))) 0 -1.394*ones(1,length(floor(fs*49:fs*53))) 0 -1.394*ones(1,length(floor(fs*54:fs*58))) 0 -1.394*ones(1,length(floor(fs*59:fs*62))) 0 ...
        -1.994*ones(1,length(floor(fs*64:fs*68))) 0 -1.994*ones(1,length(floor(fs*69:fs*72.5))) 0 -1.994*ones(1,length(floor(fs*74:fs*77.5))) 0 -1.994*ones(1,length(floor(fs*79:fs*83))) 0 ...
        -2.594*ones(1,length(floor(fs*83.5:fs*88))) 0 -2.594*ones(1,length(floor(fs*89:fs*93))) 0 -2.594*ones(1,length(floor(fs*94:fs*97.5))) 0 -2.594*ones(1,length(floor(fs*99.5:fs*103))) 0 ...
        -3.194*ones(1,length(floor(fs*104.5:fs*107.5))) 0 -3.194*ones(1,length(floor(fs*108.5:fs*112.5))) 0 -3.194*ones(1,length(floor(fs*113.5:fs*117.5))) 0 -3.194*ones(1,length(floor(fs*118.5:fs*122.5))) 0 ...
        -3.794*ones(1,length(floor(fs*124:fs*127.5))) 0 -3.794*ones(1,length(floor(fs*128.5:fs*132.5))) 0 -3.794*ones(1,length(floor(fs*134:fs*138)))];
    
ind=find(isnan(x_est));
x_est(ind)=[];x_est=[0 x_est 0];
x_true(ind)=[];x_true=[0 x_true 0];
y_est(ind)=[];y_est=[0 y_est 0];
y_true(ind)=[];y_true=[0 y_true 0];

zero_ind=find(x_est==0);
for ind_pos=2:length(zero_ind)
    pos_num1(floor((ind_pos-2)/4)+1,rem(ind_pos-2,4)+1)=length(zero_ind(ind_pos-1)+1:zero_ind(ind_pos)-1);
    sqerr=dist_sqerr(x_est(zero_ind(ind_pos-1)+1:zero_ind(ind_pos)-1),y_est(zero_ind(ind_pos-1)+1:zero_ind(ind_pos)-1),x_true(zero_ind(ind_pos-1)+1:zero_ind(ind_pos)-1),y_true(zero_ind(ind_pos-1)+1:zero_ind(ind_pos)-1));
    RMSE_pos1(floor((ind_pos-2)/4)+1,rem(ind_pos-2,4)+1)=sqrt(mean(sqerr)); % total mean RMSE
    ME_pos1(floor((ind_pos-2)/4)+1,rem(ind_pos-2,4)+1)=mean(sqrt(sqerr)); % mean error
end

filename='20141101_0'; % data for performance estimation
video_struct=importdata(['data\preprocessed_data\' filename '.mat']);
location=Angle2Position(video_struct.video1_foreground_masked,video_struct.video2_foreground_masked,sensor1,sensor2,angle1_bias,angle2_bias);

x_re=predict(mdl_x,[location.x' location.y'])';
%y_re=predict(mdl_y,location.y')';
y_re=predict(mdl_y,[location.x' location.y'])';

%
x_est=[
       %x_est ...
       x_re(floor(fs*67:fs*79)) 0 x_re(floor(fs*80:fs*89.5)) 0 x_re(floor(fs*90.5:fs*100)) 0 x_re(floor(fs*101:fs*109.5)) 0 ...
       x_re(floor(fs*110:fs*119.5)) 0 x_re(floor(fs*120.5:fs*130)) 0 x_re(floor(fs*130.5:fs*138.5)) 0 x_re(floor(fs*139.5:fs*149.5)) 0 ...
       x_re(floor(fs*150.5:fs*159)) 0 x_re(floor(fs*160:fs*169.5)) 0 x_re(floor(fs*170:fs*179.5)) 0 x_re(floor(fs*180:fs*189.5)) 0 ...
       x_re(floor(fs*190:fs*199.5)) 0 x_re(floor(fs*200:fs*209.5)) 0 x_re(floor(fs*210.5:fs*219)) 0 x_re(floor(fs*220:fs*229.5)) 0 ...
       x_re(floor(fs*230:fs*239.5)) 0 x_re(floor(fs*240:fs*249.5)) 0 x_re(floor(fs*250:fs*259.5)) 0 x_re(floor(fs*260:fs*270))];
x_true=[
        %x_true ...
        -2.594*ones(1,length(floor(fs*67:fs*79))) 0 -1.994*ones(1,length(floor(fs*80:fs*89.5))) 0 -1.394*ones(1,length(floor(fs*90.5:fs*100))) 0 -0.794*ones(1,length(floor(fs*101:fs*109.5))) 0 ...
        -0.794*ones(1,length(floor(fs*110:fs*119.5))) 0 -1.394*ones(1,length(floor(fs*120.5:fs*130))) 0 -1.994*ones(1,length(floor(fs*130.5:fs*138.5))) 0 -2.594*ones(1,length(floor(fs*139.5:fs*149.5))) 0 ...
        -2.594*ones(1,length(floor(fs*150.5:fs*159))) 0 -1.994*ones(1,length(floor(fs*160:fs*169.5))) 0 -1.394*ones(1,length(floor(fs*170:fs*179.5))) 0 -0.794*ones(1,length(floor(fs*180:fs*189.5))) 0 ...
        -0.794*ones(1,length(floor(fs*190:fs*199.5))) 0 -1.394*ones(1,length(floor(fs*200:fs*209.5))) 0 -1.994*ones(1,length(floor(fs*210.5:fs*219))) 0 -2.594*ones(1,length(floor(fs*220:fs*229.5))) 0 ...
        -2.594*ones(1,length(floor(fs*230:fs*239.5))) 0 -1.994*ones(1,length(floor(fs*240:fs*249.5))) 0 -1.394*ones(1,length(floor(fs*250:fs*259.5))) 0 -0.794*ones(1,length(floor(fs*260:fs*270)))];
y_est=[
       %y_est ...
       y_re(floor(fs*67:fs*79)) 0 y_re(floor(fs*80:fs*89.5)) 0 y_re(floor(fs*90.5:fs*100)) 0 y_re(floor(fs*101:fs*109.5)) 0 ...
       y_re(floor(fs*110:fs*119.5)) 0 y_re(floor(fs*120.5:fs*130)) 0 y_re(floor(fs*130.5:fs*138.5)) 0 y_re(floor(fs*139.5:fs*149.5)) 0 ...
       y_re(floor(fs*150.5:fs*159)) 0 y_re(floor(fs*160:fs*169.5)) 0 y_re(floor(fs*170:fs*179.5)) 0 y_re(floor(fs*180:fs*189.5)) 0 ...
       y_re(floor(fs*190:fs*199.5)) 0 y_re(floor(fs*200:fs*209.5)) 0 y_re(floor(fs*210.5:fs*219)) 0 y_re(floor(fs*220:fs*229.5)) 0 ...
       y_re(floor(fs*230:fs*239.5)) 0 y_re(floor(fs*240:fs*249.5)) 0 y_re(floor(fs*250:fs*259.5)) 0 y_re(floor(fs*260:fs*270))];
y_true=[
        %y_true ...
        -1.394*ones(1,length(floor(fs*67:fs*79))) 0 -1.394*ones(1,length(floor(fs*80:fs*89.5))) 0 -1.394*ones(1,length(floor(fs*90.5:fs*100))) 0 -1.394*ones(1,length(floor(fs*101:fs*109.5))) 0 ...
        -1.994*ones(1,length(floor(fs*110:fs*119.5))) 0 -1.994*ones(1,length(floor(fs*120.5:fs*130))) 0 -1.994*ones(1,length(floor(fs*130.5:fs*138.5))) 0 -1.994*ones(1,length(floor(fs*139.5:fs*149.5))) 0 ...
        -2.594*ones(1,length(floor(fs*150.5:fs*159))) 0 -2.594*ones(1,length(floor(fs*160:fs*169.5))) 0 -2.594*ones(1,length(floor(fs*170:fs*179.5))) 0 -2.594*ones(1,length(floor(fs*180:fs*189.5))) 0 ...
        -3.194*ones(1,length(floor(fs*190:fs*199.5))) 0 -3.194*ones(1,length(floor(fs*200:fs*209.5))) 0 -3.194*ones(1,length(floor(fs*210.5:fs*219))) 0 -3.194*ones(1,length(floor(fs*220:fs*229.5))) 0 ...
        -3.794*ones(1,length(floor(fs*230:fs*239.5))) 0 -3.794*ones(1,length(floor(fs*240:fs*249.5))) 0 -3.794*ones(1,length(floor(fs*250:fs*259.5))) 0 -3.794*ones(1,length(floor(fs*260:fs*270)))];

ind=find(isnan(x_est));
x_est(ind)=[];x_est=[0 x_est 0];
x_true(ind)=[];x_true=[0 x_true 0];
y_est(ind)=[];y_est=[0 y_est 0];
y_true(ind)=[];y_true=[0 y_true 0];

zero_ind=find(x_est==0);
for ind_pos=2:length(zero_ind)
    pos_num2(floor((ind_pos-2)/4)+1,rem(ind_pos-2,4)+1)=length(zero_ind(ind_pos-1)+1:zero_ind(ind_pos)-1);
    sqerr=dist_sqerr(x_est(zero_ind(ind_pos-1)+1:zero_ind(ind_pos)-1),y_est(zero_ind(ind_pos-1)+1:zero_ind(ind_pos)-1),x_true(zero_ind(ind_pos-1)+1:zero_ind(ind_pos)-1),y_true(zero_ind(ind_pos-1)+1:zero_ind(ind_pos)-1));
    RMSE_pos2(floor((ind_pos-2)/4)+1,rem(ind_pos-2,4)+1)=sqrt(mean(sqerr)); % total mean RMSE
    ME_pos2(floor((ind_pos-2)/4)+1,rem(ind_pos-2,4)+1)=mean(sqrt(sqerr)); % mean error
end

pos_num=pos_num1+pos_num2
RMSE_pos=(RMSE_pos1.*pos_num1+RMSE_pos2.*pos_num2)./pos_num
ME_pos=(ME_pos1.*pos_num1+ME_pos2.*pos_num2)./pos_num

size(ME_pos)

figure
surface(-2.594:0.6:-0.794,-1.394:-0.6:-3.794,ME_pos)
grid on;
view(70,40);
colorbar
caxis([0 0.2])
xlabel('Distance (m)')
ylabel('Distance (m)')
zlabel('Error (m)')

    function sqerr=dist_sqerr(x,y,x_true,y_true)
        sqerr=(x-x_true).^2+(y-y_true).^2;
    end

    
end % end Performance