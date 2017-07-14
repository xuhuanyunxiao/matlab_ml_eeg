function FeatureData = MachineLearning_CalFeaturePSDmultiChan(data)

global ML 

hicutoff = ML.RawPreprocessing.hicutoff;
locutoff = ML.Parameter.locutoff ;
fs = ML.Parameter.fs;
t_window = ML.CalculateFeature.PSD.t_window;
ChannelNum = ML.Parameter.ChannelNum;

PSD = cell(length(data(:,1)),ChannelNum);
for fileN = 1:length(data(:,1))
    for Chan = 1:ChannelNum
        EEGdata = double(data{fileN,Chan});
        % �������ܶ�
        nfft=fs * t_window;  % t_window = nfft / fs
        window=hamming(fs); %������
        % window=boxcar(100); %���δ�
        % window2=blackman(100); %blackman��
        noverlap=25; % һ���������϶������ص�25%
        [psd,f]=pwelch(EEGdata,window,noverlap,nfft,fs);
        psd = psd';
        PSD(fileN,Chan) = {psd(1,locutoff+1:hicutoff*t_window+1)};
    end
end
fHz = f(locutoff+1:hicutoff*t_window+1,1);

FeatureData = PSD;
ML.CalculateFeature.PSD.fHz = fHz;
ML.FeaturePlot.XTickLabel = num2cell(fHz');

end