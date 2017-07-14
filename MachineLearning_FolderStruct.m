function MachineLearning_FolderStruct

global ML 

DataFolder = ML.DataDescription.DataFolder;
Day = ML.DataDescription.DayName; 
FeatureType = ML.Parameter.FeatureType;
FeatureTypeName = ML.Parameter.FeatureTypeName;
MachineLearningMethod = ML.Parameter.MachineLearningMethod;
MachineLearningMethodName = ML.Parameter.MachineLearningMethodName;

% 文件夹架构
if ~exist([DataFolder,'\A_result_for_',num2str(length(Day)),'_days_data'])
    mkdir([DataFolder,'\A_result_for_',num2str(length(Day)),'_days_data']);
end
ML.FolderName.ResultFolder = [DataFolder,'\A_result_for_',num2str(length(Day)),'_days_data'];
AllResultFolder = ML.FolderName.ResultFolder;

%% 一、数据流动文件夹结构~文件夹名~
% 1 原始数据（txt）导入
if ~exist([AllResultFolder,'\ML_1_ImportData'])
    mkdir([AllResultFolder,'\ML_1_ImportData']);
end
ML.FolderName.ImportRawDataFolder = [AllResultFolder,'\ML_1_ImportData'];

% 2 预处理结果（mat）：组织形式是：条件、通道、天、文件数
% 数据和标签分开
if ~exist([AllResultFolder,'\ML_2_RawPreprocessingResult'])
    mkdir([AllResultFolder,'\ML_2_RawPreprocessingResult']);
end
ML.FolderName.RawPreprocessingResultFolder = [AllResultFolder,'\ML_2_RawPreprocessingResult'];

% 3 特征提取结果
if ~exist([AllResultFolder,'\ML_3_FeatureResult_',FeatureTypeName{FeatureType}])
    mkdir([AllResultFolder,'\ML_3_FeatureResult_',FeatureTypeName{FeatureType}]);
end
ML.FolderName.FeatureResultFolder = [AllResultFolder,'\ML_3_FeatureResult_',FeatureTypeName{FeatureType}];

% 4 特征清洗和特征组合挑选结果
if ~exist([AllResultFolder,'\ML_4_FeaturePreprocessingResult_',FeatureTypeName{FeatureType}])
    mkdir([AllResultFolder,'\ML_4_FeaturePreprocessingResult_',FeatureTypeName{FeatureType}]);
end
ML.FolderName.FeaturePreprocessingResultFolder = [AllResultFolder,'\ML_4_FeaturePreprocessingResult_',FeatureTypeName{FeatureType}];

% 5 机器学习结果
if ~exist([AllResultFolder,'\ML_5_MachineLearningResult_',MachineLearningMethodName{MachineLearningMethod}])
    mkdir([AllResultFolder,'\ML_5_MachineLearningResult_',MachineLearningMethodName{MachineLearningMethod}]);
end
ML.FolderName.MachineLearningResultFolder = [AllResultFolder,'\ML_5_MachineLearningResult_',MachineLearningMethodName{MachineLearningMethod}];

%% 二、可视化结果~文件夹名~
% 1 导入数据后可视化
if ~exist([AllResultFolder,'\ML_6_VisualImportData'])
    mkdir([AllResultFolder,'\ML_6_VisualImportData']);
end
ML.FolderName.VisualImportRawDataFolder = [AllResultFolder,'\ML_6_VisualImportData'];

% 2 EEG数据预处理后可视化
if ~exist([AllResultFolder,'\ML_7_VisualRawPreprocessing'])
    mkdir([AllResultFolder,'\ML_7_VisualRawPreprocessing']);
end
ML.FolderName.VisualRawPreprocessingFolder = [AllResultFolder,'\ML_7_VisualRawPreprocessing'];

% 3 特征提取后可视化
if ~exist([AllResultFolder,'\ML_8_VisualFeatureResult_',FeatureTypeName{FeatureType}])
    mkdir([AllResultFolder,'\ML_8_VisualFeatureResult_',FeatureTypeName{FeatureType}]);
end
ML.FolderName.VisualFeatureResultFolder = [AllResultFolder,'\ML_8_VisualFeatureResult_',FeatureTypeName{FeatureType}];

% 4 特征预处理后可视化
if ~exist([AllResultFolder,'\ML_9_VisualFeaPreproResult_',FeatureTypeName{FeatureType}])
    mkdir([AllResultFolder,'\ML_9_VisualFeaPreproResult_',FeatureTypeName{FeatureType}]);
end
ML.FolderName.VisualFeaturePreprocessingResultFolder = [AllResultFolder,'\ML_9_VisualFeaPreproResult_',FeatureTypeName{FeatureType}];

% 5 机器学习后可视化
if ~exist([AllResultFolder,'\ML_10_VisualMachineLearningResult_',MachineLearningMethodName{MachineLearningMethod}])
    mkdir([AllResultFolder,'\ML_10_VisualMachineLearningResult_',MachineLearningMethodName{MachineLearningMethod}]);
end
ML.FolderName.VisualMachineLearningResultFolder = [AllResultFolder,'\ML_10_VisualMachineLearningResult_',MachineLearningMethodName{MachineLearningMethod}];

%% 三、所有图片和Excel结果保存到一起
if ~exist([AllResultFolder,'\ML_11_ImageAndExcel'])
    mkdir([AllResultFolder,'\ML_11_ImageAndExcel']);
end
ML.FolderName.ImageAndExcelFolder = [AllResultFolder,'\ML_11_ImageAndExcel'];

%% 四、数据流动~文件名~
% 1 原始数据（txt）导入后，存mat文件的文件名
ML.FileName.ImportRawDataFile = [ML.FolderName.ImportRawDataFolder,'\ML_1_ImportData_ExpType',...
    num2str(ML.DataDescription.ExperimentType),'_',num2str(ML.Parameter.ChannelNum),...
    'Channel_',num2str(length(ML.DataDescription.DayName)),'DaysData'];

% 2 预处理结果（mat）
ML.FileName.RawPreprocessing = [ML.FolderName.RawPreprocessingResultFolder,...
    '\ML_2_RawPrepro_ExpType',num2str(ML.DataDescription.ExperimentType),...
    '_RawPreproWay',num2str(ML.Parameter.RawPreprocessingWay),'_',...
    num2str(ML.Parameter.ChannelNum),'Channel_',num2str(length(ML.DataDescription.DayName)),'DaysData'];
ML.FileName.RawPreprocessingRestrictAmplitude = [ML.FolderName.RawPreprocessingResultFolder,...
    '\ML_2_RawPrepro_ExpType',num2str(ML.DataDescription.ExperimentType),...
    '_RawPreproWay',num2str(ML.Parameter.RawPreprocessingWay),...
    '_Amplitude',num2str(ML.Parameter.Amplitude),'_',...
    num2str(ML.Parameter.ChannelNum),'Channel_',num2str(length(ML.DataDescription.DayName)),'DaysData'];

% 3 特征提取结果
ML.FileName.FeatureType = [ML.FolderName.FeatureResultFolder,...
    '\ML_3_FeatureResult_ExpType',num2str(ML.DataDescription.ExperimentType),...
    '_RawPreproWay',num2str(ML.Parameter.RawPreprocessingWay),...
    '_FeaType',num2str(ML.Parameter.FeatureType),...
    '_Amplitude',num2str(ML.Parameter.Amplitude),'_',...
    num2str(ML.Parameter.ChannelNum),'Channel_',num2str(length(ML.DataDescription.DayName)),'DaysData'];
ML.FileName.FeatureStatictis = [ML.FolderName.VisualFeatureResultFolder,...
    '\ML_8_VisualFeature_ExpType',num2str(ML.DataDescription.ExperimentType),...
    '_RawPreproWay',num2str(ML.Parameter.RawPreprocessingWay),...
    '_FeaType',num2str(ML.Parameter.FeatureType),...
    '_Amplitude',num2str(ML.Parameter.Amplitude),'_',...
    num2str(ML.Parameter.ChannelNum),'Channel_',num2str(length(ML.DataDescription.DayName)),'DaysData'];

% 4 特征清洗和特征组合挑选结果
ML.FileName.FeaturePreprocessing = [ML.FolderName.FeaturePreprocessingResultFolder,...
    '\ML_4_FeaturePreprocessing_ExpType',num2str(ML.DataDescription.ExperimentType),...
    '_RawPreproWay',num2str(ML.Parameter.RawPreprocessingWay),...
    '_FeaType',num2str(ML.Parameter.FeatureType),...
    '_FeaPreproWay',num2str(ML.Parameter.FeaturePreprocessingWay),...
    '_Amplitude',num2str(ML.Parameter.Amplitude),'_',...
    num2str(ML.Parameter.ChannelNum),'Channel_',num2str(length(ML.DataDescription.DayName)),'DaysData'];
ML.FileName.PreprocessedFeatureStatictis = [ML.FolderName.VisualFeaturePreprocessingResultFolder,...
    '\ML_9_VisualFeaturePreprocessingResult_ExpType',num2str(ML.DataDescription.ExperimentType),...
    '_RawPreproWay',num2str(ML.Parameter.RawPreprocessingWay),...
    '_FeaPreproWay',num2str(ML.Parameter.FeaturePreprocessingWay),...
    '_FeaType',num2str(ML.Parameter.FeatureType),...
    '_Amplitude',num2str(ML.Parameter.Amplitude),'_',...
    num2str(ML.Parameter.ChannelNum),'Channel_',num2str(length(ML.DataDescription.DayName)),'DaysData'];

% 5 机器学习结果
ML.FileName.MachineLearning = [ML.FolderName.MachineLearningResultFolder,...
    '\ML_5_MachineLearning_ExpType',num2str(ML.DataDescription.ExperimentType),...
    '_RawPreproWay',num2str(ML.Parameter.RawPreprocessingWay),...
    '_FeaType',num2str(ML.Parameter.FeatureType),...
    '_FeaPreproWay',num2str(ML.Parameter.FeaturePreprocessingWay),...
    '_MLmethod',num2str(ML.Parameter.MachineLearningMethod),...
    '_Amplitude',num2str(ML.Parameter.Amplitude),'_',...
    num2str(ML.Parameter.ChannelNum),'Channel_',num2str(length(ML.DataDescription.DayName)),'DaysData'];
ML.FileName.MachineLearningStatictis = [ML.FolderName.VisualMachineLearningResultFolder,...
    '\ML_10_VisualMachineLearningResult_ExpType',num2str(ML.DataDescription.ExperimentType),...
    '_RawPreproWay',num2str(ML.Parameter.RawPreprocessingWay),...
    '_FeaType',num2str(ML.Parameter.FeatureType),...
    '_FeaPreproWay',num2str(ML.Parameter.FeaturePreprocessingWay),...
    '_MLmethod',num2str(ML.Parameter.MachineLearningMethod),...
    '_Amplitude',num2str(ML.Parameter.Amplitude),'_',...
    num2str(ML.Parameter.ChannelNum),'Channel_',num2str(length(ML.DataDescription.DayName)),'DaysData'];

end