function MachineLearning_EEG
% xuhuan
% 改进：20161017加
% 1.更改数据分析的整体框架，包括数据存储及分析流程
% 2.使用新的变量命名方式
% 3.使用全局变量改进参数存储及参数传递：global ML
% 4.加入新的EEG特征，TimeSeries
% 5.添加特征清洗步骤：
% 6.修改SVM、BP的code，加入决策树算法
% 7.重新规划模型评价体系
% 8.新的机器学习方法：Bayesian、KNN（20161020）
% 9.结果可视化（20161031）

% 有待改进：20161017加
% 1.加入新的EEG特征（持续进行）
% 2.提高运算效率：GPU 计算、并行计算
% 3.多通道可用code
% 4.机器学习结果的可视化

global ML
%% 参数设置
% 原始数据（txt）所在文件夹：组织形式是：天、条件、文件数、通道数
% 两个通道
% ML.DataDescription.DataFolder = 'D:\summerEEGdata\twochannel';
% 单通道 10s每段
% ML.DataDescription.DataFolder = 'D:\summerEEGdata\Data_Divided_10s';
% 单通道 5s每段
ML.DataDescription.DataFolder = 'D:\summerEEGdata\Data2_5s';

ML.DataDescription.ProgramFolder = 'D:\XH\analysis_prog\ML_multiclass0929'; % 程序所在文件夹
addpath(genpath(ML.DataDescription.ProgramFolder));

ML.DataDescription.ExperimentType = 2; % 哪种实验条件
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
ML.DataDescription.ExperimentName ={'说话实验(饥饿、口渴、清醒、睡觉)';'两种气味实验(香油、醋味、清醒)';'三种气味实验（香油、醋味、清醒、cherry）';...
    '三种气味实验（香油、醋味、cherry）';'两种种气味实验(香油、醋味)'};

% 日期
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

% 1 导入数据
ML.Parameter.IsImportData = 0;  % 是否导入数据  (0、1)
ML.Parameter.fs = 512;
ML.Parameter.locutoff = 1;
ML.Parameter.hicutoff = 20;
ML.Parameter.ChannelNum = 1; %%%% 重要！记得设置！！！！ %%%%
ML.Parameter.ConditionNum = length(ML.DataDescription.ConditionName);

% 2 预处理
ML.Parameter.IsRawPreprocessing = 0; % 是否进行预处理步骤  (0、1)
ML.Parameter.RawPreprocessingWay  = 8; % 预处理的方式  (1-9)
ML.Parameter.RejectChannelThreshold = 5 ; % threshold：使用RejChan时的标准，一般为5

% 通过限制EEG振幅范围挑选数据
ML.Parameter.IsAfterRestrictAmplitude = 0; % 先预处理，再限幅
ML.Parameter.IsBeforeRestrictAmplitude = 1;
if ML.Parameter.IsAfterRestrictAmplitude == 1 || ML.Parameter.IsBeforeRestrictAmplitude == 1
    ML.Parameter.Amplitude = 150;
else
    ML.Parameter.Amplitude = 0;
end

% 3 特征类型
ML.Parameter.IsCalculateFeature = 1; % 是否进行特征计算  (0、1)
ML.Parameter.FeatureType = 1; % 用哪种特征数据  (1-4)
ML.Parameter.FeatureTypeName = {'PSD';'PowerPecrcent';'TimeSeries';'FeatureCombine'};
% TimeSeries 是从《EEG 脑电信号分析方法及其应用 by 李颖洁》找到的程序
% 时域特征包括：LzC复杂度、Renyi熵、Tsallis熵、小波熵、两个一维向量x和y的互信息
% FeatureCombine 所有的特征合并到一起
ML.Parameter.DataForFeature = 1; % 1，限幅后数据；2，未限幅数据

% 4 数据清洗和特征组合挑选
ML.Parameter.IsFeaturePreprocessing = 0;  % 是否进行数据清洗和特征组合  (0、1)
ML.Parameter.FeaturePreprocessingWay = 1;

% 5 机器学习算法
ML.Parameter.IsMachineLearning = 0; % 是否进行机器学习  (0、1)
ML.Parameter.MachineLearningMethod = 1; % 用哪种机器学习 (1-5)
ML.Parameter.MachineLearningMethodName = {'SVM','BP','DecisionTree','NaiveBayes','KNN'};
ML.MachineLearning.DataForML = 2; % 1，未进行第四步；2，进行了第四步(特征挑选与特征组合)

% 6 可视化结果
ML.Parameter.IsVisualImportRawData = 0; % 是否可视化原始数据的每天各种条件的文件数  (0、1)
ML.Parameter.IsVisualRawPreprocessing = 0; % % 是否可视化预处理后数据的每天各种条件的文件数  (0、1)
ML.Parameter.IsVisualAfterRestrictAmplitude = 0; % 限幅后可视化
ML.Parameter.IsVisualFeature = 0; % 是否可视化特征计算结果  (0、1)
ML.Parameter.IsVisualFeaturePreprocessing = 0; % 是否可视化特征清洗组合挑选后的结果  (0、1)
ML.Parameter.IsVisualMachineLearning = 0; % 是否可视化机器学习结果  (0、1)

ML.History = [];
% 创建文件夹结构 和 文件名
MachineLearning_FolderStruct;
% 创建参数结结构
MachineLearning_ParameterConfigure;
%% 1 导入数据 ImportRawData
% 1.0 先限定幅值
if ML.Parameter.IsBeforeRestrictAmplitude
    
end

% 1.2 导入数据及生成对应标签
if ML.Parameter.IsImportData
    [ImportRawData,ImportRawDataLabel] = MachineLearning_ImportRawData;
    save([ML.FileName.ImportRawDataFile,'.mat'],'ImportRawData','ImportRawDataLabel','ML');
    clear ImportRawData ImportRawDataLabel;
end

% 1.3 原始数据可视化
ML.ImportDataParameter.meshrawon = 1;
if ML.Parameter.IsVisualImportRawData
    data = load([ML.FileName.ImportRawDataFile,'.mat']);
    MachineLearning_VisualImportRawData(data);
    clear data
end

%% 2 EEG数据预处理 RawPreprocessing
% 2.2 EEG 预处理
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

% 2.3 预处理后可视化
ML.RawPreprocessing.Preprocessed_meshrawon = 1;
if ML.Parameter.IsVisualRawPreprocessing
    data = load([ML.FileName.RawPreprocessing,'.mat']);
    meshrawon = ML.RawPreprocessing.Preprocessed_meshrawon;
    MachineLearning_VisualRawPreprocessing(data);
    clear data
end

% 2.4 后限定幅值
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

% 2.5 限幅后可视化
ML.RawPreprocessing.AfterRestrictAmplitude_meshrawon = 1;
if ML.Parameter.IsVisualAfterRestrictAmplitude
    data = load([ML.FileName.RawPreprocessingRestrictAmplitude,'.mat']);
    MachineLearning_VisualAfterRestrictAmplitude(data);
    clear data
end

%% 3 特征提取 FeatureResult
% 3.1 提取特征
if ML.Parameter.IsCalculateFeature
    if ML.Parameter.DataForFeature  % 导入EEG预处理后数据，且限幅后数据
        data = load([ML.FileName.RawPreprocessingRestrictAmplitude,'.mat']);
        ForFeatureData = data.AfterRestrictAmplitudeData;
        FeatureLabel = data.AfterRestrictAmplitudeDataLabel;
    else  % 导入EEG预处理后数据
        data = load([ML.FileName.RawPreprocessing,'.mat']);
        ForFeatureData = data.PreprocessedData;
        FeatureLabel = data.PreprocessedDataLabel;
    end
    ML.History = data.ML;clear data;
    
    switch ML.Parameter.FeatureType  % 特征值计算
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

% 3.2 特征统计结果画图
if ML.Parameter.IsVisualFeature
    % param
    ML.FeaturePlot.meshon = 1; % 三维图
    ML.FeaturePlot.boxon = 1; % 箱线图
    ML.FeaturePlot.MSEon = 1; % 均值标准误
    ML.FeaturePlot.OtherFeatureStatistics = 1; % 中心趋势 样本分布
    % data
    if exist([ML.FileName.FeatureStatictis,'.mat'], 'file')
        data = load([ML.FileName.FeatureStatictis,'.mat']);
    else
        % 特征值样本统计值计算，包括：
        % 条件通道数据、均值、中数、众数、极值、标准差、标准误、变异系数、偏度、峰度
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

%% 4 特征清洗和特征组合挑选
% 4.1 特征值样本预处理
if ML.Parameter.IsFeaturePreprocessing
    data = load([ML.FileName.FeatureType,'.mat']);
    ML.History = data.ML;
    [PreprocessedFeatureData,PreprocessedFeatureLabel]= MachineLearning_FeaturePreprocessing(data);
    save([ML.FileName.FeaturePreprocessing,'.mat'],'PreprocessedFeatureData','PreprocessedFeatureLabel','ML');
    clear data PreprocessedFeatureData PreprocessedFeatureLabel
end

% 4.2 特征值样本预处理后可视化
if ML.Parameter.IsVisualFeaturePreprocessing
    % param
    ML.PreprocessedFeaturePlot.meshon = 1; % 三维图
    ML.PreprocessedFeaturePlot.boxon = 1; % 箱线图
    ML.PreprocessedFeaturePlot.MSEon = 1; % 均值标准误
    ML.PreprocessedFeaturePlot.OtherFeatureStatistics = 1; % 中心趋势 样本分布    
    % data
    ML.Parameter.ChannelNum = 1;
    if exist([ML.FileName.PreprocessedFeatureStatictis,'.mat'], 'file')
        data = load([ML.FileName.PreprocessedFeatureStatictis,'.mat']);
    else
        % 特征值样本统计值计算，包括：
        % 条件通道数据、均值、中数、众数、极值、标准差、标准误、变异系数、偏度、峰度
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

%% 5 机器学习
% 5.1 机器学习算法
if ML.Parameter.IsMachineLearning
    switch ML.MachineLearning.DataForML
        case 1 % 没有特征清洗的数据
            data = load([ML.FileName.FeatureType,'.mat']);
            MLdata = data.FeatureData;
            MLlabel = data.FeatureLabel;
        case 2 % 特征清洗后的数据
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
            ML.BP.NetGenerateFunction = 'newff';  % 'newff' ；'feedforwardnet'
            [Model,MLresult] = MachineLearning_BP(MLdata,MLlabel);
            ML.BP.Model = Model;
        case 3 % DecisionTree
            ML.DecisionTree.IsPrune = 1; % 是否剪枝，控制深度。1 剪枝；0 不剪枝
            [Model,MLresult] = MachineLearning_DecisionTree(MLdata,MLlabel);
            ML.DecisionTree.Model = Model;
        case 4 % Bayesion
            [Model,MLresult] = MachineLearning_NaiveBayes(MLdata,MLlabel);
            ML.NaiveBayes.Model = Model;
        case 5 % KNN
            ML.KNN.CrossValidation.Parameter.Kvalue = 1:50; % K 的取值，最小为1最大为50
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

% 5.2 机器学习结果可视化
if ML.Parameter.IsVisualMachineLearning
    data = load([ML.FileName.MachineLearning,'.mat']);
    MachineLearning_Visual_ML_Result(data);
end

end