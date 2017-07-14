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
%% ����������άͼ��ʾ��ʱ��-�ļ���-��� mesh
if ML.ImportDataParameter.meshrawon
    for Chan = 1: ChannelNum
        for Cond = 1:ConditionNum
            ConRawDatas = GetDispData(RawData,RawDataLabel);
            flag = 1;
            MachineLearning_ThreeDimensionFig(ConRawDatas,Chan,Cond,flag);
            title({['ML-6-ImportRawData  ExperimentType=',num2str(ExperimentType)],...
                [ConditionName{Cond},'     Channel=�� ',num2str(Chan)]},'fontsize',18);
            saveas(gcf,[FigName,'_1_Preview_3D_ExperimentType=',num2str(ExperimentType),'_',ConditionName{Cond},'_channel=',num2str(Chan),'.jpg']);
        end
    end
end

%% ������ͳ�Ƽ���ʾ��������-�ļ���
MachineLearning_DayFilesDescriptiveStatisticsFig(RawDataFileName,RawDataLabel);
title({['ML-6-ImportRawData  ExperimentType=',num2str(ExperimentType)];...
                'ÿ��������µ��ļ���Ϊ�� '},'fontsize',20);
saveas(gcf,[FigName,'_2_DescriptiveStatistics_ExperimentType=',num2str(ExperimentType),'.jpg']);

end


function ConRawDatas = GetDispData(RawData,RawDataLabel)
global ML
ChannelNum = ML.Parameter.ChannelNum;
ConditionNum = ML.Parameter.ConditionNum;

% ���ɻ�ͼ������
% RawDataLabel���������������ļ���
ConRawDatas = cell(ChannelNum,ConditionNum); % ��Ϊͨ���Ų�����Ϊ�����Ų�
for Cond = 1:ConditionNum
    ConRawData = RawData(RawDataLabel(:,1) == Cond,:);  % ÿ������������
    if ~isempty(ConRawData)
        % �����������ݻ���
        for fileN = 1:length(ConRawData(:,1))
            for Chan = 1:ChannelNum
                ConRawDatas{Cond,Chan}(fileN,:) = ConRawData{fileN,:};
            end
        end
    end
end

end