function MachineLearning_EEG
% xuhuan
% �Ľ���20161017��
% 1.�������ݷ����������ܣ��������ݴ洢����������
% 2.ʹ���µı���������ʽ
% 3.ʹ��ȫ�ֱ����Ľ������洢���������ݣ�global ML
% 4.�����µ�EEG������TimeSeries
% 5.���������ϴ���裺
% 6.�޸�SVM��BP��code������������㷨
% 7.���¹滮ģ��������ϵ
% 8.�µĻ���ѧϰ������Bayesian��KNN��20161020��
% 9.������ӻ���20161031��

% �д��Ľ���20161017��
% 1.�����µ�EEG�������������У�
% 2.�������Ч�ʣ�GPU ���㡢���м���
% 3.��ͨ������code
% 4.����ѧϰ����Ŀ��ӻ�

global ML
%% ��������
% ԭʼ���ݣ�txt�������ļ��У���֯��ʽ�ǣ��졢�������ļ�����ͨ����
% ����ͨ��
% ML.DataDescription.DataFolder = 'D:\summerEEGdata\twochannel';
% ��ͨ�� 10sÿ��
% ML.DataDescription.DataFolder = 'D:\summerEEGdata\Data_Divided_10s';
% ��ͨ�� 5sÿ��
ML.DataDescription.DataFolder = 'D:\summerEEGdata\Data2_5s';

ML.DataDescription.ProgramFolder = 'D:\XH\analysis_prog\ML_multiclass0929'; % ���������ļ���
addpath(genpath(ML.DataDescription.ProgramFolder));

ML.DataDescription.ExperimentType = 2; % ����ʵ������
switch ML.DataDescription.ExperimentType
    case 1
        ML.DataDescription.ConditionName ={'hungry','thirsty','wake','sleep'};  % conlabel = 1 2 3 4 5 ...
    case 2
        ML.DataDescription.ConditionName ={'perfume','vinegar','wake'};
    case 3
        ML.DataDescription.ConditionName ={'perfume','vinegar','wake','muse'};
    case 4
        ML.DataDescription.ConditionName ={'perfume','vinegar','muse'};
    case 5
        ML.DataDescription.ConditionName ={'perfume','vinegar'};
end
ML.DataDescription.ExperimentName ={'˵��ʵ��(�������ڿʡ����ѡ�˯��)';'������ζʵ��(���͡���ζ������)';'������ζʵ�飨���͡���ζ�����ѡ�cherry��';...
    '������ζʵ�飨���͡���ζ��cherry��';'��������ζʵ��(���͡���ζ)'};

% ����
ML.DataDescription.DayName ={'Day20160802','Day20160803','Day20160804','Day20160805','Day20160808','Day20160809','Day20160810',...
    'Day20160811','Day20160812','Day20160815','Day20160816','Day20160817','Day20160818',...
    'Day20160819','Day20160820','Day20160821','Day20160822','Day20160823',...
    'Day20160824','Day20160825','Day20160826','Day20160830','Day20160831','Day20160901','Day20160902','Day20160905','Day20160906',...
    'Day20160907','Day20160908','Day20160909','Day20160912','Day20160913','Day20160914','Day20160918','Day20160919','Day20160920',...
    'Day20160921','Day20160922','Day20160923','Day20160926','Day20160927','Day20160928','Day20161011','Day20161012','Day20161013',...
    'Day20161014','Day20161017','Day20161018','Day20161019','Day20161020','Day20161021','Day20161024','Day20161026','Day20161027',...
    'Day20161028'};
% ML.DataDescription.DayName ={'Day20160802','Day20160803','Day20160804','Day20160805','Day20160808','Day20160809','Day20160810','Day20160811','Day20160812',...
% };
% ML.DataDescription.DayName ={'Day20160907','Day20160908'};

% 1 ��������
ML.Parameter.IsImportData = 0;  % �Ƿ�������  (0��1)
ML.Parameter.fs = 512;
ML.Parameter.locutoff = 1;
ML.Parameter.hicutoff = 20;
ML.Parameter.ChannelNum = 1; %%%% ��Ҫ���ǵ����ã������� %%%%
ML.Parameter.ConditionNum = length(ML.DataDescription.ConditionName);

% 2 Ԥ����
ML.Parameter.IsRawPreprocessing = 0; % �Ƿ����Ԥ������  (0��1)
ML.Parameter.RawPreprocessingWay  = 8; % Ԥ����ķ�ʽ  (1-9)
ML.Parameter.RejectChannelThreshold = 5 ; % threshold��ʹ��RejChanʱ�ı�׼��һ��Ϊ5

% ͨ������EEG�����Χ��ѡ����
ML.Parameter.IsAfterRestrictAmplitude = 0; % ��Ԥ�������޷�
ML.Parameter.IsBeforeRestrictAmplitude = 1;
if ML.Parameter.IsAfterRestrictAmplitude == 1 || ML.Parameter.IsBeforeRestrictAmplitude == 1
    ML.Parameter.Amplitude = 150;
else
    ML.Parameter.Amplitude = 0;
end

% 3 ��������
ML.Parameter.IsCalculateFeature = 1; % �Ƿ������������  (0��1)
ML.Parameter.FeatureType = 1; % ��������������  (1-4)
ML.Parameter.FeatureTypeName = {'PSD';'PowerPecrcent';'TimeSeries';'FeatureCombine'};
% TimeSeries �Ǵӡ�EEG �Ե��źŷ�����������Ӧ�� by ��ӱ�ࡷ�ҵ��ĳ���
% ʱ������������LzC���Ӷȡ�Renyi�ء�Tsallis�ء�С���ء�����һά����x��y�Ļ���Ϣ
% FeatureCombine ���е������ϲ���һ��
ML.Parameter.DataForFeature = 1; % 1���޷������ݣ�2��δ�޷�����

% 4 ������ϴ�����������ѡ
ML.Parameter.IsFeaturePreprocessing = 0;  % �Ƿ����������ϴ���������  (0��1)
ML.Parameter.FeaturePreprocessingWay = 1;

% 5 ����ѧϰ�㷨
ML.Parameter.IsMachineLearning = 0; % �Ƿ���л���ѧϰ  (0��1)
ML.Parameter.MachineLearningMethod = 1; % �����ֻ���ѧϰ (1-5)
ML.Parameter.MachineLearningMethodName = {'SVM','BP','DecisionTree','NaiveBayes','KNN'};
ML.MachineLearning.DataForML = 2; % 1��δ���е��Ĳ���2�������˵��Ĳ�(������ѡ���������)

% 6 ���ӻ����
ML.Parameter.IsVisualImportRawData = 0; % �Ƿ���ӻ�ԭʼ���ݵ�ÿ������������ļ���  (0��1)
ML.Parameter.IsVisualRawPreprocessing = 0; % % �Ƿ���ӻ�Ԥ��������ݵ�ÿ������������ļ���  (0��1)
ML.Parameter.IsVisualAfterRestrictAmplitude = 0; % �޷�����ӻ�
ML.Parameter.IsVisualFeature = 0; % �Ƿ���ӻ�����������  (0��1)
ML.Parameter.IsVisualFeaturePreprocessing = 0; % �Ƿ���ӻ�������ϴ�����ѡ��Ľ��  (0��1)
ML.Parameter.IsVisualMachineLearning = 0; % �Ƿ���ӻ�����ѧϰ���  (0��1)

ML.History = [];
% �����ļ��нṹ �� �ļ���
MachineLearning_FolderStruct;
% ����������ṹ
MachineLearning_ParameterConfigure;
%% 1 �������� ImportRawData
% 1.0 ���޶���ֵ
if ML.Parameter.IsBeforeRestrictAmplitude
    
end

% 1.2 �������ݼ����ɶ�Ӧ��ǩ
if ML.Parameter.IsImportData
    [ImportRawData,ImportRawDataLabel] = MachineLearning_ImportRawData;
    save([ML.FileName.ImportRawDataFile,'.mat'],'ImportRawData','ImportRawDataLabel','ML');
    clear ImportRawData ImportRawDataLabel;
end

% 1.3 ԭʼ���ݿ��ӻ�
ML.ImportDataParameter.meshrawon = 1;
if ML.Parameter.IsVisualImportRawData
    data = load([ML.FileName.ImportRawDataFile,'.mat']);
    MachineLearning_VisualImportRawData(data);
    clear data
end

%% 2 EEG����Ԥ���� RawPreprocessing
% 2.2 EEG Ԥ����
if ML.Parameter.IsRawPreprocessing
    data = load([ML.FileName.ImportRawDataFile,'.mat']);
    ML.History = data.ML;
    [PreprocessedData,PreprocessedDataLabel, PreprocessedResult]...
        = MachineLearning_RawPreprocessing(data);
    % save data
    save([ML.FileName.RawPreprocessing,'.mat'],...
        'PreprocessedData','PreprocessedDataLabel','PreprocessedResult','ML');
    xlswrite([ML.FileName.RawPreprocessing,'.xlsx'],PreprocessedResult,'prepro','A1');
    clear PreprocessedData PreprocessedDataLabel
end

% 2.3 Ԥ�������ӻ�
ML.RawPreprocessing.Preprocessed_meshrawon = 1;
if ML.Parameter.IsVisualRawPreprocessing
    data = load([ML.FileName.RawPreprocessing,'.mat']);
    meshrawon = ML.RawPreprocessing.Preprocessed_meshrawon;
    MachineLearning_VisualRawPreprocessing(data);
    clear data
end

% 2.4 ���޶���ֵ
if ML.Parameter.IsAfterRestrictAmplitude
    data = load([ML.FileName.RawPreprocessing,'.mat']);
    ML.History = data.ML;
    [AfterRestrictAmplitudeData,AfterRestrictAmplitudeDataLabel, ResAmplitudeResult]...
        = MachineLearning_AfterRestrictAmplitude(data);
    % save data
    save([ML.FileName.RawPreprocessingRestrictAmplitude,'.mat'],...
        'AfterRestrictAmplitudeData','AfterRestrictAmplitudeDataLabel','ResAmplitudeResult','ML');
    xlswrite([ML.FileName.RawPreprocessingRestrictAmplitude,'.xlsx'],ResAmplitudeResult,'prepro','A1');
    clear AfterRestrictAmplitudeData AfterRestrictAmplitudeDataLabel
end

% 2.5 �޷�����ӻ�
ML.RawPreprocessing.AfterRestrictAmplitude_meshrawon = 1;
if ML.Parameter.IsVisualAfterRestrictAmplitude
    data = load([ML.FileName.RawPreprocessingRestrictAmplitude,'.mat']);
    MachineLearning_VisualAfterRestrictAmplitude(data);
    clear data
end

%% 3 ������ȡ FeatureResult
% 3.1 ��ȡ����
if ML.Parameter.IsCalculateFeature
    if ML.Parameter.DataForFeature  % ����EEGԤ��������ݣ����޷�������
        data = load([ML.FileName.RawPreprocessingRestrictAmplitude,'.mat']);
        ForFeatureData = data.AfterRestrictAmplitudeData;
        FeatureLabel = data.AfterRestrictAmplitudeDataLabel;
    else  % ����EEGԤ���������
        data = load([ML.FileName.RawPreprocessing,'.mat']);
        ForFeatureData = data.PreprocessedData;
        FeatureLabel = data.PreprocessedDataLabel;
    end
    ML.History = data.ML;clear data;
    
    switch ML.Parameter.FeatureType  % ����ֵ����
        case 1  % PSD
            ML.CalculateFeature.PSD.t_window =1;
            FeatureData = MachineLearning_CalFeaturePSDmultiChan(ForFeatureData);
        case 2  % PowerPecrcent
            ML.CalculateFeature.PowerPecrcent.t_window = 1;
            FeatureData = MachineLearning_CalFeaturePowerPmultiChan(ForFeatureData);
        case 3  % TimeSeries
            FeatureData = MachineLearning_CalFeatureTimeSeriesmultiChan(ForFeatureData);
        case 4 % Feature Combine
            FeatureData = MachineLearning_CalFeatureCombinemultiChan;
    end
    save([ML.FileName.FeatureType,'.mat'],'FeatureData','FeatureLabel','ML');
    
    % for python data
    if ML.Parameter.ChannelNum ==1
        for fileN = 1:length(FeatureData(:,1))
            featuredata(fileN,:) = FeatureData{fileN,1};
        end
    end    
    xlswrite([ML.FileName.FeatureType,'_FeatureData.xlsx'],featuredata,'FeatureData','A1');
    xlswrite([ML.FileName.FeatureType,'_FeatureLabel.xlsx'],FeatureLabel,'FeatureLabel','A1');
    
    clear data FeatureData 
end

% 3.2 ����ͳ�ƽ����ͼ
if ML.Parameter.IsVisualFeature
    % param
    ML.FeaturePlot.meshon = 1; % ��άͼ
    ML.FeaturePlot.boxon = 1; % ����ͼ
    ML.FeaturePlot.MSEon = 1; % ��ֵ��׼��
    ML.FeaturePlot.OtherFeatureStatistics = 1; % �������� �����ֲ�
    % data
    if exist([ML.FileName.FeatureStatictis,'.mat'], 'file')
        data = load([ML.FileName.FeatureStatictis,'.mat']);
    else
        % ����ֵ����ͳ��ֵ���㣬������
        % ����ͨ�����ݡ���ֵ����������������ֵ����׼���׼�󡢱���ϵ����ƫ�ȡ����
        data = load([ML.FileName.FeatureType,'.mat']);
        [ConditionChannelMatrixData,FMean,FMedian,FMode,FRange,FSD,FSE,FCV,FSkewness,FKurtosis] = ...
            MachineLearning_FeatureStatictis(data,1);
        save([ML.FileName.FeatureStatictis,'.mat'],'ConditionChannelMatrixData','FMean','FMedian','FMode','FRange',...
            'FSD','FSE','FCV','FSkewness','FKurtosis','ML');
        data = load([ML.FileName.FeatureStatictis,'.mat']);
    end
    %
    MachineLearning_VisualFeatureData(data);
end

%% 4 ������ϴ�����������ѡ
% 4.1 ����ֵ����Ԥ����
if ML.Parameter.IsFeaturePreprocessing
    data = load([ML.FileName.FeatureType,'.mat']);
    ML.History = data.ML;
    [PreprocessedFeatureData,PreprocessedFeatureLabel]= MachineLearning_FeaturePreprocessing(data);
    save([ML.FileName.FeaturePreprocessing,'.mat'],'PreprocessedFeatureData','PreprocessedFeatureLabel','ML');
    clear data PreprocessedFeatureData PreprocessedFeatureLabel
end

% 4.2 ����ֵ����Ԥ�������ӻ�
if ML.Parameter.IsVisualFeaturePreprocessing
    % param
    ML.PreprocessedFeaturePlot.meshon = 1; % ��άͼ
    ML.PreprocessedFeaturePlot.boxon = 1; % ����ͼ
    ML.PreprocessedFeaturePlot.MSEon = 1; % ��ֵ��׼��
    ML.PreprocessedFeaturePlot.OtherFeatureStatistics = 1; % �������� �����ֲ�    
    % data
    ML.Parameter.ChannelNum = 1;
    if exist([ML.FileName.PreprocessedFeatureStatictis,'.mat'], 'file')
        data = load([ML.FileName.PreprocessedFeatureStatictis,'.mat']);
    else
        % ����ֵ����ͳ��ֵ���㣬������
        % ����ͨ�����ݡ���ֵ����������������ֵ����׼���׼�󡢱���ϵ����ƫ�ȡ����
        data = load([ML.FileName.FeaturePreprocessing,'.mat']);
        [ConditionChannelMatrixData,FMean,FMedian,FMode,FRange,FSD,FSE,FCV,FSkewness,FKurtosis] = ...
            MachineLearning_FeatureStatictis(data,2);
        save([ML.FileName.PreprocessedFeatureStatictis,'.mat'],'ConditionChannelMatrixData','FMean','FMedian','FMode','FRange',...
            'FSD','FSE','FCV','FSkewness','FKurtosis','ML');
        data = load([ML.FileName.PreprocessedFeatureStatictis,'.mat']);
    end
    %
    MachineLearning_VisualPreprocessedFeatureData(data);
end

%% 5 ����ѧϰ
% 5.1 ����ѧϰ�㷨
if ML.Parameter.IsMachineLearning
    switch ML.MachineLearning.DataForML
        case 1 % û��������ϴ������
            data = load([ML.FileName.FeatureType,'.mat']);
            MLdata = data.FeatureData;
            MLlabel = data.FeatureLabel;
        case 2 % ������ϴ�������
            data = load([ML.FileName.FeaturePreprocessing,'.mat']);
            MLdata = data.PreprocessedFeatureData;
            MLlabel = data.PreprocessedFeatureLabel;
    end
    ML.History = data.ML;
    switch ML.Parameter.MachineLearningMethod
        case 1 % SVM: libsvm
            [Model,MLresult] = MachineLearning_SVM(MLdata,MLlabel);
            ML.SVM.Model = Model;
        case 2 % BP
            ML.BP.NetGenerateFunction = 'newff';  % 'newff' ��'feedforwardnet'
            [Model,MLresult] = MachineLearning_BP(MLdata,MLlabel);
            ML.BP.Model = Model;
        case 3 % DecisionTree
            ML.DecisionTree.IsPrune = 1; % �Ƿ��֦��������ȡ�1 ��֦��0 ����֦
            [Model,MLresult] = MachineLearning_DecisionTree(MLdata,MLlabel);
            ML.DecisionTree.Model = Model;
        case 4 % Bayesion
            [Model,MLresult] = MachineLearning_NaiveBayes(MLdata,MLlabel);
            ML.NaiveBayes.Model = Model;
        case 5 % KNN
            ML.KNN.CrossValidation.Parameter.Kvalue = 1:50; % K ��ȡֵ����СΪ1���Ϊ50
            [Model,MLresult] = MachineLearning_KNN(MLdata,MLlabel);
            ML.KNN.Model = Model;
    end
    save([ML.FileName.MachineLearning,'.mat'],'MLresult','Model','ML');
    
    % for excel
    SituationName = {ML.DataDescription.ExperimentName{ML.DataDescription.ExperimentType};...
        ML.Parameter.RawPreprocessingName;...
        ML.Parameter.FeatureTypeName{ML.Parameter.FeatureType};...
        ML.Parameter.FeaturePreprocessingName;...
        ML.Parameter.MachineLearningMethodName{ML.Parameter.MachineLearningMethod};...
        ['Amplitude',num2str(ML.Parameter.Amplitude)];...
        [num2str(ML.Parameter.ChannelNum),'Channel_',num2str(length(ML.DataDescription.DayName)),'DaysData']};
    xlswrite([ML.FileName.MachineLearning,'.xlsx'],SituationName,'ML_Result','A1');
    xlswrite([ML.FileName.MachineLearning,'.xlsx'],MLresult,'ML_Result','A10');    
end

% 5.2 ����ѧϰ������ӻ�
if ML.Parameter.IsVisualMachineLearning
    data = load([ML.FileName.MachineLearning,'.mat']);
    MachineLearning_Visual_ML_Result(data);
end

end