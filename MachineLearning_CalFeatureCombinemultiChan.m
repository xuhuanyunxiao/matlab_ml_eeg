function FeatureData = MachineLearning_CalFeatureCombinemultiChan
global ML
ChannelNum = ML.Parameter.ChannelNum;

% 导入EEG预处理后数据
FeatureType = 1;
FileName = GetFeatureDataForCombine(FeatureType);
data = load([FileName,'.mat']);
PSD = data.FeatureData;
fHz = data.ML.FeaturePlot.XTickLabel;

FeatureType = 2;
FileName = GetFeatureDataForCombine(FeatureType);
data = load([FileName,'.mat']);
PowerPercent = data.FeatureData;
PowerPtitle = data.ML.FeaturePlot.XTickLabel;

FeatureType = 3;
FileName = GetFeatureDataForCombine(FeatureType);
data = load([FileName,'.mat']);
TimeSeries = data.FeatureData;    
TimeSeriesTitle = data.ML.FeaturePlot.XTickLabel;

FeatureType = 4; % 保证最后的文件夹结构恢复原样
GetFeatureDataForCombine(FeatureType);

% 组织数据
FeatureData = cell(length(PSD(:,1)),ChannelNum);
for fileN = 1:length(PSD(:,1))
    for Chan = 1:ChannelNum
        FeatureData{fileN,Chan} = [PSD{fileN,Chan} PowerPercent{fileN,Chan} TimeSeries{fileN,Chan}];
    end
end

%
ML.FeaturePlot.XTickLabel = [num2cell(fHz') PowerPtitle TimeSeriesTitle];

end

function  FileName = GetFeatureDataForCombine(FeatureType)
global ML
%
DataFolder = ML.DataDescription.DataFolder;
Day = ML.DataDescription.DayName; 
FeatureTypeName = ML.Parameter.FeatureTypeName;

%
ML.FolderName.ResultFolder = [DataFolder,'\A_result_for_',num2str(length(Day)),'_days_data'];
AllResultFolder = ML.FolderName.ResultFolder;

%
ML.Parameter.FeatureType = FeatureType;

ML.FolderName.FeatureResultFolder = [AllResultFolder,'\ML_3_FeatureResult_',FeatureTypeName{FeatureType}];

ML.FileName.FeatureType = [ML.FolderName.FeatureResultFolder,'\ML_3_FeatureResult_ExpType',...
    num2str(ML.DataDescription.ExperimentType),'_RawPreproWay',num2str(ML.Parameter.RawPreprocessingWay),...
    '_FeaType',num2str(ML.Parameter.FeatureType),'_Amplitude',num2str(ML.Parameter.Amplitude),'_',...
    num2str(ML.Parameter.ChannelNum),'Channel_',num2str(length(ML.DataDescription.DayName)),'DaysData'];

FileName = ML.FileName.FeatureType;

end



