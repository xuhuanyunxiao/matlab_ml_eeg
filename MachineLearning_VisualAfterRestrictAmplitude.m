function MachineLearning_VisualAfterRestrictAmplitude(data)

global ML
ChannelNum = ML.Parameter.ChannelNum;
ConditionName = ML.DataDescription.ConditionName;
ConditionNum = ML.Parameter.ConditionNum;
ExperimentType = ML.DataDescription.ExperimentType;
RawPreprocessingWay = ML.Parameter.RawPreprocessingWay;
Amplitude = ML.Parameter.Amplitude;

%% Data
RawDataFileName = data.ML.RawPreprocessing.AfterRestrictAmplitudeDataFileName;
RawDataLabel = data.AfterRestrictAmplitudeDataLabel;
RawData = data.AfterRestrictAmplitudeData;

%
FigName = [ML.FolderName.VisualRawPreprocessingFolder,'\ML_7_VisualRawPreprocessing'];
%% 所有数据三维图显示：时长-文件数-振幅 mesh
if ML.RawPreprocessing.AfterRestrictAmplitude_meshrawon
    for Chan = 1: ChannelNum
        for Cond = 1:ConditionNum
            ConRawDatas = GetDispData(RawData,RawDataLabel);
            flag = 2;
            MachineLearning_ThreeDimensionFig(ConRawDatas,Chan,Cond,flag);
            title({['ML-7-VisualRawPreprocessing  ExperimentType=',num2str(ExperimentType)];...
                [' RawPreprocessingWay=' num2str(RawPreprocessingWay),...
                ' Amplitude=' num2str(Amplitude)];...
                [ConditionName{Cond},'     Channel=： ',num2str(Chan)]},'fontsize',18);
            saveas(gcf,[FigName,'_3_Preview_3D_ExperimentType=',num2str(ExperimentType),...
                '_RawPreprocessingWay=' num2str(RawPreprocessingWay),...
                '_Amplitude=' num2str(Amplitude),...
                '_',ConditionName{Cond},'_channel=',num2str(Chan),'.jpg']);        
        end
    end
end

%% 数据量统计及显示：日期名-文件数
MachineLearning_DayFilesDescriptiveStatisticsFig(RawDataFileName,RawDataLabel);
title({['ML-7-VisualRawPreprocessing  ExperimentType=',num2str(ExperimentType)];...
                [' RawPreprocessingWay=' num2str(RawPreprocessingWay),...
                ' Amplitude=' num2str(Amplitude)];...
                ['每天各条件下的文件数为： ']},'fontsize',20);
saveas(gcf,[FigName,'_4_DescriptiveStatistics_ExperimentType=',num2str(ExperimentType),...
    '_RawPreprocessingWay=' num2str(RawPreprocessingWay),...
    '_Amplitude=' num2str(Amplitude),...
    '.jpg']);
end


function ConRawDatas = GetDispData(RawData,RawDataLabel)
global ML
ChannelNum = ML.Parameter.ChannelNum;
ConditionNum = ML.Parameter.ConditionNum;

% 生成画图用数据
% RawDataLabel：条件、天数、文件数
ConRawDatas = cell(ChannelNum,ConditionNum); % 行为通道排布，列为条件排布
for Cond = 1:ConditionNum
    ConRawData = RawData(RawDataLabel(:,1) == Cond,:);  % 每种条件的数据
    if ~isempty(ConRawData)
        % 以条件将数据汇总
        for fileN = 1:length(ConRawData(:,1))
            for Chan = 1:ChannelNum
                ConRawDatas{Cond,Chan}(fileN,:) = ConRawData{fileN,:};
            end
        end
    end
end

end