function FeatureData = MachineLearning_CalFeaturePowerPmultiChan(data)
% power percent

global ML

hicutoff = ML.RawPreprocessing.hicutoff;
locutoff = ML.Parameter.locutoff ;
fs = ML.Parameter.fs;
t_window = ML.CalculateFeature.PowerPecrcent.t_window;
ChannelNum = ML.Parameter.ChannelNum;

% A:1-3Hz B:4-7Hz C:8-13Hz D1:14-20 D2:21-30 E1:31-50 E2:51-96
% δ（德尔塔）θ（西塔）α( 阿而法)β( 贝塔)γ(伽马）

Delta = 1:3; Theta = 4:7; Alpha = 8:13; Beta = 14:20;
Beta1 = 14:20; Beta2 = 21:30; Gamma = 31:40;
Gamma1 =31:50; Gamma2 = 50:hicutoff;

PowerPecrcent = cell(length(data(:,1)),ChannelNum);
for fileN = 1:length(data(:,1))
    for Chan = 1:ChannelNum
        EEGdata = double(data{fileN,Chan});
        % 功率谱密度
        nfft=fs;
        window=hamming(fs); %海明窗
        % window=boxcar(100); %矩形窗
        % window2=blackman(100); %blackman窗
        noverlap=25; % 一段数据与上段数据重叠25%
        [psd,f]=pwelch(EEGdata,window,noverlap,nfft,fs);
        psd = psd';
        psd = psd(1,locutoff+1:hicutoff*t_window+1);
        if locutoff > 1
            Delta = 1;
            del = 'Delta = 3';
        else 
            del = 'Delta = 1:3';
        end
        
        switch hicutoff
            case 20
                delta = sum(psd(1,Delta))/sum(psd(1,1:end));
                theta = sum(psd(1,Theta))/sum(psd(1,1:end));
                alpha = sum(psd(1,Alpha))/sum(psd(1,1:end));
                beta = sum(psd(1,Beta))/sum(psd(1,1:end));
                PowerPercent = [delta theta alpha beta];
                PowerPtitle = {del ,'Theta = 4:7','Alpha = 8:13','Beta = 14:20'};
            case 40
                delta = sum(psd(1,Delta))/sum(psd(1,1:end));
                theta = sum(psd(1,Theta))/sum(psd(1,1:end));
                alpha = sum(psd(1,Alpha))/sum(psd(1,1:end));
                beta1 = sum(psd(1,Beta1))/sum(psd(1,1:end));
                beta2 = sum(psd(1,Beta2))/sum(psd(1,1:end));
                gamma = sum(psd(1,Gamma))/sum(psd(1,1:end));
                PowerPercent = [delta theta alpha beta1 beta2 gamma];
                PowerPtitle = {del ,'Theta = 4:7','Alpha = 8:13','Beta1 = 14:20','Beta2 = 21:30','Gamma = 31:40'};
            case 96
                delta = sum(psd(1,Delta))/sum(psd(1,1:end));
                theta = sum(psd(1,Theta))/sum(psd(1,1:end));
                alpha = sum(psd(1,Alpha))/sum(psd(1,1:end));
                beta1 = sum(psd(1,Beta1))/sum(psd(1,1:end));
                beta2 = sum(psd(1,Beta2))/sum(psd(1,1:end));
                gamma1 = sum(psd(1,Gamma1))/sum(psd(1,1:end));
                gamma2 = sum(psd(1,Gamma2))/sum(psd(1,1:end));
                PowerPercent = [delta theta alpha beta1 beta2 gamma1 gamma2];
                PowerPtitle = {del ,'Theta = 4:7','Alpha = 8:13','Beta1 = 14:20','Beta2 = 21:30','Gamma1 = 31:50','Gamma2 = 51:96'};
        end
        
        PowerPecrcent(fileN,Chan) = {PowerPercent}; % 用于机器学习数据
    end
end

FeatureData = PowerPecrcent;
ML.CalculateFeature.PowerPecrcent.PowerPtitle = PowerPtitle;
ML.FeaturePlot.XTickLabel = PowerPtitle;

end