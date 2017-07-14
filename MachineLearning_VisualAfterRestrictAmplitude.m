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
%% ����������άͼ��ʾ��ʱ��-�ļ���-��� mesh
if ML.RawPreprocessing.AfterRestrictAmplitude_meshrawon
    for Chan = 1: ChannelNum
        for Cond = 1:ConditionNum
            ConRawDatas = GetDispData(RawData,RawDataLabel);
            flag = 2;
            MachineLearning_ThreeDimensionFig(ConRawDatas,Chan,Cond,flag);
            title({['ML-7-VisualRawPreprocessing  ExperimentType=',num2str(ExperimentType)];...
                [' RawPreprocessingWay=' num2str(RawPreprocessingWay),...
                ' Amplitude=' num2str(Amplitude)];...
                [ConditionName{Cond},'     Channel=�� ',num2str(Chan)]},'fontsize',18);
            saveas(gcf,[FigName,'_3_Preview_3D_ExperimentType=',num2str(ExperimentType),...
                '_RawPreprocessingWay=' num2str(RawPreprocessingWay),...
                '_Amplitude=' num2str(Amplitude),...
                '_',ConditionName{Cond},'_channel=',num2str(Chan),'.jpg']);        
        end
    end
end

%% ������ͳ�Ƽ���ʾ��������-�ļ���
MachineLearning_DayFilesDescriptiveStatisticsFig(RawDataFileName,RawDataLabel);
title({['ML-7-VisualRawPreprocessing  ExperimentType=',num2str(ExperimentType)];...
                [' RawPreprocessingWay=' num2str(RawPreprocessingWay),...
                ' Amplitude=' num2str(Amplitude)];...
                ['ÿ��������µ��ļ���Ϊ�� ']},'fontsize',20);
saveas(gcf,[FigName,'_4_DescriptiveStatistics_ExperimentType=',num2str(ExperimentType),...
    '_RawPreprocessingWay=' num2str(RawPreprocessingWay),...
    '_Amplitude=' num2str(Amplitude),...
    '.jpg']);
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