function DefaultSetting
global fs;fs=16;

% Control whether to open the figure in each function or not
global visible;
visible.Tracking='off';
visible.Feature_extraction='off';
visible.Classifier='on';

global window_size;
window_size=1; % sec

%set(findall(gcf,'-property','FontSize'),'FontSize',12)

set(0,'DefaultAxesFontSize',12)
end