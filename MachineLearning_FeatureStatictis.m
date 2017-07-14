function [ConditionChannelMatrixData,FMean,FMedian,FMode,FRange,FSD,FSE,FCV,FSkewness,FKurtosis] = MachineLearning_FeatureStatictis(data,flag)

global ML

ConditionNum = ML.Parameter.ConditionNum;
ChannelNum = ML.Parameter.ChannelNum;

% ����
switch flag
    case 1
        FeatureData = data.FeatureData;
        FeatureLabel = data.FeatureLabel;        
        % �ѻ���Ϣ����ͨ���ڣ���ͨ���ڻ���Ϣ��һ����
        if ML.Parameter.FeatureType == 3 && ChannelNum > 1
            for fileN = 1:length(FeatureData(:,1))
                for Chan = 1: ChannelNum
                    FeaData{fileN,Chan}(1,:) = [FeatureData{fileN,Chan} FeatureData{fileN,ChannelNum+1}];
                end
            end
            FeatureData = FeaData;
        end
    case 2
        FeatureData = data.PreprocessedFeatureData;
        FeatureLabel = data.PreprocessedFeatureLabel;
        % �����ʽ
        for fileN = 1:length(FeatureData(:,1))
            FeaData{fileN,1}(1,:) = FeatureData(fileN,:);
        end
        FeatureData = FeaData;
end
%%
for Cond = 1:ConditionNum
        ConditionData = FeatureData(FeatureLabel(:,1)==Cond,:);
    
    if ~isempty(ConditionData)
        % �����������ݻ���
        for fileN = 1:length(ConditionData(:,1))
            for Chan = 1:ChannelNum
                ConditionChannelMatrixData{Cond,Chan}(fileN,:) = ConditionData{fileN,:};
            end
        end
        
        % M��SD
        for Chan = 1: ChannelNum
            % ���Ķ���
            FMean(Cond,Chan)={mean(ConditionChannelMatrixData{Cond,Chan})}; % ��ֵ
            FMedian(Cond,Chan)={median(ConditionChannelMatrixData{Cond,Chan})}; % ��λ��
            FMode(Cond,Chan)={mode(ConditionChannelMatrixData{Cond,Chan})}; % ����
            
            
            % ��ɢ����
            FRange(Cond,Chan)={range(ConditionChannelMatrixData{Cond,Chan})}; % ����
            FSD(Cond,Chan)={std(ConditionChannelMatrixData{Cond,Chan})};  % ��׼��
            n = length(ConditionChannelMatrixData{Cond,Chan}(:,1));
            FSE(Cond,Chan)={std(ConditionChannelMatrixData{Cond,Chan})/sqrt(n)};  % ��׼��
            
            % ����ϵ��
            for F = 1:length(ConditionChannelMatrixData{Cond,Chan}(1,:))
                FCV{Cond,Chan}(F) = std(ConditionChannelMatrixData{Cond,Chan}(:,F))/mean(ConditionChannelMatrixData{Cond,Chan}(:,F));
            end
            
            % �ֲ�����
            FSkewness(Cond,Chan)={skewness(ConditionChannelMatrixData{Cond,Chan})}; % ƫ��
            FKurtosis(Cond,Chan)={kurtosis(ConditionChannelMatrixData{Cond,Chan})}; % ���
        end
    end
end

end