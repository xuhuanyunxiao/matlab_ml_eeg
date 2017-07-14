function [ConditionChannelMatrixData,FMean,FMedian,FMode,FRange,FSD,FSE,FCV,FSkewness,FKurtosis] = MachineLearning_FeatureStatictis(data,flag)

global ML

ConditionNum = ML.Parameter.ConditionNum;
ChannelNum = ML.Parameter.ChannelNum;

% 数据
switch flag
    case 1
        FeatureData = data.FeatureData;
        FeatureLabel = data.FeatureLabel;        
        % 把互信息放入通道内，各通道内互信息是一样的
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
        % 改造格式
        for fileN = 1:length(FeatureData(:,1))
            FeaData{fileN,1}(1,:) = FeatureData(fileN,:);
        end
        FeatureData = FeaData;
end
%%
for Cond = 1:ConditionNum
        ConditionData = FeatureData(FeatureLabel(:,1)==Cond,:);
    
    if ~isempty(ConditionData)
        % 以条件将数据汇总
        for fileN = 1:length(ConditionData(:,1))
            for Chan = 1:ChannelNum
                ConditionChannelMatrixData{Cond,Chan}(fileN,:) = ConditionData{fileN,:};
            end
        end
        
        % M、SD
        for Chan = 1: ChannelNum
            % 中心度量
            FMean(Cond,Chan)={mean(ConditionChannelMatrixData{Cond,Chan})}; % 均值
            FMedian(Cond,Chan)={median(ConditionChannelMatrixData{Cond,Chan})}; % 中位数
            FMode(Cond,Chan)={mode(ConditionChannelMatrixData{Cond,Chan})}; % 众数
            
            
            % 离散度量
            FRange(Cond,Chan)={range(ConditionChannelMatrixData{Cond,Chan})}; % 极差
            FSD(Cond,Chan)={std(ConditionChannelMatrixData{Cond,Chan})};  % 标准差
            n = length(ConditionChannelMatrixData{Cond,Chan}(:,1));
            FSE(Cond,Chan)={std(ConditionChannelMatrixData{Cond,Chan})/sqrt(n)};  % 标准误
            
            % 变异系数
            for F = 1:length(ConditionChannelMatrixData{Cond,Chan}(1,:))
                FCV{Cond,Chan}(F) = std(ConditionChannelMatrixData{Cond,Chan}(:,F))/mean(ConditionChannelMatrixData{Cond,Chan}(:,F));
            end
            
            % 分布度量
            FSkewness(Cond,Chan)={skewness(ConditionChannelMatrixData{Cond,Chan})}; % 偏度
            FKurtosis(Cond,Chan)={kurtosis(ConditionChannelMatrixData{Cond,Chan})}; % 峰度
        end
    end
end

end