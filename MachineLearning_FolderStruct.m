function MachineLearning_FolderStruct

global ML 

DataFolder = ML.DataDescription.DataFolder;
Day = ML.DataDescription.DayName; 
FeatureType = ML.Parameter.FeatureType;
FeatureTypeName = ML.Parameter.FeatureTypeName;
MachineLearningMethod = ML.Parameter.MachineLearningMethod;
MachineLearningMethodName = ML.Parameter.MachineLearningMethodName;

% �ļ��мܹ�
if ~exist([DataFolder,'\A_result_for_',num2str(length(Day)),'_days_data'])
    mkdir([DataFolder,'\A_result_for_',num2str(length(Day)),'_days_data']);
end
ML.FolderName.ResultFolder = [DataFolder,'\A_result_for_',num2str(length(Day)),'_days_data'];
AllResultFolder = ML.FolderName.ResultFolder;

%% һ�����������ļ��нṹ~�ļ�����~
% 1 ԭʼ���ݣ�txt������
if ~exist([AllResultFolder,'\ML_1_ImportData'])
    mkdir([AllResultFolder,'\ML_1_ImportData']);
end
ML.FolderName.ImportRawDataFolder = [AllResultFolder,'\ML_1_ImportData'];

% 2 Ԥ��������mat������֯��ʽ�ǣ�������ͨ�����졢�ļ���
% ���ݺͱ�ǩ�ֿ�
if ~exist([AllResultFolder,'\ML_2_RawPreprocessingResult'])
    mkdir([AllResultFolder,'\ML_2_RawPreprocessingResult']);
end
ML.FolderName.RawPreprocessingResultFolder = [AllResultFolder,'\ML_2_RawPreprocessingResult'];

% 3 ������ȡ���
if ~exist([AllResultFolder,'\ML_3_FeatureResult_',FeatureTypeName{FeatureType}])
    mkdir([AllResultFolder,'\ML_3_FeatureResult_',FeatureTypeName{FeatureType}]);
end
ML.FolderName.FeatureResultFolder = [AllResultFolder,'\ML_3_FeatureResult_',FeatureTypeName{FeatureType}];

% 4 ������ϴ�����������ѡ���
if ~exist([AllResultFolder,'\ML_4_FeaturePreprocessingResult_',FeatureTypeName{FeatureType}])
    mkdir([AllResultFolder,'\ML_4_FeaturePreprocessingResult_',FeatureTypeName{FeatureType}]);
end
ML.FolderName.FeaturePreprocessingResultFolder = [AllResultFolder,'\ML_4_FeaturePreprocessingResult_',FeatureTypeName{FeatureType}];

% 5 ����ѧϰ���
if ~exist([AllResultFolder,'\ML_5_MachineLearningResult_',MachineLearningMethodName{MachineLearningMethod}])
    mkdir([AllResultFolder,'\ML_5_MachineLearningResult_',MachineLearningMethodName{MachineLearningMethod}]);
end
ML.FolderName.MachineLearningResultFolder = [AllResultFolder,'\ML_5_MachineLearningResult_',MachineLearningMethodName{MachineLearningMethod}];

%% �������ӻ����~�ļ�����~
% 1 �������ݺ���ӻ�
if ~exist([AllResultFolder,'\ML_6_VisualImportData'])
    mkdir([AllResultFolder,'\ML_6_VisualImportData']);
end
ML.FolderName.VisualImportRawDataFolder = [AllResultFolder,'\ML_6_VisualImportData'];

% 2 EEG����Ԥ�������ӻ�
if ~exist([AllResultFolder,'\ML_7_VisualRawPreprocessing'])
    mkdir([AllResultFolder,'\ML_7_VisualRawPreprocessing']);
end
ML.FolderName.VisualRawPreprocessingFolder = [AllResultFolder,'\ML_7_VisualRawPreprocessing'];

% 3 ������ȡ����ӻ�
if ~exist([AllResultFolder,'\ML_8_VisualFeatureResult_',FeatureTypeName{FeatureType}])
    mkdir([AllResultFolder,'\ML_8_VisualFeatureResult_',FeatureTypeName{FeatureType}]);
end
ML.FolderName.VisualFeatureResultFolder = [AllResultFolder,'\ML_8_VisualFeatureResult_',FeatureTypeName{FeatureType}];

% 4 ����Ԥ�������ӻ�
if ~exist([AllResultFolder,'\ML_9_VisualFeaPreproResult_',FeatureTypeName{FeatureType}])
    mkdir([AllResultFolder,'\ML_9_VisualFeaPreproResult_',FeatureTypeName{FeatureType}]);
end
ML.FolderName.VisualFeaturePreprocessingResultFolder = [AllResultFolder,'\ML_9_VisualFeaPreproResult_',FeatureTypeName{FeatureType}];

% 5 ����ѧϰ����ӻ�
if ~exist([AllResultFolder,'\ML_10_VisualMachineLearningResult_',MachineLearningMethodName{MachineLearningMethod}])
    mkdir([AllResultFolder,'\ML_10_VisualMachineLearningResult_',MachineLearningMethodName{MachineLearningMethod}]);
end
ML.FolderName.VisualMachineLearningResultFolder = [AllResultFolder,'\ML_10_VisualMachineLearningResult_',MachineLearningMethodName{MachineLearningMethod}];

%% ��������ͼƬ��Excel������浽һ��
if ~exist([AllResultFolder,'\ML_11_ImageAndExcel'])
    mkdir([AllResultFolder,'\ML_11_ImageAndExcel']);
end
ML.FolderName.ImageAndExcelFolder = [AllResultFolder,'\ML_11_ImageAndExcel'];

%% �ġ���������~�ļ���~
% 1 ԭʼ���ݣ�txt������󣬴�mat�ļ����ļ���
ML.FileName.ImportRawDataFile = [ML.FolderName.ImportRawDataFolder,'\ML_1_ImportData_ExpType',...
    num2str(ML.DataDescription.ExperimentType),'_',num2str(ML.Parameter.ChannelNum),...
    'Channel_',num2str(length(ML.DataDescription.DayName)),'DaysData'];

% 2 Ԥ��������mat��
ML.FileName.RawPreprocessing = [ML.FolderName.RawPreprocessingResultFolder,...
    '\ML_2_RawPrepro_ExpType',num2str(ML.DataDescription.ExperimentType),...
    '_RawPreproWay',num2str(ML.Parameter.RawPreprocessingWay),'_',...
    num2str(ML.Parameter.ChannelNum),'Channel_',num2str(length(ML.DataDescription.DayName)),'DaysData'];
ML.FileName.RawPreprocessingRestrictAmplitude = [ML.FolderName.RawPreprocessingResultFolder,...
    '\ML_2_RawPrepro_ExpType',num2str(ML.DataDescription.ExperimentType),...
    '_RawPreproWay',num2str(ML.Parameter.RawPreprocessingWay),...
    '_Amplitude',num2str(ML.Parameter.Amplitude),'_',...
    num2str(ML.Parameter.ChannelNum),'Channel_',num2str(length(ML.DataDescription.DayName)),'DaysData'];

% 3 ������ȡ���
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

% 4 ������ϴ�����������ѡ���
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

% 5 ����ѧϰ���
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