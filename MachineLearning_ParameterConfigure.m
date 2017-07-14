function MachineLearning_ParameterConfigure

global ML
hicutoff = ML.Parameter.hicutoff ;
locutoff = ML.Parameter.locutoff ;
%% 2 EEG预处理
switch ML.Parameter.RawPreprocessingWay
    case 1
        RejArti = 0; wavedenoise = 0; RejChan = 0;RemoveM = 0;Detr = 0;FIRband = 0;
        ML.Parameter.RawPreprocessingName = '不预处理：';
    case 2
        RejArti = 1; wavedenoise = 0; RejChan = 0; RemoveM = 1;Detr = 1;FIRband = 1;
        ML.Parameter.RawPreprocessingName = ['预处理：全部数据 去均值、去漂移、滤波' ' (带通为：' num2str(locutoff) '-' num2str(hicutoff) ')'];
    case 3
        RejArti = 1; wavedenoise = 0; RejChan = 1; RemoveM = 1;Detr = 1;FIRband = 1; 
        ML.Parameter.RawPreprocessingName = ['预处理：部分数据 去均值、去漂移、滤波' ' (带通为：' num2str(locutoff) '-' num2str(hicutoff) ')'];
    case 4
        RejArti = 1; wavedenoise = 0; RejChan = 0; RemoveM = 0;Detr = 0; FIRband = 1;
        ML.Parameter.RawPreprocessingName = ['预处理：全部数据 只滤波' ' (带通为：' num2str(locutoff) '-' num2str(hicutoff) ')'];
    case 5
        RejArti = 1; wavedenoise = 0; RejChan = 1; RemoveM = 0;Detr = 0; FIRband = 1; 
        ML.Parameter.RawPreprocessingName = ['预处理：部分数据 只滤波' ' (带通为：' num2str(locutoff) '-' num2str(hicutoff) ')'];
    case 6
        RejArti = 1; wavedenoise = 1; RejChan = 0; RemoveM = 0;Detr = 0; FIRband = 1;
        ML.Parameter.RawPreprocessingName = ['预处理：小波去噪 全部数据 只滤波' ' (带通为：' num2str(locutoff) '-' num2str(hicutoff) ')'];
    case 7
        RejArti = 1; wavedenoise = 1; RejChan = 1; RemoveM = 0;Detr = 0; FIRband = 1;
        ML.Parameter.RawPreprocessingName = ['预处理：小波去噪 部分数据 只滤波' ' (带通为：' num2str(locutoff) '-' num2str(hicutoff) ')'];        
    case 8
        RejArti = 1; wavedenoise = 1; RejChan = 0; RemoveM = 1;Detr = 1; FIRband = 1;
        ML.Parameter.RawPreprocessingName = ['预处理：小波去噪 全部数据 去均值、去漂移、滤波' ' (带通为：' num2str(locutoff) '-' num2str(hicutoff) ')'];
    case 9
        RejArti = 1; wavedenoise = 1; RejChan = 1; RemoveM = 1;Detr = 1; FIRband = 1;
        ML.Parameter.RawPreprocessingName = ['预处理：小波去噪 部分数据 去均值、去漂移、滤波' ' (带通为：' num2str(locutoff) '-' num2str(hicutoff) ')'];
end

ML.RawPreprocessing.WaveDenoise = wavedenoise;
ML.RawPreprocessing.hicutoff = hicutoff;
ML.RawPreprocessing.RejectChannel = RejChan;
ML.RawPreprocessing.RejectArtifact = RejArti;
ML.RawPreprocessing.RemoveMean = RemoveM;
ML.RawPreprocessing.Detrend = Detr;
ML.RawPreprocessing.FIRband = FIRband;

%% 4 特征清洗
switch ML.Parameter.FeaturePreprocessingWay
    case 1
        feaIntegration = 0 ;feaClean = 0 ; feaReduction = 0 ;feaTransformation = 1; % 变换到[0 1]
        ML.Parameter.FeaturePreprocessingName = '变换到[0 1]';
    case 2
        feaIntegration = 0 ;feaClean = 0 ; feaReduction = 1 ;feaTransformation = 1; % 统计挑选、变换到[0 1]
        ML.Parameter.FeaturePreprocessingName = '统计挑选、变换到[0 1]';
    case 3
        feaIntegration = 0 ;feaClean = 1 ; feaReduction = 1 ;feaTransformation = 1; % 直接去除出离群点、统计挑选、变换到[0 1]
        ML.Parameter.FeaturePreprocessingName = '直接去除出离群点、统计挑选、变换到[0 1]';
    case 4
        feaIntegration = 0 ;feaClean = 1 ; feaReduction = 0 ;feaTransformation = 1; % 直接去除出离群点、变换到[0 1]
        ML.Parameter.FeaturePreprocessingName = '直接去除出离群点、变换到[0 1]';
    case 5
        feaIntegration = 0 ;feaClean = 0 ; feaReduction = 0 ;feaTransformation = 4; % 小数定标规范化
        ML.Parameter.FeaturePreprocessingName = '小数定标规范化';
end

% feaIntegration 后面没有用到
ML.FeaturePreprocessing.feaClean = feaClean;
ML.FeaturePreprocessing.feaIntegration = feaIntegration ;
ML.FeaturePreprocessing.feaReduction = feaReduction ;
ML.FeaturePreprocessing.feaTransformation = feaTransformation ;


end