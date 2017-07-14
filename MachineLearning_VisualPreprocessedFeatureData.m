function MachineLearning_VisualPreprocessedFeatureData(data)
global ML

ConditionName = ML.DataDescription.ConditionName;
ConditionNum = ML.Parameter.ConditionNum;
ChannelNum = ML.Parameter.ChannelNum;
FeatureTypeName = ML.Parameter.FeatureTypeName;
FeatureType = ML.Parameter.FeatureType;
RawPreprocessingWay = ML.Parameter.RawPreprocessingWay;
ExperimentType = ML.DataDescription.ExperimentType;
Amplitude = ML.Parameter.Amplitude;
FeaturePreprocessingWay = ML.Parameter.FeaturePreprocessingWay;

%% data
ConditionChannelMatrixData = data.ConditionChannelMatrixData;
FMean = data.FMean ;
FMedian = data.FMedian;
FMode = data.FMode;
FRange = data.FRange;
FSD = data.FSD;
FSE = data.FSE;
FCV = data.FCV;
FSkewness = data.FSkewness;
FKurtosis = data.FKurtosis;

ML.FeaturePlot.XTickLabel = data.ML.FeaturePlot.XTickLabel;
%
FigName = [ML.FolderName.VisualFeaturePreprocessingResultFolder,'\ML_9_VisualFeaPreproResult',...
    '_ExpType=',num2str(ExperimentType),...
    '_RawPreproWay=' num2str(RawPreprocessingWay),...
    '_FeaType=',FeatureTypeName{FeatureType},...
    '_FeaPreproWay=',num2str(FeaturePreprocessingWay),...
    '_Amp=' num2str(Amplitude)];
TitleName = {['ML-9-VisualFeaturePreprocessingResult  ExperimentType=',num2str(ExperimentType)];...
            ['RawPreprocessingWay=' num2str(RawPreprocessingWay),' Amplitude=' num2str(Amplitude)];...
            ['FeatureType=',FeatureTypeName{FeatureType},' FeaturePreprocessingWay=',num2str(FeaturePreprocessingWay)]};
%% ����������άͼ��ʾ��ʱ��-�ļ���-��� mesh
if ML.PreprocessedFeaturePlot.meshon
    Chan = 1;flag = 3;
    for Cond = 1:ConditionNum
        MachineLearning_ThreeDimensionFig(ConditionChannelMatrixData,Chan,Cond,flag);
        title([TitleName;['   Condition= ',ConditionName{Cond}]],'fontsize',18);      
        saveas(gcf,[FigName,'_',ConditionName{Cond},'_channel=',num2str(Chan),'_1_Preview_3D','.jpg']);
    end
end

%% ��ͼ�������ֲ�����ֵ+��׼�
if ML.PreprocessedFeaturePlot.boxon
    for Chan = 1: ChannelNum
        MachineLearning_PlotBox(ConditionChannelMatrixData,FMean,FSD,Chan,TitleName);        
        saveas(gcf,[FigName,'_channel=',num2str(Chan),'_2_�����ֲ�����','.jpg']); % save
    end
end

%% ��ֵ+��׼��
% ����ÿ������ÿ��ͨ��������
ConditionChannelMatrixNameNum = cell(ConditionNum,ChannelNum);
for Chan = 1: ChannelNum
    for Cond = 1:ConditionNum
        ConditionChannelMatrixNameNum(Cond,Chan) = {[ConditionName{Cond},'��',num2str(length(ConditionChannelMatrixData{Cond,Chan}(:,1)))]};
    end
end

if ML.PreprocessedFeaturePlot.MSEon
    for Chan = 1: ChannelNum
        MachineLearning_Plot_M_SE(ConditionChannelMatrixNameNum,FMean,FSE,Chan);
        title([TitleName;['  Channel=',num2str(Chan)];...
            '3-��������ֵ��׼��'],'fontsize',18);        
        saveas(gcf,[FigName,...    % save
            '_',ConditionName{Cond},'_channel=',num2str(Chan),'_3_��������ֵ��׼��','.jpg']);
    end
end

%% ����ͳ��ֵ��
if ML.PreprocessedFeaturePlot.OtherFeatureStatistics
    for Chan = 1: ChannelNum
        % ��������
        MachineLearning_GetOtherFeatureStatisticsFig(ConditionChannelMatrixNameNum,FMedian,Chan,FigName,TitleName,1);% ����ͼ
        MachineLearning_GetOtherFeatureStatisticsFig(ConditionChannelMatrixNameNum,FMode,Chan,FigName,TitleName,2);% ����ͼ
        MachineLearning_GetOtherFeatureStatisticsFig(ConditionChannelMatrixNameNum,FRange,Chan,FigName,TitleName,3);% ����ͼ
        % �����ֲ�
        MachineLearning_GetOtherFeatureStatisticsFig(ConditionChannelMatrixNameNum,FCV,Chan,FigName,TitleName,4);% ����ϵ��ͼ
        MachineLearning_GetOtherFeatureStatisticsFig(ConditionChannelMatrixNameNum,FSkewness,Chan,FigName,TitleName,5);% ƫ��ͼ
        MachineLearning_GetOtherFeatureStatisticsFig(ConditionChannelMatrixNameNum,FKurtosis,Chan,FigName,TitleName,6);% ���ͼ
    end
end

end