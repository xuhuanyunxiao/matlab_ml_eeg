function MachineLearning_VisualImportRawData(data)

global ML
ChannelNum = ML.Parameter.ChannelNum;
ConditionName = ML.DataDescription.ConditionName;
ConditionNum = ML.Parameter.ConditionNum;
ExperimentType = ML.DataDescription.ExperimentType;

%% Data
RawDataFileName = data.ML.ImportRawData.ImportRawDataFileName;
RawDataLabel = data.ImportRawDataLabel;
RawData = data.ImportRawData;

%
FigName = [ML.FolderName.VisualImportRawDataFolder,'\ML_6_VisualImportData'];
%% 所有数据三维图显示：时长-文件数-振幅 mesh
if ML.ImportDataParameter.meshrawon
    for Chan = 1: ChannelNum
        for Cond = 1:ConditionNum
            ConRawDatas = GetDispData(RawData,RawDataLabel);
            flag = 1;
            MachineLearning_ThreeDimensionFig(ConRawDatas,Chan,Cond,flag);
            title({['ML-6-ImportRawData  ExperimentType=',num2str(ExperimentType)],...
                [ConditionName{Cond},'     Channel=： ',num2str(Chan)]},'fontsize',18);
            saveas(gcf,[FigName,'_1_Preview_3D_ExperimentType=',num2str(ExperimentType),'_',ConditionName{Cond},'_channel=',num2str(Chan),'.jpg']);
        end
    end
end

%% 数据量统计及显示：日期名-文件数
MachineLearning_DayFilesDescriptiveStatisticsFig(RawDataFileName,RawDataLabel);
title({['ML-6-ImportRawData  ExperimentType=',num2str(ExperimentType)];...
                '每天各条件下的文件数为： '},'fontsize',20);
saveas(gcf,[FigName,'_2_DescriptiveStatistics_ExperimentType=',num2str(ExperimentType),'.jpg']);

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