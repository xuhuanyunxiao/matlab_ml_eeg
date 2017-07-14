function MachineLearning_VisualFeatureData(data)

global ML

ConditionName = ML.DataDescription.ConditionName;
ConditionNum = ML.Parameter.ConditionNum;
ChannelNum = ML.Parameter.ChannelNum;
FeatureTypeName = ML.Parameter.FeatureTypeName;
FeatureType = ML.Parameter.FeatureType;
RawPreprocessingWay = ML.Parameter.RawPreprocessingWay;
ExperimentType = ML.DataDescription.ExperimentType;
Amplitude = ML.Parameter.Amplitude;

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
FigName = [ML.FolderName.VisualFeatureResultFolder,'\ML_8_VisualFeatureResult',...
    '_ExperimentType=',num2str(ExperimentType),...
    '_RawPreprocessingWay=' num2str(RawPreprocessingWay),...
    '_FeatureType=',FeatureTypeName{FeatureType},...
    '_Amplitude=' num2str(Amplitude)];
TitleName = {['ML-8-VisualFeatureResult  ExperimentType=',num2str(ExperimentType)];...
            [' RawPreprocessingWay=' num2str(RawPreprocessingWay),' Amplitude=' num2str(Amplitude)];...
            ['FeatureType=',FeatureTypeName{FeatureType}]};
%% 所有数据三维图显示：时长-文件数-振幅 mesh
if ML.FeaturePlot.meshon
    Chan = 1;flag = 3;
    for Cond = 1:ConditionNum
        MachineLearning_ThreeDimensionFig(ConditionChannelMatrixData,Chan,Cond,flag);
        title([TitleName;['   Condition= ',ConditionName{Cond}]],'fontsize',18);      
        saveas(gcf,[FigName,'_',ConditionName{Cond},'_channel=',num2str(Chan),'_1_Preview_3D','.jpg']);
    end
end

%% 箱图：样本分布（均值+标准差）
if ML.FeaturePlot.boxon
    for Chan = 1: ChannelNum
        MachineLearning_PlotBox(ConditionChannelMatrixData,FMean,FSD,Chan,TitleName);        
        saveas(gcf,[FigName,'_channel=',num2str(Chan),'_2_样本分布总览','.jpg']); % save
    end
end

%% 均值+标准误
% 计算每种条件每个通道的数量
ConditionChannelMatrixNameNum = cell(ConditionNum,ChannelNum);
for Chan = 1: ChannelNum
    for Cond = 1:ConditionNum
        ConditionChannelMatrixNameNum(Cond,Chan) = {[ConditionName{Cond},'：',num2str(length(ConditionChannelMatrixData{Cond,Chan}(:,1)))]};
    end
end

if ML.FeaturePlot.MSEon
    for Chan = 1: ChannelNum
        MachineLearning_Plot_M_SE(ConditionChannelMatrixNameNum,FMean,FSE,Chan);
        title([TitleName;['  Channel=',num2str(Chan)];...
            '3-各条件均值标准误'],'fontsize',18);        
        saveas(gcf,[FigName,'_channel=',num2str(Chan),'_3_各条件均值标准误','.jpg']);
    end
end

%% 其他统计值：
if ML.FeaturePlot.OtherFeatureStatistics
    for Chan = 1: ChannelNum
        % 中心趋势
        MachineLearning_GetOtherFeatureStatisticsFig(ConditionChannelMatrixNameNum,FMedian,Chan,FigName,TitleName,1);% 中数图
        MachineLearning_GetOtherFeatureStatisticsFig(ConditionChannelMatrixNameNum,FMode,Chan,FigName,TitleName,2);% 众数图
        MachineLearning_GetOtherFeatureStatisticsFig(ConditionChannelMatrixNameNum,FRange,Chan,FigName,TitleName,3);% 极差图
        % 样本分布
        MachineLearning_GetOtherFeatureStatisticsFig(ConditionChannelMatrixNameNum,FCV,Chan,FigName,TitleName,4);% 差异系数图
        MachineLearning_GetOtherFeatureStatisticsFig(ConditionChannelMatrixNameNum,FSkewness,Chan,FigName,TitleName,5);% 偏度图
        MachineLearning_GetOtherFeatureStatisticsFig(ConditionChannelMatrixNameNum,FKurtosis,Chan,FigName,TitleName,6);% 峰度图
    end
end

end

