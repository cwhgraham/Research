function Classifier
clc;clear all;close all;global fs;fs=16;
evalin('caller','clear all')
global window_size;window_size=1; % sec
DefaultSetting;
global visible;

filename=['20140822' '_' '6']; % date_whichtime
video_struct=importdata(['data\preprocessed_data\' filename '.mat']);

Feature_extract_filebased(filename,0,1);

%
%% Feed the training data
%training_data=gen_training_data;
training_data=importdata('data\KNN_training_data\KNN_training_data.mat');
%numel(find(training_data.label==1))
%training_data.feature()=[];
%feature('memstats')

figure('name','Sample distribution','numberTitle','off','visible',visible.Classifier);
hold all;
%plot(training_data.feature(1:numfallevent,1),training_data.feature(1:numfallevent,2),'r*','MarkerSize',10)
%plot(training_data.feature(numfallevent+1:end,1),training_data.feature(numfallevent+1:end,2),'b*','MarkerSize',10)

%plot3(training_data.feature(1:numfallevent,1),training_data.feature(1:numfallevent,2),training_data.feature(1:numfallevent,3),'r*','MarkerSize',10)
%plot3(training_data.feature(numfallevent+1:end,1),training_data.feature(numfallevent+1:end,2),training_data.feature(numfallevent+1:end,3),'b*','MarkerSize',10)
%grid on;view(35,30);
%% Feature selection
%     1             2          3            4             5       6           7            8             9               10         11      12       13 
%'ver_lslope', 'hor_lvdir', 'hor_lv', 'vertical_proj', 'MAD_v', 'MAD_h', 'ver_gslope', 'hor1_gv', 'std_absdiff_v', 'std_absdiff_h', 'min', 'std_v', 'std_h'
% sort AUC 11 1 7 6 5 12 13 2 10 4 9 3 8
%feature_sel='ver_lslope', 'hor_lv', 'MAD_v', 'MAD_h' 'std_h'; k=3; max performance
feature_sel=[1 2 7 8 10 11]; % 
feature_sel=[1 2 9 10 11]; % 
feature_sel=[11 1 12 13 2]; % max

% Sequential forward selection (SFS)
% http://stackoverflow.com/questions/10469837/features-selection-with-sequentialfs-with-libsvm
%fun = @(XT,yT,Xt,yt) (sum(~strcmp(yt,classify(Xt,XT,y,'quadratic'))));

%sequentialfs()

%% Classification
%
KNN_mdl=ClassificationKNN.fit(training_data.feature(:,feature_sel),training_data.label,'NSMethod','exhaustive');
KNN_mdl.NumNeighbors=3;
KNN_mdl.Distance='mahalanobis';
%KNN_mdl.DistParameter % covariance matrix for mahalanobis
%

%
kfold=length(training_data.label); % leave one out
indices=crossvalind('Kfold', length(training_data.label),kfold);
predict_label=nan(length(training_data.label),1);
for i=1:kfold
test_ind=(indices==i);
train_ind=~test_ind;
KNN_mdl=ClassificationKNN.fit(training_data.feature(train_ind,feature_sel),training_data.label(train_ind),'NSMethod','exhaustive');
KNN_mdl.NumNeighbors=3;
KNN_mdl.Distance='mahalanobis';


predict_label_tmp=predict(KNN_mdl,training_data.feature(test_ind,feature_sel));
predict_label(test_ind)=predict_label_tmp;
end
predict_label;

TP_num=numel(find(predict_label==1 & training_data.label==1))
TN_num=numel(find(predict_label==2 & training_data.label==2))

sensitivity=TP_num/length(find(training_data.label==1))
specificity=TN_num/length(find(training_data.label==2))

Accuracy=(1-numel(find(predict_label~=training_data.label))/length(predict_label))*100

%
cvKNN_mdl=crossval(KNN_mdl,'leaveout','on');
kcloss=kfoldLoss(cvKNN_mdl);
Accuracy=(1-kcloss)*100
%}




%{
%% Feed the testing data
testseq_filename=['20140913' '_' '0'];time_interval=20:0.5:100;
testseq_filename=['20140822' '_' '12'];time_interval=12.5:0.5:55;

%testing_data=gen_testing_data;
testing_data=importdata('data\KNN_testing_data\KNN_testing_data.mat');

%testing_data.feature=test_sequence(testseq_filename,time_interval);
%testing_data.feature=importdata(['data\KNN_testing_data\test_sequence\' testseq_filename '.mat']);

[predict_label score]=predict(KNN_mdl,testing_data.feature(:,feature_sel));

testdisp=cell(length(predict_label)+1,size(testing_data.feature,2)+2);
testdisp(1,:)={'sample_ind', 'label', ...
               'ver_lslope', 'hor_lvdir', 'hor1_lv', 'vertical_proj', 'MAD_v', 'MAD_h', 'ver_gslope', 'hor1_gv', 'std_absdiff_v', 'std_absdiff_h', 'min', 'std_v', 'std_h'};
testdisp(2:length(predict_label)+1,:)=num2cell([(1:length(predict_label))' predict_label testing_data.feature(:,:)])

%[(1:length(predict_label))' predict_label testing_data.feature(:,:)]
plot_testingdata([predict_label testing_data.feature(:,:)],time_interval)
%}
end

function training_data=gen_training_data
global fs;
global window_size;
global visible;



%% Fall event
% falling

%feature_length=13;
%feature_fall=nan(500,feature_length);

%
feature_fall=[
Feature_extract_filebased(['20140822' '_' '7'],[28.75 53.75 76.75 96.75],1); % 4
Feature_extract_filebased(['20140822' '_' '8'],[34.25 58.25 82.75 107.25 127.5 147.25],1); % 6
Feature_extract_filebased(['20140822' '_' '9'],[28.75 49.75 75.25 97 116.25 140 167.75],1); % 7
Feature_extract_filebased(['20140822' '_' '10'],[23.25 49.25 70.5 92.5 116.75 138],1); % 6
Feature_extract_filebased(['20140822' '_' '11'],[24.25 48.5 71.75 94 117.75],1); % 5
Feature_extract_filebased(['20140822' '_' '12'],[28.75 52.5 74.25 94.75 116 138.25],1); % 6
% 34

Feature_extract_filebased(['20140822' '_' '7'],[28.5 53.5 76.5 96.75],2); % 4
Feature_extract_filebased(['20140822' '_' '8'],[34 58.25 82.75 107.25 127.5 147],2); % 6
Feature_extract_filebased(['20140822' '_' '10'],[23.25 49.25 70.5 92.5 116.75 138],2); % 6
Feature_extract_filebased(['20140822' '_' '12'],[28.75 94.5 116 138],2); % 4
Feature_extract_filebased(['20140920' '_' '3'],[22.75 45.5 71.75 102.75],1); % 4
Feature_extract_filebased(['20140920' '_' '3'],[23 45.75 72 103],2); % 4
Feature_extract_filebased(['20140920' '_' '4'],[32.75 57 82.75 105 132 156.25 175.75 199.75],1); % 8
Feature_extract_filebased(['20140920' '_' '4'],[33.25 57.25 83 105.5 132.5 156.5 175.75 200],2); % 8
% 44 
% 79~98
Feature_extract_filebased(['20140920' '_' '0'],[29.25 46.75 69.5 84.25 110.75 127.25           196 213.25              293    304.25],1); % 10
Feature_extract_filebased(['20140920' '_' '0'],[            69.5 84.5  111    127.5 147 160.75            235.5 248.25 293.25 304.5 ],2); % 10
]; % 99~118
  
save('feature_fall.mat','feature_fall')

%}
%
feature_fall=[
Feature_extract_filebased(['20140920' '_' '1'],[58.25 78.25 102.25 118.5  145.5  159.75 179.75 198.25 232.25 249.75 276    289.25 319    333    354.25 369.25],1); % 16
Feature_extract_filebased(['20140920' '_' '1'],[      78.5  102.5  118.75 145.75 159.75 180.5  198.75        250    276.25 289.5  319.25 333.25 354.5  369.25],2); % 14
Feature_extract_filebased(['20140930' '_' '0'],[31.5  71.25 102.75 118.5 150.25 165.75 190.75 207.5 239 247.5 264.5 295.25 311 350.75 367.75 394 410.5],1); % 17
Feature_extract_filebased(['20140930' '_' '0'],[31.75 71.75 102.75                                                                                    ],2); % 3
Feature_extract_filebased(['20141006' '_' '0'],[24.5  45.75 73.25 88.25 117.75 139.75 173   190.5  234    251.25 286.5  304.25 351.75 369.5  389.25 407   ],1); % 16
Feature_extract_filebased(['20141006' '_' '0'],[24.75 46    73.5  88.5  118    139.75 173.5 190.75 234.25 251.5  286.75 304.25 351.75 369.75 389.5  407.25],2); % 16
Feature_extract_filebased(['20141007' '_' '0'],[40    54    74.25 88    118.5  135    158.75 174.5  224.75 241.25 272    289    317.5  335.75 367.5 383   ],1); % 16
Feature_extract_filebased(['20141007' '_' '0'],[40.25 54.25 74.5  88.25 118.75 135.25 159    174.75 225    241.5  272.25 289.25 317.75 335.75 367.5 383.25],2);%  16
];
% 134


%cat_ind=find(isnan(feature_fall(:,1)),1,'first')
%feature_fall(cat_ind:cat_ind+size(feature_fall_tmp,1)-1,1:size(feature_fall_tmp,2))=feature_fall_tmp;
%clear feature_fall_tmp
save('feature_fall.mat','feature_fall')

%}
%feature_fall(find(isnan(feature_fall)))=[];
% total 212		
%% Non-Fall event
feature_nofall=[

% stand up from ground
Feature_extract_filebased(['20140822' '_' '7'],[23 44 68.25 90 110.5],1); % 5
Feature_extract_filebased(['20140822' '_' '7'],[23.5 44 68 90 110],2); % 5
Feature_extract_filebased(['20140920' '_' '0'],[80   137],1); % 2
Feature_extract_filebased(['20140920' '_' '0'],[79.5 137],2); % 2
Feature_extract_filebased(['20140920' '_' '1'],[114 155.5 212.5],1); % 3
Feature_extract_filebased(['20140920' '_' '1'],[113 154.5 212.5],2); % 3
Feature_extract_filebased(['20140930' '_' '0'],[22.75 63    82.25],1); % 3
Feature_extract_filebased(['20140930' '_' '0'],[23.5  62.75 82.25],2); % 3
Feature_extract_filebased(['20141006' '_' '0'],[36.25 83   102 134   ],1); % 4
Feature_extract_filebased(['20141006' '_' '0'],[35.5  82.5 102 133.75],2); % 4
Feature_extract_filebased(['20141007' '_' '0'],[36.25 49.5 64    83.5  97    ],1); % 5
Feature_extract_filebased(['20141007' '_' '0'],[      49.5 63.75 83.25 95.75 ],2); % 4
% 43

% walking or standing
Feature_extract_filebased(['20140822' '_' '7'],[26 50 72 92],1); % 4
Feature_extract_filebased(['20140822' '_' '8'],[29 54 75 104 125 144],1); % 6
Feature_extract_filebased(['20140822' '_' '9'],[26 47 70 94 113 135 164],1); % 7
Feature_extract_filebased(['20140822' '_' '10'],[20 44 66 89 112 134],1); % 6
Feature_extract_filebased(['20140822' '_' '11'],[22.5 44 67 90 113],1); % 5
Feature_extract_filebased(['20140822' '_' '12'],[27 48 71 91.5 113 135],1); %6
Feature_extract_filebased(['20141006' '_' '0'],[42 85.5 110 137],1); % 4
Feature_extract_filebased(['20141006' '_' '0'],[42 85.5 110 137],1); % 4
% 42

% squat 
Feature_extract_filebased(['20140913' '_' '0'],[35.5 55 74.75 95 115 134.75 155 174.75 194.75 215 234.5],1); % 11
%Feature_extract_filebased(['20140913' '_' '0'],[55.25 75 95.25 115.25 135.25 155.25 175 195 215.25 234.75 255.5],2); % 11
%Feature_extract_filebased(['20140920' '_' '0'],[323 328.25 333.5  339.5],1); % 4
%Feature_extract_filebased(['20140920' '_' '0'],[           333.75 339.5],2); % 2
%Feature_extract_filebased(['20140920' '_' '1'],[399.5  406.25 416.25 424.25],1); % 4
Feature_extract_filebased(['20140920' '_' '1'],[399.75 406.5  416.25 424.25],2); % 4
Feature_extract_filebased(['20140930' '_' '0'],[446.75 454.5  462.75 469.5 ],1); % 4
Feature_extract_filebased(['20140930' '_' '0'],[446.75 454.75 463    469.75],2); % 4
Feature_extract_filebased(['20141006' '_' '0'],[435.5  450.5 463.25 475.25],1); % 4
Feature_extract_filebased(['20141006' '_' '0'],[435.75 450.5 463.25 475.25],2); % 4
];
save('feature_nofall.mat','feature_nofall')


feature_nofall=[
Feature_extract_filebased(['20141007' '_' '0'],[413.25 426 437.75 450.5],1); % 4
Feature_extract_filebased(['20141007' '_' '0'],[413.5  426 437.75 450.5],2); % 4
% 39

% bending
Feature_extract_filebased(['20140913' '_' '1'],[26.5 36.5 46.5 56.25 66.5 76.25 86 96 106.5 116 125.75],1); % 11
%Feature_extract_filebased(['20140913' '_' '1'],[26.5 37 46.5 56.25 66.5 76.25 86 96 107 116.25 126 137],2); % 12
%Feature_extract_filebased(['20140920' '_' '0'],[348 353 358.5 363.75],1); % 4
%Feature_extract_filebased(['20140920' '_' '0'],[],2); % 0
Feature_extract_filebased(['20140920' '_' '1'],[440 447.25 453.75 459.75],1); % 4
Feature_extract_filebased(['20140920' '_' '1'],[440 447.25 454    460   ],2); % 4
Feature_extract_filebased(['20140930' '_' '0'],[482.25 490.75 497.75 503.75],1); % 4
Feature_extract_filebased(['20140930' '_' '0'],[482.5  491    497.75 504   ],2); % 4
Feature_extract_filebased(['20141006' '_' '0'],[491.75 502.75 512.5  522   ],1); % 4
Feature_extract_filebased(['20141006' '_' '0'],[492    503    512.75 522.25],2); % 4
Feature_extract_filebased(['20141007' '_' '0'],[465    476.5  488 499.5 ],1); % 4
Feature_extract_filebased(['20141007' '_' '0'],[465.25 476.75 488 499.75],2); % 4
% 43

% sit
Feature_extract_filebased(['20140920' '_' '5'],[25.25 40.25],1); % 2
Feature_extract_filebased(['20140920' '_' '5'],[25    40.5 ],2); % 2
Feature_extract_filebased(['20140920' '_' '0'],[374.25 380.75 388.25 395],1); % 4
Feature_extract_filebased(['20140920' '_' '0'],[       380.75 388.25    ],2); % 2
Feature_extract_filebased(['20140920' '_' '1'],[476.75 485.5 491.75 500.25],1); % 4
Feature_extract_filebased(['20140920' '_' '1'],[477    485.5 491.75 500.25],2); % 4
Feature_extract_filebased(['20140930' '_' '0'],[521.5  529.75 538.5 547],1); % 4
Feature_extract_filebased(['20140930' '_' '0'],[521.75 529.75 538.5 547],2); % 4
Feature_extract_filebased(['20141006' '_' '0'],[549.25 562.25 573.5 584],1); % 4
Feature_extract_filebased(['20141006' '_' '0'],[549.25 562.25 573.5 584],2); % 4
Feature_extract_filebased(['20141007' '_' '0'],[525.5 539.5 552.5 566.25],1); % 4
Feature_extract_filebased(['20141007' '_' '0'],[525.5 539.5 552.5 566.25],2); % 4
% 42
];

save('feature_nofall.mat','feature_nofall')

plot(feature_fall(:,1),feature_fall(:,2),'r*','MarkerSize',10)
plot(feature_nofall(:,1),feature_nofall(:,2),'b*','MarkerSize',10)

feature_fall=importdata('feature_fall.mat');
feature_nofall=importdata('feature_nofall.mat');
training_data.feature=[feature_fall;feature_nofall];
training_data.label=[ones(size(feature_fall,1),1);2*ones(size(feature_nofall,1),1)];

save('data\KNN_training_data\KNN_training_data.mat','training_data')
end

function testing_data=gen_testing_data
%global fs;
%global window_size;
%global visible;

%% Fall event
% falling
feature_fall=Feature_extract_filebased(['20140822' '_' '7'],[28.75 53.75 77 97.25]); % 4
feature_fall=[feature_fall;Feature_extract_filebased(['20140822' '_' '8'],[34.25 58.25 82.75 107.5 127.5 147.25])]; % 6

%% Non-Fall event
% stand up from ground
feature_nofall=Feature_extract_filebased(['20140822' '_' '12'],[25.5 45.5 67 88 109.5 132]); % 6
% walking or standing
feature_nofall=[feature_nofall;Feature_extract_filebased(['20140822' '_' '12'],[27 48 71 91.5 113 135])]; % 6

testing_data.feature=[feature_fall;feature_nofall];
save('data\KNN_testing_data\KNN_testing_data.mat','testing_data')
end

function plot_testingdata(feature_array,time_interval)

feature_normalized(:,1)=feature_array(:,1);

for f_ind=1:size(feature_array,2)-1
    feature_normalized(:,f_ind+1)=(feature_array(:,f_ind+1)-min(feature_array(:,f_ind+1)))/(max(feature_array(:,f_ind+1))-min(feature_array(:,f_ind+1)));
end

figure
subplot(211)
%plot(time_interval,feature_normalized(:,1),'b*','Markersize',8)
plot(feature_normalized(:,1),'b*','Markersize',8)
title('Label')
subplot(212)
plot(feature_normalized(:,2:end))
title('Feature')
end

function test_sequence_feature=test_sequence(testseq_filename,time_interval)
test_sequence_feature=Feature_extract_filebased(testseq_filename,time_interval);
save(['data\KNN_testing_data\test_sequence\' testseq_filename '.mat'],'test_sequence_feature')
end